-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Python: Format on save with ruff (format + organize imports)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    require("conform").format({
      bufnr = vim.api.nvim_get_current_buf(),
      timeout_ms = 3000,
      lsp_fallback = false,
    })
  end,
  group = vim.api.nvim_create_augroup("python_format_on_save", { clear = true }),
  desc = "Format Python files with ruff on save",
})
