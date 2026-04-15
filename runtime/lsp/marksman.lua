return {
	workspace_required = false,
	root_markers = {},
	-- Force single-file mode so Marksman never scans large/untrusted workspace trees.
	root_dir = function(_, on_dir)
		on_dir(nil)
	end,
}
