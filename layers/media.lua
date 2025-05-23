local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Media Files" }

function L.plugins()
	setup.plugin({
		{
			"HakonHarnes/img-clip.nvim",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
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

function L.settings()
	commands.implement({ "markdown", "vimwiki", "html", "asciidoc" }, {
		{ cmd.LYRDPasteImage, ":PasteImage" },
		{ cmd.LYRDInsertImage, L.insert_image },
	})
end

return L
