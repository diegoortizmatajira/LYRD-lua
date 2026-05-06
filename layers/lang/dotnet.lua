local declarative_layer = require("LYRD.shared.declarative_layer")
local icons = require("LYRD.layers.icons")
local dotnet_languages = { "cs", "vb" }

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = ".NET languages: C#, F#, VB",
	required_plugins = {
		{
			"nsidorenco/neotest-vstest",
			ft = dotnet_languages,
		},
		{
			"gustaveikaas/easy-dotnet.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
			},
			opts = {
				test_runner = {
					---@type "split" | "float" | "buf"
					viewmode = "float",
					enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
					noBuild = true,
					noRestore = true,
					icons = {
						passed = icons.test.passed,
						skipped = icons.test.skipped,
						failed = icons.test.failed,
						success = icons.test.success,
						reload = icons.test.reload,
						test = icons.code.test,
						sln = icons.dotnet.sln,
						project = icons.dotnet.project,
						dir = icons.folder.default,
						package = icons.dotnet.package,
					},
				},
				terminal = function(path, action)
					local dotnet_commands = {
						run = function()
							return "dotnet run --project " .. path
						end,
						test = function()
							return "dotnet test " .. path
						end,
						restore = function()
							return "dotnet restore " .. path
						end,
						build = function()
							return "dotnet build  " .. path
						end,
					}

					local function filter_warnings(line)
						if not line:find("warning") then
							local filename, lnum, col, text = line:match("^%s*(.+)%((%d+),(%d+)%)%: (.+)$")
							if filename and text then
								text = text:gsub("%s*%[.-%]%s*$", "")
							end
							return filename, lnum, col, text
						end
					end

					local overseer_components = {
						{
							"on_complete_dispose",
							timeout = 30,
						},
						"default",
						{
							"unique",
							replace = true,
						},
						{
							"on_output_parse",
							parser = {
								diagnostics = {
									{ "extract", filter_warnings, "filename", "lnum", "col", "text" },
								},
							},
						},
						{
							"on_result_diagnostics_quickfix",
							open = true,
							close = true,
						},
					}

					if action == "run" or action == "test" then
						table.insert(overseer_components, { "restart_on_save" })
					end

					local command = dotnet_commands[action]()
					local task = require("overseer").new_task({
						strategy = {
							"jobstart",
							use_shell = false,
							direction = "horizontal",
							open_on_start = true,
						},
						name = action,
						cmd = command,
						components = overseer_components,
					})
					task:start()
				end,
				secrets = {
					path = function(secret_guid)
						if secret_guid == nil then
							return ""
						end
						local path = ""
						local home_dir = vim.fn.expand("~")
						local utils = require("LYRD.shared.utils")
						if require("easy-dotnet.extensions").isWindows() then
							path = utils.join_paths(
								home_dir,
								"AppData",
								"Roaming",
								"Microsoft",
								"UserSecrets",
								secret_guid,
								"secrets.json"
							)
						else
							path = utils.join_paths(home_dir, ".microsoft", "usersecrets", secret_guid, "secrets.json")
						end
						return path
					end,
				},
				csproj_mappings = true,
				fsproj_mappings = true,
				auto_bootstrap_namespace = false,
			},
			ft = dotnet_languages,
		},
	},
	required_mason_packages = {
		"netcoredbg",
		"roslyn",
		"csharpier",
	},
	required_treesitter_parsers = {
		"c_sharp",
		"fsharp",
	},
	required_enabled_lsp_servers = {
		"roslyn",
	},
	required_formatters = {
		["csharpier"] = require("LYRD.shared.conform.csharpier"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "cs",
			format_settings = { "csharpier", lsp_format = "prefer" },
		},
	},
	required_test_adapters = {
		"neotest-vstest",
	},
}

function L.preparation()
	-- DEBUG ADAPTER
	local debugger = require("LYRD.shared.dap.netcoredbg")
	debugger.setup(dotnet_languages)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement(dotnet_languages, {
		{
			cmd.LYRDCodeBuild,
			function()
				local dotnet = require("easy-dotnet")
				dotnet.build_quickfix()
			end,
		},
		{
			cmd.LYRDCodeBuildAll,
			function()
				local dotnet = require("easy-dotnet")
				dotnet.build_solution()
			end,
		},
		{
			cmd.LYRDCodeRun,
			function()
				local dotnet = require("easy-dotnet")
				dotnet.run({})
			end,
		},
		{
			cmd.LYRDCodeRestorePackages,
			function()
				local dotnet = require("easy-dotnet")
				dotnet.restore()
			end,
		},
		{
			cmd.LYRDCodeSecrets,
			function()
				local dotnet = require("easy-dotnet")
				dotnet.secrets()
			end,
		},
		{ cmd.LYRDCodeTooling, ":Dotnet" },
	})

	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.cake"))
end

return declarative_layer.apply(L)
