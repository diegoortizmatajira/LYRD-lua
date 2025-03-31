local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Java language" }

function L.plugins()
	setup.plugin({})
end

function L.preparation() end

function L.settings()
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete() end

return L
