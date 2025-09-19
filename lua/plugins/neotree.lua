-- Function to read patterns from .rgignore file
local function read_rgignore_patterns()
  local patterns = {}
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  if git_root and git_root ~= "" then
    local rgignore_path = git_root .. "/.rgignore"
    local file = io.open(rgignore_path, "r")

    if file then
      for line in file:lines() do
        -- Skip comments and empty lines
        if line ~= "" and not line:match "^#" then
          -- Convert ripgrep patterns to neo-tree patterns
          -- Remove leading ./ if present
          line = line:gsub("^%./", "")
          -- Add the pattern
          table.insert(patterns, line)
        end
      end
      file:close()
    end
  end

  return patterns
end

return {
  {
    "neo-tree.nvim",
    opts = function()
      -- Get patterns from .rgignore
      local rgignore_patterns = read_rgignore_patterns()

      -- Default patterns
      local default_patterns = {
        "chain_*.json",
        "Library",
        ".typecopy",
        ".python-version",
        "*.pb.go",
        "*config.*.js",
        "*config.js",
        "deps.mjs",
        ".parcelrc",
        "worker-configuration.d.ts",
        "wrangler.jsonc",
        "*.pkl.go",
        ".trunk",
        ".config",
        ".cz.toml",
        "*_mock.go",
      }

      -- Merge patterns
      local hide_patterns = vim.list_extend(vim.list_extend({}, default_patterns), rgignore_patterns)

      return {
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = false,
        auto_expand_width = true,
        git_status_async = true, -- Asynchronous git status. Improves performance.
        hide_root_node = true, -- Hide the root node.
        retain_hidden_root_indent = true, -- IF the root node is hidden, keep the indentation anyhow.
        use_libuv_file_watcher = false,
        sort = {
          sorter = "name",
        },
        window = {
          position = "left",
          width = 34,
          mappings = {
            ["H"] = "navigate_up",
            ["L"] = "set_root",
            ["<bs>"] = "toggle_hidden",
            ["."] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["<CR>"] = "open_and_close_neotree",
            ["<S-CR>"] = "open",
            -- Git keybindings from astrocore
            ["<C-g>o"] = function() vim.cmd "!gh repo view --web" end,
            ["<C-g>h"] = function()
              require("snacks").terminal("gh dash", {
                hidden = true,
                auto_close = false,
                interactive = true,
              })
            end,
            ["<C-g>g"] = function()
              require("snacks").terminal("lazygit", {
                hidden = true,
                auto_close = true,
                interactive = true,
              })
            end,
            ["<C-g>d"] = function() require("snacks").picker.git_diff() end,
            ["<C-g>b"] = function() require("snacks").picker.git_branches() end,
            -- Terminal keybindings from astrocore
            ["<C-t>m"] = function() _G.Mk_toggle() end,
            ["<C-t>j"] = function() _G.Lazyjournal_toggle() end,
            ["<C-t>l"] = function()
              require("snacks").terminal("lazydocker", {
                hidden = true,
                auto_close = true,
                start_in_insert = true,
                interactive = true,
              })
            end,
            ["<C-t>du"] = function()
              require("snacks").terminal("devbox services up", {
                hidden = true,
                auto_close = false,
                start_in_insert = true,
                interactive = true,
              })
            end,
            ["<C-t>dd"] = function()
              require("snacks").terminal("devbox services down", {
                hidden = true,
                auto_close = false,
                start_in_insert = true,
                interactive = true,
              })
            end,
            ["<C-t>da"] = function()
              require("snacks").terminal("devbox services attach", {
                hidden = true,
                auto_close = false,
                start_in_insert = true,
                interactive = true,
              })
            end,
            ["<C-t>."] = function() _G.Yazi_toggle() end,
            ["<C-t>t"] = function() require("snacks").terminal() end,
            -- Find keybindings from astrocore
            -- These Find keybindings are defined in astrocore.lua
            -- NeoTree only needs the basic navigation and terminal bindings
            -- Mappings for Mason and formatting
          },
          header = {
            highlight = "NeoTreeHeader",
          },
        },
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          name = {
            trailing_slash = false, -- append a trailing slash to folder names
            use_git_status_colors = true, -- use git status colors instead of the default colors
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              -- Change type
              added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
              modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
              deleted = "✖", -- this can only be used in the git_status source
              renamed = "󰁕", -- this can only be used in the git_status source
              -- Status type
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
          },
          -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
          file_size = {
            enabled = true,
            width = 12, -- width of the column
            required_width = 48, -- min width of window required to show this column
          },
          type = {
            enabled = true,
            width = 10, -- width of the column
            required_width = 122, -- min width of window required to show this column
          },
          last_modified = {
            enabled = true,
            width = 20, -- width of the column
            required_width = 88, -- min width of window required to show this column
          },
          created = {
            enabled = true,
            width = 20, -- width of the column
            required_width = 110, -- min width of window required to show this column
          },
          symlink_target = {
            enabled = false,
          },
        },

        buffers = {
          follow_current_file = {
            enabled = true,
          },
        },

        -- Filesystem specific settings
        filesystem = {
          commands = {
            -- If item is a file it will close neotree after opening it.
            open_and_close_neotree = function(state)
              require("neo-tree.sources.filesystem.commands").open(state)
              local tree = state.tree
              local success, node = pcall(tree.get_node, tree)
              if not success then return end
              if node.type == "file" then require("neo-tree.command").execute { action = "close" } end
            end,

            -- Custom command to open Mason
            mason_open = function() vim.cmd "Mason" end,

            -- Custom command to format a file using the LSP
            format_file = function(state)
              local node = state.tree:get_node()
              if node and node.type == "file" then
                -- Format the file in a temporary buffer without opening it in a window
                local bufnr = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_name(bufnr, node.path)
                vim.api.nvim_buf_load(bufnr)
                vim.lsp.buf.format { bufnr = bufnr, async = false, timeout_ms = 5000 }
                vim.api.nvim_buf_call(bufnr, function() vim.cmd "write" end)
                vim.notify("Formatted " .. vim.fs.basename(node.path), vim.log.levels.INFO, { title = "Neo-tree" })
              else
                vim.notify("Not a file", vim.log.levels.WARN, { title = "Neo-tree" })
              end
            end,
          },
          bind_to_cwd = true,
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          filtered_items = {
            force_visible_in_empty_folder = false,
            group_empty = false,
            show_hidden_count = false,
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_pattern = hide_patterns,
            hide_by_name = {
              -- "contracts",
              -- "crypto",
              -- "CONSTITUTION.md",
              -- "CONTRIBUTING.md",
              -- "api",
              -- "turbo.json",
              -- "OpenCode.md",
              -- "AGENT.md",
              -- "AGENTS.md",
              -- "svgo.config.mjs",
              -- ".prettierrc.cjs",
              -- ".eslintrc.cjs",
              -- "tsconfig.json",
              -- "tsconfig.prod.json",
              -- ".prettierignore",
              -- "CONVENTIONS.md",
              -- ".gitkeep",
              -- ".source",
              -- "settings.json",
              -- ".gitignore",
              -- "analysis_options.yaml",
              -- "slumber.yml",
              -- ".eslintignore",
              -- "CONTRIBUTING.md",
              -- "CHANGELOG.md",
              -- "devbox.d",
              -- "env",
              -- ".husky",
              -- "translations",
              -- "LICENSE.md",
              -- ".envrc",
              -- "CLAUDE.md",
              -- "chains",
              -- "test",
              -- ".golangci.yml",
              -- "go.mod",
              -- "pnpm-workspace.yaml",
              -- "examples",
              -- "bridge",
              -- "client",
            },
            never_show_by_pattern = {
              "*DS_Store",
              ".obsidian",
              ".pkl-lsp",
              ".tsbuildinfo",
              "package-lock.json",
              ".prettierrc",
              "node_modules",
              ".DocumentRevisions-V100",
              ".Spotlight-V100",
              ".TemporaryItems",
              ".Trashes",
              ".fseventsd",
              ".editorconfig",
              "*.min.js",
              "*.lock",
              "*lock*",
              "*.lockb",
              "*.pulsar.go",
              "*.pb.gorm.go",
              "*.pb.gw.go",
              "*_templ.go",
              "*.tmp",
              "*.work.*",
              "*.sum",
              ".parcel-cache",
              "*.icns",
              "*.ico",
              ".aider.tags.cache.v4",
              "*.iml",
              "Icon?",
              "iCloud~",
              "com~",
              "*.icns",
              ".conform*",
              ".null-ls_*",
            },
            never_show = {
              ".git",
              "pnpm-lock.yaml",
              ".next",
              ".task",
              ".devbox",
              ".dart_tool",
              ".idea",
              ".metadata",
              ".venv",
              ".gradle",
              "gradle.bat",
              ".aider.chat.history.md",
              ".aider.input.history",
              ".aider.tags.cache.v3",
              ".devcontainer",
              "heighliner",
              ".tmp",
              "go.work.sum",
              ".DS_Store",
              ".git",
              "LICENSE",
              "tmp",
              "sonr.log",
              "DISCUSSION_TEMPLATE",
              "ISSUE_TEMPLATE",
              ".devbox",
              ".timemachine",
              "junit.xml",
              ".jj",
              ".spawn",
              ".turbo",
            },
          },
        },
        diagnostics = {
          enable = false,
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },

        source_selector = {
          winbar = false,
          statusline = false,
        },

        -- Main sources
        sources = {
          "filesystem",
        },
      }
    end,
  },
}
