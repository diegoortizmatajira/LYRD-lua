local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "CiCd",
	required_plugins = {},
	required_mason_packages = {
		"actionlint",
		"gitlab-ci-ls",
		"gh-actions-language-server",
		"azure-pipelines-language-server",
	},
	required_treesitter_parsers = {},
	required_enabled_lsp_servers = {
		"gitlab_ci_ls",
		"gh_actions_ls",
		"azure_pipelines_ls",
	},
	required_executables = {},
	required_formatters = {},
	required_formatter_per_filetype = {},
	required_test_adapters = {},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.actionlint",
	},
	required_filetype_definitions = {
		pattern = {
			["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		},
	},
}

return declarative_layer.apply(L)
