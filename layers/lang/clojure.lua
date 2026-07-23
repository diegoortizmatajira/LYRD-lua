local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Clojure",
	required_mason_packages = {
		"clojure-lsp",
		"cljfmt",
	},
	required_treesitter_parsers = {
		"clojure",
	},
	required_enabled_lsp_servers = {
		"clojure_lsp",
	},
	required_executables = {
		"clojure",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "clojure",
			format_settings = { "cljfmt" },
		},
	},
}

return declarative_layer.apply(L)
