local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.lang.Java: LYRD.setup.Module
local L = {
	name = "Java language",
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

function L.plugins()
	setup.plugin({
		{
			"mfussenegger/nvim-jdtls",
			opts = false,
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
			"JavaHello/spring-boot.nvim",
			ft = "java",
			dependencies = {
				"mfussenegger/nvim-jdtls",
			},
			opts = function()
				local ls_path = vim.fn.glob(
					lsp.get_pkg_path("spring-boot-tools") .. "/extension/language-server/spring-boot-language-server*.jar"
				)
				if ls_path ~= "" then
					return { ls_path = ls_path }
				end
				return {}
			end,
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"palantir-java-format",
		"jdtls",
		"lombok-nightly",
		"java-test",
		"java-debug-adapter",
		"spring-boot-tools",
		"openjdk-17",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"java",
		"javadoc",
		"properties",
	})

	lsp.customize_formatter("palantir-java-format", require("LYRD.shared.conform.palantir-java-format"))
	lsp.format_with_conform("java", { "palantir-java-format" })
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-java"))
end

function L.settings()
	commands.implement("java", {
		{ cmd.LYRDCodeBuildAll, ":JdtCompile" },
		{ cmd.LYRDCodeTooling, start_tooling },
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.maven"))
	overseer.register_template(require("LYRD.shared.overseer.gradle"))
end

function L.complete()
	vim.lsp.enable("jdtls")
end

return L
