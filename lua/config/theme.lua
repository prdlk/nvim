-- Colorscheme follows the desktop's light/dark mode: koda-light under a light
-- theme (Omarchy's Hazy Peak), cyberdream under a dark one.
--
-- On Omarchy the mode comes from the active theme's colors.toml, read before
-- the first colorscheme loads so there is no dark flash. Elsewhere it is
-- 'background' as Neovim detects it from the terminal. Afterwards every change
-- of 'background' swaps the colorscheme: Omarchy's theme-set hook pushes
-- `set background=light|dark` into each running nvim, so a theme switch
-- recolours open editors too. Shared with the treemux sidebar
-- (~/.config/tmux/treemux_init.lua), which has this lua/ dir on package.path.

local M = {}

M.schemes = { light = "koda-light", dark = "cyberdream" }

--- koda.nvim setup: seat koda-light on Hazy Peak's #cccccc fog (koda's own
--- light background is #faf9f5) and keep the line numbers, cursor line and
--- comments readable on it.
M.koda_opts = {
  colors = {
    light = {
      bg = "#cccccc",
      line = "#bdbdbd",
      dim = "#9a9a9a",
      comment = "#7a7a7a",
    },
  },
}

local colors_toml = vim.fn.expand "~/.local/state/omarchy/current/theme/colors.toml"

--- The active Omarchy theme's `mode`, or nil off Omarchy (or for a theme
--- without the key).
---@return "light"|"dark"|nil
function M.omarchy_mode()
  local file = io.open(colors_toml)
  if not file then return nil end
  for line in file:lines() do
    local mode = line:match '^%s*mode%s*=%s*["\'](%a+)["\']'
    if mode == "light" or mode == "dark" then
      file:close()
      return mode
    end
  end
  file:close()
  return nil
end

--- Set 'background' from Omarchy (when available), install the swap, and
--- return the colorscheme to load first.
---@return string
function M.init()
  local mode = M.omarchy_mode()
  if mode then vim.o.background = mode end

  vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("config_theme", { clear = true }),
    pattern = "background",
    -- nested: `:colorscheme` must fire ColorSchemePre (lazy.nvim loads koda
    -- on it) and ColorScheme (heirline, bufferline re-derive their colours)
    nested = true,
    desc = "Swap the colorscheme with the light/dark mode",
    callback = function()
      local want = M.schemes[vim.v.option_new]
      if want and vim.g.colors_name ~= want then vim.cmd.colorscheme(want) end
    end,
  })

  return M.schemes[vim.o.background] or M.schemes.dark
end

return M
