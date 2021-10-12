return PlaceObj('ModDef', {
	'title', "[rcsh] QoL Stuff",
	'description', "See github.com/ryancsh/SurvivingMarsMods for more information.",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "rcsh_library",
			'title', "[rcsh] Library",
			'version_minor', 1,
		}),
	},
	'id', "rcsh_qol_stuff",
	'pops_desktop_uuid', "ff1a90dd-bc32-457e-88ee-8ab65e266b15",
	'pops_any_uuid', "08661b48-3eef-41d8-ab4a-57da75f8482c",
	'author', "ryancsh",
	'version_minor', 1,
	'version', 8,
	'lua_revision', 1007000,
	'saved_with_revision', 1008107,
	'code', {
		"Code/Script.lua",
	},
	'has_options', true,
	'saved', 1633348530,
})