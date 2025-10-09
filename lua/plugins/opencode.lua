return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `toggle()`.
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }

    -- Required for `vim.g.opencode_opts.auto_reload`
    vim.opt.autoread = true

    -- Recommended/example keymaps
    vim.keymap.set(
      { "n", "x" },
      "<C-o>a",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask about this" }
    )
    vim.keymap.set({ "n", "x" }, "<C-o>@", function() require("opencode").prompt "@this" end, { desc = "Add this" })
    vim.keymap.set({ "n", "x" }, "<C-o>s", function() require("opencode").select() end, { desc = "Select prompt" })
    vim.keymap.set("n", "<C-o>t", function() require("opencode").toggle() end, { desc = "Toggle embedded" })
    vim.keymap.set("n", "<C-o>n", function() require("opencode").command "session_new" end, { desc = "New session" })
    vim.keymap.set(
      "n",
      "<C-o>i",
      function() require("opencode").command "session_interrupt" end,
      { desc = "Interrupt session" }
    )
    vim.keymap.set(
      "n",
      "U",
      function() require("opencode").command "messages_half_page_up" end,
      { desc = "Messages half page up" }
    )
    vim.keymap.set(
      "n",
      "D",
      function() require("opencode").command "messages_half_page_down" end,
      { desc = "Messages half page down" }
    )
  end,
}
