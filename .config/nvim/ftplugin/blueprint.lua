-- Blueprint (.blp) linting: :BlueprintCheck
--
-- Notes on this version of the compiler, verified on 2026-09-12:
--   * the CLI is `blueprint-compiler compile <file> --output <file>`;
--     there is no --target-gtk flag and no -o short form
--   * diagnostics print the message BEFORE the location:
--         error: Class Gtk.Button does not have a property called nonsense
--         at /path/file.blp line 5 column 3:
--     so a simple errorformat cannot express them
--   * output contains ANSI colour codes even when stdout is not a terminal
--
-- Therefore this parses the diagnostics in Lua and fills the quickfix list
-- directly, pairing each "error:/warning:/hint:" line with the "at ... line L
-- column C:" line that follows it.

local toolchain = require("config.toolchain")
local compiler = toolchain.blueprint_compiler()

local function strip_ansi(text)
  return (text:gsub("\27%[[%d;]*m", ""))
end

local function parse_diagnostics(text)
  local entries, pending = {}, nil
  for line in strip_ansi(text):gmatch("[^\r\n]+") do
    local kind, message = line:match("^%s*(%a+):%s*(.+)$")
    if kind == "error" or kind == "warning" or kind == "hint" then
      pending = { kind = kind, message = message }
    else
      local file, lnum, col = line:match("^at (.-) line (%d+) column (%d+):")
      if file and pending then
        table.insert(entries, {
          filename = file,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = pending.message,
          type = pending.kind == "error" and "E" or (pending.kind == "warning" and "W" or "I"),
        })
        pending = nil
      end
    end
  end
  return entries
end

local function check()
  if not compiler then
    return vim.notify("Blueprint: blueprint-compiler not found", vim.log.levels.ERROR)
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return vim.notify("Blueprint: buffer has no file name", vim.log.levels.WARN)
  end

  -- The compiler always writes an output file, so send it to the cache dir.
  local output = vim.fs.joinpath(vim.fn.stdpath("cache"), "blueprint-check.ui")
  local result = vim
    .system({
      compiler,
      "compile",
      file,
      "--output",
      output,
    }, { text = true })
    :wait()

  local entries = parse_diagnostics((result.stderr or "") .. "\n" .. (result.stdout or ""))
  vim.fn.setqflist(entries, "r")

  if #entries > 0 then
    vim.cmd("copen")
  elseif result.code ~= 0 then
    vim.notify("Blueprint: compiler failed with exit " .. result.code, vim.log.levels.ERROR)
  else
    vim.notify("Blueprint: no problems found", vim.log.levels.INFO)
  end
end

vim.api.nvim_buf_create_user_command(0, "BlueprintCheck", check, {
  desc = "Compile-check the current .blp file into the quickfix list",
})

vim.keymap.set("n", "<leader>mc", "<cmd>BlueprintCheck<cr>", {
  buffer = true,
  desc = "Blueprint: check file (quickfix)",
})
