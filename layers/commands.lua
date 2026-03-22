local utils = require("LYRD.utils")

--- @class LYRD.layer.Commands: LYRD.setup.Module
local L = {
	name = "Commands",
	vscode_compatible = true,
	--- @type table<string, Command>
	commands = {},
}

function L.wrap(fn)
	return function()
		return fn()
	end
end

--- @class ShortCutOptions
--- @field range? boolean Indicates the shorcut uses current selection.
--- @field escape? boolean Indicates the shorcut includes <ESC> before running the command.

--- @alias CommandImplementation string|fun(opts?: table)

--- @class Command
--- @field name? string Name of the command.
--- @field desc string Command description.
--- @field default_implementation? CommandImplementation Default implementation.
--- @field icon string|nil Icon to show for the command.
--- @field range? boolean Indicates whether the command can be applied to a range of text.
--- @field leave_insert_mode? boolean|nil Indicates whether the command should leave insert mode.
--- @field implementations table<string, CommandImplementation> Implementations per filetype.
Command = {}

--- Constructor
--- @param desc string Command description.
--- @param default_implementation? CommandImplementation Default implementation.
--- @param icon? string Icon to show for the command.
--- @param range? boolean Indicates whether the command can be applied to a range of text.
--- @return Command
function Command:new(desc, default_implementation, icon, range, leave_insert_mode)
	local o = setmetatable({}, self)
	self.__index = self
	o.name = ""
	o.desc = desc
	o.default_implementation = default_implementation
	o.icon = icon
	o.range = range
	o.leave_insert_mode = leave_insert_mode
	o.implementations = {}
	return o
end

--- Implements the command for one or many file types.
--- @param filetype string A filetype.
--- @param implementation CommandImplementation An implementation of the command.
function Command:implement_for_filetype(filetype, implementation)
	if filetype == "*" then
		self.default_implementation = implementation
	else
		self.implementations[filetype] = implementation
	end
end

--- Implements the command for one or many file types.
--- @param target string|string[] One filetype or a list of filetypes.
--- @param implementation CommandImplementation An implementation of the command.
function Command:implement_for(target, implementation)
	if type(target) == "string" then
		self:implement_for_filetype(target, implementation)
	elseif type(target) == "table" then
		for _, f in pairs(target) do
			self:implement_for_filetype(f, implementation)
		end
	else
		error("Filetype must be a string or a list of strings")
	end
end

--- Executes the command implementation corresponding to the current file type or the default one if no specific implementation is available.
--- If no implementation is found, a warning is shown.
--- @param opts? table Options for the command execution.
function Command:execute(opts)
	-- Looks for the current file type command implementation
	local filetype = vim.bo.filetype
	if not filetype then
		vim.notify("Filetype is not set", vim.log.levels.ERROR)
		return
	end

	-- First, we try to find an implementation for the full filetype.
	local implementation = self.implementations[filetype]
	if implementation then
		-- If an implementation is found, we execute it and return.
		L.execute_implementation(implementation, opts)
		return
	end

	-- Some filetypes are compound, like "javascript.react". In those cases, we try to find an implementation for each part.
	-- If filetype contains a dot, we try to split it and find implementations for each part.
	if string.find(filetype, "%.") then
		local split_filetypes = vim.split(filetype, ".", { plain = true })
		for _, ft in ipairs(split_filetypes) do
			implementation = self.implementations[ft]
			if implementation then
				-- If an implementation is found for one of the parts, we execute it and return.
				L.execute_implementation(implementation, opts)
				return
			end
		end
	end

	-- If no implementation was found for full filetype or any filetype part, we try the default implementation.
	if self.default_implementation then
		L.execute_implementation(self.default_implementation, opts)
	else
		vim.notify(
			string.format([[Command '%s' has not been implemented for the filetype '%s']], self.name, filetype),
			vim.log.levels.WARN
		)
	end
end

--- Registers the command with the given name, and links the execute method to it.
--- @param command_name string Name for the command to be created
function Command:register_with_name(command_name)
	self.name = command_name
	L.commands[self.name] = self
	vim.api.nvim_create_user_command(command_name, function(opts)
		self:execute(opts)
	end, { desc = self.desc, range = self.range })
