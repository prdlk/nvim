--- Persistent yazi session in a snacks terminal (replaces yazi.nvim).
---
--- One long-lived yazi process per nvim instance, addressed over DDS with a
--- stable client-id (this nvim's pid). <C-e> hides/shows the window instead
--- of quitting yazi, so tabs / per-tab cwds / selections survive toggles.
--- Pressing `q` inside yazi still ends the session for real: the process
--- exits, snacks auto-closes the buffer, and the next toggle spawns fresh.
---
--- File opens are routed back into this instance by the yazi `edit` opener
--- (~/.local/bin/yazi-nvim-open): when $NVIM is set it calls
---   nvim --server $NVIM --remote-expr 'v:lua.EditFromYazi(mode, path)'
--- (the same callback pattern nvim-external-tui uses for :Scooter).

local M = {}

M.term = nil ---@type snacks.win?

local function client_id() return tostring(vim.uv.os_getpid()) end

--- Talk to the running yazi over DDS (works while hidden, too).
local function emit(...) vim.system { "ya", "emit-to", client_id(), ... } end

--- Real file behind the current buffer, or nil (terminals, pickers, scratch).
local function buffer_target()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or name == "" then return nil end
  return name
end

local function alive() return M.term ~= nil and M.term:buf_valid() end

--- Show (or spawn) the session. `target` is revealed (file) or entered
--- (directory) on arrival; the session's other tabs are left untouched.
---@param target? string
function M.open(target)
  if alive() then
    if not M.term:win_valid() then M.term:show() end
    if target then emit(vim.fn.isdirectory(target) == 1 and "cd" or "reveal", target) end
    return
  end
  -- fresh spawn: yazi hovers a file argument / starts in a directory argument
  M.term = require("snacks").terminal.open(
    { "yazi", "--client-id", client_id(), target or vim.uv.cwd() },
    { win = { style = "yazi" } }
  )
end

--- <C-e>: hide when visible, otherwise show at the current file.
function M.toggle()
  if alive() and M.term:win_valid() then
    M.term:hide()
    return
  end
  M.open(buffer_target())
end

--- Show the session revealing the current file (no toggle).
function M.open_current() M.open(buffer_target()) end

--- Callback for the yazi-side opener script. Runs via --remote-expr, where
--- window/text changes are forbidden, so the real work is scheduled.
---@param mode "edit"|"vsplit"|"split"|"tabedit"
---@param path string absolute path
function _G.EditFromYazi(mode, path)
  vim.schedule(function()
    if alive() and M.term:win_valid() then M.term:hide() end
    local cmd = ({ edit = "edit", vsplit = "vsplit", split = "split", tabedit = "tabedit" })[mode] or "edit"
    vim.cmd(cmd .. " " .. vim.fn.fnameescape(path))
  end)
  return ""
end

return M
