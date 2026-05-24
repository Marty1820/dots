-- Install Plugins
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

	-- WhichKey
	"https://github.com/folke/which-key.nvim",

	-- Mason
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason-lspconfig.nvim",

	-- Telescope
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "*" },
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
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
				cond = package.loaded["micropython_nvim"] and require("micropython_nvim").exists,
			},
		},
	},
})

-- snacks.nvim
require("snacks").setup()

-- which-key.nvim
require("which-key").setup()
require("keymaps")

-- More complex configs get their own file
-- LSP configs
require("plugins.mason")
-- Telescope
require("plugins.telescope")
