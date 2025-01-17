local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Media Files" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"HakonHarnes/img-clip.nvim",
			opts = {
				-- add options here
				-- or leave it empty to use the default settings
			},
			cmd = {
				"PasteImage",
			},
		},
	})
end

function L.insert_image()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	telescope.find_files({
		find_command = { "rg", "--files", "--iglob", "!*.{png,jpg}" },
		attach_mappings = function(_, map)
			local function embed_image(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				local filepath = entry[1]
				actions.close(prompt_bufnr)

				local img_clip = require("img-clip")
				img_clip.paste_image(nil, filepath)
			end

			map("i", "<CR>", embed_image)
			map("n", "<CR>", embed_image)

			return true
		end,
	})
end

function L.settings(s)
	commands.implement(s, { "markdown", "vimwiki", "html", "asciidoc" }, {
		{ cmd.LYRDPasteImage, ":PasteImage" },
		{ cmd.LYRDInsertImage, L.insert_image },
	})
end

return L
