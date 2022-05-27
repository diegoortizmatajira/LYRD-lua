local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'Buffer format'}
local custom_formatters = {}

function L.plugins(s)
  setup.plugin(s, {'mhartington/formatter.nvim'})
end

function L.settings(s)
  commands.implement(s, '*', {LYRDBufferFormat = ':Format'})
end

function L.complete(_)
  -- Sets the formatters provided by all the other layers
  require('formatter').setup{filetype = custom_formatters}
end

function L.add_formatters(file_type, formatters)
  custom_formatters[file_type] = formatters
end

return L
