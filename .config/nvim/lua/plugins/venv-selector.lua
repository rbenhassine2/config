return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    opts = {
      name = { ".venv", "venv", ".env" }, -- common venv folder names
      auto_refresh = true, -- re-detect on DirChanged
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cmd>", desc = "Select VirtualEnv" },
    },
    ft = "python",
  },
}
