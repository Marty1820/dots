-- Install Plugins
vim.pack.add({
	{ src = "https://github.com/Mofiqul/dracula.nvim" },
	{ src = "https://github.com/m4xshen/autoclose.nvim" },
	{ src = "https://github.com/elkowar/yuck.vim" },

	-- lualine
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },

	-- Micropython
	{ src = "https://github.com/jim-at-jibba/micropython.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },

	-- WhichKey
	{ src = "https://github.com/folke/which-key.nvim" },

	-- Mason
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },

	-- Telescope
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
})

-- Default options for nvim
require("vim-opts")

-- Simple config setups
vim.cmd.colorscheme("dracula")
require("autoclose").setup({
	opts = {
		disabled_filetypes = { "text", "markdown" },
		disable_when_touch = true,
		pair_spaces = true,
	},
})
require("lualine").setup({
	opts = {
		theme = "dracula-nvim",
	},
})
-- Which-Key
require("which-key").setup()
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
require("keymaps")

-- More complex configs get their own file
require("plugins.telescope")
require("plugins.mason")
