return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "ibhagwan/fzf-lua" },
    opts = {
      name = { ".venv", "venv", ".env" }, -- common venv folder names
      auto_refresh = true, -- re-detect on DirChanged
      picker = "fzf-lua", -- match vim.g.lazyvim_picker
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cmd>", desc = "Select VirtualEnv" },
    },
    ft = "python",
  },
}
