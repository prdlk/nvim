--- <C-e>: focus the treemux file tree sidebar (a tmux pane, see
--- ~/.config/tmux/tmux.conf and treemux_init.lua), opening it when the window
--- has none. The sidebar is persistent (one in every tmux window), so there
--- usually is one.
---
--- The sidebar follows one pane of the window, not necessarily this one, so
--- any sidebar in this window counts.
--- treemux marks a sidebar pane with the global option
--- `@-treemux-is-treemux-<sidebar pane id>` (its internal registry; entries
--- outlive their panes, hence the intersection with this window's panes).
--- @module config.treemux

local M = {}

--- @param args string[]
--- @return string|nil stdout, nil on failure
local function tmux(args)
  local res = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
  if res.code ~= 0 then return nil end
  return res.stdout
end

function M.focus()
  local pane = vim.env.TMUX_PANE
  if (vim.env.TMUX or "") == "" or not pane then
    vim.notify("Not in tmux: the file tree is the treemux sidebar", vim.log.levels.WARN, { title = "treemux" })
    return
  end

  local window_panes = {}
  for id in (tmux { "list-panes", "-t", pane, "-F", "#{pane_id}" } or ""):gmatch "%S+" do
    window_panes[id] = true
  end
  for id in (tmux { "show-options", "-g" } or ""):gmatch "@%-treemux%-is%-treemux%-(%%%d+) " do
    if window_panes[id] then
      tmux { "select-pane", "-t", id }
      return
    end
  end

  -- none here: open one for this pane, as prefix BSpace does (focus variant)
  local args = vim.trim(tmux { "show-options", "-gv", "@treemux-key-Bspace" } or "")
  local script = vim.fn.expand "~/.config/tmux/plugins/treemux/scripts/toggle.sh"
  if args == "" or vim.fn.executable(script) == 0 then
    vim.notify("treemux is not loaded in this tmux server", vim.log.levels.WARN, { title = "treemux" })
    return
  end
  tmux { "run-shell", "-b", ("%s %s %s"):format(vim.fn.shellescape(script), vim.fn.shellescape(args), pane) }
end

return M
