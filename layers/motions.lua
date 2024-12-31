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
		},
		{
			"chrisgrieser/nvim-spider",
			opts = {},
			keys = {
				-- Mapped commands need to be defined as Ex commands to be able repeatable
				{
					"e",
					"<cmd>lua require('spider').motion('e')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"w",
					"<cmd>lua require('spider').motion('w')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"b",
					"<cmd>lua require('spider').motion('b')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"ge",
					"<cmd>lua require('spider').motion('ge')<CR>",
					mode = { "n", "o", "x" },
				},
			},
		},
	})
end

function L.keybindings(s)
	mappings.leader(s, {
		{ { "n", "v" }, { "g" }, c("HopLine"), "Go to line" },
		{ { "n", "v" }, { "w" }, c("HopWord"), "Go to word" },
		{ { "n", "v" }, { "/" }, c("HopPattern"), "Go to pattern" },
	})
	mappings.keys(s, {
		{ { "n", "v" }, "s", "<cmd>HopChar1<CR>" },
		{ { "n", "v" }, "S", "<cmd>HopChar2<CR>" },
	})
end

return L
