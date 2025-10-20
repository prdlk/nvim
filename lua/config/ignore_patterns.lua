--- Shared ignore patterns for file explorers and pickers
--- This module provides a centralized list of patterns to ignore across
--- neotree, telescope, snacks.picker, and other file browsing tools.
--- @module config.ignore_patterns

local M = {}

--- Core ignore patterns used across the configuration
--- These patterns use glob syntax (* for wildcards)
M.patterns = {
  -- Build artifacts and generated files
  ".github",
  "chain_*.json",
  "*.pb.go",
  "*.pkl.go",
  "*.pulsar.go",
  "*.pb.gorm.go",
  "*.pb.gw.go",
  "*_templ.go",
  "*_mock.go",
  "*_integration.go",
  "*_test.go",

  -- Configuration files
  "*config.*.js",
  "*config.js",
  "deps.mjs",
  ".parcelrc",
  "worker-configuration.d.ts",
  "wrangler.jsonc",
  "biome*",
  ".cz.toml",
  ".editorconfig",
  ".gitpod.*",
  "cspell.*",

  -- Documentation
  "*_query_docs.md",
  "*_tx_docs.md",
  "readme.md",
  "CLAUDE*",

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
  ".aider.tags.cache.v4",
  ".aider.tags.cache.v3",
  ".aider.chat.history.md",
  ".aider.input.history",
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

  -- Dependencies
  "node_modules",

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
  ".aider.tags.cache.v4",
  "*.iml",
  "Icon?",
  "iCloud~",
  "com~",
  "*.icns",
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
}

--- Read additional ignore patterns from .rgignore file in git root
--- @return table patterns List of patterns from .rgignore
function M.read_rgignore()
  local patterns = {}
  local current_file = vim.fn.expand "%:p"
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  if current_dir == "" then current_dir = vim.fn.getcwd() end

  local git_root =
    vim.fn.systemlist("cd " .. vim.fn.shellescape(current_dir) .. " && git rev-parse --show-toplevel 2>/dev/null")[1]

  if git_root and git_root ~= "" and not git_root:match "^fatal:" then
    local rgignore_path = git_root .. "/.rgignore"
    local file = io.open(rgignore_path, "r")

    if file then
      for line in file:lines() do
        if line ~= "" and not line:match "^#" then
          line = line:gsub("^%./", "")
          table.insert(patterns, line)
        end
      end
      file:close()
    end
  end

  return patterns
end

--- Get all hide patterns including rgignore
--- @return table patterns Combined list of all patterns to hide
function M.get_all_patterns()
  local rgignore_patterns = M.read_rgignore()
  return vim.list_extend(vim.list_extend({}, M.patterns), rgignore_patterns)
end

--- Create a file filter function for pickers
--- @return function filter Function that filters files based on ignore patterns
function M.create_picker_filter()
  return function(item)
    if not item or not item.file then return item end

    local file = item.file
    local basename = vim.fn.fnamemodify(file, ":t")
    local dir = vim.fn.fnamemodify(file, ":h:t")

    -- Check against all patterns
    local all_patterns = M.get_all_patterns()
    for _, pattern in ipairs(all_patterns) do
      local lua_pattern = pattern:gsub("%.", "%%."):gsub("%*", ".*"):gsub("%?", ".")
      if basename:match("^" .. lua_pattern .. "$") or file:match(lua_pattern) then return nil end
    end

    -- Check ignored directories
    for _, ignored in ipairs(M.ignored_directories) do
      if dir == ignored or file:match("/" .. ignored .. "/") then return nil end
    end

    return item
  end
end

return M
