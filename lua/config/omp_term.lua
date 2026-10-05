--- Single Oh My Pi side terminal, toggled with <C-a><C-a>.
---
--- `Snacks.terminal.toggle` keys terminals by cmd + window-local cwd +
--- v:count1, so toggling from a buffer whose window has another cwd spawns a
--- second omp. Holding the handle here keeps exactly one session; it is
--- recreated only after the omp process exits (auto_close wipes the buffer).
local M = {}

local term ---@type snacks.win?

function M.toggle()
  if term and term:buf_valid() then
    term:toggle()
    return
  end
  term = require("snacks").terminal.open("omp", {
    win = {
      position = "right",
      width = 0.4,
      -- buffer-local, so <C-a> keeps reaching other terminals unchanged
      keys = { omp_hide = { "<C-a><C-a>", "hide", mode = { "n", "t" }, desc = "Hide Oh My Pi" } },
    },
  })
end

return M
