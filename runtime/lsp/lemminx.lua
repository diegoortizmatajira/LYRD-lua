-- lemminx (XML language server). Self-contained: works as a plain XML/XSD/
-- XSL/SVG server for any project, and additionally associates Hybris's own
-- generated schemas (items.xsd/beans.xsd/extensioninfo.xsd) when the buffer
-- is inside a Hybris extension, so *-items.xml/*-beans.xml/extensioninfo.xml
-- get schema-driven completion and validation. Everything Hybris-specific
-- degrades to a no-op for non-Hybris XML files -- root_dir falls back to the
-- nearest .git (or the buffer's own directory), and before_init leaves
-- lemminx's settings untouched when no Hybris schema is found.
local scanner = require("LYRD.shared.hybris.scanner")

---@param bufnr integer
---@param on_dir fun(root: string)
local function root_dir(bufnr, on_dir)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	local start = (fname ~= "") and vim.fs.dirname(fname) or vim.fn.getcwd()
	local ext_root = scanner.find_extension_root(start)
	if ext_root then
		on_dir(ext_root)
		return
	end
	local git_root = vim.fs.root(bufnr, { ".git" })
	on_dir(git_root or start)
end

---@param params table
---@param config table
local function before_init(params, config)
	local root = params.rootPath
	if (not root or root == "") and params.workspaceFolders and params.workspaceFolders[1] then
		root = vim.uri_to_fname(params.workspaceFolders[1].uri)
	end
	if not root or root == "" then
		return
	end

	local associations = {}
	local function associate(basename, pattern)
		local xsd = scanner.find_schema(root, basename)
		if xsd then
			table.insert(associations, { systemId = xsd, pattern = pattern })
		end
	end

	associate("items.xsd", "**/*items.xml")
	associate("beans.xsd", "**/*beans.xml")
	associate("extensioninfo.xsd", "**/extensioninfo.xml")
	if #associations == 0 then
		return
	end

	config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
		xml = { fileAssociations = associations },
	})
end

return {
	cmd = { "lemminx" },
	filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
	single_file_support = true,
	root_dir = root_dir,
	settings = {
		xml = {
			format = { enabled = true },
			completion = { autoCloseTags = true },
			-- Lets XMLs that DO carry an xsi:schemaLocation (e.g. *-spring.xml)
			-- fetch their schema so completion works there too (cached after
			-- the first fetch); schema-less files are unaffected.
			downloadExternalResources = { enabled = true },
		},
	},
	before_init = before_init,
}
