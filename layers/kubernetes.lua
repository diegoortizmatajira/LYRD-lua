local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")

local declarative_layer = require("LYRD.shared.declarative_layer")

local MANIFEST_FILETYPE = "yaml.kubernetes"
local HELM_FILETYPE = "yaml.helm"

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Kubernetes",
	required_plugins = {
		{
			"qvalentin/helm-ls.nvim",
			ft = HELM_FILETYPE,
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
		"kubectl",
	},
	required_filetype_definitions = {
		pattern = {
		    -- Common Kubernetes manifest patterns
			[".*/.kube/config"] = "yaml",
			[".*/k8s/.*%.yaml"] = MANIFEST_FILETYPE,
			[".*/k8s/.*%.yml"] = MANIFEST_FILETYPE,
			[".*/kubernetes/.*%.yaml"] = MANIFEST_FILETYPE,
			[".*/kubernetes/.*%.yml"] = MANIFEST_FILETYPE,
			[".*/kube/.*%.yaml"] = MANIFEST_FILETYPE,
			[".*/kube/.*%.yml"] = MANIFEST_FILETYPE,
			[".*/manifests/.*%.yaml"] = MANIFEST_FILETYPE,
			[".*/manifests/.*%.yml"] = MANIFEST_FILETYPE,
			[".*/deploy/.*%.yaml"] = MANIFEST_FILETYPE,
			[".*/deploy/.*%.yml"] = MANIFEST_FILETYPE,
			-- Helm patterns
			[".*/templates/.*%.tpl"] = HELM_FILETYPE,
			[".*/templates/.*%.ya?ml"] = HELM_FILETYPE,
			[".*/templates/.*%.txt"] = HELM_FILETYPE,
			["helmfile.*%.ya?ml"] = HELM_FILETYPE,
			["helmfile.*%.ya?ml.gotmpl"] = HELM_FILETYPE,
			["values.*%.yaml"] = "yaml.helm-values",
		},
	},
	focus_terminal_on_run = true,
}

function L.toggle_k9s()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("k9s")
end

--- Runs a kubectl command against the current file.
--- @param command string The kubectl subcommand to execute (e.g., "apply", "delete", "describe").
--- @param extra_args? string[] Additional arguments to pass to kubectl.
local function kubectl_file_task(command, extra_args)
	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("No file to run kubectl against", vim.log.levels.WARN)
		return
	end
	local args = { command, "-f", file }
	if extra_args then
		vim.list_extend(args, extra_args)
	end
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = "kubectl " .. command,
		cmd = "kubectl",
		args = args,
		cwd = vim.fn.expand("%:p:h"),
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

local function kubernetes_generate_actions()
	local prefix = "Kubernetes: "
	local file_commands = {
		{ label = "apply", command = "apply" },
		{ label = "delete", command = "delete" },
		{ label = "describe", command = "describe" },
		{ label = "create", command = "create" },
		{ label = "diff", command = "diff" },
		{ label = "apply (dry-run client)", command = "apply", args = { "--dry-run=client" } },
		{ label = "apply (dry-run server)", command = "apply", args = { "--dry-run=server" } },
	}
	return vim.tbl_map(function(c)
		return {
			title = prefix .. c.label,
			action = function()
				kubectl_file_task(c.command, c.args)
			end,
		}
	end, file_commands)
end

function L.preparation()
	lsp.register_code_actions({ MANIFEST_FILETYPE }, kubernetes_generate_actions)
end

function L.settings()
	commands.implement(MANIFEST_FILETYPE, {
		{
			cmd.LYRDCodeRun,
			function()
				kubectl_file_task("apply")
			end,
		},
	})
	commands.implement("*", {
		{ cmd.LYRDKubernetesUI, L.toggle_k9s },
	})
end

return declarative_layer.apply(L)
