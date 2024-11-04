local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Docker" }

function L.toggle_lazydocker()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("lazydocker")
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})
end

return L
