--- Neo-tree file explorer (replaces the mini.files explorer)
--- @module plugins.neotree
---
--- This layers on top of AstroNvim's own neo-tree spec instead of replacing it:
--- `opts` takes the table AstroNvim built and only overrides what differs, so
--- `close_if_last_window`, `auto_clean_after_session_restore` (needed by the
--- resession dirsessions), `hijack_netrw_behavior` (`nvim <dir>`), the AstroUI
--- icon set and the `system_open`/`copy_selector`/`parent_or_close` commands
--- all stay in place.
---
--- Filtering comes from two sources:
---   * static globs in `config.ignore_patterns` -> `hide_by_pattern` /
---     `never_show*` (neo-tree compiles globs to Lua patterns in `setup()`)
---   * neo-tree's own gitignore-style `ignore_files` reader for per-repo
---     `.rgignore` files, which replaces the old DirChanged / `set_root`
---     "pattern refresh" hooks. Those injected raw globs *after* setup() had
---     already compiled the list, so they silently matched nothing.

local ignore_patterns = require "config.ignore_patterns"

--- neo-tree rewrites these lists in place at `setup()` time (glob -> Lua
--- pattern), so hand it copies: the shared module keeps serving raw globs to
--- the snacks picker filter in astrocore.lua.
--- @param list string[]
--- @return string[]
local function copy(list) return vim.list_extend({}, list) end

--- Open a hidden snacks terminal running `cmd`.
--- @param cmd string
--- @param opts? table extra snacks.terminal options
local function term(cmd, opts)
  return function()
    require("snacks").terminal(cmd, vim.tbl_extend("force", { hidden = true, interactive = true }, opts or {}))
  end
end

