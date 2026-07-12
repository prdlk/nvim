--- flash.nvim: labeled jumps and enhanced motions
---@type LazySpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        -- normal-mode `f` is the Vimium-style word jump and `F` is the
        -- search-style jump below, so flash's char mode must not rebind
        -- them; t/T/;/, stay enhanced
        keys = { "t", "T", ";", "," },
        -- show jump labels on the char-motion matches (t/T)
        jump_labels = true,
      },
      -- label-enhanced regular `/` and `?` search; <c-s> in cmdline
      -- toggles it off for a plain search
      search = { enabled = true },
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
    {
      "F",
      mode = "n",
      function()
        -- Search-style flash: type a regex pattern and labels appear on
        -- every match. While selecting, `<C-n>`/`<C-b>` cycle to the
        -- next/previous result, <CR> confirms the selection, a label jumps
        -- directly, <Esc> cancels back to the origin. The pattern is pushed
        -- to search history and the `/` register, so `n`/`N` keep working
        -- after the jump.
        local current ---@type Flash.Match?
        require("flash").jump {
          search = { mode = "search" },
          jump = { history = true, register = true, nohlsearch = true },
          actions = {
            ["<c-n>"] = function(state)
              -- first press selects the current target, then cycle forward
              current = current and state:find { match = current, forward = true, wrap = true } or state.target
              if current then state:jump(current) end
            end,
            ["<c-b>"] = function(state)
              current = state:find { match = current or state.target, forward = false, wrap = true }
              if current then state:jump(current) end
            end,
            ["<cr>"] = function(state)
              state:jump(current) -- nil falls back to state.target
              return false -- end the loop
            end,
          },
        }
      end,
      desc = "Flash search",
    },
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
