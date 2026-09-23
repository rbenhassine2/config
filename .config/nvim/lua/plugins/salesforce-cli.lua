-- Salesforce CLI workflow layer: orgs, push/retrieve, metadata, tests,
-- coverage, anonymous Apex, SOQL, ctags-enhanced jump, sObject stub refresh.
--
-- Built on xixiaofinland/sf.nvim (pinned to a known-good commit). Its own
-- hotkeys are disabled; the keymaps below are the project's <leader>S group.
--
-- The plugin registers :SF subcommands lazily: they only exist while the cwd or
-- the current buffer is inside a project with sfdx-project.json/.forceignore.
-- That is expected; open a file under force-app/ to use the commands.

return {
  {
    "xixiaofinland/sf.nvim",
    event = "VeryLazy",
    commit = "420c259d9bdf569fe5be33d558c638520db4daec",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "ibhagwan/fzf-lua",
    },
    config = function()
      local sf = require("sf")
      sf.setup({
        -- Keep our own keymaps; the plugin's defaults are broad and collide.
        enable_hotkeys = false,
        terminal = "integrated",
        fetch_org_list_at_nvim_start = true,
      })

      local map = vim.keymap.set
      map("n", "<leader>So", sf.set_target_org, { desc = "Salesforce: set target org" })
      map("n", "<leader>SO", sf.org_open, { desc = "Salesforce: open org" })
      map("n", "<leader>Sp", sf.save_and_push, { desc = "Salesforce: push current file" })
      map("n", "<leader>Sr", sf.retrieve, { desc = "Salesforce: retrieve current file" })
      map("n", "<leader>Sd", sf.diff_in_org, { desc = "Salesforce: diff file vs org" })
      map("n", "<leader>Sm", sf.list_md_to_retrieve, { desc = "Salesforce: list metadata to retrieve" })
      map("n", "<leader>Sa", sf.run_anonymous, { desc = "Salesforce: run anonymous Apex (buffer)" })
      map("n", "<leader>St", sf.run_current_test, { desc = "Salesforce: test under cursor" })
      map("n", "<leader>ST", sf.run_all_tests_in_this_file, { desc = "Salesforce: all tests in file" })
      map("n", "<leader>Sc", sf.toggle_sign, { desc = "Salesforce: toggle coverage signs" })
      map("x", "<leader>Sq", sf.run_highlighted_soql, { desc = "Salesforce: run selected SOQL" })
      map("n", "<leader>Sl", sf.pull_log, { desc = "Salesforce: pull debug log" })
      map("n", "<leader>Sg", sf.create_and_list_ctags, { desc = "Salesforce: refresh/list ctags" })
      map("n", "<leader>Sb", function()
        sf.refresh_sobjects({ category = "ALL" })
      end, { desc = "Salesforce: refresh sObject stubs (apex_ls)" })
      map("n", "<leader>Sk", function()
        require("config.sf").scan_file(0)
      end, { desc = "Salesforce: Code Analyzer scan file" })
    end,
  },
}
