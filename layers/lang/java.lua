local declarative_layer = require("LYRD.shared.declarative_layer")
local lsp = require("LYRD.layers.lsp")
local join = require("LYRD.shared.utils").join_paths

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Java language",
	required_plugins = {
		{
			"mfussenegger/nvim-jdtls",
			dependencies = {
				"mfussenegger/nvim-dap",
			},
			opts = nil,
		},
		{
			"oclay1st/maven.nvim",
			cmd = { "Maven", "MavenInit", "MavenExec", "MavenFavorites" },
			dependencies = {
				"nvim-lua/plenary.nvim",
				"muniftanjim/nui.nvim",
			},
			opts = {}, -- options, see default configuration
		},
		{
			"oclay1st/gradle.nvim",
			cmd = { "Gradle", "GradleExec", "GradleInit", "GradleFavorites" },
			dependencies = {
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
			},
			opts = {}, -- options, see default configuration
		},
		{
			"rcasia/neotest-java",
			ft = "java",
			dependencies = {
				"mfussenegger/nvim-jdtls",
				"mfussenegger/nvim-dap",
			},
		},
		{
			"weilbith/neotest-gradle",
			ft = "java",
		},
		{
			"JavaHello/spring-boot.nvim",
			ft = "java",
			dependencies = {
				"mfussenegger/nvim-jdtls",
			},
			opts = function()
				local ls_path = vim.fn.glob(
					lsp.get_pkg_path("spring-boot-tools")
						.. "/extension/language-server/spring-boot-language-server*.jar"
				)
				-- Attach the server only to workspaces that depend on Spring Boot.
				local opts = { project_filter = require("spring_boot.util").has_spring_boot_dependency }
				if ls_path ~= "" then
					opts.ls_path = ls_path
				end
				return opts
			end,
			config = function(_, opts)
				local spring_boot = require("spring_boot")
				spring_boot.setup(opts)
				-- nvim-jdtls installs its own handler first, which returns a bare nil for
				-- `vscode-spring-boot.ls.start` and makes jdtls log SERVER_REQUEST_HANDLER_ERROR.
				-- The spring-boot.nvim variant answers with vim.NIL instead.
				vim.lsp.handlers["workspace/executeClientCommand"] = spring_boot.execute_client_command
			end,
		},
	},
	required_mason_packages = {
		"palantir-java-format",
		"jdtls",
		"lombok-nightly",
		"java-test",
		"java-debug-adapter",
		"spring-boot-tools",
		"gradle-language-server",
	},
	required_treesitter_parsers = {
		"java",
		"javadoc",
		"properties",
		"sql",
	},
	required_enabled_lsp_servers = {
		"jdtls",
		"gradle_ls",
	},
	required_executables = {
		"java",
		"javac",
		"mvn",
		"gradle",
	},
	required_formatters = {
		["palantir-java-format"] = require("LYRD.shared.conform.palantir-java-format"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "java",
			format_settings = { "palantir-java-format" },
		},
	},
	required_test_adapters = {
		"neotest-java",
		"neotest-gradle",
	},
}

local function start_tooling()
	-- Check if should use Maven or Gradle
	-- If both are present, prefer Maven
	local is_maven = vim.fn.filereadable(vim.fn.getcwd() .. "/mvnw") == 1
	local is_gradle = vim.fn.filereadable(vim.fn.getcwd() .. "/gradlew") == 1
	if is_maven then
		vim.cmd("Maven")
	elseif is_gradle then
		vim.cmd("Gradle")
	else
		vim.notify("No Maven or Gradle build file found in the project root.", vim.log.levels.WARN)
	end
end

-- Mirrors runtime/lsp/jdtls.lua's get_workspace_path() so this can locate (and
-- force-remove) the cache without requiring that module, which would start a
-- new jdtls client as a side effect of `require`-ing it.
local function jdtls_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")
	return join(vim.fn.stdpath("cache"), "jdtls", "workspaces", project_path_hash)
end

local function clean_jdtls_cache()
	local workspace_path = jdtls_workspace_path()
	if vim.fn.isdirectory(workspace_path) == 0 then
		vim.notify("No jdtls cache found for this project:\n" .. workspace_path, vim.log.levels.WARN)
		return
	end

	local choice = vim.fn.confirm("Delete jdtls cache for this project?\n" .. workspace_path, "&Yes\n&No", 2)
	if choice ~= 1 then
		return
	end

	if vim.fn.delete(workspace_path, "rf") ~= 0 then
		vim.notify("Failed to delete jdtls cache:\n" .. workspace_path, vim.log.levels.ERROR)
		return
	end

	vim.notify(
		"Deleted jdtls cache:\n" .. workspace_path .. "\nRestart Neovim (or :LspRestart) to reinitialize jdtls.",
		vim.log.levels.INFO
	)
