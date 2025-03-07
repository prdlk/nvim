local files = require "overseer.files"
local overseer = require "overseer"

---@type overseer.TemplateFileDefinition
local tmpl = {
  priority = 60,
  params = {
    args = { optional = true, type = "list", delimiter = " " },
    cwd = { optional = true },
  },
  builder = function(params)
    return {
      cmd = { "sh" },
      args = { "-c", table.concat(params.args, " && ") },
      cwd = params.cwd,
    }
  end,
}

---@param opts overseer.SearchParams
---@return string|nil
local function get_devbox_file(opts)
  return vim.fs.find("devbox.json", {
    upward = true,
    type = "file",
    path = opts.dir,
  })[1]
end

return {
  cache_key = function(opts) return get_devbox_file(opts) end,
  condition = {
    callback = function(opts)
      local devbox_file = get_devbox_file(opts)
      if not devbox_file then return false, "No devbox.json file found" end
      return true
    end,
  },
  generator = function(opts, cb)
    local devbox_file = get_devbox_file(opts)
    if not devbox_file then
      cb {}
      return
    end
    local data = files.load_json_file(devbox_file)
    local ret = {}
    if data.shell and data.shell.scripts then
      for k, v in pairs(data.shell.scripts) do
        table.insert(
          ret,
          overseer.wrap_template(
            tmpl,
            { name = string.format("devbox run %s", k) },
            { args = v, cwd = vim.fs.dirname(devbox_file) }
          )
        )
      end
    end
    cb(ret)
  end,
}
