vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

-- Configuration
require("catppuccin").setup({
  flavour = "mocha",
  integrations = {
    mason = true,
    which_key = true,
  },
})

-- Set Colorscheme
vim.cmd([[colorscheme catppuccin-nvim]])
