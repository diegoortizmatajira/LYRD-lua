local concrete_module = require("LYRD.shared.concrete_module")

local L = concrete_module:new({
	name = "Bash",
	required_mason_packages = {
		"bashls",
	},
	required_enabled_lsp_servers = {
		"bashls",
	},
})

return L
