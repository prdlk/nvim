-- AI ghost-text completion via NeoCodeium (Windsurf/Codeium). Replaces
-- supermaven. Suggestions render as virtual text only; blink.cmp keeps its
-- own menu (ghost_text stays disabled in AstroNvim's blink spec).
--
-- Disabled in python buffers and under the LeetCode work directory. Both are
-- evaluated by neocodeium on InsertEnter, and `:NeoCodeium enable_buffer`
-- still overrides them per buffer.
local leetcode_dir = vim.fn.expand "~/Developer/github.com/prdlk/leetcode/work/"

local function is_leetcode_buffer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name:sub(1, #leetcode_dir) == leetcode_dir
end

-- Insert-mode keys that act on a visible suggestion and otherwise keep their
-- native meaning (<C-h> backspace, <C-w> delete word).
local function when_visible(action, fallback)
  return function()
    local neocodeium = require "neocodeium"
    if neocodeium.visible() then
      neocodeium[action]()
      return ""
    end
    return fallback
  end
end

return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  cmd = "NeoCodeium",
  opts = {
    log_level = "warn",
    filetypes = { python = false },
    filter = function(bufnr) return not is_leetcode_buffer(bufnr) end,
  },
  keys = {
    { "<C-l>", when_visible("accept", "<C-l>"), mode = "i", expr = true, desc = "Accept AI suggestion" },
    { "<C-w>", when_visible("accept_word", "<C-w>"), mode = "i", expr = true, desc = "Accept AI suggestion word" },
    { "<C-h>", when_visible("clear", "<C-h>"), mode = "i", expr = true, desc = "Clear AI suggestion" },
  },
}
