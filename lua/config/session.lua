--- Git-aware directory sessions on top of resession's `dirsession` store.
---
--- Session identity is `<worktree root>@<ref>`, so every git worktree gets its
--- own session (worktrees live in distinct directories) and every branch
--- inside a worktree gets its own layout. Detached HEAD pins to the short
--- commit; outside a repository the plain cwd is used, matching AstroNvim's
--- default dirsession naming.
---
--- resession sanitizes `/` and `:` in session names, so slashes in worktree
--- paths and branch names (`feat/foo`) are safe.
--- @module config.session

local M = {}

local DIR = "dirsession"

--- Run git in `cwd`; nil on failure or empty output.
--- @param cwd string
--- @param ... string git arguments
--- @return string?
local function git(cwd, ...)
  local cmd = { "git", "-C", cwd }
  for _, arg in ipairs { ... } do
    cmd[#cmd + 1] = arg
  end
  local out = vim.trim(vim.fn.system(cmd))
  if vim.v.shell_error ~= 0 or out == "" then return nil end
  return out
end

--- Session name for the current working directory.
--- @return string
function M.name()
  local cwd = vim.fn.getcwd()
  local root = git(cwd, "rev-parse", "--show-toplevel")
  if not root then return cwd end
  -- `branch --show-current` is empty on detached HEAD; an unborn branch in a
  -- fresh repo has no commit to fall back to.
  local ref = git(cwd, "branch", "--show-current")
    or git(cwd, "rev-parse", "--short", "HEAD")
    or "HEAD"
  return root .. "@" .. ref
end

--- Whether a saved session file exists for `name`.
--- @param name string
--- @return boolean
function M.exists(name)
  return vim.uv.fs_stat(require("resession.util").get_session_file(name, DIR)) ~= nil
end

--- Save the session for the current worktree/branch.
--- @param opts? table extra resession save options
function M.save(opts)
  require("resession").save(M.name(), vim.tbl_extend("force", { dir = DIR }, opts or {}))
end

--- Load the session for the current worktree/branch.
--- @param opts? table extra resession load options
function M.load(opts)
  require("resession").load(M.name(), vim.tbl_extend("force", { dir = DIR }, opts or {}))
end

--- Open the picker used when there is nothing to restore: git files inside a
--- repository, plain file search outside one.
local function pick_files()
  local snacks = require "snacks"
  local transform = require("config.ignore_patterns").create_picker_filter()
  if snacks.git.get_root() then
    snacks.picker.git_files { transform = transform }
  else
    snacks.picker.files { transform = transform }
  end
end

--- VimEnter entry point: restore this worktree/branch session, or fall back to
--- the file picker when none has been saved yet.
function M.restore()
  local name = M.name()
  if M.exists(name) then
    M.load { silence_errors = true }
  else
    -- defer so the picker opens after startup finished drawing the UI
    vim.schedule(pick_files)
  end
end

return M
