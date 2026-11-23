--- The treemux file tree sidebar (a tmux pane, see ~/.config/tmux/tmux.conf
--- and treemux_init.lua):
---
---   * <C-e> focuses it, opening one when the window has none; `open` (the
---     :OmpContinue layout) opens one without taking focus. treemux marks
---     a sidebar pane with the global option `@-treemux-is-treemux-<pane id>`
---     (its internal registry; entries outlive their panes, hence the
---     intersection with this window's panes).
---   * `reveal` keeps the sidebar's cursor on this nvim's current file. Every
---     sidebar publishes its RPC address as the pane option
---     `@treemux-nvim-addr`; this window's sidebars get the file path pushed
---     to their `treemux_reveal` (a notification: nothing here waits on them).
---
--- The sidebar follows one pane of the window, not necessarily this one, so
--- any sidebar in this window counts.
--- @module config.treemux

local M = {}

--- @param args string[]
--- @return string|nil stdout, nil on failure
local function tmux(args)
  local res = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
  if res.code ~= 0 then return nil end
  return res.stdout
end

--- This tmux pane, or nil (warned about) outside tmux.
--- @return string|nil
local function own_pane()
  local pane = vim.env.TMUX_PANE
  if (vim.env.TMUX or "") ~= "" and pane then return pane end
  vim.notify("Not in tmux: the file tree is the treemux sidebar", vim.log.levels.WARN, { title = "treemux" })
end

--- The sidebar in `pane`'s window, if any.
--- @param pane string
--- @return string|nil sidebar pane id
local function sidebar(pane)
  local window_panes = {}
  for id in (tmux { "list-panes", "-t", pane, "-F", "#{pane_id}" } or ""):gmatch "%S+" do
    window_panes[id] = true
  end
  for id in (tmux { "show-options", "-g" } or ""):gmatch "@%-treemux%-is%-treemux%-(%%%d+) " do
    if window_panes[id] then return id end
  end
end

--- Open a sidebar for `pane` the way treemux's `prefix <key>` does: BSpace
--- focuses it, Tab keeps focus on `pane`.
--- @param pane string
--- @param key "Bspace"|"Tab"
local function toggle(pane, key)
  local args = vim.trim(tmux { "show-options", "-gv", "@treemux-key-" .. key } or "")
  local script = vim.fn.expand "~/.config/tmux/plugins/treemux/scripts/toggle.sh"
  if args == "" or vim.fn.executable(script) == 0 then
    vim.notify("treemux is not loaded in this tmux server", vim.log.levels.WARN, { title = "treemux" })
    return
  end
  tmux { "run-shell", "-b", ("%s %s %s"):format(vim.fn.shellescape(script), vim.fn.shellescape(args), pane) }
end

function M.focus()
  local pane = own_pane()
  if not pane then return end
  local id = sidebar(pane)
  if id then
    tmux { "select-pane", "-t", id }
  else
    toggle(pane, "Bspace")
  end
end

--- Open a sidebar in this window unless it has one; focus stays here.
function M.open()
  local pane = own_pane()
  if pane and not sidebar(pane) then toggle(pane, "Tab") end
end

local channels = {} ---@type table<string, integer> sidebar RPC address -> channel

--- Push `path` to the sidebar at `addr`, reconnecting once if the cached
--- channel went stale.
--- @param addr string
--- @param path string
local function push(addr, path)
  for _ = 1, 2 do
    local chan = channels[addr]
    if not chan then
      local ok, new = pcall(vim.fn.sockconnect, "pipe", addr, { rpc = true })
      if not ok or new == 0 then return end
      chan, channels[addr] = new, new
    end
    if pcall(vim.rpcnotify, chan, "nvim_exec_lua", "if treemux_reveal then treemux_reveal(...) end", { path }) then
      return
    end
    channels[addr] = nil
  end
end

local timer ---@type uv.uv_timer_t?

--- Reveal the current buffer's file in this tmux window's sidebars.
--- Debounced: session restores and window hops fire BufEnter in bursts.
function M.reveal()
  local pane = vim.env.TMUX_PANE
  if (vim.env.TMUX or "") == "" or not pane then return end
  timer = timer or assert(vim.uv.new_timer())
  timer:stop()
  timer:start(30, 0, vim.schedule_wrap(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" then return end
    -- the tree's paths come from the resolved shell cwd; unsaved files have none
    local path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf))
    if not path then return end
    vim.system({ "tmux", "list-panes", "-t", pane, "-F", "#{@treemux-nvim-addr}" }, { text = true }, function(res)
      if res.code ~= 0 then return end
      local live = {}
      for addr in res.stdout:gmatch "[^\n]+" do
        live[addr] = true
      end
      vim.schedule(function()
        for addr, chan in pairs(channels) do
          if not live[addr] then
            pcall(vim.fn.chanclose, chan)
            channels[addr] = nil
          end
        end
        for addr in pairs(live) do
          push(addr, path)
        end
      end)
    end)
  end))
end

return M
