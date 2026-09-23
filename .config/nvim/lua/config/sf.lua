-- Salesforce/Apex tooling integration for this LazyVim setup.
--
-- This mirrors the role of config/toolchain.lua, but for Salesforce: it resolves
-- the language-server executables that ship inside the VS Code Salesforce
-- extension pack, plus the `sf` CLI, and offers small helpers for running CLI
-- commands against the current SFDX project.
--
-- Why reuse the VS Code servers: Salesforce publishes no standalone Apex IDE.
-- The Apex Jorje server, and the LWC/Aura/SOQL/Visualforce servers, are ordinary
-- stdio/socket LSP servers bundled in the .vsix packages. Resolving them by glob
-- (rather than a hardcoded path) keeps this working across extension updates and
-- degrades to nil so callers can skip the server instead of spawning a broken
-- command -- the same policy as toolchain.lua.

local M = {}

M.ext_dir = vim.fn.expand("~/.vscode/extensions")

-- ---------------------------------------------------------------------------
-- Version-aware resolution of bundled VS Code servers
-- ---------------------------------------------------------------------------

-- Extract a numeric version tuple from the extension directory and the file
-- name, so `...-vscode-apex-67.9.0` sorts below `...-vscode-apex-67.18.2`.
local function version_key(path)
  local rel = path:sub(#M.ext_dir + 2)
  local extdir = rel:match("^([^/]+)") or rel
  local file = vim.fn.fnamemodify(path, ":t")
  local v = {}
  for n in (extdir .. "-" .. file):gmatch("%d+") do
    v[#v + 1] = tonumber(n)
  end
  return v
end

local function cmp_versions(a, b)
  local va, vb = version_key(a), version_key(b)
  for i = 1, math.max(#va, #vb) do
    local x, y = va[i] or 0, vb[i] or 0
    if x ~= y then
      return x < y
    end
  end
  return false
end

--- Return the newest path matching a glob relative to ~/.vscode/extensions,
--- or nil when nothing matches.
---@param pattern string
---@return string|nil
function M.vsix(pattern)
  local matches = vim.fn.glob(M.ext_dir .. "/" .. pattern, false, true)
  if #matches == 0 then
    return nil
  end
  table.sort(matches, cmp_versions)
  return matches[#matches]
end

-- ---------------------------------------------------------------------------
-- Server resolution: prefer managed installs, fall back to the VS Code bundle
-- ---------------------------------------------------------------------------
--
-- Order of preference for each server:
--   1. Mason-managed artifact (apex jar under share/, or a bin under mason/bin)
--   2. npm global bin (nvm) -- used for Aura, which has no Mason package
--   3. the file bundled inside the installed VS Code extension (last resort)
--
-- This keeps the setup working without VS Code for Apex/LWC/Visualforce/Aura,
-- while remaining functional if the VS Code extensions are the only source.

local function exists(path)
  return path ~= nil and vim.uv.fs_stat(path) ~= nil
end

local function executable(path)
  return path ~= nil and vim.fn.executable(path) == 1
end

function M.mason_dir()
  return vim.fn.stdpath("data") .. "/mason"
end

-- Artifacts we vendor ourselves (currently the Apex jar, copied out of the
-- VSIX so runtime no longer depends on the extension remaining installed).
function M.vendor_dir()
  return vim.fn.stdpath("data") .. "/salesforce-ls"
end

--- Resolve an executable from mason/bin, then nvm global bins, then PATH.
function M.find_bin(name)
  local m = M.mason_dir() .. "/bin/" .. name
  if executable(m) then
    return m
  end
  local nvm = vim.fn.glob(vim.fn.expand("~/.nvm/versions/node/*/bin/" .. name), false, true)
  if #nvm > 0 then
    table.sort(nvm)
    return nvm[#nvm]
  end
  local p = vim.fn.exepath(name)
  if p ~= "" then
    return p
  end
  return nil
end

--- Apex (Java Jorje): Mason share dir, then a vendored copy, then the VSIX.
function M.apex_jar()
  local mason = M.mason_dir() .. "/share/apex-language-server/apex-jorje-lsp.jar"
  if exists(mason) then
    return mason
  end
  local vendored = M.vendor_dir() .. "/apex/apex-jorje-lsp.jar"
  if exists(vendored) then
    return vendored
  end
  return M.vsix("salesforce.salesforcedx-vscode-apex-*/dist/apex-jorje-lsp.jar")
end

--- LWC: vendored server, else Mason/npm bin, else the bundled lwcServer.js.
function M.lwc_cmd()
  local js = M.vendor_dir() .. "/lwc/lwcServer.js"
  if exists(js) then
    return { "node", js, "--stdio" }
  end
  local b = M.find_bin("lwc-language-server")
  if b then
    return { b, "--stdio" }
  end
  js = M.vsix("salesforce.salesforcedx-vscode-lwc-*/dist/lwcServer.js")
  return js and { "node", js, "--stdio" } or nil
end

function M.lwc_typings()
  local mason = M.mason_dir() .. "/packages/lwc-language-server/node_modules/@salesforce/lwc-language-server/resources/sfdx/typings"
  if vim.fn.isdirectory(mason) == 1 then
    return mason
  end
  return M.vsix("salesforce.salesforcedx-vscode-lwc-*/resources/sfdx/typings")
end

--- Aura: npm global bin, else the bundled auraServer.js.
function M.aura_cmd()
  local b = M.find_bin("aura-language-server")
  if b then
    return { b, "--stdio" }
  end
  local js = M.vsix("salesforce.salesforcedx-vscode-lightning-*/dist/auraServer.js")
  return js and { "node", js, "--stdio" } or nil
end

--- SOQL: no standalone package exists; prefer the vendored copy, else VSIX.
function M.soql_cmd()
  local js = M.vendor_dir() .. "/soql/server.js"
  if not exists(js) then
    js = M.vsix("salesforce.salesforcedx-vscode-soql-*/dist/server.js")
  end
  return js and { "node", js, "--stdio" } or nil
end

--- Visualforce: vendored server, else Mason bin, else the bundled server.
function M.visualforce_cmd()
  local js = M.vendor_dir() .. "/visualforce/visualforceServer.js"
  if exists(js) then
    return { "node", js, "--stdio" }
  end
  local b = M.find_bin("visualforce-language-server")
  if b then
    return { b, "--stdio" }
  end
  js = M.vsix("salesforce.salesforcedx-vscode-visualforce-*/dist/visualforceServer.js")
  return js and { "node", js, "--stdio" } or nil
end

--- SLDS validator: prefer the vendored jar, else the VSIX.
function M.slds_cmd()
  local jar = M.vendor_dir() .. "/slds/lsp-executable.jar"
  if not exists(jar) then
    jar = M.vsix("salesforce.salesforce-vscode-slds-*/lsp-*-executable.jar")
  end
  if not jar then
    return nil
  end
  return {
    M.java_bin(),
    "-jar",
    jar,
    "--MODE=STREAM",
    "--spring.main.banner-mode=off",
    "--logging.level.root=OFF",
  }
end

function M.replay_adapter()
  local js = M.vendor_dir() .. "/replay/apexReplayDebug.js"
  if exists(js) then
    return js
  end
  return M.vsix("salesforce.salesforcedx-vscode-apex-replay-debugger-*/dist/apexReplayDebug.js")
end

-- ---------------------------------------------------------------------------
-- Server bootstrap (no VS Code required)
-- ---------------------------------------------------------------------------
--
-- Artifacts are copied from a locally installed VS Code extension when present
-- (fast, no network), otherwise downloaded from the VS Code Marketplace and
-- extracted. The Marketplace is used because the GitHub release assets for the
-- larger extensions were unreliable, and because it needs no VS Code install.
--
-- Requirements: curl (or wget), gzip, unzip, node. Aura is separate (npm).

M.artifacts = {
  {
    name = "apex",
    ext = "salesforcedx-vscode-apex",
    version = "67.18.2",
    inner = "extension/dist/apex-jorje-lsp.jar",
    dst = "/apex/apex-jorje-lsp.jar",
    glob = "salesforce.salesforcedx-vscode-apex-*/dist/apex-jorje-lsp.jar",
  },
  {
    name = "lwc",
    ext = "salesforcedx-vscode-lwc",
    version = "67.18.2",
    inner = "extension/dist/lwcServer.js",
    dst = "/lwc/lwcServer.js",
    glob = "salesforce.salesforcedx-vscode-lwc-*/dist/lwcServer.js",
  },
  {
    name = "visualforce",
    ext = "salesforcedx-vscode-visualforce",
    version = "67.18.2",
    inner = "extension/dist/visualforceServer.js",
    dst = "/visualforce/visualforceServer.js",
    glob = "salesforce.salesforcedx-vscode-visualforce-*/dist/visualforceServer.js",
  },
  {
    name = "soql",
    ext = "salesforcedx-vscode-soql",
    version = "67.18.2",
    inner = "extension/dist/server.js",
    dst = "/soql/server.js",
    glob = "salesforce.salesforcedx-vscode-soql-*/dist/server.js",
  },
  {
    name = "replay",
    ext = "salesforcedx-vscode-apex-replay-debugger",
    version = "67.18.2",
    inner = "extension/dist/apexReplayDebug.js",
    dst = "/replay/apexReplayDebug.js",
    glob = "salesforce.salesforcedx-vscode-apex-replay-debugger-*/dist/apexReplayDebug.js",
  },
  {
    name = "slds",
    ext = "salesforce-vscode-slds",
    version = "2.0.12",
    inner = "extension/lsp-{{version}}-executable.jar",
    dst = "/slds/lsp-executable.jar",
    glob = "salesforce.salesforce-vscode-slds-*/lsp-*-executable.jar",
  },
}

--- Marketplace vspackage URL for a pinned VSIX version.
function M.marketplace_url(ext, version)
  return string.format(
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/salesforce/vsextensions/%s/%s/vspackage",
    ext,
    version
  )
end

local function is_gzip(path)
  local f = io.open(path, "rb")
  if not f then
    return false
  end
  local magic = f:read(2)
  f:close()
  return magic == "\31\139"
end

local function write_file(path, data)
  local f = io.open(path, "wb")
  if not f then
    return false
  end
  f:write(data)
  f:close()
  return true
end

local function download(url, dest)
  local cmd
  if vim.fn.executable("curl") == 1 then
    cmd = { "curl", "-fsSL", "-o", dest, url }
  elseif vim.fn.executable("wget") == 1 then
    cmd = { "wget", "-q", "-O", dest, url }
  else
    return false
  end
  local out = vim.system(cmd):wait()
  return out.code == 0 and exists(dest)
end

--- Extract `inner` from a (possibly gzipped) VSIX into `dest`.
local function extract_vsix(vsix, inner, dest)
  local zip = vsix
  local tmp
  if is_gzip(vsix) then
    local out = vim.system({ "gzip", "-dc", vsix }):wait()
    if out.code ~= 0 or not out.stdout then
      return false
    end
    tmp = vim.fn.tempname() .. ".zip"
    if not write_file(tmp, out.stdout) then
      return false
    end
    zip = tmp
  end
  local out = vim.system({ "unzip", "-p", zip, inner }):wait()
  if tmp then
    pcall(os.remove, tmp)
  end
  if out.code ~= 0 or not out.stdout or #out.stdout == 0 then
    return false
  end
  return write_file(dest, out.stdout)
end

--- Ensure all vendored artifacts exist. Copies from a local VS Code extension
--- when present; otherwise downloads the VSIX from the Marketplace. No VS Code
--- install is required. Returns three name lists: (copied, downloaded, failed).
---@param opts { force?: boolean, copy_only?: boolean, prefer_download?: boolean }|nil
function M.install_servers(opts)
  opts = opts or {}
  local copied, downloaded, failed = {}, {}, {}
  for _, a in ipairs(M.artifacts) do
    local to = M.vendor_dir() .. a.dst
    if not (exists(to) and not opts.force) then
      vim.fn.mkdir(vim.fn.fnamemodify(to, ":h"), "p")
      local inner = (a.inner:gsub("{{version}}", a.version))
      local ok = false
      if not opts.prefer_download then
        local from = M.vsix(a.glob)
        if from and vim.system({ "cp", "-f", from, to }):wait().code == 0 and exists(to) then
          ok = true
          copied[#copied + 1] = a.name
        end
      end
      if not ok and not opts.copy_only then
        local tmp = vim.fn.tempname() .. ".vspackage"
        if download(M.marketplace_url(a.ext, a.version), tmp) and extract_vsix(tmp, inner, to) then
          ok = true
          downloaded[#downloaded + 1] = a.name
        end
        pcall(os.remove, tmp)
      end
      if not ok then
        failed[#failed + 1] = a.name
      end
    end
  end
  return copied, downloaded, failed
end

--- Backward-compatible alias: copy from a local VS Code install only.
function M.vendor_servers()
  local copied, _, failed = M.install_servers({ copy_only = true, force = true })
  return copied, failed
end

-- ---------------------------------------------------------------------------
-- Java
-- ---------------------------------------------------------------------------

function M.java_bin()
  if vim.env.JAVA_HOME and vim.fn.executable(vim.env.JAVA_HOME .. "/bin/java") == 1 then
    return vim.env.JAVA_HOME .. "/bin/java"
  end
  return "java"
end

-- ---------------------------------------------------------------------------
-- sf CLI + project helpers
-- ---------------------------------------------------------------------------

-- `sf` is normally on PATH via nvm, but GUI/non-login launches may not inherit
-- it, so fall back to the newest nvm-managed copy.
function M.sf_bin()
  if vim.fn.executable("sf") == 1 then
    return "sf"
  end
  local candidates = vim.fn.glob(vim.fn.expand("~/.nvm/versions/node/*/bin/sf"), false, true)
  if #candidates > 0 then
    table.sort(candidates)
    return candidates[#candidates]
  end
  return "sf"
end

--- Root of the Salesforce DX project containing the given buffer (or cwd).
---@param bufnr integer|nil
---@return string|nil
function M.project_root(bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  local dir = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
  return vim.fs.root(dir, { "sfdx-project.json", ".forceignore" })
end

--- Run an `sf` subcommand asynchronously against the project root.
---@param args string[]
---@param opts { cwd?: string, on_exit?: fun(out: table)|nil }|nil
function M.run_sf(args, opts)
  opts = opts or {}
  local cmd = vim.list_extend({ M.sf_bin() }, args)
  return vim.system(cmd, {
    cwd = opts.cwd or M.project_root(0) or vim.fn.getcwd(),
    text = true,
  }, function(out)
    if opts.on_exit then
      opts.on_exit(out)
    end
  end)
end

--- True when the buffer/file lives under a Lightning Web Component folder.
function M.in_lwc(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  return name:find("/lwc/", 1, true) ~= nil
end

--- True when the buffer/file lives under an Aura component folder.
function M.in_aura(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  return name:find("/aura/", 1, true) ~= nil
end

-- ---------------------------------------------------------------------------
-- Formatting + Code Analyzer
-- ---------------------------------------------------------------------------

--- Project-local prettier first, so the project's prettier-plugin-apex is
--- resolvable; fall back to a PATH prettier.
function M.prettier_bin(bufnr)
  local root = M.project_root(bufnr or 0)
  if root then
    local p = root .. "/node_modules/.bin/prettier"
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  return "prettier"
end

--- Run `sf code-analyzer` on the given buffer and surface the violations as
--- quickfix entries and buffer diagnostics.
function M.scan_file(bufnr)
  bufnr = bufnr or 0
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("Salesforce: buffer has no file", vim.log.levels.WARN)
    return
  end

  local root = M.project_root(bufnr) or vim.fn.getcwd()
  local rel = vim.fn.fnamemodify(file, ":.")
  local out = vim.fn.tempname() .. ".json"

  vim.notify("Salesforce: running Code Analyzer...", vim.log.levels.INFO)
  vim.system(
    { M.sf_bin(), "code-analyzer", "run", "--target", rel, "--output-file", out },
    { cwd = root, text = true },
    function(res)
      vim.schedule(function()
        if res.code ~= 0 and vim.uv.fs_stat(out) == nil then
          vim.notify("Code Analyzer failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
          return
        end
        local ok, data = pcall(function()
          return vim.json.decode(table.concat(vim.fn.readfile(out), "\n"))
        end)
        if not ok or type(data) ~= "table" or type(data.violations) ~= "table" then
          vim.notify("Code Analyzer: no parseable results", vim.log.levels.WARN)
          return
        end

        local qf, diags = {}, {}
        for _, v in ipairs(data.violations) do
          local loc = (v.locations or {})[v.primaryLocationIndex or 1] or (v.locations or {})[1]
          if loc then
            local fname = loc.file or rel
            if not fname:match("^/") then
              fname = vim.fs.joinpath(root, fname)
            end
            qf[#qf + 1] = {
              filename = fname,
              lnum = loc.startLine or 1,
              col = loc.startColumn or 1,
              text = string.format("[%s] %s", v.rule or "?", v.message or ""),
              type = "W",
            }
            diags[#diags + 1] = {
              lnum = (loc.startLine or 1) - 1,
              col = (loc.startColumn or 1) - 1,
              message = string.format("%s (%s)", v.message or "", v.rule or "?"),
              severity = vim.diagnostic.severity.WARN,
              source = "sf-code-analyzer",
            }
          end
        end

        vim.fn.setqflist(qf, "r")
        vim.diagnostic.set(vim.api.nvim_create_namespace("sf_code_analyzer"), bufnr, diags)
        vim.notify(string.format("Code Analyzer: %d violation(s)", #qf), vim.log.levels.INFO)
        if #qf > 0 then
          vim.cmd("copen")
        end
      end)
    end
  )
end

-- ---------------------------------------------------------------------------
-- Debug logs (for the Apex Replay Debugger)
-- ---------------------------------------------------------------------------

--- List recent debug logs for the target org, newest first.
---@param cb fun(logs: table[])
function M.list_logs(cb)
  M.run_sf({ "apex", "list", "log", "--json" }, {
    on_exit = function(out)
      local ok, data = pcall(vim.json.decode, out.stdout or "")
      local logs = (ok and type(data) == "table" and type(data.result) == "table") and data.result or {}
      vim.schedule(function()
        cb(logs)
      end)
    end,
  })
end

--- Download a debug log by id into `dir`, then call cb(path).
---@param id string
---@param dir string
---@param cb fun(path: string|nil)
function M.fetch_log(id, dir, cb)
  vim.fn.mkdir(dir, "p")
  M.run_sf({ "apex", "get", "log", "-i", id, "-d", dir, "--json" }, {
    on_exit = function(out)
      local path
      local ok, data = pcall(vim.json.decode, out.stdout or "")
      if ok and type(data) == "table" and type(data.result) == "table" then
        path = data.result.log or (data.result.logs and data.result.logs[1])
      end
      if not path then
        local files = vim.fn.glob(dir .. "/*.log", false, true)
        table.sort(files)
        path = files[#files]
      end
      vim.schedule(function()
        cb(path)
      end)
    end,
  })
end

return M
