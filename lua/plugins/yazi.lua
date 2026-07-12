--- Yazi as the default file manager (full neo-tree replacement)
---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    version = "*", -- latest stable release
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi in nvim's working directory",
      },
      {
        -- replaces AstroNvim's <Leader>o "Toggle Explorer Focus" (neo-tree)
        "<leader>o",
        "<cmd>Yazi<cr>",
        desc = "Open Explorer (yazi at current file)",
      },
      {
        "<C-e>",
        mode = { "n", "v", "t" },
        function()
          -- true toggle: if a yazi window is already open, quit it instead
          -- of nesting a second instance (yazi.nvim's toggle() always spawns)
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "yazi" then
              -- send `q` to the yazi process so it exits gracefully and
              -- saves its state for the next resume
              vim.api.nvim_chan_send(vim.bo[buf].channel, "q")
              return
            end
          end
          vim.cmd "Yazi toggle"
        end,
        desc = "Toggle yazi (resume last session)",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- yazi replaces netrw/neo-tree when opening directories (nvim .)
      open_for_directories = true,
      -- open visible splits as yazi tabs for fast navigation
      open_multiple_tabs = true,
      -- occupy the whole screen instead of a floating popup
      floating_window_scaling_factor = 1,
      yazi_floating_window_border = "none",
      keymaps = {
        show_help = "<f1>",
        -- Open the hovered/selected file(s) as nvim splits. These are
        -- buffer-local terminal-mode keymaps on the yazi buffer, so nvim
        -- intercepts the chord before the yazi process ever sees it --
        -- nothing is needed in ~/.config/yazi/keymap.toml. Chords match
        -- the telescope/snacks picker convention (<c-v>/<c-x>/<c-t>).
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        -- NOTE: the default <c-t> (open in tab) shadows the yazi-side
        -- <C-t> "plugin tv" bind from keymap.toml while inside nvim;
        -- set open_file_in_tab = false to let <C-t> reach yazi/tv instead
        open_file_in_tab = "<c-t>",
        -- ~/.config/yazi/keymap.toml binds <C-q> to quit inside yazi;
        -- don't hijack it for the quickfix list (multi-select still goes
        -- to the quickfix list via the default yazi_opened_multiple_files)
        send_to_quickfix_list = false,
      },
      integrations = {
        -- <c-y> copy-relative-path action inside snacks pickers too
        picker_add_copy_relative_path_action = "snacks.picker",
      },
    },
    init = function()
      -- netrw is fully replaced by yazi (open_for_directories)
      vim.g.loaded_netrwPlugin = 1
    end,
  },

  -- neo-tree is fully replaced by yazi.nvim
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