end

-- Combines the main classes discovered by jdtls with the Java launch profiles
-- from .vscode/launch.json (the single source of run/debug profiles). A profile
-- naming a discovered `mainClass` is layered over the discovered config, so it
-- inherits the resolved classpath/java executable and only overrides what the
-- profile sets (vmArgs, args, env, cwd, preLaunchTask...). Profiles without a
-- known `mainClass` are kept as-is; jdtls resolves them when launching.
---@param dap table
---@param discovered table[]
---@return table[]
local function merge_launch_json_profiles(dap, discovered)
	local provider = dap.providers and dap.providers.configs["dap.launch.json"]
	local profiles = provider and provider() or {}
	local by_main_class = {}
	for _, config in ipairs(discovered) do
		by_main_class[config.mainClass] = config
	end

	local result, covered = {}, {}
	for _, profile in ipairs(profiles) do
		if profile.type == "java" and profile.request == "launch" then
			local base = profile.mainClass and by_main_class[profile.mainClass]
			if base then
				covered[profile.mainClass] = true
			end
			table.insert(result, vim.tbl_extend("force", base or {}, profile))
		end
	end
	for _, config in ipairs(discovered) do
		if not covered[config.mainClass] then
			table.insert(result, config)
		end
	end
	return result
end

-- Discovers the project's main classes through jdtls and lets the user pick one
-- (skipped when there is only one). `no_debug` runs it without attaching the
-- debugger, which is what the "run" flow wants; the debug flow reuses the same
-- picker. Output goes to the dap-ui/integrated terminal console.
local function pick_main_class(no_debug)
	local ok_dap, dap = pcall(require, "dap")
	local ok_dap_java, jdtls_dap = pcall(require, "jdtls.dap")
	if not (ok_dap and ok_dap_java) then
		vim.notify("nvim-dap / nvim-jdtls are not available", vim.log.levels.ERROR)
		return
	end
	if #vim.lsp.get_clients({ name = "jdtls", bufnr = 0 }) == 0 then
		vim.notify("jdtls is not attached to this buffer", vim.log.levels.WARN)
		return
	end
	local function launch(config)
		config = vim.deepcopy(config)
		config.noDebug = no_debug or nil
		dap.run(config)
	end
	jdtls_dap.fetch_main_configs({}, function(discovered)
		local configs = merge_launch_json_profiles(dap, discovered)
		if #configs == 0 then
			vim.notify("No main class found in this project", vim.log.levels.WARN)
		elseif #configs == 1 then
			launch(configs[1])
		else
			vim.ui.select(configs, {
				prompt = "Main class / profile",
				format_item = function(item)
					return item.name
				end,
			}, function(choice)
				if choice then
					launch(choice)
				end
			end)
		end
	end)
end

function L.complete()
	-- Registers dap.adapters.java and refreshes the main-class launch configs
	-- once jdtls is up, so :DapContinue works in plain Maven/Gradle projects
	-- (the Hybris layer only adds remote-attach configs).
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("LYRDJavaDapSetup", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or client.name ~= "jdtls" then
				return
			end
			local ok, jdtls_dap = pcall(require, "jdtls.dap")
			if not ok then
				return
			end
			-- The java-debug bundle loads asynchronously; wait for jdtls to be ready.
			vim.defer_fn(function()
				if client:is_stopped() then
					return
				end
				pcall(jdtls_dap.setup_dap, { hotcodereplace = "auto" })
				pcall(jdtls_dap.setup_dap_main_class_configs)
			end, 2000)
		end,
	})
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("java", {
		{ cmd.LYRDCodeBuildAll, ":JdtCompile" },
		{
			cmd.LYRDCodeRun,
			function()
				pick_main_class(true)
			end,
		},
		{ cmd.LYRDCodeTooling, start_tooling },
		{ cmd.LYRDCodeSelectEnvironment, ":JdtSetRuntime" },
		{ cmd.LYRDLSPClearCache, clean_jdtls_cache },
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.maven"))
	overseer.register_template(require("LYRD.shared.overseer.gradle"))
end

return declarative_layer.apply(L)
