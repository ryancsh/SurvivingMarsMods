return PlaceObj('ModDef', {
	'title', "[rcsh] Birth Control",
	'description', "See github.com/ryancsh/SurvivingMarsMods for more information.",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "rcsh_library",
			'title', "[rcsh] Library",
			'version_minor', 1,
			'required', false,
		}),
	},
	'id', "rcsh_birth_control",
	'pops_desktop_uuid', "f5a99176-ebf2-4c23-879f-7c32e773e4a5",
	'pops_any_uuid', "025a2cc5-23e7-40b0-96b8-c5ebc49e3f9e",
	'author', "ryancsh",
	'version_minor', 1,
	'version', 19,
	'lua_revision', 1007000,
	'saved_with_revision', 1008107,
	'code', {
		"Code/Script.lua",
	},
	'has_options', true,
	'saved', 1633271253,
})
