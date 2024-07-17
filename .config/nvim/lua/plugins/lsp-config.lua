return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
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
      lspconfig.lua_ls.setup({})
      lspconfig.marksman.setup({})
      lspconfig.pyre.setup({})
      lspconfig.pyright.setup({})
      lspconfig.yamlls.setup({})
    end,
  },
}
