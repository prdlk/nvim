--- User plugins: cursor animation and the central snacks.nvim configuration
--- (all snacks modules are configured here in one snacks.Config table)

-- Confirm action for file-opening pickers: <CR> opens the selection as a
-- tab via `tabdrop` (:tab drop semantics — focus the buffer if it's already
-- visible in any tab, don't spawn a tab from an empty buffer, else open a
-- new tab). Explicit edit-cmd keybinds (<S-CR>/<c-v> vsplit, <c-s> split)
-- carry `action.cmd` and are passed through untouched.
local function tab_confirm(picker, item, action)
  local actions = require "snacks.picker.actions"
  if action.cmd then return actions.jump(picker, item, action) end
  return actions.jump(picker, item, vim.tbl_extend("force", {}, action, { cmd = "tabdrop" }))
end

-- Tab-on-enter + vsplit-on-shift-enter for the file-opening pickers only;
-- location pickers (lsp_*, lines, diagnostics, grep) and sources with their
-- own confirm (git_branches, projects) keep their defaults.
local picker_sources = {}
for _, source in ipairs { "files", "git_files", "smart", "recent", "buffers" } do
  picker_sources[source] = {
    confirm = tab_confirm,
    win = {
      input = { keys = { ["<S-CR>"] = { "edit_vsplit", mode = { "n", "i" } } } },
      list = { keys = { ["<S-CR>"] = "edit_vsplit" } },
    },
  }
end

-- Smart picker: anchor to the current git repository. `config` runs when
-- the picker opens: cwd becomes the repo root (so the `files` finder scans
-- the whole repo, not just a rooter-chdir'd subdir) and `filter.cwd` drops
-- buffers/recent entries from other repos. Outside a repo, plain cwd
-- behavior is kept.
picker_sources.smart.config = function(opts)
  local root = require("snacks").git.get_root()
  if root then
    opts.cwd = root
    opts.filter = vim.tbl_extend("force", opts.filter or {}, { cwd = true })
  end
  return opts
end

---@type LazySpec
return {
  { "sphamba/smear-cursor.nvim", opts = {} },

  -- terminals are handled by kitty now
  { "akinsho/toggleterm.nvim", enabled = false },

  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        jump = { reuse_win = true },
        sources = picker_sources,
      },
      -- no dashboard: startup either restores the worktree/branch session or
      -- opens the git files picker (see config.session)
      dashboard = { enabled = false },

      -- GitHub issue/PR pickers and buffers (`<C-g>` binds in astrocore.lua)
      gh = {},

      -- auto-highlight LSP references of the symbol under the cursor;
      -- ]] / [[ jump binds live in plugins/astrolsp.lua (capability-gated)
      words = { enabled = true },
    },
  },

}
