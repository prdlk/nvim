--- mini.files as the default file explorer (replaces the yazi.nvim integration)
---
--- Navigation is stock mini.files (h/l columns, q close, `=` synchronize).
--- Neo-tree muscle memory is kept via buffer-local maps: `a` adds a file,
--- `A` adds a directory -- both prompt for the name via Snacks.input, create
--- the entry on disk immediately, and refresh the explorer (no `=` needed).

--- Open the explorer anchored at the current file (falls back to cwd for
--- terminals / pickers / unnamed buffers).
local function open_at_current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or vim.uv.fs_stat(path) == nil then path = vim.uv.cwd() end
  require("mini.files").open(path)
end

--- Buffer-local <C-x>/<C-v>/<C-t> (picker convention, matches the old yazi
--- binds): open entry under cursor in a horizontal/vertical split or new tab.
--- Recipe from :h MiniFiles-examples.
local function map_split(buf_id, lhs, direction)
  vim.keymap.set("n", lhs, function()
    local mf = require "mini.files"
    local entry = mf.get_fs_entry()
    if entry == nil or entry.fs_type ~= "file" then return end
    local new_target = vim.api.nvim_win_call(mf.get_explorer_state().target_window, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)
    mf.set_target_window(new_target)
    mf.go_in { close_on_file = true }
  end, { buffer = buf_id, desc = "Open in " .. direction .. " split" })
end

--- Prompt for a name with Snacks.input and create the entry inside the
--- focused explorer directory. Created directly on the file system (create
--- is not LSP-relevant, unlike rename/move), then MiniFiles.synchronize()
--- picks it up as an external change -- no confirmation dialog involved.
--- Neo-tree parity: `a` with a trailing `/` or nested `dir/file` also works.
---@param force_dir boolean `A`: always create a directory
local function add_entry(force_dir)
  local mf = require "mini.files"
  local state = mf.get_explorer_state()
  if state == nil then return end
  local dir = state.branch[state.depth_focus]
  -- show where the entry will land: cwd-relative when inside, else ~-relative
  -- (branch paths can carry a trailing slash, which defeats the `:.` reduce)
  local norm = dir:gsub("(.)/+$", "%1")
  local label = norm == vim.uv.cwd() and "." or vim.fn.fnamemodify(norm, ":~:.")
  require("snacks").input({
    prompt = (force_dir and "New directory in %s/" or "New file in %s/"):format(label),
  }, function(name)
    if name == nil or name == "" then return end
    vim.schedule(function()
      local path = vim.fs.joinpath(dir, (name:gsub("/+$", "")))
      if force_dir or vim.endswith(name, "/") then
        vim.fn.mkdir(path, "p")
      else
        vim.fn.mkdir(vim.fs.dirname(path), "p")
        local fd = vim.uv.fs_open(path, "a", 420) -- "a": never truncate existing
        if fd then vim.uv.fs_close(fd) end
      end
      mf.synchronize()
      -- put the cursor on the created (top-level) entry
      local seg = name:match "^[^/]+"
      for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        if line:find("/" .. vim.pesc(seg) .. "$") then
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          break
        end
      end
    end)
  end)
end

--- `d`: delete the entry under cursor after a quick Snacks.input confirm.
--- Deletes directly on disk, then MiniFiles.synchronize() refreshes the
--- explorer (external change -> no second mini.files dialog).
--- Buffer-edit deletion (visual-select + d + `=`) still works for bulk ops.
local function delete_entry()
  local mf = require "mini.files"
  local entry = mf.get_fs_entry()
  if entry == nil then return end
  local suffix = entry.fs_type == "directory" and "/" or ""
  require("snacks").input({
    prompt = ("Delete %s%s? [y/N]"):format(entry.name, suffix),
  }, function(answer)
    if answer == nil or not vim.tbl_contains({ "y", "yes" }, answer:lower()) then return end
    vim.schedule(function()
      vim.fn.delete(entry.path, "rf")
      mf.synchronize()
    end)
  end)
end

---@type LazySpec
return {
  {
    "nvim-mini/mini.files",
    -- load during startup: the `nvim <dir>` hijack (use_as_default_explorer)
    -- needs setup() to have run before the directory buffer is entered
    lazy = false,
    keys = {
      {
        "<C-e>",
        mode = { "n", "v" },
        function()
          if not require("mini.files").close() then open_at_current_file() end
        end,
        desc = "Toggle Explorer (mini.files)",
      },
      {
        "<leader>-",
        mode = { "n", "v" },
        open_at_current_file,
        desc = "Open mini.files at the current file",
      },
      {
        -- replaces AstroNvim's <Leader>o "Toggle Explorer Focus" (neo-tree)
        "<leader>o",
        open_at_current_file,
        desc = "Open Explorer (mini.files at current file)",
      },
      {
        "<leader>cw",
        function() require("mini.files").open(vim.uv.cwd(), false) end,
        desc = "Open mini.files in nvim's working directory",
      },
    },
    opts = {
      options = {
        -- take over `nvim <dir>` / :edit <dir> from netrw
        use_as_default_explorer = true,
        -- disable mini.files' own workspace/will*Files LSP hooks: renames are
        -- routed through Snacks.rename below instead (both active would send
        -- willRenameFiles twice and apply server workspace edits twice)
        lsp_timeout = 0,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        group = vim.api.nvim_create_augroup("minifiles_user_keys", { clear = true }),
        desc = "Neo-tree style a/A + picker-style split opens in mini.files buffers",
        callback = function(args)
          local buf = args.data.buf_id
          -- neo-tree muscle memory: prompt for a name, create, refresh
          vim.keymap.set("n", "a", function() add_entry(false) end, { buffer = buf, desc = "Add file" })
          vim.keymap.set("n", "A", function() add_entry(true) end, { buffer = buf, desc = "Add directory" })
          vim.keymap.set("n", "d", delete_entry, { buffer = buf, desc = "Delete entry" })
          map_split(buf, "<C-x>", "belowright horizontal")
          map_split(buf, "<C-v>", "belowright vertical")
          map_split(buf, "<C-t>", "tab")
        end,
      })

      -- LSP-integrated renames: `=` renames/moves fire these events after the
      -- fs change; Snacks.rename notifies clients and applies returned edits
      vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
        group = vim.api.nvim_create_augroup("minifiles_snacks_rename", { clear = true }),
        desc = "Notify LSP clients about mini.files renames/moves",
        callback = function(event) require("snacks").rename.on_rename_file(event.data.from, event.data.to) end,
      })
    end,
    init = function()
      -- netrw stays fully replaced (was set by the yazi spec before)
      vim.g.loaded_netrwPlugin = 1
    end,
  },

  -- neo-tree is fully replaced by mini.files (AstroNvim core ships it)
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
