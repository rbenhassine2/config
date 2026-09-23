-- Postterm project commands (plan step B4).
--
-- Everything here is scoped to the project: the root is found by looking
-- upward for a *.nimble file, so the keymaps do nothing surprising when you are
-- editing something else. Output is captured into a scratch buffer rather than
-- a terminal, which keeps things simple under i3 where nested terminal escape
-- sequences inside nvim can misbehave.

local toolchain = require("config.toolchain")

local M = {}

--- Directory containing the nearest *.nimble file above the cwd, or nil.
local function project_root()
  local found = vim.fs.find(function(name)
    return name:match("%.nimble$") ~= nil
  end, { upward = true, path = vim.fn.getcwd() })[1]
  return found and vim.fs.dirname(found) or nil
end

local function scratch_split()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.wrap = false
  return buf
end

local function append(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- A freshly created scratch buffer already contains one empty line, and
  -- set_lines(buf, -1, -1, ...) inserts *after* it, which would leave a blank
  -- first line. Replace that line on the first write; append thereafter.
  local count = vim.api.nvim_buf_line_count(buf)
  local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  if count == 1 and (first == nil or first == "") then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  else
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  end
end

local function write_log(root, cmd, lines)
  local logfile = vim.fs.joinpath(root, ".llm", "build.log")
  vim.fn.mkdir(vim.fs.dirname(logfile), "p")
  local fh = io.open(logfile, "w")
  if not fh then
    return vim.notify("Postterm: cannot write " .. logfile, vim.log.levels.ERROR)
  end
  fh:write("$ " .. table.concat(cmd, " ") .. "\n\n")
  fh:write(table.concat(lines, "\n"), "\n")
  fh:close()
  vim.notify("Postterm: wrote " .. vim.fn.fnamemodify(logfile, ":~"))
end

--- Run a command in the project root and show its output in a split.
--- @param cmd string[] command and arguments
--- @param opts? { log?: boolean }
local function run(cmd, opts)
  opts = opts or {}

  local root = project_root()
  if not root then
    return vim.notify(
      "Postterm: no *.nimble file found above " .. vim.fn.getcwd(),
      vim.log.levels.WARN
    )
  end

  local buf = scratch_split()
  append(buf, { "$ " .. table.concat(cmd, " "), "" })

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local lines = {}
      for _, chunk in ipairs({ result.stdout, result.stderr }) do
        if chunk and chunk ~= "" then
          vim.list_extend(lines, vim.split(chunk:gsub("\n+$", ""), "\n", { plain = true }))
        end
      end
      table.insert(lines, "")
      table.insert(lines, ("[exit %d]"):format(result.code))
      append(buf, lines)

      if opts.log then
        write_log(root, cmd, lines)
      end
    end)
  end)
end

function M.setup()
  local nimble = toolchain.nimble() or "nimble"

  vim.keymap.set("n", "<leader>mb", function()
    run({ nimble, "build" })
  end, { desc = "Postterm: build (nimble build)" })

  vim.keymap.set("n", "<leader>mt", function()
    run({ nimble, "test" })
  end, { desc = "Postterm: test (nimble test)" })

  vim.keymap.set("n", "<leader>mr", function()
    local root = project_root()
    if not root then
      return vim.notify(
        "Postterm: no *.nimble file found above " .. vim.fn.getcwd(),
        vim.log.levels.WARN
      )
    end

    -- Prefer the built binary so the app is not rebuilt on every launch;
    -- fall back to `nimble run` before the first successful build.
    local binary = vim.fs.joinpath(root, "build", "apps", "postterm")
    if vim.fn.executable(binary) == 1 then
      run({ binary })
    else
      run({ nimble, "run" })
    end
  end, { desc = "Postterm: run app" })

  vim.keymap.set("n", "<leader>mu", function()
    run({ nimble, "build" }, { log = true })
  end, { desc = "Postterm: build, log to .llm/build.log" })
end

return M
