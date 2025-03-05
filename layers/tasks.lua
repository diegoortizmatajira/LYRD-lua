local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tasks" }

function L.plugins()
	setup.plugin({
		{
			--TODO: Make the most out of this one
			"stevearc/overseer.nvim",
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
				},
			},
		},
	})
end

function L.settings()
	commands.implement("*", {})
end

return L
