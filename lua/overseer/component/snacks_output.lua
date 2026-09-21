--- Overseer component: show task output in a Snacks window docked to the
--- bottom of the editor, toggleterm-style: the window is focused and dropped
--- into terminal mode when the task starts (and whenever the buffer is
--- re-entered), and closes itself when the task exits.
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
      keys = { q = "close" },
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
    auto_close = {
      desc = "Close the output window when the task exits",
      type = "boolean",
      default = true,
    },
  },
  constructor = function(params)
    --- @param task overseer.Task
    local function close_if_showing(task)
      local bufnr = task:get_bufnr()
      if bufnr and showing(bufnr) then win:close() end
    end
    return {
      on_start = function(_, task)
        local bufnr = task:get_bufnr()
        if bufnr then show(bufnr, params) end
      end,
      on_complete = function(_, task)
        if params.auto_close then close_if_showing(task) end
      end,
      on_dispose = function(_, task) close_if_showing(task) end,
    }
  end,
}
