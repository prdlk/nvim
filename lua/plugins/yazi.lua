--- Yazi as the default file manager (persistent session, full neo-tree
--- replacement). yazi.nvim was removed: it spawns a NEW yazi process on
--- every toggle (only the last-hovered path survives), so tab arrangements
--- were lost and each <C-e> "created a new tab for the workspace". Instead,
--- lua/config/yazi_session.lua keeps ONE yazi process alive in a snacks
--- terminal and <C-e> just hides/shows it — same session, same tabs.
--- File opens come back via ~/.local/bin/yazi-nvim-open -> _G.EditFromYazi
--- (edit / <C-v> vsplit / <C-x> split, bound yazi-side in keymap.toml).
---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        -- fullscreen borderless float for the yazi session terminal
        yazi = {
          position = "float",
          width = 0,
          height = 0,
          border = "none",
          backdrop = false,
        },
      },
    },
  },

  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<C-e>"] = {
            function() require("config.yazi_session").toggle() end,
            desc = "Toggle yazi (persistent session)",
          },
          ["<Leader>-"] = {
            function() require("config.yazi_session").open_current() end,
            desc = "Open yazi at the current file",
          },
          ["<Leader>o"] = {
            function() require("config.yazi_session").open_current() end,
            desc = "Open Explorer (yazi at current file)",
          },
          ["<Leader>cw"] = {
            function() require("config.yazi_session").open(vim.uv.cwd()) end,
            desc = "Open yazi in nvim's working directory",
          },
        },
        v = {
          ["<C-e>"] = {
            function() require("config.yazi_session").toggle() end,
            desc = "Toggle yazi (persistent session)",
          },
        },
        t = {
          ["<C-e>"] = {
            function() require("config.yazi_session").toggle() end,
            desc = "Toggle yazi (persistent session)",
          },
        },
      },
      autocmds = {
        -- netrw is disabled in lazy_setup.lua (performance.rtp.disabled_plugins);
        -- directory buffers (nvim . / :e dir) open in the yazi session instead
        yazi_dir_hijack = {
          {
            event = "BufEnter",
            desc = "Open directory buffers in the yazi session",
            callback = function(args)
              local path = vim.api.nvim_buf_get_name(args.buf)
              if path == "" or vim.fn.isdirectory(path) == 0 then return end
              vim.bo[args.buf].bufhidden = "wipe"
              vim.schedule(function()
                if vim.api.nvim_get_current_buf() == args.buf then vim.cmd.enew() end
                require("config.yazi_session").open(path)
              end)
            end,
          },
        },
      },
    },
  },

  -- neo-tree is fully replaced by the yazi session
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
