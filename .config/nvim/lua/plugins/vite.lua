return {
  -- Add Vite-specific keybindings
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          local vite_config = vim.fn.findfile("vite.config.ts", vim.fn.getcwd() .. ";")
          if vite_config ~= "" then
            return "Vite"
          end
          vite_config = vim.fn.findfile("vite.config.js", vim.fn.getcwd() .. ";")
          if vite_config ~= "" then
            return "Vite"
          end
          return nil
        end,
      })
    end,
  },
}
