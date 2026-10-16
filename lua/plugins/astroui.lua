-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- plain `cyberdream` honours `variant` below, so :CyberdreamToggleMode
      -- flips muted <-> light (`cyberdream-muted` would hard-code the palette)
      colorscheme = "cyberdream",
    },
  },
  {
    -- layered on the astrocommunity spec (transparent, italic_comments,
    -- hide_fillchars, terminal_colors stay as it sets them)
    "scottmckendry/cyberdream.nvim",
    ---@type cyberdream.Config
    opts = {
      variant = "muted",
      -- astrocommunity still passes the pre-rename `borderless_telescope`,
      -- which cyberdream ignores; this is the current key (snacks picker)
      borderless_pickers = true,
      -- only the installed plugins; base highlights always load. A newly
      -- added plugin with a cyberdream extension must be listed here.
      extensions = {
        default = false,
        blinkcmp = true,
        dapui = true,
        gitsigns = true,
        grugfar = true,
        heirline = true, -- AstroNvim's statusline reads the Heirline<Mode> groups
        lazy = true,
        mini = true, -- mini.icons
        snacks = true,
        treesitter = true,
        trouble = true,
        whichkey = true,
      },
    },
  },
}
