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
        -- pyrefly = {
        --   cmd = { vim.fn.expand("~/.local/bin/pyrefly"), "lsp" }, -- global binary
        --   filetypes = { "python" },
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern("pyproject.toml", ".git")(fname)
        --   end,
        -- },
        -- pyrefly = {},
        ty = false,
        -- ruff = {
        --   init_options = {
        --     settings = {
        --       logLevel = "error", -- Reduce noise
        --       config = vim.fn.getcwd() .. "/pyproject.toml",
        --     },
        --   },
        --   -- Defer non-linting features to Pyrefly
        --   capabilities = {
        --     hoverProvider = false,
        --     renameProvider = false, -- Disable Ruff's rename (redundant anyway)
        --   },
        -- },
        ruff = false,
        ruff_lsp = false,
        erlang_ls = false,
        erlangls = false,
        rubocop = false,
        ruby_lsp = false,
        fsautocomplete = false,
      },
      setup = {
        pyrefly = function(_, _)
          -- Register pyrefly using Mason's binary path
          local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/pyrefly"

          vim.lsp.config("pyrefly", {
            cmd = { mason_bin, "lsp" },
            filetypes = { "python" },
            root_dir = function(fname)
              return require("lspconfig.util").root_pattern("pyproject.toml", ".git")(fname)
            end,
            settings = {
              pyrefly = {
                displayTypeErrors = "default",
              },
            },
          })

          vim.lsp.enable("pyrefly")
          return true -- Prevent lspconfig from managing this server
        end,
      },
    },
  },
}
