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
  {
    "MunsMan/kitty-navigator.nvim",
    keys = {
      { "<C-h>", function() require("kitty-navigator").navigateLeft() end, desc = "Move left a Split", mode = { "n" } },
      { "<C-j>", function() require("kitty-navigator").navigateDown() end, desc = "Move down a Split", mode = { "n" } },
      { "<C-k>", function() require("kitty-navigator").navigateUp() end, desc = "Move up a Split", mode = { "n" } },
      { "<C-l>", function() require("kitty-navigator").navigateRight() end, desc = "Move right a Split", mode = { "n" } },
    },
  },
  { import = "plugins" },
} --[[@as LazySpec]], {
  install = { colorscheme = { "cyberdream" } },
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
