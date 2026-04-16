return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format()
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			sh = { "shfmt" },
			python = { "black", "isort" }, -- Or just "ruff"
			javascript = { "biome" },
			typescript = { "biome" },
			html = { "biome" },
			css = { "biome" },
			lua = { "stylua" },
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
	},
	dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason is a dep
	config = function(_, opts)
		require("conform").setup(opts)
		-- Optional: Auto-install formatters via Mason if missing
		require("mason").setup()
		require("mason-tool-installer").setup({ ensure_installed = { "shfmt", "black", "biome", "stylua" } })
	end,
}
