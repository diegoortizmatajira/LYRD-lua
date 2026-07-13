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
				if ls_path ~= "" then
					return { ls_path = ls_path }
				end
				return {}
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

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("java", {
		{ cmd.LYRDCodeBuildAll, ":JdtCompile" },
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
