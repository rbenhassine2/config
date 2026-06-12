return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            vim.fn.expand("~/tools/llvm/bin/clangd"),
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=" .. vim.fn.expand("~/tools/llvm/bin/clang++") .. ",/usr/bin/g++,/usr/bin/gcc",
          },
        },

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

        -- Zig Language Server via zvm
        zls = {
          cmd = { vim.fn.expand("~/.zvm/bin/zls") },
        },

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
