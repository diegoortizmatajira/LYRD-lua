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
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.protolint",
	},
}

return declarative_layer.apply(L)
