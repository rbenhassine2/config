local toolchain = require("config.toolchain")

-- B1 fix: clangd used to be hardcoded to ~/tools/llvm/bin/clangd, which does not
-- exist here. Resolve the real path instead, and fall back to a bare "clangd"
-- so lspconfig can still find it on PATH if resolution ever fails.
local clangd = toolchain.clangd() or "clangd"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            clangd,
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=" .. toolchain.query_drivers(),
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
          filetypes = { "html", "htmldjango" },
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
        },

        -- Emmet
        emmet_ls = {
          filetypes = {
            "html",
            "css",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
      },
    },
  },
}
