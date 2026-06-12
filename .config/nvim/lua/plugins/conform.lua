return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        javascript = { "eslint_d", "prettier" },
        javascriptreact = { "eslint_d", "prettier" },
        typescript = { "eslint_d", "prettier" },
        typescriptreact = { "eslint_d", "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        xml = { "xmllint" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    },
    formatters = {
      xmllint = {
        command = "xmllint",
        args = { "--format", "-" },
        stdin = true,
      },
      ["clang-format"] = {
        command = vim.fn.expand("~/tools/llvm/bin/clang-format"),
      },
    },
  },
}
