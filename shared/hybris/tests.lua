-- Test discovery + picker for the "Hybris: Test" overseer task. Hybris' ant
-- test targets (unittests/integrationtests) must be told what to run via
-- -Dtestclasses.extensions=<ext> or -Dtestclasses=<fully qualified class>, so this scans the custom extensions' testsrc/ and lets the user
-- choose one with vim.ui.select.
--
-- Public API:
--   M.list_targets(hybris_home)  -- { { label, property, value, extension } ... }
--   M.pick(hybris_home, cb)      -- vim.ui.select over list_targets; cb(target?)

local M = {}

---@class LYRD.hybris.TestTarget
---@field label string text shown in the picker
---@field property "extensions"|"classes" what the value is: an extension name, or a fully qualified class
---@field value string value for that property
---@field extension string owning extension

local TEST_FILE_PATTERN = "Tests?%.java$"

---@param hybris_home string
---@return table<string, string> extension name -> root dir
local function custom_extensions(hybris_home)
	local roots = {}
	-- Project extensions sit in bin/custom or in any other bin/ group folder
	-- (e.g. bin/ext-<company>/); platform and modules are SAP's, not ours.
	-- The scanner follows symlinks; vim's ** glob doesn't.
	local scanner = require("LYRD.shared.hybris.scanner")
	local base_dirs = {}
	for _, dir in ipairs(vim.fn.glob(hybris_home .. "/bin/*", false, true)) do
		local name = vim.fn.fnamemodify(dir, ":t")
		if name ~= "platform" and name ~= "modules" and vim.fn.isdirectory(dir) == 1 then
			table.insert(base_dirs, dir)
		end
	end
	local all_roots = {}
	for _, base_dir in ipairs(base_dirs) do
		vim.list_extend(all_roots, scanner.find_extension_roots(base_dir))
	end
	for _, root in ipairs(all_roots) do
		local file = root .. "/extensioninfo.xml"
		local name = table.concat(vim.fn.readfile(file), "\n"):match('<extension[^>]-%sname%s*=%s*"([^"]+)"')
		if name then
			roots[name] = root
		end
	end
	return roots
end

-- Finds the fully qualified class name from the path under testsrc/, which
-- avoids parsing the file's package declaration.
---@param testsrc string
---@param file string
---@return string
local function class_name(testsrc, file)
	return (file:sub(#testsrc + 2):gsub("%.java$", ""):gsub("[/\\]", "."))
end

---@param hybris_home string
---@return LYRD.hybris.TestTarget[]
function M.list_targets(hybris_home)
	local targets = {}
	local extensions = custom_extensions(hybris_home)
	local names = vim.tbl_keys(extensions)
	table.sort(names)
	for _, ext in ipairs(names) do
		local testsrc = extensions[ext] .. "/testsrc"
		if vim.fn.isdirectory(testsrc) == 1 then
			table.insert(targets, {
				label = string.format("[extension] %s", ext),
				property = "extensions",
				value = ext,
				extension = ext,
			})
			local classes = {}
			for _, file in ipairs(vim.fn.glob(testsrc .. "/**/*.java", false, true)) do
				if file:match(TEST_FILE_PATTERN) then
					table.insert(classes, class_name(testsrc, file))
				end
			end
			table.sort(classes)
			for _, class in ipairs(classes) do
				table.insert(targets, {
					label = string.format("%s  (%s)", class, ext),
					property = "classes",
					value = class,
					extension = ext,
				})
			end
		end
	end
	return targets
end

---@param hybris_home string
---@param cb fun(target: LYRD.hybris.TestTarget?)
function M.pick(hybris_home, cb)
	local targets = M.list_targets(hybris_home)
	if #targets == 0 then
		vim.notify("Hybris: no test sources (testsrc/) found in custom extensions.", vim.log.levels.WARN)
		return
	end
	vim.ui.select(targets, {
		prompt = "Hybris test to run:",
		format_item = function(item)
			return item.label
		end,
	}, cb)
end

return M
