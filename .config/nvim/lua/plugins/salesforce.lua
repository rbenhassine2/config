-- Salesforce / Apex language support.
--
-- Apex:      the Java Jorje server (lspconfig `apex_ls`), jar taken from the
--            VS Code extension. This is the engine that actually resolves
--            references; the newer TS Apex server is not used here.
-- LWC:       `lwc_ls` pointed at the bundled lwcServer.js, scoped to /lwc/.
-- Aura:      custom server pointed at the bundled auraServer.js, scoped to /aura/.
-- SOQL:      custom server pointed at the bundled soql server (.soql buffers).
-- Visualforce: `visualforce_ls` pointed at the bundled visualforceServer.js.
-- SLDS:      optional Java validator for LWC markup/JS/CSS.
--
-- Every path is resolved through config.sf; when an extension is not present the
-- corresponding server is simply not registered, mirroring toolchain.lua.

local sf = require("config.sf")

-- ---------------------------------------------------------------------------
-- Filetype detection
-- ---------------------------------------------------------------------------
vim.filetype.add({
  extension = {
    cls = "apex",
    trigger = "apex",
    apex = "apexcode",
    page = "visualforce",
    component = "visualforce",
    soql = "soql",
    sosl = "sosl",
    sflog = "sflog",
    -- Aura markup (parsed as HTML by the aura server, which also understands
    -- the {!...} expressions).
    cmp = "html",
    app = "html",
    evt = "html",
    intf = "html",
    design = "html",
    auradoc = "html",
  },
})

-- `.cls` is also LaTeX's class extension, and TeX tooling (e.g. vimtex) detects
-- it as `tex` via ftdetect, which runs after vim.filetype. Re-map it to `apex`
-- when the file actually lives in a Salesforce DX project.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name:sub(-4) == ".cls" and sf.project_root(args.buf) then
      vim.bo[args.buf].filetype = "apex"
    end
  end,
})

-- Aura markup may also be picked up by other ftdetect rules; enforce it inside
-- an SFDX project (scoped so unrelated .cmp/.app files are untouched).
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.cmp", "*.app", "*.evt", "*.intf", "*.design", "*.auradoc" },
  callback = function(args)
    if sf.project_root(args.buf) then
      vim.bo[args.buf].filetype = "html"
    end
  end,
})

-- Bootstrap/refresh the language-server artifacts. `:SfInstallServers` copies
-- from a local VS Code install when present, otherwise downloads the VSIX from
-- the Marketplace and extracts it -- no VS Code installation required.
-- `:SfVendorServers` forces the local-copy path only.
vim.api.nvim_create_user_command("SfInstallServers", function(args)
  local force = args.bang
  vim.notify("Salesforce: installing language servers (this may take a minute)...", vim.log.levels.INFO)
  vim.schedule(function()
    local copied, downloaded, failed = sf.install_servers({ force = force })
    local msg = string.format(
      "Salesforce servers: %d copied, %d downloaded, %d failed%s",
      #copied,
      #downloaded,
      #failed,
      (#failed > 0 and (": " .. table.concat(failed, ", ")) or "")
    )
    vim.notify(msg, #failed > 0 and vim.log.levels.ERROR or vim.log.levels.INFO)
  end)
end, { bang = true, desc = "Salesforce: install/refresh LSP servers (Marketplace if needed)" })

vim.api.nvim_create_user_command("SfVendorServers", function()
  local copied, failed = sf.vendor_servers()
  vim.notify(
    string.format(
      "Salesforce: copied %d from local VS Code install%s",
      #copied,
      (#failed > 0 and ("; missing: " .. table.concat(failed, ", ")) or "")
    ),
    #failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
  )
end, { desc = "Salesforce: copy LSP servers from a local VS Code install" })

-- Fresh-machine hint: inside a Salesforce project with no server artifacts,
-- tell the user to bootstrap them. Does not auto-download.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if sf.project_root(0) and not sf.apex_jar() then
      vim.notify(
        "Salesforce: language servers not installed. Run :SfInstallServers, then restart Neovim.",
        vim.log.levels.WARN
      )
    end
  end,
})

-- ---------------------------------------------------------------------------
-- LSP server definitions
-- ---------------------------------------------------------------------------
local servers = {}

-- Apex (Java Jorje).
local apex_jar = sf.apex_jar()
if apex_jar then
  servers.apex_ls = {
    mason = false,
    apex_jar_path = apex_jar,
    apex_jvm_max_heap = "2048m",
    apex_enable_semantic_errors = true,
    apex_enable_completion_statistics = false,
  }
end

-- Lightning Web Components (only inside /lwc/).
local lwc_cmd = sf.lwc_cmd()
if lwc_cmd then
  servers.lwc_ls = {
    mason = false,
    cmd = lwc_cmd,
    filetypes = { "javascript", "html" },
    init_options = {
      workspaceType = "SFDX",
      sfdxTypingsDir = sf.lwc_typings(),
      embeddedLanguages = { javascript = true },
    },
    root_dir = function(bufnr, on_dir)
      if sf.in_lwc(bufnr) then
        on_dir(sf.project_root(bufnr))
      end
    end,
  }
end

-- Aura components (only inside /aura/). The server advertises support for the
-- underlying html/xml/json/javascript languages, so it is gated by directory.
local aura_cmd = sf.aura_cmd()
if aura_cmd then
  servers.aura_ls = {
    mason = false,
    cmd = aura_cmd,
    filetypes = { "html", "xml", "javascript", "json" },
    init_options = { workspaceType = "SFDX" },
    root_dir = function(bufnr, on_dir)
      if sf.in_aura(bufnr) then
        on_dir(sf.project_root(bufnr))
      end
    end,
  }
end

-- Visualforce (.page / .component).
local vf_cmd = sf.visualforce_cmd()
if vf_cmd then
  servers.visualforce_ls = {
    mason = false,
    cmd = vf_cmd,
    init_options = { embeddedLanguages = { css = true, javascript = true } },
  }
end

-- SOQL (standalone .soql buffers). Syntax-level assistance only: the server's
-- sObject/field completions are resolved client-side in VS Code.
local soql_cmd = sf.soql_cmd()
if soql_cmd then
  servers.soql_ls = {
    mason = false,
    cmd = soql_cmd,
    filetypes = { "soql" },
    root_dir = function(bufnr, on_dir)
      on_dir(sf.project_root(bufnr))
    end,
  }
end

-- SLDS validator (LWC markup/JS/CSS). Spring Boot fat jar; force stream mode and
-- silence its stdout logging so it does not corrupt the LSP channel.
local slds_cmd = sf.slds_cmd()
if slds_cmd then
  servers.slds_ls = {
    mason = false,
    cmd = slds_cmd,
    filetypes = { "html", "javascript", "css" },
    root_dir = function(bufnr, on_dir)
      if sf.in_lwc(bufnr) then
        on_dir(sf.project_root(bufnr))
      end
    end,
  }
end

-- ---------------------------------------------------------------------------
return {
  -- Parsers used by sf.nvim's log/metadata views and for highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "apex", "soql", "sosl", "sflog" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = servers,
    },
  },
}
