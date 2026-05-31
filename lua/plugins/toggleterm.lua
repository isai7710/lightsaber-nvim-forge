return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require('toggleterm').setup({
      size = 90,
      open_mapping = [[<c-\>]],
      direction = "vertical",
    })

    -- Function for setting terminal keymaps
    local function set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    -- Apply keymaps automatically when a terminal opens
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = set_terminal_keymaps,
    })
  end,
}
