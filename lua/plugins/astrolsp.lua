--- AstroLSP configuration optimized for tech stack:
--- - Cloudflare Workers/Pages
--- - Golang (Cosmos SDK)
--- - TypeScript/React/Vite
--- - Protobufs
--- - Bun/ES Modules/WASM
--- @module plugins.astrolsp

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Enable LSP features
    features = {
      autoformat = true,
      codelens = true,
      inlay_hints = true, -- Enable inlay hints for TS/Go
      lsp_handlers = true,
      semantic_tokens = true,
    },

    -- LSP UI defaults
    defaults = {
      hover = { border = "rounded", silent = true }, -- Rounded border for hover windows
      signature_help = { border = "rounded", silent = true }, -- Enable signature help
    },

    -- LSP client flags
    flags = {
      exit_timeout = 5000, -- Time to wait for LSP server to exit before force kill
      debounce_text_changes = 150, -- Debounce didChange notifications
    },

    -- LSP Formatting Configuration
    formatting = {
      format_on_save = {
        enabled = true,
        -- Allow specific filetypes (prefer conform.nvim for JS/TS)
        allow_filetypes = {
          "go",
          "proto",
          "toml",
          "lua",
        },
      },
      -- Disable LSP formatting for these (use conform.nvim/biome instead)
      disabled = {
        "tsserver", -- Use biome/prettier via conform
        "vtsls", -- Use biome/prettier via conform
        "eslint", -- Diagnostics only, not formatting
        "html", -- Use conform
        "cssls", -- Use conform
        "tailwindcss", -- Doesn't format
      },
      timeout_ms = 5000, -- Increase timeout for large Go files
      filter = function(client)
        -- Prefer conform.nvim for JS/TS formatting
        if vim.bo.filetype == "typescript" or vim.bo.filetype == "javascript" or vim.bo.filetype == "typescriptreact" or vim.bo.filetype == "javascriptreact" then
          return false
        end
        -- Use gopls for Go formatting
        if vim.bo.filetype == "go" then
          return client.name == "gopls"
        end
        return true
      end,
    },

    -- Enable file operations for better refactoring
    file_operations = {
      timeout = 10000,
      operations = {
        willCreate = true,
        didCreate = true,
        willRename = true,
        didRename = true,
        willDelete = true,
        didDelete = true,
      },
    },

    -- Language server configurations
    config = {
      -- Golang configuration optimized for Cosmos SDK
      gopls = {
        settings = {
          gopls = {
            -- Code analysis
            analyses = {
              unusedparams = true,
              shadow = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
              unusedvariable = true,
            },
            -- Staticcheck integration
            staticcheck = true,
            -- Inlay hints
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            -- Code completion
            usePlaceholders = true,
            completeUnimported = true,
            -- Build flags for Cosmos SDK
            buildFlags = { "-tags=ledger,test" },
            -- Workspace settings
            directoryFilters = {
              "-**/node_modules",
              "-**/.git",
              "-**/.vscode",
              "-**/.idea",
              "-**/.devbox",
              "-**/dist",
              "-**/build",
            },
            -- Semantic tokens
            semanticTokens = true,
            -- Code lenses
            codelenses = {
              gc_details = true,
              generate = true,
              regenerate_cgo = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
          },
        },
      },

      -- TypeScript configuration for Vite/React/Cloudflare
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
              completeFunctionCalls = true,
            },
            -- Cloudflare Workers types
            preferences = {
              importModuleSpecifier = "relative",
              importModuleSpecifierEnding = "minimal",
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
            suggest = {
              completeFunctionCalls = true,
            },
          },
        },
      },

      -- ESLint configuration
      eslint = {
        settings = {
          workingDirectories = { mode = "auto" },
          format = false, -- Don't use ESLint for formatting
        },
        on_attach = function(client, bufnr)
          -- Disable formatting capability (use conform.nvim)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },

      -- Tailwind for React components
      tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                -- Support for cn() and clsx() utilities
                { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
            validate = true,
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidScreen = "error",
              invalidVariant = "error",
              invalidConfigPath = "error",
              invalidTailwindDirective = "error",
              recommendedVariantOrder = "warning",
            },
          },
        },
      },

      -- HTML for React/templates
      html = {
        settings = {
          html = {
            format = {
              templating = true,
              wrapLineLength = 100,
              wrapAttributes = "auto",
            },
            hover = {
              documentation = true,
              references = true,
            },
          },
        },
      },

      -- Protobuf LSP
      bufls = {
        settings = {
          -- Add any buf-specific settings
        },
      },

      -- JSON/JSONC for config files
      jsonls = {
        settings = {
          json = {
            schemas = {
              -- Cloudflare wrangler.toml
              {
                fileMatch = { "wrangler.toml", "wrangler.json" },
                url = "https://raw.githubusercontent.com/cloudflare/wrangler/main/wrangler-schema.json",
              },
              -- Package.json
              {
                fileMatch = { "package.json" },
                url = "https://json.schemastore.org/package.json",
              },
              -- tsconfig.json
              {
                fileMatch = { "tsconfig.json", "tsconfig.*.json" },
                url = "https://json.schemastore.org/tsconfig.json",
              },
            },
            validate = { enable = true },
          },
        },
      },

      -- YAML for configs
      yamlls = {
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
            },
            validate = true,
            hover = true,
            completion = true,
          },
        },
      },

      -- Lua for Neovim config
      lua_ls = {
        settings = {
          Lua = {
            hint = {
              enable = true,
              arrayIndex = "Auto",
              setType = true,
            },
          },
        },
      },
    },

    -- Capabilities configuration
    capabilities = {
      textDocument = {
        completion = {
          completionItem = {
            documentationFormat = { "markdown", "plaintext" },
            snippetSupport = true,
            preselectSupport = true,
            insertReplaceSupport = true,
            labelDetailsSupport = true,
            deprecatedSupport = true,
            commitCharactersSupport = true,
            tagSupport = { valueSet = { 1 } },
            resolveSupport = {
              properties = {
                "documentation",
                "detail",
                "additionalTextEdits",
              },
            },
          },
        },
      },
    },

    -- LSP-specific keymappings (keeping existing bindings)
    mappings = {
      n = {
        -- LSP Code Actions
        ["<C-a>a"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "LSP Code Action",
        },

        -- LSP Hover
        ["<C-a>h"] = {
          function() vim.lsp.buf.hover() end,
          desc = "LSP Hover",
        },

        -- LSP Rename (using inc-rename plugin)
        ["<C-a>r"] = {
          function() return ":IncRename " .. vim.fn.expand("<cword>") end,
          expr = true,
          desc = "Rename current symbol",
          cond = "textDocument/rename",
        },

        -- LSP Diagnostics (using snacks.picker)
        ["<C-a>d"] = {
          function() require("snacks").picker.diagnostics() end,
          desc = "Find LSP diagnostics",
        },

        -- LSP Symbols (using snacks.picker)
        ["<C-a>s"] = {
          function() require("snacks").picker.lsp_symbols() end,
          desc = "Find LSP symbols",
        },

        -- Navigate diagnostics
        K = {
          function() vim.diagnostic.goto_prev() end,
          desc = "Previous Diagnostic",
        },
        J = {
          function() vim.diagnostic.goto_next() end,
          desc = "Next Diagnostic",
        },
      },
    },

    -- Autocmds for LSP-specific behavior
    autocmds = {
      -- Disable inlay hints in insert mode for cleaner editing
      no_insert_inlay_hints = {
        cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
        {
          event = "InsertEnter",
          desc = "Disable inlay hints on insert",
          callback = function(args)
            local filter = { bufnr = args.buf }
            if vim.lsp.inlay_hint.is_enabled(filter) then
              vim.lsp.inlay_hint.enable(false, filter)
              vim.api.nvim_create_autocmd("InsertLeave", {
                buffer = args.buf,
                once = true,
                callback = function() vim.lsp.inlay_hint.enable(true, filter) end,
              })
            end
          end,
        },
      },
    },
  },
}
