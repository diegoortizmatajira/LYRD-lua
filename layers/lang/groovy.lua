local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Groovy",
	required_plugins = {},
	required_mason_packages = {
		"groovy-language-server",
		"npm-groovy-lint",
	},
	required_treesitter_parsers = {
		"groovy",
	},
	required_enabled_lsp_servers = {
		"groovyls",
	},
	required_executables = {},
	required_formatters = {
		["npm-groovy-lint"] = {

			command = "npm-groovy-lint",
			args = { "--failon", "none", "--format", "-" },
			stdin = true,
		},
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "groovy",
			format_settings = { "npm-groovy-lint" },
		},
	},
	required_test_adapters = {},
	required_null_ls_sources = {
		declarative_layer.source_with_opts("null-ls.builtins.diagnostics.npm_groovy_lint", {
			filetypes = { "groovy", "Jenkinsfile" },
		}),
	},
	required_filetype_definitions = {},
}

return declarative_layer.apply(L)
