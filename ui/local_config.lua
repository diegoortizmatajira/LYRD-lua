local utils = require("LYRD.shared.utils")
local icons = require("LYRD.layers.icons")

local UI = {}

--- Extracts the short display name from a full layer module path.
--- @param layer_module string Full module path (e.g., "LYRD.layers.lang.python")
--- @return string Short name for display
local function display_name(layer_module)
	return layer_module:gsub("^LYRD%.layers%.", "")
end

--- Generates the buffer lines from the current state.
--- @param layers string[] Full list of layer module paths
--- @param skipped table<string, boolean> Set of skipped layer paths
--- @param names table<string, string> Map of module path to display name
--- @return string[] Lines to display in the buffer
local function render_lines(layers, skipped, names)
	local lines = {}
	table.insert(lines, "LYRD Local Configuration - Layer Selection")
	table.insert(lines, string.rep("─", 50))
	table.insert(lines, "")
	table.insert(lines, " <Space>/<Enter> toggle  |  <S>/:w save  |  <q>/Esc cancel")
	table.insert(lines, "")
	for _, layer in ipairs(layers) do
		local marker = skipped[layer] and icons.ui.checkbox_unchecked .. " SKIP" or icons.ui.checkbox_checked .. " LOAD"
		table.insert(lines, string.format("  %s  %s", marker, names[layer] or display_name(layer)))
	end
	return lines
end

--- Writes the local config file with the given skip_layers list.
--- @param skip_layers string[] List of layer module paths to skip
local function save_local_config(skip_layers)
	local setup = require("LYRD.shared.setup")
	local path = setup.local_config_path
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	local lines = {
		'require("LYRD.shared.setup")',
		"",
		"--- @type LYRD.shared.setup.LocalConfig",
		"return {",
		"\tskip_layers = {",
	}
	for _, layer in ipairs(skip_layers) do
		table.insert(lines, string.format('\t\t"%s",', layer))
	end
	table.insert(lines, "\t},")
	table.insert(lines, "}")
	table.insert(lines, "")

	local file = io.open(path, "w")
	if file then
		file:write(table.concat(lines, "\n"))
		file:close()
		vim.notify("Local config saved. Restart Neovim to apply changes.", vim.log.levels.INFO)
	else
		vim.notify("Could not write local config: " .. path, vim.log.levels.ERROR)
	end
end

--- Returns the layer index corresponding to a buffer line number.
--- The first layer starts at line 6 (1-indexed), matching the header lines.
--- @param line_nr number 1-indexed line number in the buffer
--- @param header_count number Number of header lines before the layer list
--- @return number|nil Layer index (1-indexed) or nil if not on a layer line
local function line_to_layer_index(line_nr, header_count)
	local idx = line_nr - header_count
	if idx >= 1 then
		return idx
	end
	return nil
end

--- Displays a dialog for selecting the local configuration to use.
--- @param settings LYRD.shared.setup.Settings The current configuration settings.
function UI.show(settings)
	-- Filter out unskippable layers and collect display names
	local layers = {}
	local names = {}
	for _, layer_module in ipairs(settings.layers) do
		local ok, layer = pcall(require, layer_module)
		if not ok or type(layer) ~= "table" or not layer.unskippable then
			table.insert(layers, layer_module)
			if ok and type(layer) == "table" and layer.name then
				names[layer_module] = layer.name
			end
		end
	end
	local skipped = {}
	for _, layer in ipairs(settings.skip_layers or {}) do
		skipped[layer] = true
	end

	local header_count = 5 -- lines before the layer list starts

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].readonly = false
	vim.api.nvim_buf_set_name(buf, "lyrd://local-config")
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].filetype = "lyrd-local-config"

	-- Render initial content
	local function refresh()
		local lines = render_lines(layers, skipped, names)
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
	end
	refresh()

	-- Calculate window size
	local width = math.floor(vim.o.columns * 0.50)
	local height = header_count + #layers + 1
	local max_height = vim.o.lines - 6
	if height > max_height then
		height = max_height
	end
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Open floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " LYRD Config ",
		title_pos = "center",
	})
	vim.wo[win].cursorline = true
	vim.wo[win].wrap = false

	-- Place cursor on first layer line
	vim.api.nvim_win_set_cursor(win, { header_count + 1, 0 })

	-- Close helper
	local function close_win()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	-- Toggle the layer under cursor
	local function toggle_current()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local idx = line_to_layer_index(cursor[1], header_count)
		if idx and idx >= 1 and idx <= #layers then
			local layer = layers[idx]
			skipped[layer] = not skipped[layer] or nil
			refresh()
			-- Move cursor down if not at the last layer
			if cursor[1] < header_count + #layers then
				vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, 0 })
			end
		end
	end

	-- Save action
	local function save()
		local skip_list = {}
		for _, layer in ipairs(layers) do
			if skipped[layer] then
				table.insert(skip_list, layer)
			end
		end
		save_local_config(skip_list)
		settings.skip_layers = skip_list
		close_win()
	end

	-- Intercept :w to save settings
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			save()
		end,
	})

	-- Key mappings
	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", toggle_current, opts)
	vim.keymap.set("n", "<Space>", toggle_current, opts)
	vim.keymap.set("n", "s", save, opts)
	vim.keymap.set("n", "S", save, opts)
	vim.keymap.set("n", "q", close_win, opts)
	vim.keymap.set("n", "<Esc>", close_win, opts)
end

return UI
