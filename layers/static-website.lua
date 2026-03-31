local setup = require("LYRD.setup")

---@class LYRD.layer.StaticWebSite: LYRD.setup.Module
local L = { name = "Static web sites: Hugo" }

function L.settings()
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.hugo"))
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("hugo")
end

return L
