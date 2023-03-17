local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Buffer format" }
local custom_formatters = {}

function L.plugins(s)
	setup.plugin(s, { "mhartington/formatter.nvim" })
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDBufferFormat, ":Format" },
	})
	-- Default formatters
	L.add_formatters("cs", { require("formatter.filetypes.cs").dotnetformat })
	L.add_formatters("css", { require("formatter.filetypes.css").prettier })
	L.add_formatters("go", { require("formatter.filetypes.go").gofumpt })
	L.add_formatters("html", { require("formatter.filetypes.html").prettier })
	L.add_formatters("javascript", { require("formatter.filetypes.javascript").prettier })
	L.add_formatters("json", { require("formatter.filetypes.json").prettier })
	L.add_formatters("lua", { require("formatter.filetypes.lua").luaformat })
	L.add_formatters("python", { require("formatter.filetypes.python").yapf })
	L.add_formatters("toml", { require("formatter.filetypes.toml").taplo })
	L.add_formatters("typescript", { require("formatter.filetypes.typescript").prettier })
	L.add_formatters("yaml", { require("formatter.filetypes.yaml").prettier })
end

function L.complete(_)
	-- Sets the formatters provided by all the other layers
	require("formatter").setup({ filetype = custom_formatters })
end

function L.add_formatters(file_type, formatters)
	custom_formatters[file_type] = formatters
end

return L
