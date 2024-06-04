return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'catppuccin'
    },
    sections = {
      lualine_x = { 'filetype' },
      lualine_y = { "os.date('%a %m/%d')" },
    }
  }
}
