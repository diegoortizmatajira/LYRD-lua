local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")
local ts = require("LYRD.layers.treesitter")

---@class LYRD.layer.Docker: LYRD.setup.Module
local L = {
	name = "Docker",
	docker_compose_filetype = "yaml.docker-compose",
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
}

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
	tasks.run_task({
		name = "Docker Compose",
		cmd = "docker",
		args = vim.list_extend({ "compose" }, args),
		cwd = vim.fn.getcwd(),
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
	local services = ts.get_all_match_text(L.ts_compose_services_query, "yaml", "service-node", "service-name")
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
	local current_service_actions = {}
	local service_at_cursor = L.docker_compose_get_service_at_cursor()
	if service_at_cursor ~= "" then
		current_service_actions = vim.tbl_map(function(c)
			return {
				title = prefix .. string.format("[%s] %s service", service_at_cursor, c),
				action = function()
					L.docker_compose_execute_service(service_at_cursor, c)
				end,
			}
		end, docker_service_commands)
	end
	local result = vim.tbl_map(function(c)
		return {
			title = prefix .. string.format("%s all services", c),
			action = function()
				L.docker_compose_execute(c)
			end,
		}
	end, docker_file_commands)
	result = vim.list_extend(result, current_service_actions)
	return result
end

function L.preparation()
	--
	lsp.register_code_actions({ L.docker_compose_filetype }, docker_compose_generate_actions)
	lsp.mason_ensure({
		"dockerfile-language-server",
		"docker-compose-language-service",
	})
	-- Configure hadolint only if platform is Linux
	if vim.fn.has("linux") == 1 then
		lsp.mason_ensure({
			"hadolint",
		})
		lsp.null_ls_register_sources({
			require("null-ls.builtins.diagnostics.hadolint"),
		})
	end
	ts.ensureParser({
		"dockerfile",
	})
end

function L.settings()
	vim.filetype.add({
		pattern = {
			["docker%-compose*%.yaml"] = L.docker_compose_filetype,
			["docker%-compose*%.yml"] = L.docker_compose_filetype,
		},
	})
	commands.implement(L.docker_compose_filetype, {
		{ cmd.LYRDCodeRunSelection, L.docker_compose_run_service_at_cursor },
		{ cmd.LYRDCodeRun, L.docker_compose_execute },
	})
	commands.implement("*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})
end

function L.complete()
	vim.lsp.enable({
		"dockerls",
		"docker_compose_language_service",
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("lazydocker")
end

return L
