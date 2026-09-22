--- `<Leader>e` visual-mode formatting binds for markdown/mdx buffers; the
--- editing itself lives in config.markdown_edit.
---
--- Buffer-local so `<Leader>e` stays the git files picker everywhere else.
--- @module plugins.markdown-edit

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      markdown_edit = {
        {
          event = "FileType",
          -- `markdown.*` catches the `markdown.mdx` buffers the mdx pack sets
          -- up; a plain `markdown` pattern does not match a dotted filetype
          pattern = { "markdown", "markdown.*" },
          desc = "Markdown formatting binds for the visual selection",
          callback = function(args)
            require("astrocore").set_mappings(require("config.markdown_edit").mappings, { buffer = args.buf })
          end,
        },
      },
    },
  },
}
