local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Ruby",
	required_mason_packages = {
		"solargraph",
		"rubocop",
	},
	required_treesitter_parsers = {
		"ruby",
	},
	required_enabled_lsp_servers = {
		"solargraph",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "ruby",
			format_settings = { "rubocop" },
		},
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.rubocop",
	},
}

return declarative_layer.apply(L)
