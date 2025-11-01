return {
  -- Helper function to find Python executable in uv venv
  -- Looks for .venv in current directory and parent directories
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      -- Disable inlay hints for Python to prevent errors
      inlay_hints = {
        enabled = false,
      },
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        -- Disable other Python language servers
        basedpyright = false,
        pyright = false,

        -- Configure Pyrefly as LSP and type checker
        pyrefly = {
          settings = {
            pyrefly = {
              -- Disable Pyrefly's own import sorting (we'll use ruff for this)
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                -- Use Pyrefly for type checking
                typeCheckingMode = "basic", -- Options: "off", "basic", "strict"
                -- Auto-import completions
                autoImportCompletions = true,
                -- Auto-search paths
                autoSearchPaths = true,
                -- Use library code for types
                useLibraryCodeForTypes = true,
                -- Diagnostics mode
                diagnosticMode = "workspace", -- Options: "openFilesOnly", "workspace"
                -- Auto-detect virtual environments
                venvPath = ".",
                venv = ".venv",
              },
            },
          },
        },
      },
      -- Setup hook to configure venv detection
      setup = {
        pyrefly = function(_, opts)
          -- Function to find the virtual environment Python executable
          local function find_venv_python()
            -- Check for .venv in current working directory first
            local cwd = vim.fn.getcwd()
            local venv_paths = {
              cwd .. "/.venv/bin/python",
              cwd .. "/.venv/Scripts/python.exe", -- Windows
            }

            for _, path in ipairs(venv_paths) do
              if vim.fn.executable(path) == 1 then
                return path
              end
            end

            -- Fallback to system Python
            return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
          end

          -- Set the Python path
          opts.settings.python = opts.settings.python or {}
          opts.settings.python.pythonPath = find_venv_python()
        end,
      },
    },
  },

  -- Configure formatters and linters with conform.nvim
  {
    "stevearc/conform.nvim",
    opts = function()
      -- Function to find ruff in venv or fallback to system
      local function find_ruff_cmd()
        local cwd = vim.fn.getcwd()
        local venv_paths = {
          cwd .. "/.venv/bin/ruff",
          cwd .. "/.venv/Scripts/ruff.exe", -- Windows
        }

        for _, path in ipairs(venv_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end

        -- Fallback to system ruff or Mason-installed ruff
        return "ruff"
      end

      return {
        formatters_by_ft = {
          python = { "ruff_format", "ruff_organize_imports" },
        },
        -- Configure ruff to use pyproject.toml only
        formatters = {
          ruff_format = {
            command = find_ruff_cmd(),
            args = {
              "format",
              "--force-exclude",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
          },
          ruff_organize_imports = {
            command = find_ruff_cmd(),
            args = {
              "check",
              "--select",
              "I",
              "--fix",
              "--force-exclude",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
          },
        },
      }
    end,
  },

  -- Configure linters with nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = function()
      -- Function to find ruff in venv or fallback to system
      local function find_ruff_cmd()
        local cwd = vim.fn.getcwd()
        local venv_paths = {
          cwd .. "/.venv/bin/ruff",
          cwd .. "/.venv/Scripts/ruff.exe", -- Windows
        }

        for _, path in ipairs(venv_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end

        -- Fallback to system ruff or Mason-installed ruff
        return "ruff"
      end

      return {
        linters_by_ft = {
          python = { "ruff" },
        },
        -- Configure ruff linter to use pyproject.toml
        linters = {
          ruff = {
            cmd = find_ruff_cmd(),
            stdin = true,
            args = {
              "check",
              "--force-exclude",
              "--output-format",
              "json",
              "--stdin-filename",
              function()
                return vim.api.nvim_buf_get_name(0)
              end,
              "-",
            },
            stream = "stdout",
            ignore_exitcode = true,
            parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
              source = "ruff",
            }),
          },
        },
      }
    end,
  },

  -- Install required tools with Mason (as fallback if not in venv)
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pyrefly",  -- LSP server and type checker (fallback)
        "ruff",     -- Linter, formatter, and import sorter (fallback)
      },
    },
  },

  -- Optional: Add venv-selector for easier virtual environment switching
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      -- Auto select .venv if it exists
      auto_refresh = true,
      search_venv_managers = true,
      search = true,
      dap_enabled = false,
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
      },
    },
    event = "VeryLazy",
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
    },
  },
}
