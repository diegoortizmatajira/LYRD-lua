local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"
local L = {name = 'Snippets'}

function L.plugins(s)
  setup.plugin(s, {'sirver/ultisnips', 'honza/vim-snippets'})
end

function L.settings(_)
  -- Setup lspconfig.
  lsp.plug_capabilities(function(previous_plug)
    return function()
      local capabilities = previous_plug()
      capabilities.textDocument.completion.completionItem.snippetSupport = true;
      return capabilities
    end
  end)
  vim.g.UltiSnipsExpandTrigger = '<Plug>(ultisnips_expand)'
  vim.g.UltiSnipsJumpForwardTrigger = '<Plug>(ultisnips_jump_forward)'
  vim.g.UltiSnipsJumpBackwardTrigger = '<Plug>(ultisnips_jump_backward)'
  vim.g.UltiSnipsListSnippets = '<c-x><c-s>'
  vim.g.UltiSnipsRemoveSelectModeMappings = 0
end

function L.keybindings(_)
end

return L
