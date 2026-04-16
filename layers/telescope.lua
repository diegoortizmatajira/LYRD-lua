local setup = require("LYRD.shared.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.shared.utils")

local command_palette_frecency_file = utils.get_lyrd_data_path("command_palette_frecency.json")

--- @return table<string, integer>
local function load_command_palette_frecency()
	if vim.fn.filereadable(command_palette_frecency_file) == 0 then
		return {}
	end
	local content = table.concat(vim.fn.readfile(command_palette_frecency_file), "\n")
	if content == "" then
		return {}
	end
	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return {}
	end
	return data
end

--- @param frecency table<string, integer>
local function save_command_palette_frecency(frecency)
	local dir = vim.fn.fnamemodify(command_palette_frecency_file, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, encoded = pcall(vim.json.encode, frecency)
	if not ok then
		vim.notify("Could not encode command frecency data", vim.log.levels.ERROR)
		return
	end
	vim.fn.writefile(vim.split(encoded, "\n", { plain = true }), command_palette_frecency_file)
end

--- @param items CommandListItem[]
--- @param frecency table<string, integer>
local function sort_command_palette_items_by_frecency(items, frecency)
	table.sort(items, function(a, b)
		local a_name = a.cmd and a.cmd.name or ""
		local b_name = b.cmd and b.cmd.name or ""
		local a_count = frecency[a_name] or 0
		local b_count = frecency[b_name] or 0
		if a_count == b_count then
			return a.label < b.label
		end
		return a_count > b_count
	end)
end

--- @param item CommandListItem
--- @param frecency table<string, integer>
local function track_command_palette_usage(item, frecency)
	local command_name = item and item.cmd and item.cmd.name
	if not command_name or command_name == "" then
		return
	end
	frecency[command_name] = (frecency[command_name] or 0) + 1
	save_command_palette_frecency(frecency)
end

---@class LYRD.layer.Telescope: LYRD.shared.setup.Module
local L = {
	name = "Telescope",
	unskippable = true,
	use_frecency = false,
}

function L.plugins()
	setup.plugin({
		{ "nvim-lua/popup.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("fzf")
			end,
			build = "make",
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"nvim-telescope/telescope-ui-select.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("ui-select")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"benfowler/telescope-luasnip.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("luasnip")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"nvim-telescope/telescope.nvim",
			opts = {},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope-fzf-native.nvim",
				"nvim-telescope/telescope-ui-select.nvim",
			},
		},
		{
			"nvim-telescope/telescope-frecency.nvim",
			-- install the latest stable version
			version = "*",
			opts = {
				show_filter_column = false,
			},
			enabled = L.use_frecency,
			config = function(_, opts)
				require("telescope-frecency").setup(opts)
				require("telescope").load_extension("frecency")
			end,
		},
		{
			-- Adds support for viewing code outlines in a floating window
			"stevearc/aerial.nvim",
			opts = {
				close_on_select = true,
				layout = {
					default_direction = "right",
				},
			},
			-- Optional dependencies
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
				"nvim-telescope/telescope.nvim",
			},
			config = function(_, opts)
				require("aerial").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("aerial")
			end,
		},
	})
end

function L.select_file_and_execute(callback, title, filter, working_directory)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local builtin = require("telescope.builtin")
	builtin.find_files({
		prompt_title = title or "Select a file",
		cwd = working_directory or vim.fn.getcwd(), -- Set the current working directory
		find_command = { "find", ".", "-type", "f", "-name", filter or "*.*" },
		attach_mappings = function(prompt_bufnr, map)
			local function on_select()
				local selected_entry = action_state.get_selected_entry()
				local file_path = selected_entry.path or selected_entry.filename
				actions.close(prompt_bufnr)
				callback(file_path) -- Call the callback function with the selected file path
			end
			map("i", "<CR>", on_select)
			map("n", "<CR>", on_select)
			return true
		end,
	})
end

