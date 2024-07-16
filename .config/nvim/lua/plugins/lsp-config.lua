return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup()
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      }
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      auto_install = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      -- Diagnostic fixs
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
      lspconfig.lua_ls.setup({})
      lspconfig.marksman.setup({})
      lspconfig.pyre.setup({})
      lspconfig.pyright.setup({})
      lspconfig.yamlls.setup({})
    end,
  },
}
