-- C++ Development Configuration
return {
  -- Configure conform.nvim for C++
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang_format" },
        c = { "clang_format" },
      },
      formatters = {
        clang_format = {
          command = "clang-format",
          args = { "--style=file" },
        },
      },
    },
  },
  -- Configure DAP for C++
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local dap = require("dap")

      -- Configure CodeLLDB for C++
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.exepath("codelldb"),
          args = { "--port", "${port}" },
        },
      }

      -- C++ debugging configuration
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          console = "integratedTerminal",
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          console = "integratedTerminal",
        },
      }

      -- Apply to C files as well
      dap.configurations.c = dap.configurations.cpp
    end,
  },
  -- Install additional C++ tools
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clang-format",
        "cpplint",
        -- "cppcheck",
      },
    },
  },
}
