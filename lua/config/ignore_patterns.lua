--- Shared ignore patterns for file explorers and pickers
--- This module provides a centralized list of patterns to ignore across
--- snacks.picker and other file browsing tools. (The never_show lists were
--- consumed by neo-tree, now replaced by mini.files; kept as reference data.)
---
--- Everything here is fast-event-context safe (pure Lua + libuv only):
--- snacks picker transforms run inside async/uv callbacks where vimL
--- functions (vim.fn.*) raise E5560.
--- @module config.ignore_patterns

local uv = vim.uv or vim.loop

local M = {}

--- Core ignore patterns used across the configuration
--- These patterns use glob syntax (* and ? wildcards), matched against
--- file basenames and individual path segments.
M.patterns = {
  -- Build artifacts and generated files
  ".beads",
  "chain_*.json",
  ".npmrc",
  ".epiq",
  ".omc",
  ".claude",
  ".changeset",
  ".codegraph",
  ".gitignore",
  "turbo.json",
  "vite.config.ts",
  "bunfig.toml",
  "*.pb.go",
  "*.pkl.go",
  "*.pulsar.go",
  "*.pb.gorm.go",
  "*.pb.gw.go",
  "*_templ.go",
  "*_mock.go",
  "*_integration.go",
  "*_test.go",
  "AGENTS.md",
  "test",
  "tests",

  -- Configuration files
  ".editorconfig",
  ".gitpod.*",

  -- Lock files and dependencies
  "*.lock",
  "*.lockb",
  "*.sum",
  "*.work.*",
  "package-lock.json",
  "pnpm-lock.yaml",
  ".gitattributes",
  ".oxlintrc.json",
  "tsconfig*",

  -- Temporary and cache files
  "*.tmp",
  ".typecopy",
  ".python-version",
  ".prettierrc",
  ".trunk",
  ".config",
  ".pkl-lsp",
  ".tsbuildinfo",
  ".wrangler",
  ".parcel-cache",
  ".conform*",
  ".null-ls_*",

  -- Binary and media files
  "*.wasm",
  "*.png",
  "*.jpg",
  "*.icns",
  "*.ico",

  -- Directories and special files
  "contrib",
  "interchaintest",
  "PULL_REQUEST_TEMPLATE.md",
  "Icon?",
  "iCloud~",
  "com~",
}

--- Patterns that should never be shown in any file browser
M.never_show = {
  -- Version control
  ".git",
  ".ai",
  ".omc",

  -- Dependencies
  "node_modules",
  ".wrangler",
  "CODEOWNERS",
  ".golangci.yml",

  -- Build outputs
  ".next",
  ".parcel-cache",

  -- Task runners and tools
  ".task",
  ".devbox",
  ".turbo",
  ".jj",
  ".spawn",

  -- IDE and editor
  ".idea",
  ".venv",
  ".metadata",
  ".dart_tool",
  ".devcontainer",

  -- Build tools
  ".gradle",
  "gradle.bat",
  "heighliner",

  -- Temporary
  ".tmp",
  "tmp",

  -- Logs
  "sonr.log",
  "junit.xml",

  -- macOS
  ".DS_Store",
  ".DocumentRevisions-V100",
  ".Spotlight-V100",
  ".TemporaryItems",
  ".Trashes",
  ".fseventsd",
  ".timemachine",

  -- Templates
  "DISCUSSION_TEMPLATE",
  "ISSUE_TEMPLATE",

  -- License
  "LICENSE",
}

--- Patterns that should never be shown (pattern matching)
M.never_show_patterns = {
  "*DS_Store",
  ".obsidian",
  ".pkl-lsp",
  ".tsbuildinfo",
  "package-lock.json",
  ".prettierrc",
  "node_modules",
  ".DocumentRevisions-V100",
  ".Spotlight-V100",
  ".TemporaryItems",
  ".Trashes",
  ".fseventsd",
  ".editorconfig",
  "*.min.js",
  "*.lock",
  "*lock*",
  "*.lockb",
  "*.pulsar.go",
  "*.pb.gorm.go",
  "*.pb.gw.go",
  "*_templ.go",
  "*.tmp",
  "*.work.*",
  "*.sum",
  ".parcel-cache",
  "*.icns",
  "*.ico",
  "*.iml",
  "Icon?",
  "iCloud~",
  "com~",
  ".conform*",
  ".null-ls_*",
}

