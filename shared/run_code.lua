local L = {}
--- @class LYRD.RunCodeDefinition
--- @field name string The name of the task definition.
--- @field preview? string|fun():string A function that takes the code to run and returns a preview string to show in the selector.
--- @field runner fun() A function that takes the code to run and executes it.

--- @class LYRD.TreeSitterSelectorOptions
--- @field recursive_search? boolean Whether to run a recursive search up to find multiple matches or just get the match at the cursor position. Defaults to false (only get match at cursor).
--- @field query_string string The treesitter query string
--- @field lang string The language of the current buffer
--- @field node_capture_name string The name of the capture that contains the node to check
--- @field text_capture_name string|nil The name of the capture that contains the text to return (if different from node_capture_name)

--- @class LYRD.RunCodeOptions
--- @field title? string The title to show in the selector when there are multiple task definitions to choose from.
--- @field skip_visual_selection? boolean Whether to skip using the visually selected text as the code to run. If true, it will not attempt to get the visual selection and will directly use the selector or treesitter_selector to get the code to run.
--- @field selector? fun():string A function that returns the code to run. This is used when use_selection is false or when there is no selection.
--- @field treesitter_selector? LYRD.TreeSitterSelectorOptions A set of options to use a Tree-sitter query to select the code to run. This is used when use_selection is false or when there is no selection and no selector provided.
--- @field fail_if_no_selected_code? boolean Whether to fail if there is no selected code and no selector provided.
--- @field display_one_option_list? boolean Whether to display the selection menu even if there is only one task definition generated. Defaults to false (if there is only one task definition, it will be run directly without showing the selection menu).
--- @field generator fun(filename: string,code?:string, iteration: number):LYRD.RunCodeDefinition[] A function that takes the code to run and returns a list of task definitions to choose from.

--- Runs the code using the provided options.
--- @param opts LYRD.RunCodeOptions
function L.run_selection(opts)
	local utils = require("LYRD.shared.utils")
	--- @type string[]
	local candidate_selected_texts = {}

	local function has_selection()
		return #candidate_selected_texts >= 1
	end

	--- A helper function to set the selected text and log it for debugging purposes.
	--- @param text string
	local function set_selected_text(text)
		if text and text ~= "" then
			candidate_selected_texts = { text }
		end
	end
	--- Attempts to use the visually selected text as the code to run if
	--- use_visual_selection is true.
	if not opts.skip_visual_selection then
		set_selected_text(utils.get_visual_selection())
	end
	--- If there is no visually selected text, or if use_visual_selection is
	--- false, it falls back to using the selector function to get the code to
	--- run.
	if not has_selection() and opts.selector then
		set_selected_text(opts.selector())
	end
	--- If there is still no code to run, and treesitter_selector is provided, it
	--- uses the Tree-sitter query to get the code to run.
	if not has_selection() and opts.treesitter_selector then
		local ts = require("LYRD.layers.treesitter")
		if opts.treesitter_selector.recursive_search then
			candidate_selected_texts = ts.get_match_texts_at_cursor_recursive(
				opts.treesitter_selector.query_string,
				opts.treesitter_selector.lang,
				opts.treesitter_selector.node_capture_name,
				opts.treesitter_selector.text_capture_name
			)
		else
			candidate_selected_texts = {
				ts.get_match_text_at_cursor(
					opts.treesitter_selector.query_string,
					opts.treesitter_selector.lang,
					opts.treesitter_selector.node_capture_name,
					opts.treesitter_selector.text_capture_name
				),
			}
		end
	end
	--- If there is still no code to run, and fail_if_no_selected_code is true,
	--- it shows a warning notification and returns early.
	if not has_selection() and opts.fail_if_no_selected_code then
		vim.notify("No code to run", vim.log.levels.WARN)
		return
	end
	local filename = vim.api.nvim_buf_get_name(0)
	--- It generates a list of task definitions by calling the generator
	--- function with the selected text. If there are no task definitions
	--- generated, it shows a warning notification and returns early.
	--- @type LYRD.RunCodeDefinition[]
	local task_definitions = {}
	for i, selected_text in ipairs(candidate_selected_texts) do
		local generated_definitions = opts.generator(filename, selected_text, i)
		if generated_definitions and #generated_definitions > 0 then
			vim.list_extend(task_definitions, generated_definitions)
		end
	end
	if #task_definitions == 0 then
		vim.notify("No task definitions generated", vim.log.levels.WARN)
		return
	end
	--- If there is only one task definition generated, it runs it directly
	--- with the selected text and returns early.
	if #task_definitions == 1 and not opts.display_one_option_list then
		task_definitions[1].runner()
		return
	end
	--- If there are multiple task definitions generated, it shows a selection
	--- menu to the user using vim.ui.select. The user can choose which task to
	--- run, and the chosen task is executed with the selected text. If there
	--- is an error while running the task, it shows an error notification.

	--- If Telescope is available, use it for a better selection UI
	local has_pickers, pickers = pcall(require, "telescope.pickers")
	local has_finders, finders = pcall(require, "telescope.finders")
	local has_conf, conf = pcall(require, "telescope.config")
	local has_previewers, previewers = pcall(require, "telescope.previewers")
	local has_actions, actions = pcall(require, "telescope.actions")
	local has_action_state, action_state = pcall(require, "telescope.actions.state")
	if has_pickers and has_finders and has_conf and has_previewers and has_actions and has_action_state then
		pickers
			.new({}, {
				prompt_title = opts.title or "Select a way to run the code",
				finder = finders.new_table({
					results = task_definitions,
					entry_maker = function(entry)
						return {
							value = entry,
							display = entry.name,
							ordinal = entry.name,
						}
					end,
				}),
				sorter = conf.values.generic_sorter({}),
				previewer = previewers.new_buffer_previewer({
					define_preview = function(self, entry)
						if not entry.value.preview then
							return
						end
						local preview_bufnr = self.state.bufnr
						local preview_value = entry.value.preview
						if type(preview_value) == "function" then
							preview_value = preview_value()
						end
						local lines = vim.split(preview_value, "\n", { plain = true })
						vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, lines)
					end,
				}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						if not selection then
							return
						end
						local ok, err = pcall(selection.value.runner)
						if not ok then
							vim.notify("Error running task: " .. err, vim.log.levels.ERROR)
						end
					end)
					return true
				end,
			})
			:find()
	else
		vim.ui.select(task_definitions, {
			prompt = opts.title or "Select a way to run the code",
			format_item = function(item)
				return item.name
			end,
		}, function(choice)
			if not choice then
				return
			end
			local ok, err = pcall(choice.runner, filename, selected_text)
			if not ok then
				vim.notify("Error running task: " .. err, vim.log.levels.ERROR)
			end
		end)
	end
end
return L
