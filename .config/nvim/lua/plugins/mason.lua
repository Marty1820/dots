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
})

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

require("mason-tool-installer").setup({
  ensure_installed = {
    { "bash-language-server" },
    { "biome" },
    { "css-lsp" },
    { "html-lsp" },
    { "lua-language-server" },
    { "prettierd" },
    { "ruff" },
    { "shfmt" },
    { "stylua" },
    { "typescript-language-server" },
    { "yaml-language-server" },
  },
  auto_update = true,
  integrations = {
    ["mason-null-ls"] = false,
    ["mason-nvim-dap"] = false,
  },
})

--- LSP Settings
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- Autoformat code when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
