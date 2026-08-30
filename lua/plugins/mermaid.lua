--- Mermaid diagrams inside markdown/mdx (and standalone `.mmd`/`.mermaid`
--- files): tree-sitter highlighting for the fence contents, plus syntax
--- diagnostics from mermaid's own parsers.
---
--- The `mermaid` parser is all the highlighting needs — markdown's stock
--- injections query hands ```mermaid fence contents to whatever parser the info
--- string names, and `markdown.mdx` buffers parse as markdown, so mdx is
--- covered by the same parser.
---
--- Diagnostics are not a language server (none is packaged for mermaid) and are
--- deliberately not derived from tree-sitter, which rejects too much valid
--- mermaid to be used for errors; see config.mermaid for the measurements and
--- the validator it drives.
--- @module plugins.mermaid

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = { ensure_installed = { "mermaid" } },

    autocmds = {
      mermaid_diagnostics = {
        {
          event = "FileType",
          -- a dotted filetype only matches a pattern that spells it out, so
          -- `markdown.*` is what catches the `markdown.mdx` buffers the mdx
          -- pack sets up (plain `markdown` does not)
          pattern = { "markdown", "markdown.*", "mermaid" },
          desc = "Validate mermaid diagrams in this buffer as it changes",
          callback = function(args) require("config.mermaid").attach(args.buf) end,
        },
      },
    },

    commands = {
      MermaidCheck = {
        function() require("config.mermaid").check() end,
        desc = "Re-validate the mermaid diagrams in the current buffer",
      },
    },
  },
}
