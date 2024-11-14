local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Dotnet languages: C#, F#, Vb" }

local dotnet_languages = { "cs", "vb", "fsharp" }

local omnisharp_settings = {
	msbuild = {
		enabled = true,
		-- ToolsVersion = nil,
		-- VisualStudioVersion = nil,
		-- Configuration = nil,
		-- Platform = nil,
		EnablePackageAutoRestore = true,
		-- MSBuildExtensionsPath = nil,
		-- TargetFrameworkRootPath = nil,
		-- MSBuildSDKsPath = nil,
		-- RoslynTargetsPath = nil,
		-- CscToolPath = nil,
		-- CscToolExe = nil,
		loadProjectsOnDemand = false,
		-- GenerateBinaryLogs = false,
	},
	Sdk = {
		IncludePrereleases = true,
	},
	cake = {
		enabled = true,
		bakeryPath = nil,
	},
	FormattingOptions = {
		EnableEditorConfigSupport = true,
		OrganizeImports = true,
		-- NewLine = "\n",
		-- UseTabs = false,
		-- TabSize = 4,
		-- IndentationSize = 4,
		-- SpacingAfterMethodDeclarationName = false,
		-- SpaceWithinMethodDeclarationParenthesis = false,
		-- SpaceBetweenEmptyMethodDeclarationParentheses = false,
		-- SpaceAfterMethodCallName = false,
		-- SpaceWithinMethodCallParentheses = false,
		-- SpaceBetweenEmptyMethodCallParentheses = false,
		-- SpaceAfterControlFlowStatementKeyword = true,
		-- SpaceWithinExpressionParentheses = false,
		-- SpaceWithinCastParentheses = false,
		-- SpaceWithinOtherParentheses = false,
		-- SpaceAfterCast = false,
		-- SpacesIgnoreAroundVariableDeclaration = false,
		-- SpaceBeforeOpenSquareBracket = false,
		-- SpaceBetweenEmptySquareBrackets = false,
		-- SpaceWithinSquareBrackets = false,
		-- SpaceAfterColonInBaseTypeDeclaration = true,
		-- SpaceAfterComma = true,
		-- SpaceAfterDot = false,
		-- SpaceAfterSemicolonsInForStatement = true,
		-- SpaceBeforeColonInBaseTypeDeclaration = true,
		-- SpaceBeforeComma = false,
		-- SpaceBeforeDot = false,
		-- SpaceBeforeSemicolonsInForStatement = false,
		-- SpacingAroundBinaryOperator = "single",
		-- IndentBraces = false,
		-- IndentBlock = true,
		-- IndentSwitchSection = true,
		-- IndentSwitchCaseSection = true,
		-- IndentSwitchCaseSectionWhenBlock = true,
		-- LabelPositioning = "oneLess",
		-- WrappingPreserveSingleLine = true,
		-- WrappingKeepStatementsOnSingleLine = true,
		-- NewLinesForBracesInTypes = true,
		-- NewLinesForBracesInMethods = true,
		-- NewLinesForBracesInProperties = true,
		-- NewLinesForBracesInAccessors = true,
		-- NewLinesForBracesInAnonymousMethods = true,
		-- NewLinesForBracesInControlBlocks = true,
		-- NewLinesForBracesInAnonymousTypes = true,
		-- NewLinesForBracesInObjectCollectionArrayInitializers = true,
		-- NewLinesForBracesInLambdaExpressionBody = true,
		-- NewLineForElse = true,
		-- NewLineForCatch = true,
		-- NewLineForFinally = true,
		-- NewLineForMembersInObjectInit = true,
		-- NewLineForMembersInAnonymousTypes = true,
		-- NewLineForClausesInQuery = true,
	},
	RoslynExtensionsOptions = {
		AnalyzeOpenDocumentsOnly = false,
		-- documentAnalysisTimeoutMs = 30000,
		enableDecompilationSupport = true,
		enableImportCompletion = true,
		enableAnalyzersSupport = false,
		-- diagnosticWorkersThreadCount = 8,
		-- locationPaths = {
		-- 	"//path_to/code_actions.dll",
		-- },
		-- inlayHintsOptions = {
		-- 	enableForParameters = true,
		-- 	forLiteralParameters = true,
		-- 	forIndexerParameters = true,
		-- 	forObjectCreationParameters = true,
		-- 	forOtherParameters = true,
		-- 	suppressForParametersThatDifferOnlyBySuffix = false,
		-- 	suppressForParametersThatMatchMethodIntent = false,
		-- 	suppressForParametersThatMatchArgumentName = false,
		-- 	enableForTypes = true,
		-- 	forImplicitVariableTypes = true,
		-- 	forLambdaParameterTypes = true,
		-- 	forImplicitObjectCreation = true,
		-- },
	},
	-- fileOptions = {
	-- 	systemExcludeSearchPatterns = {
	-- 		"**/node_modules/**/*",
	-- 		"**/bin/**/*",
	-- 		"**/obj/**/*",
	-- 	},
	-- 	excludeSearchPatterns = {},
	-- },
	-- RenameOptions = {
	-- 	RenameInComments = false,
	-- 	RenameOverloads = false,
	-- 	RenameInStrings = false,
	-- },
}

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
		-- {
		-- 	"omnisharp/omnisharp-vim",
		-- 	ft = dotnet_languages,
		-- 	config = function()
		-- 		vim.g.OmniSharp_highlighting = 0
		-- 		vim.g.OmniSharp_server_use_mono = 0
		-- 		vim.g.OmniSharp_server_path =
		-- 			vim.fn.expand(require("mason-registry").get_package("omnisharp"):get_install_path() .. "/omnisharp")
		-- 	end,
		-- 	dependencies = {
		-- 		"tpope/vim-dispatch",
		-- 		"williamboman/mason.nvim",
		-- 	},
		-- },
		-- {
		-- 	"nickspoons/vim-sharpenup",
		-- 	ft = dotnet_languages,
		-- 	init = function()
		-- 		vim.g.sharpenup_create_mappings = 0
		-- 	end,
		-- },
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
		{
			"iabdelkareem/csharp.nvim",
			dependencies = {
				"williamboman/mason.nvim", -- Required, automatically installs omnisharp
				"mfussenegger/nvim-dap",
				"tastyep/structlog.nvim", -- optional, but highly recommended for debugging
			},
			opts = {
				lsp = {
					-- Sets if you want to use omnisharp as your LSP
					omnisharp = {
						-- When set to false, csharp.nvim won't launch omnisharp automatically.
						enable = false,
					},
					-- Sets if you want to use roslyn as your LSP
					roslyn = {
						-- When set to true, csharp.nvim will launch roslyn automatically.
						enable = false,
						-- Path to the roslyn LSP see 'Roslyn LSP Specific Prerequisites' above.
						cmd_path = nil,
					},
					-- The capabilities to pass to the omnisharp server
					capabilities = nil,
					-- on_attach function that'll be called when the LSP is attached to a buffer
					on_attach = nil,
				},
				logging = {
					-- The minimum log level.
					level = "INFO",
				},
				dap = {
					-- When set, csharp.nvim won't launch install and debugger automatically. Instead, it'll use the debug adapter specified.
					--- @type string?
					adapter_name = nil,
				},
			},
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
		"netcoredbg",
		"omnisharp",
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
	lsp.enable("omnisharp", {
		settings = omnisharp_settings,
	})
end

return L
