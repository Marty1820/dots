vim.pack.add({
  "https://github.com/Mofiqul/dracula.nvim",
})

-- Configuration
require("dracula").setup({
  show_end_of_buffer = true,
  lualine_bg_color = "#282A36",
  italic_comment = true,
})

-- Set Colorscheme
vim.cmd([[colorscheme dracula]])
