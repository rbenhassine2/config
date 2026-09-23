-- Nim buffer setup: type-check the current file into the quickfix list.
--
-- `nim check` type-checks without producing a binary and reports diagnostics as
-- "file(line, col) Error: message". errorformat parses that shape; hints are
-- suppressed because Nim emits a lot of them and they drown the real errors.
--
-- Bind <leader>mc to check, which is also the Blueprint check keymap, so
-- "check the current file" is the same chord in both languages.

local toolchain = require("config.toolchain")
local nim = toolchain.nim()

if not nim then
  vim.notify("Nim: compiler not found in ~/.nimble/bin or on PATH", vim.log.levels.WARN)
  return
end

vim.opt_local.makeprg = string.format(
  "%s check --colors:off --hints:off %%",
  vim.fn.shellescape(nim)
)

vim.opt_local.errorformat = table.concat({
  "%f(%l\\, %c) %t%*[^:]: %m",
  "%-G%.%#",
}, ",")

vim.keymap.set("n", "<leader>mc", "<cmd>make<cr>", {
  buffer = true,
  desc = "Nim: check file (quickfix)",
})
