local setup = require("LYRD.setup")

local L = { name = "Development" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"numtostr/comment.nvim",
		},
		{
			"norcalli/nvim-colorizer.lua",
		},
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
		{
			"kylechui/nvim-surround",
			version = "*", -- Use for stability; omit to use `main` branch for the latest features
			event = "VeryLazy",
			opts = {},
		},
	})
end

function L.settings(_)
	-- TODO: Include on CMP
	-- -- If you want insert `(` after select function or method item
	-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	-- local cmp = require('cmp')
	-- cmp.event:on(
	--   'confirm_done',
	--   cmp_autopairs.on_confirm_done()
	-- )
end

return L
