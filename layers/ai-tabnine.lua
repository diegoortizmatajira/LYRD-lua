local setup = require("LYRD.setup")

local L = { name = "TabNine" }

function L.plugins(s)
	setup.plugin(s, {
		{ "codota/tabnine-nvim", run = "./dl_binaries.sh" },
	})
end

function L.settings(_)
	require("tabnine").setup({
		disable_auto_comment = true,
		accept_keymap = false,
		dismiss_keymap = "<C-]>",
		debounce_ms = 800,
		suggestion_color = { gui = "#808080", cterm = 244 },
		exclude_filetypes = { "TelescopePrompt", "NvimTree" },
		log_file_path = nil, -- absolute path to Tabnine log file
		ignore_certificate_errors = false,
	})
end

return L
