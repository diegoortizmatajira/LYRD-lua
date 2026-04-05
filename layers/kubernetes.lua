local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Kubernetes",
	required_plugins = {
		{
			"qvalentin/helm-ls.nvim",
			ft = "helm",
			opts = {
				-- leave empty or see below
			},
		},
	},
	required_mason_packages = {
		"helm_ls",
	},
	required_treesitter_parsers = {
		"helm",
	},
	required_enabled_lsp_servers = {
		"helm_ls",
	},
	required_executables = {
		"k9s",
	},
}

function L.toggle_k9s()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("k9s")
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDKubernetesUI, L.toggle_k9s },
	})
end

return declarative_layer.apply(L)
