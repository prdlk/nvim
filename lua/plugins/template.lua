--- template.nvim: insert file templates with {{_expr_}} grammar
--- Templates live in <config>/templates/<ft>/*.ext and are matched to the
--- buffer by filetype. Picker frontend lives in config.templates (<C-f>t).
--- @module plugins.template

return {
  "nvimdev/template.nvim",
  cmd = "Template",
  opts = {
    temp_dir = vim.fn.stdpath "config" .. "/templates",
    author = "Prad Nukala",
    email = "prad@sonr.io",
  },
}
