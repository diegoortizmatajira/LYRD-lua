local declarative_layer = require("LYRD.shared.declarative_layer")

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
		"rgx",
		"jscpd",
	},
	required_executables = {
		"live-server",
		"ngrok",
		"trufflehog",
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

--- Options for `L.find_duplicates`. A `.jscpd.json` in the project root is still honored by jscpd itself.
L.duplicates = {
	min_lines = 5,
	min_tokens = 50,
	ignore = {
		"**/node_modules/**",
		"**/.git/**",
		"**/dist/**",
		"**/build/**",
		"**/target/**",
		"**/bin/platform/**",
		"**/*.min.*",
	},
	--- Restrict to these jscpd formats (e.g. { "java", "lua" }); empty means all.
	formats = {},
	--- Search kinds offered by the prompt, with the extra jscpd flags each one needs.
	modes = {
		{ label = "Exact copies", args = {} },
		{
			label = "Renamed (identifiers and literals may differ)",
			args = { "--ignore-identifiers", "--ignore-literals" },
		},
		{ label = "Similar functions (structural, supported languages only)", args = { "--similarity" } },
	},
}

--- @param file { name: string, start?: integer, startLoc?: { line: integer } }
local function clone_line(file)
	return file.startLoc and file.startLoc.line or file.start or 1
end

--- Converts a jscpd JSON report into quickfix items, two per clone (one per side).
--- @param report table
--- @param root string
local function report_to_quickfix(report, root)
	local items = {}
	for _, dup in ipairs(report.duplicates or {}) do
		local sides = { dup.firstFile, dup.secondFile }
		for i, file in ipairs(sides) do
			local other = sides[3 - i]
			local name = file.name
			if not vim.startswith(name, "/") then
				name = root .. "/" .. name
			end
			table.insert(items, {
				filename = name,
				lnum = clone_line(file),
				end_lnum = file.endLoc and file.endLoc.line or file["end"],
				text = string.format(
					"Duplicated (%s) %d lines with %s:%d",
					dup.kind or "exact",
					dup.lines or 0,
					other.name,
					clone_line(other)
				),
			})
		end
	end
	return items
end

--- Asks which kind of duplicates to look for, then runs `run_duplicates_scan`.
function L.find_duplicates()
	if vim.fn.executable("jscpd") == 0 then
		vim.notify("jscpd is not installed. Please install it via Mason.", vim.log.levels.ERROR)
		return
	end
	vim.ui.select(L.duplicates.modes, {
		prompt = "Find duplicated code:",
		format_item = function(mode)
			return mode.label
		end,
	}, function(mode)
		if mode then
			L.run_duplicates_scan(mode.args)
		end
	end)
end

--- Runs jscpd over the current working directory through overseer and loads the
--- clones into the quickfix list, showing both locations of every clone.
--- @param extra_args string[] mode specific jscpd flags
function L.run_duplicates_scan(extra_args)
	local opts = L.duplicates
	local root = vim.fn.getcwd()
	local output = vim.fn.tempname()
	-- Passed as a list (no shell involved) so globs in --ignore aren't expanded by fish/zsh.
	local cmdline = {
		"jscpd",
		"--reporters",
		"json",
		"--output",
		output,
		"--min-lines",
		tostring(opts.min_lines),
		"--min-tokens",
		tostring(opts.min_tokens),
	}
	vim.list_extend(cmdline, extra_args)
	if #opts.ignore > 0 then
		vim.list_extend(cmdline, { "--ignore", table.concat(opts.ignore, ",") })
	end
	if #opts.formats > 0 then
		vim.list_extend(cmdline, { "--format", table.concat(opts.formats, ",") })
	end
	table.insert(cmdline, ".")

	local tasks = require("LYRD.layers.tasks")
	local task = tasks.run_task({
		name = "Finding duplicated code with jscpd",
		cmd = cmdline,
		cwd = root,
		silent = true,
	})
	task:subscribe("on_complete", function(_, status)
		vim.schedule(function()
			local report_path = output .. "/jscpd-report.json"
			if status ~= "SUCCESS" or vim.fn.filereadable(report_path) == 0 then
				vim.notify("jscpd failed to produce a report", vim.log.levels.ERROR)
				return
			end
			local ok, report = pcall(vim.json.decode, table.concat(vim.fn.readfile(report_path), "\n"))
			vim.fn.delete(output, "rf")
			if not ok then
				vim.notify("jscpd report could not be parsed", vim.log.levels.ERROR)
				return
			end
			local items = report_to_quickfix(report, root)
			if #items == 0 then
				vim.notify("No duplicated code found", vim.log.levels.INFO)
				return
			end
			local total = report.statistics and report.statistics.total or {}
			vim.fn.setqflist({}, " ", { title = "Duplicated code (jscpd)", items = items })
			vim.cmd("copen")
			vim.notify(
				string.format(
					"%d clones found, %s%% of lines duplicated",
					#items / 2,
					tostring(total.percentage or "?")
				),
				vim.log.levels.INFO
			)
		end)
		return false
	end)
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

--- Opens `rgx` (regex debugger) in a floating terminal popup, similar to the
--- LazyGit/LazyDocker popups. If called from a visual selection, the selected
--- text is passed to `rgx --vim` as the pattern to test; otherwise `rgx --vim`
--- is opened without a pattern.
function L.regex_test()
	if vim.fn.executable("rgx") == 0 then
		vim.notify("rgx is not installed. Please install it via Mason.", vim.log.levels.ERROR)
		return
	end
	local utils = require("LYRD.shared.utils")
	local ui = require("LYRD.layers.lyrd-ui")
	local selection = utils.get_visual_selection()
	local command = "rgx --vim"
	if selection ~= "" then
		command = string.format("%s %s", command, vim.fn.shellescape(selection))
	end
	ui.toggle_external_app_terminal(command)
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
		{ cmd.LYRDRegexTest, L.regex_test },
		{ cmd.LYRDCodeFindDuplicates, L.find_duplicates },
	})
end

return declarative_layer.apply(L)
