local setup = require("LYRD.setup")

local L = { name = "Database" }

function L.plugins(s)
	setup.plugin(s, {
		"MunifTanjim/nui.nvim",
		{
			"kndndrj/nvim-dbee",
			requires = {
				"MunifTanjim/nui.nvim",
			},
			run = function()
				-- Install tries to automatically detect the install method.
				-- if it fails, try calling it with one of these parameters:
				--    "curl", "wget", "bitsadmin", "go"
				require("dbee").install()
			end,
		},
	})
end

function L.settings(_)
	require("dbee").setup()
end

function L.keybindings(s)
	local commands = require("LYRD.layers.commands")
	local c = commands.command_shortcut
	local mappings = require("LYRD.layers.mappings")

	mappings.space_menu(s, { { { "d" }, "Database" } })
	mappings.space(s, {
		{ "n", { "d", "d" }, c("Dbee"), "Dbee UI" },
	})
end

function L.complete(_) end

return L
