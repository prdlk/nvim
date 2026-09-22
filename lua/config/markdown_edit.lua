--- Visual-mode markdown formatting for the `<Leader>e` group in markdown/mdx
--- buffers: wrap the selection in inline markers (italic, bold, code, link)
--- or rewrite its lines as a list / fenced code block.
---
--- Inline ops work on the exact charwise selection, or on the whole lines of
--- a linewise one. Line ops always act on whole lines, whichever way the
--- selection was made. Blockwise selections are refused.
---
--- Mapped buffer-locally from plugins/markdown-edit.lua.
--- @module config.markdown_edit

local M = {}

local ESC = vim.keycode "<Esc>"

--- Leave visual mode and return the selection as a 0-based, end-exclusive
--- `nvim_buf_set_text` rectangle.
--- @return integer? srow, integer scol, integer erow, integer ecol
local function selection()
  -- `'<`/`'>` are only set once visual mode ends. `:normal!` rather than
  -- feedkeys(..., "x"): the latter also flushes any typed-ahead keys, which
  -- would run before the insert mode some of the binds end in.
  vim.cmd.normal { ESC, bang = true }
  local mode = vim.fn.visualmode()
  local s, e = vim.fn.getpos "'<", vim.fn.getpos "'>"
  local srow, erow = s[2] - 1, e[2] - 1
  if mode == "V" then
    local last = vim.api.nvim_buf_get_lines(0, erow, erow + 1, true)[1]
    return srow, 0, erow, #last
  elseif mode == "v" then
    -- getregionpos clamps a `$` end column (v:maxcol) to the line length and
    -- moves the inclusive end onto the last byte of a multibyte character
    local pos = vim.fn.getregionpos(s, e, { type = mode })
    return srow, pos[1][1][3] - 1, erow, pos[#pos][2][3]
  end
  vim.notify("Blockwise selections are not supported", vim.log.levels.WARN)
end

--- Insert `before` at the start and `after` at the end of the selection.
--- @param before string
--- @param after string
--- @return integer? row, integer? col 0-based position of `after`
local function wrap(before, after)
  local srow, scol, erow, ecol = selection()
  if not srow then return end
  -- suffix first so the start position stays valid
  vim.api.nvim_buf_set_text(0, erow, ecol, erow, ecol, { after })
  vim.api.nvim_buf_set_text(0, srow, scol, srow, scol, { before })
  if srow == erow then ecol = ecol + #before end
  return erow, ecol
end

--- `[text](|)` with insert mode started at the cursor
local function link()
  local row, col = wrap("[", "]()")
  if not row then return end
  vim.api.nvim_win_set_cursor(0, { row + 1, col + 2 })
  vim.cmd "startinsert"
end

--- Prefix every non-blank selected line, after its indentation, with
--- `marker(n)` for the n-th such line. Blank lines separate items and are
--- left alone.
--- @param marker fun(n: integer): string
local function list(marker)
  local srow, _, erow = selection()
  if not srow then return end
  local lines = vim.api.nvim_buf_get_lines(0, srow, erow + 1, true)
  local n = 0
  for i, line in ipairs(lines) do
    if line:find "%S" then
      n = n + 1
      local indent = line:match "^%s*"
      lines[i] = indent .. marker(n) .. line:sub(#indent + 1)
    end
  end
  vim.api.nvim_buf_set_lines(0, srow, erow + 1, true, lines)
end

--- Fence the selected lines, indented like the first one, with insert mode
--- started after the opening ``` for the language
local function code_block()
  local srow, _, erow = selection()
  if not srow then return end
  local fence = vim.api.nvim_buf_get_lines(0, srow, srow + 1, true)[1]:match "^%s*" .. "```"
  vim.api.nvim_buf_set_lines(0, erow + 1, erow + 1, true, { fence })
  vim.api.nvim_buf_set_lines(0, srow, srow, true, { fence })
  vim.api.nvim_win_set_cursor(0, { srow + 1, 0 })
  vim.cmd "startinsert!"
end

--- @type table<string, table<string, AstroCoreMapping>>
M.mappings = {
  x = {
    ["<Leader>e"] = { desc = "Markdown" },
    ["<Leader>ei"] = { function() wrap("*", "*") end, desc = "Italic" },
    ["<Leader>eb"] = { function() wrap("**", "**") end, desc = "Bold" },
    ["<Leader>ec"] = { function() wrap("`", "`") end, desc = "Inline code" },
    ["<Leader>ex"] = { link, desc = "Link" },
    ["<Leader>el"] = {
      function()
        list(function() return "- " end)
      end,
      desc = "Unordered list",
    },
    ["<Leader>eL"] = {
      function()
        list(function(n) return n .. ". " end)
      end,
      desc = "Ordered list",
    },
    ["<Leader>eC"] = { code_block, desc = "Code block" },
  },
}

return M
