local L = {
	name = "Commands",
	--- @type table<string, Command>
	commands = {},
}
--- @class ShortCutOptions
--- @field range? boolean Indicates the shorcut uses current selection.
--- @field escape? boolean Indicates the shorcut includes <ESC> before running the command.

---@class Command
---@field name? string|nil Name of the command.
---@field desc string Command description.
---@field default_implementation? string|function|nil Default implementation.
---@field icon string|nil Icon to show for the command.
---@field range? boolean|nil Indicates whether the command can be applied to a range of text.
---@field implementations table<string, string|function> Implementations per filetype.
Command = {}

--- Constructor
---@param desc string Command description.
---@param default_implementation? string|function|nil Default implementation.
---@param icon? string|nil Icon to show for the command.
---@param range? boolean|nil Indicates whether the command can be applied to a range of text.
---@return Command
function Command:new(desc, default_implementation, icon, range)
	self.__index = self
	local o = setmetatable({}, self)
	o.name = ""
	o.desc = desc
	o.default_implementation = default_implementation
	o.icon = icon
	o.range = range
	o.implementations = {}
	return o
end

--- Implements the command for one or many file types.
---@param filetype string A filetype.
---@param implementation string|function An implementation of the command.
function Command:implement_for_filetype(filetype, implementation)
	if filetype == "*" then
		self.default_implementation = implementation
	else
		self.implementations[filetype] = implementation
	end
end

--- Implements the command for one or many file types.
---@param target string|string[] One filetype or a list of filetypes.
---@param implementation string|function An implementation of the command.
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
function Command:execute()
	-- Looks for the current file type command implementation
	local implementation = self.implementations[vim.bo.filetype]
	if implementation then
		L.execute_implementation(implementation)
	else
		if self.default_implementation then
			L.execute_implementation(self.default_implementation)
		else
			vim.notify(
				string.format(
					[[Command '%s' has not been implemented for the filetype '%s']],
					self.name,
					vim.bo.filetype
				),
				vim.log.levels.WARN
			)
		end
	end
end

--- Registers the command with the given name, and links the execute method to it.
---@param command_name string Name for the command to be created
function Command:register_with_name(command_name)
	self.name = command_name
	L.commands[self.name] = self
	vim.api.nvim_create_user_command(command_name, function()
		self:execute()
	end, { desc = self.desc, range = self.range })
end

--- Returns the command with modifiers to be used with a text range in visual mode.
--- @param opts ShortCutOptions
--- @return string
function Command:shortcut(opts)
	return L.command_shortcut(self.name, opts)
end

--- Executes a command instance
---@param implementation string|function|Command
---@return boolean
function L.execute_implementation(implementation)
	if type(implementation) == "string" and implementation ~= "" then
		---Executes a command
		---@param command string
		local ok, _ = pcall(function(command)
			return vim.cmd(command)
		end, implementation)
		if not ok then
			vim.notify("Command execution failed: " .. implementation, vim.log.levels.ERROR)
		end
		return true
	elseif type(implementation) == "function" then
		implementation()
		return true
	elseif type(implementation) == "table" and implementation.name then
		L.execute_implementation(":" .. implementation.name)
	end
	return false
end

---@class LYRD.commands.settings
---@field commands table<string, table<string, string|function>>

---@class LYRD.commands.implementation
---@field [1] Command
---@field [2] string|function

--- Prints a list of commands that don't have an implementation (default or per filetype)
function L.list_unimplemented()
	print("The following commands are not implemented for any type of file")
	for name, cmd in pairs(L.commands) do
		if (not cmd.default_implementation) and (#cmd.implementations == 0) then
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
---@param filetype string|string[]
---@param commands LYRD.commands.implementation[]
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
---@param commands table<string, Command> dictionary with the list of commands to be registered.
function L.register(commands)
	for command_name, definition in pairs(commands) do
		definition:register_with_name(command_name)
	end
end

--- @param commandName string Name of the command to generate the shortcut
--- @param opts ShortCutOptions Options for the generated shortcut
function L.command_shortcut(commandName, opts)
	local sequence = commandName
	if opts and opts.range then
		sequence = "'<,'>" .. sequence
	end
	sequence = "<cmd>" .. sequence .. "<CR>"
	if opts and opts.escape then
		sequence = "<ESC>" .. sequence
	end

	return sequence
end

--- This function return a handler function which will execute the given callback function with the given arguments.
---@param callback Function to be executed with the given arguments
---@vararg any list of arguments to be passed to the callback function
---@return function
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
		if (not cmd.default_implementation) and (#cmd.implementations == 0) then
			table.insert(unimplemented_commands, name)
			vim.health.warn(name .. " commmand is not implemented")
		end
	end
	if #unimplemented_commands == 0 then
		vim.health.ok("All commands have at least one implementation.")
	end
end

return L
