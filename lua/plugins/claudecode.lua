-- Claude Code IDE integration via WebSocket MCP.
-- <C-a><C-a> opens/focuses a near-fullscreen snacks float; the same key inside
-- the terminal hides it (toggle). Visual-mode <C-a><C-a> sends the selection.
-- Neo-tree's <C-a> is wired separately (see lua/plugins/neotree.lua).

local toggle_key = "<C-a><C-a>"

---@type LazySpec
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSend",
    "ClaudeCodeAdd",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeSelectModel",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeStatus",
  },
  keys = {
    { toggle_key, "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "x" }, desc = "Toggle Claude Code" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
    { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
    { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },
  },
  opts = {
    git_repo_cwd = true,
    terminal = {
      provider = "snacks",
      ---@module "snacks"
      ---@type snacks.win.Config|{}
      snacks_win_opts = {
        position = "right",
        width = 0.3,
        height = 1,
        border = "rounded",
        backdrop = 60,
        keys = {
          claude_hide = {
            toggle_key,
            function(self) self:hide() end,
            mode = { "t", "n" },
            desc = "Hide Claude Code",
          },
        },
      },
    },
    diff_opts = {
      layout = "vertical",
      open_in_new_tab = false,
    },
  },
  config = true,
}
