-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@param opts AstroUIOpts
    opts = function(_, opts)
      -- cyberdream (dark) or koda-light (light), from Omarchy's theme mode or
      -- the terminal background; swapped live on every 'background' change.
      -- See lua/config/theme.lua.
      opts.colorscheme = require("config.theme").init()
    end,
  },
  {
    -- the light half: Omarchy's Hazy Peak. Loaded on `:colorscheme
    -- koda-light`; palette overrides in lua/config/theme.lua.
    "oskarnurm/koda.nvim",
    lazy = true,
    opts = function() return require("config.theme").koda_opts end,
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
