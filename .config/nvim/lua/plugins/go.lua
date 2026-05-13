local function go_alternate_test()
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(buf, ":h")
  local name = vim.fn.fnamemodify(buf, ":t")
  local target
  if name:match("_test%.go$") then
    target = name:gsub("_test%.go$", ".go")
  elseif name:match("%.go$") then
    target = name:gsub("%.go$", "_test.go")
  else
    return
  end
  local path = dir .. "/" .. target
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  else
    Snacks.notify.warn("File not found: " .. target)
  end
end

local function go_run_file()
  Snacks.terminal({ "go", "run", vim.fn.expand("%:p") }, { cwd = vim.fn.getcwd() })
end

local function go_run_module()
  Snacks.terminal({ "go", "run", "." }, { cwd = vim.fn.getcwd() })
end

local function go_build()
  Snacks.terminal({ "go", "build", "./..." }, { cwd = vim.fn.getcwd() })
end

local function go_vet()
  Snacks.terminal({ "go", "vet", "./..." }, { cwd = vim.fn.getcwd() })
end

local function go_test_coverage()
  Snacks.terminal(
    { "go", "test", "-coverprofile=coverage.out", "./..." },
    { cwd = vim.fn.getcwd(), auto_close = false }
  )
end

local function organize_imports()
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
  if not result then
    return
  end
  for _, res in pairs(result) do
    for _, action in pairs(res.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
      end
    end
  end
  vim.lsp.buf.format({ async = false })
end

local function fill_struct()
  vim.lsp.buf.code_action({
    context = { only = { "refactor.rewrite.fillStruct" } },
    apply = true,
  })
end

return {
  {
    "LazyVim/LazyVim",
    optional = true,
    keys = {
      { "<leader>g", false },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    keys = {
      { "<leader>gT", go_alternate_test, ft = "go", desc = "Go toggle test file" },
      { "<leader>gf", fill_struct, ft = "go", desc = "Go fill struct" },
      { "<leader>gi", organize_imports, ft = "go", desc = "Go organize imports" },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    keys = {
      { "<leader>gt", function() require("neotest").run.run() end, ft = "go", desc = "Go run nearest test" },
      { "<leader>gS", function() require("neotest").run.run(vim.fn.expand("%")) end, ft = "go", desc = "Go run file tests" },
      { "<leader>gs", function() require("neotest").run.run({ suite = true }) end, ft = "go", desc = "Go run test suite" },
      { "<leader>gd", function() require("neotest").run.run({ strategy = "dap" }) end, ft = "go", desc = "Go debug nearest test" },
      { "<leader>go", function() require("neotest").output.open({ enter = true }) end, ft = "go", desc = "Go test output" },
      { "<leader>gO", function() require("neotest").summary.open() end, ft = "go", desc = "Go test summary" },
    },
  },
  {
    "snacks.nvim",
    optional = true,
    keys = {
      { "<leader>gr", go_run_file, ft = "go", desc = "Go run file" },
      { "<leader>gR", go_run_module, ft = "go", desc = "Go run module" },
      { "<leader>gb", go_build, ft = "go", desc = "Go build" },
      { "<leader>gV", go_vet, ft = "go", desc = "Go vet" },
      { "<leader>gc", go_test_coverage, ft = "go", desc = "Go test coverage" },
    },
  },
}
