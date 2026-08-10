--- Custom statusline (heirline via astroui.status components):
---   left  = NvChad style: mode pill with separators, file info, git branch/diff
---   right = VSCode style: diagnostics (NvChad icons), LSP, Ln/Col, Spaces,
---           encoding, EOL, filetype — flat text, no powerline chunks
---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      icons = {
        VimIcon = "",
        GitBranch = "",
        GitAdd = "",
        GitChange = "",
        GitDelete = "",
        -- NvChad diagnostic icons
        DiagnosticError = "󰅙",
        DiagnosticWarn = "",
        DiagnosticInfo = "󰋼",
        DiagnosticHint = "󰛩",
      },
      status = {
        -- NvChad-style slanted separators for the left-side sections
        separators = {
          left = { "", "" },
          right = { " ", "" },
        },
        colors = function(hl)
          local get_hlgroup = require("astroui").get_hlgroup
          local comment_fg = get_hlgroup("Comment").fg
          hl.git_branch_fg = comment_fg
          hl.git_added = comment_fg
          hl.git_changed = comment_fg
          hl.git_removed = comment_fg
          hl.blank_bg = get_hlgroup("Folded").fg
          hl.file_info_bg = get_hlgroup("Visual").bg
          return hl
        end,
        attributes = {
          mode = { bold = true },
        },
      },
    },
  },

  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"

      opts.statusline = {
        hl = { fg = "fg", bg = "bg" },

        -- ────────────────── left: NvChad ──────────────────
        status.component.mode {
          mode_text = {
            icon = { kind = "VimIcon", padding = { right = 1, left = 1 } },
          },
          surround = {
            separator = "left",
            color = function() return { main = status.hl.mode_bg(), right = "blank_bg" } end,
          },
        },
        status.component.builder {
          { provider = "" },
          surround = {
            separator = "left",
            color = { main = "blank_bg", right = "file_info_bg" },
          },
        },
        status.component.file_info {
          filename = { fallback = "Empty" },
          filetype = false,
          file_read_only = false,
          padding = { right = 1 },
          surround = { separator = "left", condition = false },
        },
        status.component.git_branch {
          git_branch = { padding = { left = 1 } },
          surround = { separator = "none" },
        },
        status.component.git_diff {
          padding = { left = 1 },
          surround = { separator = "none" },
        },

        status.component.fill(),

        -- ────────────────── right: VSCode ──────────────────
        status.component.diagnostics {
          padding = { right = 1 },
          surround = { separator = "none" },
        },
        status.component.lsp {
          lsp_progress = false,
          padding = { right = 1 },
          surround = { separator = "none" },
        },
        status.component.builder {
          {
            provider = function()
              local pos = vim.api.nvim_win_get_cursor(0)
              return ("Ln %d, Col %d"):format(pos[1], pos[2] + 1)
            end,
          },
          padding = { right = 2 },
        },
        status.component.builder {
          {
            provider = function()
              if vim.bo.expandtab then return ("Spaces: %d"):format(vim.bo.shiftwidth) end
              return ("Tab Size: %d"):format(vim.bo.tabstop)
            end,
          },
          padding = { right = 2 },
        },
        status.component.builder {
          {
            provider = function()
              local enc = (vim.bo.fileencoding ~= "" and vim.bo.fileencoding) or vim.o.encoding
              local eol = ({ unix = "LF", dos = "CRLF", mac = "CR" })[vim.bo.fileformat] or vim.bo.fileformat
              return ("%s  %s"):format(enc:upper(), eol)
            end,
          },
          padding = { right = 2 },
        },
        status.component.file_info {
          file_icon = false,
          filename = false,
          filetype = {},
          file_modified = false,
          file_read_only = false,
          padding = { right = 1 },
          surround = { separator = "none", condition = false },
        },
      }
    end,
  },
}
