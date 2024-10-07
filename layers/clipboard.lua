local setup = require("LYRD.setup")

local L = { name = "Clipboard" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	vim.opt.clipboard = "unnamed,unnamedplus"
	-- vim.g.clipboard = {
	-- 	name = "OSC 52",
	-- 	copy = {
	-- 		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
	-- 		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	-- 	},
	-- 	paste = {
	-- 		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
	-- 		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	-- 	},
	-- }
	-- if vim.env.TMUX ~= nil then
	-- 	local copy = { "tmux", "load-buffer", "-w", "-" }
	-- 	local paste = { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
	-- 	vim.g.clipboard = {
	-- 		name = "tmux",
	-- 		copy = {
	-- 			["+"] = copy,
	-- 			["*"] = copy,
	-- 		},
	-- 		paste = {
	-- 			["+"] = paste,
	-- 			["*"] = paste,
	-- 		},
	-- 		cache_enabled = 0,
	-- 	}
	-- end

end

return L

