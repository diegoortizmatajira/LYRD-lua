local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Java language" }

function L.plugins()
	setup.plugin({
		{
			"nvim-java/nvim-java",
			opts = {
				jdk = {
					auto_install = false,
				},
			},
		},
	})
end

function L.preparation()
	lsp.mason_ensure({})
end

function L.settings()
	commands.implement("java", {
		{ cmd.LYRDCodeBuildAll, ":JavaBuildBuildWorkspace" },
		{ cmd.LYRDTestFunc, ":JavaTestRunCurrentMethod" },
		{ cmd.LYRDTestSuite, ":JavaTestRunCurrentClass" },
	})
end

function L.complete()
	lsp.enable("jdtls", {
		handlers = {
			-- By assigning an empty function, you can remove the notifications
			-- printed to the cmd
			["$/progress"] = function(_, _, _) end,
		},
	})
end

return L
