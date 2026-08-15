--- Multiplexer-aware <C-h/j/k/l> split navigation.
---
--- Neovim owns the key first: move between Neovim splits, and only once the
--- cursor is already at the outermost split in that direction hand the move to
--- whatever owns the surrounding panes:
---
---   herdr  -> herdr pane focus --direction <dir> --pane $HERDR_PANE_ID
---   tmux   -> tmux select-pane -t $TMUX_PANE -L/-D/-U/-R
---   kitty  -> kitty @ kitten navigate_kitty.py <edge>  (needs `listen_on`)
---   none   -> stay put
---
--- The outer half of each pair already forwards the chord into Neovim when the
--- pane runs (n)vim (herdr: vim-herdr-navigation's navigate.sh, tmux: the
--- `is_vim` if-shell in tmux.conf, kitty: pass_keys.py), so this side only has
--- to answer "who do I hand the edge to".
---
--- Which one owns the panes is answered by the process tree, not by env vars:
--- $TMUX / $HERDR_PANE_ID / $KITTY_LISTEN_ON are inherited, so they survive into
--- unrelated grandchildren (a kitty window launched from a herdr pane still
--- advertises $HERDR_PANE_ID, and a tmux server started inside a herdr pane
--- leaves both set). The nearest ancestor process that is a terminal or
--- multiplexer is the one actually drawing the surrounding panes; the env var is
--- then required as proof that we can drive it (a socket, a pane id) and demoted
--- to the only signal on platforms without /proc.
--- @module config.pane_nav

local uv = vim.uv or vim.loop

local M = {}

--- Per-direction handoff arguments: Neovim wincmd, tmux select-pane flag and
--- kitty edge name (kitty calls the vertical edges "top"/"bottom").
local directions = {
  left = { wincmd = "h", tmux = "-L", kitty = "left" },
  down = { wincmd = "j", tmux = "-D", kitty = "bottom" },
  up = { wincmd = "k", tmux = "-U", kitty = "top" },
  right = { wincmd = "l", tmux = "-R", kitty = "right" },
}

--- Read a single /proc file, trimmed. Returns nil when unreadable (non-Linux,
--- process already gone).
--- @param path string
--- @return string|nil
local function read_proc(path)
  local fd = uv.fs_open(path, "r", 292) -- 0444
  if not fd then return nil end
  local data = uv.fs_read(fd, 4096, 0)
  uv.fs_close(fd)
  if not data then return nil end
  return (data:gsub("%s+$", ""))
end

--- Nearest terminal/multiplexer ancestor of this Neovim. comm is "tmux: server"
--- for tmux, "herdr" for the herdr server, "kitty" for kitty.
--- @return "tmux"|"herdr"|"kitty"|nil
local function ancestor_mux()
  local pid = uv.os_getppid()
  for _ = 1, 32 do
    if not pid or pid <= 1 then return nil end
    local comm = read_proc(("/proc/%d/comm"):format(pid))
    if not comm then return nil end
    if comm:match "^tmux" then return "tmux" end
    if comm == "herdr" then return "herdr" end
    if comm == "kitty" then return "kitty" end
    local status = read_proc(("/proc/%d/status"):format(pid))
    pid = status and tonumber(status:match "PPid:%s*(%d+)")
  end
  return nil
end

--- Whether this Neovim was handed what it needs to drive `mux`: herdr and tmux
--- name the pane to move from, kitty a remote-control socket.
--- @param mux "tmux"|"herdr"|"kitty"
--- @return boolean
local function drivable(mux)
  if mux == "herdr" then return (vim.env.HERDR_PANE_ID or "") ~= "" end
  if mux == "tmux" then return (vim.env.TMUX or "") ~= "" end
  return (vim.env.KITTY_LISTEN_ON or "") ~= ""
end

--- @return "herdr"|"tmux"|"kitty"|"none"
local function detect()
  local owner = ancestor_mux()
  -- Known owner: either we can drive it, or nothing else may be driven on its
  -- behalf (e.g. kitty without `listen_on`, where the edge simply stops).
  if owner then return drivable(owner) and owner or "none" end
  -- No ancestry (no /proc): fall back to env vars, innermost-looking first.
  for _, mux in ipairs { "herdr", "tmux", "kitty" } do
    if drivable(mux) then return mux end
  end
  return "none"
end

local env

--- The multiplexer that owns the panes around this Neovim. Cached: a process
--- cannot change multiplexers mid-life.
--- @return "herdr"|"tmux"|"kitty"|"none"
function M.env()
  if not env then env = detect() end
  return env
end

--- Fire off a handoff command, warning if it fails (e.g. `kitty @` without a
--- remote-control socket) instead of swallowing a dead keypress.
--- @param cmd string[]
local function run(cmd)
  vim.system(cmd, { text = true }, function(result)
    if result.code == 0 then return end
    local message = ("pane_nav: %s exited %d%s"):format(cmd[1], result.code, result.stderr ~= "" and (": " .. vim.trim(result.stderr)) or "")
    vim.schedule(function() vim.notify(message, vim.log.levels.WARN) end)
  end)
end

--- Hand the move to the surrounding multiplexer. Both herdr and tmux resolve a
--- bare command against the *focused* pane; target this Neovim's own pane
--- instead, so a handoff is still correct if focus drifted (e.g. a click, or a
--- second keypress arriving while the first is still in flight).
--- @param dir "left"|"down"|"up"|"right"
local function handoff(dir)
  local mux = M.env()
  if mux == "herdr" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then herdr = "herdr" end
    run { herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID }
  elseif mux == "tmux" then
    local pane = vim.env.TMUX_PANE
    if pane == nil or pane == "" then
      run { "tmux", "select-pane", directions[dir].tmux }
    else
      run { "tmux", "select-pane", "-t", pane, directions[dir].tmux }
    end
  elseif mux == "kitty" then
    run { "kitty", "@", "kitten", "navigate_kitty.py", directions[dir].kitty }
  end
end

--- Move to the split in `dir`, crossing into the surrounding multiplexer when
--- already at that edge. Floating windows never hand off: they are overlays, so
--- jumping the whole pane out from under one is never what was meant.
--- @param dir "left"|"down"|"up"|"right"
function M.navigate(dir)
  local from = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(directions[dir].wincmd)
  if vim.api.nvim_get_current_win() ~= from then return end
  if vim.api.nvim_win_get_config(0).relative ~= "" then return end
  handoff(dir)
end

--- Terminal-mode variant. Inside a floating terminal the chord belongs to the
--- child process (AstroNvim's `term_nav` behaviour), everywhere else it
--- navigates as usual.
--- @param dir "left"|"down"|"up"|"right"
--- @return function
function M.terminal(dir)
  local key = ("<C-%s>"):format(directions[dir].wincmd)
  return function()
    if vim.api.nvim_win_get_config(0).zindex then
      vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
    else
      M.navigate(dir)
    end
  end
end

return M
