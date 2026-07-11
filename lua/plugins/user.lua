--- User plugins: cursor animation and snacks.nvim (picker + dashboard) customization

-- Confirm action for file-opening pickers:
-- open in a vertical split by default, reuse the window when the buffer is
-- already visible in this tab, plain edit when the main window holds an
-- empty scratch buffer. Explicit edit-cmd keybinds (<c-s> split, <c-v>
-- vsplit, <c-t> tab) carry `action.cmd` and are passed through untouched.
local function vsplit_confirm(picker, item, action)
  local actions = require "snacks.picker.actions"
  if action.cmd then return actions.jump(picker, item, action) end
  local path = item and item.file and require("snacks.picker.util").path(item)
  if not (item and (item.buf or path)) then return actions.jump(picker, item, action) end
  local buf = item.buf or vim.fn.bufadd(path)
  local visible = false
  for _, w in ipairs(vim.fn.win_findbuf(buf)) do
    if
      vim.api.nvim_win_get_tabpage(w) == vim.api.nvim_get_current_tabpage()
      and vim.api.nvim_win_get_config(w).relative == ""
    then
      visible = true
      break
    end
  end
  local main_buf = picker.main and vim.api.nvim_win_is_valid(picker.main) and vim.api.nvim_win_get_buf(picker.main)
  local main_empty = main_buf
    and vim.api.nvim_buf_get_name(main_buf) == ""
    and vim.bo[main_buf].buftype == ""
    and not vim.bo[main_buf].modified
  local cmd = (visible or main_empty) and "edit" or "vsplit"
  return actions.jump(picker, item, vim.tbl_extend("force", {}, action, { cmd = cmd }))
end

---@type LazySpec
return {
  { "sphamba/smear-cursor.nvim", opts = {} },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        jump = { reuse_win = true },
        -- vsplit-by-default only for file-opening pickers; location pickers
        -- (lsp_*, lines, diagnostics, grep) keep the default in-window jump
        sources = {
          files = { confirm = vsplit_confirm },
          git_files = { confirm = vsplit_confirm },
          smart = { confirm = vsplit_confirm },
          recent = { confirm = vsplit_confirm },
          buffers = { confirm = vsplit_confirm },
        },
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
