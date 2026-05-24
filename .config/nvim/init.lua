-- Install Simple Plugins
-- Complex are in their own files
vim.pack.add({
  "https://github.com/Mofiqul/dracula.nvim",
  "https://github.com/m4xshen/autoclose.nvim",
  "https://github.com/elkowar/yuck.vim",

  -- lualine
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",

  -- Micropython
  "https://github.com/folke/snacks.nvim",
  "https://github.com/jim-at-jibba/micropython.nvim",
})

-- Default options for nvim
require("vim-opts")

-- Simple config setups
-- dracula.nvim
vim.cmd([[colorscheme dracula]])

-- autoclose.nvim
require("autoclose").setup({
  options = {
    disabled_filetypes = { "text", "markdown" },
    disable_when_touch = true,
    pair_spaces = true,
  },
})

-- lualine.nvim
require("nvim-web-devicons").setup({
  variant = "dark",
})
require("lualine").setup({
  options = {
    theme = "dracula-nvim",
  },
  sections = {
    lualine_b = {
      {
        require("micropython_nvim").statusline,
        cond = package.loaded["micropython_nvim"]
          and require("micropython_nvim").exists,
      },
    },
  },
})

-- snacks.nvim
require("snacks").setup()

-- More complex configs get their own file
-- LSP configs
require("plugins.mason")
-- Telescope
require("plugins.telescope")
-- which-key.nvim install and keymap configs
require("keymaps")
