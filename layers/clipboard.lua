local L = { name = "Clipboard" }

function L.settings(_)
	if not vim.env.SSH_TTY or vim.fn.has("nvim-0.10") ~= 1 then -- only set `clipboard` if in SSH session and in neovim 0.10+
		vim.opt.clipboard = "unnamed,unnamedplus"
	end

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
