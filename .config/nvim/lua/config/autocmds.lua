-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Web filetypes use two-space indentation.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Treesitter folds are first evaluated during redraw, which for large Apex files
-- can happen before the parser has finished, caching an empty result so `zc`/`za`
-- do nothing. Once the tree is parsed, recompute folds (equivalent to `zx`).
local function recompute_apex_folds(buf)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok or not parser then
      return
    end
    parser:parse()
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! zx")
      end)
    end
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "apex", "apexcode" },
  callback = function(args)
    recompute_apex_folds(args.buf)
  end,
})

-- Cover Apex buffers that were already open when this module loaded.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype:match("^apex") then
    recompute_apex_folds(buf)
  end
end
