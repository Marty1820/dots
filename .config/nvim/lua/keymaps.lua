-- [[ Basic Keymaps ]]
local wk = require('which-key')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

wk.add({
  -- Keymaps for better default experience
  -- See `:help vim.keymap.set()`
  {
    mode = { 'n', 'v' },
    { '<Space>',   '<Nop>',      { silent = true } },
    { '<leader>q', '<cmd>q<cr>', desc = 'Quit' },
    { '<leader>w', '<cmd>w<cr>', desc = 'Write' },
  },

  -- Diagnostics
  { '<leader>d',  group = '+[D]iagnostics' },
  { '<leader>d[', vim.diagnostic.goto_prev,                  desc = 'Go to previous diagnostic message' },
  { '<leader>d]', vim.diagnostic.goto_next,                  desc = 'Go to next diagnostic message' },
  { '<leader>de', vim.diagnostic.open_float,                 desc = 'Open floating diagnostic message' },
  { '<leader>dq', vim.diagnostic.setloclist,                 desc = 'Open diagnostics list' },

  -- Buffer
  { '<leader>b',  group = '+[B]uffer' },
  { '<leader>bh', '<cmd>TSBufEnable highlight<cr>',          desc = '[H]ighlight enabled' },
  { '<S-h>',      '<cmd>bprevious<cr>',                      desc = 'Previous buffer' },
  { '<S-l>',      '<cmd>bnext<cr>',                          desc = 'Next buffer' },

  -- File
  { '<leader>f',  group = '+[F]iles' },
  { '<leader>fn', '<cmd>enew<cr>',                           desc = '[N]ew File' },
  { '<leader>ff', vim.lsp.buf.format,                        desc = '[F]ormat [F]ile' },
  { '<leader>fp', '<cmd>Prettier<cr>',                       desc = '[F]ormat with [P]rettier' },
  -- See `:help telescope.builtin`
  { '<leader>fr', '<cmd>Telescope oldfiles<cr>',             desc = '[F]ind [R]ecent files' },
  { '<leader>fg', '<cmd>Telescope git_files<cr>',            desc = '[F]ind [G]it files' },
  { '<leader>fw', '<cmd>%s/\\s\\+$//e<cr>',                  desc = '[F]ormat [W]hitespace' },

  -- Search
  { '<leader>s',  group = '+[S]earch' },
  { '<leader>sf', '<cmd>Telescope find_files<cr>',           desc = '[S]earch [F]iles' },
  { '<leader>sh', '<cmd>Telescope help_tags<cr>',            desc = '[S]earch [H]elp' },
  { '<leader>sw', '<cmd>Telescope grep_string<cr>',          desc = '[S]earch [W]ord' },
  { '<leader>sg', '<cmd>Telescope live_grep<cr>',            desc = '[S]earch [G]rep' },
  { '<leader>sd', '<cmd>Telescope diagnostics<cr>',          desc = '[S]earch [D]iagnostics' },
  { '<leader>sr', '<cmd>Telescope resume<cr>',               desc = '[S]earch [R]esume' },

  -- LSP
  -- See `:help vim.lsp.*` for documentation on the below functions
  { '<leader>l',  group = '+[L]SP' },
  { '<leader>lk', vim.lsp.buf.hover,                         desc = 'Diagnostics pop-up' },
  { '<leader>ld', vim.lsp.buf.definition,                    desc = '[D]efinition' },
  { '<leader>lr', vim.lsp.buf.references,                    desc = '[R]eferences' },
  { '<leader>lc', vim.lsp.buf.code_action,                   desc = '[C]ode action' },

  -- Neotree
  { '<leader>n',  group = '+[N]eotree' },
  { '<leader>nn', '<cmd>Neotree filesystem reveal left<cr>', desc = 'Open Neotree' },
  { '<leader>nb', '<cmd>Neotree buffers reveal float<cr>',   desc = 'Neotree [b]uffers' },

  -- MISC
  { '<leader>xl', '<cmd>lopen<cr>',                          desc = 'Location List' },
  { '<leader>xq', '<cmd>copen<cr>',                          desc = 'Quickfix List' },
  { '[q',         '<cmd>cprev<cr>',                          desc = 'Previous quickfix' },
  { ']q',         '<cmd>cnext<cr>',                          desc = 'Next quickfix' },
})

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
