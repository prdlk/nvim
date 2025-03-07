-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

require("telescope").setup {
  pickers = {
    oldfiles = {
      cwd_only = true,
    },
  },
}

require("overseer").setup {
  strategy = {
    "toggleterm",
    use_shell = false,
    size = vim.o.columns * 0.25,
    auto_scroll = true,
    close_on_exit = false,
    quit_on_exit = "success",
    open_on_start = true,
    hidden = true,
  },
}

require("lspconfig").jsonls.setup {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}

require("lspconfig").yamlls.setup {
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}
