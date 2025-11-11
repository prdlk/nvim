--- Nap snippets integration
--- Provides keybinding to insert nap snippets using Snacks picker
--- @module plugins.nap

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    -- Add keybinding for nap snippets picker
    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}

    opts.mappings.n["<C-p>"] = {
      function()
        -- Get current buffer's filetype
        local filetype = vim.bo.filetype

        -- Map filetype to common language folder names
        local filetype_map = {
          typescript = "ts",
          javascript = "js",
          typescriptreact = "tsx",
          javascriptreact = "jsx",
          python = "py",
          go = "go",
          rust = "rs",
          lua = "lua",
          vim = "vim",
          sh = "sh",
          bash = "bash",
          zsh = "zsh",
          c = "c",
          cpp = "cpp",
          java = "java",
          ruby = "rb",
          php = "php",
          html = "html",
          css = "css",
          scss = "scss",
          json = "json",
          yaml = "yaml",
          toml = "toml",
          markdown = "md",
          sql = "sql",
          proto = "proto",
        }

        local lang = filetype_map[filetype] or filetype

        -- Get list of snippets using nap list
        local handle = io.popen("nap list 2>/dev/null")
        if not handle then
          vim.notify("Failed to execute 'nap list' command", vim.log.levels.ERROR)
          return
        end

        local output = handle:read("*a")
        handle:close()

        if not output or output == "" then
          vim.notify("No nap snippets found", vim.log.levels.WARN)
          return
        end

        -- Parse snippet names
        local all_snippets = {}
        for line in output:gmatch("[^\r\n]+") do
          if line and line ~= "" then
            table.insert(all_snippets, line)
          end
        end

        if #all_snippets == 0 then
          vim.notify("No nap snippets found", vim.log.levels.WARN)
          return
        end

        -- Filter snippets by language/filetype
        local filtered_snippets = {}
        local snippet_prefix = lang .. "/"

        for _, snippet in ipairs(all_snippets) do
          -- Match snippets that start with lang/ or contain .lang extension
          if snippet:match("^" .. vim.pesc(snippet_prefix))
            or snippet:match("%." .. vim.pesc(lang) .. "$")
            or snippet:match("/" .. vim.pesc(lang) .. "/")
          then
            table.insert(filtered_snippets, snippet)
          end
        end

        -- Use filtered snippets if found, otherwise show all
        local snippets = #filtered_snippets > 0 and filtered_snippets or all_snippets
        local prompt = #filtered_snippets > 0
          and "Select " .. lang .. " snippet:"
          or "Select nap snippet (no " .. lang .. " snippets found):"

        -- Use vim.ui.select to pick a snippet
        vim.ui.select(snippets, {
          prompt = prompt,
          format_item = function(item)
            return item
          end,
        }, function(choice)
          if not choice then return end

          -- Get the snippet content
          local content_handle = io.popen("nap " .. vim.fn.shellescape(choice) .. " 2>/dev/null")
          if not content_handle then
            vim.notify("Failed to read snippet: " .. choice, vim.log.levels.ERROR)
            return
          end

          local content = content_handle:read("*a")
          content_handle:close()

          if not content or content == "" then
            vim.notify("Snippet is empty or not found: " .. choice, vim.log.levels.WARN)
            return
          end

          -- Insert the snippet content at cursor position
          local lines = vim.split(content, "\n", { trimempty = false })
          -- Remove trailing empty line if present
          if lines[#lines] == "" then
            table.remove(lines)
          end

          local cursor = vim.api.nvim_win_get_cursor(0)
          local row = cursor[1]
          local col = cursor[2]

          -- Insert the lines
          vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)

          -- Move cursor to end of inserted text
          local new_row = row + #lines - 1
          local new_col = #lines[#lines]
          if #lines == 1 then
            new_col = col + new_col
          end
          vim.api.nvim_win_set_cursor(0, { new_row, new_col })

          vim.notify("Inserted snippet: " .. choice, vim.log.levels.INFO)
        end)
      end,
      desc = "Insert nap snippet",
    }
  end,
}
