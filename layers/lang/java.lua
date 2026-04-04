local lsp = require("LYRD.layers.lsp")
local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Java language",
	required_plugins = {
		{
			"mfussenegger/nvim-jdtls",
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
		"openjdk-17",
	},
	required_treesitter_parsers = {
		"java",
		"javadoc",
		"properties",
	},
	required_enabled_lsp_servers = {
		"jdtls",
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

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("java", {
		{ cmd.LYRDCodeBuildAll, ":JdtCompile" },
		{ cmd.LYRDCodeTooling, start_tooling },
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.maven"))
	overseer.register_template(require("LYRD.shared.overseer.gradle"))
end

return declarative_layer.apply(L)
