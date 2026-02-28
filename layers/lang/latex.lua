local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")

---@class LYRD.layer.lang.LaTeX: LYRD.setup.Module
local L = { name = "LaTeX" }

function L.plugins()
	setup.plugin({
		{
			"lervag/vimtex",
			lazy = false,
			init = function()
				vim.g.vimtex_view_method = "zathura"
				vim.g.vimtex_compiler_method = "latexmk"
				vim.g.vimtex_compiler_latexmk = {
					options = {
						"-pdf",
						"-shell-escape",
						"-verbose",
						"-file-line-error",
						"-synctex=1",
						"-interaction=nonstopmode",
					},
				}
				vim.g.vimtex_quickfix_mode = 0
			end,
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"texlab",
		"latexindent",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"latex",
		"bibtex",
	})
	lsp.format_with_conform("tex", { "latexindent" })
end

function L.settings()
	commands.implement("tex", {
		{ cmd.LYRDCodeBuild, ":VimtexCompile" },
		{ cmd.LYRDCodeRun, ":VimtexView" },
		{ cmd.LYRDCodeGlobalCheck, ":VimtexErrors" },
		{ cmd.LYRDCodeTooling, ":VimtexInfo" },
	})
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable("texlab")
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("latexmk")
	health.check_executable("zathura")
end
return L
