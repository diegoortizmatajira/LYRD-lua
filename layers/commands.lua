local setup = require "setup"

local L = {
    name = 'Commands'
}

function L.plugins(_)
end

function register_implementation(filetype, commandName, implementation)
    if LYRD_setup.commands[commandName] == nil then
        LYRD_setup.commands[commandName] = {
            ['_'] = '', -- Placeholder
        }
    end
    LYRD_setup.commands[commandName][filetype] = implementation
end

function execute_command(commandName)
    local cmd = LYRD_setup.commands[commandName][vim.bo.filetype]
    if cmd ~= nil and cmd ~= '' then
        vim.cmd(cmd)
        return
    end
    cmd = LYRD_setup.commands[commandName]['*']
    if cmd ~= nil and cmd ~= '' then
        vim.cmd(cmd)
        return
    end
    local message = "Command '"..commandName.."' not implemented for the filetype '"..vim.bo.filetype.."'"
    vim.cmd('echo '..message)
end

function L.settings(s)
    s.commands = {
        ['_'] = {} -- Placeholder
    }
end

function L.keybindings(s)
end

function L.complete(s)
end

function L.implementations(filetype, commands)
    for command, implementation in pairs(commands) do
        register_implementation(filetype, command, implementation)
    end
end

function L.commands(commands)
    for _, command in ipairs(commands) do
        register_implementation('*', command, implementation)
        vim.cmd("command! '"..command[1].."' call luaeval('require \"layers.command\".execute_command("..command[1]..")')")
    end
end

return L
