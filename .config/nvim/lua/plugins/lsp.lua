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
  -- Disable pyright
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = false,
        ruff = false,
        ruff_lsp = false,
      },
    },
  },
}
