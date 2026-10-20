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
      local sf_helpers = require("config.sf")

      -- sf.nvim shells out to a bare `sf` and skips its org fetch unless
      -- vim.fn.executable("sf") succeeds. Under GUI/non-login launches the
      -- nvm bin dir is often absent from PATH, so make the CLI resolvable first.
      sf_helpers.ensure_path()

      sf.setup({
        -- Keep our own keymaps; the plugin's defaults are broad and collide.
        enable_hotkeys = false,
        terminal = "integrated",
        -- sf.nvim implements this with a VimEnter autocmd, but it only registers
        -- that autocmd when setup() runs. This plugin is lazy-loaded on
        -- VeryLazy, which fires *after* VimEnter, so the hook never runs and the
        -- org cache stays empty ("No orgs available"). Fetch explicitly below.
        fetch_org_list_at_nvim_start = false,
      })

      -- Populate the org cache once setup is done, so target-org resolution and
      -- the org picker work on first use.
      vim.schedule(function()
        if vim.fn.executable("sf") == 1 then
          sf.fetch_org_list()
        end
      end)

      -- --- SFTerm close/toggle ----------------------------------------------
      -- raw_term.lua closes then reopens its floating window after every command
      -- ("hack way to scroll to end") and always reopens on job exit, so a plain
      -- close is undone while a command is still running. Patch raw_term so an
      -- explicit close sticks: mark a pending close, and clear it whenever a new
      -- command is started (all commands go through the instance's run()).
      local raw_term = require("sf.sub.raw_term")
      local close_pending = false

      local orig_open = raw_term.open
      raw_term.open = function(self, ...)
        if close_pending then
          close_pending = false
          return self
        end
        return orig_open(self, ...)
      end

      local orig_run = raw_term.run
      raw_term.run = function(self, ...)
        close_pending = false
        return orig_run(self, ...)
      end

      local function sfterm_is_open()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "SFTerm" then
            return true
          end
        end
        return false
      end

      -- Close the popup when it is open, open it when it is not.
      local function toggle_sfterm()
        close_pending = sfterm_is_open()
        sf.toggle_term()
      end

      -- The floating term steals focus only momentarily; allow closing it from
      -- inside too, without leaving terminal mode.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "SFTerm",
        callback = function(args)
          vim.keymap.set({ "n", "t" }, "<Esc>", toggle_sfterm, {
            buffer = args.buf,
            desc = "Salesforce: close terminal",
          })
        end,
      })

      local map = vim.keymap.set

      -- Push the current file, then dismiss the SFTerm popup once the deploy
      -- succeeds. sf.nvim's save_and_push takes no callback, and raw_term
      -- reopens its window after every command (to scroll to the end), so run
      -- the same deploy through sf.run() and close in the exit callback. A
      -- failed deploy leaves the term open so the errors stay visible.
      local function push_current_file()
        local U = require("sf.util")
        if U.is_empty_str(U.target_org) then
          return U.show_err("Target_org empty!")
        end

        vim.cmd("write!")

        local B = require("sf.sub.cmd_builder")
        local cmd = B:new():cmd("project"):act("deploy start"):addParams("-d", "%:p"):build()

        sf.run(cmd, function(term, _, code)
          if code == 0 then
            term:close()
          end
        end)
      end

      map("n", "<leader>So", sf.set_target_org, { desc = "Salesforce: set target org" })
      map("n", "<leader>SO", sf.org_open, { desc = "Salesforce: open org" })
      map("n", "<leader>Sp", push_current_file, { desc = "Salesforce: push current file" })
      map("n", "<leader>Sr", sf.retrieve, { desc = "Salesforce: retrieve current file" })
      map("n", "<leader>Sd", sf.diff_in_org, { desc = "Salesforce: diff file vs org" })
      map("n", "<leader>Sm", sf.list_md_to_retrieve, { desc = "Salesforce: list metadata to retrieve" })
      map("n", "<leader>Sa", sf.run_anonymous, { desc = "Salesforce: run anonymous Apex (buffer)" })
      map("n", "<leader>St", sf.run_current_test, { desc = "Salesforce: test under cursor" })
      map("n", "<leader>ST", sf.run_all_tests_in_this_file, { desc = "Salesforce: all tests in file" })
      map("n", "<leader>Sc", sf.toggle_sign, { desc = "Salesforce: toggle coverage signs" })
      map("x", "<leader>Sq", sf.run_highlighted_soql, { desc = "Salesforce: run selected SOQL" })
      map("n", "<leader>Sl", sf.pull_log, { desc = "Salesforce: pull debug log" })
      map("n", "<leader>Sx", toggle_sfterm, { desc = "Salesforce: toggle terminal" })
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
