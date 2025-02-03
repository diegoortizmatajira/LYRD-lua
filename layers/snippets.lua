local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.utils")
local L = {
	name = "Snippets",
	snippets_path = utils.get_lyrd_path() .. "/snippets",
}

function L.plugins(s)
	setup.plugin({
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = { L.snippets_path },
				})
			end,
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
			dependencies = {
				"rafamadriz/friendly-snippets",
			},
		},
		{ "rafamadriz/friendly-snippets" },
		{
			"chrisgrieser/nvim-scissors",
			dependencies = "nvim-telescope/telescope.nvim",
			opts = {
				snippetDir = L.snippets_path,
			},
		},
	})
end

function L.settings(_)
	-- Setup lspconfig.
	lsp.plug_capabilities(function(previous_plug)
		return function()
			local capabilities = previous_plug()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			return capabilities
		end
	end)
	commands.implement("*", {
		{
			cmd.LYRDCodeCreateSnippet,
			function()
				require("scissors").addNewSnippet()
			end,
		},
		{
			cmd.LYRDCodeEditSnippet,
			function()
				require("scissors").editSnippet()
			end,
		},
	})
end

return L
