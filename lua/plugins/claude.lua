return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<C-a>", nil, desc = "AI/Claude Code" },
    { "<C-a><C-a>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<C-a>f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<C-a>C", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<C-a>c", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<C-a>m", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<C-a>b", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<C-a>", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<C-a>",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<C-a>y", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<C-a>n", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
