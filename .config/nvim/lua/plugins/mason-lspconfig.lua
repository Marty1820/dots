return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = { "lua_ls" },
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				ensure_installed = { "prettier", "black" },
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
				max_concurent_installers = 5,
			},
		},
		{ "neovim/nvim-lspconfig" },
	},
}
