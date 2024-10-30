local setup = require("LYRD.setup")

local L = { name = "Development" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"numToStr/Comment.nvim",
			opts = {},
		},
		{
			"norcalli/nvim-colorizer.lua",
			opts = {},
		},
		{
			"windwp/nvim-autopairs",
			opts = {},
		},
		{
			"kylechui/nvim-surround",
			opts = {},
		},
	})
end

function L.settings(_) end

return L
