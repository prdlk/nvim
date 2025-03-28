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
          "lua",
          "Taskfile.yml",
          "devbox.json",
          "Cargo.toml",
          "go.work",
          "Pipfile",
          "Makefile",
          "requirements.txt",
          "README.md",
          "devbox.json",
          "package.json",
          "go.mod",
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
      scope = "tab", -- Changed from "win" to "global" to make directory changes apply globally
      -- show notification on every working directory change
      notify = false,
    },

    -- Configure core features of AstroNvim
    features = {
      autopairs = true, -- enable autopairs at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = false, -- enable notifications at start
    },

    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        wrap = true, -- sets vim.opt.wrap
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
        ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["K"] = { "g;", desc = "Go to previous edited line" },
        ["J"] = { "g,", desc = "Go to next edited line" },
        ["vv"] = { "gg0VG$", desc = "Select all contents in buffer" },
        ["<C-Space>"] = { "<Cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
        ["<C-m>"] = { "<Cmd>OverseerRun<CR>", desc = "Overseer" },
        ["<C-u>"] = { "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Show Symbols" },
        ["<C-c>"] = { function() vim.cmd "bd" end, desc = "Close window" },
        ["<C-q>"] = { "<Cmd>wa<CR><Cmd>qa!<CR>", desc = "Save and Quit Neovim" },
        ["<C-r>"] = { vim.lsp.buf.rename, desc = "LSP Rename Symbol" },
        ["<C-e>"] = { "<Cmd>Neotree toggle<CR>", desc = "Show Explorer" },
        ["<C-p>"] = { "p", desc = "Paste" },
      },
      v = {
        ["<C-e>"] = { "<Cmd>Neotree toggle<CR>", desc = "Show Explorer" },
      },

      t = {
        ["<Esc>"] = {
          function()
            -- Check if we're in an Aider terminal buffer
            local current_buf = vim.api.nvim_get_current_buf()
            local buf_name = vim.api.nvim_buf_get_name(current_buf)

            -- If the buffer name contains "Aider" (as seen in the screenshot)
            if buf_name:match "Aider" then
              vim.cmd "AiderTerminalToggle"
            else
              -- Default behavior: exit terminal mode
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
            end
          end,
          desc = "Exit terminal mode or toggle Aider terminal",
        },
      },
    },
  },
}
