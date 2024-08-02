local mappings = require("LYRD.layers.mappings")

local L = { name = "TabBehavior" }

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function tab_handler()
	local tabnine = require("tabnine.keymaps")
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	if luasnip.locally_jumpable(1) then
		luasnip.jump(1)
	elseif tabnine.has_suggestion() then
		return tabnine.accept_suggestion()
	elseif cmp.visible() then
		local entry = cmp.get_selected_entry()
		if not entry then
			cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
		end
		cmp.confirm()
	elseif has_words_before() then
		cmp.complete()
	else
		return "<tab>"
	end
end

local function shift_tab_handler()
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	if luasnip.locally_jumpable(-1) then
		luasnip.jump(-1)
	elseif cmp.visible() then
		cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
	else
		return "<S-tab>"
	end
end

function L.keybindings(_)
	vim.keymap.set("i", "<tab>", tab_handler, { expr = true })
	vim.keymap.set("s", "<tab>", tab_handler, { expr = true })
	vim.keymap.set("c", "<tab>", tab_handler, { expr = true })
	vim.keymap.set("i", "<S-tab>", shift_tab_handler, { expr = true })
	vim.keymap.set("s", "<S-tab>", shift_tab_handler, { expr = true })
	vim.keymap.set("c", "<S-tab>", shift_tab_handler, { expr = true })
end

return L
