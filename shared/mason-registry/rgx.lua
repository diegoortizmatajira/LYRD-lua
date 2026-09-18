return {
	name = "rgx",
	description = "A regex debugger for the terminal — step-through execution, "
		.. "ReDoS analysis, 3 engines, code generation, and live stream filtering",
	homepage = "https://github.com/brevity1swos/rgx",
	licenses = { "MIT" },
	languages = { "Regex" },
	categories = { "TUI" },
	source = {
		id = "pkg:cargo/rgx-cli@0.14.2",
	},
	bin = {
		["rgx"] = "cargo:rgx",
	},
}
