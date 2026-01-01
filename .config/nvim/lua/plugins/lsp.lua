-- Function to get Python path from venv
local function get_python_path()
  -- Use the activated venv's python if available
  local venv_path = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv_path then
    return venv_path .. "/bin/python"
  end

  -- Fallback to system python
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

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
        pyright = {
          python = {
            pythonPath = "python",
          },
          analysis = {
            typeCheckingMode = "standard", -- or "strict"
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
        -- pyright = false,
        pyrefly = false,
        ty = false,
        -- ruff = {
        -- init_options = {
        -- settings = {
        -- logLevel = "error", -- Reduce noise
        -- },
        -- },
        -- Defer non-linting features to Pyrefly
        -- capabilities = {
        -- hoverProvider = false,
        -- renameProvider = false, -- Disable Ruff's rename (redundant anyway)
        -- },
        -- },
        ruff = false,
        ruff_lsp = false,
        erlang_ls = false,
        erlangls = false,
        rubocop = false,
        ruby_lsp = false,
      },
    },
  },
}
