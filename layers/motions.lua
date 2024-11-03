local setup = require("LYRD.setup")
local mappings = require("LYRD.layers.mappings")
local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut

local L = { name = "Motions" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"smoka7/hop.nvim",
			version = "*",
			opts = {},
			cmd = {
				"HopLine",
				"HopWord",
				"HopPattern",
				"HopChar1",
				"HopChar2",
			},
		},
	})
end

function L.settings(_)
	require("hop").setup({})
end

function L.keybindings(s)
	mappings.leader(s, {
		{ "", { "g" }, c("HopLine"), "Go to line" },
		{ "", { "w" }, c("HopWord"), "Go to word" },
		{ "", { "," }, c("HopPattern"), "Go to pattern" },
	})
	mappings.keys(s, { { "", "s", "<cmd>HopChar1<CR>" }, { "", "S", "<cmd>HopChar2<CR>" } })
end

return L
