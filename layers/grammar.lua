local lsp = require("LYRD.layers.lsp")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Grammar: LYRD.setup.Module
local L = { name = "Grammar Checking" }

local enabled = false

local function toggle()
	enabled = not enabled
	vim.lsp.enable("harper_ls", enabled)
	if not enabled then
		-- Stop active harper_ls clients
		for _, client in ipairs(vim.lsp.get_clients({ name = "harper_ls" })) do
			client:stop()
		end
	end
	vim.notify("Grammar checker " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function L.preparation()
	lsp.mason_ensure({
		"harper-ls",
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDGrammarToggle, toggle },
	})
end

return L
