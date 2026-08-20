-- Disable supermaven in buffers under the LeetCode work directory, and
-- re-enable it when leaving them.
--
-- Note: supermaven's built-in `condition` option is one-way — its BufEnter
-- listener gates the restart branch on `vim.g.SUPERMAVEN_DISABLED`, which
-- `api.stop()` itself sets, so once auto-stopped it never comes back. This
-- autocmd owns both directions instead. `vim.g.supermaven_leetcode_stopped`
-- distinguishes our auto-stop from a manual :SupermavenStop, which stays off.
local leetcode_dir = vim.fn.expand "~/Developer/github.com/prdlk/leetcode/work/"

local function is_leetcode_buffer()
  local name = vim.api.nvim_buf_get_name(0)
  return name:sub(1, #leetcode_dir) == leetcode_dir
end

local function sync()
  local api = require "supermaven-nvim.api"
  if is_leetcode_buffer() then
    if api.is_running() then
      api.stop()
      vim.g.supermaven_leetcode_stopped = true
    end
  elseif vim.g.supermaven_leetcode_stopped and not api.is_running() then
    vim.g.supermaven_leetcode_stopped = nil
    api.start()
  end
end

return {
  "supermaven-inc/supermaven-nvim",
  optional = true,
  config = function(_, opts)
    require("supermaven-nvim").setup(opts)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("supermaven_leetcode", { clear = true }),
      desc = "Toggle supermaven off in LeetCode solution buffers",
      callback = sync,
    })
    sync() -- plugin loads on VeryLazy; cover the buffer we're already sitting in
  end,
}
