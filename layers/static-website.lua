---@type LYRD.setup.Module
local L = { name = "Static web sites" }

function L.settings()
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.hugo"))
end

return L
