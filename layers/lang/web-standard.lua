local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Web Standard Languages: HTML, CSS, SCSS",
	required_plugins = {
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"windwp/nvim-autopairs",
			},
			opts = {},
		},
		{
			"jezda1337/nvim-html-css",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {
				enable_on = {
					"html",
					"htmldjango",
					"tsx",
					"jsx",
					"erb",
					"svelte",
					"vue",
					"blade",
					"php",
					"templ",
					"astro",
				},
				handlers = {
					definition = {
						bind = "gd",
					},
					hover = {
						bind = "K",
						wrap = true,
						border = "none",
						position = "cursor",
					},
				},
				documentation = {
					auto_show = true,
				},
				peek = {
					enabled = true,
					border = "rounded",
					position = "center",
					width = 0.5,
					height = 0.5,
					focus = true,
					style = "minimal",
				},
				style_sheets = {
					"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
					"https://cdnjs.cloudflare.com/ajax/libs/bulma/1.0.3/css/bulma.min.css",
					"./index.css", -- `./` refers to the current working directory.
				},
			},
		},
	},
	required_mason_packages = {
		"html-lsp",
		"css-lsp",
		"emmet-language-server",
		"emmet-ls",
		"prettier",
	},
	required_treesitter_parsers = {
		"html",
		"css",
		"scss",
	},
	required_enabled_lsp_servers = {
		"emmet_language_server",
		"cssls",
		"html",
	},
	required_null_ls_sources = {
		declarative_layer.source_with_opts("null-ls.builtins.formatting.prettier", {
			extra_filetypes = { "htmldjango" },
		}),
	},
}

local function run_local_server(port, folder)
	local command = "live-server"
	if vim.fn.executable(command) == 0 then
		vim.notify(
			"live-server is not installed. Please install it globally using 'npm i -g live-server'",
			vim.log.levels.ERROR
		)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = string.format("Developer Local Server (port: %s)", port),
		cmd = command,
		args = {
			string.format("--port=%s", port),
			folder,
		},
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

function L.StartDevServer()
	vim.ui.input({ prompt = "Enter port number:", default = "3000" }, function(port)
		local current_dir = vim.fn.getcwd()
		vim.ui.input(
			{ prompt = "Folder to serve (leave blank for current directory):", default = current_dir },
			function(folder)
				-- Check if the provided folder is valid
				if folder == "" then
					folder = current_dir
				elseif not vim.fn.isdirectory(folder) then
					vim.notify("Invalid folder path: " .. folder, vim.log.levels.ERROR)
					return
				end
				run_local_server(port, folder)
			end
		)
	end)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("*", {
		{ cmd.LYRDDevServerStart, L.StartDevServer },
	})
end

return declarative_layer.apply(L)
