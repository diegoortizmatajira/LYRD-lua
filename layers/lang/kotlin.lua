local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Kotlin Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(s)
	lsp.mason_ensure({
		"kotlin-language-server",
	})
end

function L.keybindings(s) end

function L.complete(s)
	lsp.enable("kotlin_language_server", {})
end

return L
