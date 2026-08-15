--- <C-h/j/k/l> pane navigation that follows whatever multiplexer Neovim is
--- running under (herdr, tmux, or bare kitty) — see config.pane_nav.
---
--- This replaces AstroNvim's smart-splits mappings on the same keys (which only
--- know tmux/wezterm/kitty and would move the wrong layer inside herdr).
--- smart-splits itself stays for the <C-Up/Down/Left/Right> resize mappings.

local nav = require "config.pane_nav"

--- AstroNvim's key spelling for these chords, so the entries overwrite rather
--- than race the smart-splits / term_nav mappings.
local moves = {
  ["<C-H>"] = "left",
  ["<C-J>"] = "down",
  ["<C-K>"] = "up",
  ["<C-L>"] = "right",
}

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings
    for key, dir in pairs(moves) do
      local desc = ("Move %s a split (%s aware)"):format(dir, nav.env())
      maps.n[key] = { function() nav.navigate(dir) end, desc = desc }
      maps.t[key] = { nav.terminal(dir), desc = desc }
    end
  end,
}
