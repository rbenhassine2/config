-- Resolves external developer tools to paths that actually exist.
--
-- Why this exists: lsp.lua and dap.lua used to hardcode ~/tools/llvm/bin/...,
-- and that directory does not exist on this machine, so clangd and lldb-dap
-- silently failed to start. Every path now goes through resolve(), which
-- checks executability before returning, and returns nil when nothing matches
-- so the caller can degrade instead of spawning a broken command.
--
-- Lookup order per tool: explicit local build, then Debian's system install,
-- then the Mason-managed copy. Reorder the candidate lists to change priority.

local M = {}

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

-- Make the Nim toolchain reachable on PATH.
--
-- Resolving absolute paths (below) is enough for anything nvim launches with an
-- explicit command, but nimlangserver launches `nimsuggest` and `nim` itself,
-- and it looks them up on PATH. Without this it fails to spawn them and then
-- dies with "SIGSEGV: Illegal storage access" instead of reporting the error.
local function prepend_path(dir)
  if vim.fn.isdirectory(dir) == 0 then
    return
  end
  local path = vim.env.PATH or ""
  if not path:find(dir, 1, true) then
    vim.env.PATH = dir .. ":" .. path
  end
end

prepend_path(vim.fn.expand("~/.nimble/bin"))

local function resolve(candidates)
  for _, path in ipairs(candidates) do
    if path:sub(1, 1) == "~" then
      path = vim.fn.expand(path)
    end
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return nil
end

M.mason_bin = mason_bin

--- clangd, for C/C++ completion in the generated/shim code.
function M.clangd()
  return resolve({
    "~/tools/llvm/bin/clangd", -- if you ever install LLVM locally
    "/usr/bin/clangd", -- Debian clangd (19.1.7)
    mason_bin .. "/clangd", -- Mason-managed (22.1.6)
  })
end

--- clang++ matching clangd, if present.
function M.clang_plus_plus()
  return resolve({
    "~/tools/llvm/bin/clang++",
    "/usr/bin/clang++",
    "clang++",
  })
end

--- Value for clangd's --query-driver, a comma separated compiler list.
--- gcc matters here: Nim and the GTK code compile through gcc on this box.
function M.query_drivers()
  local drivers = {}

  -- Note: build this with insert() rather than a literal table. A table like
  -- { maybe_nil, "/usr/bin/g++" } has a hole at index 1, and ipairs() stops
  -- there, silently yielding an empty list.
  local clang_pp = M.clang_plus_plus()
  if clang_pp then
    table.insert(drivers, clang_pp)
  end

  for _, path in ipairs({ "/usr/bin/g++", "/usr/bin/gcc" }) do
    if vim.fn.executable(path) == 1 then
      table.insert(drivers, path)
    end
  end

  return table.concat(drivers, ",")
end

--- gdb, for its native DAP server (gdb >= 14; Debian ships 16.3).
function M.gdb()
  return resolve({ "/usr/bin/gdb", "gdb" })
end

--- lldb-dap, for the LLVM debug adapter.
--- Debian installs it under /usr/lib/llvm-<version>/bin, so pick the highest.
function M.lldb_dap()
  local direct = resolve({ "/usr/bin/lldb-dap", "~/tools/llvm/bin/lldb-dap" })
  if direct then
    return direct
  end

  local best, best_version = nil, -1
  for _, path in ipairs(vim.fn.glob("/usr/lib/llvm-*/bin/lldb-dap", false, true)) do
    local version = tonumber(path:match("/llvm%-(%d+)/")) or 0
    if version > best_version and vim.fn.executable(path) == 1 then
      best, best_version = path, version
    end
  end
  return best
end

--- codelldb from Mason, the fallback adapter when neither gdb nor lldb-dap is usable.
function M.codelldb()
  return resolve({ mason_bin .. "/codelldb", "codelldb" })
end

-- ---------------------------------------------------------------------------
-- Nim toolchain
-- ---------------------------------------------------------------------------
-- choosenim installs shims into ~/.nimble/bin. That directory is exported in
-- ~/.profile but not guaranteed to be on PATH in every shell that launches
-- nvim, so resolve the absolute path and let callers fall back to a bare name.

--- Resolve any tool shipped with the Nim toolchain.
function M.nim_tool(name)
  local direct = resolve({ "~/.nimble/bin/" .. name, name })
  if direct then
    return direct
  end

  -- Fallback for a raw toolchain directory, preferring the newest version.
  local best, best_version = nil, -1
  local pattern = vim.fn.expand("~/.choosenim/toolchains/nim-*/bin/") .. name
  for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
    local major, minor, patch = path:match("nim%-(%d+)%.(%d+)%.(%d+)")
    if major and vim.fn.executable(path) == 1 then
      local version = tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
      if version > best_version then
        best, best_version = path, version
      end
    end
  end
  return best
end

function M.nim()
  return M.nim_tool("nim")
end

function M.nimble()
  return M.nim_tool("nimble")
end

function M.nimpretty()
  return M.nim_tool("nimpretty")
end

function M.nimlangserver()
  return M.nim_tool("nimlangserver")
end

--- blueprint-compiler, the build-time compiler for .blp UI files.
function M.blueprint_compiler()
  return resolve({ "/usr/bin/blueprint-compiler", "blueprint-compiler" })
end

return M
