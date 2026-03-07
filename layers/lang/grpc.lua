local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Grpc and Protobuffers",
	required_mason_packages = {
		"buf",
		"protolint",
	},
	required_enabled_lsp_servers = {
		"buf_ls",
	},
}

function L.preparation()
	local lsp = require("LYRD.layers.lsp")
	lsp.null_ls_register_sources({
		require("null-ls.builtins.diagnostics.protolint"),
	})
end

return declarative_layer.apply(L)
