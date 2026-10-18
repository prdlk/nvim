# prdlk/nvim

Personal Neovim config built on [AstroNvim](https://github.com/AstroNvim/AstroNvim) v6 (`version = "^6"` in `lua/lazy_setup.lua`), targeting Neovim 0.12.

It started from the AstroNvim template and now adds git-aware sessions, `fff`-backed file search, multiplexer-aware split navigation, mermaid diagnostics, MDX templates, and an Oh My Pi side terminal. One plugin per job: where AstroNvim or a community pack ships a second implementation of something already covered, it is disabled rather than configured.

## Requirements

| Tool | Used by |
| --- | --- |
| Neovim 0.12+, git | everything |
| Nerd Font | icons (`icons_enabled = true`) |
| `fd`, `ripgrep` | `<C-f>e` / `<C-f>m` pickers, grug-far |
| `cargo` (fallback only) | `fff` builds from source when no prebuilt binary downloads |
| `node` + `npm` | mermaid validator (installs `mermaid` + `jsdom` under `stdpath("data")` on first use) |
| `lazygit`, `lazydocker`, `gh` (+ `gh-dash`), `ghq` | git/GitHub/project binds |
| `kitty`, `yazi` | neo-tree image preview (`kitten icat`) and yazi launchers |
| `omp` + `omp plugin install omp.nvim` | Oh My Pi terminal and `omp.nvim` integration |
| `uv` / a project venv | basedpyright third-party imports (`uv sync`) |

Language servers, formatters, and linters come from the AstroCommunity packs through Mason.

## Installation

Back up any existing config:

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

Clone and start:

```shell
git clone https://github.com/prdlk/nvim ~/.config/nvim
nvim
```

`init.lua` bootstraps lazy.nvim on first launch and installs the plugins pinned in `lazy-lock.json`.

## Layout

```
init.lua               lazy.nvim bootstrap, terminal title, cursor shape
lua/lazy_setup.lua     AstroNvim import, leader keys (<Space>, localleader ","), lazy options
lua/community.lua      AstroCommunity imports (language packs, colorscheme, trouble, supermaven)
lua/plugins/           plugin specs and AstroNvim overrides, one file per concern
lua/config/            plain Lua modules used by the plugin specs
lua/polish.lua         runs last; registers the <Leader>u toggles
templates/mdx/         template.nvim snippets for MDX docs
scripts/               mermaid-validator.mjs (node process used by config/mermaid.lua)
```

## What's included

**Languages** (`lua/community.lua`): Go (+ golangci-lint), Rust, TypeScript, Biome, Python (basedpyright, no black/isort), HTML/CSS, Tailwind, JSON, YAML, TOML, Proto, Pkl, MDX.

**Python**: `plugins/python.lua` points basedpyright at `$VIRTUAL_ENV`/`$CONDA_PREFIX`, then `.venv`/`venv`/`env` in the project root, then system `python3`. A project with a `uv.lock` or `poetry.lock` and no venv gets a one-time warning. Ruff organizes imports and formats.

**Format on save** (`plugins/conform.lua`, `config/lsp_code_actions.lua`): on save, `source.organizeImports` and `source.fixAll` code actions run first, then conform formats. JavaScript buffers get the code actions but are not formatted. `<Leader>uf` turns the whole pipeline on or off.

**Sessions** (`config/session.lua`): sessions are keyed by `<worktree root>@<branch>`, so each worktree and branch keeps its own layout. On `VimEnter`, neo-tree opens and the saved session is restored; with no saved session, the git files picker opens instead. None of this happens when nvim is started with file arguments. Sessions save on exit.

**Search**: `fff.nvim` handles files and grep (frecency, respects `.gitignore` and `.ignore`). snacks.picker handles everything else. `config/ignore_patterns.lua` holds the shared ignore list used by neo-tree and the snacks pickers.

**Pane navigation** (`config/pane_nav.lua`): `<C-h/j/k/l>` moves between Neovim splits first. At the outermost split, the move goes to herdr, tmux, or kitty, whichever is the nearest ancestor process. Resize is plain `:resize` on `<C-Up/Down/Left/Right>`; smart-splits is disabled.

**Mermaid** (`config/mermaid.lua`): tree-sitter highlights ```` ```mermaid ```` fences in markdown/MDX and `.mmd` files. Diagnostics come from mermaid's own parser running in a node process, which exits after 5 idle minutes. Run `:MermaidCheck` to re-validate.

**Markdown**: `:Vellum` opens a live GitHub-style preview (prdlk fork, `mdx` branch). In markdown and MDX buffers, visual `<Leader>e…` applies formatting (see below).

**AI**: Supermaven provides inline ghost-text completions (`<C-l>` accepts). It is disabled for Python and inside the LeetCode work directory. `<C-a><C-a>` toggles an Oh My Pi terminal on the right.

**UI**: cyberdream colorscheme (muted variant), bufferline, neo-tree replacing mini.files, smear-cursor (loaded at `VeryLazy`). No statusline (`laststatus = 0`); heirline stays for the winbar breadcrumbs. Snacks dashboard is disabled.

### Disabled on purpose

Core or community plugins turned off in `plugins/user.lua` because something else already owns the job:

| Plugin | Replaced by |
| --- | --- |
| `none-ls.nvim`, `mason-null-ls.nvim` | conform (`mason-null-ls` would auto-register every Mason tool as a second formatter/linter client) |
| `smart-splits.nvim` | `config/pane_nav.lua` + native `:resize` |
| `toggleterm.nvim` | kitty / snacks terminals |
| `lsp_signature.nvim` (not imported) | astrolsp's built-in signature help (`features.signature_help = true`) |
| `refactoring.nvim`, `dev-tools.nvim` (not imported) | LSP code actions (`<C-a>a`) |
| `tv.nvim` (removed) | fff + snacks pickers |

Startup on a TTY is ~80 ms with 41 of 65 plugins loaded eagerly (`:Lazy profile`); the rest load on their command, key, filetype, or `User AstroFile`.

## Keymaps

Leader is `<Space>`; localleader is `,`. Prefixes: `<C-f>` find, `<C-g>` git/GitHub, `<C-b>` buffers, `<C-a>` assist, `<Leader>u` UI toggles.

### Files and search

| Key | Action |
| --- | --- |
| `<Leader><Leader>` | Smart picker (scoped to the git root) |
| `<Leader>e` | Git files |
| `<C-f>f` / `<C-f>.` | Find files in cwd / in the buffer's directory |
| `<C-f>w` / `<C-f>z` / `<C-f><C-w>` | Live grep / fuzzy grep / grep word or selection |
| `<C-f>r` | Resume last find/grep |
| `<C-f>e` | Pick an extension, then find files with that extension |
| `<C-f>m` | Files modified today |
| `<C-f>x` | URLs in the buffer (opens in browser) |
| `<C-f>o` / `<C-f>p` / `<C-f>P` | Recent files / projects / ghq repos |
| `<C-f>d` / `<C-f>l` | Diagnostics / lines |
| `<C-f>gw` `gd` `gm` `gp` `gc` | Workflows, Devbox/Docker, Makefiles, package.json, `.ai/` files |
| `<C-f><C-f>` | LSP symbols |
| `<C-i>` | Template picker (also takes over `<Tab>` in normal mode) |
| `<C-r>` | Find & replace (grug-far; linewise visual selection limits the range) |
| `<C-e>` | Toggle neo-tree |

File pickers open the selection with `:tab drop` on `<CR>` and in a vsplit on `<S-CR>`.

### Editing and navigation

| Key | Action |
| --- | --- |
| `f` / `F` | Flash word-start labels / toggle fold |
| `g/` | Flash search: type a pattern, labels on every match |
| `s` / `S` | Flash jump / Flash treesitter |
| `J` / `K` | Next / previous diagnostic |
| `H` / `L` | Previous / next buffer |
| `]]` / `[[` | Next / previous LSP reference |
| `<C-h/j/k/l>` | Move between splits, then tmux/herdr/kitty panes |
| `<C-Up/Down/Left/Right>` | Resize split |
| `vv` / `T` | Select all / go to top |
| visual `D` / `R` | Delete / replace every occurrence of the selection |
| `<C-p>` | Paste from system clipboard |

### Buffers, windows, saving

| Key | Action |
| --- | --- |
| `<C-s>` | Save if modified, otherwise buffer picker |
| `<C-w>` | Save buffer |
| `<C-c>` | Save if modified, then close buffer |
| `<C-q>` | Close window; save all and quit if it's the last one |
| `ZZ` / `<A-q>` | Save all and quit |
| `<C-b>b` / `<C-b>f` / `<C-b><C-c>` | Pick buffer / find buffers / close all other buffers |

`<C-w>` is remapped to save, so the built-in window prefix is not available on it.

### Git and GitHub

| Key | Action |
| --- | --- |
| `<C-g><C-g>` | lazygit |
| `<C-g><C-d>` | CodeDiff review workspace |
| `<C-g>d` / `<C-g><C-b>` | Git diff / branches picker |
| `<C-g><C-i>` / `<C-g>I` | GitHub issues (open / all) |
| `<C-g><C-p>` / `<C-g>P` | GitHub PRs (open / all) |
| `<C-g>o` | Open the repo on the web |
| `<C-d><C-d>` | lazydocker |

### Assist

| Key | Action |
| --- | --- |
| `<C-a>a` | Code actions |
| `<C-a>s` / `<C-a>S` | Document / workspace symbols (`<C-t>` in the picker sends results to Trouble) |
| `<C-a>d` | Diagnostics (`<C-t>` sends results to Trouble) |
| `<C-a><C-s>` | Toggle Supermaven |
| `<C-a><C-a>` | Toggle Oh My Pi terminal |

LSP binds are created only when the attached server supports the method (`plugins/astrolsp.lua`).

### Markdown (visual mode, markdown/MDX buffers)

`<Leader>ei` italic, `eb` bold, `ec` inline code, `ex` link, `el` / `eL` unordered / ordered list, `eC` code block.

### UI toggles

`<Leader>u` + `d` diagnostics, `l` diagnostic virtual lines, `f` format on save, `n` line numbers, `r` relative numbers, `w` wrap, `s` spell, `c` conceal, `i` inlay hints, `t` treesitter, `I` indent guides, `x` dim, `z` zen, `Z` zoom, `a` animations, `S` smooth scroll, `p` / `h` profiler.

## Development

Lua is formatted with StyLua (`.stylua.toml`) and linted with Selene (`selene.toml`, `neovim.yml`). Run `:Lazy update` to update plugins, then commit `lazy-lock.json`.
