--- tv.nvim: television channels in a floating terminal
--- <C-t> picks from the file/editor cable channels in the dotfiles
--- (~/.config/television/cable) only. Their cable `enter` actions would spawn
--- an editor inside the float, so each gets Neovim-side handlers: tv.nvim
--- passes handler keys as `--expect`, which wins over cable keybindings.
--- `:Tv <channel>` still reaches any channel.
--- @module plugins.tv

local OPEN = { "files", "git-files", "recent-files", "dotfiles", "git-diff" }
local GREP = { "text", "todo-comments" }

---@type LazySpec
return {
  "alexpasmantier/tv.nvim",
  cmd = "Tv",
  keys = {
    {
      "<C-t>",
      function()
        vim.ui.select(vim.list_extend(vim.list_extend({}, OPEN), GREP), { prompt = "Television" }, function(choice)
          if choice then require("tv").tv_channel(choice) end
        end)
      end,
      desc = "Television file channels",
    },
  },
  config = function()
    local h = require("tv").handlers
    local channels = {}
    -- no <C-s>/<C-x>: tv uses them for cycle_sources / the action picker
    for _, name in ipairs(OPEN) do
      channels[name] = {
        handlers = { ["<CR>"] = h.open_as_files, ["<C-q>"] = h.send_to_quickfix, ["<C-v>"] = h.open_in_vsplit },
      }
    end
    for _, name in ipairs(GREP) do
      channels[name] = { handlers = { ["<CR>"] = h.open_at_line, ["<C-q>"] = h.send_to_quickfix } }
    end

    require("tv").setup {
      global_keybindings = { channels = false }, -- <C-t> lives in `keys` above
      channels = channels,
    }
  end,
}
