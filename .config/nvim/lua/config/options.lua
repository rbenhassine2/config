-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_python_lsp = "pyrefly"

local function has_native_clipboard()
  if vim.fn.has("mac") == 1 then
    return true
  end
  if vim.env.WAYLAND_DISPLAY ~= nil
      and vim.fn.executable("wl-copy") == 1
      and vim.fn.executable("wl-paste") == 1 then
    return true
  end
  if vim.env.DISPLAY ~= nil
      and (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1) then
    return true
  end
  if vim.fn.executable("win32yank.exe") == 1
      or vim.fn.executable("putclip") == 1
      or vim.fn.executable("termux-clipboard-set") == 1 then
    return true
  end
  return false
end

if not has_native_clipboard() then
  vim.g.clipboard = "osc52"
end
vim.opt.clipboard = "unnamedplus"
