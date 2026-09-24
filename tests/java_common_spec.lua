local generator = require("LYRD.shared.java-common")

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

describe("java-common.get_package", function()
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

describe("java-common.get_runtimes", function()
	local scratch
	local ENV_KEYS = {
		"JAVA_HOME",
		"JDK_HOME",
		"JRE_HOME",
		"JAVA8_HOME",
		"JAVA11_HOME",
		"JAVA17_HOME",
		"JAVA21_HOME",
		"SDKMAN_DIR",
		"ASDF_DATA_DIR",
		"JABBA_HOME",
		"JENV_ROOT",
	}
	local original_env = {}

	-- Builds a fake JDK home (bin/java executable + a release file reporting
	-- JAVA_VERSION), so is_valid_java_home/java_version_from_release work
	-- against a real filesystem rather than mocking every vim.fn.* call.
	local function fake_jdk(path, version)
		vim.fn.mkdir(path .. "/bin", "p")
		local java_bin = path .. "/bin/java"
		vim.fn.writefile({ "#!/bin/sh", "exit 0" }, java_bin)
		vim.fn.system({ "chmod", "+x", java_bin })
		vim.fn.writefile({ 'JAVA_VERSION="' .. version .. '"' }, path .. "/release")
	end

	before_each(function()
		for _, key in ipairs(ENV_KEYS) do
			original_env[key] = vim.env[key]
		end
		scratch = vim.fn.tempname()
		vim.fn.mkdir(scratch, "p")
		-- get_runtimes() memoizes; force a fresh scan per test.
		generator.runtimes = nil
		-- Point the "installer" roots somewhere empty so only our fake JDKs
		-- (plus whatever hardcoded system paths genuinely exist) are found.
		vim.env.SDKMAN_DIR = scratch .. "/no-sdkman"
		vim.env.ASDF_DATA_DIR = scratch .. "/no-asdf"
		vim.env.JABBA_HOME = scratch .. "/no-jabba"
		vim.env.JENV_ROOT = scratch .. "/no-jenv"
		for _, key in ipairs({ "JDK_HOME", "JRE_HOME", "JAVA8_HOME", "JAVA11_HOME", "JAVA17_HOME" }) do
			vim.env[key] = nil
		end
	end)

	after_each(function()
		for _, key in ipairs(ENV_KEYS) do
			vim.env[key] = original_env[key]
		end
		vim.fn.delete(scratch, "rf")
		generator.runtimes = nil
	end)

	local function find_by_name(runtimes, name)
		for _, r in ipairs(runtimes) do
			if r.name == name then
				return r
			end
		end
		return nil
	end

	it("keeps the first runtime's plain name and suffixes a later collision with its source", function()
		local jdk_a = scratch .. "/jdk-a"
		local jdk_b = scratch .. "/jdk-b"
		fake_jdk(jdk_a, "21.0.1")
		fake_jdk(jdk_b, "21.0.5")
		vim.env.JAVA_HOME = jdk_a
		vim.env.JAVA21_HOME = jdk_b

		local runtimes = generator.get_runtimes()

		local first = find_by_name(runtimes, "JavaSE-21")
		assert.is_not_nil(first)
		assert.are.equal(vim.fn.fnamemodify(jdk_a, ":p"), first.path)
		assert.is_true(first.default)

		local second = find_by_name(runtimes, "JavaSE-21 (JAVA21_HOME)")
		assert.is_not_nil(second)
		assert.are.equal(vim.fn.fnamemodify(jdk_b, ":p"), second.path)
	end)

	it("never produces two runtimes with the same name", function()
		local jdk_a = scratch .. "/jdk-a"
		local jdk_b = scratch .. "/jdk-b"
		fake_jdk(jdk_a, "21.0.1")
		fake_jdk(jdk_b, "21.0.5")
		vim.env.JAVA_HOME = jdk_a
		vim.env.JAVA21_HOME = jdk_b

		local runtimes = generator.get_runtimes()

		local seen_names = {}
		for _, r in ipairs(runtimes) do
			assert.is_falsy(seen_names[r.name])
			seen_names[r.name] = true
		end
	end)
end)
