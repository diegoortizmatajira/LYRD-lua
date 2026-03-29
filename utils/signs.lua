--- @class LYRD.SignItem
--- @field name string
SignItem = {
	name = "",
	sign_group = "LYRDSigns",
}

function SignItem:new(name, text, texthl)
	vim.fn.sign_define(name, { text = text or ">", texthl = texthl or "WarningMsg" })
	local obj = { name = name }
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function SignItem:place(bufnr, line)
	vim.fn.sign_place(0, self.sign_group, self.name, bufnr, { lnum = line, priority = 10 })
end

function SignItem:unplace(bufnr, line)
	vim.fn.sign_unplace(self.sign_group, { buffer = bufnr, lnum = line })
end

function SignItem:toggle(bufnr, line)
	local placed = vim.fn.sign_getplaced(bufnr, { group = self.sign_group })[1].signs
	for _, sign in ipairs(placed) do
		if sign.name == self.name and sign.lnum == line then
			self:unplace(bufnr)
			return
		end
	end
	self:place(bufnr, line)
end

function SignItem:is_placed(bufnr, line)
	local placed = vim.fn.sign_getplaced(bufnr, { group = self.sign_group })[1].signs
	for _, sign in ipairs(placed) do
		if sign.name == self.name and sign.lnum == line then
			return true
		end
	end
	return false
end

function SignItem:get_placed(bufnr)
	local placed = vim.fn.sign_getplaced(bufnr, { group = self.sign_group })[1].signs
	local lines = {}
	for _, sign in ipairs(placed) do
		if sign.name == self.name then
			table.insert(lines, sign.lnum)
		end
	end
	return lines
end

function SignItem:clear(bufnr)
	local placed = vim.fn.sign_getplaced(bufnr, { group = self.sign_group })[1].signs
	for _, sign in ipairs(placed) do
		if sign.name == self.name then
			vim.fn.sign_unplace(self.sign_group, { buffer = bufnr, id = sign.id })
		end
	end
end

function SignItem:undefine()
	vim.fn.sign_undefine(self.name)
end
