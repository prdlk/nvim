--- User plugins: cursor animation and the central snacks.nvim configuration
--- (all snacks modules are configured here in one snacks.Config table)

-- Confirm action for file-opening pickers: <CR> opens the selection as a
-- tab via `tabdrop` (:tab drop semantics — focus the buffer if it's already
-- visible in any tab, don't spawn a tab from an empty buffer, else open a
-- new tab). Explicit edit-cmd keybinds (<S-CR>/<c-v> vsplit, <c-s> split)
-- carry `action.cmd` and are passed through untouched.
local function tab_confirm(picker, item, action)
  local actions = require "snacks.picker.actions"
  if action.cmd then return actions.jump(picker, item, action) end
  return actions.jump(picker, item, vim.tbl_extend("force", {}, action, { cmd = "tabdrop" }))
end

-- Tab-on-enter + vsplit-on-shift-enter for the file-opening pickers only;
-- location pickers (lsp_*, lines, diagnostics, grep) and sources with their
-- own confirm (git_branches, projects) keep their defaults.
local picker_sources = {}
for _, source in ipairs { "files", "git_files", "smart", "recent", "buffers" } do
  picker_sources[source] = {
    confirm = tab_confirm,
    win = {
      input = { keys = { ["<S-CR>"] = { "edit_vsplit", mode = { "n", "i" } } } },
      list = { keys = { ["<S-CR>"] = "edit_vsplit" } },
    },
  }
end

-- Smart picker: anchor to the current git repository. `config` runs when
-- the picker opens: cwd becomes the repo root (so the `files` finder scans
-- the whole repo, not just a rooter-chdir'd subdir) and `filter.cwd` drops
-- buffers/recent entries from other repos. Outside a repo, plain cwd
-- behavior is kept.
picker_sources.smart.config = function(opts)
  local root = require("snacks").git.get_root()
  if root then
    opts.cwd = root
    opts.filter = vim.tbl_extend("force", opts.filter or {}, { cwd = true })
  end
  return opts
end

-- Projects picker (<Leader>fp, <C-f>p, <S-Space><S-Space>): when the ghq
-- CLI is installed, every `ghq list -p` repo joins the recent/dev projects.
-- Resolved at open time so newly cloned repos show up without a restart.
picker_sources.projects = {
  config = function(opts)
    if vim.fn.executable "ghq" == 1 then
      local repos = vim.fn.systemlist { "ghq", "list", "-p" }
      if vim.v.shell_error == 0 then opts.projects = vim.list_extend(vim.list_slice(opts.projects or {}), repos) end
    end
    return opts
  end,
}

---@type LazySpec
return {
  { "sphamba/smear-cursor.nvim", event = "VeryLazy", opts = {} },

  -- terminals are handled by kitty now
  { "akinsho/toggleterm.nvim", enabled = false },

  -- conform owns formatting (plugins/conform.lua). AstroNvim's none-ls ships
  -- with mason-null-ls `handlers = {}`, which auto-registers every mason tool
  -- (biome, goimports, buf, ...) as a second formatter/linter client.
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },

  -- Under tmux, smart-splits drives <C-h/j/k/l> and resizing (config.pane_nav
  -- and plugins/pane-nav.lua delegate to it) and flags the pane @pane-is-vim
  -- for tmux.conf. herdr and kitty stay on config.pane_nav, so its env() picks
  -- the integration instead of smart-splits' own env-var guess. Loaded at
  -- startup under tmux so the flag is set before the first keypress
  -- (AstroNvim's early load keys off TERM_PROGRAM, which tmux.conf passes
  -- through from the outer terminal).
  {
    "mrjones2014/smart-splits.nvim",
    lazy = require("config.pane_nav").env() ~= "tmux",
    opts = function(_, opts)
      opts.at_edge = "wrap"
      opts.multiplexer_integration = require("config.pane_nav").env() == "tmux" and "tmux" or false
    end,
  },

  -- lsp_signature.nvim is gone; astrolsp's own signature help replaces it
  { "AstroNvim/astrolsp", opts = { features = { signature_help = true } } },

  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        jump = { reuse_win = true },
        sources = picker_sources,
      },
      -- no dashboard: startup either restores the worktree/branch session or
      -- opens the git files picker (see config.session)
      dashboard = { enabled = false },

      -- GitHub issue/PR pickers and buffers (`<C-g>` binds in astrocore.lua)
      gh = {},

      -- auto-highlight LSP references of the symbol under the cursor;
      -- ]] / [[ jump binds live in plugins/astrolsp.lua (capability-gated)
      words = { enabled = true },
    },
  },

}
