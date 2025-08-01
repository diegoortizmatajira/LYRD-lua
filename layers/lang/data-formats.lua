local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Data formats json, yaml, toml, xml" }

function L.plugins()
	setup.plugin({

		{ "b0o/schemastore.nvim" },
	})
end

function L.preparation()
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"lemminx",
		"prettier",
		"taplo",
		"xmlformatter",
		"yaml-language-server",
		"yamlfmt",
		"yamllint",
	})
	lsp.format_with_conform("xml", {
		"xmlformatter",
		lsp_format = "prefer",
	})
end

function L.settings() end

function L.keybindings() end

function L.complete()
	vim.lsp.enable({
		"jsonls",
		"yamlls",
		"taplo",
		"lemminx",
	})
end

return L
