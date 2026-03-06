local concrete_module = require("LYRD.shared.concrete_module")

local L = concrete_module:new({
	name = "CSV",
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
})

return L
