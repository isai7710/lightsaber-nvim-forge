return {
  {
    -- nvim-treesitter: Provides syntax highlighting, indentation, and other features
    -- by using tree-sitter language parsers instead of regex-based syntax files.
    -- This config targets the new main branch rewrite (NOT the old master branch).
    -- The new API no longer uses require('nvim-treesitter.configs').setup() —
    -- instead it exposes functions directly on require('nvim-treesitter') and
    -- relies on Neovim's built-in vim.treesitter API for attaching parsers.
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    -- [[ Configure Treesitter ]]
    -- See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'python', 'html', 'javascript', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'vim', 'vimdoc' },
      -- Autoinstall on languages that don't have parser specified
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent. Below shows how to do so with Ruby
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    opts = {
      max_lines = 3,       -- max lines the context window can take up
      trim_scope = 'outer', -- which context lines to discard when too long
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
