local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Web frontend languages: JavaScript, TypeScript, Vue, Svelte, Angular",
	required_plugins = {
		{
			"pangloss/vim-javascript",
			init = function()
				vim.g.javascript_plugin_jsdoc = 1
				vim.g.javascript_plugin_ngdoc = 1
				vim.g.javascript_plugin_flow = 1
			end,
			ft = { "js" },
		},
		{
			"leafgarland/typescript-vim",
			ft = { "ts", "tsx", "vue", "svelte" },
		},
		{
			"marilari88/neotest-vitest",
		},
		{
			"nvim-neotest/neotest-jest",
		},
		{
			"nvim-svelte/nvim-svelte-snippets",
		},
	},
	required_mason_packages = {
		"vue-language-server",
		"angular-language-server",
		"svelte-language-server",
		"js-debug-adapter",
		"eslint-lsp",
		"vtsls",
	},
	required_treesitter_parsers = {
		"javascript",
		"typescript",
		"vue",
		"svelte",
		"tsx",
		"angular",
	},
	required_enabled_lsp_servers = {
		"vtsls",
		"vue_ls",
		"angularls",
		"svelte",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "vue",
			use_lsp = true,
			lsp_name = "vue_ls",
		},
		{
			target_filetype = "ts",
			use_lsp = true,
			lsp_name = "vtsls",
		},
		{
			target_filetype = "svelte",
			use_lsp = true,
			lsp_name = "svelte",
		},
	},
	required_test_adapters = {
		"neotest-vitest",
		"neotest-jest",
	},
	focus_terminal_on_run = true,
	ts_root_markers = {
		"package.json",
		"tsconfig.json",
		"jsconfig.json",
		".git",
	},
}

--- Executes the NPM build command in the project's root directory.
--- Ensures that NPM is installed and available in the system PATH before running.
--- Determines the working directory using configured root markers or defaults to the current directory.
--- Runs the "npm run build" command in a terminal split, with focus behavior configurable.
function L.run_npm_build()
	if vim.fn.executable("npm") == 0 then
		vim.notify("NPM is not installed or not found in PATH", vim.log.levels.ERROR)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	local utils = require("LYRD.utils")
	--- Get the current working directory as the folder where the current file is located
	local cwd = utils.find_root_dir(L.ts_root_markers) or vim.fn.getcwd()
	tasks.run_task({
		name = "NPM Build",
		cmd = "npm",
		args = { "run", "build" },
		cwd = cwd,
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

function L.preparation()
	-- Enable Tree-sitter for Angular HTML files
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		pattern = { "*.component.html", "*.container.html" },
		callback = function()
			vim.treesitter.start(nil, "angular")
		end,
	})
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local wrap = require("LYRD.layers.commands").wrap
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement({ "typescript", "vue", "svelte" }, {
		{ cmd.LYRDCodeBuild, wrap(L.run_npm_build) },
		{ cmd.LYRDCodeBuildAll, wrap(L.run_npm_build) },
	})
end

return declarative_layer.apply(L)
