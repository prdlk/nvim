--- Cloudflare Workers and React/shadcn development tools
--- Includes Workers-specific LSP, React tooling, and UI helpers
--- @module plugins.cloudflare

return {
  -- WASM/WebAssembly support for Workers
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
          "wgsl",
          "wgsl_bevy",
        })
      end
    end,
  },

  -- TOML support for wrangler.toml
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        taplo = {
          settings = {
            evenBetterToml = {
              schema = {
                enabled = true,
                associations = {
                  ["wrangler\\.toml"] = "https://raw.githubusercontent.com/cloudflare/workers-sdk/main/schemas/wrangler.json",
                },
              },
            },
          },
        },
      },
    },
  },

  -- Enhanced search/replace for refactoring React components
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      mapping = {
        ["toggle_line"] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle item",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "open file",
        },
        ["send_to_qf"] = {
          map = "<leader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all items to quickfix",
        },
        ["replace_cmd"] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace command",
        },
        ["show_option_menu"] = {
          map = "<leader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show options",
        },
        ["run_current_replace"] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
        ["run_replace"] = {
          map = "<leader>R",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
      },
    },
  },

  -- React component preview and development
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    event = "VeryLazy",
    opts = {
      color_square_width = 2,
    },
    config = function(_, opts)
      require("tailwindcss-colorizer-cmp").setup(opts)
    end,
  },

  -- Color highlighting for CSS/Tailwind
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "css",
        "scss",
        "html",
        "vue",
        "lua",
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
        always_update = false,
      },
      buftypes = {},
    },
  },

  -- Import cost for monitoring bundle size
  {
    "yardnsm/vim-import-cost",
    build = "npm install --production",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  },

  -- Live browser reload for Workers development
  {
    "Barrett17/browser-sync.nvim",
    build = "npm install -g browser-sync",
    cmd = {
      "BrowserSyncStart",
      "BrowserSyncReload",
      "BrowserSyncStop",
    },
    opts = {},
  },

  -- Component generator for shadcn/ui
  {
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = { "ScissorsAddNewSnippet", "ScissorsEditSnippet" },
    opts = {
      snippetDir = vim.fn.stdpath "config" .. "/snippets",
      editSnippetPopup = {
        height = 0.4,
        width = 0.6,
        border = "rounded",
        keymaps = {
          cancel = "q",
          saveChanges = "<CR>",
          deleteSnippet = "<leader>d",
          duplicateSnippet = "<leader>c",
        },
      },
    },
  },

  -- HTTP client for testing Workers
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    opts = {
      default_view = "body",
      debug = false,
      contenttypes = {
        ["application/json"] = {
          ft = "json",
          formatter = { "jq", "." },
        },
        ["application/xml"] = {
          ft = "xml",
          formatter = { "xmllint", "--format", "-" },
        },
        ["text/html"] = {
          ft = "html",
          formatter = { "xmllint", "--format", "--html", "-" },
        },
      },
    },
  },

  -- Enhanced movement for JSX/TSX
  {
    "echasnovski/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local ai = require "mini.ai"
      return {
        custom_textobjects = {
          -- Function calls
          f = ai.gen_spec.treesitter { a = "@call.outer", i = "@call.inner" },
          -- Function definitions
          F = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
          -- Classes
          c = ai.gen_spec.treesitter { a = "@class.outer", i = "@class.inner" },
          -- Parameters/arguments
          a = ai.gen_spec.treesitter { a = "@parameter.outer", i = "@parameter.inner" },
          -- JSX elements
          x = ai.gen_spec.treesitter {
            a = { "@jsx_element", "@jsx_self_closing_element" },
            i = { "@jsx_element", "@jsx_self_closing_element" },
          },
        },
      }
    end,
  },

  -- React component navigation
  {
    "someone-stole-my-name/yaml-companion.nvim",
    ft = { "yaml" },
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    opts = {},
  },

  -- Worker-specific terminal commands via toggleterm
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    opts = function(_, opts)
      local Terminal = require("toggleterm.terminal").Terminal

      -- Wrangler dev server
      local wrangler_dev = Terminal:new {
        cmd = "bunx wrangler dev",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
        on_open = function(term)
          vim.cmd "startinsert!"
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
      }

      -- Wrangler tail (logs)
      local wrangler_tail = Terminal:new {
        cmd = "bunx wrangler tail",
        hidden = true,
        direction = "horizontal",
        on_open = function(term)
          vim.cmd "startinsert!"
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
      }

      -- Wrangler deploy
      local wrangler_deploy = Terminal:new {
        cmd = "bunx wrangler deploy",
        hidden = true,
        direction = "float",
        close_on_exit = false,
        on_open = function(term)
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
      }

      -- Extend the opts with custom terminals
      opts.on_create = function()
        vim.keymap.set("n", "<leader>wd", function() wrangler_dev:toggle() end, { desc = "Wrangler Dev" })
        vim.keymap.set("n", "<leader>wt", function() wrangler_tail:toggle() end, { desc = "Wrangler Tail" })
        vim.keymap.set("n", "<leader>wp", function() wrangler_deploy:toggle() end, { desc = "Wrangler Deploy" })
      end

      return opts
    end,
  },
}
