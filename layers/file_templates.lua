local setup = require("LYRD.setup")
local utils = require("LYRD.utils")

local L = {
	name = "File templates",
	ignore_filetypes = { "dbout" },
}

function L.plugins(s)
	setup.plugin(s, {
		{
			"Futarimiti/spooky.nvim",
			opts = {
				directory = utils.get_lyrd_path() .. "/skeletons",
				case_sensitive = false,
				auto_use_only = false,
				ui = {
					select = "builtin",
					select_full_path = false,
					show_no_template = true,
					prompt = "Select template",
					previewer_prompt = "Preview",
					preview_normalised = true,
					highlight_preview = true,
					no_template = "<No template>",
					telescope_opts = {},
				},
			},
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
	})
end

function L.settings(_)
	vim.api.nvim_create_augroup("EmptyFileCheck", { clear = true })

	vim.api.nvim_create_autocmd("BufReadPost", {
		group = "EmptyFileCheck",
		pattern = "*",
		callback = function()
			if utils.contains(L.ignore_filetypes, vim.bo.filetype) then
				return
			end
			-- Check if the file is empty
			if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
				-- Attempt to use Spook to apply a template
				vim.cmd("Spook!")
			end
		end,
	})
end

return L
