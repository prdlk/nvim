--- Bufferline configuration with AstroNvim integration
--- Provides enhanced buffer/tab management with diagnostics and custom close handlers
--- @module plugins.bufferline

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "AstroNvim/astrocore" },
  event = "VeryLazy",
  config = function()
    local bufferline = require "bufferline"
    local groups = require "bufferline.groups"

    bufferline.setup {
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = function(n) require("astrocore.buffer").close(n) end,
        right_mouse_command = function(n) require("astrocore.buffer").close(n) end,
        separator_style = "thick",
        indicator = { style = "none", icon = "" },
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local s = " "
          for e, _ in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or " ")
            s = s .. sym
          end
          return s
        end,
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        modified_icon = "●",
        buffer_close_icon = "󰅖",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        offsets = {
          { filetype = "snacks_picker", text = "", padding = 0 },
        },
      },
      highlights = {
        group_label = { fg = "#ffffff", bg = "#423f5a", bold = true },
        group_separator = { fg = "#585b70" },
        buffer_selected = { fg = "#89dceb", bold = true },
        buffer_visible = { fg = "#585b70" },
        background = { fg = "#585b70" },
        hint = { fg = "#94e2d5" },
        hint_selected = { fg = "#94e2d5", bold = true },
        warning = { fg = "#f9e2af" },
        warning_selected = { fg = "#f9e2af", bold = true },
        error = { fg = "#f38ba8" },
        error_selected = { fg = "#f38ba8", bold = true },
      },
    }
  end,
}
