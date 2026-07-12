--- flash.nvim: labeled jumps and enhanced motions
---@type LazySpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        -- normal-mode `f` is the Vimium-style word jump below, so flash's
        -- char mode must not rebind it; F/t/T/;/, stay enhanced
        keys = { "F", "t", "T", ";", "," },
      },
    },
  },
  keys = {
    {
      "f",
      mode = "n",
      function()
        -- Vimium-c style: label every visible word start immediately,
        -- press a label to jump (no search pattern typed)
        require("flash").jump {
          search = { mode = "search", max_length = 0 },
          label = { after = false, before = { 0, 0 } },
          pattern = [[\<]],
        }
      end,
      desc = "Jump to word (Vimium-style)",
    },
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
