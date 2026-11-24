--- minuet-ai.nvim: ghost-text completion (virtualtext) in insert mode and
--- next-edit prediction (duet) in normal mode, served by the first reachable
--- provider of, in order:
---
---   1. Inception    FIM mercury-coder; duet: mercury-3 chat
---   2. Ollama       inkling-2-mini, local: what being offline lands on
---   3. OpenCode Go  deepseek-v4.1-flash
---   4. OpenRouter   deepseek/deepseek-v4.1-flash; duet: gemini-3.1-flash-lite
---
--- API keys come from the environment (fish's conf.d/secrets.fish); a
--- provider whose key is unset is skipped. `select` probes the providers in
--- order and points minuet at the first that answers: an authenticated GET
--- for the remote ones (OpenCode Go's usage meter must not be rate-limited),
--- Ollama's model list naming inkling-2-mini. It runs at setup and again on
--- InsertEnter / FocusGained once a minute has passed, so going offline
--- moves to Ollama by the next insert. Until a probe succeeds nothing is
--- auto-triggered (no request storm against a dead endpoint).
---
--- Every provider sets the same option keys, so switching never leaves
--- another provider's fields (thinking switches, headers) behind.
--- @module config.minuet

local M = {}

local LEETCODE_DIR = vim.fn.expand "~/Developer/github.com/prdlk/leetcode/work/"
local OLLAMA = "http://localhost:11434"
local FIM_TEMPLATE = require("minuet.config").default_fim_template

--- inkling-2-mini has no FIM (Ollama: "does not support insert") and its
--- chat template always reasons, unseen and slow, even at effort "none".
--- Raw /api/generate skips the template: the model just continues the code
--- before the cursor. Reshapes minuet's /completions body into that.
local function ollama_raw(data)
  local b = data.body
  data.body = {
    model = b.model,
    prompt = b.prompt,
    raw = true,
    stream = false,
    options = { num_predict = b.max_tokens, stop = b.stop },
  }
  return data
end

--- OpenCode Go routes by session and rejects generic clients: one stable
--- session id per Neovim, sent with a client user agent.
local opencode_session = ("nvim-%d-%d"):format(vim.fn.getpid(), os.time())
local function opencode_headers(data)
  data.headers["x-opencode-session"] = opencode_session
  data.headers["User-Agent"] = "minuet-ai.nvim"
  return data
end

---@class MinuetProvider
---@field label string
---@field key? string env var holding the API key; nil for Ollama
---@field probe string url
---@field ok fun(code: string, body: string): boolean
---@field settings table top-level minuet options
---@field completion { provider: string, options: table }
---@field duet table duet.provider_options.openai_compatible
---@field duet_timeout integer seconds

local function http_ok(code) return code == "200" end

---@type MinuetProvider[]
M.providers = {
  {
    label = "Inception (mercury-coder)",
    key = "INCEPTION_API_KEY",
    probe = "https://api.inceptionlabs.ai/v1/models",
    ok = http_ok,
    settings = { request_timeout = 3, context_window = 16000 },
    completion = {
      provider = "openai_fim_compatible",
      options = {
        name = "Inception",
        model = "mercury-coder",
        end_point = "https://api.inceptionlabs.ai/v1/fim/completions",
        api_key = "INCEPTION_API_KEY",
        stream = true,
        template = FIM_TEMPLATE,
        get_text_fn = {},
        optional = { max_tokens = 256, stop = { "\n\n" } },
        transform = {},
      },
    },
    duet = {
      name = "Inception",
      model = "mercury-3",
      end_point = "https://api.inceptionlabs.ai/v1/chat/completions",
      api_key = "INCEPTION_API_KEY",
      optional = { reasoning_effort = "none" },
      transform = {},
    },
    duet_timeout = 15,
  },
  {
    label = "Ollama (inkling-2-mini)",
    probe = OLLAMA .. "/api/tags",
    ok = function(code, body) return code == "200" and body:find('"inkling%-2%-mini') ~= nil end,
    -- local, ~20 tok/s: less context, more time
    settings = { request_timeout = 6, context_window = 6000 },
    completion = {
      provider = "openai_fim_compatible",
      options = {
        name = "Ollama",
        model = "inkling-2-mini",
        end_point = OLLAMA .. "/api/generate",
        api_key = "TERM", -- Ollama takes no key; minuet wants a set env var
        stream = false,
        template = { prompt = FIM_TEMPLATE.prompt, suffix = false },
        get_text_fn = { no_stream = function(json) return json.response end },
        optional = { max_tokens = 64, stop = { "\n\n" } },
        transform = { ollama_raw },
      },
    },
    -- next edits need the chat template, hidden reasoning included
    duet = {
      name = "Ollama",
      model = "inkling-2-mini",
      end_point = OLLAMA .. "/v1/chat/completions",
      api_key = "TERM",
      optional = { reasoning = { effort = "none" } },
      transform = {},
    },
    duet_timeout = 45,
  },
  {
    label = "OpenCode Go (deepseek-v4.1-flash)",
    key = "OPENCODE_GO_API_KEY",
    probe = "https://opencode.ai/inference/go/v1/usage",
    ok = function(code, body) return code == "200" and not body:find "rate%-limited" end,
    settings = { request_timeout = 3, context_window = 16000 },
    completion = {
      provider = "openai_compatible",
      options = {
        name = "OpenCode Go",
        model = "deepseek-v4.1-flash",
        end_point = "https://opencode.ai/inference/go/v1/chat/completions",
        api_key = "OPENCODE_GO_API_KEY",
        stream = true,
        optional = { max_tokens = 64, top_p = 0.9, thinking = { type = "disabled" } },
        transform = { opencode_headers },
      },
    },
    duet = {
      name = "OpenCode Go",
      model = "deepseek-v4.1-flash",
      end_point = "https://opencode.ai/inference/go/v1/chat/completions",
      api_key = "OPENCODE_GO_API_KEY",
      optional = { thinking = { type = "disabled" } },
      transform = { opencode_headers },
    },
    duet_timeout = 15,
  },
  {
    label = "OpenRouter (deepseek-v4.1-flash)",
    key = "OPENROUTER_API_KEY",
    probe = "https://openrouter.ai/api/v1/key",
    ok = http_ok,
    settings = { request_timeout = 3, context_window = 16000 },
    completion = {
      provider = "openai_compatible",
      options = {
        name = "OpenRouter",
        model = "deepseek/deepseek-v4.1-flash",
        end_point = "https://openrouter.ai/api/v1/chat/completions",
        api_key = "OPENROUTER_API_KEY",
        stream = true,
        optional = {
          max_tokens = 64,
          top_p = 0.9,
          reasoning = { effort = "none" },
          provider = { sort = "throughput" },
        },
        transform = {},
      },
    },
    duet = {
      name = "OpenRouter",
      model = "google/gemini-3.1-flash-lite",
      end_point = "https://openrouter.ai/api/v1/chat/completions",
      api_key = "OPENROUTER_API_KEY",
      optional = { reasoning = { effort = "none" }, provider = { sort = "throughput" } },
      transform = {},
    },
    duet_timeout = 15,
  },
}

local current ---@type MinuetProvider?
local reachable = false -- the last probe found a provider
local probing, last_probe = false, -math.huge
local warned = false -- "nothing reachable" shown since the last success

--- @param p MinuetProvider
local function usable(p) return not p.key or (vim.env[p.key] or "") ~= "" end

--- Point minuet's completion and duet at `p`.
--- @param p MinuetProvider
local function apply(p)
  local config = require("minuet").config
  for k, v in pairs(p.settings) do
    config[k] = v
  end
  config.provider = p.completion.provider
  local options = config.provider_options[p.completion.provider]
  for k, v in pairs(p.completion.options) do
    options[k] = v
  end
  config.duet.provider = "openai_compatible"
  config.duet.request_timeout = p.duet_timeout
  local duet = config.duet.provider_options.openai_compatible
  for k, v in pairs(p.duet) do
    duet[k] = v
  end
  if current and current ~= p then
    vim.notify("Using " .. p.label, vim.log.levels.INFO, { title = "Minuet" })
  end
  current = p
end

--- Probe providers from `i` on, applying the first that answers.
--- @param i integer
local function probe_from(i)
  local p = M.providers[i]
  if not p then
    probing, reachable = false, false
    -- once per outage, not on every re-probe while offline
    if not warned then
      warned = true
      vim.notify("No completion provider reachable", vim.log.levels.WARN, { title = "Minuet" })
    end
    return
  end
  if not usable(p) then return probe_from(i + 1) end
  local cmd = { "curl", "-sS", "-m", "2", "-w", "\n%{http_code}", p.probe }
  if p.key then vim.list_extend(cmd, { "-H", "Authorization: Bearer " .. vim.env[p.key] }) end
  vim.system(cmd, { text = true }, function(res)
    local body, code = (res.stdout or ""):match "^(.*)\n(%d+)$"
    vim.schedule(function()
      if res.code == 0 and code and p.ok(code, body) then
        probing, reachable, warned = false, true, false
        apply(p)
      else
        probe_from(i + 1)
      end
    end)
  end)
end

--- Re-pick the provider; at most once a minute unless `force`.
--- @param force? boolean
function M.select(force)
  local now = vim.uv.now()
  if probing or (not force and now - last_probe < 60000) then return end
  probing, last_probe = true, now
  probe_from(1)
end

--- Auto-trigger gate for both ghost text and next edits: a reachable
--- provider, a file buffer, not the LeetCode work directory, not toggled off.
--- @return boolean
function M.enabled()
  return reachable
    and not vim.g.minuet_disabled
    and vim.bo.buftype == ""
    and vim.api.nvim_buf_get_name(0):sub(1, #LEETCODE_DIR) ~= LEETCODE_DIR
end

function M.toggle()
  vim.g.minuet_disabled = not vim.g.minuet_disabled
  if vim.g.minuet_disabled then
    require("minuet.virtualtext").action.dismiss()
    require("minuet.duet").action.dismiss()
  end
  vim.notify(
    "AI completion " .. (vim.g.minuet_disabled and "off" or "on"),
    vim.log.levels.INFO,
    { title = "Minuet" }
  )
end

--- Insert-mode `key`: `action` while a ghost-text suggestion shows, else the
--- key's own meaning.
--- @param key string
--- @param action fun()
--- @return fun()
local function ghost(key, action)
  return function()
    if require("minuet.virtualtext").action.is_visible() then
      action()
    else
      vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
    end
  end
end

function M.setup()
  -- initial pick without the network, so the first requests already go
  -- somewhere plausible; the probe corrects it
  for _, p in ipairs(M.providers) do
    if usable(p) then
      require("minuet").setup(M.opts(p))
      current = p
      break
    end
  end
  M.select(true)

  local group = vim.api.nvim_create_augroup("minuet_config", { clear = true })
  vim.api.nvim_create_autocmd({ "InsertEnter", "FocusGained" }, {
    group = group,
    desc = "Re-pick the minuet provider (online/offline)",
    callback = function() M.select() end,
  })

  -- Next edits are predicted after an edit made in normal mode, or after
  -- leaving an insert that changed the buffer, once 600 ms pass without
  -- another change. Duet's own auto trigger is off: it debounces
  -- TextChangedI too, so an insert that pauses before <Esc> never
  -- predicts, and leaving insert mode raises no TextChanged.
  local timer = assert(vim.uv.new_timer())
  local function schedule(buf)
    timer:start(600, 0, vim.schedule_wrap(function()
      if
        buf == vim.api.nvim_get_current_buf()
        and vim.fn.mode() == "n"
        and vim.bo[buf].modifiable
        and vim.bo[buf].filetype ~= "python"
        and M.enabled()
      then
        require("minuet.duet").action.predict()
      end
    end))
  end
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(ev) vim.b[ev.buf].minuet_insert_tick = vim.b[ev.buf].changedtick end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    desc = "Predict the next edit after a changing insert",
    callback = function(ev)
      if vim.b[ev.buf].changedtick ~= vim.b[ev.buf].minuet_insert_tick then schedule(ev.buf) end
    end,
  })
  vim.api.nvim_create_autocmd("TextChanged", {
    group = group,
    desc = "Predict the next edit after a normal-mode change",
    callback = function(ev) schedule(ev.buf) end,
  })

  local vt = require("minuet.virtualtext").action
  local duet = require("minuet.duet").action
  local map = vim.keymap.set
  map("i", "<C-l>", ghost("<C-l>", vt.accept), { desc = "Accept AI suggestion" })
  map("i", "<C-w>", ghost("<C-w>", vt.accept_word), { desc = "Accept AI suggestion word" })
  map("i", "<C-h>", ghost("<C-h>", vt.dismiss), { desc = "Dismiss AI suggestion" })
  map("i", "<M-]>", vt.next, { desc = "Next AI suggestion (or request one)" })
  map("i", "<M-[>", vt.prev, { desc = "Previous AI suggestion (or request one)" })
  -- <C-l> is pane navigation in normal mode; it applies a next-edit
  -- preview while one shows
  map("n", "<C-l>", function()
    if duet.is_visible() then
      duet.apply()
    else
      require("config.pane_nav").navigate "right"
    end
  end, { desc = "Apply next edit, else move right a split" })
  map("n", "<C-a>e", duet.predict, { desc = "Predict next edit" })
  map("n", "<C-a>x", duet.dismiss, { desc = "Dismiss next edit" })
end

--- minuet.setup options with `p` as the provider.
--- @param p MinuetProvider
--- @return table
function M.opts(p)
  local gate = { M.enabled }
  local opts = vim.tbl_extend("force", {
    provider = p.completion.provider,
    provider_options = { [p.completion.provider] = p.completion.options },
    n_completions = 1,
    notify = "warn",
    enable_predicates = gate,
    virtualtext = {
      -- alongside blink's menu, as Supermaven's ghost text was
      show_on_completion_menu = true,
      auto_trigger_ft = { "*" },
      auto_trigger_ignore_ft = { "python" },
    },
    duet = {
      provider = "openai_compatible",
      request_timeout = p.duet_timeout,
      provider_options = { openai_compatible = p.duet },
    },
  }, p.settings)
  return opts
end

return M
