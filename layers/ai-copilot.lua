local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "AI - Copilot" }

function L.plugins(s)
	setup.plugin(s, {
		{ "github/copilot.vim" },
	})
end

function L.settings(s)
	vim.g.copilot_no_tab_map = false
	commands.implement("*", {
		{ cmd.LYRDSmartCoder, ":Copilot" },
	})
end

return L
