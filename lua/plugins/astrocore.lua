--- AstroCore configuration
--- Core settings, keymappings, and autocmds for AstroNvim
--- @module plugins.astrocore

-- Import shared modules
local ignore_patterns = require "config.ignore_patterns"
local terminals = require "config.terminals"

-- Initialize terminals
terminals.setup()

-- Get file filter for pickers
local file_filter = ignore_patterns.create_picker_filter()

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {

    sessions = {
      -- Configure auto saving
      autosave = {
        last = true, -- auto save last session
        cwd = true, -- auto save session for each working directory
      },
      -- Patterns to ignore when saving sessions
      ignore = {
        dirs = {}, -- working directories to ignore sessions in
        filetypes = { "gitcommit", "gitrebase" }, -- filetypes to ignore sessions
        buftypes = {}, -- buffer types to ignore sessions
      },
      -- Store pinned buffers in session data
      before_save = function()
        local pinned = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname ~= "" then
              -- Check if buffer is pinned using BufferLine's API
              local ok, bufferline = pcall(require, "bufferline")
              if ok and bufferline.get_elements then
                local elements = bufferline.get_elements()
                for _, element in ipairs(elements) do
                  if element.id == buf and element.pinned then
                    table.insert(pinned, bufname)
                    break
                  end
                end
              end
            end
          end
        end
        vim.g.session_pinned_buffers = pinned
      end,
      -- Restore pinned buffers after session load
      after_load = function()
        if vim.g.session_pinned_buffers then
          vim.defer_fn(function()
            for _, bufname in ipairs(vim.g.session_pinned_buffers) do
              -- Find the buffer by name
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == bufname then
                  -- Pin the buffer using BufferLine command
                  vim.cmd("BufferLineTogglePin " .. buf)
                  break
                end
              end
            end
            vim.g.session_pinned_buffers = nil
          end, 100)
        end
      end,
    },
    rooter = {
      -- list of detectors in order of prevalence, elements can be:
      --   "lsp" : lsp detection
      --   string[] : a list of directory patterns to look for
      --   fun(bufnr: integer): string|string[] : a function that takes a buffer number and outputs detected roots
      detector = {
        "lsp", -- highest priority is getting workspace from running language servers
        { ".git", "_darcs", ".hg", ".bzr", ".svn" }, -- next check for a version controlled parent directory
        {
          "package.json",
          "lua",
          "Cargo.toml",
          "Pipfile",
          "docs.json",
        }, -- lastly check for a file named `main`
      },
      -- ignore things from root detection
      ignore = {
        servers = {
          "golangci_lint_ls",
        }, -- list of language server names to ignore (Ex. { "efm" })
        dirs = {}, -- list of directory patterns (Ex. { "~/.cargo/*" })
      },
      -- automatically update working directory (update manually with `:AstroRoot`)
      autochdir = true,
      -- scope of working directory to change ("global"|"tab"|"win")
      scope = "win", -- Changed from "win" to "global" to make directory changes apply globally
      -- show notification on every working directory change
      notify = false,
    },

    -- Configure core features of AstroNvim
    features = {
      autopairs = true, -- enable autopairs at start
      diagnostics_mode = 1, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = false, -- enable notifications at start
    },

    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },

    -- Autocmds can be configured here
    autocmds = {
      -- Custom title formatting for ghq repos
      custom_title = {
        {
          event = { "BufEnter", "DirChanged" },
          desc = "Update terminal title with org/repo format",
          callback = function()
            local filepath = vim.fn.expand "%:p"
            local filename = vim.fn.expand "%:t"

            -- If no file is open, try to show just the repo name
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

            -- Check if path contains github.com (ghq structure)
            local github_match = filepath:match "github%.com/([^/]+/[^/]+)"

            if github_match then
              -- Format: filename | org/repo
              vim.opt.titlestring = string.format("%s | %s", filename, github_match)
            else
              -- Fallback: filename | Nvim
              vim.opt.titlestring = string.format("%s | Nvim", filename)
            end
          end,
        },
      },
      -- Show smart picker on startup
      startup_picker = {
        {
          event = "VimEnter",
          desc = "Show smart picker on startup",
          callback = function()
            -- Skip if opening with arguments
            if vim.fn.argc() > 0 then return end

            -- Skip if current buffer has content
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            if #lines > 1 or (#lines == 1 and lines[1] ~= "") then return end

            -- Delay to ensure everything is loaded
            vim.defer_fn(function()
              require("snacks").picker.smart()
            end, 50)
          end,
        },
      },
    },

    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        wrap = true, -- sets vim.opt.wrap
        clipboard = "unnamedplus", -- use system clipboard for all operations
        title = true, -- enable title string
        titlestring = "", -- will be set dynamically by autocommand
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["<C-!>"] = { "<Cmd>suspend<CR>", desc = "Suspend nvim (return with 'fg')" },
        ["<C-q>Q"] = { "<Cmd>wqa<CR>", desc = "Save all buffers and quit Neovim" },
        -- navigate buffer tabs
        ["<C-c>"] = { "<Cmd>wa<CR><Cmd>bd<CR>", desc = "Save and close buffer" }, -- Added C-x to save and close buffer
        ["F"] = { "za", desc = "Toggle fold under cursor" },
        ["J"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
        ["K"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
        ["L"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
        ["H"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
        ["<C-e>"] = { "<Cmd>Neotree toggle<CR>", desc = "Open Explorer" },
        ["<C-m>"] = { "<Cmd>OverseerRun<CR>", desc = "Run Overseer" },
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
        -- Quick group toggles
        ["<C-b>l"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find in line",
        },
        ["<C-b>1"] = { "<Cmd>BufferLineGroupToggle DEX<CR>", desc = "Toggle DEX group" },
        ["<C-b>2"] = { "<Cmd>BufferLineGroupToggle DID<CR>", desc = "Toggle DID group" },
        ["<C-b>3"] = { "<Cmd>BufferLineGroupToggle DWN<CR>", desc = "Toggle DWN group" },
        ["<C-b>4"] = { "<Cmd>BufferLineGroupToggle SVC<CR>", desc = "Toggle SVC group" },
        ["<C-b>t"] = { "<Cmd>BufferLineGroupToggle Tests<CR>", desc = "Toggle Tests group" },
        ["<C-b>k"] = { "<Cmd>BufferLinePickClose<CR>", desc = "Pick buffer to close" },
        ["<C-g>o"] = { "<cmd>!gh repo view --web<CR>", desc = "Open Repo on Web" },
        ["<C-g><C-d>"] = {
          function()
            require("snacks").terminal("gh dash", {
              hidden = true,
              auto_close = true,
              interactive = true,
            })
          end,
          desc = "GH Dash",
        },
        ["<C-g><C-c>"] = {
          terminals.smartCommit_toggle,
          desc = "SmartCommit Toggle",
        },
        ["<C-g><C-g>"] = {
          terminals.lazygit_toggle,
          desc = "Lazygit Toggle",
        },
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
        ["<C-f>r"] = {
          terminals.scooter_toggle,
          desc = "Find and replace",
        },
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
        ["<C-f>gc"] = {
          function()
            local claude_dir = vim.fn.getcwd() .. "/.claude"
            -- Check if directory exists
            if vim.fn.isdirectory(claude_dir) == 0 then
              vim.notify("No .claude directory found in current project", vim.log.levels.WARN)
              return
            end
            -- Use files picker to find Claude files
            require("snacks").picker.files {
              cwd = claude_dir,
              transform = file_filter,
            }
          end,
          desc = "Find Claude files",
        },
        ["<C-f>p"] = { desc = "Find Package files" },
        ["<C-f>pc"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/packages/cli" },
              exclude = { "packages/cli/dist" },
              ft = { "ts", "tsx", "js" },
            }
          end,
          desc = "Find @sonr.io/cli files",
        },
        ["<C-f>pe"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/packages/es" },
              exclude = { "packages/es/dist" },
              ft = { "ts", "tsx", "js" },
            }
          end,
          desc = "Find @sonr.io/es files",
        },
        ["<C-f>pp"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/packages/pkl" },
              exclude = { "packages/pkl/dist" },
              ft = { "ts", "tsx", "js" },
            }
          end,
          desc = "Find @sonr.io/es files",
        },
        ["<C-f>ps"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/packages/sdk" },
              exclude = { "packages/sdk/dist" },
              ft = { "ts", "tsx", "js" },
            }
          end,
          desc = "Find @sonr.io/sdk files",
        },
        ["<C-f>pu"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/packages/ui" },
              exclude = { "packages/ui/dist" },
              ft = { "ts", "tsx", "js" },
            }
          end,
          desc = "Find @sonr.io/ui files",
        },
        ["<C-f>m"] = { desc = "Find Module files" },
        ["<C-f>me"] = {
          function()
            require("snacks").picker.files {
              dirs = {
                "/home/prad/code/github.com/sonr-io/sonr/proto/dex",
                "/home/prad/code/github.com/sonr-io/sonr/x/dex",
              },
              ft = { "go", "md", "proto" },
            }
          end,
          desc = "Find x/dex files",
        },
        ["<C-f>mi"] = {
          function()
            require("snacks").picker.files {
              dirs = {
                "/home/prad/code/github.com/sonr-io/sonr/proto/did",
                "/home/prad/code/github.com/sonr-io/sonr/x/did",
              },
              ft = { "go", "md", "proto" },
            }
          end,
          desc = "Find x/did files",
        },
        ["<C-f>md"] = {
          function()
            require("snacks").picker.files {
              dirs = {
                "/home/prad/code/github.com/sonr-io/sonr/proto/dwn",
                "/home/prad/code/github.com/sonr-io/sonr/x/dwn",
              },
              ft = { "go", "md", "proto" },
            }
          end,
          desc = "Find x/dwn files",
        },
        ["<C-f>ms"] = {
          function()
            require("snacks").picker.files {
              dirs = {
                "/home/prad/code/github.com/sonr-io/sonr/proto/svc",
                "/home/prad/code/github.com/sonr-io/sonr/x/svc",
              },
              ft = { "go", "md", "proto" },
            }
          end,
          desc = "Find x/svc files",
        },
        ["<C-f>g"] = {
          desc = "Find by Group",
        },
        ["<C-f>gw"] = {
          function()
            local workflows_dir = vim.fn.getcwd() .. "/.github/workflows"
            -- Check if directory exists
            if vim.fn.isdirectory(workflows_dir) == 0 then
              vim.notify("No .github/workflows directory found in current project", vim.log.levels.WARN)
              return
            end
            -- Use files picker to find workflow files
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
              args = {
                "devbox.json|process-compose.yaml|Dockerfile|docker-compose.yaml|compose.yaml",
              },
            }
          end,
          desc = "Find Devbox/Docker files",
        },
        ["<C-f>gm"] = {
          function()
            require("snacks").picker.files {
              cmd = "fd",
              args = {
                "Makefile",
              },
            }
          end,
          desc = "Find Makefile files",
        },
        ["<C-f>gp"] = {
          function()
            require("snacks").picker.files {
              cmd = "fd",
              args = {
                "package.json",
              },
            }
          end,
          desc = "Find Package.json files",
        },
        ["<C-f>."] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi" },
            }
          end,
          desc = "Find dotfiles",
        },
        ["<C-f>c."] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi" },
            }
          end,
          desc = "Find chezmoi config files",
        },
        ["<C-f>cn"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/prnk28/nvim" },
            }
          end,
          desc = "Find nvim files",
        },
        ["<C-f>cs"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi/dot_local/share/services" },
            }
          end,
          desc = "Find Service files",
        },
        -- AI/Assistant mappings (Claude Code)
        ["<C-a>"] = { nil, desc = "AI/Claude Code" },
        ["<C-a><C-a>"] = { function() _G.claude_at_root "ClaudeCode"() end, desc = "Toggle Claude" },
        ["<C-a>f"] = { function() _G.claude_at_root "ClaudeCodeFocus"() end, desc = "Focus Claude" },
        ["<C-a>C"] = { function() _G.claude_at_root "ClaudeCode --resume"() end, desc = "Resume Claude" },
        ["<C-a>c"] = { function() _G.claude_at_root "ClaudeCode --continue"() end, desc = "Continue Claude" },
        ["<C-a>m"] = { "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
        ["<C-a>b"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
        ["<C-a>y"] = { "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
        ["<C-a>n"] = { "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        ["<C-a><C-t>"] = { "<cmd>TemplateSnacks<cr>", desc = "Open template picker" },
        ["<C-a>t"] = {
          function() vim.fn.feedkeys ":TemplateCreate " end,
          desc = "Create new template",
        },
        ["<C-a>T"] = { "<cmd>TemplateTelescope type=insert<cr>", desc = "Template picker (Telescope)" },
        -- Taskfile
        ["<C-t><C-t>"] = { terminals.mk_toggle, desc = "Taskfile Toggle" },
        -- UI Toggles with Snacks
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
        ["<leader>ul"] = {
          function()
            local new_value = not require("lsp_lines").toggle()
            vim.diagnostic.config { virtual_text = new_value }
          end,
          desc = "Toggle LSP Lines",
        },
      },
      i = {
        ["<C-c>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" },
        ["<C-x>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" }, -- Added C-x for insert mode
      },
      v = {
        ["<C-e>"] = { "<Cmd>Neotree toggle<CR>", desc = "Open Explorer" },
        ["<C-c>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" }, -- Modified to save and close buffer
        ["<C-x>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" }, -- Added C-x for visual mode
        -- Claude Code visual mode
        ["<C-a>"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
        ["D"] = {
          function()
            -- Yank the visual selection to register v
            vim.cmd 'normal! "vy'
            local selection = vim.fn.getreg "v"

            -- Escape special regex characters
            local escaped = vim.fn.escape(selection, [[/\.*$^~[]])

            -- Delete all occurrences in the buffer (e flag suppresses errors if no match)
            vim.cmd(string.format([[%%s/%s//ge]], escaped))

            -- Show notification of what was deleted
            vim.notify(string.format("Deleted all occurrences of: %s", selection), vim.log.levels.INFO)
          end,
          desc = "Delete all occurrences of selected text",
        },
        ["R"] = {
          function()
            -- Yank the visual selection to register v
            vim.cmd 'normal! "vy'
            local selection = vim.fn.getreg "v"

            -- Escape special regex characters for search pattern
            local escaped = vim.fn.escape(selection, [[/\.*$^~[]])

            -- Show input prompt using snacks.input
            require("snacks").input({
              prompt = string.format("Replace '%s' with:", selection),
              default = "",
            }, function(replacement)
              if replacement then
                -- Escape special characters for replacement string
                local escaped_replacement = vim.fn.escape(replacement, [[/\&~]])

                -- Replace all occurrences in the buffer
                vim.cmd(string.format([[%%s/%s/%s/ge]], escaped, escaped_replacement))

                -- Show notification
                vim.notify(string.format("Replaced '%s' with '%s'", selection, replacement), vim.log.levels.INFO)
              end
            end)
          end,
          desc = "Replace all occurrences of selected text",
        },
      },
      t = {
        ["<C-t><C-t>"] = { terminals.mk_toggle, desc = "Taskfile Toggle" },
        ["<C-e>"] = { "<Cmd>Neotree toggle<CR>", desc = "Open Explorer" },
        ["<C-b>f"] = {
          function() require("snacks").picker.buffers() end,
          desc = "Find buffers",
        },
        -- Exit terminal mode and close window
        ["<C-q>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
            vim.cmd "close"
          end,
          desc = "Exit terminal and close window",
        },
        -- Exit terminal mode and close window
        ["<C-h>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-w>h]], true, false, true), "n", false)
          end,
          desc = "Navigate to left window",
        },
        ["<C-j>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-w>j]], true, false, true), "n", false)
          end,
          desc = "Navigate to bottom window",
        },
        ["<C-k>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-w>k]], true, false, true), "n", false)
          end,
          desc = "Navigate to top window",
        },
        ["<C-l>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-w>l]], true, false, true), "n", false)
          end,
          desc = "Navigate to right window",
        },
      },
    },
  },
}
