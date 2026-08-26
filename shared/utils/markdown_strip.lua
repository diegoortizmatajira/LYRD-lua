-- Strips common Markdown syntax down to plain, readable text. This is a
-- pragmatic regex-based pass (not a full CommonMark parser), aimed at the
-- "copy as plain text" use case rather than perfect round-tripping.

local M = {}

--- Recognized inline emphasis/markup markers, longest first so e.g. "***x***"
--- is peeled before "**x**" or "*x*" could partially match it.
local INLINE_MARKERS = {
	{ "%*%*%*(.-)%*%*%*", "%1" },
	{ "___(.-)___", "%1" },
	{ "%*%*(.-)%*%*", "%1" },
	{ "__(.-)__", "%1" },
	{ "~~(.-)~~", "%1" },
	{ "==(.-)==", "%1" },
	{ "%*(.-)%*", "%1" },
	{ "_(.-)_", "%1" },
	{ "</?u>", "" },
	{ "</?sup>", "" },
	{ "</?sub>", "" },
}

---@param line string
---@return string
local function strip_inline(line)
	-- Images: ![alt](url) -> alt
	line = line:gsub("!%[(.-)%]%(.-%)", "%1")
	-- Links: [text](url) -> text
	line = line:gsub("%[(.-)%]%(.-%)", "%1")
	-- Reference-style links/images: [text][ref] -> text
	line = line:gsub("%[(.-)%]%[.-%]", "%1")
	-- Inline code spans: `code` -> code
	line = line:gsub("`([^`]*)`", "%1")

	for _, marker in ipairs(INLINE_MARKERS) do
		line = line:gsub(marker[1], marker[2])
	end

	return line
end

---@param line string
---@return boolean
local function is_horizontal_rule(line)
	local trimmed = line:gsub("%s+", "")
	return trimmed ~= ""
		and (trimmed:match("^%-%-%-+$") or trimmed:match("^%*%*%*+$") or trimmed:match("^___+$")) ~= nil
end

--- Strips Markdown syntax from `text`, returning plain text: headings,
--- blockquote/list/task markers, emphasis, inline code, links/images, fenced
--- code delimiters, and horizontal rules are all removed or unwrapped down to
--- their readable content.
---@param text string
---@return string
function M.strip(text)
	local lines = vim.split(text, "\n", { plain = true })
	local result = {}
	local in_fence = false

	for _, line in ipairs(lines) do
		if line:match("^%s*```") or line:match("^%s*~~~") then
			in_fence = not in_fence
		elseif in_fence then
			table.insert(result, line)
		elseif is_horizontal_rule(line) then
			-- drop the line entirely
		else
			-- Headings: "## Title" -> "Title"
			line = line:gsub("^(%s*)#+%s*", "%1")
			-- Blockquote markers, possibly nested: "> > text" -> "text"
			line = line:gsub("^(%s*)[>%s]*>%s?", "%1")
			-- Task list checkboxes: "- [ ] " / "- [x] "
			line = line:gsub("^(%s*)[-*+]%s+%[[ xX]%]%s+", "%1")
			-- Bullet list markers: "- ", "* ", "+ "
			line = line:gsub("^(%s*)[-*+]%s+", "%1")
			-- Ordered list markers: "1. ", "1) "
			line = line:gsub("^(%s*)%d+[.)]%s+", "%1")

			table.insert(result, strip_inline(line))
		end
	end

	return table.concat(result, "\n")
end

return M
