local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local join = require("LYRD.utils").join_paths

local L = { name = "Database" }

local function get_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")

	local result = join(setup.data_path, "dbee-workspaces", project_path_hash)
	-- Create the directory if it doesn't exist
	vim.fn.mkdir(result, "p")
	return result
end

function L.plugins()
	setup.plugin({
		{
			"kndndrj/nvim-dbee",
			dependencies = {
				"muniftanjim/nui.nvim",
			},
			build = function()
				-- Install tries to automatically detect the install method.
				-- if it fails, try calling it with one of these parameters:
				--    "curl", "wget", "bitsadmin", "go"
				require("dbee").install()
			end,
			config = function()
				require("dbee").setup({
					sources = {
						require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
						require("dbee.sources").FileSource:new(vim.fn.stdpath("state") .. "/dbee/persistence.json"),
						require("dbee.sources").FileSource:new(get_workspace_path() .. "/dbee/workspace.json"),
					},
				})
			end,
		},
		{
			"mattiasmts/cmp-dbee",
			dependencies = {
				{ "kndndrj/nvim-dbee" },
			},
			ft = "sql", -- optional but good to have
			opts = {}, -- needed
		},
	})
end

function L.preparation() end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDDatabaseUI, ":Dbee toggle" },
	})
	commands.implement("sql", {
		{ cmd.LYRDCodeRun, ":%DB" },
		{ cmd.LYRDCodeRunSelection, ":'<,'>normal <Plug>(DBUI_ExecuteQuery)" },
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "sql", "mysql", "plsql" },
		callback = function()
			require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
		end,
	})
end

return L
