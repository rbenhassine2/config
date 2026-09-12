-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- nvim 0.12+ removed the nvim-lspconfig `:Lsp*` commands in favor of the
-- builtin `:lsp` command. Keep the old command names working.
vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "LSP info" })
vim.api.nvim_create_user_command("LspRestart", "lsp restart", { bang = true, desc = "Restart LSP client(s)" })
vim.api.nvim_create_user_command("LspStart", "lsp enable", { desc = "Enable and launch a language server" })
vim.api.nvim_create_user_command("LspStop", "lsp stop", { bang = true, desc = "Stop LSP client(s)" })

vim.keymap.set("n", "<leader>cp", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return vim.notify("No file name", "warn")
  end
  local root = vim.fs.root(0, ".git") or vim.fs.root(0, ".gitignore") or vim.fn.getcwd()
  local rel = vim.fs.relpath(root, file) or file
  vim.fn.setreg("+", rel)
  vim.notify("Copied: " .. rel)
end, { desc = "Copy path relative to project root" })

vim.keymap.set("n", "<leader>cP", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy full file path" })

-- All C++ actions under <leader>z (for "make/build")
vim.keymap.set("n", "<leader>zb", "<cmd>CMakeBuild<cr>", { desc = "CMake Build" })
vim.keymap.set("n", "<leader>zr", "<cmd>CMakeRun<cr>", { desc = "CMake Run" })
vim.keymap.set("n", "<leader>zd", "<cmd>CMakeDebug<cr>", { desc = "CMake Debug" })
vim.keymap.set("n", "<leader>zg", "<cmd>CMakeGenerate<cr>", { desc = "CMake Generate" })
vim.keymap.set("n", "<leader>zt", "<cmd>CMakeRunTest<cr>", { desc = "CMake Test" })
vim.keymap.set("n", "<leader>zc", "<cmd>CMakeClean<cr>", { desc = "CMake Clean" })

vim.keymap.set("n", "gs", function()
  vim.go.operatorfunc = "v:lua.snake_case_op"
  return "g@"
end, { expr = true })

function snake_case_op(type)
  vim.cmd("'[,']s/\\v([a-z0-9])([A-Z])/\\1_\\l\\2/g")
end

-- buffers
vim.keymap.set("n", "<S-Left>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-Right>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Postterm project commands (plan step B4): <leader>mb build, <leader>mt test,
-- <leader>mr run, <leader>mu build with output logged to .llm/build.log.
require("config.postterm").setup()
