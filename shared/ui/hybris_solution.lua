-- Checkbox UI for selecting which Hybris extensions and independent jars get
-- loaded into JDTLS. Mirrors shared/ui/local_config.lua's floating-window
-- pattern, but the content mixes non-toggleable section headers with
-- toggleable rows, so it tracks an explicit line_map instead of a fixed
-- header-count offset.

local icons = require("LYRD.layers.icons")

local UI = {}

---@param ext table
---@return string
local function ext_label(ext)
	return string.format("%d jars, %d src", #ext.lib_jars + #ext.bin_jars + #ext.classpath_jars, #ext.source_paths)
end

-- Strips the hybris_home prefix (and any leading slash) from an absolute
-- path so extension/jar rows show a short, project-relative path instead of
-- the full filesystem path.
---@param hybris_home string?
---@param path string
---@return string
local function relative_path(hybris_home, path)
	if hybris_home and path:sub(1, #hybris_home) == hybris_home then
		return (path:sub(#hybris_home + 1):gsub("^/", ""))
	end
	return path
end

---@param extensions table<string, table>
---@param ext_type string
---@return table[]
local function extensions_of_type(extensions, ext_type)
	local list = {}
	for _, ext in pairs(extensions) do
		if ext.type == ext_type then
			table.insert(list, ext)
		end
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

---@param list table[]
---@return table<string, table[]>, string[]
local function group_by(list)
	local groups = {}
	local order = {}
	for _, ext in ipairs(list) do
		local key = ext.group or ""
		if not groups[key] then
			groups[key] = {}
			table.insert(order, key)
		end
		table.insert(groups[key], ext)
	end
	table.sort(order)
	return groups, order
end

-- Appends a rendered line and its line_map entry in lockstep. line_map is
-- indexed directly by the line's position (not via table.insert, since
-- table.insert(t, nil) is a no-op that would desync line_map from lines the
-- moment a header/blank row -- whose entry is nil -- is pushed).
---@param lines string[]
---@param line_map table[]
---@param text string
---@param entry table?
local function push(lines, line_map, text, entry)
	table.insert(lines, text)
	line_map[#lines] = entry
end

---@param lines string[]
---@param line_map table[]
---@param title string
---@param list table[]
---@param hybris_home string?
local function append_extension_section(lines, line_map, title, list, hybris_home)
	if #list == 0 then
		return
	end
	push(lines, line_map, "", nil)
	push(lines, line_map, title, nil)
	for _, ext in ipairs(list) do
		local marker = ext.enabled and icons.ui.checkbox_checked or icons.ui.checkbox_unchecked
		push(
			lines,
			line_map,
			string.format("  %s %s (%s)  (%s)", marker, ext.name, relative_path(hybris_home, ext.path), ext_label(ext)),
			{ kind = "extension", key = ext.name }
		)
	end
end

---@param lines string[]
---@param line_map table[]
---@param title string
---@param list table[]
---@param hybris_home string?
local function append_grouped_extension_section(lines, line_map, title, list, hybris_home)
	if #list == 0 then
		return
	end
	push(lines, line_map, "", nil)
	push(lines, line_map, title, nil)
	local groups, order = group_by(list)
	for _, group_key in ipairs(order) do
		if group_key ~= "" then
			push(lines, line_map, "  " .. group_key .. ":", nil)
		end
		for _, ext in ipairs(groups[group_key]) do
			local marker = ext.enabled and icons.ui.checkbox_checked or icons.ui.checkbox_unchecked
			push(
				lines,
				line_map,
				string.format(
					"    %s %s (%s)  (%s)",
					marker,
					ext.name,
					relative_path(hybris_home, ext.path),
					ext_label(ext)
				),
				{ kind = "extension", key = ext.name }
			)
		end
	end
end

---@param lines string[]
---@param line_map table[]
---@param title string
---@param jars table[]
---@param hybris_home string?
local function append_jar_section(lines, line_map, title, jars, hybris_home)
	if #jars == 0 then
		return
	end
	push(lines, line_map, "", nil)
	push(lines, line_map, title, nil)
	for idx, jar in ipairs(jars) do
		local marker = jar.enabled and icons.ui.checkbox_checked or icons.ui.checkbox_unchecked
		push(
			lines,
			line_map,
			string.format("  %s %s", marker, relative_path(hybris_home, jar.path)),
			{ kind = "jar", key = idx }
		)
	end
end

---@param config table
---@return string[] lines
---@return table[] line_map
local function render(config)
	local lines = {}
	local line_map = {}
	push(lines, line_map, "Hybris Solution Configuration", nil)
	push(lines, line_map, string.rep("─", 50), nil)
	push(lines, line_map, "HYBRIS_HOME: " .. (config.hybris_home or "(unknown)"), nil)
	push(lines, line_map, "", nil)
	push(lines, line_map, " <Space>/<Enter> toggle  |  <C-s>/:w save  |  <q>/Esc cancel", nil)

	local extensions = config.extensions or {}
	local hybris_home = config.hybris_home
	append_extension_section(
		lines,
		line_map,
		"Platform Extensions",
		extensions_of_type(extensions, "platform"),
		hybris_home
	)
	append_extension_section(
		lines,
		line_map,
		"Custom Extensions",
		extensions_of_type(extensions, "custom"),
		hybris_home
	)
	append_grouped_extension_section(
		lines,
		line_map,
		"Module Extensions",
		extensions_of_type(extensions, "module"),
		hybris_home
	)
	append_grouped_extension_section(
		lines,
		line_map,
		"Extra-Pattern Extensions",
		extensions_of_type(extensions, "extra-pattern"),
		hybris_home
	)
	append_jar_section(lines, line_map, "Independent JARs", config.independent_jars or {}, hybris_home)

	return lines, line_map
end

-- Shows the checkbox UI for a scanned/persisted solution config. Never
-- mutates `config` directly -- toggles apply to a deep copy, and only
-- `opts.on_save` (if provided) receives the updated config, on save.
---@param config table
---@param opts { on_save: fun(updated_config: table) }?
function UI.show(config, opts)
	opts = opts or {}
	local working = vim.deepcopy(config)
	-- line_map holds nil holes for header/blank rows, so its length is NOT read
	-- via `#line_map` (undefined for tables with holes) -- line_count tracks the
	-- real row total from `lines` (a proper, hole-free sequence) instead.
	local line_map = {}
	local line_count = 0

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].readonly = false
	vim.api.nvim_buf_set_name(buf, "lyrd://hybris-solution")
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].filetype = "lyrd-hybris-solution"

	local function refresh()
		local lines, map = render(working)
		line_map = map
		line_count = #lines
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
	end
	refresh()

	local width = math.floor(vim.o.columns * 0.7)
	local max_height = vim.o.lines - 6
	local height = math.min(line_count, max_height)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " Hybris Solution ",
		title_pos = "center",
	})
	vim.wo[win].cursorline = true
	vim.wo[win].wrap = false

	local function close_win()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function toggle_current()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local entry = line_map[cursor[1]]
		if not entry then
			return
		end
		if entry.kind == "extension" then
			local ext = working.extensions[entry.key]
			ext.enabled = not ext.enabled
		elseif entry.kind == "jar" then
			local jar = working.independent_jars[entry.key]
			jar.enabled = not jar.enabled
		end
		refresh()
		if cursor[1] < line_count then
			pcall(vim.api.nvim_win_set_cursor, win, { cursor[1] + 1, 0 })
		end
	end

	local function save()
		if opts.on_save then
			opts.on_save(working)
		end
		close_win()
	end

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			save()
		end,
	})

	local map_opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", toggle_current, map_opts)
	vim.keymap.set("n", "<Space>", toggle_current, map_opts)
	vim.keymap.set("n", "<C-s>", save, map_opts)
	vim.keymap.set("n", "q", close_win, map_opts)
	vim.keymap.set("n", "<Esc>", close_win, map_opts)
end

return UI
