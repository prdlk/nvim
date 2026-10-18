--- <C-h/j/k/l> pane navigation that follows whatever multiplexer Neovim is
--- running under (herdr, tmux, or bare kitty) — see config.pane_nav.
---
--- This replaces AstroNvim's smart-splits mappings (which only know
--- tmux/wezterm/kitty and would move the wrong layer inside herdr). The plugin
--- is disabled in plugins/user.lua; its <C-Up/Down/Left/Right> resize binds
--- are plain :resize here.

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
local resizes = {
  ["<C-Up>"] = { "resize +2", "Resize split taller" },
  ["<C-Down>"] = { "resize -2", "Resize split shorter" },
  ["<C-Left>"] = { "vertical resize -2", "Resize split narrower" },
  ["<C-Right>"] = { "vertical resize +2", "Resize split wider" },
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
    for key, spec in pairs(resizes) do
      maps.n[key] = { "<Cmd>" .. spec[1] .. "<CR>", desc = spec[2] }
    end
  end,
}
