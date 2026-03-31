local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Pascal language",
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
		"ptop",
	},
	required_formatters = {
		["ptop"] = require("LYRD.shared.conform.ptop"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "pascal",
			format_settings = { "ptop", lsp_format = "prefer" },
		},
	},
	required_test_adapters = {},
}

return declarative_layer.apply(L)
