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
  -- Mk (make) terminal
  local lazydocker = Terminal:new {
    cmd = "lazydocker",
    hidden = true,
    direction = "float",
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }

  -- Opencode Terminal Tab

  -- Opencode Terminal Tab (persistent)
  local opencode = Terminal:new {
    cmd = "opencode",
    hidden = true,
    direction = "tab",
    close_on_exit = false,
    count = 99, -- fixed ID so toggleterm never creates a duplicate
    on_open = function(term)
      vim.cmd "startinsert!"
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>tabprevious<CR>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "t",
        "<C-a><C-a>",
        "<cmd>tabprevious<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-p>", "", {
        noremap = true,
        silent = true,
        callback = function()
          vim.fn.chansend(term.job_id, "\x10") -- raw Ctrl-P
        end,
      })
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<S-CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
          vim.fn.chansend(term.job_id, "\x1b[13;2u") -- kitty protocol Shift+Enter
        end,
      })
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        "<C-a><C-a>",
        "<cmd>tabprevious<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-o>", "<cmd>tabprevious<CR>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<C-o>", "<cmd>tabprevious<CR>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c>", "", {
        noremap = true,
        silent = true,
        callback = function()
          term:shutdown()
          vim.cmd "tabprevious"
        end,
      })
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<C-c>", "", {
        noremap = true,
        silent = true,
        callback = function()
          term:shutdown()
          vim.cmd "tabprevious"
        end,
      })
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
  M.lazydocker_toggle = function() lazydocker:toggle() end
  M.smartCommit_toggle = function() smartCommit:toggle() end
  M.scratch_toggle = function() scratch:toggle() end
  M.opencode_toggle = function()
    if not opencode:is_open() then
      opencode:open()
    elseif opencode:is_focused() then
      vim.cmd "tabprevious"
    else
      -- Find and switch to the opencode tab
      local bufnr = opencode.bufnr
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
          vim.api.nvim_set_current_win(win)
          vim.cmd "startinsert!"
          return
        end
      end
    end
  end
end

return M
