local setup = require("LYRD.shared.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.shared.utils")
local frecency_utils = require("LYRD.shared.utils.frecency")

---@class LYRD.layer.Telescope: LYRD.shared.setup.Module
local L = {
	name = "Telescope",
	unskippable = true,
	use_frecency = false,
	command_palette = {
		frecency_enabled = true,
		frecency_file = utils.get_lyrd_data_path("command_palette_frecency.json"),
		--- @type CommandListItem[]|nil
		cached_commands = nil,
		frecency = nil,
	},
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

--- Telescope Command Palette handler.
--- Provides a UI for selecting and executing commands with telescope.
--- Commands are sorted by name or frecency, and a cache is used for performance.
local function telescopeCommandPalette()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local entry_display = require("telescope.pickers.entry_display")
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	--- Retrieves the list of commands for the command palette, sorted by frecency if enabled.
	--- Utilizes a cache for previously loaded commands to enhance performance.
	--- Loads frecency data from a configured file and sorts commands accordingly.
	--- Sorts commands either by their name or label.
	--- @param invalidate_cache boolean Whether to invalidate the cached commands and reload them
	--- @return CommandListItem[] The list of commands sorted and ready for display in the command palette.
	local function get_command_list(invalidate_cache)
		if L.command_palette.cached_commands and not invalidate_cache then
			return L.command_palette.cached_commands
		end
		L.command_palette.cached_commands = commands.get_command_list()
		if L.command_palette.frecency_enabled then
			L.command_palette.frecency = frecency_utils.load(L.command_palette.frecency_file)
			local items = L.command_palette.cached_commands or {}
			frecency_utils.sort(items, L.command_palette.frecency, function(item)
				return item.cmd and item.cmd.name or nil
			end, function(item)
				return item.label
			end)
			L.command_palette.cached_commands = items
		end
		return L.command_palette.cached_commands
	end

	--- Updates the frecency of a selected command.
	--- This ensures that frequently used commands are prioritized in the UI.
	--- @param command_name string The name of the command to update frecency for.
	local function update_command_frecency(command_name)
		if not L.command_palette.frecency_enabled then
			return
		end
		L.command_palette.frecency = L.command_palette.frecency or {}
		frecency_utils.increment(L.command_palette.frecency, command_name)
		frecency_utils.save(L.command_palette.frecency_file, L.command_palette.frecency)
		get_command_list(true) -- Invalidate cache to re-sort commands based on updated frecency
	end

	local items = get_command_list()
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
						ordinal = string.format(
							"%s %s",
							item.cmd and item.cmd.desc or "",
							item.cmd and item.cmd.name or ""
						),
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
						selection.value.cmd:execute()
						update_command_frecency(selection.value.cmd.name)
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
