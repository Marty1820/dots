require("mason").setup({
  max_concurent_installers = 4,
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls", -- stylua
    "ruff", -- for python
    "bashls", -- shfmt
    "html", -- prettierd
    "cssls", -- prettierd
    "ts_ls", -- biome
    "yamlls", -- prettierd
  },
  automatic_enable = true,
})

-- Autoformat code when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
