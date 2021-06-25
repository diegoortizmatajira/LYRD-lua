local setup = require"LYRD.setup"
local mappings = require"LYRD.layers.mappings"
local commands = require"LYRD.layers.commands"
local L = {name = 'Snippets'}

function L.plugins(s)
  setup.plugin(s, {'hrsh7th/vim-vsnip', 'hrsh7th/vim-vsnip-integ', 'rafamadriz/friendly-snippets'})
end

function L.settings(s)
  vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"
  vim.g.vsnip_filetypes = {javascriptreact = {'javascript'}, typescriptreact = {'typescript'}}
  commands.implement(s, '*', {
    LYRDSnippetTab = [[vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>']],
    LYRDSnippetShiftTab = [[vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']],
    LYRDSnippetExpand = [[vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>']],
    LYRDSnippetExpandOrJump = [[vsnip#expandable(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']]
  })
end

function L.keybindings(s)
  s.SharedExpressions.Tab.snippets = function()
    return nil
  end

  mappings.keys(s, {
    {'i', '<C-j>', e('LYRDSnippetExpand')},
    {'s', '<C-j>', e('LYRDSnippetExpand')},
    {'i', '<C-l>', e('LYRDSnippetExpandOrJump')},
    {'s', '<C-l>', e('LYRDSnippetExpandOrJump')}
  }, {silent = true, expr = true, noremap = true})
end

return L
