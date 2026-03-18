return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "astromars",
      -- add new user interface icon
      icons = {
        VimIcon = "",
        ScrollText = "",
        GitBranch = "",
        GitAdd = "",
        GitChange = "",
        GitDelete = "",
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = {
      statusline = false,
    },
  },
}