---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      -- kept from the mini.files era; AstroNvim's <Leader>e is overridden by
      -- the git files picker in astrocore.lua, <Leader>o still focuses the tree
      { "<C-e>", "<Cmd>Neotree toggle<CR>", mode = { "n", "v" }, desc = "Toggle Explorer" },
    },
    opts = function(_, opts)
      opts = require("astrocore").extend_tbl(opts, {
        popup_border_style = "rounded",
        enable_diagnostics = true,
        git_status_async = true, -- asynchronous git status, improves performance
        hide_root_node = true,
        retain_hidden_root_indent = true, -- keep the indent so expanders line up
        sort_case_insensitive = false,
        source_selector = { winbar = false, statusline = false },
        window = {
          position = "left",
          width = 32,
          -- window option, not a top level one (it used to be set top level,
          -- where neo-tree ignored it)
          auto_expand_width = false,
          -- keys must be spelled exactly like neo-tree's own defaults:
          -- setup() does not case-normalize them, so `<CR>` would sit next to
          -- the default `<cr>` and whichever `pairs()` reached last would win
          mappings = {
            ["H"] = "navigate_up",
            ["L"] = "set_root",
            ["<bs>"] = "toggle_hidden",
            ["."] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["f"] = "filter_on_submit",
            ["<C-x>"] = "clear_filter",
            ["<cr>"] = "open_and_close_neotree",
            ["<S-CR>"] = "open",
            -- Preview image under cursor via kitty's icat kitten
            ["<leader>p"] = "image_kitty",
            -- Git keybindings, mirroring astrocore.lua
            ["<C-g>o"] = function() vim.cmd "!gh repo view --web" end,
            ["<C-g>h"] = term("gh dash", { auto_close = false }),
            ["<C-g>g"] = function() require("snacks").lazygit() end,
            ["<C-g>d"] = function() require("snacks").picker.git_diff() end,
            ["<C-g>b"] = function() require("snacks").picker.git_branches() end,
            -- Terminals (toggleterm and config.terminals are both gone)
            ["<C-t>l"] = term("lazydocker", { auto_close = true, start_in_insert = true }),
            ["<C-t>."] = term("yazi", { auto_close = true, start_in_insert = true }),
            ["<C-t>t"] = function() require("snacks").terminal() end,
            -- Open yazi in a detached kitty OS window at the node's directory
            ["N"] = function(state)
              local node = state.tree:get_node()
              local path = node.type == "directory" and node.path or vim.fs.dirname(node.path)
              vim.fn.jobstart { "kitty", "--detach", "--directory", path, "yazi" }
            end,
          },
        },
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              -- change type: empty where the name already carries git colors
              added = "",
              modified = "",
              deleted = "✖",
              renamed = "󰁕",
              -- status type
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
          },
          -- extra columns, each only rendered once the window is wide enough
          file_size = { enabled = true, width = 12, required_width = 48 },
          type = { enabled = true, width = 10, required_width = 122 },
          last_modified = { enabled = true, width = 20, required_width = 88 },
          created = { enabled = true, width = 20, required_width = 110 },
          symlink_target = { enabled = false },
        },
        filesystem = {
          commands = {
            -- Close neo-tree after opening a file (directories just expand).
            -- The node has to be read before `open`: afterwards the tree
            -- window may be gone and `tree:get_node()` errors.
            open_and_close_neotree = function(state)
              local node = state.tree:get_node()
              require("neo-tree.sources.filesystem.commands").open(state)
              if node and node.type == "file" then
                require("neo-tree.command").execute { action = "close" }
              end
            end,
            -- Preview an image with kitty's icat kitten in a snacks terminal
            image_kitty = function(state)
              local node = state.tree:get_node()
              if node and node.type == "file" then
                term("kitten icat --hold " .. vim.fn.shellescape(node.path), { auto_close = false })()
              else
                vim.notify("Not a file", vim.log.levels.WARN, { title = "Neo-tree" })
              end
            end,
          },
          bind_to_cwd = true,
          follow_current_file = { enabled = true, leave_dirs_open = false },
          use_libuv_file_watcher = true, -- filesystem option, not a top level one
          filtered_items = {
            force_visible_in_empty_folder = false,
            show_hidden_count = false,
            hide_dotfiles = false,
            hide_gitignored = true,
            -- gitignore-style ignore files, read per directory by neo-tree
            hide_ignored = true,
            ignore_files = { ".neotreeignore", ".ignore", ".rgignore" },
            -- hide_by_pattern / never_show / never_show_by_pattern are seeded
            -- from config.ignore_patterns in `config` below
          },
        },
      })
      -- deep merge of list values is index wise, so AstroNvim's extra sources
      -- survive a `sources = { "filesystem" }` override: assign instead.
      -- (`:checkhealth neo-tree` then reports config.buffers/git_status
      -- `renderers: expected ?, got nil` - stock neo-tree does the same with a
      -- single source, those sections are simply never loaded.)
      opts.sources = { "filesystem" }
      -- git reports ignored paths in a second pass, and neo-tree's own
      -- GIT_STATUS_CHANGED handler only redraws the nodes it already has, so
      -- `!!` entries that land after the first scan stay visible until
      -- something rescans. Rescan once per worktree (the flag also keeps this
      -- from looping on the status the rescan itself kicks off) - this is what
      -- the old BufEnter/DirChanged "refresh patterns" autocmd was papering
      -- over.
      local rescanned = {} ---@type table<string, true>
      table.insert(opts.event_handlers, {
        event = "git_status_changed",
        handler = function(args)
          local root = args and args.git_root
          if root == nil or rescanned[root] then return end
          rescanned[root] = true
          require("neo-tree.sources.manager").refresh "filesystem"
        end,
      })
      return opts
    end,
    config = function(_, opts)
      -- setup() compiles the glob lists into Lua patterns (and turns
      -- `never_show` into a lookup table) in place, so re-seed them from the
      -- shared module on every setup: `:Lazy reload neo-tree.nvim` re-runs
      -- this with the same cached opts table, and compiling already compiled
      -- patterns a second time silently breaks all pattern filtering.
      local filtered = opts.filesystem.filtered_items
      filtered.hide_by_pattern = copy(ignore_patterns.patterns)
      filtered.never_show = copy(ignore_patterns.never_show)
      filtered.never_show_by_pattern = copy(ignore_patterns.never_show_patterns)
      require("neo-tree").setup(opts)
    end,
  },
}
