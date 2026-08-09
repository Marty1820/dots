vim.pack.add({
  { src = "https://github.com/folke/tokyonight.nvim" },
})

-- Configuration
require("tokyonight").setup({
  style = "night",
  lualine_bold = true,
})

-- Set Colorscheme
vim.cmd([[colorscheme tokyonight]])
