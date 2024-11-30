local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Dotnet languages: C#, F#, Vb" }

local dotnet_languages = { "cs", "vb" }

-- local omnisharp_settings = require("LYRD.configs.omnisharp")

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
			"issafalcon/neotest-dotnet",
			ft = dotnet_languages,
		},
		{
			"seblj/roslyn.nvim",
			ft = "cs",
			opts = {
				["csharp|background_analysis"] = {},
				-- your configuration comes here; leave empty for default settings
			},
		},
		-- {
		-- 	"moaidhathot/dotnet.nvim",
		-- 	cmd = "DotnetUI",
		-- 	opts = {
		-- 		bootstrap = {
		-- 			auto_bootstrap = true, -- Automatically call "bootstrap" when creating a new file, adding a namespace and a class to the files
		-- 		},
		-- 		project_selection = {
		-- 			path_display = "filename_first", -- Determines how file paths are displayed. All of Telescope's path_display options are supported
		-- 		},
		-- 	},
		-- 	ft = dotnet_languages,
		-- },
		-- {
		-- 	"iabdelkareem/csharp.nvim",
		-- 	dependencies = {
		-- 		"williamboman/mason.nvim", -- Required, automatically installs omnisharp
		-- 		"mfussenegger/nvim-dap",
		-- 		"tastyep/structlog.nvim", -- optional, but highly recommended for debugging
		-- 	},
		-- 	opts = {
		-- 		lsp = {
		-- 			-- Sets if you want to use omnisharp as your LSP
		-- 			omnisharp = {
		-- 				-- When set to false, csharp.nvim won't launch omnisharp automatically.
		-- 				enable = false,
		-- 			},
		-- 			-- Sets if you want to use roslyn as your LSP
		-- 			roslyn = {
		-- 				-- When set to true, csharp.nvim will launch roslyn automatically.
		-- 				enable = false,
		-- 				-- Path to the roslyn LSP see 'Roslyn LSP Specific Prerequisites' above.
		-- 				cmd_path = nil,
		-- 			},
		-- 			-- The capabilities to pass to the omnisharp server
		-- 			capabilities = nil,
		-- 			-- on_attach function that'll be called when the LSP is attached to a buffer
		-- 			on_attach = nil,
		-- 		},
		-- 		logging = {
		-- 			-- The minimum log level.
		-- 			level = "INFO",
		-- 		},
		-- 		dap = {
		-- 			-- When set, csharp.nvim won't launch install and debugger automatically. Instead, it'll use the debug adapter specified.
		-- 			--- @type string?
		-- 			adapter_name = nil,
		-- 		},
		-- 	},
		-- 	ft = dotnet_languages,
		-- },
		-- {
		-- 	"gustaveikaas/easy-dotnet.nvim",
		-- 	dependencies = {
		-- 		"nvim-lua/plenary.nvim",
		-- 		"nvim-telescope/telescope.nvim",
		-- 	},
		-- 	opts = {
		-- 		test_runner = {
		-- 			---@type "split" | "float" | "buf"
		-- 			viewmode = "float",
		-- 			enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
		-- 			noBuild = true,
		-- 			noRestore = true,
		-- 			icons = {
		-- 				passed = icons.test.passed,
		-- 				skipped = icons.test.skipped,
		-- 				failed = icons.test.failed,
		-- 				success = icons.test.success,
		-- 				reload = icons.test.reload,
		-- 				test = icons.code.test,
		-- 				sln = icons.dotnet.sln,
		-- 				project = icons.dotnet.project,
		-- 				dir = icons.folder.default,
		-- 				package = icons.dotnet.package,
		-- 			},
		-- 		},
		-- 		---@param action "test" | "restore" | "build" | "run"
		-- 		terminal = function(path, action)
		-- 			local cmd_definitions = {
		-- 				run = function()
		-- 					return "dotnet run --project " .. path
		-- 				end,
		-- 				test = function()
		-- 					return "dotnet test " .. path
		-- 				end,
		-- 				restore = function()
		-- 					return "dotnet restore " .. path
		-- 				end,
		-- 				build = function()
		-- 					return "dotnet build " .. path
		-- 				end,
		-- 			}
		-- 			local command = cmd_definitions[action]() .. "\r"
		-- 			vim.cmd("vsplit")
		-- 			vim.cmd("term " .. command)
		-- 		end,
		-- 		secrets = {
		-- 			path = get_secret_path,
		-- 		},
		-- 		csproj_mappings = true,
		-- 		fsproj_mappings = true,
		-- 		auto_bootstrap_namespace = true,
		-- 	},
		-- 	ft = dotnet_languages,
		-- },
		-- {
		-- 	"adamclerk/vim-razor",
		-- 	ft = dotnet_languages,
		-- },
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		"netcoredbg",
		"roslyn",
		-- "omnisharp",
	})
end

function L.settings(s)
	commands.implement(s, "cs", {
		-- { cmd.LYRDCodeFixImports, ":OmniSharpFixUsings" },
		-- { cmd.LYRDCodeGlobalCheck, ":OmniSharpGlobalCodeCheck" },
		{ cmd.LYRDBufferFormat, lsp.format_handler("omnisharp") },
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

	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-dotnet"))
end

function L.complete(_)
	-- lsp.enable("omnisharp", {
	-- 	settings = omnisharp_settings,
	-- })
end

return L
