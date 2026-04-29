local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Bash Scripting",
	required_mason_packages = {
		"bashls",
		"shfmt",
		"shellcheck", -- ShellCheck is used by bashls for diagnostics, so we include it as a required Mason package.
	},
	required_enabled_lsp_servers = {
		"bashls",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "sh",
			format_settings = { "shfmt" },
		},
	},
}

return declarative_layer.apply(L)
