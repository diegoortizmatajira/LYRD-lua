local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

---@type LYRD.setup.Module
local L = { name = "Web frontend" }

function L.plugins()
	setup.plugin({
		{
			"pangloss/vim-javascript",
			init = function()
				vim.g.javascript_plugin_jsdoc = 1
				vim.g.javascript_plugin_ngdoc = 1
				vim.g.javascript_plugin_flow = 1
			end,
			ft = { "js" },
		},
		{
			"leafgarland/typescript-vim",
			ft = { "ts", "tsx", "vue" },
		},
		{
			"marilari88/neotest-vitest",
		},
		{
			"nvim-neotest/neotest-jest",
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"vue-language-server",
		"angular-language-server",
		"js-debug-adapter",
		"eslint-lsp",
		"vtsls",
	})
	lsp.format_with_lsp("vue", "vue_ls")
	lsp.format_with_lsp("ts", "vtsls")

	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"javascript",
		"typescript",
		"vue",
		"tsx",
		"angular",
	})

	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-vitest"))
	test.configure_adapter(require("neotest-jest"))

	-- Enable treesitter for Angular HTML files
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		pattern = { "*.component.html", "*.container.html" },
		callback = function()
			vim.treesitter.start(nil, "angular")
		end,
	})
end


function L.complete()
	vim.lsp.enable({
		"vtsls",
		"vue_ls",
		"angularls",
	})
end

return L
