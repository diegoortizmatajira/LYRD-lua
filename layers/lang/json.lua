local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"

local L = {name = 'Json documents'}

function L.plugins(s)
  setup.plugin(s, {"b0o/schemastore.nvim"})
end

function L.settings(_)
end

function L.keybindings(_)
end

function L.complete(_)
  lsp.enable('jsonls',
    {settings = {json = {schemas = require("schemastore").json.schemas(), validate = {enabled = true}}}})
end

return L
