--- Snacks.nvim configuration
--- Overrides and customizations for snacks.nvim features
--- Relies on astrocommunity.recipes.telescope-nvim-snacks for base setup
--- @module plugins.snacks

return {
  "folke/snacks.nvim",
  opts = {
    -- Disable dashboard - we use custom startup picker in astrocore.lua
    dashboard = { enabled = false },

    -- Enable snacks features we use throughout config
    bigfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    words = { enabled = true },
    indent = { enabled = true },

    -- Terminal styles
    styles = {
      terminal = {
        bo = { filetype = "snacks_terminal" },
        wo = {},
        keys = {
          q = "hide",
          term_normal = {
            "<esc>",
            function(self)
              self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
              if self.esc_timer:is_active() then
                self.esc_timer:stop()
                vim.cmd "stopinsert"
              else
                self.esc_timer:start(200, 0, function() end)
                return "<esc>"
              end
            end,
            mode = "t",
            expr = true,
            desc = "Double escape to normal mode",
          },
        },
      },
    },
  },
}
