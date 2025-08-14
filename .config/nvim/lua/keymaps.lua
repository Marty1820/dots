local wk = require("which-key")

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

wk.add({
	{
		mode = { "n", "v" }, -- NORMAL and VISUAL mode
		{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
		{ "<leader>w", "<cmd>w<cr>", desc = "Write" },
	},

	-- Diagnostics
	{ "<leader>d", group = "+[D]iagnostics" },
	{ "<leader>d[", vim.diagnostic.goto_prev, desc = "Go to previous diagnostic message" },
	{ "<leader>d]", vim.diagnostic.goto_next, desc = "Go to next diagnostic message" },
	{ "<leader>de", vim.diagnostic.open_float, desc = "Open floating diagnostic message" },
	{ "<leader>dq", vim.diagnostic.setloclist, desc = "Open diagnostics list" },

	-- File
	{ "<leader>f", group = "+[F]iles" },
	{ "<leader>fn", "<cmd>enew<cr>", desc = "[N]ew File" },
	{ "<leader>fp", "<cmd>Prettier<cr>", desc = "[F]ormat with [P]rettier" },

	-- LSP
	-- See `:help vim.lsp.*` for documentation on the below functions
	{ "<leader>l", group = "+[L]SP" },
	{ "<leader>lk", vim.lsp.buf.hover, desc = "Diagnostics pop-up" },
	{ "<leader>ld", vim.lsp.buf.definition, desc = "[D]efinition" },
	{ "<leader>lr", vim.lsp.buf.references, desc = "[R]eferences" },
	{ "<leader>lc", vim.lsp.buf.code_action, desc = "[C]ode action" },

	-- Buffer
	{ "<leader>b", group = "+[B]uffer" },
	{ "<leader>bh", "<cmd>TSBufEnable highlight<cr>", desc = "[H]ighlight enabled" },
	{ "<S-h>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
	{ "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },

	-- MISC
	{ "<leader>xl", "<cmd>lopen<cr>", desc = "Location List" },
	{ "<leader>xq", "<cmd>copen<cr>", desc = "Quickfix List" },
	{ "[q", "<cmd>cprev<cr>", desc = "Previous quickfix" },
	{ "]q", "<cmd>cnext<cr>", desc = "Next quickfix" },
})
