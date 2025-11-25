require("lspconfig").ruff.setup({
  -- empty on_attach is fine, just make sure init_options exists
  init_options = {
    settings = {
      -- explicitly tell it to load config from pyproject.toml (default but sometimes needed)
      config = vim.fn.getcwd() .. "/pyproject.toml",
    },
  },
})

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },
}
