--- Telescope configuration with Doodle integration
--- Extends telescope.nvim with doodle extension
--- @module plugins.telescope

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "apdot/doodle",
  },
  opts = function(_, opts)
    -- Ensure extensions table exists
    opts.extensions = opts.extensions or {}

    -- Add doodle extension configuration
    opts.extensions.doodle = {}

    return opts
  end,
  config = function(_, opts)
    local telescope = require "telescope"

    -- Setup telescope with options
    telescope.setup(opts)

    -- Load the doodle extension
    telescope.load_extension "doodle"
  end,
}
