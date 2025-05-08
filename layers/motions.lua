local setup = require("LYRD.setup")
local mappings = require("LYRD.layers.mappings")
local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut

local L = {
	name = "Motions",
	vscode_compatible = true,
}

function L.plugins()
	setup.plugin({
		{
			"smoka7/hop.nvim",
			version = "*",
			opts = {},
		},
		{
			"chrisgrieser/nvim-spider",
			opts = {
				skipInsignificantPunctuation = false,
				consistentOperatorPending = true,
			},
			keys = {
				-- Mapped commands need to be defined as Ex commands to be able repeatable
				{
					"<M-e>",
					"<cmd>lua require('spider').motion('e')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"<M-w>",
					"<cmd>lua require('spider').motion('w')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"<M-b>",
					"<cmd>lua require('spider').motion('b')<CR>",
					mode = { "n", "o", "x" },
				},
				{
					"<M-g><M-e>",
					"<cmd>lua require('spider').motion('ge')<CR>",
					mode = { "n", "o", "x" },
				},
			},
		},
	})
end

function L.keybindings()
	mappings.keys({
		{ { "n", "v" }, "<Leader>w", c("HopWord"), { desc = "Go to word" } },
		{ { "n", "v" }, "gl", c("HopLine"), { desc = "Go to line" } },
		{ { "n", "v" }, "g/", c("HopPattern"), { desc = "Go to pattern" } },
		{ { "n", "v" }, "s", "<cmd>HopChar1<CR>" },
		{ { "n", "v" }, "S", "<cmd>HopChar2<CR>" },
	})
end

return L
