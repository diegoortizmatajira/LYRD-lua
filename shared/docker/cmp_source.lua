-- nvim-cmp source that completes the "image:" property in docker-compose
-- files with references (repository:tag) from the local Docker image cache
-- (shared/docker/images.lua). No language server can offer this: the value
-- is free-form to the compose schema, and the candidates are host-local
-- state rather than anything derivable from the file itself.

local docker_images = require("LYRD.shared.docker.images")

local M = {}

--- Matches an "image:" mapping value, with or without a partial value typed.
local IMAGE_LINE_PATTERN = "^%s*image%s*:%s*%S*$"

--- Vim-regex character class covering the characters found in a Docker image
--- reference (registry host, path segments, tag/digest separators), used so
--- the full reference replaces any partially typed text instead of just the
--- last path segment.
local IMAGE_KEYWORD_PATTERN = [[\%([[:alnum:]./:_-]\)*]]

--- @param filetype string filetype this source is active for (e.g. "yaml.docker-compose")
function M.new(filetype)
	return setmetatable({ filetype = filetype }, { __index = M })
end

function M:get_debug_name()
	return "docker_images"
end

function M:is_available()
	return vim.bo.filetype == self.filetype
end

function M:get_trigger_characters()
	return { ":", "/" }
end

function M:get_keyword_pattern()
	return IMAGE_KEYWORD_PATTERN
end

function M:complete(params, callback)
	if not params.context.cursor_before_line:match(IMAGE_LINE_PATTERN) then
		return callback({ items = {}, isIncomplete = false })
	end
	local kind = require("cmp").lsp.CompletionItemKind.Value
	local items = {}
	for _, image in ipairs(docker_images.list()) do
		table.insert(items, { label = image, kind = kind })
	end
	callback({ items = items, isIncomplete = false })
end

return M
