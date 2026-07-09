local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Nix (system configuring language)",
	required_mason_packages = {
		"nil",
		"alejandra",
	},
	required_treesitter_parsers = {
		"nix",
	},
	required_enabled_lsp_servers = {
		"nil_ls",
	},
	required_formatters = {
		["alejandra"] = require("LYRD.shared.conform.alejandra"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "nix",
			format_settings = { "alejandra" },
		},
	},
}

return declarative_layer.apply(L)
