--- Claude Code integration for AI-powered development
--- Provides commands and keybindings for Claude Code assistant
--- @module plugins.claude

---@type LazySpec
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    require("claudecode").setup()

    -- Helper function to get git root and change directory
    local function ensure_git_root()
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if git_root and vim.v.shell_error == 0 then vim.api.nvim_set_current_dir(git_root) end
    end

    -- Wrapper function to run commands at git root
    _G.claude_at_root = function(cmd)
      return function()
        ensure_git_root()
        vim.cmd(cmd)
      end
    end

    -- Create autocommand to ensure we're at git root when opening Claude Code
    vim.api.nvim_create_autocmd("User", {
      pattern = "ClaudeCodeOpen",
      callback = ensure_git_root,
      desc = "Change to git root when opening Claude Code",
    })
  end,
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
