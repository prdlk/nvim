-- Run all safe LSP code actions advertised by attached servers before save,
-- then let conform format. The astrocommunity conform-nvim pack wires up
-- format_on_save; this just adds the pre-save code-action pass.

-- Action kinds we consider safe to apply on save. Matches exact kinds and
-- any subkinds via "<kind>." prefix (LSP CodeActionKind is hierarchical).
local SAFE_KINDS = {
  "source",
  "quickfix",
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

local function apply_result(client, bufnr, result)
  if not result then return end
  for _, action in ipairs(result) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-8")
    end
    if type(action.command) == "table" then
      client:exec_cmd(action.command, { bufnr = bufnr })
    end
  end
end

local function apply_safe_actions(bufnr)
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

---@type LazySpec
return {
  "stevearc/conform.nvim",
  init = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("user_lsp_safe_actions", { clear = true }),
      desc = "Apply all safe LSP code actions (source.*, quickfix) before save",
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then return end
        if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then return end
        apply_safe_actions(args.buf)
      end,
    })
  end,
}
