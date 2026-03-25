local function get_current_year()
	return os.date("%Y")
end

local function setup_goku_highlights()
	vim.api.nvim_set_hl(0, "GokuHair", { fg = "#0AD7EB" })
	vim.api.nvim_set_hl(0, "GokuSkin", { fg = "#FFCC99" })
	vim.api.nvim_set_hl(0, "GokuSkinDark", { fg = "#DB7C6B" })
	vim.api.nvim_set_hl(0, "GokuGi", { fg = "#FF6600" })
	vim.api.nvim_set_hl(0, "GokuUnderGi", { fg = "#1B5585" })
end

local goku_ns = vim.api.nvim_create_namespace("lyrd_goku_colors")
setup_goku_highlights()

local color_map = {
	"___________HHHHH______________", -- hair spike
	"_____HHHHHH_HHHH______________", -- hair
	"______HHHHHHHHHHHH____________", -- hair
	"________HHHHHHHHHHHH__________", -- hair
	"____HHHHHHHHHHHHHHHHH_________", -- hair/forehead
	"___HHHHHHHHHHHHHHHHHHHHHHH____", -- hair sides + face
	"______HHHHHHHSSHHHHHHHHHHH____", -- eyes area
	"______HHHHHHSSSSsssHHHHHH_____", -- lower face
	"_________HHSSSSSssssHHH_______", -- mouth
	"_________USSSSssssssHH________", -- chin/neck
	"____GGGGUUSSSsSSsssssUGGGG____", -- shoulders
	"_UGGGGGGUUSSSSsSSssssUUGGG__UU", -- torso
	"UGG_G_GGUUUSSSSSSsssUUGGGGGUUU", -- torso
	"UUUGGGGGGGUUUUUUUUUUUUGGGGGUUU", -- lower body
	"UUUUGGGGGGGUUUUUUGGGGGGGGUUUUU", -- lower body
	"UUUUGGGGGGGGGGGGGGGGGGGGUUUUUU", -- feet
}
local content = {
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣶⣦⡄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⢀⠀⢹⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣷⣄⠨⣿⣿⣿⡌⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣷⣿⣿⣿⣿⣿⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⣠⣴⣾⣿⣮⣝⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠈⠉⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣿⣿⣬⣶⣶⡶⠦⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⣀⣢⣙⣻⢿⣿⣿⣿⢿⢹⣿⠕⢹⣿⣿⡿⣛⣥⣀⣀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⡏⣿⡏⠿⢿⣜⣡⠿⠏⡽⣸⡿⣟⡋⠉⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠾⣿⣿⣿⣿⣏⣸⣿⣿⣿⠿⠛⠓⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀  ⢙⢿⣿⣯⣽⡿⠋ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⣀⣠⣴⣶⣿⣧⣾⣿⣿⠎⢎⣋⡅⠆⣿⣿⡄⢉⠃⣦⡤⡀⠀⠀⠀⠀]],
	[[⠀⠀⠐⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣸⣇⣭⣸⣇⣿⣿⢀⡌⠀⣿⡇⠟⠀⠀⢄⠀]],
	[[⠀⣴⣇⠀⡇⠀⠸⣿⣿⣿⣿⣽⣟⣲⡤⣉⣠⣴⡾⣿⠟⠀⣸⠟⠀⠀⣿⠟⡰⡀]],
	[[⣼⣿⠋⢀⣇⢸⡄⢻⣟⠻⣿⣿⣿⣿⣿⣿⠿⡿⠟⢁⠀⢾⣿⡏⣸⢰⠀⣠⠀⠰]],
	[[⢸⣿⡣⣜⣿⣼⣿⣄⠻⡄⡀⠉⠛⠿⠿⠛⣉⡤⠖⣡⣶⠁⠀⠼⠟⣾⣶⣿⣿⡀]],
	[[⣾⡇⠈⠛⠛⠿⣿⣿⣦⠁⠘⢷⣶⣶⡶⠟⢋⣠⣾⡿⠃⠀⡤⠖⠰⠛⠉⠉⠀    LYRD® Neovim by Diego Ortiz. ]]
		.. get_current_year(),
}
local image_hl_map = {
	H = "GokuHair",
	S = "GokuSkin",
	s = "GokuSkinDark",
	G = "GokuGi",
	U = "GokuUnderGi",
}

local function colorize(buf)
	vim.api.nvim_buf_clear_namespace(buf, goku_ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local goku_line = 0
	for i, line in ipairs(lines) do
		if line:find("\xe2[\xa0-\xa3][\x80-\xbf]") then
			goku_line = goku_line + 1
			local map_str = color_map[goku_line]
			if not map_str then
				break
			end
			-- Collect byte positions of all braille chars in this line
			local positions = {}
			for pos in line:gmatch("()\xe2[\xa0-\xa3][\x80-\xbf]") do
				table.insert(positions, pos)
			end
			-- Apply highlights by grouping consecutive chars with the same color
			local run_start = nil
			local run_hl = nil
			local run_end = nil
			for idx, pos in ipairs(positions) do
				local hl = image_hl_map[map_str:sub(idx, idx)]
				if hl == run_hl then
					run_end = pos + 2
				else
					if run_hl and run_start then
						vim.api.nvim_buf_set_extmark(buf, goku_ns, i - 1, run_start - 1, {
							end_col = run_end,
							hl_group = run_hl,
							priority = 200,
						})
					end
					if hl then
						run_start = pos
						run_hl = hl
						run_end = pos + 2
					else
						run_start = nil
						run_hl = nil
					end
				end
			end
			if run_hl and run_start then
				vim.api.nvim_buf_set_extmark(buf, goku_ns, i - 1, run_start - 1, {
					end_col = run_end,
					hl_group = run_hl,
					priority = 200,
				})
			end
		end
	end
end
return {
	-- Per-character color map for the Goku image (H=Hair, S=Skin, G=Gi, _=no color)
	-- Each string corresponds to an image line; one character per braille character
	color_map = color_map,
	content = content,
	setup_highlights = setup_goku_highlights,
	colorize = colorize,
}
