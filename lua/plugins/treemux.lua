--- Keep the treemux sidebar's cursor on the current buffer's file; the push
--- lives in config.treemux, the receiving end in
--- ~/.config/tmux/treemux_init.lua (`treemux_reveal`).
--- FocusGained covers coming back from the tree after browsing it.
--- @module plugins.treemux

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      treemux_follow = {
        {
          event = { "BufEnter", "FocusGained" },
          desc = "Reveal the current file in the treemux sidebar",
          callback = function() require("config.treemux").reveal() end,
        },
      },
    },
  },
}
