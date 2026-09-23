-- Nim support: treesitter parsers, language server, formatter.
--
-- Nothing here is provided by a LazyVim extra: LazyVim ships extras for neither
-- Nim nor Vala, so this file is the whole integration.

local toolchain = require("config.toolchain")

return {
  -- Parsers. `nim` exists in nvim-treesitter; `meson` is here for build files.
  -- There is no Blueprint parser, which is why byte-level syntax highlighting
  -- for .blp is hand-written in syntax/blueprint.vim.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "nim", "meson" },
    },
  },

  -- Language server: https://github.com/nim-lang/langserver
  -- Installed with `nimble install nimlangserver`; lspconfig knows it as
  -- `nim_langserver` and roots the project at *.nimble or the git root.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nim_langserver = {
          cmd = { toolchain.nimlangserver() or "nimlangserver" },
          -- Install provenance: the binary comes from `nimble install`, not
          -- Mason. nim_langserver IS listed in mason-lspconfig's
          -- lspconfig_to_package map, and LazyVim treats any server in that map
          -- as Mason-managed: it skips vim.lsp.enable() and defers to Mason's
          -- automatic_enable, which only looks in Mason's own bin directory.
          -- The result is a server that never starts and logs nothing. Setting
          -- mason = false makes LazyVim call vim.lsp.enable() directly.
          mason = false,
        },
      },
    },
  },

  -- Formatting. nimpretty ships with Nim and supports --stdin, so conform can
  -- pipe the buffer through it instead of formatting the file in place.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nim = { "nimpretty" },
      },
      formatters = {
        nimpretty = {
          command = toolchain.nimpretty() or "nimpretty",
          args = { "--stdin", "--indent:2" },
          stdin = true,
        },
      },
    },
  },
}
