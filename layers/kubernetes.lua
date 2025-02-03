local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Kubernetes" }

function L.toggle_k9s()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("k9s")
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDKubernetesUI, L.toggle_k9s },
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("k9s")
end

return L
