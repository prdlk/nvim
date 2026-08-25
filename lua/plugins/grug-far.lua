--- grug-far.nvim: buffer-based find & replace, backing the <C-r> binds in
--- plugins/astrocore.lua. Replaces the scooter TUI (nvim-external-tui, gone).
--- Buffer-local actions hang off <localleader> (`,`): `,r` replace,
--- `,s` sync all lines, `,l` sync line, `,q` quickfix, `,c` close, `g?` help.
--- @module plugins.grug-far

return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  opts = {
    -- ripgrep only: no ast-grep binary on this machine, so keep the
    -- astgrep engines out of the Swap Engine (`,e`) cycle
    enabledEngines = { "ripgrep" },

    -- right-hand split, matching where scooter used to open
    windowCreationCommand = "botright vsplit",

    -- linewise selection (V) limits search/replace to that range,
    -- charwise selection (v) prefills the search input instead
    visualSelectionUsage = "auto-detect",
  },
}
