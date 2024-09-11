return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonInstallAll', 'MasonUpdate' },
    config = function()
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
        max_concurent_installers = 10,
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup()
    end,
    opts = {
      automatic_installation = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Diagnostic icons
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.INFO] = '󰙎',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.ERROR] = '',
          },
        },
        virtual_text = false,
        underline = true,
        update_in_insert = true,
      })
      -- Setup language servers.
      local lspconfig = require('lspconfig')
      lspconfig.bashls.setup({})
      lspconfig.cssls.setup({})
      lspconfig.html.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            telementry = {
              enable = false,
            },
          },
        },
      })
      lspconfig.marksman.setup({})
      lspconfig.pyright.setup({})
      lspconfig.yamlls.setup({
        settings = {
          redhat = {
            telementry = {
              enabled = false,
            },
          },
        },
      })
    end,
  },
}
