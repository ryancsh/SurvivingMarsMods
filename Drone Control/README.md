
Readme last updated: 2021-10-10 10:11:53

### Bug reports, feature requests, or comments on the issues page.

---

# Drone Control

   Too many drones at one drone hub?

   Too few drones at the ones that need drones?

   Other mods adjusting drone count too fast, leading to swingy drone populations?

   This mod tries to avoid all those issues by being more conservative with drone reassignments.

## How it works

   Every hour, the mod checks all hubs in the city and makes a note of the number of idle drones at that hub.

   At the end of each drone reassignment cycle (mod option available), the mod makes a decision based on the maximum number of idle drones:
   - If there aren't enough idle drones, use some drone prefabs.
   - If there are too many idle drones, convert some to drone prefabs

   After reassigning drones, the mod will check if there are enough drone prefabs in stock and try to order more.

   You can also set a resource limit so that the mod will only order prefabs if you have more than that amount.

## Mod Options

- **Enable**
   - Default value: On
	- Enable mod. Mod does nothing if this is Off
- **Disable if less than X drone hubs**
	- DefaultValue: 2
	- If the number of drone hubs in the city is less than this number, mod won't do anything.
   - Meant to be an early game option where you might want to be very precise with your drone assignments.
- **Minimum drone count for Drone Hubs**
	- DefaultValue: 4
	- If mod is active, it will make sure drones don't go below this amount even at idle Drone Hubs.
   - This is useful if you send Rockets into space and they randomly take drones from Drone Hubs.
- **Minimum drone count for RC Commanders**
	- DefaultValue: 4
	- Like above but for RC Commanders
- **Adjust DroneHub drones**
	- DefaultValue: On
	- If On: Assign drones based on drone load of Drone Hubs
   - If Off: Remove all drones at Drone Hubs except specified minimum amount.
- **Adjust RC Commander drones**
	- DefaultValue: On
	- If On: Assign drones based on drone load of RC Commanders
   - If Off: Remove all drones at RC Commanders except specified minimum amount.
- **Remove all drones assigned to rockets**
	- DefaultValue: On
	- If On: Remove all drones at Rockets except for specified minimum amount.
   - If Off: Don't do anything to drones assigned at Rockets.
- **Drone Group Size**
	- DefaultValue: 1
   - When adding or removing drones based on busy/idle load at drone hubs, do it in groups of this size.
   - Drone prefab ordering also scales based on this value.
   - Choose low values for this setting.
- **Hours between drone reassignments**
	- DefaultValue: 8
	- Duration of one drone reassignment cycle.
   - Lower number for faster adjustments.
   - Higher numbers for more stable drone population at hubs and better performance.
- **Busy Threshold**
	- DefaultValue: 2
   - Controls when more drones should be added to a hub.
	- When hub has less than BusyThreshold idle drones for an entire cycle, consider hub busy and add more drones.
   - If hub has more than (BusyThreshold + 2*DroneGroupSize) idle drones for an entire cycle, consider hub idle and remove drones.
- **Allow Automatic Requesting of Drone Prefabs**
	- DefaultValue: On
	- Will automatically request prefabs at Drone Assembers if total number of prefabs drops below (total_number_of_hubs * DroneGroupSize)
   - Will respect spare resource setting.
   - Will try to order in bulk if possible to reduce performance impact.
- **Drone Spare Resource Threshold**
	- DefaultValue: 100
	- Only request drone prefabs if we have this many recipes worth of spare materials.
   - Set to higher values to reserve more resources for other purposes
- **Enable logging**
	- DefaultValue: Off
   - Enable printing to console for debugging purposes.
   - Leave Off unless you want to figure out if the mod is working properly.
   - Requires rcsh_library mod.

## Caution

- **If there are not enough drone prefabs, the drone population may get wrongly balanced.**

   It's your job to make sure you have enough drone prefabs in stock.

   If you don't have enough drones, just use more conservative settings such as lower minimums and smaller group sizes so that you can optimize the usage of your limited supply of drones as much as possible.

- **Not tested with Below and Beyond DLC**

   I don't have the DLC so I have no idea if it behaves properly or not with Below and Beyond.

   If there are issues, try filing a bug report and I'll see what I can do.

- **Disable or avoid using with other drone control mods**

   It's sort of your problem what happens if you enable multiple drone management mods.

   Just pick one of them.

---

### Bug reports, feature requests, or comments on the issues page.
