local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Python language",
	required_plugins = {
		{
			"mfussenegger/nvim-dap-python",
			dependencies = { "mfussenegger/nvim-dap" },
			config = function()
				-- WARN: Using 'uv' for uv projects support, otherwise skip.
				require("dap-python").setup("uv")
				table.insert(require("dap").configurations.python, {
					type = "python",
					request = "launch",
					name = "My custom launch configuration",
					program = "${file}",
				})
			end,
			ft = "python",
		},
		{
			"nvim-neotest/neotest-python",
			ft = "python",
		},
		{
			"linux-cultist/venv-selector.nvim",
			dependencies = {
				"neovim/nvim-lspconfig",
				"mfussenegger/nvim-dap",
				"nvim-telescope/telescope.nvim",
			},
			lazy = false,
			opts = {
				name = { "venv", ".venv" },
			},
			ft = "python",
		},
		{
			"raimon49/requirements.txt.vim",
		},
		{
			"benomahony/uv.nvim",
			opts = {
				picker_integration = true,
				keymaps = false,
			},
		},
		{
			"lukoshkin/pymove.nvim",
			opts = {},
		},
	},
	required_mason_packages = {
		"basedpyright",
		"debugpy",
		"pydocstyle",
		"pylint",
		"ruff",
		"yapf",
	},
	required_treesitter_parsers = {
		"python",
		"htmldjango",
	},
	required_enabled_lsp_servers = {
		"basedpyright",
		"ruff",
	},
	required_test_adapters = {
		"neotest-python",
	},
	required_null_ls_sources = {
		declarative_layer.source_with_opts("null-ls.builtins.diagnostics.pylint", {
			command = "python",
			args = { "-m", "pylint", "--from-stdin", "$FILENAME", "-f", "json" },
		}),
	},
}

-- Opens the .env file in the current directory
local function open_dotenv()
	local utils = require("LYRD.utils")
	utils.open_or_create_file(".env")
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("python", {
		{ cmd.LYRDCodeSelectEnvironment, ":VenvSelect" },
		{ cmd.LYRDCodeSecrets, open_dotenv },
		{ cmd.LYRDCodeRunSelection, ":LYRDReplNotebookRunCellAndMove" },
		{ cmd.LYRDCodeOrganizeFile, ":PySortFile" },
		{
			cmd.LYRDCodeTooling,
			function()
				require("uv").pick_uv_commands()
			end,
		},
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.python_tasks"))
end

return declarative_layer.apply(L)
