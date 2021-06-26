local setup = require"LYRD.setup"
local L = {name = 'Snippets'}

function L.plugins(s)
  setup.plugin(s, {'sirver/ultisnips', 'honza/vim-snippets'})
end

function L.settings(_)
end

function L.keybindings(s)
  vim.g.UltiSnipsExpandTrigger = "<c-j>"
  vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
  vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
end

return L
