-- See LICENSE for terms

-- IMPROVEMENT: only process one hub per hour (for large colonies)
-- IMPROVEMENT: maybe only warn for drone heavy usage if no drone prefabs
--function DroneControl:UpdateHeavyLoadNotification()

-- IMPROVEMENT: function DroneControl:GatherOrphanedDrones()
--function DroneControl:GatherOrphanedDrones()

--DroneControl:ForEachDrone(func, ...)
--function DroneControl:CanHaveMoreDrones()

local mod	--enable mod or not
local dbg	--enable console logging
local lib	--library

local vars = {}	--mod data
local thr = nil

-- 	### MOD OPTIONS ###
local function ModOptions()
  -- enable/disable mod
  mod = CurrentModOptions:GetProperty("Enable")
  dbg = mod and CurrentModOptions:GetProperty("EnableLog") and rcsh_library and true or false
  if not mod then
    if thr then endThread() end
    return
  end
  lib = rcsh_library

  -- disable if less than specified number of drone hubs
  vars.DisableIfDroneHubLessThan = CurrentModOptions:GetProperty("DisableIfDroneHubLessThan")

  -- minimum drones to assign to each
  vars.MinDroneHub = CurrentModOptions:GetProperty("MinDroneHub")
  vars.MinCommander = CurrentModOptions:GetProperty("MinCommander")

  -- allow assigning drones to each category
  -- even if false, the drone hub will still maintain the minimum drones defined above
  vars.AssignDroneHub = CurrentModOptions:GetProperty("AssignDroneHub")
  vars.AssignCommander = CurrentModOptions:GetProperty("AssignCommander")

  -- removes all drones assigned to rockets
  vars.RemoveRocket = CurrentModOptions:GetProperty("RemoveRocket")

  -- Assign drones in groups of DroneGroupSize
  vars.DroneGroupSize = CurrentModOptions:GetProperty("DroneGroupSize")

  -- Reassign drones every X workshifts.
  vars.DroneHoursBetweenAssign = CurrentModOptions:GetProperty("DroneHoursBetweenAssign")
  -- INTERNAL: DroneHourCount tracks number of hours elapsed since last drone reassignment
  vars.DroneHourCount = 0

  -- Consider drone hub busy if less than BusyThreshold idle drones during low activity periods
  vars.BusyThreshold = CurrentModOptions:GetProperty("BusyThreshold")
  -- INTERNAL: Dronehub is considered idle if more than (vars.BusyThreshold + 3*DroneGroupSize)
  vars.IdleThreshold = vars.BusyThreshold + 2*vars.DroneGroupSize

  -- Whether mod should order prefabs automatically
  vars.RequestDronePrefabs = CurrentModOptions:GetProperty("RequestDronePrefabs")
  -- The amount of spare mats should be available for automatic prefab ordering.
  vars.DroneSpareResource = CurrentModOptions:GetProperty("DroneSpareResource")

  if dbg then
    local pre = lib.make_prefix(CurrentModId, "ModOptions")
    lib.logtable(pre, vars)
  end

  startThread()
end

OnMsg.ModsReloaded = ModOptions
function OnMsg.ApplyModOptions(id) if id == CurrentModId then ModOptions() end end

-- 	### DRONE CONTROL ###
local Commanders = {}
local DroneHubs = {}

-- Assigns 'count' number of drones to 'hub'.
-- If 'count' is +ve, add drones, if 'count' is -ve remove drones, do nothing if zero
-- Do nothing if not enough drone prefabs.
local function assignDrones(hub, count)
  if dbg then
    assert(mod)
    local pre = lib.make_prefix(CurrentModId, "assignDrones")
    lib.log(pre, "hub_entity", hub.entity, "drones_count", count)
  end

  while count > 0 do
    hub:UseDronePrefab()
    count = count - 1
  end
  while count < 0 do
    hub:ConvertDroneToPrefab()
    count = count + 1
  end
end

