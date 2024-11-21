local setup = require("LYRD.setup")

local L = { name = "TabNine" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"codota/tabnine-nvim",
			opts = {
				disable_auto_comment = true,
				accept_keymap = "<Right>",
				dismiss_keymap = "<C-]>",
				debounce_ms = 800,
				suggestion_color = { gui = "#808080", cterm = 244 },
				exclude_filetypes = { "TelescopePrompt", "NvimTree" },
				log_file_path = nil, -- absolute path to Tabnine log file
				ignore_certificate_errors = false,
			},
			main = "tabnine",
			build = "./dl_binaries.sh",
		},
		{
			"tzachar/cmp-tabnine",
			opts = {
				max_lines = 1000,
				max_num_results = 20,
				sort = true,
				run_on_every_keystroke = true,
				snippet_placeholder = "..",
				ignored_file_types = {
					-- default is not to ignore
					-- uncomment to ignore in lua:
					-- lua = true
				},
				show_prediction_strength = false,
				min_percent = 0,
			},
			build = "./install.sh",
			dependencies = "hrsh7th/nvim-cmp",
		},
	})
end

function L.settings(_) end

return L
