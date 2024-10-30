local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Kotlin Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.preparation(_)
	lsp.mason_ensure({
		"kotlin-language-server",
	})
end

function L.settings(_) end

function L.keybindings(_) end

function L.complete(_)
	lsp.enable("kotlin_language_server", {})
end

return L
