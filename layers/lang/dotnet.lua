local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local mappings = require("LYRD.layers.mappings")
local lsp = require("LYRD.layers.lsp")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Dotnet languages: C#, F#, Vb" }

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

local dotnet_languages = { "cs", "vb", "fsharp" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"omnisharp/omnisharp-vim",
			ft = dotnet_languages,
			config = function()
				vim.g.OmniSharp_highlighting = 0
				vim.g.OmniSharp_server_use_mono = 0
				vim.g.OmniSharp_server_path =
					vim.fn.expand(require("mason-registry").get_package("omnisharp"):get_install_path() .. "/omnisharp")
			end,
			dependencies = {
				"tpope/vim-dispatch",
				"williamboman/mason.nvim",
			},
		},
		{
			"nickspoons/vim-sharpenup",
			ft = dotnet_languages,
			init = function()
				vim.g.sharpenup_create_mappings = 0
			end,
		},
		{
			"adamclerk/vim-razor",
			ft = dotnet_languages,
		},
		{
			"issafalcon/neotest-dotnet",
			ft = dotnet_languages,
		},
		{
			"moaidhathot/dotnet.nvim",
			cmd = "DotnetUI",
			opts = {},
			ft = dotnet_languages,
		},
		-- {
		-- 	"iabdelkareem/csharp.nvim",
		-- 	dependencies = {
		-- 		"williamboman/mason.nvim", -- Required, automatically installs omnisharp
		-- 		"mfussenegger/nvim-dap",
		-- 		"tastyep/structlog.nvim", -- optional, but highly recommended for debugging
		-- 	},
		-- 	opts = {},
		-- 	ft = dotnet_languages,
		-- },
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
				},
				---@param action "test" | "restore" | "build" | "run"
				terminal = function(path, action)
					local cmd_definitions = {
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
					local command = cmd_definitions[action]() .. "\r"
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
			ft = dotnet_languages,
		},
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		-- "csharp-language-server",
		"netcoredbg",
		"omnisharp",
		"ast_grep",
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
					---@diagnostic disable-next-line: redundant-parameter
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
				},
			}
		end
	end

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
