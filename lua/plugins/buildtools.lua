--- Build tools and development environment optimizations
--- Includes support for bun, vite, and modern JS tooling
--- @module plugins.buildtools

---@type LazySpec
return {
  -- Vim support for various config files
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
          "toml",
          "yaml",
          "json",
          "jsonc",
        })
      end
    end,
  },

  -- Enhanced JSON support with schema validation
  {
    "b0o/schemastore.nvim",
    lazy = true,
    dependencies = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          ---@diagnostic disable: missing-fields
          config = {
            jsonls = {
              on_new_config = function(config)
                if not config.settings.json then config.settings.json = {} end
                if not config.settings.json.schemas then config.settings.json.schemas = {} end
                vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
              end,
              settings = {
                json = {
                  format = { enable = true },
                  validate = { enable = true },
                },
              },
            },
          },
        },
      },
    },
  },

  -- YAML schema support
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        yamlls = {
          on_new_config = function(config)
            config.settings.yaml.schemas =
              vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
          end,
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
            },
          },
        },
      },
    },
  },

  -- Task runner integration (for vite, bun scripts)
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerOpen",
      "OverseerClose",
      "OverseerLoadBundle",
      "OverseerSaveBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerQuickAction",
      "OverseerTaskAction",
    },
    opts = {
      strategy = {
        "toggleterm",
        use_shell = false,
        auto_scroll = true,
        close_on_exit = false,
        direction = "tab",
        quit_on_exit = "success",
        open_on_start = true,
        hidden = true,
      },
      templates = {
        "builtin",
        "bun.run",
        "npm.run",
        "vite.dev",
        "vite.build",
      },
      task_list = {
        bindings = {
          ["<C-l>"] = false,
          ["<C-h>"] = false,
          ["<C-k>"] = false,
          ["<C-j>"] = false,
        },
      },
    },
    config = function(_, opts)
      local overseer = require "overseer"
      overseer.setup(opts)

      -- Custom task templates for bun
      overseer.register_template {
        name = "bun.run",
        builder = function(params)
          return {
            cmd = { "bun" },
            args = { "run", params.script },
            name = "bun run " .. params.script,
            components = { "default" },
          }
        end,
        params = {
          script = {
            type = "string",
            default = "dev",
            description = "Script to run from package.json",
          },
        },
        condition = {
          filetype = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        },
      }

      -- Custom task templates for vite
      overseer.register_template {
        name = "vite.dev",
        builder = function()
          return {
            cmd = { "bun" },
            args = { "run", "dev" },
            name = "vite dev server",
            components = {
              { "on_output_quickfix", open = false },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable "vite.config.ts" == 1 or vim.fn.filereadable "vite.config.js" == 1
          end,
        },
      }

      overseer.register_template {
        name = "vite.build",
        builder = function()
          return {
            cmd = { "bun" },
            args = { "run", "build" },
            name = "vite build",
            components = {
              { "on_output_quickfix", open = true },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable "vite.config.ts" == 1 or vim.fn.filereadable "vite.config.js" == 1
          end,
        },
      }

      -- Register Devbox template for Overseer
      overseer.register_template {
        name = "devbox",
        params = {
          script = {
            type = "string",
            optional = false,
            desc = "The devbox script to run",
          },
        },
        strategy = {
          "toggleterm",
          use_shell = true,
          auto_scroll = true,
          close_on_exit = true,
          direction = "tab",
          quit_on_exit = "success",
          open_on_start = true,
          hidden = true,
        },
        condition = {
          callback = function()
            if vim.fn.executable "git" == 0 then return false, "git not found" end
            local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
            if vim.v.shell_error ~= 0 or not git_root or git_root == "" then return false, "Not in a git repository" end
            local devbox_file = git_root .. "/devbox.json"
            if vim.fn.filereadable(devbox_file) == 0 then return false, "No devbox.json found in git root" end
            if vim.fn.executable "devbox" == 0 then return false, "devbox command not found" end
            return true
          end,
        },
        generator = function(_, cb)
          local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
          if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
            cb {}
            return
          end
          local devbox_file = git_root .. "/devbox.json"

          local file = io.open(devbox_file, "r")
          if not file then
            cb {}
            return
          end
          local content = file:read "*all"
          file:close()
          local ok, data = pcall(vim.json.decode, content)
          if not ok or not data then
            cb {}
            return
          end

          local tasks = {}
          if data.shell and data.shell.scripts then
            for script_name, _ in pairs(data.shell.scripts) do
              table.insert(tasks, {
                name = "devbox run " .. script_name,
                builder = function() return { cmd = { "devbox" }, args = { "run", script_name }, cwd = git_root } end,
              })
            end
          end
          table.insert(tasks, {
            name = "devbox shell",
            builder = function() return { cmd = { "devbox" }, args = { "shell" }, cwd = git_root } end,
          })
          cb(tasks)
        end,
      }
    end,
  },
  -- Seamless navigation between build errors
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = {
      use_diagnostic_signs = true,
      action_keys = {
        close = "q",
        cancel = "<esc>",
        refresh = "r",
        jump = { "<cr>", "<tab>" },
        open_split = { "<c-x>" },
        open_vsplit = { "<c-v>" },
        open_tab = { "<c-t>" },
        jump_close = { "o" },
        toggle_mode = "m",
        toggle_preview = "P",
        hover = "K",
        preview = "p",
        close_folds = { "zM", "zm" },
        open_folds = { "zR", "zr" },
        toggle_fold = { "zA", "za" },
        previous = "k",
        next = "j",
      },
    },
  },

  { "wakatime/vim-wakatime", lazy = false },
  -- Git integration for collaborative development
  {
    "lewis6991/gitsigns.nvim",
    event = "User AstroGitFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
      },
    },
  },

  -- EditorConfig support
  {
    "editorconfig/editorconfig-vim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- Development container support
  {
    "esensar/nvim-dev-container",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = {
      "DevcontainerStart",
      "DevcontainerAttach",
      "DevcontainerExec",
      "DevcontainerStop",
      "DevcontainerLogs",
    },
    opts = {},
  },
}
