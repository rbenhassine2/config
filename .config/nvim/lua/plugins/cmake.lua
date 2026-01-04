return {
  "Civitasv/cmake-tools.nvim",
  opts = {
    cmake_build_options = { "-j4" },
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
    cmake_run_options = {},
    cmake_dap_configuration = {
      name = "cpp",
      type = "codelldb",
      request = "launch",
    },
  },
}
