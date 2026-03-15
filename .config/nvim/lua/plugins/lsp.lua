return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- pyright = {
        --   python = {
        --     pythonPath = "python",
        --   },
        --   analysis = {
        --     typeCheckingMode = "standard", -- or "strict"
        --     autoSearchPaths = true,
        --     useLibraryCodeForTypes = true,
        --     diagnosticMode = "workspace",
        --   },
        -- },
        pyright = false,
        pyrefly = {
          cmd = { vim.fn.expand("~/.local/bin/pyrefly"), "lsp" },
          settings = {
            pyrefly = {
              displayTypeErrors = "all",
            },
          },
        },
        ruff = {
          cmd = { vim.fn.expand("~/.local/bin/ruff"), "server" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
        },
        ty = false,
        ruff_lsp = false,
        fsautocomplete = false,
      },
    },
  },
}
