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
		{
			"cenk1cenk2/jq.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"muniftanjim/nui.nvim",
				"grapp-dev/nui-components.nvim",
			},
			opts = {},
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
	required_formatter_per_filetype = {
		{
			target_filetype = { "yaml", "yml" },
			format_settings = { "yamlfmt" },
		},
		{
			target_filetype = { "json", "jsonc", "json5" },
			format_settings = { "prettier" },
		},
		{
			target_filetype = { "xml" },
			format_settings = { "xmlformatter", lsp_format = "prefer" },
		},
	},
	required_null_ls_sources = {
		--- Define a null-ls source for jsonlint, which is a JSON linter
		--- that can be used to provide diagnostics for JSON files.
		function()
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
					on_output = h.diagnostics.from_pattern(
						"line (%d+), col (%d+), (.*)",
						{ "row", "col", "message" },
						{}
					),
				},
				factory = h.generator_factory,
			})
		end,
	},
	required_filetype_definitions = {
		filename = {
			["tasks.json"] = "jsonc",
			["launch.json"] = "jsonc",
		},
	},
}

function L.run_query()
	require("jq").run()
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("json", {
		{ cmd.LYRDCodeRunSelection, L.run_query },
		{ cmd.LYRDCodeRun, L.run_query },
	})
end

return declarative_layer.apply(L)
