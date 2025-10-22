--- Template.nvim integration for quick file scaffolding
--- Provides templates for Cosmos SDK, Protobuf, and Vite+Cloudflare development
--- @module plugins.template

---@type LazySpec
return {
  "glepnir/template.nvim",
  cmd = { "Template", "TemProject" },
  dependencies = { "folke/snacks.nvim" },
  config = function()
    local template = require "template"

    -- Setup template.nvim
    template.setup {
      temp_dir = vim.fn.stdpath "config" .. "/templates",
      author = "Prad",
      email = "prad@sonr.io",
    }

    -- Custom template picker using Snacks
    vim.api.nvim_create_user_command("TemplateSnacks", function(opts)
      local temp_dir = vim.fn.stdpath "config" .. "/templates"
      local current_ft = vim.bo.filetype

      -- Find all template files
      local template_files = vim.fn.globpath(temp_dir, "**/*", false, true)

      -- Filter and format templates
      local templates = {}
      for _, file in ipairs(template_files) do
        if vim.fn.isdirectory(file) == 0 then
          local filename = vim.fn.fnamemodify(file, ":t")
          local relative_path = vim.fn.fnamemodify(file, ":~:.")
          local category = vim.fn.fnamemodify(file, ":h:t")

          -- Extract filetype from template
          local ext = vim.fn.fnamemodify(file, ":e")
          if ext == "tpl" then
            -- Read first line to get filetype marker
            local first_line = vim.fn.readfile(file, "", 1)[1] or ""
            ext = first_line:match "^;; (%w+)" or ext
          end

          -- Filter by current filetype if specified
          local should_include = true
          if opts.args == "" and current_ft ~= "" then
            -- Only filter if we have a current filetype and no args
            should_include = ext == current_ft or ext == "tpl"
          end

          if should_include then
            table.insert(templates, {
              text = string.format("[%s] %s", category, filename),
              path = file,
              filename = filename,
            })
          end
        end
      end

      if #templates == 0 then
        vim.notify("No templates found", vim.log.levels.WARN)
        return
      end

      -- Use Snacks picker
      require("snacks").picker.pick {
        items = templates,
        format = function(item) return item.text end,
        confirm = function(item)
          if not item then return end

          -- Read template content
          local content = vim.fn.readfile(item.path)

          -- Process template variables
          local processed = {}
          local needs_variable = false
          local variable_name = nil

          for _, line in ipairs(content) do
            -- Skip filetype marker line
            if not line:match "^;; %w+" then
              -- Check for variable placeholder
              if line:match "{{_variable_}}" and not variable_name then
                needs_variable = true
              end
              table.insert(processed, line)
            end
          end

          -- Prompt for variable if needed
          if needs_variable then
            require("snacks").input({ prompt = "Variable name:" }, function(input)
              if not input then return end
              variable_name = input

              -- Replace variable in content
              for i, line in ipairs(processed) do
                processed[i] = line:gsub("{{_variable_}}", variable_name)
              end

              -- Insert template
              insert_template(processed)
            end)
          else
            insert_template(processed)
          end
        end,
      }
    end, { nargs = "?", desc = "Open template picker" })

    -- Helper function to insert template
    function insert_template(lines)
      local cursor_line = nil
      local processed = {}

      for i, line in ipairs(lines) do
        -- Replace template markers
        line = line:gsub("{{_date_}}", os.date "%Y-%m-%d %H:%M:%S")
        line = line:gsub("{{_author_}}", "Prad")
        line = line:gsub("{{_email_}}", "prad@sonr.io")
        line = line:gsub("{{_file_name_}}", vim.fn.expand "%:t:r")
        line = line:gsub("{{_upper_file_}}", vim.fn.expand("%:t:r"):upper())

        -- Convert snake_case to CamelCase
        local file_name = vim.fn.expand "%:t:r"
        local camel_case = file_name:gsub("_(%w)", function(c) return c:upper() end)
        camel_case = camel_case:gsub("^%w", string.upper)
        line = line:gsub("{{_camel_case_file_}}", camel_case)

        -- Handle lua expressions
        line = line:gsub("{{_lua:(.-)_}}", function(expr)
          local func, err = load("return " .. expr)
          if func then
            local ok, result = pcall(func)
            if ok then return tostring(result) end
          end
          return ""
        end)

        -- Track cursor position
        if line:match "{{_cursor_}}" then
          cursor_line = i
          line = line:gsub("{{_cursor_}}", "")
        end

        table.insert(processed, line)
      end

      -- Insert lines at cursor
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, processed)

      -- Set cursor position if marker found
      if cursor_line then
        vim.api.nvim_win_set_cursor(0, { row + cursor_line - 1, 0 })
      end
    end
  end,
}
