return {
  'nvim-lualine/lualine.nvim',
  event = "VeryLazy",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      section_separators = { left = '', right = '' },
      theme = 'catppuccin-nvim',
      globalstatus = true,
    },
    sections = {
      lualine_c = { "filename" },
      lualine_x = { "filetype" },
      lualine_y = { "os.date('%a %m/%d')" },
      lualine_z = { "lsp_status" },
    }
  }
}
