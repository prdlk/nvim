--- Oh My Pi terminal, opened with <C-a><C-a>; in visual mode the bind also
--- hands omp the selection as a file reference.
---
--- Under tmux (config.pane_nav's env) omp is a tmux pane right of Neovim's,
--- 30% of the window's width. The bind reuses an omp pane before splitting
--- a new one: one already in Neovim's window is focused; otherwise one from
--- another window of the session (in Neovim's cwd first) is moved right of Neovim;
--- only with none running is a new one split off. Neovim never kills it.
---
--- A new omp, in tmux or not, runs `omp --continue`: it resumes the latest
--- session of Neovim's cwd, or starts a fresh one when the cwd has none.
---
--- The visual bind pastes `@path:first-last ` into omp's input editor and
--- focuses the pane, so the question follows the reference. The paste is
--- bracketed: omp's `@` file autocomplete stays shut and nothing is submitted.
--- omp inlines only a bare `@path`; a ranged one stays literal and the agent
--- reads exactly those lines (its read tool takes the same `path:N-M`
--- selector). path is relative to the omp pane's cwd when the file is under
--- it, else absolute. A modified or unnamed buffer is snapshotted to a temp
--- file, so the agent never reads stale disk content. A freshly split omp gets
--- the paste once its TUI is up, which tmux's bracket_paste_flag reports.
---
--- :OmpContinue (fish's `omp-continue` runs `nvim +OmpContinue`, see
--- ~/.config/fish/functions/omp-continue.fish) lays out the window: the same
--- omp pane plus the treemux file tree on the left (config.treemux.open),
--- and ends with focus in omp. Neovim's VimEnter restores its own buffers
--- (config.session) behind it.
---
--- Elsewhere it is a snacks terminal on the right, toggled; the visual send
--- needs tmux. `Snacks.terminal.toggle` keys terminals by cmd + window-local
--- cwd + v:count1, so toggling from a buffer whose window has another cwd
--- spawns a second omp. Holding the handle here keeps exactly one session; it
--- is recreated only after the omp process exits (auto_close wipes the buffer).
local M = {}

local term ---@type snacks.win?

local function warn(msg) vim.notify(msg, vim.log.levels.WARN, { title = "Oh My Pi" }) end

--- Run a tmux command. Trimmed stdout, or nil on failure, warned about
--- unless `quiet` (a probe whose failure is an answer).
--- @param args string[]
--- @param quiet? boolean
--- @param stdin? string
--- @return string|nil
local function tmux(args, quiet, stdin)
  local result = vim.system(vim.list_extend({ "tmux" }, args), { text = true, stdin = stdin }):wait()
  if result.code == 0 then return vim.trim(result.stdout) end
  if not quiet then warn(("tmux %s: %s"):format(args[1], vim.trim(result.stderr))) end
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
--- `anchor` is the pane omp belongs beside (default: Neovim's own).
--- @param anchor string
--- @return string|nil pane id
--- @return boolean here whether it is already in the anchor's window
local function find_omp(anchor)
  local format = "#{pane_id}\t#{pane_pid}\t#{window_id}\t#{pane_current_path}"
  local out = tmux { "list-panes", "-s", "-t", anchor, "-F", format }
  if not out then return nil, false end
  local panes, window = {}, nil ---@type table<integer, { id: string, window: string, path: string }>
  for line in out:gmatch "[^\n]+" do
    local id, pid, win, path = line:match "^(%S+)\t(%d+)\t(%S+)\t(.*)$"
    if id then
      panes[tonumber(pid)] = { id = id, window = win, path = path }
      if id == anchor then window = win end
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

--- Focus the omp pane right of Neovim, reusing one or splitting off
--- `omp --continue`. The pane is marked @treemux-keep-width, so opening the
--- treemux sidebar (scripts/toggle.sh in the prdlk fork) takes its columns
--- from the other panes and leaves omp's width as it was; tmux.conf's
--- even-out hooks skip windows holding such a pane. A new pane is marked in
--- the same tmux command list as the split, before those hooks run.
--- `anchor` is the pane to put omp right of: Neovim's own by default; the
--- treemux sidebar passes its editor or shell pane (send_paths).
--- @param anchor? string
--- @return string|nil pane id
local function tmux_open(anchor)
  local self = anchor or vim.env.TMUX_PANE
  local pane, here = find_omp(self)
  local ok
  if here then
    ok = tmux { "select-pane", "-t", pane }
  else
    -- 30% of the window, whatever share of it Neovim's pane has (the treemux
    -- tree may already sit left of it)
    local width = tmux { "display-message", "-p", "-t", self, "#{e|/:#{e|*:#{window_width},3},10}" }
    if not width then return end
    if pane then
      local join = { "join-pane", "-h", "-l", width, "-s", pane, "-t", self }
      return tmux(vim.list_extend(join, { ";", "set-option", "-p", "-t", pane, "@treemux-keep-width", "1" })) and pane
    end
    local split = { "split-window", "-h", "-l", width, "-t", self, "-c", vim.fn.getcwd(), "-P", "-F", "#{pane_id}" }
    return tmux(vim.list_extend(split, { "omp", "--continue", ";", "set-option", "-p", "@treemux-keep-width", "1" }))
  end
  if not ok then return end
  tmux { "set-option", "-p", "-t", pane, "@treemux-keep-width", "1" }
  return pane
end

--- Bracketed-paste `text` into omp's input once its TUI has enabled
--- bracketed paste (at once for a running omp; ~10s grace for a new one).
--- @param pane string
--- @param text string
--- @param tries? integer
local function paste(pane, text, tries)
  tries = tries or 0
  local ready = tmux({ "display-message", "-p", "-t", pane, "#{bracket_paste_flag}" }, true)
  if not ready then return end -- pane closed meanwhile
  if ready ~= "1" then
    if tries >= 100 then return warn "omp did not start in time; reference not sent" end
    return vim.defer_fn(function() paste(pane, text, tries + 1) end, 100)
  end
  if tmux({ "load-buffer", "-b", "omp-nvim", "-" }, false, text) then
    tmux { "paste-buffer", "-p", "-d", "-b", "omp-nvim", "-t", pane }
  end
end

--- `@path:first-last ` for lines of the current buffer, as omp in `cwd`
--- reads them.
--- @param first integer
--- @param last integer
--- @param cwd string
--- @return string
local function reference(first, last, cwd)
  local name = vim.api.nvim_buf_get_name(0)
  local function rel(path) return vim.fs.relpath(cwd, path) or path end
  local range = first == last and tostring(first) or ("%d-%d"):format(first, last)
  if name ~= "" and not vim.bo.modified then return ("@%s:%s "):format(rel(name), range) end
  local ext = vim.fn.fnamemodify(name, ":e")
  local snapshot = vim.fn.tempname() .. (ext ~= "" and "." .. ext or "")
  vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), snapshot)
  local origin = name ~= "" and (" (unsaved %s)"):format(rel(name)) or ""
  return ("@%s:%s%s "):format(snapshot, range, origin)
