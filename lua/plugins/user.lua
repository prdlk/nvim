-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  "andweeb/presence.nvim",
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<C-g>", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<C-f>",
        function() require("rip-substitute").sub() end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },
  -- disable neo-tree
  {
    "goolord/alpha-nvim",
    enabled = true,
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        "       ▗▄████▄▖       ",
        "      ▟███▛███▛▘      ",
        "    ▄███▜▝  ▘▀   ▗    ",
        "  ▗▟██▜▞▘       ▟██▖  ",
        " ▟██▛█▘   ▄▙▖  ▝▜█▜█▙ ",
        "▟██▜▀   ▄████▄   ▀██▟▙",
        "██▟▌   ▐████▟█▜   ▐▟██",
        "▜▛██▄   ▀▜▟█▛▀   ▄██▛▛",
        " ▜█▛█▙▖  ▝▀▌▘  ▗▟█▟▙▛ ",
        "  ▝▜█▛▘       ▟██▟█▘  ",
        "    ▘   ▄▄  ▄███▟▀    ",
        "      ▗▟▜▛██▜█▜▞▘     ",
        "       ▝▀████▀▘       ",
      }
      return opts
    end,
  },

  -- Add SchemaStore.nvim to your plugin
  {
    "b0o/SchemaStore.nvim",
  },
}
