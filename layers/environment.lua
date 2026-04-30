local declarative_layer = require("LYRD.shared.declarative_layer")

local ENV_FILETYPES = { "env", "dotenv", "edf", "conf" }

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Environment variables support",
	required_plugins = {
		{
			"ellisonleao/dotenv.nvim",
			opts = {},
			cmd = { "Dotenv", "DotenvGet" },
		},
		{
			--- Provides LSP features for environment variable files, with optional integration with shelter.nvim for enhanced masking and peeking capabilities.
			"ph1losof/ecolog2.nvim",
			lazy = false,
			build = "cargo install ecolog-lsp",
			opts = {},
		},
		{
			--- Provides masking for environment variables in supported filetypes, with optional integration with ecolog2.nvim for enhanced features.
			"ph1losof/shelter.nvim",
			lazy = false,
			opts = {
				env_filetypes = ENV_FILETYPES,
				modules = {
					ecolog = {
						cmp = true, -- Mask in completion
						peek = false, -- Show real value on hover
						picker = false, -- Show real value in picker
					},
					files = true,
					telescope_previewer = true,
				},
			},
		},
	},
	required_mason_packages = {
		"dotenv-linter",
	},
	required_formatters = {
		["dotenv_linter"] = require("LYRD.shared.conform.dotenv-linter"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = ENV_FILETYPES,
			format_settings = { "dotenv_linter" },
		},
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.editorconfig_checker",
		declarative_layer.source_with_opts("null-ls.builtins.diagnostics.dotenv_linter", {
			args = { "check", "$FILENAME" },
			extra_filetypes = ENV_FILETYPES,
		}),
	},
	required_filetype_definitions = {
		-- Mappings based on file extension
		extension = {
			env = "env",
		},
		-- Mappings based on FULL filename
		filename = {
			[".env"] = "env",
			["env"] = "env",
		},
		-- Mappings based on filename pattern match
		pattern = {
			-- Match filenames like ".env.development", "env.local" and so on
			[".env.*"] = "env",
			[".?env%.?[^%.]{3}$"] = "env", -- Updated criterion to exclude files with 3-character extensions.
		},
	},
}

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement(ENV_FILETYPES, {
		{ cmd.LYRDToggleBufferDecorations, ":Shelter toggle" },
		{ cmd.LYRDLSPHoverInfo, "Shelter peek" },
	})
end

return declarative_layer.apply(L)
