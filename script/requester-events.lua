-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- A requester was created.
--
-- @param entity The LuaEntity of the created requester
-- @param playerId The index of the player that created the requester
--
function onRequesterCreated(entity, playerId)
  log("requester created at ["..entity.position.x..";"..entity.position.y.."], orientation "..entity.direction)

  local ctrl = entity.get_or_create_control_behavior()
  ctrl.use_colors = true
  ctrl.circuit_condition = {
    condition = {comparator = ">",
      --first_signal = {type="virtual", name = "signal-T"},
      constant = 0,
    }
  }

  local stops = find_stops_near(entity)
  local stopId = nil
  if not stops or #stops == 0 then
    log("no stop found nearby")
    print_player(playerId, "error.noStopFound")
  elseif #stops > 1 then
    log(#stops.." stops found nearby")
    print_player(playerId, "error.multipleStopsFound")
  else
    stopId = stops[1].unit_number
    log("stop found nearby: "..stops[1].backer_name)
    register_requester_at_stop(stops[1], entity.unit_number)
  end

  global.requesters[entity.unit_number] = {
    entity = entity,
    entityId = entity.unit_number,
    stopId = stopId,
    surfaceId = entity.surface.index,
    forceId = entity.force.index,
    networkName = DEFAULT_NETWORK_NAME,
    resourceName = nil
  }
end


--
-- A requester was removed.
--
-- @param entity The LuaEntity of the removed requester
--
function onRequesterRemoved(entity)
  log("requester removed at ["..entity.position.x..";"..entity.position.y.."]")

  local requester = global.requesters[entity.unit_number]
  if requester then
    dispatcher_unregister_requester(requester)
  end

  local stops = find_stops_near(entity)
  if stops and #stops == 1 then
    unregister_requester_from_stop(stops[1], entity.unit_number)
  end

  global.requesters[entity.unit_number] = nil
end

