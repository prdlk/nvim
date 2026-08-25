--- AstroCore configuration (AstroNvim v6 / Neovim 0.12)
--- Core settings, keymappings, and autocmds
--- @module plugins.astrocore

local ignore_patterns = require "config.ignore_patterns"

local file_filter = ignore_patterns.create_picker_filter()

-- <C-f>e: two-stage find-by-extension. Stage 1 scans the repo with fd
-- (respects .gitignore) and shows every file extension ranked by count;
-- stage 2 opens fff prefilled with a `*.<ext> ` glob constraint so the
-- rest of the query fuzzy-matches within that extension.
local function find_files_by_extension()
  local snacks = require "snacks"
  local root = snacks.git.get_root() or vim.uv.cwd()
  local files = vim.fn.systemlist { "fd", "--type", "f", "--base-directory", root }
  if vim.v.shell_error ~= 0 then
    vim.notify("fd failed to list files in " .. root, vim.log.levels.ERROR)
    return
  end
  local counts = {}
  for _, path in ipairs(files) do
    -- last dot of the basename; skips dotfiles (.gitignore) and bare names
    local ext = path:match "[^/]%.([%w_%-]+)$"
    if ext then counts[ext] = (counts[ext] or 0) + 1 end
  end
  local items = {}
  for ext, count in pairs(counts) do
    items[#items + 1] = { text = ext, ext = ext, count = count }
  end
  if #items == 0 then
    vim.notify("No file extensions found in " .. root, vim.log.levels.WARN)
    return
  end
  table.sort(items, function(a, b)
    if a.count ~= b.count then return a.count > b.count end
    return a.ext < b.ext
  end)
  snacks.picker {
    title = "File Extensions",
    layout = { preset = "select" },
    items = items,
    format = function(item)
      return {
        { ("%-12s"):format(item.ext), "SnacksPickerLabel" },
        { ("%d file%s"):format(item.count, item.count == 1 and "" or "s"), "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      require("fff").find_files { cwd = root, title = "*." .. item.ext .. " files", query = "*." .. item.ext .. " " }
    end,
  }
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    sessions = {
      -- cwd autosave is handled by the git_branch_sessions autocmd below so
      -- the session name carries the worktree/branch, see config.session
      autosave = {
        last = true,
        cwd = false,
      },
      ignore = {
        dirs = {},
        filetypes = { "gitcommit", "gitrebase" },
        buftypes = {},
      },
    },

    rooter = {
      detector = {
        "lsp",
        { ".git", "_darcs", ".hg", ".bzr", ".svn" },
        {
          "package.json",
          "lua",
          "Cargo.toml",
          "Pipfile",
          "docs.json",
        },
      },
      ignore = {
        -- golangci_lint_ls roots at the nearest go.mod, not the repo
        -- dev-tools attaches with an empty root_dir which rooter treats as "/"
        servers = { "golangci_lint_ls", "dev-tools" },
        dirs = {},
      },
      autochdir = true,
      scope = "global",
      notify = false,
    },

    -- v6: features schema changed
    -- diagnostics_mode (0-3) -> diagnostics = { virtual_text, virtual_lines }
    -- large_buf and cmp are new keys
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = false, virtual_lines = false },
      highlighturl = true,
      notifications = false,
    },

    -- vim.diagnostic.config() values applied when diagnostics are toggled on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },

    autocmds = {
      custom_title = {
        {
          event = { "BufEnter", "DirChanged" },
          desc = "Update terminal title with org/repo format",
          callback = function()
            local filepath = vim.fn.expand "%:p"
            local filename = vim.fn.expand "%:t"

            if filename == "" then
              local cwd = vim.fn.getcwd()
              local github_match = cwd:match "github%.com/([^/]+/[^/]+)"
              if github_match then
                vim.opt.titlestring = github_match
              else
                vim.opt.titlestring = "Nvim"
              end
              return
            end

            local github_match = filepath:match "github%.com/([^/]+/[^/]+)"

            if github_match then
              vim.opt.titlestring = string.format("%s | %s", filename, github_match)
            else
              vim.opt.titlestring = string.format("%s | Nvim", filename)
            end
          end,
        },
      },
      git_branch_sessions = {
        {
          event = "VimLeavePre",
          desc = "Save the worktree/branch directory session on close",
          callback = vim.schedule_wrap(function()
            if require("astrocore.buffer").is_valid_session() then
              require("config.session").save { notify = false }
            end
          end),
        },
        {
          event = "VimEnter",
          desc = "Restore worktree/branch session, else open the git files picker",
          nested = true, -- trigger other autocommands as buffers open
          -- no-op when nvim was started with file arguments, see config.session
          callback = function() require("config.session").restore() end,
        },
      },
    },

    options = {
      opt = {
        relativenumber = false,
        number = true,
        spell = false,
        wrap = true,
        clipboard = "unnamedplus",
        title = true,
        titlestring = "",
        laststatus = 3, -- global statusline (custom heirline in heirline.lua)
      },
      g = {},
    },

    mappings = {
      n = {
        -- overrides AstroNvim's default <C-q> = force quit (:q!)
        ["<C-q>"] = { "<Cmd>wqa<CR>", desc = "Save all buffers and quit Neovim" },
        ["<C-!>"] = { "<Cmd>suspend<CR>", desc = "Suspend nvim (return with 'fg')" },
        ["ZZ"] = { "<Cmd>wqa<CR>", desc = "Save all buffers and quit Neovim" },
        ["<A-q>"] = { "<Cmd>wqa<CR>", desc = "Save all buffers and quit Neovim" },
        ["<C-c>"] = {
          function()
            vim.cmd "wa"
            require("snacks").bufdelete()
          end,
          desc = "Save and close buffer",
        },
        ["F"] = { "za", desc = "Toggle fold under cursor" },
        -- v6: vim.diagnostic.goto_next/goto_prev deprecated in 0.11, use jump()
        ["J"] = {
          function() vim.diagnostic.jump { count = 1, float = true } end,
          desc = "Next diagnostic",
        },
        ["K"] = {
          function() vim.diagnostic.jump { count = -1, float = true } end,
          desc = "Previous diagnostic",
        },
        ["L"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
        ["H"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
        ["<Leader>e"] = {
          function() require("snacks").picker.git_files { transform = file_filter } end,
          desc = "Find git files",
        },
        -- AstroNvim's dirsession maps key off the bare cwd; use the
        -- worktree/branch-aware name instead
        ["<Leader>SS"] = {
          function() require("config.session").save() end,
          desc = "Save this dirsession",
        },
        ["<Leader>S."] = {
          function() require("config.session").load() end,
          desc = "Load current dirsession",
        },
        ["<leader><leader>"] = {
          function() require("snacks").picker.smart() end,
          desc = "Find files",
        },
        ["<C-b>b"] = { "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
        ["<C-b>f"] = {
          function() require("snacks").picker.buffers() end,
          desc = "Find buffers",
        },
        ["<C-b><C-c>"] = {
          function() require("snacks").bufdelete.other() end,
          desc = "Close all buffers except the current one",
        },
        ["<C-b>g"] = {
          function()
            local groups = { "DEX", "DID", "DWN", "SVC", "Tests", "Actions", "Claude", "Docs", "Config" }
            for _, group in ipairs(groups) do
              vim.cmd("BufferLineGroupToggle " .. group)
            end
          end,
          desc = "Toggle all buffer groups",
        },
        ["<C-b>l"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find in line",
        },
        ["<C-g>o"] = { function() require("snacks").gitbrowse() end, desc = "Open Repo on Web" },
        ["<C-s>"] = { "<cmd>w<CR>", desc = "Save buffer" },
        ["<C-w>"] = {
          function()
            vim.cmd "w"
            require("snacks").bufdelete()
          end,
          desc = "Save and close buffer",
        },
        ["<C-Tab>"] = { "<cmd>tabnext<CR>", desc = "Next Tab" },
        ["<C-g><C-i>"] = {
          function() require("snacks").picker.gh_issue() end,
          desc = "GitHub issues (open)",
        },
        ["<C-g>I"] = {
          function() require("snacks").picker.gh_issue { state = "all" } end,
          desc = "GitHub issues (all)",
        },
        ["<C-g><C-p>"] = {
          function() require("snacks").picker.gh_pr() end,
          desc = "GitHub PRs (open)",
        },
        ["<C-g>P"] = {
          function() require("snacks").picker.gh_pr { state = "all" } end,
          desc = "GitHub PRs (all)",
        },
        ["<C-g><C-g>"] = {
          function() require("snacks").lazygit() end,
          desc = "Toggle lazygit (float)",
        },
        ["<C-d><C-d>"] = {
          function() require("snacks").terminal.toggle("lazydocker", { win = { style = "float" } }) end,
          desc = "Toggle lazydocker (float)",
        },
        -- grug-far.nvim: buffer-based find & replace (plugins/grug-far.lua).
        -- `open` reads the visual selection itself, so the same callback
        -- serves both modes.
        ["<C-r>"] = { function() require("grug-far").open() end, desc = "Find & replace (grug-far)" },
        -- which-key prefix group labels
        ["<C-g>"] = { desc = "Git + GitHub" },
        ["<C-f>"] = { desc = "Find" },
        ["<C-b>"] = { desc = "Buffers" },
        ["<C-a>"] = { desc = "Assist" },
        -- ghq project switcher
        ["<C-f>P"] = {
          function()
            local repos = vim.fn.systemlist "ghq list -p"
            vim.ui.select(repos, { prompt = "Select repository" }, function(dir)
              if not dir then return end
              vim.cmd.cd(dir)
              require("snacks").picker.files()
            end)
          end,
          desc = "Find ghq projects",
        },
        ["<C-g><C-r>"] = { "<cmd>!gh release list<CR>", desc = "List Releases" },
        ["<C-g>d"] = {
          function() require("snacks").picker.git_diff() end,
          desc = "Search git diffs",
        },
        ["<C-g><C-b>"] = {
          function() require("snacks").picker.git_branches() end,
          desc = "Search git branches",
        },
        ["vv"] = { "gg0VG$", desc = "Select all contents in buffer" },
        ["T"] = { "gg", desc = "Go to top of file" },
        ["<C-f>d"] = {
          function() require("snacks").picker.diagnostics() end,
          desc = "Find diagnostics",
        },
        ["<C-f>l"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find in line",
        },
        -- NOTE: <C-i> and <Tab> are the same key at the mapping level, so
        -- this also shadows <Tab> (jumplist-forward) in normal mode
        ["<C-i>"] = {
          function() require("config.templates").pick() end,
          desc = "Find templates",
        },
        ["<C-f>w"] = {
          function() require("fff").live_grep() end,
          desc = "Live grep",
        },
        ["<C-f>z"] = {
          function() require("fff").live_grep { grep = { modes = { "fuzzy", "plain" } } } end,
          desc = "Live fuzzy grep",
        },
        ["<C-f><C-w>"] = {
          function() require("fff").live_grep_under_cursor() end,
          desc = "Grep word under cursor",
        },
        ["<C-f>f"] = {
          function() require("fff").find_files() end,
          desc = "Find files (cwd)",
        },
        ["<C-f>m"] = {
          function() require("fff").find_files { title = "Git Modified", query = "git:modified " } end,
          desc = "Find git-modified files",
        },
        ["<C-f>r"] = {
          function() require("fff").resume() end,
          desc = "Resume last find/grep",
        },
        ["<C-f>."] = {
          function() require("fff").find_files_in_dir(vim.fn.expand "%:p:h") end,
          desc = "Find files in buffer directory",
        },
        ["<C-f>e"] = {
          find_files_by_extension,
          desc = "Find files by extension",
        },
        ["<C-f>o"] = {
          function() require("snacks").picker.recent() end,
          desc = "Find recent files",
        },
        ["<C-f>p"] = {
          function() require("snacks").picker.projects() end,
          desc = "Find projects",
        },
        ["<C-f>gc"] = {
          function()
            local ai_dir = vim.fn.getcwd() .. "/.ai"
            if vim.fn.isdirectory(ai_dir) == 0 then
              vim.notify("No .ai directory found in current project", vim.log.levels.WARN)
              return
            end
            require("fff").find_files_in_dir(ai_dir)
          end,
          desc = "Find AI files",
        },
        ["<C-f>g"] = { desc = "Find by Group" },
        ["<C-f>gw"] = {
          function()
            local workflows_dir = vim.fn.getcwd() .. "/.github/workflows"
            if vim.fn.isdirectory(workflows_dir) == 0 then
              vim.notify("No .github/workflows directory found in current project", vim.log.levels.WARN)
              return
            end
            require("fff").find_files_in_dir(workflows_dir)
          end,
          desc = "Find GitHub Workflow files",
        },
        ["<C-f>gd"] = {
          function()
            require("fff").find_files {
              title = "Devbox/Docker files",
              query = "{devbox.json,process-compose.yaml,Dockerfile,docker-compose.yaml,compose.yaml} ",
            }
          end,
          desc = "Find Devbox/Docker files",
        },
        ["<C-f>gm"] = {
          function() require("fff").find_files { title = "Makefiles", query = "*Makefile* " } end,
          desc = "Find Makefile files",
        },
        ["<C-f>gp"] = {
          function() require("fff").find_files { title = "package.json files", query = "*package.json " } end,
          desc = "Find Package.json files",
        },
        ["<C-p>"] = {
          function()
            if vim.b.toggle_number == 99 then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "t", false)
              return
            end
            local content = vim.fn.getreg "+"
            vim.api.nvim_paste(content, true, -1)
          end,
          desc = "Paste from system clipboard",
        },
        -- LSP-scoped assist binds (<C-a>a/s/S) are capability-gated in
        -- plugins/astrolsp.lua; diagnostics exist without a server, so this
        -- one stays global
        ["<C-a>d"] = {
          function() require("config.picker").with_trouble "diagnostics" end,
          desc = "Search diagnostics (<C-t> sends to Trouble)",
        },
        ["<C-a><C-s>"] = { "<Cmd>SupermavenToggle<CR>", desc = "Toggle Supermaven" },

        -- <Leader>u toggles are mapped through Snacks.toggle in
        -- config.toggles (called from polish.lua) so which-key renders their
        -- enabled/disabled state
        ["<leader>u"] = { desc = "UI Toggles" },
      },
      i = {
        ["<C-s>"] = { "<Cmd>wa<CR><Esc>", desc = "Save buffer, and return to normal mode" },
        ["<C-c>"] = {
          function()
            vim.cmd "stopinsert"
            vim.cmd "wa"
            require("snacks").bufdelete()
          end,
          desc = "Save, close buffer, and return to normal mode",
        },
        ["<C-x>"] = {
          function()
            vim.cmd "stopinsert"
            vim.cmd "wa"
            require("snacks").bufdelete()
          end,
          desc = "Save, close buffer, and return to normal mode",
        },
      },
      v = {
        ["<C-c>"] = {
          function()
            vim.cmd "w"
            require("snacks").bufdelete()
          end,
          desc = "Save and close buffer",
        },
        ["<C-x>"] = {
          function()
            vim.cmd "w"
            require("snacks").bufdelete()
          end,
          desc = "Save and close buffer",
        },
        ["<C-f><C-w>"] = {
          function() require("fff").live_grep_under_cursor() end,
          desc = "Grep selection",
        },
        -- charwise (v) selection prefills the search input, linewise (V)
        -- limits search & replace to the selected range (visualSelectionUsage
        -- = "auto-detect" in plugins/grug-far.lua)
        ["<C-r>"] = {
          function() require("grug-far").open() end,
          desc = "Find & replace selection (grug-far)",
        },
        ["D"] = {
          function()
            vim.cmd 'normal! "vy'
            local selection = vim.fn.getreg "v"
            local escaped = vim.fn.escape(selection, [[/\.*$^~[]])
            vim.cmd(string.format([[%%s/%s//ge]], escaped))
            vim.notify(string.format("Deleted all occurrences of: %s", selection), vim.log.levels.INFO)
          end,
          desc = "Delete all occurrences of selected text",
        },
        ["R"] = {
          function()
            vim.cmd 'normal! "vy'
            local selection = vim.fn.getreg "v"
            local escaped = vim.fn.escape(selection, [[/\.*$^~[]])
            require("snacks").input({
              prompt = string.format("Replace '%s' with:", selection),
              default = "",
            }, function(replacement)
              if replacement then
                local escaped_replacement = vim.fn.escape(replacement, [[/\&~]])
                vim.cmd(string.format([[%%s/%s/%s/ge]], escaped, escaped_replacement))
                vim.notify(string.format("Replaced '%s' with '%s'", selection, replacement), vim.log.levels.INFO)
              end
            end)
          end,
          desc = "Replace all occurrences of selected text",
        },
      },
      t = {
        ["<C-p>"] = { function() vim.cmd 'normal! "+p' end, desc = "Paste from system clipboard" },
        ["<C-b>f"] = {
          function() require("snacks").picker.buffers() end,
          desc = "Find buffers",
        },
        ["<C-q>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
            vim.cmd "close"
          end,
          desc = "Exit terminal and close window",
        },
      },
    },
  },
}
