-- Load custom Lua snippets for TanStack and Shadcn
return {
  {
    "nvim-cmp",
    dependencies = {
      -- Add LuaSnip for snippet engine
      {
        "L3MON4D3/LuaSnip",
        config = function()
          local luasnip = require("luasnip")
          local types = require("luasnip.util.types")

          -- Load custom snippets
          local tanstack_snippets = require("snippets.tanstack")
          local shadcn_snippets = require("snippets.shadcn")

          -- Add snippets to LuaSnip
          for _, snippet in ipairs(tanstack_snippets) do
            luasnip.add_snippets("typescript", { snippet })
            luasnip.add_snippets("typescriptreact", { snippet })
            luasnip.add_snippets("javascript", { snippet })
            luasnip.add_snippets("javascriptreact", { snippet })
          end

          for _, snippet in ipairs(shadcn_snippets) do
            luasnip.add_snippets("typescript", { snippet })
            luasnip.add_snippets("typescriptreact", { snippet })
          end

          -- Configure snippet behavior
          luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            ext_opts = {
              [types.choiceNode] = {
                active = {
                  virt_text = { { "●", "LuasnipChoice" } },
                },
              },
            },
          })
        end,
      },
    },
  },
}
