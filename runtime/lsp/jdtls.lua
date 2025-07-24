return {
	--    filetypes={}
	settings = {
		java = {
			jdt = {
				ls = {
					lombokSupport = {
						enabled = true,
					},
				},
			},
		},
	},
	handlers = {
		-- By assigning an empty function, you can remove the notifications
		-- printed to the cmd
		["$/progress"] = function(_, _, _) end,
	},
}
