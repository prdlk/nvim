--- vellum.nvim: live GitHub-markdown preview in a split, mermaid/math as images
--- `:Vellum` toggles it, `:Vellum export [file.pdf|file.html]` exports.
---
--- Runs from the prdlk fork's `mdx` branch until blackhat-7/vellum.nvim#4
--- merges: upstream only accepts filetype `markdown`, so `markdown.mdx`
--- buffers could not export, take over the preview or be followed by links,
--- and their import/export lines and {/* comments */} rendered as text.
--- @module plugins.vellum

---@type LazySpec
return {
  "prdlk/vellum.nvim",
  branch = "mdx",
  -- `markdown.mdx` is the mdx pack's filetype; a dotted filetype only matches
  -- a pattern that spells it out
  ft = { "markdown", "markdown.mdx" },
  cmd = "Vellum",
  opts = {},
}
