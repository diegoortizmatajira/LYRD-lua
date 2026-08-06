local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")
local lsp = require("LYRD.layers.lsp")
local ts = require("LYRD.layers.treesitter")
require("LYRD.shared.utils.signs")
local utils = require("LYRD.shared.utils")

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @class LYRD.DockerComposeCommandSpec
--- @field pre_service_args? string[]
--- @field post_service_args? string[]
--- @field command? string

--- @class LYRD.DockerCommandSpecList
--- @field [number] string
--- @field [string] LYRD.DockerComposeCommandSpec

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Docker Containers and Compose",
	required_mason_packages = {
		"dockerfile-language-server",
		"docker-language-server",
		"docker-compose-language-service",
	},
	required_treesitter_parsers = {
		"dockerfile",
	},
	required_enabled_lsp_servers = {
		"dockerls",
		"docker_language_server",
		{
			"docker_compose_language_service",
			config = {
				filetypes = { "yaml.docker-compose", "docker-compose" },
			},
		},
	},
	required_executables = {
		"docker",
		"docker-compose",
		"lazydocker",
	},
	required_filetype_definitions = {
		pattern = {
			[".*/docker%-compose.*%.yaml"] = "yaml.docker-compose",
			[".*/docker%-compose.*%.yml"] = "yaml.docker-compose",
			[".*/compose.*%.yaml"] = "yaml.docker-compose",
			[".*/compose.*%.yml"] = "yaml.docker-compose",
		},
	},
	focus_terminal_on_run = true,
	ts_compose_services_query = [[
(block_mapping_pair
	key: ((flow_node) @services-key (#eq? @services-key "services"))
	value: (block_node
		(block_mapping (block_mapping_pair
		key: (flow_node) @service-name
		) @service-node)
))]],
	docker_compose_service_sign = SignItem:new("DockerComposeService", icons.cloud.service, "Type"),
	docker_compose_filetype = "yaml.docker-compose",
	ts_compose_image_query = [[
(block_mapping_pair
	key: ((flow_node) @image-key (#eq? @image-key "image"))
	value: (flow_node) @image-value)
]],

	---@type LYRD.DockerCommandSpecList
	docker_service_commands = {
		"build",
		"create",
		"down",
		"pull",
		"restart",
		"start",
		"stop",
		["up"] = {
			pre_service_args = { "-d" },
		},
		["up (force recreate)"] = {
			pre_service_args = { "-d" },
			post_service_args = { "--force-recreate" },
			command = "up",
		},
		"logs",
		["logs (follow)"] = {
			pre_service_args = { "-f" },
			command = "logs",
		},
		["exec"] = {
			pre_service_args = { "-it" },
			post_service_args = { "sh" },
		},
	},
	---@type LYRD.DockerCommandSpecList
	docker_compose_commands = {
		"down",
		"pull",
		"restart",
		["up"] = {
			pre_service_args = { "-d" },
		},
		["up (force recreate)"] = {
			pre_service_args = { "-d" },
			post_service_args = { "--force-recreate" },
			command = "up",
		},
	},
}

local function docker_compose_refresh_service_signs()
	-- Gets all the line numbers where services are defined in the docker-compose file
	local service_rows = ts.get_matches(L.ts_compose_services_query, "yaml", nil, function(match, captures)
		local index = utils.index_of(captures, "service-name")
		if index then
			local row, _, _, _ = vim.treesitter.get_node_range(match[index][1])
			return row + 1
		end
	end)
	local bufnr = vim.api.nvim_get_current_buf()
	L.docker_compose_service_sign:clear(bufnr)
	for _, row in ipairs(service_rows) do
		L.docker_compose_service_sign:place(bufnr, row)
	end
end

function L.toggle_lazydocker()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("lazydocker")
end

--- Finds the "image:" value node at the given row in a docker-compose file.
--- @param row number 0-indexed row to search for the image value
--- @return {text: string, start_row: number, start_col: number, end_row: number, end_col: number}|nil
local function docker_compose_image_at_row(row)
	local matches = ts.get_matches(L.ts_compose_image_query, "yaml", function(match, captures)
		local key_index = utils.index_of(captures, "image-key")
		if not key_index then
			return false
		end
		local key_row = vim.treesitter.get_node_range(match[key_index][1])
		return key_row == row
	end, function(match, captures)
		local value_index = utils.index_of(captures, "image-value")
		if not value_index then
			return nil
		end
		local value_node = match[value_index][1]
		local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(value_node)
		return {
			text = vim.treesitter.get_node_text(value_node, vim.api.nvim_get_current_buf()),
			start_row = start_row,
			start_col = start_col,
			end_row = end_row,
			end_col = end_col,
		}
	end, 1)
	return matches[1]
end

--- Strips a single pair of surrounding quotes (single or double) from a string.
--- @param text string
--- @return string
local function strip_quotes(text)
	return (text:gsub("^[\"']", ""):gsub("[\"']$", ""))
end

--- Opens a Telescope picker listing local Docker images, prefiltered with
--- the current image value, and invokes `on_select` with the chosen image.
--- @param current_value string initial filter text
--- @param on_select fun(image: string)
local function docker_compose_pick_image(current_value, on_select)
	local ok_telescope = pcall(require, "telescope")
	if not ok_telescope then
		vim.notify("Docker: telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	local images = require("LYRD.shared.docker.images").list()
	if #images == 0 then
		vim.notify("Docker: no local images found", vim.log.levels.WARN)
		return
	end
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	pickers
		.new({}, {
			prompt_title = "Select Docker Image",
			default_text = strip_quotes(current_value),
			finder = finders.new_table({ results = images }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value then
						on_select(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

--- Null-ls CODE_ACTION generator that offers to pick a local Docker image
--- for the "image:" property under the cursor in a docker-compose file.
local function docker_compose_image_code_action(params)
	local image = docker_compose_image_at_row(params.range.row - 1)
	if not image then
		return {}
	end
	return {
		{
			title = "Select local Docker image...",
			action = function()
				docker_compose_pick_image(image.text, function(selected)
					vim.api.nvim_buf_set_text(
						params.bufnr,
						image.start_row,
						image.start_col,
						image.end_row,
						image.end_col,
						{ selected }
					)
				end)
			end,
		},
	}
end

local function docker_compose_command_preview(command, service, pre_service_args, post_service_args)
	local args = {}
	if pre_service_args and #pre_service_args > 0 then
		vim.list_extend(args, pre_service_args)
	end
	if service and service ~= "" then
		table.insert(args, service)
	end
	if post_service_args and #post_service_args > 0 then
		vim.list_extend(args, post_service_args)
	end
	local extra = #args > 0 and (" " .. table.concat(args, " ")) or ""
	return "docker compose " .. command .. extra
end

--- Normalizes a `LYRD.DockerCommandSpecList` (a mix of plain command-name
--- strings and `[name] = LYRD.DockerComposeCommandSpec` entries) into a flat
--- list of definitions. The map key (or the string itself) is always used
--- as the display name; the actual command run is the entry's `command`
--- field when present, falling back to that same key/string otherwise.
--- @param command_definitions LYRD.DockerCommandSpecList
--- @return {display: string, command: string, pre_service_args: string[]?, post_service_args: string[]?}[]
local function normalize_command_definitions(command_definitions)
	--- @type {display: string, command: string, pre_service_args: string[]?, post_service_args: string[]?}[]
	local definitions = {}
	for _, command in ipairs(command_definitions) do
		if type(command) == "string" then
			table.insert(definitions, { display = command, command = command })
		elseif type(command) == "table" then
			local command_name = command.command or command.name
			if command_name then
				table.insert(definitions, {
					display = command_name,
					command = command_name,
					pre_service_args = command.pre_service_args,
					post_service_args = command.post_service_args,
				})
			end
		end
	end
	local map_keys = {}
	for key, _ in pairs(command_definitions) do
		if type(key) ~= "number" then
			table.insert(map_keys, key)
		end
	end
	table.sort(map_keys)
	for _, key in ipairs(map_keys) do
		local value = command_definitions[key]
		if type(value) == "table" then
			table.insert(definitions, {
				display = key,
				command = value.command or key,
				pre_service_args = value.pre_service_args,
				post_service_args = value.post_service_args,
			})
		else
			table.insert(definitions, { display = key, command = key })
		end
	end
	return definitions
end

--- Runs a Docker Compose task with the specified command and optional service.
---
--- This function constructs and executes a Docker Compose task based on the
--- provided command and service. The task is run in the current working
--- directory and opens in a split terminal.
---
--- @param command? string: The Docker Compose command to execute (e.g., "up", "down"). Defaults to "up".
--- @param service? string: The name of the service to target with the command. Optional.
--- @param pre_service_args? string[]: Args placed before the service name (e.g., "-it" for exec).
--- @param post_service_args? string[]: Args placed after the service name (e.g., "sh").
--- @usage
--- -- Run all services with `docker-compose up -d`:
--- docker_compose_task("up")
---
--- -- Stop a specific service with `docker-compose stop web`:
--- docker_compose_task("stop", "web")
local function docker_compose_task(command, service, pre_service_args, post_service_args)
	command = command or "up"
	local args = { command }
	if pre_service_args and #pre_service_args > 0 then
		vim.list_extend(args, pre_service_args)
	end
	if service then
		table.insert(args, service)
	end
	if post_service_args and #post_service_args > 0 then
		vim.list_extend(args, post_service_args)
	end
	local tasks = require("LYRD.layers.tasks")
	--- get the current working directory as the folder where the current file is located
	local cwd = vim.fn.expand("%:p:h")

	tasks.run_task({
		name = "Docker Compose",
		cmd = "docker",
		args = vim.list_extend({ "compose" }, args),
		cwd = cwd,
		open_in_split = true,
		focus = L.focus_terminal_on_run,
	})
end

--- Runs a Docker Compose service based on the cursor's position.
---
--- This function identifies the service name currently under the cursor
--- in a Docker Compose YAML file and executes the corresponding service.
--- If no service name is found at the cursor, a warning is displayed.
---
--- @usage
--- -- Place the cursor over a service name in a Docker Compose YAML file
--- -- and call this function to run the service:
--- L.docker_compose_run_service_at_cursor()
---
function L.docker_compose_run_at_cursor()
	require("LYRD.shared.run_code").run_selection({
		title = "Run Docker Compose Service",
		treesitter_selector = {
			query_string = L.ts_compose_services_query,
			lang = "yaml",
			node_capture_name = "service-node",
			text_capture_name = "service-name",
		},
		skip_visual_selection = true,
		generator = function(_, service)
			local result = {}
			-- If a service name is found at the cursor, generate commands specific to that service
			if service and service ~= "" then
				local command_definitions = normalize_command_definitions(L.docker_service_commands)
				local service_result = vim.tbl_map(function(definition)
					local command = definition.command
					return {
						name = string.format("%s service: compose %s", service, string.upper(definition.display)),
						preview = docker_compose_command_preview(
							command,
							service,
							definition.pre_service_args,
							definition.post_service_args
						),
						runner = function()
							docker_compose_task(
								command,
								service,
								definition.pre_service_args,
								definition.post_service_args
							)
						end,
					}
				end, command_definitions)
				vim.list_extend(result, service_result)
			end
			-- Generate general Docker Compose commands that are not specific to any service
			local compose_command_definitions = normalize_command_definitions(L.docker_compose_commands)
			local compose_file_result = vim.tbl_map(function(definition)
				local command = definition.command
				return {
					name = string.format("Docker compose file: compose %s", string.upper(definition.display)),
					preview = docker_compose_command_preview(
						command,
						nil,
						definition.pre_service_args,
						definition.post_service_args
					),
					runner = function()
						docker_compose_task(command, nil, definition.pre_service_args, definition.post_service_args)
					end,
				}
			end, compose_command_definitions)
			vim.list_extend(result, compose_file_result)
			return result
		end,
	})
end

function L.preparation()
	-- Configure hadolint only if platform is Linux
	if vim.fn.has("linux") == 1 then
		lsp.mason_ensure({
			"hadolint",
		})
		lsp.null_ls_register_sources({
			require("null-ls.builtins.diagnostics.hadolint"),
		})
	end
	lsp.register_code_actions({ L.docker_compose_filetype }, docker_compose_image_code_action)
end

function L.settings()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers(L.docker_compose_filetype, { docker_compose_refresh_service_signs })

	-- Command implementations
	commands.implement(L.docker_compose_filetype, {
		{ cmd.LYRDCodeRunSelection, L.docker_compose_run_at_cursor },
		{ cmd.LYRDCodeRun, L.docker_compose_run_at_cursor },
	})
	commands.implement("*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})

	-- Registers the local Docker image completion source, scoped to
	-- docker-compose files, alongside the existing YAML LSP completions.
	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		pcall(
			cmp.register_source,
			"docker_images",
			require("LYRD.shared.docker.cmp_source").new(L.docker_compose_filetype)
		)
		cmp.setup.filetype(L.docker_compose_filetype, {
			sources = cmp.config.sources({
				{ name = "docker_images" },
				{ name = "nvim_lsp" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
	end
end

return declarative_layer.apply(L)
