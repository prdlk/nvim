--- Shared snacks.picker helpers.
--- @module config.picker

local M = {}

--- Open a snacks picker with trouble.nvim's send-to-list action bound to <C-t>,
--- so a picker result set can be promoted to a persistent Trouble list.
--- @param source string snacks.picker source name (e.g. "diagnostics")
--- @param opts? snacks.picker.Config extra picker options
function M.with_trouble(source, opts)
  opts = opts or {}
  opts.actions = require("trouble.sources.snacks").actions
  opts.win = opts.win or {}
  opts.win.input = opts.win.input or {}
  opts.win.input.keys = vim.tbl_extend("force", opts.win.input.keys or {}, {
    ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
  })
  require("snacks").picker[source](opts)
end

return M
