return {
  -- Add TypeScript-specific keybindings and settings
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Add React-specific keybindings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.expandtab = true
        end,
      })
    end,
  },
}
