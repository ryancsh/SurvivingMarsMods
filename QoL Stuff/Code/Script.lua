-- See LICENSE for terms

-- IMPROVEMENT: rocket auto land
-- don't spawn more than one thread

-- setup stuff
local mod       --enable mod
local dbg       --enable debug
local lib       --library
local opt = {}  --other mod options
local orig_DroneSetCommand = Drone.SetCommand
local thr = {}

-- HELPER: fired when settings are changed/init
local function ModOptions()
	mod = CurrentModOptions:GetProperty("EnableMod")
	dbg = mod and CurrentModOptions:GetProperty("EnableLog") and rcsh_library and true or false

	if not mod then return end
	lib = rcsh_library
	local pre = lib.make_prefix(CurrentModId, "ModOptions")
	if dbg then lib.log(pre) end

	-- Drone Recharge When Idle
	opt.EnableDroneIdleRecharge = CurrentModOptions:GetProperty("EnableDroneIdleRecharge")
	if opt.EnableDroneIdleRecharge then
		opt.DroneIdleRechargeThreshold = CurrentModOptions:GetProperty("DroneIdleRechargeThreshold")
	end

	-- Rocket Auto Land
	opt.EnableRocketAutoLand = CurrentModOptions:GetProperty("EnableRocketAutoLand")
	if opt.EnableRocketAutoLand then
		opt.EnableLandingPadAny = CurrentModOptions:GetProperty("EnableLandingPadAny")
		opt.EnableLandingPadAll = CurrentModOptions:GetProperty("EnableLandingPadAll")
	end

	if dbg then lib.logtable(pre, opt) end
end

-- load default/saved settings
OnMsg.ModsReloaded = ModOptions

-- fired when option is changed
function OnMsg.ApplyModOptions(id)
	if id == CurrentModId then ModOptions() end
end

-- ### ROCKET AUTO LAND ###
local function standardize_name(s)
	local pre = lib.make_prefix(CurrentModId, "standardize_name")
	if dbg then assert(type(s) == "string" and lib and lib.string_filter) end
	local result = string.upper(lib.string_filter(s , "[^%s%d%p]+.*[^%s%d%p]+"))
	-- if dbg then lib.log(pre, "initial_string", s, "filtered_string", result) end
	return result
end

local function find_suitable_pad(rocket)
	local pre = lib.make_prefix(CurrentModId, "find_suitable_pad")
	if dbg then
		assert(mod and opt.EnableRocketAutoLand)
		assert(rocket and IsValid(rocket))
		lib.log(pre, "rocket", rocket.name, "standardized_name", standardize_name(rocket.name), "#pads", #rocket.city.labels.LandingPad)
	end

	local rocket_name = standardize_name(rocket.name)
	local best_pad = nil   --best pad to land on
	local is_any = false   --is an ANY pad
	for _, pad in ipairs(rocket.city.labels.LandingPad) do
		if not pad:HasRocket() then
			local pad_name = standardize_name(pad.name)
			if dbg then lib.log(pre, "pad", pad.name, "standardized_name", pad_name) end
			if pad_name == rocket_name then	--perfect filtered_name match
				best_pad = pad
				break
			elseif opt.EnableLandingPadAny and not is_any and pad_name == "ANY" then --find an ANY pad
				best_pad = pad
				is_any = true
			elseif opt.EnableLandingPadAll and not best_pad then --fallback to everything
				best_pad = pad
			end
		end
	end
	if dbg then
		lib.log(pre, "rocket", rocket.name)
		if best_pad then
			lib.log("best_pad", best_pad.name, "is_any", is_any)
		else
			lib.log("no pad found")
		end
	end
	return best_pad
end

local function try_land(rocket)
	local pre = lib.make_prefix(CurrentModId, "try_land")
	if rocket.command == "WaitInOrbit" and rocket:IsFlightPermitted() then
		local found_pad = find_suitable_pad(rocket)
		if found_pad then
			if dbg then lib.log(pre, "rocket", rocket.name, "found_pad", found_pad.name) end
			local site = PlaceBuilding("RocketLandingSite")
			site:SetPos(found_pad:GetPos())
			site:SetAngle(found_pad:GetAngle())
			site.landing_pad = found_pad
			rocket:SetCommand("LandOnMars", site)
			if dbg then lib.log(pre, "rocket", rocket.name, "landing") end
		else
			if dbg then lib.log(pre, "rocket", rocket.name, "no suitable landing pad found") end
		end
	end
end

local DroneGoHome
function OnMsg.Autorun()
	if not DroneGoHome then DroneGoHome = Drone.GoHome end
	function Drone:GoHome(...)
		if mod and opt.EnableDroneIdleRecharge and self:GetBatteryProgress() < opt.DroneIdleRechargeThreshold then
			if dbg then
				local pre = lib.make_prefix(CurrentModId, "Drone:SetCommand")
				lib.log(pre, "Drone", self, "recharge_threshold", opt.DroneIdleRechargeThreshold, "battery-level", self:GetBatteryProgress(), "recharging")
			end
			self:SetCommand("EmergencyPower")
		else
			return DroneGoHome(self, ...)
		end
	end

	function OnMsg.RocketStatusUpdate(rocket, status)
		if status == "in orbit" then
			local thread = CreateGameTimeThread(
				function(...)
					while true do
						if not IsValid(rocket) or not rocket:IsRocketStatus("in orbit") then
							local thread = CurrentThread()
							thr[thread] = nil
							--Halt()
							return
						end
						try_land(rocket)
						WaitMsg("NewHour")
					end
				end, rocket
			)
			thr[thread] = thread
		end
	end
end
