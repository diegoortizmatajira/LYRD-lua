local M = {}
local setup = require("LYRD.setup")

function M.check_executable(filename)
	if vim.fn.executable(filename) then
		vim.health.ok("'" .. filename .. "' executable is available.")
	else
		vim.health.warn("'" .. filename .. "' executable not is available.")
	end
end

function M.check()
	vim.health.start("LYRD Health Check")

	-- Add more checks as needed
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.healthcheck ~= nil then
			layer.healthcheck()
		end
	end
end

return M
