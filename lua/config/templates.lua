--- Snacks picker frontend for template.nvim (<C-f>t).
---
--- <CR>: insert the template at the cursor when the current buffer is a
--- named file whose filetype matches the template's; otherwise fall through
--- to the new-file flow. <C-n>: always prompt (snacks.input) for a new file
--- to create in the cwd and fill with the template.
---
--- template.nvim resolves templates by filetype + basename-without-extension
--- using Lua-pattern substring matching, so template file names must use
--- underscores only and never be substrings of one another.
--- @module config.templates

local M = {}

local function temp_dir() return vim.fs.normalize(require("template").temp_dir) end

local function tpl_name(item) return vim.fn.fnamemodify(item.file, ":t:r") end

--- Insert the template at the cursor of the current buffer.
local function insert(item) require("template"):generate_template { tpl_name(item) } end

--- Prompt for a filename, create it under cwd, and fill it with the template.
local function create(item)
  local ext = vim.fn.fnamemodify(item.file, ":e")
  require("snacks").input({
    prompt = ("New .%s file (created in %s)"):format(ext, vim.fn.fnamemodify(vim.fn.getcwd(), ":~")),
  }, function(value)
    if not value or value == "" then return end
    -- template.nvim detects the file argument by its extension
    if not value:find("%.%w+$") then value = value .. "." .. ext end
    -- template.nvim opens the file with bare uv.fs_open; make parents first
    local parent = vim.fn.fnamemodify(vim.fn.getcwd() .. "/" .. value, ":h")
    if vim.fn.isdirectory(parent) == 0 then vim.fn.mkdir(parent, "p") end
    require("template"):generate_template { value, tpl_name(item) }
  end)
end

--- Open the template picker.
function M.pick()
  require "template" -- lazy-loads the plugin so temp_dir is configured
  require("snacks").picker.files {
    title = "Templates",
    cwd = temp_dir(),
    actions = {
      template_new_file = function(picker, item)
        picker:close()
        if item then vim.schedule(function() create(item) end) end
      end,
    },
    win = {
      input = {
        keys = { ["<c-n>"] = { "template_new_file", mode = { "n", "i" } } },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      -- defer past the picker teardown so the target window is current again
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        local named = vim.api.nvim_buf_get_name(buf) ~= "" and vim.bo[buf].buftype == ""
        local tpl_ft = vim.filetype.match { filename = vim.fs.joinpath(temp_dir(), item.file) }
        -- template.nvim silently no-ops on filetype mismatch, so route
        -- non-matching buffers to the new-file flow instead
        if named and vim.bo[buf].filetype == tpl_ft then
          insert(item)
        else
          create(item)
        end
      end)
    end,
  }
end

return M