end

--- Visual mode: leave it, then paste a reference to the selected lines into
--- omp's input and focus its pane.
function M.send_selection()
  local first, last = vim.fn.line "v", vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd.normal { vim.keycode "<Esc>", bang = true }
  if require("config.pane_nav").env() ~= "tmux" then return warn "Sending a selection to omp needs tmux" end
  local pane = tmux_open()
  if not pane then return end
  local cwd = tmux { "display-message", "-p", "-t", pane, "#{pane_current_path}" } or vim.fn.getcwd()
  paste(pane, reference(first, last, cwd))
end

--- `@path` mentions of `paths` into omp's input, focusing its pane (opened
--- right of `anchor` when it is not running). omp inlines a file and lists a
--- directory. Each path is relative to the omp pane's cwd when under it,
--- else absolute; quoted when it has a space or an `@`. The treemux
--- sidebar's <C-a><C-a> (~/.config/tmux/treemux_init.lua) sends its nodes.
--- @param paths string[] absolute
--- @param anchor? string pane id
function M.send_paths(paths, anchor)
  if #paths == 0 then return end
  if not vim.env.TMUX then return warn "Sending files to omp needs tmux" end
  local pane = tmux_open(anchor)
  if not pane then return end
  local cwd = tmux { "display-message", "-p", "-t", pane, "#{pane_current_path}" } or vim.fn.getcwd()
  local mentions = vim.tbl_map(function(path)
    path = vim.fs.relpath(cwd, path) or path
    return path:find "[%s@\"]" and ("@'%s'"):format(path) or "@" .. path
  end, paths)
  paste(pane, table.concat(mentions, " ") .. " ")
end

function M.toggle()
  if require("config.pane_nav").env() == "tmux" then return tmux_open() end
  if term and term:buf_valid() then
    term:toggle()
    return
  end
  term = require("snacks").terminal.open({ "omp", "--continue" }, {
    win = {
      position = "right",
      width = 0.3,
      -- buffer-local, so <C-a> keeps reaching other terminals unchanged
      keys = { omp_hide = { "<C-a><C-a>", "hide", mode = { "n", "t" }, desc = "Hide Oh My Pi" } },
    },
  })
end

--- The :OmpContinue layout: omp right of Neovim and the treemux tree left of
--- it; focus ends in omp.
function M.continue()
  if require("config.pane_nav").env() ~= "tmux" then return warn "The omp-continue layout needs tmux" end
  require("config.treemux").open(tmux_open())
end

return M
