-- Plugin Installation
vim.pack.add({
  "https://github.com/Mofiqul/dracula.nvim",
  "https://github.com/elkowar/yuck.vim",
  "https://github.com/jim-at-jibba/micropython.nvim",
})

-- Set Colorscheme
vim.cmd([[colorscheme dracula]])

-- Load config modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugin configs
require("plugins.mason")
require("plugins.telescope")
require("plugins.lualine")
require("plugins.snacks")
require("plugins.autoclose")
