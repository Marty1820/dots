-- Plugin Installation
vim.pack.add({
  "https://github.com/jim-at-jibba/micropython.nvim",
})

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugin configurations
require("plugins.colorscheme")
require("plugins.lualine")
require("plugins.mason")
require("plugins.telescope")
require("plugins.snacks")
require("plugins.autoclose")