-- Finds all hubs in city and adds them to list if of specified type and notes their max idle drone count
local function updateIdle(city)
  -- update idle drone counts for RC Commanders and DroneHubs
  for _, v in ipairs(city.labels.RCRover) do
    Commanders[v] = Max(Commanders[v] or 0, v:GetIdleDronesCount())
  end
  for _, v in ipairs(city.labels.DroneHub) do
    DroneHubs[v] = Max(DroneHubs[v] or 0, v:GetIdleDronesCount())
  end

  -- dbg stuff
  if dbg then
    assert(mod)
    local pre = lib.make_prefix(CurrentModId, "updateIdle")
    lib.log(pre, "#DroneHubs", lib.table_count_elements(DroneHubs), "#Commanders", lib.table_count_elements(Commanders))
  end
end

local function calculateAdjustment(assign_enabled, curr_drones, min_drones, max_idle)
  local adjust_by = 0 	--adjust hub drone count by
  if assign_enabled then
    adjust_by = (max_idle > vars.IdleThreshold and -vars.DroneGroupSize)
                or (max_idle < vars.BusyThreshold and vars.DroneGroupSize)
                or adjust_by
    adjust_by = Max(min_drones - curr_drones, adjust_by) --respect min_drones
  else
    adjust_by = min_drones - curr_drones
  end

  if dbg then
    assert(mod)
    local pre = lib.make_prefix(CurrentModId, "adjustHubs")
    lib.log(pre, "assign enabled", assign_enabled, "curr_drones", curr_drones, "min_drones", min_drones, "max_idle", max_idle, "adjust_by", adjust_by)
  end

  return adjust_by
end

-- Adjusts the number of drones at each hub in Hubs
-- if assign_drones is false, make sure hub has 'min_drones' number of drones
-- if assign_drones is true, adjust the number of drones by obj.DroneGroupSize
-- 	so that (vars.BusyThreshold <= idle_drones <= vars.IdleThreshold)
-- 	and (hub_drone_count >= min_drones)
local function adjustHubs(city)
  local pre
  if dbg then
    assert(mod)
    pre = lib.make_prefix(CurrentModId, "adjustHubs")
    lib.log(pre)
  end

  -- remove all drones assigned to rockets if mod option is enabled
  if vars.RemoveRocket then
    for _, v in ipairs(city.labels.SupplyRocket) do
      if v:IsRocketStatus("landed") and v:GetDronesCount() > 0 then
        if dbg then lib.log(pre, "rocket_name", v.name, "drones_removing", v:GetDronesCount()) end
        assignDrones(v, -v:GetDronesCount())
      end
    end
  end

  -- adjust Commanders
  local to_remove = {} 	--will remove any invalid commanders after loop
  for hub, max_idle in pairs(Commanders) do
    if not IsValid(hub) then table.insert(to_remove, hub)
    else
      local adjust_by = calculateAdjustment(vars.AssignCommander, hub:GetDronesCount(), vars.MinCommander, max_idle)
      assignDrones(hub, adjust_by)
      Commanders[hub] = 0 	--reset max idle drones
    end
  end
  lib.table_remove_keys(Commanders, to_remove)

  -- adjust DroneHubs
  to_remove = {}
  for hub, max_idle in pairs(DroneHubs) do
    if not IsValid(hub) then table.insert(to_remove, hub)
    else
      local adjust_by = calculateAdjustment(vars.AssignDroneHub, hub:GetDronesCount(), vars.MinDroneHub, max_idle)
      assignDrones(hub, adjust_by)
      DroneHubs[hub] = 0 	--reset max idle drones
    end
  end
  lib.table_remove_keys(DroneHubs, to_remove)


  if dbg then
    assert(mod)
    lib.log(pre, "#DroneHubs", lib.table_count_elements(DroneHubs), "#Commanders", lib.table_count_elements(Commanders))
  end
end

