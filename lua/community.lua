
-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  version = false, -- Use latest astrocommunity
  { import = "astrocommunity.bars-and-lines.bufferline-nvim" },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  { import = "astrocommunity.editing-support.conform-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.pack.biome" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.golangci-lint" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.pkl" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.tailwindcss" },
  -- python: treesitter/debugpy/venv-selector + basedpyright language server.
  -- The full `pack.python` also pulls black + isort; formatting stays on ruff
  -- (see plugins/conform.lua), so only the base and basedpyright subpacks are
  -- imported. Interpreter resolution is overridden in plugins/python.lua.
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.completion.supermaven-nvim" },
  { import = "astrocommunity.lsp.dev-tools-nvim" },
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
  { import = "astrocommunity.recipes.heirline-nvchad-statusline" },
}
