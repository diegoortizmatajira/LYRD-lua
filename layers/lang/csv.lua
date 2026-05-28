local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
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

function L.settings()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers("csv", { ":CsvViewToggle" })
end

return declarative_layer.apply(L)
