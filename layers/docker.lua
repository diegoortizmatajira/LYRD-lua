local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")
local ts = require("LYRD.layers.treesitter")
local icons = require("LYRD.layers.icons")
require("LYRD.utils.signs")
local utils = require("LYRD.utils")

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Docker",
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
		"docker_compose_language_service",
	},
	required_executables = {
		"docker",
		"docker-compose",
		"lazydocker",
	},
	docker_compose_filetype = "yaml.docker-compose",
	docker_compose_file_patterns = {
		"docker%-compose*%.yaml",
		"docker%-compose*%.yml",
		"compose*%.yaml",
		"compose*%.yml",
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
}

local function docker_compose_refesh_service_signs()
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

--- Executes a Docker Compose command.
--- @param command? string: The Docker Compose command to execute (e.g., "up", "down"). Defaults to "up".
--- @usage L.docker_compose_execute("up") -- Runs `docker-compose up`.
function L.docker_compose_execute(command)
	docker_compose_task(command)
end

--- Runs a specific Docker Compose service.
--- @param service string: The name of the service to run. If not provided, a warning is displayed.
--- @param command? string: The command to execute with the service (e.g., "up", "down"). Defaults to "up".
--- @usage L.run_docker_compose_service("web") -- Starts the "web" service using Docker Compose.
function L.docker_compose_execute_service(service, command)
	if service == "" then
		vim.notify("No service provided", vim.log.levels.WARN)
		return
	end
	docker_compose_task(command, service)
end

--- Retrieves a list of services defined in a Docker Compose YAML file.
---
--- This function uses Tree-sitter to parse the YAML structure and extract
--- the names of all the services defined under the "services" key in a
--- Docker Compose file. It returns a table containing the service names.
---
--- @return table: A table of strings, where each string represents a service name.
--- @usage
--- local services = L.docker_compose_get_services()
--- for _, service in ipairs(services) do
---     print(service)
--- end
function L.docker_compose_get_services()
	local services = ts.get_match_texts(L.ts_compose_services_query, "yaml", "service-node", "service-name")
	return services
end

--- Retrieves the Docker Compose service name at the current cursor position.
---
--- This function uses Tree-sitter to identify and extract the service name
--- under the cursor within a Docker Compose YAML file. If no service name
--- is found at the cursor, an empty string is returned.
---
--- @return string: The name of the service at the cursor, or an empty string if no service is found.
--- @usage
--- local service = L.docker_compose_get_service_at_cursor()
--- if service ~= "" then
---     print("Service at cursor: " .. service)
--- else
---     print("No service found at cursor.")
--- end
function L.docker_compose_get_service_at_cursor()
	local service = ts.get_match_text_at_cursor(L.ts_compose_services_query, "yaml", "service-node", "service-name")
	return service
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
function L.docker_compose_run_service_at_cursor()
	local service = L.docker_compose_get_service_at_cursor()
	if service == "" then
		vim.notify("No service found at cursor", vim.log.levels.WARN)
		return
	end
	L.docker_compose_execute_service(service)
end

local function docker_compose_generate_actions()
	local prefix = "Docker Compose: "
	local docker_file_commands = {
		"down",
		"pull",
		"restart",
		"up",
	}
	local docker_service_commands = {
		"build",
		"create",
		"down",
		"pull",
		"restart",
		"start",
		"stop",
		"up",
	}
	--- Accumulate all actions
	local result = {
		{ title = "Refresh service status", action = docker_compose_refesh_service_signs },
	}
	--- Generate actions for all services
	result = vim.list_extend(
		result,
		vim.tbl_map(function(c)
			return {
				title = prefix .. string.format("%s all services", c),
				action = function()
					L.docker_compose_execute(c)
				end,
			}
		end, docker_file_commands)
	)
	--- Add current service actions if any
	local service_at_cursor = L.docker_compose_get_service_at_cursor()
	if service_at_cursor ~= "" then
		result = vim.list_extend(
			result,
			vim.tbl_map(function(c)
				return {
					title = prefix .. string.format("[%s] %s service", service_at_cursor, c),
					action = function()
						L.docker_compose_execute_service(service_at_cursor, c)
					end,
				}
			end, docker_service_commands)
		)
	end
	return result
end

function L.preparation()
	--
	lsp.register_code_actions({ L.docker_compose_filetype }, docker_compose_generate_actions)
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
	-- Filetype detection for docker-compose files
	local patterns = {}
	vim.tbl_map(function(p)
		patterns[p] = L.docker_compose_filetype
	end, L.docker_compose_file_patterns)
	vim.filetype.add({
		pattern = patterns,
	})

	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers(L.docker_compose_filetype, { docker_compose_refesh_service_signs })

	-- Command implementations
	commands.implement(L.docker_compose_filetype, {
		{ cmd.LYRDCodeRunSelection, L.docker_compose_run_service_at_cursor },
		{ cmd.LYRDCodeRun, L.docker_compose_execute },
	})
	commands.implement("*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})
end

return declarative_layer.apply(L)
