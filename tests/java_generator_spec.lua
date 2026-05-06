local generator = require("LYRD.layers.lang.java-generator")

-- Save originals
local orig_fnamemodify = vim.fn.fnamemodify
local orig_notify = vim.notify

local notify_calls = {}

local function mock_notify()
	notify_calls = {}
	vim.notify = function(msg, level)
		table.insert(notify_calls, { msg = msg, level = level })
	end
end

local function restore_mocks()
	vim.fn.fnamemodify = orig_fnamemodify
	vim.notify = orig_notify
end

describe("java-generator.get_package", function()
	after_each(function()
		restore_mocks()
	end)

	it("returns the package path relative to the java/ directory", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/home/user/project/src/main/java/com/example/service"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/home/user/project/src/main/java/com/example/service/MyService.java")

		assert.are.equal("com.example.service", result)
	end)

	it("returns a single-segment package for a file directly under java/", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/app"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/main/java/app/Main.java")

		assert.are.equal("app", result)
	end)

	it("replaces hyphens with underscores", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/com/my-company/my-service"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/main/java/com/my-company/my-service/App.java")

		assert.are.equal("com.my_company.my_service", result)
	end)

	it("replaces backslashes with dots for Windows-style paths", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/com\\example\\model"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/main/java/com\\example\\model/Entity.java")

		assert.are.equal("com.example.model", result)
	end)

	it("returns default_package when no java/ directory is found in the path", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/kotlin/com/example"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/main/kotlin/com/example/Main.java")

		assert.are.equal("default_package", result)
		assert.are.equal(1, #notify_calls)
		assert.are.equal(vim.log.levels.ERROR, notify_calls[1].level)
		assert.truthy(notify_calls[1].msg:find("No java folder found"))
	end)

	it("sends an INFO notification with the resolved package", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/org/acme/api"
			end
			return orig_fnamemodify(path, modifier)
		end

		generator.get_package("/project/src/main/java/org/acme/api/Controller.java")

		local info = vim.tbl_filter(function(n)
			return n.level == vim.log.levels.INFO
		end, notify_calls)
		assert.are.equal(1, #info)
		assert.truthy(info[1].msg:find("org.acme.api"))
	end)

	it("handles deeply nested package paths", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/com/example/internal/domain/model/entity"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result =
			generator.get_package("/project/src/main/java/com/example/internal/domain/model/entity/User.java")

		assert.are.equal("com.example.internal.domain.model.entity", result)
	end)

	it("uses the first java/ segment when the path contains multiple", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/main/java/com/java/util"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/main/java/com/java/util/Helper.java")

		assert.are.equal("com.java.util", result)
	end)

	it("handles test source sets with java/ directory", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/project/src/test/java/com/example/service"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/project/src/test/java/com/example/service/MyServiceTest.java")

		assert.are.equal("com.example.service", result)
	end)
end)
