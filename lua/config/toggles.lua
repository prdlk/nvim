--- UI toggles for the `<Leader>u` group, registered through
--- `Snacks.toggle():map()` instead of plain astrocore mappings.
---
--- That is what buys the snacks default which-key integration: each toggle
--- adds its own which-key entry with the enabled/disabled state icon, the
--- green/yellow state colour, and an "Enable X" / "Disable X" label that
--- flips with the current value. Plain `vim.keymap.set` mappings only ever
--- show a static description.
---
--- Called from polish.lua, i.e. after astrocore has installed its own
--- `<Leader>u` defaults, so these win on the keys they share. Toggles
--- AstroNvim provides and snacks does not (`<Leader>ub` background,
--- `<Leader>uA` autochdir, ...) are left alone.
--- @module config.toggles

local M = {}

function M.setup()
  local ok, Snacks = pcall(require, "snacks")
  if not ok then return end
  local toggle = Snacks.toggle

  toggle.diagnostics():map "<Leader>ud"
  toggle.line_number():map "<Leader>un"
  toggle.option("relativenumber", { name = "Relative Numbers" }):map "<Leader>ur"
  toggle.option("wrap", { name = "Wrap" }):map "<Leader>uw"
  toggle.option("spell", { name = "Spelling" }):map "<Leader>us"
  toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal" }):map "<Leader>uc"
  toggle.inlay_hints():map "<Leader>ui"
  toggle.treesitter():map "<Leader>ut"
  toggle.indent():map "<Leader>uI"
  toggle.dim():map "<Leader>ux"
  toggle.zen():map "<Leader>uz"
  toggle.zoom():map "<Leader>uZ"
  toggle.animate():map "<Leader>ua"
  toggle.scroll():map "<Leader>uS"
  toggle.profiler():map "<Leader>up"
  toggle.profiler_highlights():map "<Leader>uh"

  -- conform owns format-on-save (astrocommunity conform pack) and gates it on
  -- vim.b.autoformat / vim.g.autoformat; the pre-save LSP code action pass
  -- rides the same hook, so this one flag governs the whole on-save pipeline.
  -- Mirrors the pack's own <Leader>uF, with which-key state on top.
  toggle({
    name = "Format on Save",
    get = function() return vim.F.if_nil(vim.b.autoformat, vim.g.autoformat, true) end,
    set = function(state) vim.g.autoformat, vim.b.autoformat = state, nil end,
  }):map "<Leader>uf"

  -- virtual_lines is native since 0.11; showing both at once is unreadable,
  -- so the two diagnostic renderers trade places
  toggle({
    name = "Diagnostic Virtual Lines",
    get = function() return ((vim.diagnostic.config() or {}).virtual_lines and true) or false end,
    set = function(state) vim.diagnostic.config { virtual_lines = state, virtual_text = not state } end,
  }):map "<Leader>ul"
end

return M
