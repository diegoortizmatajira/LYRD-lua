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
	})
end

function L.settings(_) end

return L
