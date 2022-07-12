local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"
local L = {name = 'Snippets'}

function L.plugins(s)
  setup.plugin(s, {'L3MON4D3/LuaSnip', 'rafamadriz/friendly-snippets'})
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
  require("luasnip.loaders.from_vscode").lazy_load()
end

function L.keybindings(_)
end

return L
