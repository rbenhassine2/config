-- GTK4 API documentation helpers (plan step B7).
--
-- The workflow this supports: keep nvim and devhelp side by side, and look up
-- the widget you are about to use *before* writing the code. devhelp's
-- --search-assistant opens results in a small non-modal window without stealing
-- focus, which is the one you want while typing; --search opens the main window.
--
-- Verified against devhelp 43: `devhelp -s/--search=KEYWORD` and
-- `devhelp -a/--search-assistant=KEYWORD` (man devhelp).

local M = {}

--- Word under the cursor, converted from camelCase to snake_case.
---
--- GTK4's documentation index is written in C symbol names (gtk_button_new),
--- while Nim bindings are usually camelCase (gtkButtonNew). Searching the raw
--- Nim spelling tends to miss, so convert when the word looks like camelCase.
--- Names that already contain underscores, or are all-lower/all-upper, pass
--- through unchanged.
function M.symbol_under_cursor()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return nil
  end
  if word:find("_", 1, true) or not word:match("%l") or not word:match("%u") then
    return word
  end
  return (word:gsub("(%l)(%u)", "%1_%2")):lower()
end

local function launch(cmd, message)
  if vim.fn.executable(cmd[1]) == 0 then
    return vim.notify(cmd[1] .. " is not installed", vim.log.levels.WARN)
  end
  -- Detached: these are GUI programs and must not block the editor.
  vim.fn.jobstart(cmd, { detach = true })
  vim.notify(message)
end

local function devhelp_search(flag, label)
  local term = M.symbol_under_cursor()
  if not term then
    return vim.notify("No symbol under cursor", vim.log.levels.WARN)
  end
  launch({ "devhelp", flag .. term }, label .. ": " .. term)
end

function M.setup()
  vim.keymap.set("n", "<leader>mh", function()
    devhelp_search("--search=", "devhelp")
  end, { desc = "Docs: devhelp search symbol" })

  vim.keymap.set("n", "<leader>ma", function()
    devhelp_search("--search-assistant=", "devhelp assistant")
  end, { desc = "Docs: devhelp assistant for symbol (no focus steal)" })

  vim.keymap.set("n", "<leader>me", function()
    launch({ "gtk4-demo" }, "gtk4-demo")
  end, { desc = "Docs: open gtk4-demo (runnable widget examples)" })

  vim.keymap.set("n", "<leader>mw", function()
    launch({ "gtk4-widget-factory" }, "gtk4-widget-factory")
  end, { desc = "Docs: open gtk4-widget-factory (widget gallery)" })
end

return M
