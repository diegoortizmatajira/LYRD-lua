local time = require("luasnip.util.time")

local function offset_str()
	return (time.get_timezone_offset(os.time()):gsub("([+-])(%d%d)(%d%d)$", "%1%2:%3"))
end

local function iana_zone()
	local ok, target = pcall(vim.uv.fs_readlink, "/etc/localtime")
	if ok and target then
		local zone = target:match("zoneinfo/(.+)$")
		if zone then
			return zone
		end
	end
	return os.date("%Z")
end

return {
	s({ trig = "now-iso-zone", dscr = "Current date/time in ISO8601 with UTC offset and IANA zone name" }, {
		f(function()
			return os.date("%Y-%m-%dT%H:%M:%S") .. offset_str() .. "[" .. iana_zone() .. "]"
		end, {}),
	}),
	s({ trig = "now-utc", dscr = "Current date/time in ISO8601 UTC (Z suffix)" }, {
		f(function()
			return os.date("!%Y-%m-%dT%H:%M:%SZ")
		end, {}),
	}),
	s({ trig = "now-gmt", dscr = "Current date/time as an RFC1123 GMT string" }, {
		f(function()
			return os.date("!%a, %d %b %Y %H:%M:%S GMT")
		end, {}),
	}),
}