--- Directories to ignore when filtering files
M.ignored_directories = {
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
  ".worktrees",
}

local EMPTY = {}

--- Convert a glob (* and ? wildcards) to an anchored Lua pattern
--- @param glob string
--- @return string
local function glob_to_lua(glob)
  return "^" .. glob:gsub("[%%%.%(%)%+%-%^%$%[%]]", "%%%0"):gsub("%*", ".*"):gsub("%?", ".") .. "$"
end

--- @param globs string[]
--- @return string[]
local function compile_globs(globs)
  local out = {}
  for _, g in ipairs(globs) do
    out[#out + 1] = glob_to_lua(g)
  end
  return out
end

--- Find the git root for a directory by walking up (pure libuv, cached)
local root_cache = {} ---@type table<string, string|false>
--- @param dir string
--- @return string?
local function git_root(dir)
  local cached = root_cache[dir]
  if cached ~= nil then return cached or nil end
  local cur = dir
  while cur and cur ~= "" do
    if uv.fs_stat(cur .. "/.git") then
      root_cache[dir] = cur
      return cur
    end
    local parent = cur:match "(.+)/[^/]+$"
    if not parent or parent == cur then break end
    cur = parent
  end
  root_cache[dir] = false
  return nil
end

--- Read additional ignore patterns from the .rgignore file in the git root.
--- Cached per file and invalidated on mtime change. Safe in fast event contexts.
--- @param dir? string directory to resolve the git root from (defaults to cwd)
--- @return string[] patterns List of glob patterns from .rgignore
local rgignore_cache = {} ---@type table<string, {mtime: number, patterns: string[]}>
function M.read_rgignore(dir)
  local root = git_root(dir or uv.cwd())
  if not root then return EMPTY end
  local path = root .. "/.rgignore"
  local stat = uv.fs_stat(path)
  if not stat then return EMPTY end
  local cached = rgignore_cache[path]
  if cached and cached.mtime == stat.mtime.sec then return cached.patterns end
  local patterns = {}
  local file = io.open(path, "r")
  if file then
    for line in file:lines() do
      if line ~= "" and not line:match "^#" then
        patterns[#patterns + 1] = (line:gsub("^%./", ""))
      end
    end
    file:close()
  end
  rgignore_cache[path] = { mtime = stat.mtime.sec, patterns = patterns }
  return patterns
end

--- Get all hide patterns including rgignore
--- @param dir? string directory to resolve the git root from (defaults to cwd)
--- @return table patterns Combined list of all patterns to hide
function M.get_all_patterns(dir)
  return vim.list_extend(vim.list_extend({}, M.patterns), M.read_rgignore(dir))
end

--- Create a filter for snacks picker `transform` options.
--- Snacks contract: return `false` to DROP an item, `true`/`nil` to keep it
--- (returning nil keeps the item!). Runs per item in a fast event context,
--- so only pure Lua and libuv are used here.
--- @return fun(item: snacks.picker.finder.Item): boolean
function M.create_picker_filter()
  local static ---@type string[]? compiled static globs (lazy)
  local last_raw, last_rg = nil, EMPTY ---@type string[]?, string[]
  return function(item)
    local file = item and item.file
    if not file then return true end

    static = static or compile_globs(M.patterns)
    local raw = M.read_rgignore(item.cwd)
    if raw ~= last_raw then
      last_raw, last_rg = raw, compile_globs(raw)
    end

    -- Match every path segment (directories and basename) anchored,
    -- so `test` drops `test/foo.lua` but never `latest.md`.
    for seg in file:gmatch "[^/\\]+" do
      for _, pat in ipairs(static) do
        if seg:match(pat) then return false end
      end
      for _, pat in ipairs(last_rg) do
        if seg:match(pat) then return false end
      end
      for _, dirname in ipairs(M.ignored_directories) do
        if seg == dirname then return false end
      end
    end
    return true
  end
end

return M
