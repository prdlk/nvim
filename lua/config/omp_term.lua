--- Oh My Pi terminal, opened with <C-a><C-a>.
---
--- Under tmux (config.pane_nav's env) omp is a tmux pane below Neovim's, 40%
--- of the height. The bind reuses an omp pane before splitting a new one: one
--- already in Neovim's window is focused; otherwise one from another window
--- of the session (in Neovim's cwd first) is moved below Neovim; only with
--- none running is a new one split off. Neovim never kills it. omp.nvim finds
--- the session by cwd, so context streaming does not care which backend runs
--- it.
---
--- Elsewhere it is a snacks terminal on the right, toggled. `Snacks.terminal.toggle`
--- keys terminals by cmd + window-local cwd + v:count1, so toggling from a
--- buffer whose window has another cwd spawns a second omp. Holding the handle
--- here keeps exactly one session; it is recreated only after the omp process
--- exits (auto_close wipes the buffer).
local M = {}

local term ---@type snacks.win?

--- Run a tmux command. Trimmed stdout, or nil on failure, warned about
--- unless `quiet` (a probe whose failure is an answer).
--- @param args string[]
--- @param quiet? boolean
--- @return string|nil
local function tmux(args, quiet)
  local result = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
  if result.code == 0 then return vim.trim(result.stdout) end
  if not quiet then
    vim.notify(("tmux %s: %s"):format(args[1], vim.trim(result.stderr)), vim.log.levels.WARN, { title = "Oh My Pi" })
  end
end

--- Every process named `omp`, and each process's parent and name, from a
--- single `ps`.
--- @return integer[] omp pids
--- @return table<integer, { ppid: integer, comm: string }> procs by pid
local function omp_processes()
  local ok, result = pcall(
    function() return vim.system({ "ps", "-e", "-o", "pid=,ppid=,comm=" }, { text = true }):wait() end
  )
  local omp, procs = {}, {}
  if not ok or result.code ~= 0 then return omp, procs end
  for line in result.stdout:gmatch "[^\n]+" do
    local pid, ppid, comm = line:match "^%s*(%d+)%s+(%d+)%s+(.-)%s*$"
    if pid then
      pid = tonumber(pid)
      -- macOS ps prints the full path as comm
      comm = comm:match "[^/]*$"
      procs[pid] = { ppid = tonumber(ppid), comm = comm }
      if comm == "omp" then omp[#omp + 1] = pid end
    end
  end
  return omp, procs
end

--- The omp pane to reuse in this tmux session: one in Neovim's window, else
--- one in Neovim's cwd, else any. The pane's foreground command is no
--- evidence: a wrapper (omp-session) or omp's own tool runs show as python3,
--- so each omp process is walked up its parents to a pane's root process.
--- An omp inside a Neovim terminal does not count: its pane is that Neovim.
--- @return string|nil pane id
--- @return boolean here whether it is already in Neovim's window
local function find_omp()
  local format = "#{pane_id}\t#{pane_pid}\t#{window_id}\t#{pane_current_path}"
  local out = tmux { "list-panes", "-s", "-t", vim.env.TMUX_PANE, "-F", format }
  if not out then return nil, false end
  local panes, window = {}, nil ---@type table<integer, { id: string, window: string, path: string }>
  for line in out:gmatch "[^\n]+" do
    local id, pid, win, path = line:match "^(%S+)\t(%d+)\t(%S+)\t(.*)$"
    if id then
      panes[tonumber(pid)] = { id = id, window = win, path = path }
      if id == vim.env.TMUX_PANE then window = win end
    end
  end
  local cwd, best, rank = vim.fn.getcwd(), nil, 0
  local omp, procs = omp_processes()
  for _, pid in ipairs(omp) do
    -- daemons and workers reparented to init never reach a pane; an omp in
    -- a Neovim terminal stops at that Neovim (also when it is a pane's root)
    while pid do
      local proc = procs[pid]
      if not proc or proc.comm == "nvim" then
        pid = nil
      elseif panes[pid] then
        break
      else
        pid = proc.ppid
      end
    end
    local pane = pid and panes[pid]
    if pane then
      local r = pane.window == window and 3 or pane.path == cwd and 2 or 1
      if r > rank then
        best, rank = pane.id, r
      end
    end
  end
  return best, rank == 3
end

local function tmux_open()
  local self = vim.env.TMUX_PANE
  local pane, here = find_omp()
  if here then
    tmux { "select-pane", "-t", pane }
  elseif pane then
    tmux { "join-pane", "-v", "-l", "40%", "-s", pane, "-t", self }
  else
    tmux { "split-window", "-v", "-l", "40%", "-t", self, "-c", vim.fn.getcwd(), "omp" }
  end
end

function M.toggle()
  if require("config.pane_nav").env() == "tmux" then return tmux_open() end
  if term and term:buf_valid() then
    term:toggle()
    return
  end
  term = require("snacks").terminal.open("omp", {
    win = {
      position = "right",
      width = 0.4,
      -- buffer-local, so <C-a> keeps reaching other terminals unchanged
      keys = { omp_hide = { "<C-a><C-a>", "hide", mode = { "n", "t" }, desc = "Hide Oh My Pi" } },
    },
  })
end

return M
