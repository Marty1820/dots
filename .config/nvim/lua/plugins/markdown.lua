return {
  'MeanderingProgrammer/render-markdown.nvim',
  opts = {
    file_types = { 'markdown', 'norg', 'rmd', 'org' },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown', 'norg', 'rmd', 'org' },
  config = function(_, opts)
    require('render-markdown').setup(opts)
  end,
}
