--- Pre-save LSP code action pass: apply every action an attached server
--- advertises that is safe to run unattended (import organizing, fix-alls,
--- quickfixes), before conform formats the buffer.
---
--- Driven from conform's `format_on_save` hook (plugins/conform.lua) rather
--- than its own BufWritePre autocmd: that hook is the one place where the order
--- relative to formatting is guaranteed, and it is already gated by the
--- `<Leader>uf` / `<Leader>uF` autoformat toggles.
--- @module config.lsp_code_actions

-- Action kinds we apply unattended. Matches exact kinds and any subkinds via
-- "<kind>." prefix (LSP CodeActionKind is hierarchical).
--
-- Deliberately NOT the bare "source" umbrella: it covers non-idempotent
-- document rewrites (e.g. marksman's "Create Table of Contents").
-- Deliberately NOT "quickfix" either: those are diagnostic-scoped choices that
-- need a human. ruff, for one, offers "Disable rule for this line" as a
-- quickfix, so a save would silently paste `# noqa: I001` into the source.
local SAFE_KINDS = {
  "source.organizeImports",
  "source.fixAll",
}

local function is_safe_kind(kind)
  if not kind or kind == "" then return false end
  for _, safe in ipairs(SAFE_KINDS) do
    if kind == safe or vim.startswith(kind, safe .. ".") then return true end
  end
  return false
end

-- Pull the kinds a given client advertises support for, filtered to safe ones.
-- If the server returns no kinds list, fall back to the top-level SAFE_KINDS so
-- it gets the chance to satisfy a broad "only" filter.
local function safe_kinds_for(client)
  local provider = (client.server_capabilities or {}).codeActionProvider
  if not provider then return {} end
  local advertised = type(provider) == "table" and provider.codeActionKinds or nil
  if not advertised or #advertised == 0 then return vim.deepcopy(SAFE_KINDS) end
  local kinds = {}
  for _, k in ipairs(advertised) do
    if is_safe_kind(k) then table.insert(kinds, k) end
  end
  return kinds
end

-- Collect LSP-shaped diagnostics so quickfix actions have something to bind to.
local function lsp_diagnostics(bufnr)
  local out = {}
  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    if d.user_data and d.user_data.lsp then table.insert(out, d.user_data.lsp) end
  end
  return out
end

-- Servers are allowed to return an action with neither `edit` nor `command`,
-- carrying only `data` to be exchanged for the real edit via codeAction/resolve
-- (vtsls does exactly this for source.organizeImports). Without this step the
-- whole pass silently does nothing on those servers.
local function resolve(client, bufnr, action)
  if action.edit or type(action.command) == "table" then return action end
  if not vim.tbl_get(client.server_capabilities or {}, "codeActionProvider", "resolveProvider") then return action end
  local resp = client:request_sync("codeAction/resolve", action, 1000, bufnr)
  if resp and not resp.err and resp.result then return resp.result end
  return action
end

-- Servers may ignore context.only (LSP allows it), so re-filter the returned
-- actions by kind before applying. Kind-less actions are skipped: we asked for
-- specific kinds, so anything untagged is not provably safe.
local function apply_result(client, bufnr, result)
  if not result then return end
  for _, action in ipairs(result) do
    if is_safe_kind(action.kind) then
      action = resolve(client, bufnr, action)
      if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-8") end
      if type(action.command) == "table" then client:exec_cmd(action.command, { bufnr = bufnr }) end
    end
  end
end

local M = {}

--- Apply every safe code action advertised for `bufnr`, synchronously.
--- No-op for scratch/special buffers and for buffers no server serves.
--- @param bufnr integer
function M.apply(bufnr)
  if vim.bo[bufnr].buftype ~= "" then return end
  local clients = vim.lsp.get_clients { bufnr = bufnr, method = "textDocument/codeAction" }
  if #clients == 0 then return end
  local diagnostics = lsp_diagnostics(bufnr)
  for _, client in ipairs(clients) do
    local kinds = safe_kinds_for(client)
    if #kinds > 0 then
      local enc = client.offset_encoding or "utf-8"
      local params = vim.lsp.util.make_range_params(0, enc)
      params.context = { only = kinds, diagnostics = diagnostics, triggerKind = 2 }
      local resp = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
      if resp and not resp.err then apply_result(client, bufnr, resp.result) end
    end
  end
end

return M
