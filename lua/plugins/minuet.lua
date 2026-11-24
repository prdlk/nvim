-- minuet-ai.nvim: ghost-text completion and next-edit prediction; provider
-- chain, keys, and gating in config.minuet. Loads before the first buffer's
-- FileType so its per-filetype auto-trigger flags reach that buffer too.
return {
  "milanglacier/minuet-ai.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function() require("config.minuet").setup() end,
}
