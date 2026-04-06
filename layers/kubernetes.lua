local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")
local ts = require("LYRD.layers.treesitter")

local declarative_layer = require("LYRD.shared.declarative_layer")

local MANIFEST_FILETYPE = "yaml.kubernetes"
local HELM_FILETYPE = "yaml.helm" -- Using specifically "helm" as plugin attaches to that filetype, and we can define it via pattern matching below for both .tpl and .yaml files in Helm charts.

--- @type table|LYRD.setup.DeclarativeLayer
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
		{
			"helm_ls",
			config = { filetypes = { "helm", "yaml.helm", "yaml.helm-values" } },
		},
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
	ts_document_query = [[
(stream
  (document) @document
)
]],
}

function L.toggle_k9s()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("k9s")
end

--- Returns the YAML text of the document under the cursor, or nil if not found.
--- @return string|nil
function L.get_document_at_cursor()
	local text = ts.get_match_text_at_cursor(L.ts_document_query, "yaml", "document", "document")
	if text == "" then
		return nil
	end
	return text
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

--- Runs a kubectl command by piping YAML text via stdin.
--- @param command string The kubectl subcommand to execute.
--- @param yaml_text string The YAML content to pipe.
--- @param extra_args? string[] Additional arguments to pass to kubectl.
local function kubectl_stdin_task(command, yaml_text, extra_args)
	local kubectl_args = { command, "-f", "-" }
	if extra_args then
		vim.list_extend(kubectl_args, extra_args)
	end
	local shell_args = vim.tbl_map(vim.fn.shellescape, kubectl_args)
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = "kubectl " .. command .. " (document)",
		cmd = "sh",
		args = {
			"-c",
			string.format("echo %s | kubectl %s", vim.fn.shellescape(yaml_text), table.concat(shell_args, " ")),
		},
		cwd = vim.fn.expand("%:p:h"),
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

--- @class KubectlAction
--- @field label string Display label for the action.
--- @field command string The kubectl subcommand.
--- @field args? string[] Extra arguments.

--- @type KubectlAction[]
local kubectl_commands = {
	{ label = "apply", command = "apply" },
	{ label = "delete", command = "delete" },
	{ label = "describe", command = "describe" },
	{ label = "create", command = "create" },
	{ label = "diff", command = "diff" },
	{ label = "apply (dry-run client)", command = "apply", args = { "--dry-run=client" } },
	{ label = "apply (dry-run server)", command = "apply", args = { "--dry-run=server" } },
}

local function kubernetes_generate_actions()
	local prefix = "Manifest file: "
	--- File-level actions
	local result = vim.tbl_map(function(c)
		return {
			title = prefix .. c.label .. " (file)",
			action = function()
				kubectl_file_task(c.command, c.args)
			end,
		}
	end, kubectl_commands)
	--- Document-at-cursor actions
	prefix = "Selected: "
	local doc_text = L.get_document_at_cursor()
	if doc_text then
		vim.list_extend(
			result,
			vim.tbl_map(function(c)
				return {
					title = prefix .. c.label .. " (at cursor)",
					action = function()
						kubectl_stdin_task(c.command, doc_text, c.args)
					end,
				}
			end, kubectl_commands)
		)
	end
	return result
end

function L.preparation()
	lsp.register_code_actions({ MANIFEST_FILETYPE }, kubernetes_generate_actions)
end

--- Applies the document under the cursor via kubectl, or the whole file if not in a document.
function L.kubectl_apply_document_at_cursor()
	local doc_text = L.get_document_at_cursor()
	if doc_text then
		kubectl_stdin_task("apply", doc_text)
	else
		kubectl_file_task("apply")
	end
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
		{
			cmd.LYRDCodeRun,
			function()
				kubectl_file_task("apply")
			end,
		},
		{ cmd.LYRDCodeRunSelection, L.kubectl_apply_document_at_cursor },
	})
	commands.implement("*", {
		{ cmd.LYRDKubernetesUI, L.toggle_k9s },
	})
end

return declarative_layer.apply(L)
