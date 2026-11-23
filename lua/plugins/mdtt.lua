--- mdtt.nvim: markdown table editor, a native port of mdtt on snacks.nvim.
--- `<C-i>t` in markdown/mdx buffers edits the table under the cursor, or
--- picks / creates one; `:Mdtt` does the same anywhere.
---
--- `dev = true` loads the local checkout under lazy's `dev.path`
--- (lua/lazy_setup.lua); `dev.fallback` clones prdlk/mdtt.nvim where there is
--- none. The `<C-i>t` bind is buffer-local to markdown so the rest of the
--- `<C-i>` group (templates on `<C-i><C-i>`, plugins/astrocore.lua) stays global.
--- @module plugins.mdtt

---@type LazySpec
return {
  "prdlk/mdtt.nvim",
  dev = true,
  dependencies = { "folke/snacks.nvim" },
  cmd = "Mdtt",
  keys = {
    {
      "<C-i>t",
      function() require("mdtt").edit() end,
      -- `markdown.mdx` is the mdx pack's filetype; a dotted filetype only
      -- matches a pattern that spells it out
      ft = { "markdown", "markdown.mdx" },
      desc = "Edit/insert table",
    },
  },
}
