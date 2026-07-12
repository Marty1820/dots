vim.pack.add({
  {
    src = "https://github.com/mason-org/mason.nvim",
    version = "stable",
  },
  "https://github.com/neovim/nvim-lspconfig",
  {
    src = "https://github.com/mason-org/mason-lspconfig.nvim",
    version = "stable",
  },
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/stevearc/conform.nvim",
})

-- Install Mason and related plugins
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
  automatic_enable = true,
})

-- Install tools automatically
require("mason-tool-installer").setup({
  ensure_installed = {
    { "bash-language-server" },
    { "biome" },
    { "json-lsp" },
    { "css-lsp" },
    { "html-lsp" },
    { "lua-language-server" },
    { "prettierd" },
    { "ruff" },
    { "shfmt" },
    { "stylua" },
    { "tombi" },
    { "typescript-language-server" },
    { "yaml-language-server" },
  },
  auto_update = true,
  integrations = {
    ["mason-null-ls"] = false,
    ["mason-nvim-dap"] = false,
  },
})

-- LSP Setup
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- Conform setup
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    markdown = { "prettierd" },
    json = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
    yaml = { "prettierd" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