local function telescopeCommandPalette()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local entry_display = require("telescope.pickers.entry_display")
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local frecency = load_command_palette_frecency()
	local items = commands.get_command_list()
	sort_command_palette_items_by_frecency(items, frecency)
	local command_name_width = 0
	for _, item in ipairs(items) do
		local name = item.cmd and item.cmd.name or ""
		command_name_width = math.max(command_name_width, vim.fn.strdisplaywidth(name))
	end
	command_name_width = command_name_width + 2

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 3 },
			{ width = command_name_width },
			{ remaining = true, right_justify = true },
		},
	})

	pickers
		.new({}, {
			prompt_title = "Select a command to execute",
			finder = finders.new_table({
				results = items,
				---@param item CommandListItem
				entry_maker = function(item)
					return {
						value = item,
						ordinal = string.format("%s %s", item.cmd and item.cmd.desc or "", item.cmd and item.cmd.name or ""),
						display = function(entry)
							local command_name = entry.value.cmd and entry.value.cmd.name or ""
							return displayer({
								{ entry.value.icon, "TelescopeResultsConstant" },
								entry.value.cmd.desc,
								{ command_name, "TelescopeResultsComment" },
							})
						end,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value and selection.value.cmd then
						track_command_palette_usage(selection.value, frecency)
						selection.value.cmd:execute()
					end
				end)
				return true
			end,
		})
		:find()
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDSearchFiles, L.use_frecency and ":Telescope frecency workspace=CWD" or "Telescope find_files" },
		{
			cmd.LYRDSearchAllFiles,
			function()
				require("telescope.builtin").find_files({ no_ignore = true })
			end,
		},
		{ cmd.LYRDSearchBuffers, ":Telescope buffers" },
		{ cmd.LYRDSearchGitFiles, ":Telescope git_files" },
		{ cmd.LYRDSearchRecentFiles, ":Telescope oldfiles" },
		{ cmd.LYRDSearchBufferLines, ":Telescope current_buffer_fuzzy_lines" },
		{ cmd.LYRDSearchCommandHistory, ":Telescope command_history" },
		{ cmd.LYRDSearchKeyMappings, ":Telescope keymaps" },
		{ cmd.LYRDSearchBufferTags, ":Telescope current_buffer_tags" },
		{ cmd.LYRDSearchLiveGrep, ":Telescope live_grep" },
		{ cmd.LYRDSearchFiletypes, ":Telescope filetypes" },
		{ cmd.LYRDSearchQuickFixes, ":Telescope quickfix" },
		{ cmd.LYRDSearchRegisters, ":Telescope registers" },
		{ cmd.LYRDSearchHighlights, ":Telescope highlights" },
		{ cmd.LYRDSearchCurrentString, ":Telescope grep_string" },
		{ cmd.LYRDSearchCommands, ":Telescope commands" },
		{ cmd.LYRDSearchSymbols, ":Telescope aerial" },
		{ cmd.LYRDLSPFindReferences, ":Telescope lsp_references" },
		{ cmd.LYRDLSPFindDocumentSymbols, ":Telescope lsp_document_symbols" },
		{ cmd.LYRDLSPFindWorkspaceSymbols, ":Telescope lsp_workspace_symbols" },
		{ cmd.LYRDLSPFindDocumentDiagnostics, ":Telescope lsp_document_diagnostics" },
		{ cmd.LYRDLSPFindWorkspaceDiagnostics, ":Telescope lsp_workspace_diagnostics" },
		{ cmd.LYRDLSPFindImplementations, ":Telescope lsp_implementations" },
		{ cmd.LYRDLSPFindDefinitions, ":Telescope lsp_definitions" },
		{ cmd.LYRDResumeLastSearch, ":Telescope resume" },
		{ cmd.LYRDCodeInsertSnippet, "Telescope luasnip" },
		{ cmd.LYRDViewCodeOutline, ":AerialToggle" },
		{ cmd.LYRDViewMarks, ":Telescope marks" },
		{ cmd.LYRDCommandPalette, telescopeCommandPalette },
	})
end

return L
