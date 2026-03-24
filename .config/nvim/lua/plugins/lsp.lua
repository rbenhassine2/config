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

        -- TypeScript/JavaScript with React support
        ts_ls = {
          settings = {
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
          },
        },

        -- ESLint for React/TypeScript linting
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            codeAction = {
              disableRuleComment = { enable = true },
              showDocumentation = { enable = true },
            },
          },
        },

        -- HTML Language Server
        html = {
          filetypes = { "html", "blade", "htmldjango" },
        },

        -- CSS Language Server
        cssls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },

        -- Tailwind CSS LSP
        tailwindcss = {
          filetypes = { "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
          init_options = {
            userLanguages = {
              eelixir = "html-eex",
              eruby = "erb",
            },
          },
        },
      },
    },
  },
}
