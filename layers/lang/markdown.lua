local setup = require("LYRD.setup")

local L = { name = "Markdown" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"MeanderingProgrammer/markdown.nvim",
			main = "render-markdown",
			opts = {},
			dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		},
	})
end

function L.settings(_) end

return L
