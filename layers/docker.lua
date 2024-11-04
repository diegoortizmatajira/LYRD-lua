local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Docker" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"mgierada/lazydocker.nvim",
			dependencies = { "akinsho/toggleterm.nvim" },
			opts = {},
		},
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{
			cmd.LYRDContainersUI,
			function()
				require("lazydocker").open()
			end,
		},
	})
end

return L
