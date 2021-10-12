return {
PlaceObj('ModItemCode', {
	'FileName', "Code/Script.lua",
}),
PlaceObj('ModItemOptionToggle', {
	'name', "Enable",
	'DisplayName', "Enable Mod",
	'Help', "Use to enable mod. If this is Off, this mod does nothing at all",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "UseDefaultIfNoNursery",
	'DisplayName', "Use default if no nursery",
	'Help', "Use default child birth function if no nursery found in city",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "PreventOverpopulation",
	'DisplayName', "Prevent Overpopulation",
	'Help', "On: Don't spawn child if they would be homeless once they grow up. Prevents overpopulation. Build more adult homes and nurseries if you want more children. | Off: Spawn child if there are any free nursery slots (even if there are no adult homes). Eventually leads to lots of homeless if birth rate is higher than death rate",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableLog",
	'DisplayName', "Enable logging",
	'Help', "Enable printing to console for debugging purposes. Should generally be turned off",
	'DefaultValue', false,
}),
}
