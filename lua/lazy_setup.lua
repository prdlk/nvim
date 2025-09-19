require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^4", -- Ensure we use AstroNvim v4+
    import = "astronvim.plugins",
    opts = {
      -- Leaders are set early in init.lua to ensure consistency
      icons_enabled = (vim.g.have_nerd_font ~= false),
      pin_plugins = nil,
      update_notifications = false,
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  install = { colorscheme = { "astrotheme" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
