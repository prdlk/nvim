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
        "<cmd>Yazi toggle<cr>",
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
