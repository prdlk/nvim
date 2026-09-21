--- Overseer component: show task output in a Snacks window docked to the
--- bottom of the editor, toggleterm-style: the window is focused and dropped
--- into terminal mode when the task starts (and whenever the buffer is
--- re-entered). Output stays on screen after the task exits; <CR> or q then
--- close the window (while running, keys still go to the process; q in
--- normal mode always closes).
---
--- The task's own terminal buffer (owned by the jobstart strategy, so exit
--- status / output parsing keep working) is placed in a single shared
--- bottom window. A newly started task takes the window over, so the most
--- recent run is always the one visible. `fixbuf = false` lets overseer swap
--- the buffer in place on restart (Task:start -> util.replace_buffer_in_wins).
--- @module overseer.component.snacks_output

--- @type snacks.win?
local win

--- @param bufnr integer
--- @return boolean
local function showing(bufnr)
  return win ~= nil and win:win_valid() and vim.api.nvim_win_get_buf(win.win) == bufnr
end

--- Enter terminal mode if the task buffer is the current one. The jobstart
--- strategy defers nvim_open_term while a floating window (the task picker)
--- is current, so the buffer may not be a terminal yet: TermOpen fires once
--- the deferred creation runs after our WinEnter.
--- @param bufnr integer
local function start_insert(bufnr)
  if vim.api.nvim_get_current_buf() ~= bufnr then return end
  if vim.bo[bufnr].buftype == "terminal" then
    vim.cmd.startinsert()
    return
  end
  vim.api.nvim_create_autocmd("TermOpen", {
    buffer = bufnr,
    once = true,
    callback = function() vim.schedule(function() start_insert(bufnr) end) end,
  })
end

--- @param bufnr integer
--- @param params { height: integer, focus: boolean, auto_insert: boolean }
local function show(bufnr, params)
  if win and win:win_valid() then
    if vim.api.nvim_win_get_buf(win.win) ~= bufnr then vim.api.nvim_win_set_buf(win.win, bufnr) end
  else
    win = require("snacks").win {
      buf = bufnr,
      position = "bottom",
      height = params.height,
      enter = false,
      backdrop = false,
      fixbuf = false,
      wo = { number = false, relativenumber = false, signcolumn = "no", winbar = "", wrap = true },
      keys = {},
    }
  end
  if params.auto_insert then
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = bufnr,
      callback = function() start_insert(bufnr) end,
    })
  end
  if params.focus then
    win:focus()
    if params.auto_insert then start_insert(bufnr) end
  end
end

--- @type overseer.ComponentFileDefinition
return {
  desc = "Show task output in a Snacks window docked to the bottom",
  params = {
    height = {
      desc = "Height of the bottom window in rows",
      type = "integer",
      default = 24,
    },
    focus = {
      desc = "Focus the output window when the task starts",
      type = "boolean",
      default = true,
    },
    auto_insert = {
      desc = "Enter terminal mode when the output buffer is focused",
      type = "boolean",
      default = true,
    },
  },
  constructor = function(params)
    --- @param bufnr integer
    local function close_win(bufnr)
      if showing(bufnr) then win:close() end
    end
    return {
      on_start = function(_, task)
        local bufnr = task:get_bufnr()
        if not bufnr then return end
        -- a restart with preserve_output reuses the buffer: hand the keys
        -- back to the process until the task completes again
        pcall(vim.keymap.del, "t", "<CR>", { buffer = bufnr })
        pcall(vim.keymap.del, "t", "q", { buffer = bufnr })
        pcall(vim.keymap.del, "n", "<CR>", { buffer = bufnr })
        vim.keymap.set("n", "q", function() close_win(bufnr) end, { buffer = bufnr, nowait = true, desc = "Close task output" })
        show(bufnr, params)
      end,
      on_complete = function(_, task)
        local bufnr = task:get_bufnr()
        if not bufnr then return end
        local function close() close_win(bufnr) end
        local opts = { buffer = bufnr, nowait = true, desc = "Close task output" }
        vim.keymap.set({ "t", "n" }, "<CR>", close, opts)
        vim.keymap.set("t", "q", close, opts)
      end,
      on_dispose = function(_, task)
        local bufnr = task:get_bufnr()
        if bufnr then close_win(bufnr) end
      end,
    }
  end,
}
