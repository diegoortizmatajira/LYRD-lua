local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web frontend" }

function L.plugins()
	setup.plugin({
		{
			"leafgarland/typescript-vim",
			ft = { "ts", "tsx", "vue" },
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"vue-language-server",
		"angular-language-server",
		"node-debug2-adapter",
		"vtsls",
	})
	lsp.format_with_lsp("vue", "vue_ls")
	lsp.format_with_lsp("ts", "vtsls")
end

function L.settings() end

function L.complete()
	vim.lsp.enable({
		"vtsls",
		"vue_ls",
	})
end

return L
