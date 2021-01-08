-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

--
-- The configuration of a requester has changed.
--
-- @param entityId The ID of the requester's LuaEntity
--
function requester_config_changed(entityId)
  log("config changed of requester #"..entityId)
  local requester = global.requesters[entityId]
  if not requester then return end

  requester.dispatcherId = dispatcher_id(requester)
end


--
-- Update the configuration of a requester. Does nothing if the updates contain the same values.
-- Components that can be updated are resourceName and networkName.
--
-- @param requester The requester to update
-- @param resourceName The updated resource name
-- @param networkName The updated network name
--
function update_requester_config(requester, resourceName, networkName)
  if requester.resourceName ~= resourceName or requester.networkName ~= networkName then
    dispatcher_cancel_delivery(requester)
    requester.resourceName = resourceName
    requester.networkName = networkName
  end
end


--
-- Find requesters near the given train stop.
--
-- @param entity The train stop LuaEntity to assign nearby requesters
-- @return An array with the nearby requesters
--
function find_nearby_requesters(entity)
  local rx = MAX_REQUESTER_STOP_DISTANCE
  local ry = MAX_REQUESTER_STOP_DISTANCE

  local dir = entity.direction
  if dir == defines.direction.north or dir == defines.direction.south then
    ry = ry + ry
  else
    rx = rx + rx
  end

  local pos = entity.position
  return entity.surface.find_entities_filtered{area = {{x = pos.x - rx, y = pos.y - ry},
    {x = pos.x + rx, y = pos.y + ry}}, name = CTM_REQUESTER, force = entity.force} or {}
end


--
-- Find nearby requesters and assign them to the given train stop.
--
-- @param entity The train stop LuaEntity to assign nearby requesters
-- @return The number of found requesters
--
function assign_nearby_requesters(entity)
  local stopId = entity.unit_number
  local requesters = find_nearby_requesters(entity)
  for _,req in pairs(requesters) do
    global.requesters[req.unit_number].stopId = stopId
  end
  log("assigned "..#requesters.." nearby requesters")
  return #requesters
end


--
-- Find nearby requesters and unassign them from the given train stop.
--
-- @param entity The train stop LuaEntity to unassign nearby requesters
--
function unassign_nearby_requesters(entity)
  local requesters = find_nearby_requesters(entity)
  for _,req in pairs(requesters) do
    global.requesters[req.unit_number].stopId = nil
  end
  log("unassigned "..#requesters.." nearby requesters")
end


--
-- Get the stop of a requester.
--
-- @param requester The requester to get the stop for
-- @return The requester's stop or nil if no stop is assigned
--
function get_stop_of_requester(requester)
  if not requester or not requester.stopId then return nil end
  local stops = find_stops_near(requester.entity)
  if #stops == 1 then return stops[1] end
  return nil
end

