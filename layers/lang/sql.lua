local setup = require("LYRD.setup")

---@type LYRD.setup.Module
local L = { name = "SQL Language" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
end

return L
