return {
PlaceObj('ModItemCode', {
	'FileName', "Code/Script.lua",
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableMod",
	'DisplayName', "Enable Mod",
	'Help', "If this is Off, the entire mod does nothing. For this mod to do something, this setting has to be on in addition to the individual functionality setting.",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableDroneIdleRecharge",
	'DisplayName', "Drones go recharge when idle",
	'Help', "When a drone is idle and its battery is below the recharge threshold, the drone charges itself",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionNumber', {
	'name', "DroneIdleRechargeThreshold",
	'DisplayName', "Drone Recharge Idle Threshold",
	'Help', "Only trigger idle recharge if drone battery % is less than this value",
	'DefaultValue', 99,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableRocketAutoLand",
	'DisplayName', "Enable auto landing rockets",
	'Help', "If a rocket has the same name as a landing pad, it will automatically land on it. Names are compared after the following operations: (1) conversion to uppercase, and (2) all leading and trailing whitespace, punctuation and numbers are removed. So !1AB7#CD12 is considered the same as AB7#CD.",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableLandingPadAny",
	'DisplayName', "Enable auto landing for all rockets on 'ANY' pads",
	'Help', "If this setting is on, and a rocket can't find a pad matching its name, it will try to land on landing pads called 'ANY'.",
	'DefaultValue', true,
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableLandingPadAll",
	'DisplayName', "Enable auto landing for all rockets on all pads",
	'Help', "If this setting is on, and a rocket can't land on anything else it would prefer, it picks any available pad to land on",
}),
PlaceObj('ModItemOptionToggle', {
	'name', "EnableLog",
	'DisplayName', "Enable logging",
	'Help', "Enable printing to console for debugging purposes. Should generally be turned off",
}),
}
