return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = false,
        auto_open = false,
      },
    },
    keys = {
      --{ "<leader>fe", true },
      --{ "<leader>fE", true },
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
