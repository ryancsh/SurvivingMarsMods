return PlaceObj('ModDef', {
	'title', "[rcsh] Drone Control",
	'description', "See github.com/ryancsh/SurvivingMarsMods for more information.",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "rcsh_library",
			'title', "[rcsh] Library",
			'version_minor', 1,
			'required', true,
		}),
	},
	'id', "rcsh_drone_control",
	'pops_desktop_uuid', "56c23360-0541-48ce-8f66-f5dd2fbe2ba1",
	'pops_any_uuid', "ebb39322-0869-472f-95f2-db43daf0818a",
	'author', "ryancsh",
	'version_minor', 1,
	'version', 15,
	'lua_revision', 1007000,
	'saved_with_revision', 1008107,
	'code', {
		"Code/Script.lua",
	},
	'has_options', true,
	'saved', 1633273431,
})
