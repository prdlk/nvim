--- User plugins: cursor animation and snacks.nvim (picker + dashboard) customization

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

---@type LazySpec
return {
  { "sphamba/smear-cursor.nvim", opts = {} },

  -- terminals are handled by kitty now
  { "akinsho/toggleterm.nvim", enabled = false },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        jump = { reuse_win = true },
        sources = picker_sources,
      },
      dashboard = {
        enabled = true,
        preset = {
          -- "prdlk.nvim" in ansi_regular block style
          header = table.concat({
            "██████  ██████  ██████  ██      ██   ██    ███    ██ ██    ██ ██ ███    ███",
            "██   ██ ██   ██ ██   ██ ██      ██  ██     ████   ██ ██    ██ ██ ████  ████",
            "██████  ██████  ██   ██ ██      █████      ██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██      ██   ██ ██   ██ ██      ██  ██     ██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██      ██   ██ ██████  ███████ ██   ██ ██ ██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          {
            icon = " ",
            desc = "Browse Repo",
            padding = 1,
            key = "b",
            action = function() Snacks.gitbrowse() end,
          },
          {
            icon = " ",
            desc = "Projects (ghq)",
            padding = 1,
            key = "p",
            action = function()
              local repos = vim.fn.systemlist "ghq list -p"
              vim.ui.select(repos, { prompt = "Select repository" }, function(dir)
                if not dir then return end
                vim.cmd.cd(dir)
                Snacks.picker.files()
              end)
            end,
          },
          { section = "startup" },
        },
      },
    },
  },

}
