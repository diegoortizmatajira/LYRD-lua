local L = {
    name = 'Commands'
}

function L.plugins(_)
end

local function register_implementation(s, filetype, commandName, implementation)
    if s.commands[commandName] == nil then
        s.commands[commandName] = {}
    end
    LYRD_setup.commands[commandName][filetype] = implementation
end

 local function execute_command(s, commandName)
    local cmd = s.commands[commandName][vim.bo.filetype]
    if cmd ~= nil and cmd ~= '' then
        vim.cmd(cmd)
        return
    end
    cmd = s.commands[commandName]['*']
    if cmd ~= nil and cmd ~= '' then
        vim.cmd(cmd)
        return
    end
    print(string.format([[Command '%s' has not been implemented for the filetype '%s']], commandName, vim.bo.filetype))
end

function L.settings(s)
    s.commands = {}
    L.execute = function(commandName)
        execute_command(s, commandName)
    end
end

function L.complete(_)
end

function L.implement(s, filetype, commands)
    for command, implementation in pairs(commands) do
        register_implementation(s, filetype, command, implementation)
    end
end

function L.register(s, commands)
    for command, implementation in pairs(commands) do
        register_implementation(s, '*', command, implementation)
        vim.cmd(string.format([[command! %s call luaeval('require "layers.commands".execute("%s")')]], command, command))
    end
end

return L
