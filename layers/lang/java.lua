local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local join = require("LYRD.utils").join_paths

local L = { name = "Java language" }

local function get_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")

	local nvim_cache_path = vim.fn.stdpath("cache")
	return join(nvim_cache_path, "jdtls", "workspaces", project_path_hash)
end

function L.get_lsp_params()
	local jdtls = require("jdtls")
	local jdtls_install = vim.fn.expand("$MASON/packages/jdtls")

	local bundles = {}

	-- Include java-test if installed
	local java_test_install = vim.fn.expand("$MASON/packages/java-test")
	local java_test_bundle = vim.split(vim.fn.glob(java_test_install .. "/extension/server/*.jar"), "\n")
	if java_test_bundle[1] ~= "" then
		vim.list_extend(bundles, java_test_bundle)
	end
	-- Include java-debug-adapter if installed
	local java_debug_install = vim.fn.expand("$MASON/packages/java-debug-adapter")
	local java_debug_bundle =
		vim.split(vim.fn.glob(java_debug_install .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")

	if java_debug_bundle[1] ~= "" then
		vim.list_extend(bundles, java_debug_bundle)
	end

	local lombok_install = vim.fn.expand("$MASON/packages/lombok-nightly")
	return {
		paths = {
			data_dir = vim.fn.stdpath("cache") .. "/nvim-jdtls",
			java_agent = lombok_install .. "/lombok.jar",
			launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher.jar"),
			runtimes = {},
			bundles = bundles,
			platform_config = vim.fn.stdpath("cache") .. "/jdtls/config",
			workspace_path = get_workspace_path(),
		},
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	}
end

function L.plugins()
	setup.plugin({
		{
			"eatgrass/maven.nvim",
			cmd = { "Maven", "MavenExec" },
			dependencies = "nvim-lua/plenary.nvim",
			config = function()
				require("maven").setup({
					executable = "./mvnw",
				})
			end,
		},
		{
			"mfussenegger/nvim-jdtls",
			opts = false,
		},
		-- {
		-- 	-- "nvim-java/nvim-java",
		-- 	"diegoortizmatajira/nvim-java",
		-- 	opts = {
		-- 		spring_boot_tools = {
		-- 			enable = true,
		-- 			version = "1.59.0",
		-- 		},
		-- 		java_test = {
		-- 			enable = true,
		-- 			version = "0.43.1",
		-- 		},
		-- 		mason = {
		-- 			disable_automatic_update = true,
		-- 		},
		-- 	},
		-- },
	})
end

function L.preparation()
	lsp.mason_ensure({
		"jdtls",
		"lombok-nightly",
		"java-test",
		"java-debug-adapter",
		"google-java-format",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"java",
		"javadoc",
		"properties",
	})
	lsp.format_with_conform("java", {
		"google-java-format",
	})
end

function L.settings()
	commands.implement("java", {
		-- { cmd.LYRDCodeBuildAll, ":JavaBuildBuildWorkspace" },
		-- { cmd.LYRDTestFunc, ":JavaTestRunCurrentMethod" },
		-- { cmd.LYRDTestSuite, ":JavaTestRunCurrentClass" },
	})
end

function L.complete()
	vim.lsp.enable("jdtls")
end

return L
