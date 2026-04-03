local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "LaTeX Documents",
	required_mason_packages = {
		"texlab",
		"latexindent",
	},
	required_treesitter_parsers = {
		"latex",
		"bibtex",
	},
	required_enabled_lsp_servers = {
		"texlab",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = { "tex" },
			format_settings = { "latexindent", lsp_format = "prefer" },
		},
	},
	required_executables = {
		"latexmk",
		"zathura",
	},
}

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("tex", {
		{ cmd.LYRDCodeBuild, ":VimtexCompile" },
		{ cmd.LYRDCodeRun, ":VimtexView" },
		{ cmd.LYRDCodeGlobalCheck, ":VimtexErrors" },
		{ cmd.LYRDCodeTooling, ":VimtexInfo" },
	})
end

return declarative_layer.apply(L)
