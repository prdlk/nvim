-- Bufferline configuration with AstroNvim integration
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
        indicator = { style = "icon", icon = "▎" },
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
        groups = {
          options = { toggle_hidden_on_enter = true },
          items = {
            groups.builtin.ungrouped,

            -- Module groups
            {
              name = "",
              auto_close = true,
              highlight = { fg = "#5ef1ff" },
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "x/dex/.*%.go$" or bufname:match "proto/dex/.*%.proto$"
              end,
            },
            {
              name = "DID",
              auto_close = true,
              highlight = { fg = "#5ef1ff" },
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "x/did/.*%.go$" or bufname:match "proto/did/.*%.proto$"
              end,
            },
            {
              name = "DWN",
              auto_close = true,
              highlight = { fg = "#5ef1ff" },
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "x/dwn/.*%.go$" or bufname:match "proto/dwn/.*%.proto$"
              end,
            },
            {
              name = "SVC",
              highlight = { fg = "#5ef1ff" },
              auto_close = true,
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "x/svc/.*%.go$" or bufname:match "proto/svc/.*%.proto$"
              end,
            },

            -- Tests
            {
              name = "Tests",
              auto_close = true,
              highlight = { fg = "#ff5ea0" },
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "_test%.go$" or bufname:match "/test/"
              end,
            },

            -- Auto-close groups
            {
              name = "Actions",
              highlight = { fg = "#ff5ef1" },
              auto_close = true,
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "%.ya?ml$" and bufname:match "%.github/"
              end,
            },
            {
              name = "Claude",
              highlight = { fg = "#ffbd5e" },
              auto_close = true,
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "%.claude/" or bufname:match "CLAUDE%.md$"
              end,
            },
            {
              name = "Docs",
              highlight = { fg = "#ffffff" },
              auto_close = true,
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return bufname:match "%.mdx?$" or bufname:match "/docs/"
              end,
            },
            {
              name = "Config",
              highlight = { fg = "#3c4048" },
              auto_close = true,
              matcher = function(buf)
                local bufname = vim.api.nvim_buf_get_name(buf.id)
                return (bufname:match "%.ya?ml$" and not bufname:match "%.github/")
                  or bufname:match "%.json$"
                  or bufname:match "%.toml$"
                  or bufname:match "%.sh$"
              end,
            },
          },
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
