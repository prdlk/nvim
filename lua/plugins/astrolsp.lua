return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      format_on_save = {
        enabled = true, -- enable or disable
        ignore_filetypes = { -- disable format on save for specified filetypes
          "markdown",
          "python",
        },
      },
    },
  },
}
