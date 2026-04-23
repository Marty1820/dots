return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"lua_ls", -- stylua
			"ruff", -- for python
			"bashls", -- shfmt
			"html", -- prettierd
			"cssls", -- prettierd
			"ts_ls", -- biome
		},
		-- Add this to your lspconfig setup or global config
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		}),
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
				max_concurent_installers = 4,
			},
		},
		{ "neovim/nvim-lspconfig" },
	},
}
