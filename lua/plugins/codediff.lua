--- codediff.nvim: VSCode-style diff review workspace (explorer + side-by-side)
--- `:CodeDiff` reviews the working tree; `q` closes the review tab.
--- @module plugins.codediff

---@type LazySpec
return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<C-g><C-d>", "<Cmd>CodeDiff<CR>", desc = "Review changes (CodeDiff)" },
  },
  opts = {},
}
