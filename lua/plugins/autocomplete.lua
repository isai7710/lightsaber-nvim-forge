-- nvim-cmp: completion engine that offers completion suggestions from different sources (like LSPs and a snippet engine, in this case LuaSnip)
-- LuaSnip: snippet engine that is added as a dependency and source for nvim-cmp
-- - provides the main snippet functionality: expansion of snippets based on triggers

return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',
      --[[ I'm not sure what this does but I'm using windows (WSL 2) so I commented it all out
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        --]]

      -- NOTE: LuaSnip doesn't ship with snippets out of the box, we have to either define them manually or use prebuilt ones like 'friendly-snippets' which is a familiar VS Code style snippets plugin
      -- 'friendly-snippets' includes a collection of snippets from various languages
      -- See their README about individual language/framework/plugin snippets:
      -- https://github.com/rafamadriz/friendly-snippets
      dependencies = {
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
    },

    -- Add other completion capabilities or 'sources' for nvim-cmp.
    --  nvim-cmp does not ship with all these sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'saadparwaiz1/cmp_luasnip', -- bridge between nvim-cmp and LuaSnip
    'hrsh7th/cmp-nvim-lsp',     -- integrates nvim-cmp with Neovim's built in LSP client
    'hrsh7th/cmp-path',         -- provides filesystem path completions
    -- NOTE: these capabilities must be broadcasted to the LSP since by default Neovim doesn't communicate with the LSP that we have these
    -- capabilities, see the capabilities section in the lsp-config.lua module for clarity
  },
  config = function()
    -- See `:help cmp`
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    luasnip.config.setup({})

    cmp.setup({
      -- specify a snippet engine here (in our case LuaSnip)
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
      },

      mapping = cmp.mapping.preset.insert({
        -- Not going to use kickstart.nvim's keymaps but rather the ones defined below

        -- Scroll the documentation window [b]ack / [f]orward:
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Completion keymaps:
        ['<Tab>'] = cmp.mapping.confirm { select = true },
        ['<CR>'] = cmp.mapping.select_next_item(),
        ['<S-CR>'] = cmp.mapping.select_prev_item(),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Some mapping for LuaSnip functionality:
        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      }),

      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      },
    })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
