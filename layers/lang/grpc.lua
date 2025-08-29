local setup = require("LYRD.setup")

---@type LYRD.setup.Module
local L = { name = "Grpc and Protobuffers" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
	local lsp = require("LYRD.layers.lsp")
	lsp.mason_ensure({
		"buf",
		"protolint",
	})
	lsp.null_ls_register_sources({
		require("null-ls.builtins.diagnostics.protolint"),
	})
end

function L.complete()
	vim.lsp.enable({ "buf_ls" })
end

return L
