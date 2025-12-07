return {
  -- Disable Erlang LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        erlangls = false,
      },
    },
  },

  -- Mason package (if it tries to install erlang_ls)
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      if opts.ensure_installed then
        vim.list_extend(opts.ensure_installed, {})
        -- Remove erlangls if present
        opts.ensure_installed = vim.tbl_filter(function(pkg)
          return pkg ~= "erlangls"
        end, opts.ensure_installed)
      end
    end,
  },

  -- Disable any Erlang tools plugin (if present)
  {
    "erlang-ls/erlang-ls",
    enabled = false,
  },

  -- Disable Tree-sitter grammar if installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed then
        opts.ensure_installed = vim.tbl_filter(function(lang)
          return lang ~= "erlang"
        end, opts.ensure_installed)
      end
    end,
  },

  -- Disable any third-party Erlang helpers (several LazyVim distros include these)
  {
    "vim-erlang/vim-erlang-runtime",
    enabled = false,
  },
  {
    "vim-erlang/vim-erlang-compiler",
    enabled = false,
  },
  {
    "vim-erlang/vim-erlang-omnicomplete",
    enabled = false,
  },
}
