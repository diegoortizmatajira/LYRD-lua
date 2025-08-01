local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local mappings = require("LYRD.layers.mappings")

local L = { name = "REST Client" }

function L.plugins()
	setup.plugin({
		{
			"mistweaverco/kulala.nvim",
			opts = {
				default_view = "headers_body",
			},
		},
	})
end

function L.preparation()
	vim.filetype.add({
		extension = {
			["http"] = "http",
		},
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"http",
	})
end

function L.keybindings()
	mappings.create_filetype_menu("http", {
		{ "n", "i", [[<Cmd>lua require("kulala").inspect()<CR>]], { desc = "Inspect current request" } },
		{ "n", "d", [[<Cmd>lua require("kulala").show_stats()<CR>]], { desc = "Describe Statistics" } },
		{ "n", "S", [[<Cmd>lua require("kulala").scratchpad()<CR>]], { desc = "Open Scratchpad" } },
		{ "n", "c", [[<Cmd>lua require("kulala").copy()<CR>]], { desc = "Copy as Curl" } },
		{ "n", "p", [[<Cmd>lua require("kulala").from_curl()<CR>]], { desc = "Paste from Curl" } },
		{ "n", "t", [[<Cmd>lua require("kulala").toggle_view()<CR>]], { desc = "Toggle results view" } },
		{ "n", "s", [[<Cmd>lua require("kulala").search()<CR>]], { desc = "Search request" } },
		{ "n", "[", [[<Cmd>lua require("kulala").jump_prev()<CR>]], { desc = "Previous request" } },
		{ "n", "]", [[<Cmd>lua require("kulala").jump_next()<CR>]], { desc = "Next request" } },
	})
end

--- Returns the closest environment file for the current working directory. Starts with the current file directory and checks parent directories until it finds the file or reaches the root.
function L.get_closest_environment_file()
	local env_file = "http-client.env.json"

	local function file_exists(path)
		---@diagnostic disable-next-line: undefined-field
		local stat = vim.loop.fs_stat(path)
		return stat and stat.type == "file"
	end

	local buf_dir = vim.fn.expand("%:p:h")
	local current_dir = buf_dir

	while current_dir ~= nil and current_dir ~= "" do
		local env_file_path = current_dir .. "/" .. env_file
		if file_exists(env_file_path) then
			return env_file_path
		end

		-- Move up one directory level
		current_dir = current_dir:match("^(.*)/")
	end

	-- Return the default path in the current working directory if not found
	return vim.fn.getcwd() .. "/" .. env_file
end

function L.settings()
	commands.implement("http", {
		{
			cmd.LYRDCodeRunSelection,
			function()
				require("kulala").run()
			end,
		},
		{
			cmd.LYRDCodeRun,
			function()
				require("kulala").run_all()
			end,
		},
		{
			cmd.LYRDCodeSelectEnvironment,
			function()
				local env_file_path = L.get_closest_environment_file()
				local function file_exists(path)
					---@diagnostic disable-next-line: undefined-field
					local stat = vim.loop.fs_stat(path)
					return stat and stat.type == "file"
				end
				--- Creates the environment file if it does not exist
				if not file_exists(env_file_path) then
					local file = io.open(env_file_path, "w")
					if file then
						file:write("")
						file:close()
						vim.cmd("edit " .. env_file_path)
					else
						print("Error: Could not create " .. env_file_path)
					end
				else
					require("kulala").set_selected_env()
				end
			end,
		},
		{
			cmd.LYRDBufferClose,
			function()
				require("kulala").close()
			end,
		},
	})
end

return L
