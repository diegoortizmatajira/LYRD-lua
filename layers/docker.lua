local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")

local L = { name = "Docker" }

function L.toggle_lazydocker()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("lazydocker")
end

function L.preparation()
	lsp.mason_ensure({
		"dockerfile-language-server",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"dockerfile",
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("lazydocker")
end

return L
