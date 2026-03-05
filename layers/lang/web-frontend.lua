local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local utils = require("LYRD.utils")
local commands = require("LYRD.layers.commands")

---@class LYRD.layer.lang.WebFrontend: LYRD.setup.Module
local L = {
	name = "Web frontend",
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
	--- get the current working directory as the folder where the current file is located
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

function L.plugins()
	setup.plugin({
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
	})
end

function L.preparation()
	lsp.mason_ensure({
		"vue-language-server",
		"angular-language-server",
		"svelte-language-server",
		"js-debug-adapter",
		"eslint-lsp",
		"vtsls",
	})
	lsp.format_with_lsp("vue", "vue_ls")
	lsp.format_with_lsp("ts", "vtsls")
	lsp.format_with_lsp("svelte", "svelte")

	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"javascript",
		"typescript",
		"vue",
		"svelte",
		"tsx",
		"angular",
	})

	local test = require("LYRD.layers.test")
	utils.with_safe_require("neotest-vitest", function(neotest_vitest)
		test.configure_adapter(neotest_vitest)
	end)
	utils.with_safe_require("neotest-jest", function(neotest_jest)
		test.configure_adapter(neotest_jest)
	end)

	-- Enable treesitter for Angular HTML files
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		pattern = { "*.component.html", "*.container.html" },
		callback = function()
			vim.treesitter.start(nil, "angular")
		end,
	})
end

function L.settings()
	local wrap = require("LYRD.layers.commands").wrap
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement({ "typescript", "vue", "svelte" }, {
		{ cmd.LYRDCodeBuild, wrap(L.run_npm_build) },
		{ cmd.LYRDCodeBuildAll, wrap(L.run_npm_build) },
	})
end

function L.complete()
	vim.lsp.enable({
		"vtsls",
		"vue_ls",
		"angularls",
		"svelte",
	})
end

return L
