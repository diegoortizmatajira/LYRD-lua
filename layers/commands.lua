local L = { name = "Commands" }

function L.plugins(_) end

local function register_implementation(s, filetype, commandName, implementation)
	if s.commands[commandName] == nil then
		s.commands[commandName] = {}
	end
	LYRD_setup.commands[commandName][filetype] = implementation
end

local function execute_command(s, commandName)
	local cmd = s.commands[commandName][vim.bo.filetype]
	if cmd ~= nil and cmd ~= "" then
		vim.cmd(cmd)
		return
	end
	cmd = s.commands[commandName]["*"]
	if cmd ~= nil and cmd ~= "" then
		vim.cmd(cmd)
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
	_G.LYRD_Execute = function(commandName)
		execute_command(s, commandName)
	end

	L.list_unimplemented = function()
		show_unimplemented_commands(s)
	end
	L.list_implemented = function()
		show_implemented_commands(s)
	end
end

function L.complete(_) end

function L.implement(s, filetype, commands)
	for command, implementation in pairs(commands) do
		register_implementation(s, filetype, command, implementation)
	end
end

function L.register(s, commands)
	for command, implementation in pairs(commands) do
		register_implementation(s, "*", command, implementation)
		vim.cmd(string.format([[command! %s lua LYRD_Execute("%s")]], command, command))
	end
end

function L.command_shortcut(commandName)
	return "<cmd>" .. commandName .. "<CR>"
end

return L
