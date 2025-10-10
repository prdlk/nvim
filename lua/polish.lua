-- Polish configuration: Final setup and overrides
-- This runs last in the setup process

-- Remove <leader>h mapping (conflicts with Telescope)
vim.api.nvim_del_keymap("n", "<leader>h")

-- Overseer setup and template (optional)
local ok_overseer, overseer = pcall(require, "overseer")
if ok_overseer then
  overseer.setup {
    strategy = {
      "toggleterm",
      use_shell = false,
      auto_scroll = true,
      close_on_exit = false,
      direction = "vertical",
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

require("inc_rename").setup {
  input_buffer_type = "snacks",
}

require("cyberdream").setup {
  variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
  transparent = true,

  -- Reduce the overall saturation of colours for a more muted look
  saturation = 1, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)

  -- Enable italics comments
  italic_comments = true,

  -- Replace all fillchars with ' ' for the ultimate clean look
  hide_fillchars = true,

  -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
  borderless_pickers = true,

  -- Set terminal colors used in `:terminal`
  terminal_colors = true,

  -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
  cache = true,

  -- Override highlight groups with your own colour values
  highlights = {
    -- Highlight groups to override, adding new groups is also possible
    -- See `:h highlight-groups` for a list of highlight groups or run `:hi` to see all groups and their current values

    -- Example:
    Comment = { fg = "#696969", bg = "NONE", italic = true },

    -- More examples can be found in `lua/cyberdream/extensions/*.lua`
  },

  -- Override a highlight group entirely using the built-in colour palette
  overrides = function(colors) -- NOTE: This function nullifies the `highlights` option
    -- Example:
    return {
      Comment = { fg = colors.green, bg = "NONE", italic = true },
      ["@property"] = { fg = colors.magenta, bold = true },
    }
  end,

  -- Override colors
  colors = {
    -- For a list of colors see `lua/cyberdream/colours.lua`

    -- Override colors for both light and dark variants
    bg = "#000000",
    green = "#00ff00",

    -- If you want to override colors for light or dark variants only, use the following format:
    dark = {
      magenta = "#ff00ff",
      fg = "#eeeeee",
    },
    light = {
      red = "#ff5c57",
      cyan = "#5ef1ff",
    },
  },

  -- Disable or enable colorscheme extensions
  extensions = {
    telescope = true,
    notify = true,
    mini = true,
    snacks = true,
    cmp = true,
    heirline = true,
    ...,
  },
}
