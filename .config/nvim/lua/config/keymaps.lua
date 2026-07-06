vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim", version = "stable" },
})
require("which-key").setup()
local wk = require("which-key")

wk.add({
  -- Help
  {
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer Local Keymaps (which-key)",
  },

  -- General
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    { "<leader>q", "<cmd>q<cr>", desc = "Quit" },
    { "<leader>w", "<cmd>w<cr>", desc = "Write" },
  },

  -- Vim Commands
  { "<leader>v", group = "+[V]im Commands" },
  {
    "<leader>vu",
    function()
      vim.pack.update()
    end,
    desc = "Plugin Updates",
  },
  {
    "<leader>vr",
    function()
      -- Collect all plugins marked as inactive
      local inactive = vim
        .iter(vim.pack.get())
        :filter(function(pkg)
          return not pkg.active
        end)
        :map(function(pkg)
          return pkg.spec.name
        end)
        :totable()
      -- Early exit if nothing to remove
      if #inactive == 0 then
        vim.notify("No inactive plugins found", vim.log.levels.INFO)
        return
      end
      -- Track successful deletions
      local removed = 0
      for _, name in ipairs(inactive) do
        local ok, err = pcall(vim.pack.del, { name })
        if ok then
          removed = removed + 1
          vim.notify("Removed: " .. name, vim.log.levels.DEBUG)
        else
          vim.notify(
            "Failed: " .. name .. " (" .. tostring(err) .. ")",
            vim.log.levels.ERROR
          )
        end
      end
      -- Summary: report how many succedded vs attempted total
      vim.notify(
        string.format("Successfully removed %d/%d plugins", removed, #inactive),
        vim.log.levels.INFO
      )
    end,
    desc = "Remove Inactive Plugins",
  },

  -- Diagnostics
  { "<leader>d", group = "+[D]iagnostics" },
  {
    "<leader>d[",
    function()
      vim.diagnostic.jump({ count = -1 })
    end,
    desc = "Previous diagnostic",
  },
  {
    "<leader>d]",
    function()
      vim.diagnostic.jump({ count = 1 })
    end,
    desc = "Next diagnostic",
  },
  { "<leader>dq", vim.diagnostic.setloclist, desc = "Diagnostics list" },

  -- Files
  { "<leader>f", group = "+[F]iles" },
  { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
  {
    "<leader>fb",
    function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "Format buffer",
  },

  -- Telescope
  {
    "<leader>ff",
    function()
      require("telescope.builtin").find_files()
    end,
    desc = "Find files",
  },
  {
    "<leader>fg",
    function()
      require("telescope.builtin").live_grep()
    end,
    desc = "Live grep",
  },
  {
    "<leader>fh",
    function()
      require("telescope.builtin").help_tags()
    end,
    desc = "Help tags",
  },
  {
    "<leader><space>",
    function()
      require("telescope.builtin").buffers()
    end,
    desc = "Buffers",
  },

  -- LSP
  { "<leader>l", group = "+[L]SP" },
  { "<leader>lk", vim.lsp.buf.hover, desc = "Diagnostics pop-up" },
  { "<leader>ld", vim.lsp.buf.definition, desc = "Go to definition" },
  { "<leader>lr", vim.lsp.buf.references, desc = "References" },
  { "<leader>lc", vim.lsp.buf.code_action, desc = "Code action" },

  -- Buffers
  { "<S-h>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
  { "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },

  -- MISC
  { "<leader>xl", "<cmd>lopen<cr>", desc = "Location List" },
  { "<leader>xq", "<cmd>copen<cr>", desc = "Quickfix List" },
  { "[q", "<cmd>cprev<cr>", desc = "Prev quickfix" },
  { "]q", "<cmd>cnext<cr>", desc = "Next quickfix" },

  -- Micropython
  { "<leader>m", group = "+[M]icropython" },
  { "<leader>mi", "<cmd>MPInit<cr>", desc = "Init project" },
  { "<leader>ml", "<cmd>MPListDevices<cr>", desc = "List devices" },
  { "<leader>mL", "<cmd>MPListFiles<cr>", desc = "List files" },
  { "<leader>mp", "<cmd>MPRun<cr>", desc = "Run buffer" },
  { "<leader>mP", "<cmd>MPRunMain<cr>", desc = "Run main.py" },
  { "<leader>mu", "<cmd>MPUpload<cr>", desc = "Upload buffer" },
  { "<leader>mU", "<cmd>MPUploadAll<cr>", desc = "Upload folder" },
  { "<leader>mR", "<cmd>MPRepl<cr>", desc = "REPL" },
  { "<leader>mr", "<cmd>MPReset<cr>", desc = "Soft reset" },
  { "<leader>mh", "<cmd>MPHardReset<cr>", desc = "Hard reset" },
})
