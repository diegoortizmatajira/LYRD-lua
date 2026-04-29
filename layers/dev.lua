local declarative_layer = require("LYRD.shared.declarative_layer")

local ENV_FILETYPES = { "env", "dotenv", "edf", "conf" }
--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Development Tools",
	required_plugins = {
		{
			-- Adds support for commenting code with TODOs, FIXMEs, etc.
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
		},
		{
			-- Adds support for viewing colors in color values in the editor
			"norcalli/nvim-colorizer.lua",
		},
		{
			"ellisonleao/dotenv.nvim",
			opts = {},
			cmd = { "Dotenv", "DotenvGet" },
		},
		{
			"ph1losof/ecolog2.nvim",
			lazy = false,
			build = "cargo install ecolog-lsp",
			opts = {},
		},
		{
			"ph1losof/shelter.nvim",
			lazy = false,
			opts = {
				env_filetypes = ENV_FILETYPES,
			},
		},
		{
			"jesseleite/nvim-macroni",
			lazy = false,
			opts = {
				-- All of your `setup(opts)` and saved macros will go here
			},
		},
		{
			"chentoast/marks.nvim",
			event = "VeryLazy",
			opts = {},
		},
	},
	required_mason_packages = {
		"editorconfig-checker",
		"dotenv-linter",
	},
	required_formatters = {
		["dotenv_linter"] = require("LYRD.shared.conform.dotenv-linter"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = ENV_FILETYPES,
			format_settings = { "dotenv_linter" },
		},
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.editorconfig_checker",
		declarative_layer.source_with_opts("null-ls.builtins.diagnostics.dotenv_linter", {
			args = { "check", "$FILENAME" },
			extra_filetypes = ENV_FILETYPES,
		}),
	},
	required_executables = {
		"live-server",
		"ngrok",
		"trufflehog",
	},
	required_filetype_definitions = {
		-- Mappings based on file extension
		extension = {
			env = "env",
		},
		-- Mappings based on FULL filename
		filename = {
			[".env"] = "env",
			["env"] = "env",
		},
		-- Mappings based on filename pattern match
		pattern = {
			-- Match filenames like ".env.development", "env.local" and so on
			[".?env.*"] = "env",
		},
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
		focus = true,
	})
end

local function expose_server(port)
	local command = "ngrok"
	if vim.fn.executable(command) == 0 then
		vim.notify("ngrok is not installed. Please install it.", vim.log.levels.ERROR)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = string.format("Exposing Local server (port: %s)", port),
		cmd = command,
		args = {
			"http",
			port,
		},
		open_in_split = true,
		focus = true,
	})
end

local function parse_trufflehog_line(line)
	local ok, result = pcall(vim.json.decode, line)
	if not ok or type(result) ~= "table" then
		return
	end
	local metadata = result.SourceMetadata
	if not metadata or not metadata.Data then
		return
	end
	local file, lnum
	for _, source_data in pairs(metadata.Data) do
		if type(source_data) == "table" then
			file = source_data.file
			lnum = source_data.line
			break
		end
	end
	if not file then
		return
	end
	local detector = result.DetectorName or "Unknown"
	local verified = result.Verified and "verified" or "unverified"
	local redacted = result.Redacted or ""
	local text = string.format("[%s] %s secret found: %s", verified, detector, redacted)
	return file, tostring(lnum or 0), "0", text
end

function L.scan_for_secrets()
	local command = "trufflehog"
	if vim.fn.executable(command) == 0 then
		vim.notify("trufflehog is not installed. Please install it.", vim.log.levels.ERROR)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = "Scanning for secrets with TruffleHog",
		cmd = command,
		args = {
			"filesystem",
			"--json",
			"--force-skip-binaries",
			"--force-skip-archives",
			".",
		},
		diagnostics_parser = { "extract", parse_trufflehog_line, "filename", "lnum", "col", "text" },
		open_in_split = true,
		auto_close = true,
		focus = false,
	})
end

function L.start_dev_server()
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

function L.expose_local_server()
	vim.ui.input({ prompt = "Enter port to expose:", default = "3000" }, function(port)
		if not port or port == "" then
			return
		end
		expose_server(port)
	end)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("*", {
		{ cmd.LYRDDevServerStart, L.start_dev_server },
		{ cmd.LYRDDevExposeLocalServer, L.expose_local_server },
		{
			cmd.LYRDSearchMacros,
			function()
				require("telescope").extensions.macroni.saved_macros()
			end,
		},
		{ cmd.LYRDScanForSecrets, L.scan_for_secrets },
	})
	commands.implement(ENV_FILETYPES, {
		{ cmd.LYRDToggleBufferDecorations, ":Shelter toggle" },
		{ cmd.LYRDLSPHoverInfo, "Shelter peek" },
	})
end

return declarative_layer.apply(L)
