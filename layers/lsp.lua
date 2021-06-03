local setup = require 'setup'
local commands = require "layers.commands"

local L = {name = 'LSP'}

function L.plugins(s) setup.plugin(s, {'neovim/nvim-lspconfig'}) end

function L.settings(s)
    commands.implement(s, '*', {
        LYRDLSPFindReferences = ':lua vim.lsp.buf.references()',
        LYRDLSPFindCodeActions = ':lua vim.lsp.buf.code_action()',
        LYRDLSPFindLineDiagnostics = ':lua vim.lsp.diagnostic.show_line_diagnostics()',
        LYRDLSPFindImplementations = ':lua vim.lsp.buf.implementation()',
        LYRDLSPFindDefinitions = ':lua vim.lsp.buf.definition()',
        LYRDLSPFindDeclaration = ':lua vim.lsp.buf.declaration()',
        LYRDLSPHoverInfo = ':lua vim.lsp.buf.hover()',
        LYRDLSPSignatureHelp = ':lua vim.lsp.buf.signature_help()',
        LYRDLSPFindTypeDefinition = ':lua vim.lsp.buf.type_definition()',
        LYRDLSPRename = ':lua vim.lsp.buf.rename()',
        LYRDLSPGotoNextDiagnostic = ':lua vim.lsp.diagnostic.goto_next()',
        LYRDLSPGotoPrevDiagnostic = ':lua vim.lsp.diagnostic.goto_prev()',
        LYRDLSPShowDiagnosticLocList = ':lua vim.lsp.diagnostic.set_loclist()'
    })
end

function L.enable(server, options)
    if options == nil then options = {} end
    require'lspconfig'[server].setup(options)
end

return L
