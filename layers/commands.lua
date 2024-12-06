local L = { name = "Commands" }

---@class LYRD.command
---@field name? string|nil
---@field desc string
---@field default? string|function|nil
---@field icon string|nil

---@class LYRD.command_settings
---@field commands table<string, table<string, string|function>>

---Registers a command implementation for an specific filetype
---@param s LYRD.command_settings
---@param filetype string
---@param commandName string
---@param implementation string|function
local function register_implementation(s, filetype, commandName, implementation)
	if s.commands[commandName] == nil then
		s.commands[commandName] = {}
	end
	LYRD_setup.commands[commandName][filetype] = implementation
end

---Executes a command depending on the type
---@param s LYRD.command_settings
---@param commandName string
local function execute_command(s, commandName)
	local function safe_cmd(command)
		return vim.cmd(command)
	end
	local execute_and_confirm = function(command_instance)
		if type(command_instance) == "string" then
			if command_instance ~= nil and command_instance ~= "" then
				local ok, res = pcall(safe_cmd, command_instance)
				if not ok then
					vim.notify("Command execution failed: " .. command_instance, vim.log.levels.ERROR)
				end
				return true
			end
		elseif type(command_instance) == "function" then
			command_instance()
			return true
		end
		return false
	end
	-- Looks for the current file type command implementation
	local cmd = s.commands[commandName][vim.bo.filetype]
	if execute_and_confirm(cmd) then
		return
	end
	-- Looks for the generic command implementation
	cmd = s.commands[commandName]["*"]
	if execute_and_confirm(cmd) then
		return
	end
	print(string.format([[Command '%s' has not been implemented for the filetype '%s']], commandName, vim.bo.filetype))
end

local function show_unimplemented_commands(s)
	print("The next commands are not implemented for any type of file")
	for command, implementation in pairs(s.commands) do
		if implementation["*"] == "" and #implementation == 1 then
			print("-", command)
		end
	end
	print("End of the list")
end

local function show_implemented_commands(s)
	print("The next commands are implemented by default")
	for command, implementation in pairs(s.commands) do
		if implementation["*"] ~= "" then
			print("-", command, "=>", implementation["*"])
		end
	end
	print("End of the list")
end

function L.settings(s)
	s.commands = {}

	L.list_unimplemented = function()
		show_unimplemented_commands(s)
	end
	L.list_implemented = function()
		show_implemented_commands(s)
	end
end

---Registers a set of commands for a specific filetype
---@param s LYRD.command_settings
---@param filetype string
---@param commands table<{[1]: LYRD.command, [2]:string|function}>
function L.implement(s, filetype, commands)
	for _, command_info in ipairs(commands) do
		local cmd, implementation = unpack(command_info)
		if cmd == nil then
			error("The command to be implemented does not exist. It's implementation would be: " .. implementation)
		end
		register_implementation(s, filetype, cmd.name, implementation)
	end
end

---Registers a set of commands
---@param commands table<string, LYRD.command>
function L.register(s, commands)
	for command_name, definition in pairs(commands) do
		definition.name = command_name
		register_implementation(s, "*", command_name, definition.default)
		vim.api.nvim_create_user_command(command_name, function()
			execute_command(s, command_name)
		end, {})
	end
end

function L.command_shortcut(commandName)
	return "<cmd>" .. commandName .. "<CR>"
end

return L
