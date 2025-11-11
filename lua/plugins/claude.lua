--- Claude Code integration for AI-powered development
--- Provides commands and keybindings for Claude Code assistant
--- @module plugins.claude

---@type LazySpec
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  -- Filetype-specific keybindings (kept here since they require ft detection)
  keys = {
    {
      "<C-a>",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file from explorer",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
  },
}
