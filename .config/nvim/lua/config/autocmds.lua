-- Create a group for auto commands to clear them together if needed
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank (moved from options.lua for better organization)
local yank_group = augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Auto-create directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    if vim.fn.isdirectory(vim.fn.fnamemodify(args.file, ":p:h")) == 0 then
      vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local cursor_pos = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", cursor_pos)
  end,
})

-- Autoformat buffer on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
