local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Bash",
	required_mason_packages = {
		"bashls",
	},
	required_enabled_lsp_servers = {
		"bashls",
	},
}

return declarative_layer.apply(L)
