local setup = require("LYRD.shared.setup")

---@class LYRD.layer.Text: LYRD.shared.setup.Module
local L = { name = "Text functions" }

function L.plugins()
	setup.plugin({
		{
			"johmsalas/text-case.nvim",
			dependencies = { "nvim-telescope/telescope.nvim" },
			opts = {},
			config = function(_, opts)
				require("textcase").setup(opts)
				require("telescope").load_extension("textcase")
			end,
			keys = {
				"ga", -- Default invocation prefix
				{ "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
			},
			cmd = {
				-- NOTE: The Subs command name can be customized via the option "substitude_command_name"
				"Subs",
				"TextCaseOpenTelescope",
				"TextCaseOpenTelescopeQuickChange",
				"TextCaseOpenTelescopeLSPChange",
				"TextCaseStartReplacingCommand",
			},
			-- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
			-- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
			-- available after the first executing of it or after a keymap of text-case.nvim has been used.
			lazy = false,
		},
	})
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("*", {
		{ cmd.LYRDEditTextCase, ":TextCaseOpenTelescope" },
		{ cmd.LYRDTextWordCount, L.word_count },
	})
end

--- Shows the number of words and characters in the current selection, the
--- given command range, or the whole document.
---@param opts? table Command options (as received from nvim_create_user_command)
function L.word_count(opts)
	local mode = vim.api.nvim_get_mode().mode
	local words, chars, scope
	if mode == "v" or mode == "V" or mode == "\22" then
		local wc = vim.fn.wordcount()
		words, chars, scope = wc.visual_words, wc.visual_chars, "Selection"
	elseif opts and opts.range and opts.range > 0 then
		local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
		local text = table.concat(lines, "\n")
		words = select(2, text:gsub("%S+", ""))
		chars = vim.fn.strchars(text)
		scope = string.format("Lines %d-%d", opts.line1, opts.line2)
	else
		local wc = vim.fn.wordcount()
		words, chars, scope = wc.words, wc.chars, "Document"
	end
	vim.notify(string.format("%s: %d words, %d characters", scope, words, chars), vim.log.levels.INFO, {
		title = "Word count",
	})
end

function L.to_title_case(text_input)
	return require("textcase").api.to_title_case(text_input)
end

function L.to_upper_case(text_input)
	return require("textcase").api.to_upper_case(text_input)
end

function L.to_lower_case(text_input)
	return require("textcase").api.to_lower_case(text_input)
end

function L.to_capital_snake_case(text_input)
	return require("textcase").api.to_constant_case(text_input)
end

function L.to_snake_case(text_input)
	return require("textcase").api.to_snake_case(text_input)
end

function L.to_dash_case(text_input)
	return require("textcase").api.to_dash_case(text_input)
end

function L.to_camel_case(text_input)
	return require("textcase").api.to_camel_case(text_input)
end

function L.to_pascal_case(text_input)
	return require("textcase").api.to_pascal_case(text_input)
end

return L
