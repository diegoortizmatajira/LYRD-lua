local setup = require("LYRD.setup")

local L = { name = "Clipboard" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	vim.opt.clipboard = "unnamed,unnamedplus"
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
end

return L
