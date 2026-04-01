---@brief
---
--- https://github.com/genericptr/pascal-language-server
---
--- An LSP server implementation for Pascal variants that are supported by Free Pascal, including Object Pascal. It uses CodeTools from Lazarus as backend.
---
--- First set `cmd` to the Pascal lsp binary.
---
--- Customization options are passed to pasls as environment variables for example in your `.bashrc`:
--- ```bash
--- export FPCDIR='/usr/lib/fpc/src'      # FPC source directory (This is the only required option for the server to work).
--- export PP='/usr/lib/fpc/3.2.2/ppcx64' # Path to the Free Pascal compiler executable.
--- export LAZARUSDIR='/usr/lib/lazarus'  # Path to the Lazarus sources.
--- export FPCTARGET=''                   # Target operating system for cross compiling.
--- export FPCTARGETCPU='x86_64'          # Target CPU for cross compiling.
--- ```

local util = require("lspconfig.util")

local required_env_vars = {
	{ name = "FPCDIR", description = "FPC source directory" },
	{ name = "PP", description = "Path to the Free Pascal compiler executable" },
	{ name = "LAZARUSDIR", description = "Path to the Lazarus sources" },
	{ name = "FPCTARGET", description = "Target operating system for cross compiling" },
	{ name = "FPCTARGETCPU", description = "Target CPU for cross compiling" },
}

local function validate_required_env_vars()
	local missing_vars = {}
	for _, var in ipairs(required_env_vars) do
		if not os.getenv(var.name) then
			table.insert(missing_vars, string.format(" - %s: %s", var.name, var.description))
		end
	end
	if #missing_vars > 0 then
		vim.notify(
			"Pascal LSP: Missing required environment variables: \n" .. table.concat(missing_vars, "\n"),
			vim.log.levels.WARN
		)
	end
end

---@type vim.lsp.Config
return {
	cmd = { "pasls" },
	filetypes = { "pascal" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		on_dir(util.root_pattern("*.lpi", "*.lpk", ".git")(fname))
	end,
	on_attach = function()
		validate_required_env_vars()
	end,
}
