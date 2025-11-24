-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<A-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<A-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<A-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<A-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

vim.keymap.set("n", "<A-S-k>", "<cmd>resize +10<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<A-S-j>", "<cmd>resize -10<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<A-S-h>", "<cmd>vertical resize -10<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<A-S-l>", "<cmd>vertical resize +10<cr>", { desc = "Increase Window Width" })
