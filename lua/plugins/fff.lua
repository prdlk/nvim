--- fff.nvim: rust-backed fuzzy file finder and live grep with frecency
--- Backs the <C-f> file/grep bindings in plugins/astrocore.lua. Honours
--- .gitignore plus per-repo .ignore files; the config.ignore_patterns
--- snacks filter does not apply here (snacks remains for non-file sources:
--- diagnostics, lines, LSP symbols, recent, projects, templates).
--- @module plugins.fff

return {
  "dmtrKovalenko/fff",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  lazy = false, -- the plugin lazy-initialises itself
  opts = {
    lazy_sync = true,
  },
}
