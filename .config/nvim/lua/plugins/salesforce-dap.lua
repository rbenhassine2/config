-- Apex Replay Debugger via nvim-dap.
--
-- The adapter is the compiled DAP server shipped inside the VS Code
-- salesforcedx-vscode-apex-replay-debugger extension (dist/apexReplayDebug.js).
-- It accepts `--server=<port>`; without it, it speaks stdio. We run it in server
-- mode on an nvim-dap-assigned port.
--
-- Workflow: create a trace flag, reproduce, then `:SfReplayDebug` / <leader>SL
-- lists debug logs, downloads the selected one, and starts the session. Log
-- lines are matched to source via the Apex LSP (apex_ls) breakpoints.

local sf = require("config.sf")

return {
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local adapter = sf.replay_adapter()
      if not adapter then
        vim.notify("Apex Replay Debugger: apexReplayDebug.js not found (VS Code extension missing).", vim.log.levels.WARN)
        return opts
      end

      local dap = require("dap")
      dap.adapters["apex-replay"] = {
        type = "server",
        port = "${port}",
        executable = {
          command = "node",
          args = { adapter, "--server=${port}" },
        },
      }

      for _, ft in ipairs({ "apex", "apexcode" }) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        table.insert(dap.configurations[ft], {
          type = "apex-replay",
          request = "launch",
          name = "Apex Replay Debug (selected log)",
          logFile = function()
            return vim.g.sf_replay_log
              or (sf.project_root(0) or vim.fn.getcwd()) .. "/.sf/sf.nvim/dap/latest.log"
          end,
          stopOnEntry = true,
          trace = true,
        })
      end

      local function launch(id)
        local dir = (sf.project_root(0) or vim.fn.getcwd()) .. "/.sf/sf.nvim/dap"
        sf.fetch_log(id, dir, function(path)
          if not path then
            vim.notify("Apex Replay Debugger: failed to download log " .. id, vim.log.levels.ERROR)
            return
          end
          vim.g.sf_replay_log = path
          require("dap").run({
            type = "apex-replay",
            request = "launch",
            name = "Apex Replay Debug: " .. vim.fn.fnamemodify(path, ":t"),
            logFile = path,
            stopOnEntry = true,
            trace = true,
          })
        end)
      end

      local function replay()
        sf.list_logs(function(logs)
          if #logs == 0 then
            vim.notify("Apex Replay Debugger: no debug logs. Create a trace flag, reproduce, then retry.", vim.log.levels.WARN)
            return
          end

          local items = {}
          for _, l in ipairs(logs) do
            table.insert(items, {
              id = l.Id,
              label = string.format(
                "%s  %s  %s  %s",
                l.StartTime or l.LastModifiedDate or "",
                l.Operation or "",
                l.Status or "",
                l.Id or ""
              ),
            })
          end

          local ok, fzf = pcall(require, "fzf-lua")
          if ok then
            fzf.fzf_exec(vim.tbl_map(function(i)
              return i.label
            end, items), {
              prompt = "Debug logs> ",
              actions = {
                ["default"] = function(selected)
                  local label = selected[1]
                  for _, i in ipairs(items) do
                    if i.label == label then
                      launch(i.id)
                      return
                    end
                  end
                end,
              },
            })
          else
            vim.ui.select(items, {
              prompt = "Debug logs",
              format_item = function(i)
                return i.label
              end,
            }, function(i)
              if i then
                launch(i.id)
              end
            end)
          end
        end)
      end

      vim.api.nvim_create_user_command("SfReplayDebug", replay, { desc = "Salesforce: replay-debug a debug log" })
      vim.keymap.set("n", "<leader>SL", replay, { desc = "Salesforce: replay-debug a log" })

      return opts
    end,
  },
}
