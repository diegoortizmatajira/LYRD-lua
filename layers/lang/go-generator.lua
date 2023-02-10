local L = { name = "Generator" }

local function get_root(bufnr)
	local parser = vim.treesitter.get_parser(bufnr, "go", {})
	local tree = parser:parse()[1]
	return tree:root()
end

local function get_structs_in_file_query()
	return vim.treesitter.parse_query(
		"go",
		[[
(type_spec .
    name: (type_identifier) @struct_name
    type: (struct_type)
)
        ]]
	)
end

local function get_fields_in_structure_query(structure_name)
	return vim.treesitter.parse_query(
		"go",
		string.format(
			[[
(type_spec .
    (type_identifier) @struct_name
    (#eq? @struct_name "%s")
    (struct_type
        (field_declaration_list
            (field_declaration
                name: (field_identifier) @field_name
                type: (_) @type_identifier
            )
        )
    )
)
        ]],
			structure_name
		)
	)
end

local function select_structure(bufnr, callback)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "go" then
		vim.notify("Can only be used in Golang")
		return
	end
	local structures = get_structs_in_file_query()
	local root = get_root(bufnr)
	local struct_names = {}
	for _, captures, _ in structures:iter_matches(root, bufnr) do
		local struct_name = vim.treesitter.query.get_node_text(captures[1], bufnr)
		table.insert(struct_names, struct_name)
	end

	if #struct_names == 1 then
		callback(struct_names[1])
		return
	end

	vim.ui.select(struct_names, { prompt = "Select a struct" }, callback)
end

local function process_fields_from_struct(bufnr, structure_name, string_generator)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "go" then
		vim.notify("Can only be used in Golang")
		return
	end
	local fields = get_fields_in_structure_query(structure_name)
	local root = get_root(bufnr)
	local new_lines = { "" }
	for _, captures, _ in fields:iter_matches(root, bufnr) do
		local struct_name = vim.treesitter.query.get_node_text(captures[1], bufnr)
		local field_name = vim.treesitter.query.get_node_text(captures[2], bufnr)
		local field_type = vim.treesitter.query.get_node_text(captures[3], bufnr)
		local text = string_generator(struct_name, field_name, field_type)
		table.insert(new_lines, text)
	end
	table.insert(new_lines, "")
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, new_lines)
end

function L.generate_getters(bufnr)
	select_structure(bufnr, function(structure_name)
		vim.notify(string.format("You have selected %s", structure_name))
		if not structure_name then
			return
		end
		local template = function(struct_name, field_name, field_type)
			local receiver = string.lower(string.sub(struct_name, 1, 1))
			local getter_name = (field_name:gsub("^%l", string.upper))
			return string.format(
				[[func (%s %s) %s() %s { return %s.%s}]],
				receiver,
				struct_name,
				getter_name,
				field_type,
				receiver,
				field_name
			)
		end
		process_fields_from_struct(bufnr, structure_name, template)
	end)
end

function L.generate_setters(bufnr)
	select_structure(bufnr, function(structure_name)
		if not structure_name then
			return
		end
		local template = function(struct_name, field_name, field_type)
			local receiver = string.lower(string.sub(struct_name, 1, 1))
			local property_name = (field_name:gsub("^%l", string.upper))
			return string.format(
				[[func (%s %s) Set%s(value %s) { %s.%s = value }]],
				receiver,
				struct_name,
				property_name,
				field_type,
				receiver,
				field_name
			)
		end
		process_fields_from_struct(bufnr, structure_name, template)
	end)
end

function L.generate_mapping(bufnr)
	select_structure(bufnr, function(structure_name)
		if not structure_name then
			return
		end

		vim.ui.input("Name for the target prefix (or empty if not required): ", function(target_prefix)
			if not target_prefix then
				return
			end
			if target_prefix ~= "" then
				target_prefix = target_prefix .. "."
			end
			vim.ui.input("Name for the source prefix (or empty if not required): ", function(source_prefix)
				if not source_prefix then
					return
				end
				if source_prefix ~= "" then
					source_prefix = source_prefix .. "."
				end
				vim.ui.input("Operator sign: ", function(operator)
					local template = function(_, field_name, _)
						return string.format(
							[[%s%s %s %s%s]],
							target_prefix,
							field_name,
							operator,
							source_prefix,
							field_name
						)
					end
					process_fields_from_struct(bufnr, structure_name, template)
				end)
			end)
		end)
	end)
end
return L
