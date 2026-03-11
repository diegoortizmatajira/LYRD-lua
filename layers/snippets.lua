local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.utils")

---@class LYRD.layer.Snippets: LYRD.setup.Module
local L = {
	name = "Snippets",
	snippets_path = utils.get_lyrd_path("snippets"),
}

function L.plugins()
	setup.plugin({
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			opts = {
				history = true,
				delete_check_events = "TextChanged",
				region_check_events = "CursorMoved",
			},
			config = function(_, opts)
				if opts then
					require("luasnip").config.setup(opts)
				end
				vim.tbl_map(function(type)
					require("luasnip.loaders.from_" .. type).lazy_load()
				end, { "vscode", "snipmate", "lua" })
				-- Load snippets from LYRD's custom snippets path.
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = { L.snippets_path },
				})
				-- friendly-snippets - enable standardized comments snippets
				require("luasnip").filetype_extend("typescript", { "tsdoc" })
				require("luasnip").filetype_extend("javascript", { "jsdoc" })
				require("luasnip").filetype_extend("lua", { "luadoc" })
				require("luasnip").filetype_extend("python", { "pydoc" })
				require("luasnip").filetype_extend("rust", { "rustdoc" })
				require("luasnip").filetype_extend("cs", { "csharpdoc" })
				require("luasnip").filetype_extend("java", { "javadoc" })
				require("luasnip").filetype_extend("c", { "cdoc" })
				require("luasnip").filetype_extend("cpp", { "cppdoc" })
				require("luasnip").filetype_extend("php", { "phpdoc" })
				require("luasnip").filetype_extend("kotlin", { "kdoc" })
				require("luasnip").filetype_extend("ruby", { "rdoc" })
				require("luasnip").filetype_extend("sh", { "shelldoc" })
				-- HTML snippets for frontend frameworks
				require("luasnip").filetype_extend("vue", { "html" })
				require("luasnip").filetype_extend("htmlangular", { "html" })
				require("luasnip").filetype_extend("svelte", { "html" })
				require("luasnip").filetype_extend("javascriptreact", { "html" })
				require("luasnip").filetype_extend("typescriptreact", { "html" })
			end,
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
			dependencies = {
				"rafamadriz/friendly-snippets",
				"zeioth/NormalSnippets",
				"benfowler/telescope-luasnip.nvim",
			},
		},
		{
			"chrisgrieser/nvim-scissors",
			dependencies = "nvim-telescope/telescope.nvim",
			opts = {
				snippetDir = L.snippets_path,
			},
		},
	})
end

function L.settings()
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
		{ cmd.LYRDSearchSnippets, ":Telescope luasnip" },
	})
end

return L
