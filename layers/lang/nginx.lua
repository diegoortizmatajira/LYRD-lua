local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Nginx",
	required_mason_packages = {
		-- "nginx-language-server",
		"nginx-config-formatter",
	},
	required_treesitter_parsers = {
		"nginx",
	},
	required_enabled_lsp_servers = {
		-- "nginx_language_server",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = { "nginx" },
			format_settings = { "nginxfmt" },
		},
	},
}

return declarative_layer.apply(L)
