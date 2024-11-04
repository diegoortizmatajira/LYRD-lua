local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local mappings = require("LYRD.layers.mappings")
local lsp = require("LYRD.layers.lsp")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "C# language" }

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