end

--- Returns the command with modifiers to be used with a text range in visual mode.
--- @param opts? ShortCutOptions
--- @return string
function Command:shortcut(opts)
	return L.command_shortcut(self.name, opts)
end

--- Returns the command as a string command to be run in vim
function Command:as_vim_command(mode)
	if self.range and utils.contains({ "v", "x" }, mode) then
		return self:shortcut({ range = true })
	elseif self.leave_insert_mode and mode == "i" then
		return self:shortcut({ escape = true })
	else
		return self:shortcut()
	end
end

--- Executes a command instance
--- @param implementation CommandImplementation|Command
--- @param opts? table Options for the command execution.
--- @return boolean
function L.execute_implementation(implementation, opts)
	if type(implementation) == "string" and implementation ~= "" then
		---Executes a command
		--- @param command string
		local ok, _ = pcall(function(command)
			return vim.cmd(command)
		end, implementation)
		if not ok then
			vim.notify("Command execution failed: " .. implementation, vim.log.levels.ERROR)
		end
		return true
	elseif type(implementation) == "function" then
		local ok, err = pcall(implementation, opts)
		if not ok then
			vim.notify("Command execution failed: " .. tostring(err), vim.log.levels.ERROR)
		end
		return true
	elseif type(implementation) == "table" and implementation.name then
		return L.execute_implementation(":" .. implementation.name, opts)
	end
	return false
end

--- @class LYRD.commands.settings
--- @field commands table<string, table<string, CommandImplementation>>

--- @class LYRD.commands.implementation
--- @field [1] Command
--- @field [2] CommandImplementation

--- Prints a list of commands that don't have an implementation (default or per filetype)
function L.list_unimplemented()
	print("The following commands are not implemented for any type of file")
	for name, cmd in pairs(L.commands) do
		if (not cmd.default_implementation) and vim.tbl_isempty(cmd.implementations) then
			print("-", name)
		end
	end
	print("End of the list")
end

function L.list_implemented()
	print("The following commands are implemented by default")
	for name, cmd in pairs(L.commands) do
		if cmd.default_implementation then
			print("-", name, "=>", cmd.default_implementation)
		end
	end
	print("End of the list")
end

---Registers a set of commands for a specific filetype
--- @param filetype string|string[]
--- @param commands LYRD.commands.implementation[]
function L.implement(filetype, commands)
	for _, command_info in ipairs(commands) do
		local cmd, implementation = unpack(command_info)
		if cmd == nil then
			error("The command to be implemented does not exist. It's implementation would be: " .. implementation)
		end
		cmd:implement_for(filetype, implementation)
	end
end

---Registers a set of commands
--- @param commands table<string, Command> dictionary with the list of commands to be registered.
function L.register(commands)
	for command_name, definition in pairs(commands) do
		definition:register_with_name(command_name)
	end
end

--- @param commandName string Name of the command to generate the shortcut
--- @param opts? ShortCutOptions Options for the generated shortcut
function L.command_shortcut(commandName, opts)
	local sequence = commandName
	-- if opts and opts.range then
	-- 	sequence = "'<,'>" .. sequence
	-- end
	sequence = "<cmd>" .. sequence .. "<CR>"
	if opts and opts.escape then
		sequence = "<ESC>" .. sequence
	end

	return sequence
end

--- This function return a handler function which will execute the given callback function with the given arguments.
--- @param callback function to be executed with the given arguments
--- @vararg any list of arguments to be passed to the callback function
--- @return function
function L.handler(callback, ...)
	local params = { ... }
	return function()
		callback(unpack(params))
	end
end

function L.healthcheck()
	vim.health.start(L.name)
	local unimplemented_commands = {}
	for name, cmd in pairs(L.commands) do
		if (not cmd.default_implementation) and vim.tbl_isempty(cmd.implementations) then
			table.insert(unimplemented_commands, name)
			vim.health.warn(name .. " commmand is not implemented")
		end
	end
	if #unimplemented_commands == 0 then
		vim.health.ok("All commands have at least one implementation.")
	end
end

return L
