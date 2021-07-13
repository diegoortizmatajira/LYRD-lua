local setup = require'LYRD.setup'
local commands = require"LYRD.layers.commands"

local L = {name = 'LSP'}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;

function L.plugins(s)
  setup.plugin(s, {
    'neovim/nvim-lspconfig',
    'kabouzeid/nvim-lspinstall',
    'folke/trouble.nvim'
  })
end

function L.settings(s)
  require'lspinstall'.setup()

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {prefix = "»", spacing = 4},
    signs = true,
    update_in_insert = false
  })
  vim.fn.sign_define('LspDiagnosticsSignError',
    {texthl = 'LspDiagnosticsSignError', text = '', numhl = 'LspDiagnosticsSignError'})
  vim.fn.sign_define('LspDiagnosticsSignWarning',
    {texthl = 'LspDiagnosticsSignWarning', text = '', numhl = 'LspDiagnosticsSignWarning'})
  vim.fn.sign_define('LspDiagnosticsSignHint',
    {texthl = 'LspDiagnosticsSignHint', text = '', numhl = 'LspDiagnosticsSignHint'})
  vim.fn.sign_define('LspDiagnosticsSignInformation',
    {texthl = 'LspDiagnosticsSignInformation', text = '', numhl = 'LspDiagnosticsSignInformation'})
  commands.implement(s, '*', {
    LYRDLSPFindReferences = ':lua vim.lsp.buf.references()',
    LYRDLSPFindCodeActions = ':lua vim.lsp.buf.code_action()',
    LYRDLSPFindLineDiagnostics = ':lua vim.lsp.diagnostic.show_line_diagnostics()',
    LYRDLSPFindDocumentDiagnostics = ':TroubleToggle lsp_document_diagnostics',
    LYRDLSPFindWorkspaceDiagnostics = ':TroubleToggle lsp_workspace_diagnostics',
    LYRDLSPFindImplementations = ':lua vim.lsp.buf.implementation()',
    LYRDLSPFindDefinitions = ':lua vim.lsp.buf.definition()',
    LYRDLSPFindDeclaration = ':lua vim.lsp.buf.declaration()',
    LYRDLSPHoverInfo = ':lua vim.lsp.buf.hover()',
    LYRDLSPSignatureHelp = ':lua vim.lsp.buf.signature_help()',
    LYRDLSPFindTypeDefinition = ':lua vim.lsp.buf.type_definition()',
    LYRDLSPRename = ':lua vim.lsp.buf.rename()',
    LYRDLSPGotoNextDiagnostic = ':lua vim.lsp.diagnostic.goto_next()',
    LYRDLSPGotoPrevDiagnostic = ':lua vim.lsp.diagnostic.goto_prev()',
    LYRDLSPShowDocumentDiagnosticLocList = ':TroubleToggle lsp_document_diagnostics',
    LYRDLSPShowWorkspaceDiagnosticLocList = ':TroubleToggle lsp_workspace_diagnostics',
    LYRDViewLocationList = ':TroubleToggle loclist',
    LYRDViewQuickFixList = ':TroubleToggle quickfix'
  })
  require("trouble").setup{}
end

function L.enable(server, options)
  if options == nil then options = {} end
  if options.capabilities == nil then options.capabilities = capabilities end
  require'lspconfig'[server].setup(options)
end

return L
