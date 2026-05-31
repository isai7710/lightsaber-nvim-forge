return {
  'stevearc/conform.nvim',
  -- lazy load the autoformat plugin on the following events (we only need formatting when we're working inside a buffer)
  -- BufReadPre: when we start to edit a new buffer, right before reading the file into the buffer
  -- BufNewFile: triggered when we open a buffer for a file that doesn't already exist
  event = { "BufReadPre", "BufNewFile" },
  -- set the following keymap to autoformat
  keys = {
    {
      '<leader>af',
      function()
        require('conform').format({
          async = true,
          lsp_format = "fallback",
        })
      end,
      mode = { 'n', 'v' },
      desc = '[A]uto[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      -- local disable_filetypes = { c = true, cpp = true }
      local disable_filetypes = {}
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 2500,
        lsp_format = lsp_format_opt
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially by adding them to the table
      python = { "isort", "black" },
      -- to run the first available formatter add stop_after_first = true
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd" },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd" },
      css = { "prettierd" },
      html = { "prettierd" },
      json = { "prettierd" },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      cpp = { "clang-format" },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
