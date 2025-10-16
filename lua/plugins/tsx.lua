--- TypeScript/TSX development optimizations
--- Includes LSP, treesitter, linting, and React-specific tooling
--- @module plugins.tsx

return {
  -- TypeScript LSP with enhanced settings for React/TSX
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        -- TypeScript/JavaScript LSP
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              suggest = {
                includeCompletionsForModuleExports = true,
              },
              preferences = {
                importModuleSpecifier = "relative",
                jsxAttributeCompletionStyle = "auto",
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        -- Volar for Vue (also helpful for some React scenarios)
        volar = {
          filetypes = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact" },
        },
        -- Tailwind CSS LSP for shadcn/ui
        tailwindcss = {
          root_dir = function(fname)
            local util = require "lspconfig.util"
            return util.root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js")(fname)
          end,
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                },
              },
            },
          },
        },
        -- CSS LSP
        cssls = {},
        -- HTML LSP
        html = {
          filetypes = { "html", "typescriptreact", "javascriptreact" },
        },
        -- ESLint LSP
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            experimental = {
              useFlatConfig = true,
            },
          },
        },
      },
    },
  },

  -- Enhanced treesitter for TSX/React
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
          "typescript",
          "tsx",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "css",
          "scss",
          "html",
          "markdown",
          "markdown_inline",
          "regex",
          "bash",
          "vim",
          "lua",
        })
      end
    end,
  },

  -- Treesitter context for React component awareness
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      patterns = {
        default = {
          "class",
          "function",
          "method",
          "for",
          "while",
          "if",
          "switch",
          "case",
          "interface",
          "struct",
          "enum",
        },
        typescript = {
          "class_declaration",
          "abstract_class_declaration",
          "function_declaration",
          "method_definition",
          "arrow_function",
          "function_expression",
          "lexical_declaration",
          "variable_declaration",
        },
        typescriptreact = {
          "class_declaration",
          "function_declaration",
          "method_definition",
          "arrow_function",
          "function_expression",
          "jsx_element",
          "jsx_self_closing_element",
        },
      },
    },
  },

  -- TypeScript utilities and tools
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = true,
        },
      },
    },
  },

  -- Mason LSP configurations
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "tsserver",
        "tailwindcss",
        "cssls",
        "html",
        "eslint",
        "jsonls",
      })
    end,
  },
  -- Auto-close and auto-rename JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "xml",
      "vue",
      "svelte",
    },
    opts = {
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
    },
  },

  -- Package info for package.json
  {
    "vuki656/package-info.nvim",
    event = "BufRead package.json",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  -- Crates.io integration (useful for Rust tooling in Workers)
  {
    "saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
}
