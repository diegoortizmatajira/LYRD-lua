local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

---@class LYRD.layer.Bash: LYRD.setup.Module
local L = { name = "Bash" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
	lsp.mason_ensure({ "bashls" })
end

function L.complete()
	vim.lsp.enable("bashls")
end

return L
