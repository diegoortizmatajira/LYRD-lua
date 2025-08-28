local setup = require("LYRD.setup")

local L = { name = "CSV" }

function L.preparation()
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"csv",
		"tsv",
	})
end
function L.plugins()
	setup.plugin({
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
