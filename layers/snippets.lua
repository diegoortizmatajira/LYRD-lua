local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local L = { name = "Snippets" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
			dependencies = {
				"rafamadriz/friendly-snippets",
			},
		},
		"rafamadriz/friendly-snippets",
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
end

function L.keybindings(_) end

return L
