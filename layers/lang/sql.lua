local setup = require("LYRD.setup")

---@class LYRD.layer.lang.Sql: LYRD.setup.Module
local L = { name = "SQL Language" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
end

return L
