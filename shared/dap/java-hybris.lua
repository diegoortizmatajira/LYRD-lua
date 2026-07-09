-- Registers the Java DAP adapter (via nvim-jdtls, bridging to the
-- java-debug-adapter Mason package already loaded into jdtls) and prepends
-- IntelliJ-style remote-attach configurations for a running Hybris server
-- (JDWP defaults to 8000 via `hybrisserver.sh debug`) and a generic Spring
-- Boot process (`-agentlib:jdwp=...` defaults to 5005).

local HYBRIS_PORT = 8000
local SPRING_PORT = 5005

local M = {
	hybris_port = HYBRIS_PORT,
	spring_port = SPRING_PORT,
}

---@return table[]
local function attach_configs()
	return {
		{
			type = "java",
			request = "attach",
			name = "Hybris: Attach to remote JVM (localhost:" .. HYBRIS_PORT .. ")",
			hostName = "127.0.0.1",
			port = HYBRIS_PORT,
		},
		{
			type = "java",
			request = "attach",
			name = "Spring: Attach to remote JVM (localhost:" .. SPRING_PORT .. ")",
			hostName = "127.0.0.1",
			port = SPRING_PORT,
		},
		{
			type = "java",
			request = "attach",
			name = "Attach to remote JVM (prompt host:port)",
			hostName = function()
				return vim.fn.input("Debug host [127.0.0.1]: ", "127.0.0.1")
			end,
			port = function()
				return tonumber(vim.fn.input("Debug port [" .. HYBRIS_PORT .. "]: ", tostring(HYBRIS_PORT)))
			end,
		},
	}
end

-- Idempotent: safe to call again (e.g. if the layer re-registers) without
-- duplicating the attach entries it previously inserted, and without
-- clobbering any unrelated dap.configurations.java entries (e.g. Maven/Gradle
-- launch configs, should those ever get added).
function M.setup()
	local ok_dap, dap = pcall(require, "dap")
	if not ok_dap then
		return
	end
	local ok_jdtls, jdtls = pcall(require, "jdtls")
	if not ok_jdtls then
		return
	end

	-- Registers dap.adapters.java, bridging DAP requests to the java-debug-adapter
	-- plugin already loaded into the running jdtls process (init_options.bundles).
	pcall(function()
		jdtls.setup_dap({ hotcodereplace = "auto" })
	end)

	local attach = attach_configs()
	dap.configurations.java = dap.configurations.java or {}
	local kept = {}
	for _, existing in ipairs(dap.configurations.java) do
		local is_ours = existing.request == "attach"
			and type(existing.name) == "string"
			and existing.name:find("Attach to remote JVM", 1, true)
		if not is_ours then
			table.insert(kept, existing)
		end
	end
	local merged = {}
	vim.list_extend(merged, attach)
	vim.list_extend(merged, kept)
	dap.configurations.java = merged
end

-- Directly starts a remote attach to the Hybris JDWP port, bypassing the
-- dap.configurations.java picker -- the common "attach to my running server"
-- shortcut.
function M.attach_hybris()
	local ok_dap, dap = pcall(require, "dap")
	if not ok_dap then
		return
	end
	dap.run({
		type = "java",
		request = "attach",
		name = "Hybris: Attach to remote JVM (localhost:" .. HYBRIS_PORT .. ")",
		hostName = "127.0.0.1",
		port = HYBRIS_PORT,
	})
end

return M
