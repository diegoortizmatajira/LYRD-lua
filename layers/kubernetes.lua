local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local declarative_layer = require("LYRD.shared.declarative_layer")

local MANIFEST_FILETYPE = "yaml.kubernetes"
local HELM_FILETYPE = "yaml.helm" -- Using specifically "helm" as plugin attaches to that filetype, and we can define it via pattern matching below for both .tpl and .yaml files in Helm charts.

--- @class KubectlAction
--- @field label string Display label for the action.
--- @field command string The kubectl subcommand.
--- @field args? string[] Extra arguments.

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Kubernetes",
	required_mason_packages = {
		"helm_ls",
	},
	required_treesitter_parsers = {
		"helm",
		"gotmpl", -- For Helm templates, which often use Go template syntax
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
			[".*/charts/.*%.ya?ml"] = HELM_FILETYPE,
			["helmfile.*%.ya?ml"] = HELM_FILETYPE,
			["helmfile.*%.ya?ml.gotmpl"] = HELM_FILETYPE,
			["values.*%.yaml"] = "yaml.helm-values",
		},
	},
	focus_terminal_on_run = true,
	ts_document_query = [[
(stream
  (document
    (block_node) @block_node
  ) @document
)
]],
	--- @type KubectlAction[]
	kubectl_commands = {
		{ label = "apply", command = "apply" },
		{ label = "delete", command = "delete" },
		{ label = "describe", command = "describe" },
		{ label = "create", command = "create" },
		{ label = "diff", command = "diff" },
		{ label = "apply (dry-run client)", command = "apply", args = { "--dry-run=client" } },
		{ label = "apply (dry-run server)", command = "apply", args = { "--dry-run=server" } },
	},
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
	local args = { command }
	if extra_args then
		vim.list_extend(args, extra_args)
	end
	vim.list_extend(args, { "-f", file })
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

--- Runs a kubectl command by piping YAML text via stdin.
--- @param command string The kubectl subcommand to execute.
--- @param yaml_text string The YAML content to pipe.
--- @param extra_args? string[] Additional arguments to pass to kubectl.
local function kubectl_stdin_task(command, yaml_text, extra_args)
	local kubectl_args = { command }
	if extra_args then
		vim.list_extend(kubectl_args, extra_args)
	end
	vim.list_extend(kubectl_args, { "-f", "-" })
	local shell_args = vim.tbl_map(vim.fn.shellescape, kubectl_args)
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = "kubectl " .. command .. " (document)",
		cmd = "sh",
		args = {
			"-c",
			string.format("printf '%%s' %s | kubectl %s", vim.fn.shellescape(yaml_text), table.concat(shell_args, " ")),
		},
		cwd = vim.fn.expand("%:p:h"),
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

function L.kubectl_run_at_cursor()
	require("LYRD.shared.run_code").run_selection({
		title = "Apply Kubernetes manifest",
		treesitter_selector = {
			query_string = L.ts_document_query,
			lang = "yaml",
			node_capture_name = "block_node",
			text_capture_name = "block_node",
		},
		skip_visual_selection = true,
		generator = function(file, document)
			local result = {}
			if document and document ~= "" then
				local document_result = vim.tbl_map(function(command)
					table.insert(result, {
						name = string.format("Manifest Part: %s (at cursor)", command.label),
						preview = string.format(
							"printf '%%s' %s | kubectl %s %s -f -",
							vim.fn.shellescape(document),
							command.command,
							command.args and table.concat(command.args, " ") or ""
						),
						runner = function()
							kubectl_stdin_task(command.command, document, command.args)
						end,
					})
				end, L.kubectl_commands)
				vim.list_extend(result, document_result)
			end
			local file_result = vim.tbl_map(function(command)
				return {
					name = string.format("Manifest: %s", command.label),
					preview = string.format(
						"kubectl %s %s -f %s",
						command.command,
						command.args and table.concat(command.args, " ") or "",
						file
					),
					runner = function()
						kubectl_file_task(command.command, command.args)
					end,
				}
			end, L.kubectl_commands)
			vim.list_extend(result, file_result)
			return result
		end,
	})
end

function L.settings()
	vim.treesitter.language.register("helm", "yaml.helm")
	vim.api.nvim_create_autocmd("FileType", {
		pattern = HELM_FILETYPE,
		callback = function(args)
			vim.treesitter.start(args.buf, "helm")
		end,
	})
	commands.implement(MANIFEST_FILETYPE, {
		{ cmd.LYRDCodeRun, L.kubectl_run_at_cursor },
		{ cmd.LYRDCodeRunSelection, L.kubectl_run_at_cursor },
	})
	commands.implement("*", {
		{ cmd.LYRDKubernetesUI, L.toggle_k9s },
	})
end

return declarative_layer.apply(L)
