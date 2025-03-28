-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
-- Map <C-/> to toggle Aider terminal in all modes
require("telescope").setup {
  pickers = {
    oldfiles = {
      cwd_only = true,
    },
  },
}

require("overseer").setup {
  strategy = {
    "toggleterm",
    use_shell = false,
    size = vim.o.columns * 0.25,
    auto_scroll = true,
    close_on_exit = false,
    quit_on_exit = "success",
    open_on_start = true,
    hidden = true,
  },
}

require("nvim_aider").setup {
  -- Command that executes Aider
  aider_cmd = "aider",
  -- Command line arguments passed to aider
  args = {
    "--no-auto-commits",
    "--pretty",
    "--stream",
    "--dark-mode",  -- Enable dark mode in Aider
  },
  -- Theme colors (dark mode palette)
  theme = {
    -- Dark mode-friendly colors
    user_input_color = "#a6da95",        -- Soft green for user input
    tool_output_color = "#8aadf4",       -- Soft blue for tool output
    tool_error_color = "#ed8796",        -- Soft red for errors
    tool_warning_color = "#eed49f",      -- Soft yellow for warnings
    assistant_output_color = "#c6a0f6",  -- Soft purple for assistant output
    completion_menu_color = "#a5adcb",   -- Slightly dimmer text for completion menu
    completion_menu_bg_color = "#1e1e2e", -- Darker background for completion menu
    completion_menu_current_color = "#89dceb", -- Cyan for selected item
    completion_menu_current_bg_color = "#313244", -- Slightly lighter than bg for selection
  },
  -- snacks.picker.layout.Config configuration
  picker_cfg = {
    preset = "vscode",
    -- Add dark mode settings for picker
    theme = "dark",
  },
  -- Other snacks.terminal.Opts options
  config = {
    os = { editPreset = "nvim-remote" },
    gui = { 
      nerdFontsVersion = "3",
      theme = "dark",  -- Ensure terminal uses dark theme
    },
    term = {
      -- Terminal settings for better dark mode appearance
      defaultBg = "#1e1e2e",  -- Dark background
      defaultFg = "#cdd6f4",  -- Light text color
    },
  },
  win = {
    wo = { 
      winbar = "Aider",
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", -- Ensure proper highlighting
    },
    position = "right",
    width = 0.33,  -- This will make the terminal take up 1/3 of the total window width
    -- Additional window settings for dark mode
    border = "rounded",  -- Rounded borders look nice in dark mode
    style = "minimal",   -- Minimal UI style
  },
  -- Additional dark mode settings
  appearance = {
    dark_mode = true,  -- Explicitly set dark mode
  },
}

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
