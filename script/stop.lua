-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Set a train manager stop's lamp to a specific color.
--
-- @param stop The stop of which the lamp shall be set
-- @param color The color of the lamp, e.g. "red"
--
function set_stop_lamp(stop, color)
  if stop and stop.lampCtrl.valid then
    local signalName, count
    if color then
      signalName = "signal-"..color
      count = 1
    else
      signalName = "signal-black"
      count = 0
    end
    stop.lampCtrl.get_control_behavior().parameters =
      {{index = 1, signal = {type = "virtual", name = signalName}, count = count}}
  end
end


--
-- Update the configuration of a stop. Does nothing if the updates contain the same values.
-- Components that can be updated are resourceName and networkName.
--
-- @param stop The stop to update
-- @param resourceName The new resource name
-- @param networkName The new network name
--
function update_stop_config(stop, resourceName, networkName)
  if stop.resourceName ~= resourceName or stop.networkName ~= networkName then
    log("Updating config of stop "..stop.entity.backer_name)
    dispatcher_unregister_stop(stop)
    stop.resourceName = resourceName
    stop.networkName = networkName
    dispatcher_register_stop(stop)
  end
end


--
-- Find a train manager stop near the given requester.
--
-- @param entity The requester LuaEntity to find a nearby stop
-- @return An array with the nearby stops
--
function find_stops_near(entity)
  local pos = entity.position
  local r = MAX_REQUESTER_STOP_DISTANCE
  local r2 = r + r

  local matches = entity.surface.find_entities_filtered{area = {{x = pos.x - r2, y = pos.y - r2},
    {x = pos.x + r2, y = pos.y + r2}}, name = CTM_STOP, force = entity.force}
  if not matches or #matches < 1 then
    return matches
  end

  -- filter out duplicates and stops that have an orientation that excludes them from the matches
  local resultUnitNumbers = {};
  local result = {};
  for _,match in ipairs(matches) do
    if not resultUnitNumbers[match.unit_number] then
      resultUnitNumbers[match.unit_number] = true
      local mpos = match.position
      local mdir = match.direction
      if ((mdir == defines.direction.north or mdir == defines.direction.south) and math.abs(mpos.x - pos.x) <= r) or
         ((mdir == defines.direction.east or mdir == defines.direction.west) and math.abs(mpos.y - pos.y) <= r) then
        table.insert(result, match)
      end
    end
  end

  return result
end


--
-- Register a requester at a stop.
--
-- @param entity The stop's LuaEntity
-- @param requesterId The requester's ID
--
function register_requester_at_stop(entity, requesterId)
  local stop = global.stops[entity.unit_number] or {}
  stop.numRequesters = stop.numRequesters + 1
  dispatcher_update_stop_status(stop)
end


--
-- Unregister a requester from a stop.
--
-- @param entity The stop's LuaEntity
-- @param requesterId The requester's ID
--
function unregister_requester_from_stop(entity, requesterId)
  local stop = global.stops[entity.unit_number] or {}
  stop.numRequesters = stop.numRequesters - 1
  dispatcher_update_stop_status(stop)
end

