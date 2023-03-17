local lsp = require("LYRD.layers.lsp")

local L = { name = "CMake Language" }

function L.plugins(_) end

function L.settings(_)
	lsp.mason_ensure({
		"cmake-language-server",
	})
end

function L.keybindings(_) end

function L.complete(_)
	lsp.enable("cmake", {})
end

return L
