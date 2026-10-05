-- omp.nvim: streams the active file / cursor line / visual selection to a
-- running Oh My Pi session over a unix socket. Needs the OMP-side extension
-- (`omp plugin install omp.nvim`). Toggle bind: <C-a><C-a> in astrocore.lua.
return {
  "rauls-kjarners/omp.nvim",
  event = "VeryLazy",
  config = function() require("omp").setup() end,
}
