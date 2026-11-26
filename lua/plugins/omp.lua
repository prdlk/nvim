-- omp.nvim: keeps every omp running in nvim's cwd told which file and line
-- (or visual range) is active, live. The nvim half writes `path:line` to the
-- unix socket each omp opens in $XDG_RUNTIME_DIR/omp-nvim-sockets (matched by
-- cwd) on BufEnter / cursor moves; the omp half, the omp.nvim extension
-- (`omp plugin install omp.nvim`), shows it above omp's editor and attaches
-- it as a hidden note to each prompt. The omp pane itself is
-- config.omp_term's (<C-a><C-a>, :OmpContinue), split off in nvim's cwd.
return {
  "rauls-kjarners/omp.nvim",
  event = "VeryLazy",
  config = function() require("omp").setup() end,
}
