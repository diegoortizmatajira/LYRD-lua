local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Data formats json, yaml, toml, xml" }

function L.plugins()
	setup.plugin({

		{ "b0o/schemastore.nvim" },
		{
			"VPavliashvili/json-nvim",
			ft = "json", -- only load for json filetype
		},
	})
end

local function jsonlint()
	local h = require("null-ls.helpers")
	local methods = require("null-ls.methods")

	local DIAGNOSTICS = methods.internal.DIAGNOSTICS

	return h.make_builtin({
		name = "jsonlint",
		meta = {
			url = "https://github.com/zaach/jsonlint",
			description = "A pure JavaScript version of the service provided at jsonlint.com.",
		},
		method = DIAGNOSTICS,
		filetypes = { "json" },
		generator_opts = {
			command = "jsonlint",
			args = { "--compact" },
			to_stdin = true,
			from_stderr = true,
			format = "line",
			check_exit_code = function(c)
				return c <= 1
			end,
			on_output = h.diagnostics.from_pattern("line (%d+), col (%d+), (.*)", { "row", "col", "message" }, {}),
		},
		factory = h.generator_factory,
	})
end

function L.preparation()
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"jsonlint",
		"lemminx",
		"prettier",
		"taplo",
		"xmlformatter",
		"yaml-language-server",
		"yamlfmt",
		"yamllint",
	})
	lsp.format_with_conform({ "json", "jsonc" }, { "prettier" })
	lsp.format_with_conform("xml", { "xmlformatter", lsp_format = "prefer" })

	lsp.null_ls_register_sources({
		jsonlint(),
	})

	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"scheme",
		"yaml",
		"json",
		"json5",
		"jsonc",
		"toml",
		"xml",
		"proto",
	})
end

function L.settings()
	-- Set up filetype for JSON configuration files to accept comments
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = { "launch.json", "tasks.json" },
		callback = function()
			vim.bo.filetype = "jsonc"
		end,
	})
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable({
		"jsonls",
		"yamlls",
		"taplo",
		"lemminx",
	})
end

return L
