-- Customize Mason
-- This file configures non-LSP tools (formatters, linters, debuggers, etc.)
-- LSP servers are configured in astrolsp.lua via mason-lspconfig

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- Formatters (non-LSP)
        "stylua",
        "rustfmt",
        "taplo",

        -- Linters
        "stylelint",
        "markdownlint",

        -- Debuggers
        "debugpy",

        -- Other tools
        "tree-sitter-cli",

        -- Note: oxlint and oxfmt should be installed separately via cargo/npm
        -- Note: LSP servers are configured in astrolsp.lua
      },
    },
  },
}
