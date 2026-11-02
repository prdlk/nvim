--- <C-h/j/k/l> pane navigation that follows whatever multiplexer Neovim is
--- running under (herdr, tmux, or bare kitty) — see config.pane_nav.
---
--- These entries overwrite AstroNvim's smart-splits mappings, which only know
--- tmux/wezterm/kitty and would move the wrong layer inside herdr. Under tmux
--- they hand back to smart-splits: navigation through config.pane_nav, resize
--- directly, plus <M-h/j/k/l> resize, the keys tmux.conf forwards to an
--- @pane-is-vim pane. Elsewhere <C-Up/Down/Left/Right> are plain :resize.

local nav = require "config.pane_nav"

--- AstroNvim's key spelling for these chords, so the entries overwrite rather
--- than race the smart-splits / term_nav mappings.
local moves = {
  ["<C-H>"] = "left",
  ["<C-J>"] = "down",
  ["<C-K>"] = "up",
  ["<C-L>"] = "right",
}

--- AstroNvim's key spelling again, overriding the smart-splits resize entries.
--- dir is the smart-splits direction under tmux; cmd the plain fallback.
local resizes = {
  ["<C-Up>"] = { dir = "up", cmd = "resize +2", desc = "Resize split taller" },
  ["<C-Down>"] = { dir = "down", cmd = "resize -2", desc = "Resize split shorter" },
  ["<C-Left>"] = { dir = "left", cmd = "vertical resize -2", desc = "Resize split narrower" },
  ["<C-Right>"] = { dir = "right", cmd = "vertical resize +2", desc = "Resize split wider" },
}

--- tmux.conf's vim-aware resize keys; only mapped under tmux.
local tmux_resizes = {
  ["<M-h>"] = "left",
  ["<M-j>"] = "down",
  ["<M-k>"] = "up",
  ["<M-l>"] = "right",
}

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings
    maps.x = maps.x or {}
    for key, dir in pairs(moves) do
      local desc = ("Move %s a split (%s aware)"):format(dir, nav.env())
      maps.n[key] = { function() nav.navigate(dir) end, desc = desc }
      maps.x[key] = maps.n[key]
      maps.t[key] = { nav.terminal(dir), desc = desc }
    end
    local tmux = nav.env() == "tmux"
    for key, spec in pairs(resizes) do
      if tmux then
        maps.n[key] = { function() require("smart-splits")["resize_" .. spec.dir]() end, desc = "Resize split " .. spec.dir }
      else
        maps.n[key] = { "<Cmd>" .. spec.cmd .. "<CR>", desc = spec.desc }
      end
    end
    if tmux then
      for key, dir in pairs(tmux_resizes) do
        maps.n[key] = { function() require("smart-splits")["resize_" .. dir]() end, desc = "Resize split " .. dir .. " (tmux aware)" }
      end
    end
  end,
}
