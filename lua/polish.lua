-- This will run last in the setup process.
-- Pure lua; anything that doesn't fit the normal config locations goes here.

-- Snacks.keymap: LSP-aware keymaps, only applied to buffers with a client
-- that supports the given method (which-key picks up the desc). ]] and [[
-- cycle through the LSP references that snacks.words auto-highlights,
-- complementing the core astrolsp `gd` / `gr` binds.
local ok, snacks = pcall(require, "snacks")
if ok then
  snacks.keymap.set("n", "]]", function() snacks.words.jump(vim.v.count1, true) end, {
    lsp = { method = "textDocument/documentHighlight" },
    desc = "Next reference",
  })
  snacks.keymap.set("n", "[[", function() snacks.words.jump(-vim.v.count1, true) end, {
    lsp = { method = "textDocument/documentHighlight" },
    desc = "Previous reference",
  })
end

-- Define _G.EditFromYazi eagerly: the yazi opener (~/.local/bin/yazi-nvim-open)
-- calls it via --remote-expr from ANY yazi running in an nvim terminal, even
-- one started before the session keymaps ever fired.
require "config.yazi_session"
