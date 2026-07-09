-- Wraps `git format-patch`/`git apply`/`git am` for exporting and importing
-- commit patches. All commands run via vim.fn.system with argument-list form
-- (never a formatted shell string), so paths, refs, and counts can never be
-- interpreted by the shell -- and vim.v.shell_error is checked after every
-- call so failures are reported instead of silently returning empty output.

local M = {}

--- Resolves the upstream tracking ref (e.g. "origin/develop") for the current branch.
---@return string? ref
---@return string? err Error output when no upstream is configured.
local function get_upstream_ref()
	local output = vim.fn.system({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}" })
	if vim.v.shell_error ~= 0 then
		return nil, output
	end
	return vim.trim(output)
end

--- Exports the last `last_n_commits` commits as patch files.
---
--- Creates `output_dir` if it doesn't exist yet, since `git format-patch -o`
--- expects the directory to already be there.
---@param last_n_commits number Number of most recent commits to export (must be a positive integer).
---@param output_dir string Directory to write the `.patch` files into.
---@return string? output List of created patch file paths (one per line), or nil on failure.
function M.produce_patches(last_n_commits, output_dir)
	local count = math.floor(last_n_commits or 0)
	if count <= 0 then
		vim.notify("git-patch: last_n_commits must be a positive number", vim.log.levels.ERROR)
		return nil
	end

	vim.fn.mkdir(output_dir, "p")

	local output = vim.fn.system({ "git", "format-patch", "-" .. count, "-o", output_dir })
	if vim.v.shell_error ~= 0 then
		vim.notify("git-patch: failed to produce patches:\n" .. output, vim.log.levels.ERROR)
		return nil
	end
	return output
end

--- Exports commits reachable from HEAD but not yet on `base_ref` as patch files.
---
--- Creates `output_dir` if it doesn't exist yet, for the same reason as `produce_patches`.
---@param output_dir string Directory to write the `.patch` files into.
---@param base_ref string? Ref to diff against (default: the current branch's upstream, e.g. "origin/<branch>").
---@return string? output List of created patch file paths (one per line), or nil on failure.
function M.produce_patches_for_unpushed_commits(output_dir, base_ref)
	if not base_ref then
		local upstream, err = get_upstream_ref()
		if not upstream then
			vim.notify("git-patch: current branch has no upstream configured:\n" .. err, vim.log.levels.ERROR)
			return nil
		end
		base_ref = upstream
	end

	vim.fn.mkdir(output_dir, "p")

	local output = vim.fn.system({ "git", "format-patch", base_ref .. "..HEAD", "-o", output_dir })
	if vim.v.shell_error ~= 0 then
		vim.notify("git-patch: failed to produce patches:\n" .. output, vim.log.levels.ERROR)
		return nil
	end
	return output
end

--- Applies a single patch file to the working tree via `git apply`.
---@param patch_file string Path to the `.patch` file to apply.
---@return string? output Command output, or nil if the file is missing or the apply failed.
function M.apply_patch(patch_file)
	if vim.fn.filereadable(patch_file) ~= 1 then
		vim.notify("git-patch: patch file not found: " .. patch_file, vim.log.levels.ERROR)
		return nil
	end

	local output = vim.fn.system({ "git", "apply", patch_file })
	if vim.v.shell_error ~= 0 then
		vim.notify("git-patch: failed to apply patch:\n" .. output, vim.log.levels.ERROR)
		return nil
	end
	return output
end

--- Applies every `.patch` file in `patch_dir` as commits via `git am`.
---
--- The file list is resolved with vim.fn.glob rather than a shell glob, so a
--- directory with no matching patches is caught up front instead of passing
--- `git am` a literal, unexpanded `*.patch` argument.
---@param patch_dir string Directory containing `.patch` files, applied in name order.
---@return string? output Command output, or nil if there was nothing to apply or the apply failed.
function M.apply_patches(patch_dir)
	if vim.fn.isdirectory(patch_dir) ~= 1 then
		vim.notify("git-patch: patch directory not found: " .. patch_dir, vim.log.levels.ERROR)
		return nil
	end

	local patches = vim.fn.glob(patch_dir .. "/*.patch", false, true)
	if #patches == 0 then
		vim.notify("git-patch: no .patch files found in " .. patch_dir, vim.log.levels.WARN)
		return nil
	end

	local cmd = { "git", "am" }
	vim.list_extend(cmd, patches)

	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("git-patch: failed to apply patches:\n" .. output, vim.log.levels.ERROR)
		return nil
	end
	return output
end

return M
