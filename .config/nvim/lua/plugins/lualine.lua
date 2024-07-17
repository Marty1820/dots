return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      -- See `:help lualine.txt`
      options = {
        theme = 'dracula-nvim',
      },
    })
  end,
}
