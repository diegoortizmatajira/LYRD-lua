local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local mappings = require("LYRD.layers.mappings")
local lsp = require("LYRD.layers.lsp")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "C# language" }

local function get_secret_path(secret_guid)
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

function L.plugins(s)
	setup.plugin(s, {
		{
			"OmniSharp/omnisharp-vim",
			ft = "cs",
			config = function()
				vim.g.OmniSharp_highlighting = 0
				vim.g.OmniSharp_server_use_mono = 0
				vim.g.OmniSharp_server_path =
					vim.fn.expand(require("mason-registry").get_package("omnisharp"):get_install_path() .. "/omnisharp")
			end,
			dependencies = { "tpope/vim-dispatch" },
		},
		{
			"nickspoons/vim-sharpenup",
			ft = "cs",
		},
		{
			"adamclerk/vim-razor",
			ft = "cs",
		},
		{
			"Issafalcon/neotest-dotnet",
			ft = "cs",
		},
		{
			"MoaidHathot/dotnet.nvim",
			cmd = "DotnetUI",
			opts = {},
		},
		{
			"iabdelkareem/csharp.nvim",
			dependencies = {
				"williamboman/mason.nvim", -- Required, automatically installs omnisharp
				"mfussenegger/nvim-dap",
				"Tastyep/structlog.nvim", -- Optional, but highly recommended for debugging
			},
			opts = {},
		},
		{
			"GustavEikaas/easy-dotnet.nvim",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
			opts = {
				test_runner = {
					---@type "split" | "float" | "buf"
					viewmode = "float",
					enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
					noBuild = true,
					noRestore = true,
					icons = {
						passed = "",
						skipped = "",
						failed = "",
						success = "",
						reload = "",
						test = "",
						sln = "󰘐",
						project = "󰘐",
						dir = "",
						package = "",
					},
					mappings = {
						run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
						filter_failed_tests = { lhs = "<leader>fe", desc = "filter failed tests" },
						debug_test = { lhs = "<leader>d", desc = "debug test" },
						go_to_file = { lhs = "g", desc = "got to file" },
						run_all = { lhs = "<leader>R", desc = "run all tests" },
						run = { lhs = "<leader>r", desc = "run test" },
						peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
						expand = { lhs = "o", desc = "expand" },
						expand_all = { lhs = "E", desc = "expand all" },
						collapse_all = { lhs = "W", desc = "collapse all" },
						close = { lhs = "q", desc = "close testrunner" },
						refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
					},
					--- Optional table of extra args e.g "--blame crash"
					additional_args = {},
				},
				---@param action "test" | "restore" | "build" | "run"
				terminal = function(path, action)
					local commands = {
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
							return "dotnet build " .. path
						end,
					}
					local command = commands[action]() .. "\r"
					vim.cmd("vsplit")
					vim.cmd("term " .. command)
				end,
				secrets = {
					path = get_secret_path,
				},
				csproj_mappings = true,
				fsproj_mappings = true,
				auto_bootstrap_namespace = true,
			},
		},
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		-- "csharp-language-server",
		"csharpier",
		"netcoredbg",
		"omnisharp",
		"ast_grep",
	})
	lsp.null_ls_register_sources({
		-- null_ls.builtins.formatting.astyle,
	})
end

function L.settings(s)
	commands.implement(s, "cs", {
		-- { cmd.LYRDTest,            ":OmniSharpRunTestsInFile" },
		-- { cmd.LYRDTestSuite,       ":OmniSharpRunTestsInFile" },
		-- { cmd.LYRDTestFile,        ":OmniSharpRunTestsInFile" },
		-- { cmd.LYRDTestFunc,        ":OmniSharpRunTest" },
		-- { cmd.LYRDTestLast,        ":OmniSharpRunTestsInFile" },
		{ cmd.LYRDCodeFixImports, ":OmniSharpFixUsings" },
		{ cmd.LYRDCodeGlobalCheck, ":OmniSharpGlobalCodeCheck" },
		{ cmd.LYRDBufferFormat, ":OmniSharpCodeFormat" },
	})
	local dap = require("dap")

	dap.adapters.coreclr = {
		type = "executable",
		command = require("mason-registry").get_package("netcoredbg"):get_install_path() .. "/netcoredbg",
		args = { "--interpreter=vscode" },
	}
	dap.configurations.cs = {
		{
			type = "coreclr",
			name = "launch - netcoredbg",
			request = "launch",
			program = function()
				return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
			end,
		},
	}

	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-dotnet"))
end

function L.keybindings(s)
	mappings.space_menu(s, { { { "p", "o" }, "OmniSharp" } })
	mappings.space(s, {
		{ "n", { "p", "o", "l" }, c("OmniSharpOpenLog"), "Open log" },
		{ "n", { "p", "o", "r" }, c("OmniSharpRestartServer"), "Restart OmniSharp server" },
		{ "n", { "p", "o", "S" }, c("OmniSharpStatus"), "OmniSharp status" },
		{ "n", { "p", "o", "s" }, c("OmniSharpStartServer"), "Start OmniSharp server" },
		{ "n", { "p", "o", "x" }, c("OmniSharpStopServer"), "Stop OmniSharp server" },
		{ "n", { "p", "o", "i" }, c("OmniSharpInstall"), "Install OmniSharp" },
	})
end

function L.complete(_)
	lsp.enable("omnisharp", {})
end

return L
