local Terminal = require("toggleterm.terminal").Terminal

-- Track closed buffers
local closed_buffers = {}

-- Shared ignore patterns from neotree configuration
local ignore_patterns = {
  -- Hidden patterns
  "chain_*.json",
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
  "*_integration.go",
  "*_test.go",
  "*_query_docs.md",
  "*_tx_docs.md",
  "*_mock.go",
  "biome*",
  -- Never show patterns
  "CLAUDE*",
  ".pkl-lsp",
  ".tsbuildinfo",
  "contrib",
  "interchaintest",
  "package-lock.json",
  ".prettierrc",
  "node_modules",
  "PULL_REQUEST_TEMPLATE.md",
  ".DocumentRevisions-V100",
  ".Spotlight-V100",
  ".TemporaryItems",
  ".Trashes",
  ".fseventsd",
  ".editorconfig",
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
  "*.jpg",
  ".parcel-cache",
  "*.icns",
  "*.ico",
  ".aider.tags.cache.v4",
  "*.iml",
  "Icon?",
  "iCloud~",
  "com~",
  "readme.md",
  ".conform*",
  ".null-ls_*",
  -- Additional never show items
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
  "LICENSE",
  "tmp",
  "sonr.log",
  "DISCUSSION_TEMPLATE",
  "ISSUE_TEMPLATE",
  ".timemachine",
  "junit.xml",
  ".jj",
  ".spawn",
  ".turbo",
}

-- Create a custom transform function to filter out ignored files
local function create_file_filter()
  return function(item)
    if not item or not item.file then return item end

    local file = item.file
    local basename = vim.fn.fnamemodify(file, ":t")
    local dir = vim.fn.fnamemodify(file, ":h:t")

    -- Check each ignore pattern
    for _, pattern in ipairs(ignore_patterns) do
      -- Convert glob pattern to Lua pattern
      local lua_pattern = pattern:gsub("%.", "%%."):gsub("%*", ".*"):gsub("%?", ".")

      -- Check if the pattern matches the basename or path
      if basename:match("^" .. lua_pattern .. "$") or file:match(lua_pattern) then
        return nil -- Filter out this item
      end
    end

    -- Also filter out specific directory names
    local ignored_dirs = {
      "contracts",
      "crypto",
      "api",
      "chains",
      "test",
      "examples",
      "scripts",
      "bridge",
      "client",
      "translations",
      "env",
      ".husky",
    }

    for _, ignored in ipairs(ignored_dirs) do
      if dir == ignored or file:match("/" .. ignored .. "/") then return nil end
    end

    return item
  end
end

local file_filter = create_file_filter()

local yazi = Terminal:new {
  cmd = "yazi",
  hidden = true,
  direction = "tab",
  close_on_exit = true, -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd "startinsert!"
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
}

local scooter = Terminal:new {
  cmd = "scooter",
  hidden = true,
  direction = "vertical", -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd "startinsert!"
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
}

local lazyjournal = Terminal:new {
  cmd = "lazyjournal",
  hidden = true,
  direction = "float", -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd "startinsert!"
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
}

local mk = Terminal:new {
  cmd = "mk",
  hidden = true,
  direction = "vertical", -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd "startinsert!"
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
}

