--- External TUIs without a dedicated snacks.nvim integration (nvim-external-tui).
--- Tools that DO have a native snacks path (lazygit -> Snacks.lazygit,
--- lazydocker -> Snacks.terminal) are wired directly in astrocore.lua.
---@type LazySpec
return {
  "gfontenot/nvim-external-tui",
  dependencies = { "folke/snacks.nvim" },
  event = "VeryLazy",
  config = function()
    local external_tui = require "external-tui"

    external_tui.setup {
      -- the `scooter` win style (snacks opts.styles in user.lua) renders the
      -- terminal as a borderless right-hand 30% split
      terminal_provider = {
        snacks = { win = { style = "scooter" } },
      },
    }

    -- :Scooter — find & replace TUI; picking a result closes the terminal
    -- and opens the file at that line in this nvim instance. Visual range
    -- (:'<,'>Scooter) and args (:Scooter term) prefill the search text.
    external_tui.add {
      user_cmd = "Scooter",
      cmd = "scooter",
      text_flag = "--search-text",
      editor_flag = "--editor-command", -- scooter >= 0.8.4
    }
  end,
}
