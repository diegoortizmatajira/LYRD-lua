local generator = require("LYRD.layers.lang.dotnet-generator")

-- Mock storage for vim.notify calls
local notify_calls = {}

-- Save originals
local orig_globpath = vim.fn.globpath
local orig_fnamemodify = vim.fn.fnamemodify
local orig_notify = vim.notify

--- Helper: set up mocks for vim.fn.globpath and vim.fn.fnamemodify using
--- a simulated filesystem rooted at `csproj_dir` with a .csproj named after the project.
--- @param csproj_dir string directory containing the .csproj file
--- @param project_name string project name (used as the .csproj filename stem)
local function mock_filesystem(csproj_dir, project_name)
	notify_calls = {}

	vim.notify = function(msg, level)
		table.insert(notify_calls, { msg = msg, level = level })
	end

	-- Simulate globpath: return a .csproj only when searching in csproj_dir
	vim.fn.globpath = function(path, pattern, _, _)
		if path == csproj_dir and pattern == "*.csproj" then
			return { csproj_dir .. "/" .. project_name .. ".csproj" }
		end
		return {}
	end

	-- Use a simple path implementation for fnamemodify
	vim.fn.fnamemodify = function(path, modifier)
		if modifier == ":h" then
			-- Return parent directory
			local parent = path:match("^(.+)/[^/]+$")
			return parent or path
		elseif modifier == ":t:r" then
			-- Return filename without extension
			local filename = path:match("([^/]+)$") or path
			return filename:match("^(.+)%..+$") or filename
		end
		return orig_fnamemodify(path, modifier)
	end
end

--- Helper: restore all mocks to originals
local function restore_mocks()
	vim.fn.globpath = orig_globpath
	vim.fn.fnamemodify = orig_fnamemodify
	vim.notify = orig_notify
end

describe("dotnet-generator.get_namespace", function()
	after_each(function()
		restore_mocks()
	end)

	it("returns namespace matching project name for a file at csproj root", function()
		mock_filesystem("/home/user/projects/MyApp", "MyApp")

		local result = generator.get_namespace("/home/user/projects/MyApp/Program.cs")

		assert.are.equal("MyApp", result)
	end)

	it("appends subdirectory path as dotted namespace segments", function()
		mock_filesystem("/home/user/projects/MyApp", "MyApp")

		local result = generator.get_namespace("/home/user/projects/MyApp/Models/Data/Entity.cs")

		assert.are.equal("MyApp.Models.Data", result)
	end)

	it("replaces hyphens with underscores in the namespace", function()
		mock_filesystem("/home/user/projects/My-App", "My-App")

		local result = generator.get_namespace("/home/user/projects/My-App/My-Module/File.cs")

		assert.are.equal("My_App.My_Module", result)
	end)

	it("replaces backslashes with dots", function()
		mock_filesystem("/home/user/projects/MyApp", "MyApp")

		-- Simulate a path that contains backslashes (Windows-style mixed path)
		-- We need to mock fnamemodify to produce a result with backslashes
		local orig_mock_fnamemodify = vim.fn.fnamemodify
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" and path == "/home/user/projects/MyApp/Sub\\Dir\\File.cs" then
				return "/home/user/projects/MyApp/Sub\\Dir"
			end
			return orig_mock_fnamemodify(path, modifier)
		end

		local result = generator.get_namespace("/home/user/projects/MyApp/Sub\\Dir\\File.cs")

		assert.are.equal("MyApp.Sub.Dir", result)
	end)

	it("returns default_namespace when no csproj is found", function()
		notify_calls = {}
		vim.notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end
		-- globpath never returns a csproj
		vim.fn.globpath = function(_, _, _, _)
			return {}
		end
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				local parent = path:match("^(.+)/[^/]+$")
				return parent or path
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_namespace("/some/deep/path/without/project/File.cs")

		assert.are.equal("default_namespace", result)
		assert.are.equal(1, #notify_calls)
		assert.are.equal(vim.log.levels.ERROR, notify_calls[1].level)
		assert.truthy(notify_calls[1].msg:find("No C# Project file found"))
	end)

	it("finds csproj in a parent directory", function()
		mock_filesystem("/home/user/projects/MyApp", "MyApp")

		local result = generator.get_namespace("/home/user/projects/MyApp/Services/Internal/Handler.cs")

		assert.are.equal("MyApp.Services.Internal", result)
	end)

	it("sends an INFO notification with the resolved namespace", function()
		mock_filesystem("/home/user/projects/MyApp", "MyApp")

		generator.get_namespace("/home/user/projects/MyApp/Controllers/HomeController.cs")

		local info_notifications = vim.tbl_filter(function(n)
			return n.level == vim.log.levels.INFO
		end, notify_calls)
		assert.are.equal(1, #info_notifications)
		assert.truthy(info_notifications[1].msg:find("MyApp.Controllers"))
	end)

	it("handles file directly in the csproj directory with no subdirectories", function()
		mock_filesystem("/home/user/src/WebApi", "WebApi")

		local result = generator.get_namespace("/home/user/src/WebApi/Startup.cs")

		assert.are.equal("WebApi", result)
	end)

	it("handles project names with multiple hyphens", function()
		mock_filesystem("/home/user/src/my-cool-app", "my-cool-app")

		local result = generator.get_namespace("/home/user/src/my-cool-app/Some-Folder/File.cs")

		assert.are.equal("my_cool_app.Some_Folder", result)
	end)
end)
