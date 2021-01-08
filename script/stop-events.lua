-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- A train manager stop was created.
--
-- @param entity The LuaEntity of the created station
-- @param playerId The index of the player that created the stop
--
function onStopCreated(entity, playerId)
  log("stop created at ["..entity.position.x..";"..entity.position.y.."], orientation "..entity.direction)

  local stop = createStop(entity)
  if not stop then return end

  stop.entity = entity
  stop.entityId = entity.unit_number
  stop.surfaceId = entity.surface.index
  stop.forceId = entity.force.index
  stop.networkName = DEFAULT_NETWORK_NAME
  stop.canDeliver = false
  stop.deliveringTrains = {}
  stop.numRequesters = assign_nearby_requesters(entity)

  global.stops[entity.unit_number] = stop
end


--
-- A train manager stop was removed.
--
-- @param entity The LuaEntity of the removed station
--
function onStopRemoved(entity)
  log("stop removed at ["..entity.position.x..";"..entity.position.y.."]")
  unassign_nearby_requesters(entity)

  local stop = global.stops[entity.unit_number]
  if stop then
    if stop.lamp and stop.lamp.valid then stop.lamp.destroy() end
    if stop.output and stop.output.valid then stop.output.destroy() end
    if stop.lampCtrl and stop.lampCtrl.valid then stop.lampCtrl.destroy() end

    dispatcher_unregister_stop(stop)
    global.stops[entity.unit_number] = nil
  end
end

