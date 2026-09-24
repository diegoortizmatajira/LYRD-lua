local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local encoding = require("LYRD.shared.utils.encoding")
local utils = require("LYRD.shared.utils")

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @class LYRD.EncodingMethod
--- @field name string Display name shown in the picker.
--- @field transform LYRD.utils.encoding.Transform

--- @type LYRD.EncodingMethod[]
local encode_methods = {
	{ name = "URL Encode", transform = encoding.url_encode },
	{ name = "Base64 Encode", transform = encoding.base64_encode },
	{ name = "UUEncode", transform = encoding.uuencode },
}

--- @type LYRD.EncodingMethod[]
local decode_methods = {
	{ name = "URL Decode", transform = encoding.url_decode },
	{ name = "Base64 Decode", transform = encoding.base64_decode },
	{ name = "UUDecode", transform = encoding.uudecode },
	{ name = "JWT Decode", transform = encoding.jwt_decode },
}

--- Runs the method's transform over the given buffer range and writes the
--- result back in place of it.
--- @param bufnr integer
--- @param start_row integer
--- @param start_col integer
--- @param end_row integer
--- @param end_col integer Inclusive end column.
--- @param method LYRD.EncodingMethod
local function apply_method(bufnr, start_row, start_col, end_row, end_col, method)
	local input_text =
		table.concat(vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {}), "\n")
	local result, err = method.transform(input_text)
	if not result then
		vim.notify(string.format("%s failed: %s", method.name, err or "unknown error"), vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_buf_set_text(
		bufnr,
		start_row,
		start_col,
		end_row,
		end_col + 1,
		vim.split(result, "\n", { plain = true })
	)
end

--- Shows a picker (Telescope if available, otherwise `vim.ui.select`) listing
--- the given methods and applies the chosen one to the current visual
--- selection.
--- @param title string
--- @param methods LYRD.EncodingMethod[]
local function pick_and_apply(title, methods)
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = utils.get_visual_range(bufnr)
	if not start_row or not start_col or not end_row or not end_col then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	local function on_choice(method)
		if method then
			apply_method(bufnr, start_row, start_col, end_row, end_col, method)
		end
	end

	local has_pickers, pickers = pcall(require, "telescope.pickers")
	local has_finders, finders = pcall(require, "telescope.finders")
	local has_conf, conf = pcall(require, "telescope.config")
	local has_actions, actions = pcall(require, "telescope.actions")
	local has_action_state, action_state = pcall(require, "telescope.actions.state")

	if has_pickers and has_finders and has_conf and has_actions and has_action_state then
		pickers
			.new({}, {
				prompt_title = title,
				finder = finders.new_table({
					results = methods,
					entry_maker = function(entry)
						return { value = entry, display = entry.name, ordinal = entry.name }
					end,
				}),
				sorter = conf.values.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						on_choice(selection and selection.value)
					end)
					return true
				end,
			})
			:find()
	else
		vim.ui.select(methods, {
			prompt = title,
			format_item = function(item)
				return item.name
			end,
		}, on_choice)
	end
end

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Encoding/Decoding utilities",
}

function L.settings()
	commands.implement("*", {
		{
			cmd.LYRDCodeEncode,
			function()
				pick_and_apply("Encode selection", encode_methods)
			end,
		},
		{
			cmd.LYRDCodeDecode,
			function()
				pick_and_apply("Decode selection", decode_methods)
			end,
		},
	})
end

return declarative_layer.apply(L)
