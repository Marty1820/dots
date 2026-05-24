vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("which-key").setup()
local wk = require("which-key")

wk.add({
  {
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer Local Keymaps (which-key)",
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
    { "<leader>w", "<cmd>w<cr>", desc = "Write" },
  },

  -- Diagnostics
  { "<leader>d", group = "+[D]iagnostics" },
  {
    "<leader>d[",
    function()
      vim.diagnostic.jump({ count = -1 })
    end,
    desc = "Go to previous diagnostic message",
  },
  {
    "<leader>d]",
    function()
      vim.diagnostic.jump({ count = 1 })
    end,
    desc = "Go to next diagnostic message",
  },
  { "<leader>dq", vim.diagnostic.setloclist, desc = "Open diagnostics list" },

  -- File
  { "<leader>f", group = "+[F]iles" },
  { "<leader>fn", "<cmd>enew<cr>", desc = "[N]ew File" },
  {
    "<leader>fb",
    function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "[F]ormat [b]uffer with LSP",
  },
  -- Telescope
  {
    "<leader>ff",
    function()
      require("telescope.builtin").find_files()
    end,
    desc = "Telescope find files",
  },
  {
    "<leader>fg",
    function()
      require("telescope.builtin").live_grep()
    end,
    desc = "Telescope live grep",
  },
  {
    "<leader><space>",
    function()
      require("telescope.builtin").buffers()
    end,
    desc = "Telescope buffers",
  },
  {
    "<leader>fh",
    function()
      require("telescope.builtin").help_tags()
    end,
    desc = "Telescope help tags",
  },

  -- LSP
  -- See `:help vim.lsp.*` for documentation on the below functions
  { "<leader>l", group = "+[L]SP" },
  { "<leader>lk", vim.lsp.buf.hover, desc = "Diagnostics pop-up" },
  { "<leader>ld", vim.lsp.buf.definition, desc = "[D]efinition" },
  { "<leader>lr", vim.lsp.buf.references, desc = "[R]eferences" },
  { "<leader>lc", vim.lsp.buf.code_action, desc = "[C]ode action" },

  -- Buffer
  { "<S-h>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
  { "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },

  -- MISC
  { "<leader>xl", "<cmd>lopen<cr>", desc = "Location List" },
  { "<leader>xq", "<cmd>copen<cr>", desc = "Quickfix List" },
  { "[q", "<cmd>cprev<cr>", desc = "Previous quickfix" },
  { "]q", "<cmd>cnext<cr>", desc = "Next quickfix" },

  -- Micropython
  { "<leader>m", group = "+[M]icropython" },
  { "<leader>mi", "<cmd>MPInit<cr>", desc = "Initialize project" },
  {
    "<leader>mI",
    "<cmd>MPInstall<cr>",
    desc = "Install project dependancies with uv",
  },
  { "<leader>ml", "<cmd>MPListDevices<cr>", desc = "List devices" },
  {
    "<leader>mp",
    "<cmd>MPRun<cr>",
    desc = "Run current buffer on device",
  },
  {
    "<leader>mu",
    "<cmd>MPUpload<cr>",
    desc = "MP Upload buffer to device",
  },
  { "<leader>mU", "<cmd>MPUploadAll<cr>", desc = "Upload folder to device" },
  { "<leader>mR", "<cmd>MPRepl<cr>", desc = "Open MicroPython REPL" },
  { "<leader>mr", "<cmd>MPReset<cr>", desc = "Soft reset device" },
  { "<leader>mh", "<cmd>MPHardReset<cr>", desc = "Hard reset device" },
})
