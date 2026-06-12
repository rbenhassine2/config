return {
  "Civitasv/cmake-tools.nvim",
  opts = {
    cmake_build_options = { "-j4" },
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
    cmake_run_options = {},
    cmake_dap_configuration = {
      name = "cpp",
      type = "lldb",
      request = "launch",
    },
    cmake_compile_commands_options = {
      action = "soft_link",
    },
  },
}
