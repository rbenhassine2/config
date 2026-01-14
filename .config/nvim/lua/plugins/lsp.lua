return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--offset-encoding=utf-16",
            "--background-index",
            "--clang-tidy",
            "--clang-tidy-checks=*",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--header-insertion=iwyu",
            "--all-scopes-completion",
            "--query-driver=/usr/bin/**/clang*",
          },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          extra_args = {
            "--query-driver=/usr/bin/**/clang*",
          },
        },
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
              displayTypeErrors = "default",
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
        erlang_ls = false,
        erlangls = false,
        rubocop = false,
        ruby_lsp = false,
        fsautocomplete = false,
      },
    },
  },
}
