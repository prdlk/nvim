--- AstroCore configuration (AstroNvim v6 / Neovim 0.12)
--- Core settings, keymappings, and autocmds
--- @module plugins.astrocore

local ignore_patterns = require "config.ignore_patterns"
local terminals = require "config.terminals"

terminals.setup()

local file_filter = ignore_patterns.create_picker_filter()

-- Open a snacks picker with trouble.nvim send-to-quickfix action bound to <C-t>.
local function with_trouble(source, opts)
  opts = opts or {}
  opts.actions = require("trouble.sources.snacks").actions
  opts.win = opts.win or {}
  opts.win.input = opts.win.input or {}
  opts.win.input.keys = vim.tbl_extend("force", opts.win.input.keys or {}, {
    ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
  })
  require("snacks").picker[source](opts)
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    sessions = {
      autosave = {
        last = true,
        cwd = true,
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
        servers = { "golangci_lint_ls" },
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
      restore_session = {
        {
          event = "VimEnter",
          desc = "Restore previous directory session if neovim opened with no arguments",
          nested = true, -- trigger other autocommands as buffers open
          callback = function()
            if vim.fn.argc(-1) == 0 then
              require("resession").load(
                vim.fn.getcwd(),
                { dir = "dirsession", silence_errors = true }
              )
            end
          end,
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
        laststatus = 0,
      },
      g = {},
    },

    mappings = {
      n = {
        ["<C-!>"] = { "<Cmd>suspend<CR>", desc = "Suspend nvim (return with 'fg')" },
        ["<C-q>Q"] = { "<Cmd>wqa<CR>", desc = "Save all buffers and quit Neovim" },
        ["<C-c>"] = { "<Cmd>wa<CR><Cmd>bd<CR>", desc = "Save and close buffer" },
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
        ["<C-e>"] = { "<Cmd>Neotree toggle reveal<CR>", desc = "Open Explorer (reveal current file)" },
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
          function()
            local current_buffer = vim.api.nvim_get_current_buf()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if buf ~= current_buffer then vim.api.nvim_buf_delete(buf, { force = true }) end
            end
          end,
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
        ["<C-g>o"] = { "<cmd>!gh repo view --web<CR>", desc = "Open Repo on Web" },
        ["<C-s>"] = { "<cmd>w<CR>", desc = "Save buffer" },
        ["<C-w>"] = { "<cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" },
        ["<C-Tab>"] = { "<cmd>tabnext<CR>", desc = "Next Tab" },
        ["<C-d><C-d>"] = { terminals.lazydocker_toggle, desc = "Lazygit Toggle" },
        ["<C-f><C-f>"] = { terminals.yazi_toggle, desc = "Yazi Toggle" },
        ["<C-g><C-g>"] = { terminals.lazygit_toggle, desc = "Lazygit Toggle" },
        ["<C-g><C-i>"] = { "<cmd>Octo issue list<CR>", desc = "List Issues" },
        ["<C-g><C-l>"] = { "<cmd>Octo label<CR>", desc = "Manage Labels" },
        ["<C-g><C-p>"] = { "<cmd>Octo pr list<CR>", desc = "List PRs" },
        ["<C-g>s"] = { "<cmd>Octo search<CR>", desc = "Octo Search" },
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
        ["<C-f>t"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find in line",
        },
        ["<C-f>w"] = {
          function() require("snacks").picker.grep() end,
          desc = "Find word",
        },
        ["<C-f>f"] = {
          function() require("snacks").picker.git_files { transform = file_filter } end,
          desc = "Find files",
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
            require("snacks").picker.files {
              cwd = ai_dir,
              transform = file_filter,
            }
          end,
          desc = "Find AI files",
        },
        ["<C-f>p"] = { desc = "Find Package files" },
        ["<C-f>m"] = { desc = "Find Module files" },
        ["<C-f>g"] = { desc = "Find by Group" },
        ["<C-f>gw"] = {
          function()
            local workflows_dir = vim.fn.getcwd() .. "/.github/workflows"
            if vim.fn.isdirectory(workflows_dir) == 0 then
              vim.notify("No .github/workflows directory found in current project", vim.log.levels.WARN)
              return
            end
            require("snacks").picker.files {
              cwd = workflows_dir,
              transform = file_filter,
            }
          end,
          desc = "Find GitHub Workflow files",
        },
        ["<C-f>gd"] = {
          function()
            require("snacks").picker.files {
              cmd = "fd",
              args = { "devbox.json|process-compose.yaml|Dockerfile|docker-compose.yaml|compose.yaml" },
            }
          end,
          desc = "Find Devbox/Docker files",
        },
        ["<C-f>gm"] = {
          function() require("snacks").picker.files { cmd = "fd", args = { "Makefile" } } end,
          desc = "Find Makefile files",
        },
        ["<C-f>gp"] = {
          function() require("snacks").picker.files { cmd = "fd", args = { "package.json" } } end,
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
        ["<C-j><C-j>"] = { function() terminals.scratch_toggle() end, desc = "Open Scratch Terminal" },
        ["<C-a>f"] = { "<Cmd>ClaudeCodeFocus<CR>", desc = "Toggle Claude Code" },
        ["<C-m>"] = { "<Cmd>OverseerRun<CR>", desc = "Run Overseer task" },
        ["<C-a>d"] = {
          function() with_trouble("diagnostics") end,
          desc = "Search diagnostics (<C-t> sends to Trouble)",
        },
        ["<C-a>a"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "Show code actions",
        },
        ["<C-a>s"] = {
          function() with_trouble("lsp_symbols") end,
          desc = "Search LSP symbols (<C-t> sends to Trouble)",
        },
        ["<C-a>S"] = {
          function() with_trouble("lsp_workspace_symbols") end,
          desc = "Search LSP workspace symbols (<C-t> sends to Trouble)",
        },

        ["<leader>u"] = { desc = "UI Toggles" },
        ["<leader>ud"] = {
          function() require("snacks").toggle.diagnostics():toggle() end,
          desc = "Toggle Diagnostics",
        },
        ["<leader>un"] = {
          function() require("snacks").toggle.line_number():toggle() end,
          desc = "Toggle Line Numbers",
        },
        ["<leader>ur"] = {
          function() require("snacks").toggle.option("relativenumber"):toggle() end,
          desc = "Toggle Relative Numbers",
        },
        ["<leader>uw"] = {
          function() require("snacks").toggle.option("wrap"):toggle() end,
          desc = "Toggle Line Wrap",
        },
        ["<leader>us"] = {
          function() require("snacks").toggle.option("spell"):toggle() end,
          desc = "Toggle Spelling",
        },
        ["<leader>ui"] = {
          function() require("snacks").toggle.inlay_hints():toggle() end,
          desc = "Toggle Inlay Hints",
        },
        ["<leader>ut"] = {
          function() require("snacks").toggle.treesitter():toggle() end,
          desc = "Toggle Treesitter",
        },
        ["<leader>uc"] = {
          function() require("snacks").toggle.option("conceallevel", { off = 0, on = 2 }):toggle() end,
          desc = "Toggle Conceal",
        },
        ["<leader>uI"] = {
          function() require("snacks").toggle.indent():toggle() end,
          desc = "Toggle Indent Guides",
        },
        ["<leader>uz"] = {
          function() require("snacks").toggle.zen():toggle() end,
          desc = "Toggle Zen Mode",
        },
        ["<leader>uZ"] = {
          function() require("snacks").toggle.zoom():toggle() end,
          desc = "Toggle Zoom",
        },
        ["<leader>ua"] = {
          function() require("snacks").toggle.animate():toggle() end,
          desc = "Toggle Animations",
        },
        ["<leader>uS"] = {
          function() require("snacks").toggle.scroll():toggle() end,
          desc = "Toggle Smooth Scroll",
        },
        ["<leader>up"] = {
          function() require("snacks").toggle.profiler():toggle() end,
          desc = "Toggle Profiler",
        },
        ["<leader>uh"] = {
          function() require("snacks").toggle.profiler_highlights():toggle() end,
          desc = "Toggle Profiler Highlights",
        },
        ["<leader>ux"] = {
          function() require("snacks").toggle.dim():toggle() end,
          desc = "Toggle Dim Inactive",
        },
        ["<leader>uf"] = {
          function()
            vim.g.disable_autoformat = not vim.g.disable_autoformat
            local status = vim.g.disable_autoformat and "disabled" or "enabled"
            vim.notify("Format on save " .. status, vim.log.levels.INFO)
          end,
          desc = "Toggle Format on Save",
        },
        -- v6: virtual_lines is native in vim.diagnostic.config, lsp_lines plugin no longer needed
        ["<leader>ul"] = {
          function()
            local cfg = vim.diagnostic.config() or {}
            local enabled = not cfg.virtual_lines
            vim.diagnostic.config { virtual_lines = enabled, virtual_text = not enabled }
          end,
          desc = "Toggle Virtual Lines",
        },
      },
      i = {
        ["<C-s>"] = { "<Cmd>wa<CR><Esc>", desc = "Save buffer, and return to normal mode" },
        ["<C-c>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" },
        ["<C-x>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" },
      },
      v = {
        ["<C-e>"] = { "<Cmd>Neotree toggle reveal<CR>", desc = "Open Explorer (reveal current file)" },
        ["<C-c>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" },
        ["<C-x>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" },
        ["<C-a><C-a>"] = { "<Cmd>ClaudeCodeSend<CR>", desc = "Send selection to Claude Code" },
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
        ["<C-a><C-a>"] = { "<Cmd>ClaudeCodeFocus<CR>", desc = "Toggle Claude Code" },
        ["<C-e>"] = { "<Cmd>Neotree toggle reveal<CR>", desc = "Open Explorer (reveal current file)" },
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
