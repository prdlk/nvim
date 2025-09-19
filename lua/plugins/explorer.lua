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

-- Build exclude patterns for snacks.explorer
local function build_exclude_patterns()
  -- Get patterns from .rgignore
  local rgignore_patterns = read_rgignore_patterns()

  -- Default hide patterns (from original neotree config)
  local hide_patterns = {
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

  -- Never show by pattern (from original neotree config)
  local never_show_by_pattern = {
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
  }

  -- Never show directories (from original neotree config)
  local never_show = {
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
  }

  -- Merge all patterns
  local all_patterns = {}

  -- Add default hide patterns
  for _, pattern in ipairs(hide_patterns) do
    table.insert(all_patterns, pattern)
  end

  -- Add rgignore patterns
  for _, pattern in ipairs(rgignore_patterns) do
    table.insert(all_patterns, pattern)
  end

  -- Add never show by pattern
  for _, pattern in ipairs(never_show_by_pattern) do
    table.insert(all_patterns, pattern)
  end

  -- Add never show directories
  for _, pattern in ipairs(never_show) do
    table.insert(all_patterns, pattern)
  end

  return all_patterns
end

-- Custom transform function to filter items
local function create_transform_filter()
  local exclude_patterns = build_exclude_patterns()

  return function(item, ctx)
    if not item then return false end

    local name = item.name or (item.file and vim.fn.fnamemodify(item.file, ":t")) or ""
    local path = item.file or ""

    -- Check each pattern
    for _, pattern in ipairs(exclude_patterns) do
      -- Convert glob pattern to Lua pattern
      local lua_pattern = pattern
        :gsub("([%.%+%-%[%]%(%)%$%^%%%?])", "%%%1") -- Escape special chars except *
        :gsub("%*%*", ".*") -- ** matches any characters including /
        :gsub("%*", "[^/]*") -- * matches any characters except /
        :gsub("%?", ".") -- ? matches single character

      -- Check against filename
      if name:match("^" .. lua_pattern .. "$") then
        return false -- Filter out this item
      end

      -- Check against full path
      if path:match("/" .. lua_pattern .. "$") or path:match("/" .. lua_pattern .. "/") then
        return false -- Filter out this item
      end
    end

    return item -- Keep the item
  end
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = function()
      return {
        -- Enable explorer and replace netrw
        explorer = {
          replace_netrw = true,
        },
        -- Dashboard configuration
        dashboard = {
          preset = {
            header = table.concat({
              "",
              "",
              "                ████████                ",
              "             ██████████████             ",
              "           ████████████████             ",
              "         ██████████  █████              ",
              "       ██████████               █       ",
              "     ██████████               █████     ",
              "    █████████               █████████   ",
              "  █████████       ████       █████████  ",
              " ████████       ████████       ████████ ",
              "███████       ████████████       ███████",
              "███████      ██████████████       ██████",
              "███████       ████████████       ███████",
              " ████████       ████████       ████████ ",
              "  █████████       ████       █████████  ",
              "    ████████               ██████████   ",
              "     ██████              ██████████     ",
              "       ██               █████████       ",
              "               ████  ██████████         ",
              "             ████████████████           ",
              "             ██████████████             ",
              "                ████████                ",
              "",
              "",
            }, "\n"),
          },
          sections = {
            { section = "header" },
            {
              pane = 2,
              section = "terminal",
              cmd = "colorscript -e square",
              height = 5,
              padding = 1,
            },
            { section = "keys", gap = 1, padding = 1 },
            {
              pane = 2,
              icon = " ",
              desc = "Browse Repo",
              padding = 1,
              key = "b",
              action = function() require("snacks").gitbrowse() end,
            },
            function()
              local in_git = require("snacks").git.get_root() ~= nil
              local cmds = {
                {
                  title = "Notifications",
                  cmd = "gh notify -s -a -n5",
                  action = function() vim.ui.open "https://github.com/notifications" end,
                  key = "n",
                  icon = " ",
                  height = 5,
                  enabled = true,
                },
                {
                  title = "Open Issues",
                  cmd = "gh issue list -L 3",
                  key = "i",
                  action = function() vim.fn.jobstart("gh issue list --web", { detach = true }) end,
                  icon = " ",
                  height = 7,
                },
                {
                  icon = " ",
                  title = "Open PRs",
                  cmd = "gh pr list -L 3",
                  key = "P",
                  action = function() vim.fn.jobstart("gh pr list --web", { detach = true }) end,
                  height = 7,
                },
                {
                  icon = " ",
                  title = "Git Status",
                  cmd = "git --no-pager diff --stat -B -M -C",
                  height = 10,
                },
              }
              return vim.tbl_map(
                function(cmd)
                  return vim.tbl_extend("force", {
                    pane = 2,
                    section = "terminal",
                    enabled = in_git,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                  }, cmd)
                end,
                cmds
              )
            end,
            { section = "startup" },
          },
        },
        -- Configure the explorer picker source
        picker = {
          sources = {
            explorer = {
              -- Explorer configuration matching neotree
              tree = true,
              hidden = true, -- Show hidden files by default (. files)
              ignored = false, -- Don't show gitignored files
              follow_file = true,
              git_status = true,
              git_untracked = true,
              diagnostics = true,
              watch = true,
              -- Use transform to filter out unwanted files/directories
              transform = create_transform_filter(),
              focus = "list",
              auto_close = false,
              jump = { close = true }, -- Close explorer when jumping to a file
              layout = {
                preset = "sidebar",
                preview = false,
                layout = {
                  width = 34,
                },
              },
              formatters = {
                file = { filename_only = true },
              },
              matcher = { sort_empty = false, fuzzy = false },
              win = {
                list = {
                  keys = {
                    -- Navigation (matching neotree)
                    ["H"] = "explorer_up", -- Navigate to parent directory
                    ["L"] = "explorer_focus", -- Open file/expand directory (with auto-close for files)
                    ["<CR>"] = "confirm", -- Open file/expand directory (with auto-close for files)
                    ["<S-CR>"] = "confirm", -- Open without closing
                    ["<BS>"] = "explorer_close_all", -- Collapse all folders
                    ["!"] = "toggle_ignored", -- Toggle ignored files
                    ["."] = "toggle_hidden", -- Toggle hidden files
                    ["/"] = function(self)
                      -- Focus search input
                      self:focus "input"
                    end,
                    ["f"] = function(self)
                      -- Focus search input (filter)
                      self:focus "input"
                    end,
                    ["<c-x>"] = function(self)
                      -- Clear filter
                      self.input:set ""
                    end,
                    ["s"] = "edit_vsplit", -- Open in vertical split
                    ["S"] = "edit_split", -- Open in horizontal split
                    ["t"] = "tab", -- Open in new tab

                    -- File operations
                    ["a"] = "explorer_add", -- Add file
                    ["d"] = "explorer_del", -- Delete
                    ["r"] = "explorer_rename", -- Rename
                    ["y"] = "explorer_yank", -- Copy
                    ["x"] = "explorer_move", -- Cut/Move
                    ["p"] = "explorer_paste", -- Paste
                    ["c"] = "explorer_yank", -- Copy to clipboard
                    ["R"] = "explorer_update", -- Refresh
                    -- Git keybindings from neotree
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
                    -- Terminal keybindings from neotree
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
                    -- Additional navigation
                    ["h"] = "explorer_close", -- Close directory
                    ["l"] = "confirm", -- Open/expand
                    ["o"] = "explorer_open", -- Open with system application
                    ["P"] = "toggle_preview",
                    ["I"] = "toggle_ignored",
                    ["Z"] = "explorer_close_all",
                    ["]g"] = "explorer_git_next",
                    ["[g"] = "explorer_git_prev",
                    ["]d"] = "explorer_diagnostic_next",
                    ["[d"] = "explorer_diagnostic_prev",
                  },
                },
              },
            },
          },
        },
      }
    end,
  },
}
