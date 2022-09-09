local setup = require("LYRD.setup")

local L = { name = "Development" }

function L.plugins(s)
	setup.plugin(s, {
		"numToStr/Comment.nvim",
		"norcalli/nvim-colorizer.lua",
		"windwp/nvim-autopairs",
		"kylechui/nvim-surround",
	})
end

function L.settings(_)
	require("Comment").setup()
	require("colorizer").setup()
	require("nvim-autopairs").setup({})
	require("nvim-surround").setup({})
end

return L
