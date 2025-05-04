local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Dotnet languages: C#, F#, Vb" }

local dotnet_languages = { "cs", "vb" }

-- local omnisharp_settings = require("LYRD.configs.omnisharp")

local function get_secret_path(secret_guid)
	if secret_guid == nil then
		return ""
	end
	local path = ""
	local home_dir = vim.fn.expand("~")
	if require("easy-dotnet.extensions").isWindows() then
		local secret_path = home_dir
			.. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\"
			.. secret_guid
			.. "\\secrets.json"
		path = secret_path
	else
		local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
		path = secret_path
	end
	return path
end

function L.plugins()
	setup.plugin({
		{
			"issafalcon/neotest-dotnet",
			ft = dotnet_languages,
		},
		{
			"seblj/roslyn.nvim",
			ft = "cs",
			opts = {
				-- your configuration comes here; leave empty for default settings
			},
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
							return line:match("^(.+)%((%d+),(%d+)%)%: (.+)$")
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
							"toggleterm",
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
					path = get_secret_path,
				},
				csproj_mappings = true,
				fsproj_mappings = true,
				auto_bootstrap_namespace = false,
			},
			ft = dotnet_languages,
		},
		-- {
		-- 	"adamclerk/vim-razor",
		-- 	ft = dotnet_languages,
		-- },
	})
end

function L.preparation()
	lsp.mason_ensure({
		"netcoredbg",
		"roslyn",
	})
	lsp.format_with_lsp(dotnet_languages, "roslyn")
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-dotnet"))
end

function L.settings()
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
	})

	-- DEBUG ADAPTER
	local dap = require("dap")
	dap.adapters.netcoredbg = {
		type = "executable",
		command = require("mason-registry").get_package("netcoredbg"):get_install_path() .. "/netcoredbg",
		args = { "--interpreter=vscode" },
		options = {
			detached = false,
		},
	}
	for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
		if not dap.configurations[lang] then
			dap.configurations[lang] = {
				{
					type = "netcoredbg",
					name = "Launch file",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
				},
			}
		end
	end
end

function L.complete() end

return L
