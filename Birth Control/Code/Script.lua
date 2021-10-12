-- See LICENSE for terms

-- IMPROVEMENT: rocket auto land
-- IMPROVEMENT: add readme.md


local mod	--enable mod or not
local dbg	--enable console logging
local lib	--library

local opt = {}             -- options
local orig_DomeSpawnChild  -- original function Dome.SpawnChild
local pending_births = {} -- insert {city, args}
local dreamer
local thr = nil            -- thread that handles spawning children

-- HELPER: fired when settings are changed/init
local function ModOptions()
  -- enable/disable mod
  mod = CurrentModOptions:GetProperty("Enable")
  dbg = mod and CurrentModOptions:GetProperty("EnableLog") and rcsh_library and true or false
  if not mod then
    if thr then endThread() end
    return
  end
  lib = rcsh_library

  -- if no nurseries globally, use default child spawning function
  opt.UseDefaultIfNoNursery = CurrentModOptions:GetProperty("UseDefaultIfNoNursery")

  -- make sure there won't be homeless adults when children grow up
  opt.PreventOverpopulation = CurrentModOptions:GetProperty("PreventOverpopulation")

  if dbg then
    local pre = lib.make_prefix(CurrentModId, "ModOptions")
    assert (not opt.UseDefaultIfNoNursery and opt.BirthControlGlobal and opt.PreventOverpopulation and true)
    lib.logtable(pre, opt)
  end

  startThread()
end

OnMsg.ModsReloaded = ModOptions
function OnMsg.ApplyModOptions(id) if id == CurrentModId then ModOptions() end end

local function getStats(city)
  local cfadult = 0    -- city free adult slots
  local cfchild = 0    -- city free child slots
  local cochild = 0    -- city occupied child slots
  local domes = {}     -- list all nurseries
  for _, dome in ipairs(city.labels.Dome) do
    cochild = cochild + (city.labels.Child and #city.labels.Child or 0)
    if dome.accept_colonists and dome.allow_birth then
      cfadult = cfadult + dome:GetFreeLivingSpace(false)
      dfchild = dome:GetFreeLivingSpace(true) - dome:GetFreeLivingSpace(false)
      if dfchild > 0 then
        cfchild = cfchild + dfchild
        table.insert(domes)
      end
    end
    -- WaitMsg("NewHour")   --process one nursery per hour
  end

  local max_births = opt.PreventOverpopulation and cfchild or Min(cfadult - cochild, cfchild)
  return domes, max_births
end

local function startThread()
  if thr == nil then
    thr = CreateGameTimeThread(
      function ()
        while true do
          for city, list_of_births in pairs(pending_births or {}) do
            if city and #list_of_births > 0 and IsValid(city) then
              local domes, max_births = getStats(city)
              for _, dome in ipairs(domes) do
                local dfchild = dome:GetFreeLivingSpace(true) - dome:GetFreeLivingSpace(false)
                local iterations = Min(dfchild, max_births)
                while iterations > 0 and #list_of_births > 0 do
                  orig_DomeSpawnChild(dome, table.unpack(list_of_births[1]))
                  table.remove(list_of_births, 1)
                  iterations = iterations - 1
                end
                max_births = max_births - iterations
                WaitMsg("NewHour")
                if #list_of_births < 1 or max_births < 1 then break end
              end
            end   -- if num_births > 0
          end   -- for each city
          WaitMsg("NewHour")
        end   --while true
      end
    )
  end
end

local function endThread()
  if thr then
    DeleteThread(thr)
    thr = nil
  end
end

function OnMsg.Autorun()
  startThread()

  if not orig_DomeSpawnChild then
    orig_DomeSpawnChild = Dome.SpawnChild
    function Dome:SpawnChild(...)
      local num_nurseries = self.city.labels.Nursery and #self.city.labels.Nursery or 0
      if not mod or opt.UseDefaultIfNoNursery and num_nurseries < 1 then return orig_DomeSpawnChild(self, ...) end

      local pre
      if dbg then
        pre = lib.make_prefix(CurrentModId, "Dome:SpawnChild")
        lib.log(pre)
      end

      -- save the args to the birth so we can deal with it later
      local city = self.city
      if not pending_births then pending_births = {} end
      if not pending_births[city] then pending_births[city] = {} end
      table.insert(pending_births[city], table.pack(...))
    end
  end
end