local function requestDronePrefabs(city)
  -- setup
  if not (mod and vars.RequestDronePrefabs) then return end
  local pre
  if dbg then
    pre = lib.make_prefix(CurrentModId, "requestDronePrefabs")
    lib.log(pre, "DroneFactories", (city.labels.DroneFactory and #city.labels.DroneFactory) or 0, "Prefabs_available", city.drone_prefabs, "DroneSpareResource", vars.DroneSpareResource)
  end

  -- Skip if we have enough drones already
  local drone_order = #city.labels.DroneHub * vars.DroneGroupSize
  local already_have = city.drone_prefabs
  if drone_order < already_have then
    if dbg then lib.log(pre, "drone_order", drone_order, "already_have", already_have, "have enough drones in city") end
    return
  end

  -- No point ordering prefabs if no working drone factories
  local working_factories = city.labels.DroneFactory or {}
  if #working_factories < 1 then
    if dbg then lib.log(pre, "no working drone factories") end
    return
  end

  -- Count ordered drones
  for _, factory in ipairs(working_factories) do
    already_have = already_have + factory.drones_in_construction
  end

  -- Skip if we ordered enough
  if drone_order < already_have then
    if dbg then lib.log(pre, "drone_order", drone_order, "prefabs_ordered", already_have, "already have enough prefabs available or ordered") end
    return
  end

  -- Order extra since we are ordering anyway. (for less performance impact)
  drone_order = drone_order * 2

  -- Check spare resources before ordering more drones
  local resource_type = DroneFactory.GetConstructResource() --resource type to build drones (can change)
  local drone_cost = DroneFactory.GetConstructDroneCost()   --resource cost to build a drone (usually 1)
  local resource_count = 0                                  --amount of resources in storage
  for _, storage in ipairs(city.labels.Storages) do
    if storage:IsKindOf("StorageDepot") or storage:IsKindOf("MechanizedDepot") then
      resource_count = resource_count + storage:GetStoredAmount(resource_type)
    end
  end

  -- Find largest possible order based on resources available
  local max_order = Max((resource_count - drone_cost * vars.DroneSpareResource )/drone_cost, 0)
  if dbg then
    lib.log(pre, "resource_type", resource_type, "resource_count", resource_count, "drone_cost", drone_cost, "DroneSpareResource", vars.DroneSpareResource, "max_order", max_order, "drone_order", drone_order)
  end

  -- Skip drone order if we don't have enough resources
  drone_order = Min(drone_order, max_order)
  if drone_order < already_have then
    if dbg then lib.log("not enough spare resources, skipping drone order") end
    return
  end

  -- Distribute orders between working factories (not true evening out, but should be okay)
  local order_per_factory = (drone_order - already_have) / #working_factories
  for _, factory in ipairs(working_factories) do
    factory:ConstructDrone(order_per_factory) -- NOTE: might be float
  end

  -- dbg stuff
  if dbg then
    local total_order = 0
    for _, factory in ipairs(working_factories) do
      total_order = total_order + factory.drones_in_construction
    end
    lib.log(pre, "total_order", total_order)
  end
end

local function startThread()
  if thr then return end
  thr = CreateGameTimeThread(
    function(){
      while true do
        if not mod then return end
        local pre
        if dbg then
          pre = lib.make_prefix(CurrentModId, "OnMsg.NewHour")
          lib.log(pre)
        end

        local city = UICity
        updateIdle(UICity)	--count number of idle drones
        if dbg then lib.log(pre, "#city.labels.DroneHub", #city.labels.DroneHub) end

        -- Don't do anything if we have less than user defined number of dronehubs.
        if #city.labels.DroneHub < vars.DisableIfDroneHubLessThan then return end

        -- If not yet time to reassign drones, don't do anything
        if vars.DroneHourCount < vars.DroneHoursBetweenAssign then
          vars.DroneHourCount = vars.DroneHourCount + 1
          if dbg then lib.log(pre, "DroneHourCount", vars.DroneHourCount, "Assignment cycle not over yet, not assigning any drones") end
          return
        end

        -- reset count since we are updating hubs
        vars.DroneHourCount = 0

        if dbg then lib.log(pre, "assigning drones to hubs") end
        adjustHubs(UICity)

        if dbg then lib.log(pre, "requesting drone prefabs") end
        requestDronePrefabs(city)
      end
    }
  )
end

local function endThread()
  if thr then
    DeleteThread(thr)
    thr = nil
  end
end
