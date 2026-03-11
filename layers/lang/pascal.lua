local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Pascal",
	required_plugins = {},
	required_mason_packages = {
		"pascal-language-server",
	},
	required_treesitter_parsers = {
		"pascal",
	},
	required_enabled_lsp_servers = {
		"pasls",
	},
	required_executables = {
		"pfc",
	},
	required_formatters = {},
	required_formatter_per_filetype = {},
	required_test_adapters = {},
}

return declarative_layer.apply(L)
