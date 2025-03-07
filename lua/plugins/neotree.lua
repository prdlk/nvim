return {
  {
    "neo-tree.nvim",
    opts = {
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sort_case_insensitive = false,
      auto_expand_width = true,
      git_status_async = true, -- Asynchronous git status. Improves performance.
      hide_root_node = true, -- Hide the root node.
      retain_hidden_root_indent = false, -- IF the root node is hidden, keep the indentation anyhow.
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 1,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          expander_collapsed = "",
          expander_expanded = "",
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
            modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "✖", -- this can only be used in the git_status source
            renamed = "󰁕", -- this can only be used in the git_status source
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
        -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
        file_size = {
          enabled = true,
          width = 12, -- width of the column
          required_width = 64, -- min width of window required to show this column
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
      -- Simplified default component configs
      window = {
        mappings = {
          ["<bs>"] = "navigate_up",
          [">"] = "set_root",
          ["."] = "toggle_hidden",
          ["/"] = "fuzzy_finder",
          ["f"] = "filter_on_submit",
          ["<c-x>"] = "clear_filter",
          ["<CR>"] = "open_and_close_neotree",
          ["<S-CR>"] = "open",
        },
        header = {
          highlight = "NeoTreeHeader",
        },
      },

      buffers = {
        follow_current_file = true,
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
        },
        bind_to_cwd = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          force_visible_in_empty_folder = true,
          group_empty = true,
          show_hidden_count = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_pattern = {
            "dist",
            ".python-version",
            "*_test.go",
            "*.pb.go",
            "*_templ.go",
            "buf.gen.*",
            "mprocs.*",
            "*config.*.js",
            "*config.js",
            "deps.mjs",
            "test_*.go",
            ".trunk",
          },
          hide_by_name = {
            ".github",
            ".taskfiles",
            "types",
            ".gitignore",
            "analysis_options.yaml",
            "decorators",
            "slumber.yml",
            "CHANGELOG.md",
            "devbox.d",
            "package-lock.json",
            ".husky",
            "translations",
            "test",
            "networks",
            "go.mod",
            "LICENSE.md",
            "CONTRIBUTING.md",
          },
          never_show_by_pattern = {
            "PULL_REQUEST_TEMPLATE.md",
            ".trunk",
            ".editorconfig",
            ".eslint*",
            "*.min.js",
            ".gitpod.*",
            "cspell.*",
            "*.lock",
            "*.lockb",
            "*.pulsar.go",
            "*.pb.gorm.go",
            "*.pb.gw.go",
            "*_templ.go",
            "*.tmp",
            "*.work.*",
            "*.sum",
            ".wrangler",
            "*.wasm",
            "*.png",
            "*.min.js",
            "*.jpg",
            "*.icns",
            "*.ico",
            "build",
            "PklProject.deps.json",
            "*.iml",
          },
          never_show = {
            ".dart_tool",
            ".idea",
            ".metadata",
            ".venv",
            "zkp",
            "ted25519",
            "dkg",
            "ecies",
            "ot",
            "paillier",
            "sharing",
            "signatures",
            "subtle",
            "bulletproof",
            "dkg",
            "daed",
            ".gradle",
            "gradle.bat",
            ".aider.chat.history.md",
            ".aider.input.history",
            ".aider.tags.cache.v3",
            ".devcontainer",
            "heighliner",
            ".tmp",
            ".zed",
            ".vscode",
            "go.work.sum",
            ".DS_Store",
            ".git",
            "LICENSE",
            "interchaintest",
            ".envrc",
            "tmp",
            "sonr.log",
            "DISCUSSION_TEMPLATE",
            "ISSUE_TEMPLATE",
          },
        },
      },

      diagnostics = {
        enable = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },

      source_selector = {
        winbar = false,
        statusline = false,
      },

      -- Main sources
      sources = {
        "filesystem",
        "diagnostics",
      },
    },
  },
}
