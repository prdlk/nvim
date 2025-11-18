-- Polish configuration: Final setup and overrides
-- This runs last in the setup process

-- Remove <leader>h mapping (conflicts with Telescope)
vim.api.nvim_del_keymap("n", "<leader>h")

-- Screen session integration: Handle suspend/resume gracefully
local screen_augroup = vim.api.nvim_create_augroup("ScreenIntegration", { clear = true })

-- Before suspension (Screen detach), save all buffers
vim.api.nvim_create_autocmd("VimSuspend", {
  group = screen_augroup,
  callback = function()
    -- Save all modified buffers before suspension
    vim.cmd "silent! wa"
    -- Save session if in a Screen session
    if vim.env.STY ~= nil and vim.env.STY ~= "" then
      local session_name = vim.env.STY:match "[^%.]+%.(.+)"
      vim.notify("Suspending from Screen session: " .. (session_name or vim.env.STY), vim.log.levels.INFO)
    end
  end,
  desc = "Save all buffers before Screen detach/suspension",
})

-- After resume from suspension (Screen reattach)
vim.api.nvim_create_autocmd("VimResume", {
  group = screen_augroup,
  callback = function()
    -- Check for external file changes after resuming
    vim.cmd "checktime"
    if vim.env.STY ~= nil and vim.env.STY ~= "" then
      local session_name = vim.env.STY:match "[^%.]+%.(.+)"
      vim.notify("Resumed in Screen session: " .. (session_name or vim.env.STY), vim.log.levels.INFO)
    end
  end,
  desc = "Check for file changes after Screen reattach/resume",
})



require("cyberdream").setup {
  variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
  transparent = true,
  italic_comments = true,
  hide_fillchars = true,
  borderless_pickers = true,
  terminal_colors = true,
}
