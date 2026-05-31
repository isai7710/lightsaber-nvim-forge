return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    -- Document existing key chains
    spec = {
      { '<leader>c', group = '[C]ode',     mode = { 'n', 'x' } },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>x', group = '[X] Diagnostics' },
      { '<leader>a', group = '[A]ctions' },
    },
  },

}
-- vim: ts=2 sts=2 sw=2 et
