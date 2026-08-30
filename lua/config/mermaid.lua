--- Mermaid syntax diagnostics for `mermaid` buffers and ```mermaid fences in
--- markdown/mdx.
---
--- Why not a language server: there is no packaged mermaid LSP (nothing on npm,
--- nothing in mason), and no client-side parser is trustworthy. The tree-sitter
--- mermaid grammar is stale enough to reject valid mermaid — `graph`, `style`,
--- `classDef`, `click`, `linkStyle`, `box`, `create`, `critical`, frontmatter
--- and `note for` all produce ERROR nodes (measured: 12 of 40 valid samples) —
--- so it is used for highlighting only, where a mis-parse costs colors instead
--- of a false error.
---
--- Instead mermaid's own parsers decide, hosted in a persistent node process
--- (`scripts/mermaid-validator.mjs`, protocol documented there). That process
--- needs `mermaid` + `jsdom` in a private workspace under `stdpath("data")`;
--- the first validation installs them with `npm` and reports progress. It exits
--- itself after five idle minutes so its ~300MB heap is not resident for the
--- whole session, and is respawned on demand.
--- @module config.mermaid

local M = {}

local NS = vim.api.nvim_create_namespace "mermaid"
local ROOT = vim.fs.joinpath(vim.fn.stdpath "data", "mermaid-validator")
local SCRIPT = vim.fs.joinpath(ROOT, "validator.mjs")
local SOURCE = vim.fs.joinpath(vim.fn.stdpath "config", "scripts", "mermaid-validator.mjs")
local IDLE_MS = 300000
local DEBOUNCE_MS = 400

-- pinned so a mermaid major bump cannot silently change what counts as valid
local PACKAGE_JSON = table.concat({
  "{",
  '  "name": "nvim-mermaid-validator",',
  '  "private": true,',
  '  "type": "module",',
  '  "dependencies": {',
  '    "jsdom": "^30.0.0",',
  '    "mermaid": "^11.12.0"',
  "  }",
  "}",
  "",
}, "\n")

--- Fenced blocks whose info string names mermaid. `@_lang` is not consumed by
--- the match, it only feeds the predicate.
local FENCE_QUERY = [[
  (fenced_code_block
    (info_string (language) @_lang)
    (code_fence_content) @content
    (#any-of? @_lang "mermaid" "mmd"))
]]

--- @class MermaidBlock
--- @field row integer 0-based buffer row where the block's first line lives
--- @field text string block source, as sent to the validator

--- @class MermaidResult
--- @field ok boolean
--- @field line? integer 1-based line within the block
--- @field col? integer 0-based UTF-16 column
--- @field message? string

--- @class MermaidBufState
--- @field timer uv.uv_timer_t debounce timer
--- @field seq integer validation pass counter, guards out-of-order responses
--- @field results table<string, MermaidResult> validated blocks, keyed by text

--- @type table<integer, MermaidBufState>
local buffers = {}

--- @type table<integer, fun(result: MermaidResult)> in-flight requests by id
local pending = {}
local next_id = 0

local job --- @type vim.SystemObj?
local tail = "" --- @type string incomplete stdout line
local deps = "unknown" --- @type "unknown"|"installing"|"ready"|"failed"
local deps_waiters = {} --- @type fun(ok: boolean)[]

--- @param msg string
--- @param level integer
local function notify(msg, level) vim.notify(msg, level, { title = "mermaid" }) end

--- @param path string
--- @return string?
local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read "a"
  file:close()
  return content
end

--- Write the workspace files, skipping writes that would change nothing. The
--- validator is copied out of the config rather than run in place so node
--- resolves `mermaid`/`jsdom` from the workspace's own `node_modules`.
--- @return boolean ok
local function write_workspace()
  local script = read_file(SOURCE)
  if not script then
    notify("validator script missing: " .. SOURCE, vim.log.levels.ERROR)
    return false
  end

  vim.fn.mkdir(ROOT, "p")
  for path, content in pairs { [SCRIPT] = script, [vim.fs.joinpath(ROOT, "package.json")] = PACKAGE_JSON } do
    if read_file(path) ~= content then
      local out = io.open(path, "w")
      if not out then
        notify("cannot write " .. path, vim.log.levels.ERROR)
        return false
      end
      out:write(content)
      out:close()
    end
  end
  return true
end

--- @return boolean
local function deps_installed()
  for _, dep in ipairs { "mermaid", "jsdom" } do
    if not vim.uv.fs_stat(vim.fs.joinpath(ROOT, "node_modules", dep, "package.json")) then return false end
  end
  return true
end

--- @param ok boolean
local function resolve_deps(ok)
  deps = ok and "ready" or "failed"
  local waiters = deps_waiters
  deps_waiters = {}
  for _, waiter in ipairs(waiters) do
    waiter(ok)
  end
end

--- Make sure the workspace exists with its dependencies installed, then call
--- `cb`. A failure is remembered: the install is not retried this session.
--- @param cb fun(ok: boolean)
local function ensure_deps(cb)
  if deps == "ready" then return cb(true) end
  if deps == "failed" then return cb(false) end
  deps_waiters[#deps_waiters + 1] = cb
  if deps == "installing" then return end
  deps = "installing"

  if vim.fn.executable "node" == 0 or vim.fn.executable "npm" == 0 then
    notify("node and npm are required for mermaid diagnostics", vim.log.levels.WARN)
    return resolve_deps(false)
  end
  if not write_workspace() then return resolve_deps(false) end
  if deps_installed() then return resolve_deps(true) end

  notify("installing mermaid validator dependencies...", vim.log.levels.INFO)
  vim.system(
    { "npm", "install", "--omit=dev", "--no-audit", "--no-fund", "--loglevel=error" },
    { cwd = ROOT, text = true },
    vim.schedule_wrap(function(result)
      if result.code == 0 and deps_installed() then
        notify("mermaid validator ready", vim.log.levels.INFO)
        return resolve_deps(true)
      end
      notify("npm install failed: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
      resolve_deps(false)
    end)
  )
end

--- @param line string one JSON response from the validator
local function handle_response(line)
  local ok, response = pcall(vim.json.decode, line)
  if not ok or type(response) ~= "table" or not response.id then return end
  local cb = pending[response.id]
  pending[response.id] = nil
  if cb then cb(response) end
end

--- @param err string?
--- @param data string?
local function on_stdout(err, data)
  if err or not data then return end
  tail = tail .. data
  while true do
    local newline = tail:find "\n"
    if not newline then break end
    local line = tail:sub(1, newline - 1)
    tail = tail:sub(newline + 1)
    if line ~= "" then vim.schedule(function() handle_response(line) end) end
  end
end

--- The validator writes to stderr only when it cannot run: a broken install, an
--- incompatible node, or a crash mid-session.
--- @param err string?
--- @param data string?
local function on_stderr(err, data)
  if err or not data or vim.trim(data) == "" then return end
  vim.schedule(function() notify(vim.trim(data), vim.log.levels.ERROR) end)
end

--- Responses for in-flight requests will never arrive; the affected blocks are
--- absent from the result cache, so the next pass re-queues them.
local function on_exit()
  job, tail, pending = nil, "", {}
end

--- Start the validator unless it is already running (it exits itself on idle).
--- @param cb fun(ok: boolean)
local function ensure_job(cb)
  if job then return cb(true) end
  ensure_deps(function(ok)
    if not ok then return cb(false) end
    if job then return cb(true) end
    local started, handle = pcall(
      vim.system,
      { "node", SCRIPT, "--idle-ms", tostring(IDLE_MS) },
      { cwd = ROOT, text = true, stdin = true, stdout = on_stdout, stderr = on_stderr },
      vim.schedule_wrap(on_exit)
    )
    if not started then
      notify("cannot start validator: " .. tostring(handle), vim.log.levels.ERROR)
      return cb(false)
    end
    job = handle
    cb(true)
  end)
end

--- @param text string
--- @param cb fun(result: MermaidResult)
local function request(text, cb)
  if not job then return end
  next_id = next_id + 1
  pending[next_id] = cb
  local id = next_id
  if not pcall(job.write, job, vim.json.encode { id = id, text = text } .. "\n") then pending[id] = nil end
end

--- Mermaid sources in `buf`: the whole buffer for a mermaid file, every
--- ```mermaid fence for markdown/mdx.
--- @param buf integer
--- @return MermaidBlock[]
local function blocks(buf)
  if vim.bo[buf].filetype == "mermaid" then
    return { { row = 0, text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") } }
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  -- mdx buffers (`markdown.mdx`) parse as markdown; anything else has no fences
  if not ok or not parser or parser:lang() ~= "markdown" then return {} end

  local query = vim.treesitter.query.parse("markdown", FENCE_QUERY)
  local found = {}
  for _, tree in ipairs(parser:parse(true)) do
    for id, node in query:iter_captures(tree:root(), buf) do
      if query.captures[id] == "content" then
        found[#found + 1] = { row = node:start(), text = vim.treesitter.get_node_text(node, buf) }
      end
    end
  end
  return found
end

--- The validator reports UTF-16 columns (javascript string indices).
--- @param line string
--- @param col integer
--- @return integer
local function byte_col(line, col)
  local ok, byte = pcall(vim.str_byteindex, line, "utf-16", col, false)
  if ok then return byte end
  return math.min(col, #line)
end

--- @param buf integer
--- @param block MermaidBlock
--- @param result MermaidResult
--- @return vim.Diagnostic
local function diagnostic(buf, block, result)
  local lnum = math.max(0, math.min(block.row + (result.line or 1) - 1, vim.api.nvim_buf_line_count(buf) - 1))
  local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
  local col = byte_col(line, result.col or 0)
  return {
    lnum = lnum,
    col = col,
    -- mermaid points at a single position; underlining the rest of the line
    -- shows which statement it choked on
    end_lnum = lnum,
    end_col = math.max(col, #line),
    severity = vim.diagnostic.severity.ERROR,
    source = "mermaid",
    message = result.message or "parse error",
  }
end

--- @param buf integer
--- @param found MermaidBlock[]
--- @param results table<string, MermaidResult>
local function publish(buf, found, results)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local diagnostics = {}
  for _, block in ipairs(found) do
    local result = results[block.text]
    if result and not result.ok then diagnostics[#diagnostics + 1] = diagnostic(buf, block, result) end
  end
  vim.diagnostic.set(NS, buf, diagnostics)
end

--- Validate every mermaid block in `buf` and replace its diagnostics.
---
--- Results are cached by block text, so editing one diagram in a document full
--- of them only re-validates that diagram. Passes are sequenced: a response
--- that arrives after a newer pass started is dropped instead of publishing
--- positions for text that has since moved.
--- @param buf? integer defaults to the current buffer
--- @param force? boolean ignore cached results
function M.validate(buf, force)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local state = buffers[buf]
  if not state or not vim.api.nvim_buf_is_valid(buf) then return end
  -- astrocore marks oversized buffers; re-parsing those on every keystroke
  -- costs more than the diagnostics are worth
  if vim.b[buf].large_buf then return end

  local found = blocks(buf)
  local previous = force and {} or state.results
  local results, queue, queued = {}, {}, {}
  for _, block in ipairs(found) do
    if vim.trim(block.text) ~= "" then
      local cached = previous[block.text]
      if cached then
        results[block.text] = cached
      elseif not queued[block.text] then
        queued[block.text] = true
        queue[#queue + 1] = block
      end
    end
  end

  state.seq = state.seq + 1
  state.results = results
  local seq = state.seq

  if #queue == 0 then return publish(buf, found, results) end

  ensure_job(function(ok)
    if not ok or buffers[buf] ~= state or state.seq ~= seq then return end
    local remaining = #queue
    for _, block in ipairs(queue) do
      request(block.text, function(result)
        if buffers[buf] ~= state or state.seq ~= seq then return end
        results[block.text] = result
        remaining = remaining - 1
        if remaining == 0 then publish(buf, found, results) end
      end)
    end
  end)
end

--- @param buf integer
local function detach(buf)
  local state = buffers[buf]
  if not state then return end
  buffers[buf] = nil
  state.timer:stop()
  state.timer:close()
  pcall(vim.api.nvim_del_augroup_by_name, "mermaid_buf_" .. buf)
  if vim.api.nvim_buf_is_valid(buf) then vim.diagnostic.reset(NS, buf) end
end

--- Start validating `buf` on changes.
---
--- Re-entrant: the driving FileType autocmd fires again on every `setfiletype`
--- and on `:edit` reloads, and an already-attached buffer just gets re-checked
--- (its content may have been re-read from disk).
--- @param buf integer
function M.attach(buf)
  if buffers[buf] then return M.validate(buf) end
  local state = { timer = assert(vim.uv.new_timer()), seq = 0, results = {} }
  buffers[buf] = state

  local group = vim.api.nvim_create_augroup("mermaid_buf_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    buffer = buf,
    desc = "Re-validate mermaid diagrams after edits",
    callback = function()
      state.timer:stop()
      state.timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function() M.validate(buf) end))
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = group,
    buffer = buf,
    desc = "Re-validate mermaid diagrams on read and write",
    callback = function() M.validate(buf) end,
  })
  -- `nvim_buf_attach`'s `on_detach` is not usable here: it also fires for a
  -- `:edit` reload, and its scheduled callback then tears down state that the
  -- reload's FileType has already re-attached
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = buf,
    desc = "Stop validating mermaid diagrams in a discarded buffer",
    callback = function() detach(buf) end,
  })

  M.validate(buf)
end

--- `:MermaidCheck` — re-validate the current buffer, ignoring cached results.
function M.check()
  local buf = vim.api.nvim_get_current_buf()
  if buffers[buf] then
    M.validate(buf, true)
  else
    M.attach(buf)
  end
end

return M
