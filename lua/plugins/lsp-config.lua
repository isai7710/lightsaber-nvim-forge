--[[ LSP Configuration w Mason and nvim-lspconfig ]]
------------------------------------------------------
-- LSP stands for Language Server Protocol
-- It is a protocol that helps editors like Neovim and specific language servers (like 'clangd', 'lua_ls', etc.) communicate
-- back and forth in a standardized fashion
-- LSPs provide Neovim with features such as...
--  - Go to definition
--  - Find references
--  - Autocompletion
--  - Symbol Search
--  - and more!
-- LSPs must be installed separately from Neovim, which is what this file hopes to accomplish
-------------------------------------------------------
return {
  -- nvim-lspconfig is a plugin that allows us to write LSP configurations for Neovim such as LSP related keymaps, LSP event attaching, etc
  -- it works with mason and mason-lspconfig to bridge LSPs, linters, formatters, and Neovim together
  'neovim/nvim-lspconfig',
  dependencies = {
    -- mason.nvim package manager
    --  Mason installs LSPs, Linters, and other tools for us
    --  To check the current status of installed tools and/or manually install other tools, you can run
    --    :Mason
    {
      'williamboman/mason.nvim',
      opts = {
        ui = {
          border = "rounded",
          width = 0.7,
          height = 0.8,
        }
      }
    },

    -- mason-lspconfig.nvim enables communication between Mason (above) and LSP configs (the nvim-lspconfig plugin)
    'williamboman/mason-lspconfig.nvim',

    -- mason-tool-installer automatically installs tools and LSPs through Mason. This includes any DAPs, Linters, or Formatters
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- `lazydev.nvim` does the Lua LSP configuration for our Neovim config, runtime and plugins
    -- it is useful for completion, annotations and signatures of Neovim apis
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },

    -- Extensible UI for Neovim notifs and useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },

  -- [[ Main LSP Configurations ]]
  config = function()
    -- LSP servers and clients are able to communicate to each other on what features they support, but we have to define those features.
    -- By default, Neovim doesn't support everything that is in an LSP specification.
    -- When you add and configure other plugins like nvim-cmp, luasnip, etc (see cmp.lua module) Neovim now has *more* capabilities.
    -- So, we created these new capabilities with nvim cmp, let's extract them here and broadcast to the servers later on
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- INFO: LSPs can be added here as tables with optional override configurations for that LSP
    -- Available keys for overriding certain configurations in the LSP tables are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      -- lazydev.nvim configures lua_ls settings (library paths, vim API types) but does
      -- NOT install or enable the server — we still need it here for that to happen.
      lua_ls = {},
      -- CPP:
      clangd = {},
      cmake = {},
      -- Python:
      jedi_language_server = {},
      -- Web Dev:
      ts_ls = {},                 -- for TypeScript
      emmet_language_server = {}, -- for html/jsx
      -- tailwindcss = {},           -- for tailwindcss
      -- Arduino:
      -- Manual arduino-language-server set up following the official nvim-lspconfig recommendations in
      -- https://github.com/neovim/nvim-lspconfig/blob/b8e7957bde4cbb3cb25a13a62548f7c273b026e9/lsp/arduino_language_server.lua
      -- The language server relies on sketch.yaml files in each project for configuration
      arduino_language_server = {
        cmd = {
          "arduino-language-server",
          "-cli-config", vim.fn.expand("~/.arduino15/arduino-cli.yaml"),
          "-cli", "arduino-cli",
          "-clangd", vim.fn.stdpath("data") .. "/mason/bin/clangd",
        },
        filetypes = { 'arduino' },
        root_markers = { { "sketch.yaml" }, "*.ino" },
        capabilities = vim.tbl_deep_extend('force', capabilities, {
          textDocument = {
            semanticTokens = vim.NIL, -- Disable semantic tokens due to upstream bug
          },
          workspace = {
            semanticTokens = vim.NIL, -- Disable semantic tokens due to upstream bug
          },
        }),
      },
    }
    local formatters = {
      'stylua',
      'prettierd',
      'prettier',
      'isort',
      'black',
      'clang-format',
    }
    local linters = {
      'eslint',
      'eslint_d',
      'stylelint',
      'htmlhint',
      'ruff'
    }
    local DAPs = {
      'codelldb',
    }
    local tools = vim.list_extend(vim.list_extend(formatters, linters), DAPs)

    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, tools)

    require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

    for name, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend(
        'force', capabilities, config.capabilities or {})
      vim.lsp.config[name] = config
    end

    require('mason-lspconfig').setup({
      ensure_installed = {},
      automatic_enable = false,
    })

    for name, _ in pairs(servers) do
      vim.lsp.enable(name)
    end

    --  This function gets run when an LSP attaches to a particular buffer.
    --    That is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- Lets create a helper function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- [[ Jump to the definition of the word under your cursor ]]
        --  This can be where a variable was first declared, where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- [[ Jump to the declaration (NOT definition) of the word under your cursor ]]
        --  For example, in C this would take you to the header.
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- [[ Find references for the word under your cursor ]]
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- [[ Jump to the implementation of the word under your cursor ]]
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- [[ Jump to the type of the word under your cursor ]]
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('grt', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- [[ Fuzzy find all the symbols in your current document ]]
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- [[ Fuzzy find all the symbols in your current workspace ]]
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- [[ Rename the variable under your cursor ]]
        --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- [[ Execute a code action, usually your cursor needs to be on top of an error ]]
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- [[ Cursor Hold and Move Autocommands ]]
        -- first get the LSP client ID
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- check if LSP client exists and supports document highlighting
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          -- The following autocommand is used to highlight references of the word under your cursor when
          -- your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          -- and then when you move your cursor, the highlights will be cleared
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          -- upon detachment of LSP client from the buffer (LspDetach) ensure highlights are cleared and autocommands
          -- above are removed
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }
  end
}
-- vim: ts=2 sts=2 sw=2 et
