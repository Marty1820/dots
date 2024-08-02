return {
  {
    'nvim-telescope/telescope-ui-select.nvim',
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        pickers = {
          find_files = {
            find_command = {
              'rg',
              '--files',
              '--color=never',
              '--ignore',
              '--hidden',
              '-L',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown({}),
          },
        },
      })
      local builtin = require('telescope.builtin')
      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      require('telescope').load_extension('ui-select')
    end,
  },
}
