require("lspconfig").clangd.setup({
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy=false", -- optional, CPython triggers too many warnings
    "--header-insertion=never", -- we don’t want iwyu suggestions
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style=llvm",
    "--all-scopes-completion",
    "--cross-file-rename",
    "--pch-storage=memory", -- faster for huge codebases
    "--enable-config", -- read .clangd files
    "--offset-encoding=utf-16", -- fixes some offset bugs with nvim
    "--log=verbose",
  },
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true,
  },
  root_dir = function(fname)
    local lspconfig_util = require("lspconfig.util")
    return lspconfig_util.root_pattern(".git")(fname)
  end,
  filetypes = { "c", "cpp", "objc", "objcpp" },
  extra_args = {
    "--query-driver=/usr/bin/**/clang*", -- helps on some systems
  },
})

return {
  -- Disable pyright
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = false,
        pyrefly = {
          cmd = { "uv", "run", "pyrefly", "lsp" },
          display_type_errors = "force-on",
          pythonPath = vim.fn.expand("$VIRTUAL_ENV/bin/python"),
          typeCheckingMode = "standard",
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
        },
        pyright = false,
        ruff = true,
        ruff_lsp = false,
      },
    },
  },
}
