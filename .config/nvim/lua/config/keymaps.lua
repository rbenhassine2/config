-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:"))
  vim.notify("Copied: " .. vim.fn.expand("%:"))
end, { desc = "Copy relative file path" })

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
