local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "CSV" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"hat0uma/csvview.nvim",
			opts = {
				view = {
					display_mode = "border",
				},
			},
			ft = { "csv", "tsv" },
		},
	})
end

return L
