--- Terminal configurations using toggleterm
--- This module provides terminal toggle functions for various CLI tools
--- @module config.terminals

local M = {}

--- Check if toggleterm is available
--- @return boolean available Whether toggleterm is loaded
local function is_toggleterm_available()
  local ok, _ = pcall(require, "toggleterm.terminal")
  return ok
end

--- Initialize all terminal configurations
--- Only runs if toggleterm is available
function M.setup()
  if not is_toggleterm_available() then
    vim.notify("toggleterm not available, skipping terminal setup", vim.log.levels.WARN)
    return
  end

  local Terminal = require("toggleterm.terminal").Terminal
  -- Scooter find and replace terminal
  local smartCommit = Terminal:new {
    cmd = "smartcommit",
    hidden = true,
    direction = "vertical",
    close_on_exit = true,
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  -- Scooter find and replace terminal
  local scooter = Terminal:new {
    cmd = "scooter",
    hidden = true,
    direction = "vertical",
    close_on_exit = true,
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  -- Mk (make) terminal
  local mk = Terminal:new {
    cmd = "task",
    hidden = true,
    direction = "horizontal",
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  -- Mk (make) terminal
  local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  -- Scratch terminal
  local scratch = Terminal:new {
    cmd = "zsh",
    hidden = true,
    direction = "horizontal",
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  -- Export toggle functions to module instead of global namespace
  M.scooter_toggle = function() scooter:toggle() end
  M.mk_toggle = function() mk:toggle() end
  M.lazygit_toggle = function() lazygit:toggle() end
  M.smartCommit_toggle = function() smartCommit:toggle() end
  M.scratch_toggle = function() scratch:toggle() end
end

return M
