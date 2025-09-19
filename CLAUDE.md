# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is a Neovim configuration based on AstroNvim v4+ framework. The configuration follows a modular plugin architecture using lazy.nvim as the plugin manager.

## Commands

### Neovim Development
- **Install/Update plugins**: Launch Neovim and run `:Lazy` to manage plugins
- **Sync plugins**: `:Lazy sync` to update all plugins
- **Check plugin health**: `:checkhealth` to verify Neovim setup

### Code Quality Tools
- **Lua linting**: Uses Selene for Lua linting (configured in `selene.toml`)
- **Lua formatting**: Uses Stylua with 120-character line width, 2-space indents (configured in `.stylua.toml`)

## Architecture

### Core Structure
The configuration bootstraps lazy.nvim and loads plugins in a specific order:
1. `init.lua` - Entry point that bootstraps lazy.nvim and sets leaders
2. `lua/lazy_setup.lua` - Configures lazy.nvim with AstroNvim and imports
3. `lua/community.lua` - Imports AstroCommunity plugin packs for language support
4. `lua/plugins/` - Custom plugin configurations
5. `lua/polish.lua` - Final configuration applied after all plugins load

### Plugin Organization
- **Base Framework**: AstroNvim v4 provides the core configuration framework
- **Language Packs**: Imported from AstroCommunity for Go, TypeScript, Markdown, HTML/CSS, etc.
- **Custom Plugins**: Located in `lua/plugins/` directory, each file configures specific functionality:
  - `astrocore.lua` - Core settings, keymappings, and autocmds
  - `astroui.lua` - UI configuration
  - `bufferline.lua` - Buffer/tab management
  - `neotree.lua` - File explorer configuration with extensive ignore patterns
  - `mason.lua` - LSP server management
  - `obsidian.lua` - Note-taking integration

### Key Configuration Patterns
- The configuration uses environment variables (e.g., `LAZY` for custom lazy.nvim path)
- Defensive programming with pcall() for robust loading across environments
- Shared ignore patterns between neotree and other file explorers to maintain consistency
- Leaders: Space as main leader, comma as local leader