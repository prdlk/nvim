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

-- Overseer setup and template (optional)
local ok_overseer, overseer = pcall(require, "overseer")
if ok_overseer then
  overseer.setup {
    strategy = {
      "toggleterm",
      use_shell = false,
      auto_scroll = true,
      close_on_exit = false,
      direction = "tab",
      quit_on_exit = "success",
      open_on_start = true,
      hidden = true,
    },
  }
end

-- ToggleTerm setup (optional)
local ok_toggleterm, toggleterm = pcall(require, "toggleterm")
if ok_toggleterm then
  toggleterm.setup {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.35)
      else
        return 20
      end
    end,
    shade_terminals = false,
    start_in_insert = true,
  }
end

-- Register Devbox template for Overseer (if available)
if ok_overseer then
  overseer.register_template {
    name = "devbox",
    params = {
      script = {
        type = "string",
        optional = false,
        desc = "The devbox script to run",
      },
    },
    strategy = {
      "toggleterm",
      use_shell = true,
      auto_scroll = true,
      close_on_exit = true,
      direction = "tab",
      quit_on_exit = "success",
      open_on_start = true,
      hidden = true,
    },
    condition = {
      callback = function()
        if vim.fn.executable "git" == 0 then return false, "git not found" end
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 or not git_root or git_root == "" then return false, "Not in a git repository" end
        local devbox_file = git_root .. "/devbox.json"
        if vim.fn.filereadable(devbox_file) == 0 then return false, "No devbox.json found in git root" end
        if vim.fn.executable "devbox" == 0 then return false, "devbox command not found" end
        return true
      end,
    },
    generator = function(_, cb)
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
        cb {}
        return
      end
      local devbox_file = git_root .. "/devbox.json"

      local file = io.open(devbox_file, "r")
      if not file then
        cb {}
        return
      end
      local content = file:read "*all"
      file:close()
      local ok, data = pcall(vim.json.decode, content)
      if not ok or not data then
        cb {}
        return
      end

      local tasks = {}
      if data.shell and data.shell.scripts then
        for script_name, _ in pairs(data.shell.scripts) do
          table.insert(tasks, {
            name = "devbox run " .. script_name,
            builder = function() return { cmd = { "devbox" }, args = { "run", script_name }, cwd = git_root } end,
          })
        end
      end
      table.insert(tasks, {
        name = "devbox shell",
        builder = function() return { cmd = { "devbox" }, args = { "shell" }, cwd = git_root } end,
      })
      cb(tasks)
    end,
  }
end

require("cyberdream").setup {
  variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
  transparent = true,
  italic_comments = true,
  hide_fillchars = true,
  borderless_pickers = true,
  terminal_colors = true,
}
