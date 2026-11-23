-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  version = false, -- Use latest astrocommunity
  { import = "astrocommunity.bars-and-lines.bufferline-nvim" },
  { import = "astrocommunity.editing-support.conform-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.pack.biome" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.golangci-lint" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.pkl" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.tailwindcss" },
  -- python: treesitter/debugpy/venv-selector + basedpyright (types/completion)
  -- + ruff language server (lint diagnostics, organizeImports/fixAll actions)
  -- + black. Imports are sorted by ruff, formatting is black's; the final
  -- conform chain is pinned in plugins/conform.lua. Interpreter resolution is
  -- overridden in plugins/python.lua.
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.python.black" },
  { import = "astrocommunity.completion.supermaven-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
}
