local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"

local L = {name = 'TypeScript Language'}

function L.plugins(s)
  setup.plugin(s, {'pangloss/vim-javascript', 'leafgarland/typescript-vim'})
end

function L.settings(_)
  vim.g.javascript_plugin_jsdoc = 1
  vim.g.javascript_plugin_ngdoc = 1
  vim.g.javascript_plugin_flow = 1
end

function L.complete(_)
  lsp.enable('tsserver', {})
end

return L
