--- fff.nvim: rust-backed fuzzy file finder and live grep with frecency
--- Backs the <C-f> file/grep bindings and <Leader><Leader> in
--- plugins/astrocore.lua. Honours .gitignore plus per-repo .ignore files; the
--- config.ignore_patterns snacks filter does not apply here (snacks remains
--- for non-file sources: diagnostics, lines, LSP symbols, recent, projects,
--- templates).
---
--- Grep is tuned for finding *which file* holds some content: a few matches
--- per file so a page spans many files, fuzzy one <S-Tab> away from plain,
--- and filename tokens in the query (`init.lua setup`) scoping the search to
--- those files. Matching definitions still lead each page (the default
--- classify_definitions). <C-q> sends the results to quickfix.
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
    grep = {
      -- breadth over depth: 5 hits per file, so a page shows ~20 files
      -- instead of one file's 100 matches
      max_matches_per_file = 5,
      -- <S-Tab> order: typo-tolerant fuzzy right after plain
      modes = { "plain", "fuzzy", "regex", "definition_only" },
      -- `score.rs foo` / `src/main.rs foo` greps foo inside those files only
      enable_filename_constraint = true,
      -- matched lines without their indentation, and `:line` only
      trim_whitespace = true,
      location_format = ":%d",
    },
    -- the preview jumps to the match; numbers place it in the file
    preview = { line_numbers = true },
  },
}
