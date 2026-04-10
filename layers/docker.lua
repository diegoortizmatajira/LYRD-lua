local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")
local ts = require("LYRD.layers.treesitter")
local icons = require("LYRD.layers.icons")
require("LYRD.shared.utils.signs")
local utils = require("LYRD.shared.utils")

local declarative_layer = require("LYRD.shared.declarative_layer")

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
  ) 
)]],
	docker_compose_service_sign = SignItem:new("DockerComposeService", icons.cloud.service, "Type"),
	docker_compose_filetype = "yaml.docker-compose",

	docker_service_commands = {
		"build",
		"create",
		"down",
		"pull",
		"restart",
		"start",
		"stop",
		"up",
		"logs",
	},
	docker_compose_commands = {
		"down",
		"pull",
		"restart",
		"up",
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

--- Runs a Docker Compose task with the specified command and optional service.
---
--- This function constructs and executes a Docker Compose task based on the
--- provided command and service. It supports additional arguments for certain
--- commands like "up" and "run". The task is run in the current working
--- directory and opens in a split terminal.
---
--- @param command? string: The Docker Compose command to execute (e.g., "up", "down"). Defaults to "up".
--- @param service? string: The name of the service to target with the command. Optional.
--- @usage
--- -- Run all services with `docker-compose up -d`:
--- docker_compose_task("up")
---
--- -- Stop a specific service with `docker-compose stop web`:
--- docker_compose_task("stop", "web")
local function docker_compose_task(command, service)
	command = command or "up"
	local additional_args = {
		up = { "-d" },
		run = { "-d" },
	}
	local args = { command }
	if additional_args[command] then
		vim.list_extend(args, additional_args[command])
	end
	if service then
		table.insert(args, service)
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
		generator = function(_, service)
			local result = {}
			-- If a service name is found at the cursor, generate commands specific to that service
			if service and service ~= "" then
				local service_result = vim.tbl_map(function(command)
					return {
						name = string.format("%s service: compose %s", service, string.upper(command)),
						preview = "docker-compose " .. command .. " " .. service,
						runner = function()
							docker_compose_task(command, service)
						end,
					}
				end, L.docker_service_commands)
				vim.list_extend(result, service_result)
			end
			-- Generate general Docker Compose commands that are not specific to any service
			local compose_file_result = vim.tbl_map(function(command)
				return {
					name = string.format("Docker compose file: compose %s", string.upper(command)),
					preview = "docker-compose " .. command,
					runner = function()
						docker_compose_task(command)
					end,
				}
			end, L.docker_compose_commands)
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
end

return declarative_layer.apply(L)
