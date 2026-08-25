--- AstroLSP: the configuration that should only exist while a language server
--- is attached (`:h astrolsp`). Every mapping carries a `cond` — a server
--- method name — so it is created buffer-locally on attach and is simply
--- absent (including in which-key) wherever no server advertises it, instead
--- of being a global bind that errors or silently does nothing.
---
--- Deliberately configured elsewhere:
---   * per-server settings: basedpyright interpreter resolution lives in
---     plugins/python.lua, the language packs in community.lua own the rest
---   * formatting: conform owns it end to end. The astrocommunity conform
---     pack sets `formatting.disabled = true` here, and the pre-save code
---     action pass hangs off conform's `format_on_save` hook so its order
---     relative to formatting is deterministic (plugins/conform.lua)
---   * diagnostics jumps/pickers (`J`, `K`, `<C-a>d`) and everything else that
---     works without a server: plugins/astrocore.lua
--- @module plugins.astrolsp

--- @param source string snacks.picker source
--- @return function
local function trouble_picker(source)
  return function() require("config.picker").with_trouble(source) end
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    mappings = {
      n = {
        -- snacks.words auto-highlights the references of the symbol under the
        -- cursor (`words` in plugins/user.lua); these cycle through them,
        -- complementing the core astrolsp `gd` / `gr` binds
        ["]]"] = {
          function() require("snacks").words.jump(vim.v.count1, true) end,
          desc = "Next reference",
          cond = "textDocument/documentHighlight",
        },
        ["[["] = {
          function() require("snacks").words.jump(-vim.v.count1, true) end,
          desc = "Previous reference",
          cond = "textDocument/documentHighlight",
        },

        -- <C-a>: assist. Code actions and symbol search, each with the
        -- trouble.nvim hand-off on <C-t> where a picker is involved.
        ["<C-a>a"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "Show code actions",
          cond = "textDocument/codeAction",
        },
        ["<C-a>s"] = {
          trouble_picker "lsp_symbols",
          desc = "Search LSP symbols (<C-t> sends to Trouble)",
          cond = "textDocument/documentSymbol",
        },
        ["<C-a>S"] = {
          trouble_picker "lsp_workspace_symbols",
          desc = "Search LSP workspace symbols (<C-t> sends to Trouble)",
          cond = "workspace/symbol",
        },
        ["<C-f><C-f>"] = {
          function() require("snacks").picker.lsp_symbols { layout = { preset = "vscode", preview = "main" } } end,
          desc = "Find LSP symbols",
          cond = "textDocument/documentSymbol",
        },
      },
    },
  },
}
