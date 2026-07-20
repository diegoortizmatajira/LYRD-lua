local M = {}

--- @alias LYRD.utils.encoding.Transform fun(text: string): string?, string?

--- URL-encodes a string (percent-encoding), leaving unreserved characters
--- (letters, digits, '-', '_', '.', '~') untouched.
--- @param str string
--- @return string
function M.url_encode(str)
	local encoded = str:gsub("[^%w%-%_%.%~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	return encoded
end

--- Decodes a percent-encoded URL string, converting '+' to spaces.
--- @param str string
--- @return string
function M.url_decode(str)
	local decoded = str:gsub("+", " "):gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)
	return decoded
end

--- Base64-encodes a string.
--- @param str string
--- @return string
function M.base64_encode(str)
	return vim.base64.encode(str)
end

--- Decodes a base64-encoded string.
--- @param str string
--- @return string?, string?
function M.base64_decode(str)
	local ok, result = pcall(vim.base64.decode, str)
	if not ok then
		return nil, "invalid base64 input"
	end
	return result
end

-- Classic uuencode maps each 6-bit value to a printable ASCII character by
-- adding 0x20, using '`' (rather than a trailing space) to represent zero.
local UUENCODE_OFFSET = 0x20

--- @param value integer A 6-bit value (0-63).
--- @return string
local function uu_encode_char(value)
	if value == 0 then
		return "`"
	end
	return string.char(value + UUENCODE_OFFSET)
end

--- @param char string A single uuencoded character.
--- @return integer value The decoded 6-bit value (0-63).
local function uu_decode_char(char)
	if char == "`" or char == " " then
		return 0
	end
	return (char:byte() - UUENCODE_OFFSET) % 0x40
end

--- Encodes a string using the classic uuencode algorithm, in chunks of up to
--- 45 bytes per line. This produces the encoded body only, without the
--- `begin`/`end` envelope used by the standalone `uuencode` command-line
--- tool, so it round-trips cleanly through `M.uudecode`.
--- @param str string
--- @return string
function M.uuencode(str)
	local lines = {}
	local pos = 1
	local len = #str
	repeat
		local chunk = str:sub(pos, pos + 44)
		local chunk_len = #chunk
		local padded = chunk .. string.rep("\0", (3 - (chunk_len % 3)) % 3)
		local parts = { uu_encode_char(chunk_len) }
		for i = 1, #padded, 3 do
			local b1, b2, b3 = padded:byte(i, i + 2)
			local n = b1 * 0x10000 + b2 * 0x100 + b3
			table.insert(parts, uu_encode_char(math.floor(n / 0x40000) % 0x40))
			table.insert(parts, uu_encode_char(math.floor(n / 0x1000) % 0x40))
			table.insert(parts, uu_encode_char(math.floor(n / 0x40) % 0x40))
			table.insert(parts, uu_encode_char(n % 0x40))
		end
		table.insert(lines, table.concat(parts))
		pos = pos + 45
	until pos > len
	return table.concat(lines, "\n")
end

--- Decodes a uuencoded string produced by `M.uuencode` (any `begin`/`end`
--- envelope lines from the standalone `uuencode` tool are ignored).
--- @param str string
--- @return string?, string?
function M.uudecode(str)
	local result = {}
	for _, line in ipairs(vim.split(str, "\n", { plain = true })) do
		if line ~= "" and not line:match("^begin ") and line ~= "end" then
			local declared_len = uu_decode_char(line:sub(1, 1))
			local body = line:sub(2)
			local written = 0
			for i = 1, #body, 4 do
				local group = body:sub(i, i + 3)
				if #group < 4 then
					return nil, "malformed uuencoded line: " .. line
				end
				local n = uu_decode_char(group:sub(1, 1)) * 0x40000
					+ uu_decode_char(group:sub(2, 2)) * 0x1000
					+ uu_decode_char(group:sub(3, 3)) * 0x40
					+ uu_decode_char(group:sub(4, 4))
				local remaining = declared_len - written
				if remaining >= 1 then
					table.insert(result, string.char(math.floor(n / 0x10000) % 0x100))
				end
				if remaining >= 2 then
					table.insert(result, string.char(math.floor(n / 0x100) % 0x100))
				end
				if remaining >= 3 then
					table.insert(result, string.char(n % 0x100))
				end
				written = written + 3
			end
		end
	end
	return table.concat(result)
end

--- Base64url-decodes a string (RFC 4648 §5), restoring standard padding.
--- @param str string
--- @return string?, string?
local function base64url_decode(str)
	local padded = str:gsub("%-", "+"):gsub("_", "/")
	padded = padded .. string.rep("=", (4 - (#padded % 4)) % 4)
	local ok, result = pcall(vim.base64.decode, padded)
	if not ok then
		return nil, "invalid base64url segment"
	end
	return result
end

--- Decodes a JWT's header and payload segments and returns them as JSON. The
--- signature is left untouched (base64url) and is not verified.
--- @param str string
--- @return string?, string?
function M.jwt_decode(str)
	local header_b64, payload_b64, signature = str:match("^%s*([%w%-_]+)%.([%w%-_]+)%.?([%w%-_]*)%s*$")
	if not header_b64 or not payload_b64 then
		return nil, "not a valid JWT (expected header.payload.signature)"
	end

	local header_json, header_err = base64url_decode(header_b64)
	if not header_json then
		return nil, "header: " .. header_err
	end
	local payload_json, payload_err = base64url_decode(payload_b64)
	if not payload_json then
		return nil, "payload: " .. payload_err
	end

	local ok_header, header = pcall(vim.json.decode, header_json)
	if not ok_header then
		return nil, "header is not valid JSON"
	end
	local ok_payload, payload = pcall(vim.json.decode, payload_json)
	if not ok_payload then
		return nil, "payload is not valid JSON"
	end

	local lines = {
		"// header",
		vim.json.encode(header),
		"",
		"// payload",
		vim.json.encode(payload),
	}
	if signature ~= "" then
		table.insert(lines, "")
		table.insert(lines, "// signature (unverified, base64url)")
		table.insert(lines, signature)
	end
	return table.concat(lines, "\n")
end

return M
