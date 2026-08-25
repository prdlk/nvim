-- This will run last in the setup process.
-- Pure lua; anything that doesn't fit the normal config locations goes here.

-- <Leader>u UI toggles, mapped via Snacks.toggle so which-key shows the
-- snacks state icons/colors (see config.toggles). LSP-scoped keymaps live in
-- plugins/astrolsp.lua, where astrolsp gates them on server capabilities.
require("config.toggles").setup()
