vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
})

-- Setup dependencies
require("nvim-web-devicons").setup({
  variant = "dark",
})

require("lualine").setup({
  options = {
    theme = "auto",
    icons_enabled = true,
  },
  sections = {
    lualine_b = {
      {
        require("micropython_nvim").statusline,
        cond = package.loaded["micropython_nvim"]
          and require("micropython_nvim").exists,
      },
    },
  },
})
