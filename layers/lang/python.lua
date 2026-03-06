local lsp = require("LYRD.layers.lsp")
local concrete_module = require("LYRD.shared.concrete_module")

---@class LYRD.layer.lang.Python: LYRD.setup.Module
local L = concrete_module:new({
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
})

-- Opens the .env file in the current directory
local function open_dotenv()
	local utils = require("LYRD.utils")
	utils.open_or_create_file(".env")
end

function L:preparation()
	concrete_module.preparation(self)

	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		-- Custom pylint to use the module in the environment (instead of the Mason one). Requires to install pylint manually.
		null_ls.builtins.diagnostics.pylint.with({
			command = "python",
			args = {
				"-m",
				"pylint",
				"--from-stdin",
				"$FILENAME",
				"-f",
				"json",
			},
		}),
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-python"))
end

function L:settings()
	concrete_module.settings(self)

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

return L
