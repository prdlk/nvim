# AstroNvim Plugin Structure

This document describes the complete plugin structure for your AstroNvim configuration.

## 📁 Directory Structure

```
lua/plugins/
├── README.md                      # Documentation and guide
├── astrocore.lua                  # Core settings, keymaps, autocmds (23KB)
├── astrolsp.lua                   # LSP, formatting, linting (23KB)
├── astroui.lua                    # UI configuration (8.3KB)
├── buildtools.lua                 # Build tools & dev environment (6.5KB)
├── bufferline.lua                 # Buffer/tab management (2.1KB)
├── claude.lua                     # Claude Code integration (1.3KB)
├── neotree.lua                    # File explorer (15KB)
├── _template-custom.lua           # Template for custom plugins (disabled)
├── _template-filetype.lua         # Template for filetype plugins (disabled)
├── _template-mason.lua            # Template for Mason tools (disabled)
├── _template-treesitter.lua       # Template for Treesitter (disabled)
└── _template-ui.lua               # Template for UI plugins (disabled)
```

## 🎯 Active Plugin Files

### Core Configuration (3 files)

1. **astrocore.lua** - Core AstroNvim functionality
   - Session management
   - Root detection (lsp, git)
   - Features configuration
   - Options (vim settings)
   - **Keymappings** (extensive custom bindings)
   - **UI toggles** (`<leader>u` prefix)

2. **astrolsp.lua** - Comprehensive LSP & Tooling (CONSOLIDATED)
   - LSP configurations (Go, TypeScript, Tailwind, HTML, CSS, Protobuf, JSON, YAML, Lua, Volar)
   - **Formatting** (Conform.nvim with oxfmt, stylua, rustfmt, taplo)
   - **Linting** (nvim-lint with oxlint, stylelint, markdownlint)
   - **Treesitter** configuration
   - **TypeScript tooling** (typescript-tools, autotag)
   - **Mason** auto-installation
   - **Package management** (package-info, crates.nvim)
   - **Diagnostics UI** (Trouble, lsp_lines, nvim-bqf)

3. **astroui.lua** - UI/UX Configuration
   - Colorscheme (cyberdream)
   - Icons
   - Statusline (Heirline)
   - Status components

### Feature Plugin Files (4 files)

4. **buildtools.lua** - Development Tools
   - Treesitter (TOML, YAML, JSON parsers)
   - SchemaStore (JSON/YAML schemas)
   - Overseer (task runner for bun, vite)
   - Trouble (diagnostics)
   - Gitsigns (git integration)
   - EditorConfig
   - DevContainer support

5. **bufferline.lua** - Buffer Management
   - Enhanced bufferline with diagnostics
   - Custom close handlers
   - Buffer groups support
   - Icon integration

6. **claude.lua** - AI Assistant
   - Claude Code integration
   - Git root detection
   - Custom commands and keybindings
   - File explorer integration

7. **neotree.lua** - File Explorer
   - Dynamic pattern filtering
   - LSP file operations integration
   - Snacks.rename integration (NEW)
   - Custom keybindings for git, terminals, docker
   - Custom commands (format, mason)

8. **template.lua** - Code Templates (NEW)
   - Snacks picker integration
   - 14 essential templates for Cosmos SDK, Protobuf, and Vite+Cloudflare
   - Smart variable substitution
   - Filetype-aware template filtering

## 📝 Template Files (5 files - disabled by default)

These files are prefixed with `_template-` and disabled with `if true then return {} end`.
Remove the first line to activate them.

1. **_template-custom.lua** - Examples for adding custom plugins
2. **_template-filetype.lua** - Filetype-specific configurations (Markdown, Rust, Python, Go, LaTeX)
3. **_template-mason.lua** - Mason tool installer customization
4. **_template-treesitter.lua** - Treesitter parser configuration
5. **_template-ui.lua** - UI plugins and colorscheme examples

## ✅ Recent Changes

### Consolidated Files
- ✅ **tsx.lua** → Merged into `astrolsp.lua`
- ✅ **linting.lua** → Merged into `astrolsp.lua`

### Added Features
- ✅ Snacks.rename integration in `neotree.lua`
- ✅ Snacks.toggle keymaps in `astrocore.lua` (`<leader>u` prefix)
- ✅ Proper `---@type LazySpec` annotations on all files
- ✅ Comprehensive documentation (README.md)
- ✅ Template files for common customizations

### New Toggle Keybindings (`<leader>u`)
- `<leader>ud` - Toggle diagnostics
- `<leader>un` - Toggle line numbers
- `<leader>ur` - Toggle relative numbers
- `<leader>uw` - Toggle line wrap
- `<leader>us` - Toggle spelling
- `<leader>ui` - Toggle inlay hints
- `<leader>ut` - Toggle treesitter
- `<leader>uc` - Toggle conceal
- `<leader>uI` - Toggle indent guides
- `<leader>uz` - Toggle zen mode
- `<leader>uZ` - Toggle zoom
- `<leader>ua` - Toggle animations
- `<leader>uS` - Toggle smooth scroll
- `<leader>up` - Toggle profiler
- `<leader>uh` - Toggle profiler highlights
- `<leader>ux` - Toggle dim inactive
- `<leader>uf` - Toggle format on save
- `<leader>ul` - Toggle LSP lines

### Template Keybindings
- `<C-a><C-t>` - Open template picker (Snacks integration)

## 📚 Documentation

All plugin files now include:
- ✅ Module documentation headers
- ✅ `---@type LazySpec` annotations
- ✅ Detailed inline comments
- ✅ Proper lazy loading strategies

## 🎓 Quick Reference

### Adding a New Plugin
1. Create a new `.lua` file in `lua/plugins/`
2. Add module documentation and `---@type LazySpec`
3. Return a table with plugin specifications
4. Configure lazy loading (event, cmd, ft, keys)

### Modifying Existing Config
- Core settings → `astrocore.lua`
- LSP/formatting/linting → `astrolsp.lua`
- UI/statusline → `astroui.lua`
- Keymaps → `astrocore.lua` (mappings section)

### Template Usage
1. Copy a template file (remove `_template-` prefix)
2. Remove `if true then return {} end` line
3. Customize the configuration
4. Save and restart Neovim

## 🔧 Useful Commands
- `:Lazy` - Plugin manager
- `:Mason` - LSP/tool installer
- `:AstroReload` - Reload config
- `:ConformInfo` - Format status
- `:FormatToggle` - Toggle format on save
- `:LspLinesToggle` - Toggle inline diagnostics
- `:checkhealth` - Health check

## 📖 Resources
- [AstroNvim Docs](https://docs.astronvim.com)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [AstroCore](https://github.com/AstroNvim/astrocore)
- [AstroLSP](https://github.com/AstroNvim/astrolsp)
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
