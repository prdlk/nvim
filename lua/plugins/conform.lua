-- Python/JS formatting rules, plus the on-save pipeline: every safe LSP code
-- action (import organizing, fix-alls, quickfixes) runs first, then conform
-- formats. Both hang off conform's `format_on_save` hook, which is the only
-- place the relative order is guaranteed; the action pass itself lives in
-- config.lsp_code_actions.

---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Python: ruff sorts imports (I001, black-compatible isort profile by
      -- default), then black formats. Pinned here because the ruff and black
      -- subpacks each append their own chain (ruff_fix/ruff_format + black).
      -- black always emits 4-space indentation, so mixed tab/space indentation
      -- is normalized on save instead of surviving to raise TabError at runtime.
      if not opts.formatters_by_ft then opts.formatters_by_ft = {} end
      opts.formatters_by_ft.python = { "ruff_organize_imports", "black" }

      -- The pack's function returns nil when autoformat is toggled off
      -- (<Leader>uf buffer / <Leader>uF global), so one toggle governs the
      -- whole pipeline: no code actions and no formatting.
      local pack_format_on_save = opts.format_on_save
      opts.format_on_save = function(bufnr)
        -- NOT `f(bufnr) or f`: that resolves to the function itself when the
        -- call returns nil, and conform then gets a function as format opts
        local format = pack_format_on_save
        if type(format) == "function" then format = format(bufnr) end
        if not format then return end

        require("config.lsp_code_actions").apply(bufnr)

        -- Skip formatting JavaScript buffers (.js/.mjs/.cjs); the code actions
        -- above still run, and manual :Format / <Leader>lf still works.
        if vim.bo[bufnr].filetype == "javascript" then return end
        return format
      end
    end,
  },
}
