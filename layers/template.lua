local setup = require("LYRD.setup")

local L = { name = "General" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.preparation(s) end

function L.settings(s) end

function L.keybindings(s) end

function L.complete(s) end

return L
