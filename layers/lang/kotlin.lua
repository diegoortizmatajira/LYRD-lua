local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Kotlin Language" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
	lsp.mason_ensure({
		"kotlin-language-server",
	})
end

function L.settings() end

function L.keybindings() end

function L.complete()
	lsp.enable("kotlin_language_server", {})
end

return L
