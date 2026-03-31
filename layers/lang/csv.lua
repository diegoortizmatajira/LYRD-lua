local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "CSV and TSV files",
	required_plugins = {
		{
			"hat0uma/csvview.nvim",
			opts = {
				view = {
					display_mode = "border",
				},
			},
			ft = { "csv", "tsv" },
		},
	},
	required_treesitter_parsers = {
		"csv",
		"tsv",
	},
}

return declarative_layer.apply(L)
