return {
	name = "pascal-language-server",
	description = "Pascal Language Server",
	homepage = "https://github.com/Axiomworks/pascal-language-server-isopod",
	licenses = { "Apache-2.0" },
	languages = { "Pascal" },
	categories = { "LSP" },
	source = {
		id = "pkg:github/castle-engine/pascal-language-server@master",
		build = {
			run = "git submodule update --init --recursive && cd server && lazbuild pasls.lpi",
		},
	},
	bin = {
		["pasls"] = "exec:server/pasls",
	},
}
