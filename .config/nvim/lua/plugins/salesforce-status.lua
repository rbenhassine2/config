-- Statusline: show the active Salesforce target org for SF filetypes.
--
-- xixiaofinland/sf.nvim fetches the org list at startup and exposes the current
-- target via get_target_org(). Guarded because that plugin only loads when you
-- are inside a project.

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local ok, sfmod = pcall(require, "sf")
          if not ok then
            return ""
          end
          local ok2, org = pcall(sfmod.get_target_org)
          if ok2 and org and org ~= "" then
            return "☁ " .. org
          end
          return ""
        end,
        cond = function()
          local ft = vim.bo.filetype
          return ft == "apex" or ft == "apexcode" or ft == "soql" or ft == "visualforce" or ft == "sflog"
        end,
      })
      return opts
    end,
  },
}
