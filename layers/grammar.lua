local lsp = require("LYRD.layers.lsp")

---@class LYRD.layer.Grammar: LYRD.setup.Module
local L = { name = "Grammar" }

function L.preparation()
	lsp.mason_ensure({
		"harper-ls",
	})
end

function L.complete()
	vim.lsp.enable("harper_ls")
end

return L
