local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Java language" }

function L.plugins()
	setup.plugin({})
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
		{ cmd.LYRDCodeBuildAll, ":JavaBuildBuildWorkspace" },
		{ cmd.LYRDTestFunc, ":JavaTestRunCurrentMethod" },
		{ cmd.LYRDTestSuite, ":JavaTestRunCurrentClass" },
	})
end

function L.complete()
	vim.lsp.enable("jdtls")
end

return L
