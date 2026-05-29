-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
--
--


local overseer = require "overseer"

overseer.setup {
  strategy = {
    "toggleterm",
    use_shell = false,
    direction = "horizontal",
    size = function() return math.floor(vim.o.lines * 0.2) end,
    auto_scroll = true,
    close_on_exit = false,
    quit_on_exit = "success",
    open_on_start = true,
    hidden = true,
  },
  -- Persistent tasks: keep completed runs around until the user disposes them.
  component_aliases = {
    default = {
      "on_exit_set_status",
      "on_complete_notify",
    },
  },
}

local task_list = require "overseer.task_list"

vim.api.nvim_create_user_command("OverseerRestartLast", function()
  local tasks = overseer.list_tasks {
    status = { overseer.STATUS.SUCCESS, overseer.STATUS.FAILURE, overseer.STATUS.CANCELED },
    sort = task_list.sort_finished_recently,
  }
  if vim.tbl_isempty(tasks) then
    vim.notify("No completed tasks to restart", vim.log.levels.WARN)
    return
  end
  overseer.run_action(tasks[1], "restart")
end, { desc = "Restart the most recently completed Overseer task" })

vim.cmd.cnoreabbrev "OS OverseerShell"
