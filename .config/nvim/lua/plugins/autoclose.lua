vim.pack.add({
  "https://github.com/m4xshen/autoclose.nvim",
})

-- Autoclose setup
require("autoclose").setup({
  options = {
    disabled_filetypes = { "text", "markdown" },
    disable_when_touch = true,
    pair_spaces = true,
  },
})
