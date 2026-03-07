local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Data formats json, yaml, toml, xml",
	required_plugins = {
		{
			"b0o/schemastore.nvim",
		},
		{
			"VPavliashvili/json-nvim",
			ft = "json",
		},
	},
	required_mason_packages = {
		"json-lsp",
		"json-to-struct",
		"jsonlint",
		"lemminx",
		"prettier",
		"taplo",
		"xmlformatter",
		"yaml-language-server",
		"yamlfmt",
		"yamllint",
	},
	required_treesitter_parsers = {
		"scheme",
		"yaml",
		"json",
		"json5",
		"jsonc",
		"toml",
		"xml",
		"proto",
	},
	required_enabled_lsp_servers = {
		"jsonls",
		"yamlls",
		"taplo",
		"lemminx",
	},
}

local function jsonlint()
	local h = require("null-ls.helpers")
	local methods = require("null-ls.methods")

	local DIAGNOSTICS = methods.internal.DIAGNOSTICS

	return h.make_builtin({
		name = "jsonlint",
		meta = {
			url = "https://github.com/zaach/jsonlint",
			description = "A pure JavaScript version of the service provided at jsonlint.com.",
		},
		method = DIAGNOSTICS,
		filetypes = { "json" },
		generator_opts = {
			command = "jsonlint",
			args = { "--compact" },
			to_stdin = true,
			from_stderr = true,
			format = "line",
			check_exit_code = function(c)
				return c <= 1
			end,
			on_output = h.diagnostics.from_pattern("line (%d+), col (%d+), (.*)", { "row", "col", "message" }, {}),
		},
		factory = h.generator_factory,
	})
end

function L.preparation()
	local lsp = require("LYRD.layers.lsp")
	lsp.format_with_conform({ "json", "jsonc" }, { "prettier" })
	lsp.format_with_conform("xml", { "xmlformatter", lsp_format = "prefer" })

	lsp.null_ls_register_sources({
		jsonlint(),
	})
end

function L.settings()
	vim.filetype.add({
		filename = {
			["tasks.json"] = "jsonc",
			["launch.json"] = "jsonc",
		},
	})
end

return declarative_layer.apply(L)
