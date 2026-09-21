--- overseer.nvim: task output in a Snacks bottom window
---
--- The astrocommunity pack (community.lua) owns the plugin spec and the
--- <Leader>M* maps; this layers the `snacks_output` component
--- (lua/overseer/component/snacks_output.lua) onto the default component
--- set so every task shows its terminal buffer in a 24-row window docked at
--- the bottom. <C-m> / Enter runs a task, see plugins/astrocore.lua.
--- @module plugins.overseer

return {
  "stevearc/overseer.nvim",
  ---@type overseer.SetupOpts
  opts = {
    component_aliases = {
      default = {
        "on_exit_set_status",
        "on_complete_notify",
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
        { "snacks_output", height = 24 },
      },
    },
  },
}
