local toolchain = require("config.toolchain")

local function prompt_program()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

return {
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local dap = require("dap")
      local adapters = {}

      local lldb_dap = toolchain.lldb_dap()
      if lldb_dap then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_dap,
          name = "lldb",
        }
        table.insert(adapters, { type = "lldb", label = "Launch file (lldb-dap)" })
      end

      local gdb = toolchain.gdb()
      if gdb then
        dap.adapters.gdb = {
          type = "executable",
          command = gdb,
          args = { "--interpreter=dap" },
          name = "gdb",
        }
        table.insert(adapters, { type = "gdb", label = "Launch file (gdb)" })
      end

      local codelldb = toolchain.codelldb()
      if codelldb then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb, args = { "--port", "${port}" } },
        }
        table.insert(adapters, { type = "codelldb", label = "Launch file (codelldb)" })
      end

      if vim.tbl_isempty(adapters) then
        vim.notify("nvim-dap: no debug adapter found. Install lldb, gdb, or codelldb.", vim.log.levels.WARN)
        return opts
      end

      -- nim and vala are here because this project targets them; both compile
      -- down to native code, so the same adapters work unchanged.
      for _, lang in ipairs({ "c", "cpp", "nim", "vala", "zig" }) do
        dap.configurations[lang] = dap.configurations[lang] or {}
        for _, adapter in ipairs(adapters) do
          local config = {
            type = adapter.type,
            request = "launch",
            name = adapter.label,
            program = prompt_program,
            cwd = "${workspaceFolder}",
          }
          -- gdb's DAP does not use stopOnEntry; lldb and codelldb do.
          if adapter.type ~= "gdb" then
            config.stopOnEntry = false
          end
          table.insert(dap.configurations[lang], config)
        end
      end

      return opts
    end,
  },
}
