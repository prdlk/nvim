--- Python: interpreter resolution for basedpyright.
---
--- The astrocommunity basedpyright subpack pins `python.pythonPath` to
--- `exepath "python"`, i.e. the system interpreter. Builtins and the stdlib
--- (`enumerate`, `collections.Counter`, ...) come from basedpyright's bundled
--- typeshed either way, but third-party imports only resolve — and only
--- complete — when the server points at the environment that has them, which
--- for a uv/poetry/venv project is the project's own virtualenv.
---
--- Resolution order: activated environment ($VIRTUAL_ENV / $CONDA_PREFIX) ->
--- a virtualenv inside the LSP root -> system python3.
--- `<Leader>lv` (venv-selector, from the base pack) still overrides at runtime.
--- @module plugins.python

local VENV_DIRS = { ".venv", "venv", "env" }
local ROOT_MARKERS = { "pyproject.toml", "uv.lock", "setup.py", "setup.cfg", "requirements.txt", ".git" }

--- @param path string? candidate interpreter
--- @return string? path when it is an executable file
local function executable(path)
  if not path or path == "" then return nil end
  local stat = vim.uv.fs_stat(path)
  if stat and stat.type == "file" and vim.fn.executable(path) == 1 then return path end
  return nil
end

--- @param root string? project root
--- @return string interpreter absolute path or bare name
local function python_path(root)
  local activated = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  local found = activated and executable(activated .. "/bin/python")
  if found then return found end

  if root then
    for _, dir in ipairs(VENV_DIRS) do
      found = executable(root .. "/" .. dir .. "/bin/python")
      if found then return found end
    end
  end

  return executable(vim.fn.exepath "python3") or "python3"
end

local warned = {} ---@type table<string, true> roots already warned about

--- A locked project with no virtualenv checked out resolves against the system
--- interpreter, where its dependencies are missing. That reads as "the LSP is
--- broken" rather than "nothing is installed", so say it out loud once.
--- @param root string?
--- @param interpreter string
local function warn_unsynced_project(root, interpreter)
  if not root or warned[root] or interpreter:find(root, 1, true) then return end
  local lock = vim.uv.fs_stat(root .. "/uv.lock") or vim.uv.fs_stat(root .. "/poetry.lock")
  if not lock then return end
  warned[root] = true
  vim.schedule(
    function()
      vim.notify(
        ("basedpyright: no virtualenv in %s, using %s.\nRun `uv sync` for third-party completions.")
          :format(vim.fn.fnamemodify(root, ":~"), interpreter),
        vim.log.levels.WARN
      )
    end
  )
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  optional = true,
  ---@type AstroLSPOpts
  opts = {
    config = {
      basedpyright = {
        before_init = function(_, config)
          local root = config.root_dir or vim.fs.root(0, ROOT_MARKERS)
          local interpreter = python_path(root)
          warn_unsynced_project(root, interpreter)
          config.settings = vim.tbl_deep_extend(
            "force",
            config.settings or {},
            { python = { pythonPath = interpreter } }
          )
        end,
      },
    },
  },
}
