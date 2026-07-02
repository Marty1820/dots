-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Tabs & Indentations
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Search
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse
vim.opt.mouse = "nvi"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Undo
vim.opt.undofile = true

-- Completion
vim.opt.completeopt = "menu,menuone,noselect"

-- Wrapping
vim.opt.whichwrap:append("<,>,h,l,[,]")

-- Yank Highlight
local highlight_group =
  vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
