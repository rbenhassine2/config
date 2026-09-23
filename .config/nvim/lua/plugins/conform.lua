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
        -- Apex uses the project's prettier + prettier-plugin-apex (see
        -- .prettierrc in the SFDX project).
        apex = { "prettier_apex" },
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
      prettier_apex = {
        command = function(_, ctx)
          return require("config.sf").prettier_bin(ctx.buf)
        end,
        cwd = function(_, ctx)
          return require("config.sf").project_root(ctx.buf)
        end,
        args = { "--stdin-filepath", "$FILENAME" },
        stdin = true,
      },
    },
  },
}