-- Toggle Functions (global so they can be used in other files)
function _G.Lazyjournal_toggle() lazyjournal:toggle() end
function _G.Mk_toggle() mk:toggle() end
function _G.Scooter_toggle() scooter:toggle() end
function _G.Yazi_toggle() yazi:toggle() end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    rooter = {
      -- list of detectors in order of prevalence, elements can be:
      --   "lsp" : lsp detection
      --   string[] : a list of directory patterns to look for
      --   fun(bufnr: integer): string|string[] : a function that takes a buffer number and outputs detected roots
      detector = {
        "lsp", -- highest priority is getting workspace from running language servers
        { ".git", "_darcs", ".hg", ".bzr", ".svn" }, -- next check for a version controlled parent directory
        {
          "go.work",
          "package.json",
          "lua",
          "Cargo.toml",
          "Pipfile",
          "docs.json",
        }, -- lastly check for a file named `main`
      },
      -- ignore things from root detection
      ignore = {
        servers = {}, -- list of language server names to ignore (Ex. { "efm" })
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
      virtual_text = false,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        wrap = true, -- sets vim.opt.wrap
        clipboard = "unnamedplus", -- use system clipboard for all operations
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
        -- navigate buffer tabs
        ["<C-c>"] = {
          function()
            -- Save the buffer path before closing
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname ~= "" then
              table.insert(closed_buffers, bufname)
              -- Keep only the last 10 closed buffers
              if #closed_buffers > 10 then table.remove(closed_buffers, 1) end
            end
            vim.cmd "wa"
            vim.cmd "bd"
          end,
          desc = "Save and close buffer",
        },
        ["F"] = { "za", desc = "Toggle fold under cursor" },
        ["L"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
        ["H"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
        ["<C-e>"] = {
          function() require("snacks").explorer.reveal() end,
          desc = "Reveal file in Explorer",
        },
        ["<C-m>"] = { "<Cmd>OverseerRun<CR>", desc = "Run Overseer" },
        ["<C-l>"] = { "<Cmd>b#<CR>", desc = "Return to last buffer" },
        ["<leader>e"] = {
          function() require("snacks").explorer.reveal() end,
          desc = "Reveal file in Explorer",
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
        ["<C-b>c"] = {
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
        ["<C-b>z"] = {
          function()
            if #closed_buffers > 0 then
              local last_closed = table.remove(closed_buffers)
              vim.cmd("e " .. vim.fn.fnameescape(last_closed))
              vim.notify("Reopened: " .. vim.fn.fnamemodify(last_closed, ":t"))
            else
              vim.notify("No recently closed buffer found", vim.log.levels.WARN)
            end
          end,
          desc = "Reopen last closed buffer",
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
        ["<C-g>h"] = {
          function()
            require("snacks").terminal("gh dash", {
              hidden = true,
              auto_close = true,
              interactive = true,
            })
          end,
          desc = "Dashboard",
        },
        ["<C-g>g"] = {
          function()
            require("snacks").terminal("lazygit", {
              hidden = true,
              auto_close = true,
              interactive = true,
            })
          end,
          desc = "Lazygit",
        },
        ["<C-g>d"] = {
          function() require("snacks").picker.git_diff() end,
          desc = "Search git diffs",
        },
        ["<C-g>b"] = {
          function() require("snacks").picker.git_branches() end,
          desc = "Search git branches",
        },
        ["<C-t>d"] = {
          desc = "Devbox Services",
        },
        ["<C-t>du"] = {
          function()
            require("snacks").terminal("devbox services up", {
              hidden = true,
              auto_close = true,
              start_in_insert = true,
              interactive = true,
            })
          end,
          desc = "Devbox Services Up",
          noremap = true,
        },
        ["<C-t>dd"] = {
          function()
            require("snacks").terminal("devbox services down", {
              hidden = true,
              auto_close = true,
              start_in_insert = true,
              interactive = true,
            })
          end,
          desc = "Devbox Services Down",
          noremap = true,
        },
        ["<C-t>da"] = {
          function()
            require("snacks").terminal("devbox services attach", {
              hidden = true,
              auto_close = false,
              start_in_insert = true,
              interactive = true,
            })
          end,
          desc = "Devbox Services Attach",
          noremap = true,
        },
        ["<C-t>."] = { _G.Yazi_toggle, desc = "Yazi Toggle" },
        ["<C-t>t"] = {
          function() require("snacks").terminal() end,
          desc = "Toggle Terminal",
        },
        ["K"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous Diagnostic" },
        ["J"] = { function() vim.diagnostic.goto_next() end, desc = "Next Diagnostic" },
        ["vv"] = { "gg0VG$", desc = "Select all contents in buffer" },
        ["T"] = { "gg", desc = "Go to top of file" },

        ["<C-f>r"] = {
          _G.Scooter_toggle,
          desc = "Find and replace",
        },
        ["<C-f>d"] = {
          function() require("snacks").picker.diagnostics() end,
          desc = "Find diagnostics",
        },
        ["<C-f>l"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find diagnostics",
        },
        ["<C-f>f"] = {
          function() require("snacks").picker.git_files { transform = file_filter } end,
          desc = "Find files",
        },
        ["<C-f>o"] = {
          function() require("snacks").picker.recent() end,
          desc = "Find recent files",
        },
        ["<C-o>"] = {
          function() require("snacks").picker.projects() end,
          desc = "Find projects",
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
        ["<C-f>go"] = { "<Cmd>ObsidianSearch<CR>", desc = "Find in Obsidian" },
        ["<C-f>p"] = { desc = "Find Package files" },
        ["<C-f>P"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/code/github.com/sonr-io/sonr/proto" },
              ft = { "proto" },
            }
          end,
          desc = "Find Proto files",
        },
        ["<C-f>W"] = {
          function()
            require("snacks").picker.files {
              dirs = {
                "/home/prad/code/github.com/sonr-io/sonr/packages",
                "/home/prad/code/github.com/sonr-io/sonr/web",
              },
              exclude = { "packages/**/dist", "web/**/dist" },
              ft = { "ts", "tsx", "js", "html", "css", "json", "yaml" },
            }
          end,
          desc = "Find Web Dev files",
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
        ["<C-,>c"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi/dot_config" },
            }
          end,
          desc = "Find chezmoi config files",
        },
        ["<C-,>e"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi/extensions" },
            }
          end,
          desc = "Find chezmoi extension files",
        },
        ["<C-,>l"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi/dot_local" },
            }
          end,
          desc = "Find chezmoi local files",
        },
        ["<C-,>n"] = {
          function()
            require("snacks").picker.files {
              dirs = { "/home/prad/.local/share/chezmoi/dot_config/nvim" },
            }
          end,
          desc = "Find chezmoi neovim files",
        },
        ["<C-a>a"] = { function() vim.lsp.buf.code_action() end, desc = "LSP Code Action" },
        ["<C-a>h"] = { function() vim.lsp.buf.hover() end, desc = "LSP Hover" },
        ["<C-a>d"] = {
          function() require("snacks").picker.lsp_definitions() end,
          desc = "Find LSP definitions",
        },
        ["<C-a>r"] = {
          function() require("snacks").picker.lsp_references() end,
          desc = "Find LSP references",
        },
        ["<C-a>s"] = {
          function() require("snacks").picker.lsp_symbols() end,
          desc = "Find LSP symbols",
        },
        -- Terminal launcher
      },
      i = {
        ["<C-s>"] = { "<Cmd>wa<CR><Esc>", desc = "Save and return to normal mode" },
        ["<C-c>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" },
        ["<C-x>"] = { "<Cmd>wa<CR><Cmd>bd<CR><Esc>", desc = "Save, close buffer, and return to normal mode" }, -- Added C-x for insert mode
      },
      v = {
        ["<C-e>"] = {
          function()
            -- Toggle explorer using the proper Snacks.explorer API
            local snacks = require "snacks"
            -- Check if there's an active explorer picker
            local pickers = snacks.picker.get { source = "explorer" }
            if #pickers > 0 then
              -- Close the explorer
              for _, picker in ipairs(pickers) do
                picker:close()
              end
            else
              -- Open the explorer
              snacks.explorer()
            end
          end,
          desc = "Toggle Explorer",
        },
        ["<C-c>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" }, -- Modified to save and close buffer
        ["<C-x>"] = { "<Cmd>w<CR><Cmd>bd<CR>", desc = "Save and close buffer" }, -- Added C-x for visual mode
      },
      t = {
        ["<C-e>"] = {
          function()
            -- Toggle explorer using the proper Snacks.explorer API
            local snacks = require "snacks"
            -- Check if there's an active explorer picker
            local pickers = snacks.picker.get { source = "explorer" }
            if #pickers > 0 then
              -- Close the explorer
              for _, picker in ipairs(pickers) do
                picker:close()
              end
            else
              -- Open the explorer
              snacks.explorer()
            end
          end,
          desc = "Toggle Explorer",
        },
        ["<C-b>f"] = {
          function() require("snacks").picker.buffers() end,
          desc = "Find buffers",
        },
        -- Exit terminal mode and close window
        ["<C-c>"] = {
          function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
            vim.cmd "close"
          end,
          desc = "Exit terminal and close window",
        },
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
