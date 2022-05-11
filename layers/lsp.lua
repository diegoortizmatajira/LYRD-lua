local setup = require'LYRD.setup'
local commands = require"LYRD.layers.commands"

local L = {name = 'LSP'}

local capabilities = nil

local plugged_capabilities = function()
  return vim.lsp.protocol.make_client_capabilities()
end

function L.plug_capabilities(plug_handler)
  plugged_capabilities = plug_handler(plugged_capabilities)
end

function L.plugins(s)
  setup.plugin(s, {'neovim/nvim-lspconfig', 'folke/trouble.nvim'})
end

function L.settings(s)

  local signs = {
    {name = "DiagnosticSignError", text = ""},
    {name = "DiagnosticSignWarn", text = ""},
    {name = "DiagnosticSignHint", text = ""},
    {name = "DiagnosticSignInfo", text = ""}
  }

  for _, sign in ipairs(signs) do vim.fn.sign_define(sign.name, {texthl = sign.name, text = sign.text, numhl = ""}) end

  local config = {
    virtual_text = true,
    -- show signs
    signs = {active = signs},
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {focusable = false, style = "minimal", border = "rounded", source = "always", header = "", prefix = ""}
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})

  require('trouble').setup()

  commands.implement(s, '*', {
    LYRDLSPFindReferences = ':lua vim.lsp.buf.references()',
    LYRDLSPFindCodeActions = ':lua vim.lsp.buf.code_action()',
    LYRDLSPFindRangeCodeActions = ':lua vim.lsp.buf.range_code_action()',
    LYRDLSPFindLineDiagnostics = ':lua vim.diagnostic.show_line_diagnostics()',
    LYRDLSPFindDocumentDiagnostics = ':TroubleToggle document_diagnostics',
    LYRDLSPFindWorkspaceDiagnostics = ':TroubleToggle workspace_diagnostics',
    LYRDLSPFindImplementations = ':lua vim.lsp.buf.implementation()',
    LYRDLSPFindDefinitions = ':lua vim.lsp.buf.definition()',
    LYRDLSPFindDeclaration = ':lua vim.lsp.buf.declaration()',
    LYRDLSPHoverInfo = ':lua vim.lsp.buf.hover()',
    LYRDLSPSignatureHelp = ':lua vim.lsp.buf.signature_help()',
    LYRDLSPFindTypeDefinition = ':lua vim.lsp.buf.type_definition()',
    LYRDLSPRename = ':lua vim.lsp.buf.rename()',
    LYRDLSPGotoNextDiagnostic = ':lua vim.diagnostic.goto_next()',
    LYRDLSPGotoPrevDiagnostic = ':lua vim.diagnostic.goto_prev()',
    LYRDLSPShowDocumentDiagnosticLocList = ':TroubleToggle document_diagnostics',
    LYRDLSPShowWorkspaceDiagnosticLocList = ':TroubleToggle workspace_diagnostics',
    LYRDViewLocationList = ':TroubleToggle loclist',
    LYRDViewQuickFixList = ':TroubleToggle quickfix'
  })
end

function L.enable(server, options)
  if capabilities == nil then capabilities = plugged_capabilities() end
  options = options or {}
  options.capabilities = options.capabilities or capabilities
  require'lspconfig'[server].setup(options)
end

return L
