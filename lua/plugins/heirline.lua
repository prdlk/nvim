--- Custom statusline (heirline via astroui.status components):
---   left  = NvChad style: angled mode pill, file info pill, git branch/diff
---   right = VSCode-style info modules, ending in an NvChad mode-colored
---           progress pill (nerd font icon + Top/Bot/percentage)
---
--- NOTE: every nerd-font PUA glyph in this file is written as a \u{XXXX}
--- Lua escape ON PURPOSE — raw 3-byte PUA glyphs (U+E000-U+F8FF) have been
--- stripped by tooling before, silently flattening the statusline.
--- Keep this file ASCII-only.
---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      icons = {
        VimIcon = "\u{e62b}", -- nf-custom-vim
        GitBranch = "\u{e725}", -- nf-dev-git_branch
        GitAdd = "\u{f457}", -- nf-oct-diff_added
        GitChange = "\u{f459}", -- nf-oct-diff_modified
        GitDelete = "\u{f458}", -- nf-oct-diff_removed
        Progress = "\u{f124}", -- nf-fa-location_arrow
        -- NvChad diagnostic icons
        DiagnosticError = "\u{f0159}", -- nf-md-close_circle
        DiagnosticWarn = "\u{f071}", -- nf-fa-warning
        DiagnosticInfo = "\u{f02fc}", -- nf-md-information
        DiagnosticHint = "\u{f06e9}", -- nf-md-lightbulb_on
      },
      status = {
        -- NvChad-style angled (powerline arrow) separators
        separators = {
          left = { "", "\u{e0b0} " }, -- trailing solid right-arrow for left pills
          right = { " \u{e0b2}", "" }, -- leading solid left-arrow for right pills
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
          surround = {
            separator = "left",
            color = { main = "file_info_bg", right = "bg" },
          },
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

        -- ────────────────── right: VSCode info + NvChad progress ──────────────────
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
        -- NvChad-style progress pill: mode-colored, angled, nerd font icon
        status.component.builder {
          {
            provider = function()
              local cur, total = vim.fn.line ".", vim.fn.line "$"
              local pct
              if cur == 1 then
                pct = "Top"
              elseif cur == total then
                pct = "Bot"
              else
                pct = math.floor(cur / total * 100 + 0.5) .. "%%"
              end
              return (" %s %s "):format(require("astroui").get_icon "Progress", pct)
            end,
          },
          hl = { fg = "bg", bold = true },
          surround = {
            separator = "right",
            color = function() return { main = status.hl.mode_bg(), left = "bg" } end,
          },
        },
      }
    end,
  },
}
