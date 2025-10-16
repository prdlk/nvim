--- Linting and formatting configuration
--- Includes oxlint, prettier, and ESLint integration
--- @module plugins.linting

return {
  -- Conform for formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        lua = { "stylua" },
        rust = { "rustfmt" },
        toml = { "taplo" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
      formatters = {
        prettier = {
          prepend_args = {
            "--plugin=prettier-plugin-tailwindcss",
          },
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- Command to toggle format on save
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          -- Toggle buffer-local setting
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        else
          -- Toggle global setting
          vim.g.disable_autoformat = not vim.g.disable_autoformat
        end
        local status = vim.g.disable_autoformat and "disabled" or "enabled"
        vim.notify("Format on save " .. status, vim.log.levels.INFO)
      end, {
        desc = "Toggle format on save",
        bang = true,
      })
    end,
  },

  -- Lint with nvim-lint (oxlint integration)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"

      -- Configure oxlint for TypeScript/JavaScript
      lint.linters.oxlint = {
        cmd = "oxlint",
        stdin = false,
        args = {
          "--format=json",
        },
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output)
          if output == "" or output == nil then return {} end

          local ok, decoded = pcall(vim.fn.json_decode, output)
          if not ok then return {} end

          local diagnostics = {}
          for _, item in ipairs(decoded) do
            if item.diagnostics then
              for _, diagnostic in ipairs(item.diagnostics) do
                table.insert(diagnostics, {
                  lnum = diagnostic.start.line - 1,
                  end_lnum = diagnostic["end"].line - 1,
                  col = diagnostic.start.column - 1,
                  end_col = diagnostic["end"].column - 1,
                  severity = vim.diagnostic.severity.WARN,
                  source = "oxlint",
                  message = diagnostic.message,
                  code = diagnostic.rule_id,
                })
              end
            end
          end
          return diagnostics
        end,
      }

      -- Configure linters per filetype
      lint.linters_by_ft = {
        typescript = { "oxlint" },
        typescriptreact = { "oxlint" },
        javascript = { "oxlint" },
        javascriptreact = { "oxlint" },
        css = { "stylelint" },
        scss = { "stylelint" },
        markdown = { "markdownlint" },
      }

      -- Auto-lint on save and text changed
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        group = lint_augroup,
        callback = function()
          -- Only lint if file exists on disk
          if vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1 then lint.try_lint() end
        end,
      })
    end,
  },

  -- Mason tool installer for linters/formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    opts = {
      ensure_installed = {
        -- Formatters
        "prettier",
        "stylua",
        "rustfmt",
        "taplo",
        -- Linters
        "eslint_d",
        "stylelint",
        "markdownlint",
        -- Note: oxlint should be installed via cargo/npm separately
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- Additional diagnostics UI
  {
    "folke/trouble.nvim",
    optional = true,
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
  },

  -- Inline linting hints
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("lsp_lines").setup()
      -- Disable virtual_text since lsp_lines will show diagnostics
      vim.diagnostic.config { virtual_text = false }

      -- Toggle command
      vim.api.nvim_create_user_command("LspLinesToggle", function()
        local new_value = not require("lsp_lines").toggle()
        vim.diagnostic.config { virtual_text = new_value }
      end, { desc = "Toggle LSP lines" })
    end,
  },

  -- Better quickfix for showing lint errors
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_resize_height = true,
      func_map = {
        vsplit = "v",
        split = "s",
        tab = "t",
        tabb = "T",
        tabc = "<C-t>",
        ptogglemode = "z,",
      },
    },
  },
}
