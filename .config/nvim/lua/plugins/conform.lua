return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>g",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			sh = { "shfmt" },
			python = { "black", "isort" },
			html = { "biome" },
			css = { "biome" },
			javascript = { "biome" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
		formatters = {
			shfmt = {
				append_args = { "-i", "2" },
			},
		},
	},
}
