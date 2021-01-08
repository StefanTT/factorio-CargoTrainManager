-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.
--
-- createStop copied and adapted from Logistics Train Network, Copyright (c) 2017 Optera, MIT license
--


--
-- Create a train manager stop.
--
-- @param entity The LuaEntity of the stop entity
-- @return An array with the created sub-entities: { lamp=LuaEntity, lampCtrl=LuaEntity, output=LuaEntity }
--
function createStop(entity)
  local posIn, posOut, rotOut, searchArea
  if entity.direction == 0 then --SN
    posIn = {entity.position.x, entity.position.y - 1}
    posOut = {entity.position.x - 1, entity.position.y - 1}
    rotOut = 0
    searchArea = {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y}}
  elseif entity.direction == 2 then --WE
    posIn = {entity.position.x, entity.position.y}
    posOut = {entity.position.x, entity.position.y - 1}
    rotOut = 2
    searchArea = {{entity.position.x, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}}
  elseif entity.direction == 4 then --NS
    posIn = {entity.position.x - 1, entity.position.y}
    posOut = {entity.position.x, entity.position.y}
    rotOut = 4
    searchArea = {{entity.position.x - 1, entity.position.y}, {entity.position.x + 1, entity.position.y + 1}}
  elseif entity.direction == 6 then --EW
    posIn = {entity.position.x - 1, entity.position.y - 1}
    posOut = {entity.position.x - 1, entity.position.y}
    rotOut = 6
    searchArea = {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x, entity.position.y + 1}}
  else --invalid orientation
    printmsg("onStationCreated: invalid train stop orientation "..tostring(entity.direction))
    entity.destroy()
    return
  end

  local lamp, output, lampCtrl
  -- handle blueprint ghosts and existing IO entities preserving circuit connections
  local ghosts = entity.surface.find_entities(searchArea)
  for _,ghost in pairs (ghosts) do
    if ghost.valid then
      if ghost.name == "entity-ghost" then
        if ghost.ghost_name == CTM_STOP_LAMP then
          -- printmsg("reviving ghost lamp at "..ghost.position.x..", "..ghost.position.y)
          _, lamp = ghost.revive()
        elseif ghost.ghost_name == CTM_STOP_OUTPUT then
          -- printmsg("reviving ghost output at "..ghost.position.x..", "..ghost.position.y)
          _, output = ghost.revive()
        elseif ghost.ghost_name == CTM_STOP_LAMP_CTRL then
          -- printmsg("reviving ghost lamp-control at "..ghost.position.x..", "..ghost.position.y)
          _, lampCtrl = ghost.revive()
        end
      -- something has built I/O already (e.g.) Creative Mode Instant Blueprint
      elseif ghost.name == CTM_STOP_LAMP then
        lamp = ghost
        --printmsg("Found existing lamp at "..ghost.position.x..", "..ghost.position.y)
      elseif ghost.name == CTM_STOP_OUTPUT then
        output = ghost
        --printmsg("Found existing output at "..ghost.position.x..", "..ghost.position.y)
      elseif ghost.name == CTM_STOP_LAMP_CTRL then
        lampCtrl = ghost
        --printmsg("Found existing lamp-control at "..ghost.position.x..", "..ghost.position.y)
      end
    end
  end

  if lamp == nil then
    lamp = entity.surface.create_entity{name = CTM_STOP_LAMP, position = posIn, force = entity.force}
  end
  lamp.operable = false
  lamp.minable = false
  lamp.destructible = false

  if lampCtrl == nil then
    lampCtrl = entity.surface.create_entity{name = CTM_STOP_LAMP_CTRL, position = lamp.position, force = entity.force}
  end
  lampCtrl.operable = false
  lampCtrl.minable = false
  lampCtrl.destructible = false
  
  -- connect lamp and control
  lampCtrl.get_or_create_control_behavior().parameters = {{index = 1, signal = {type="virtual",name="signal-black"}, count = 0}}
  lamp.connect_neighbour({target_entity=lampCtrl, wire=defines.wire_type.green})
  lamp.connect_neighbour({target_entity=lampCtrl, wire=defines.wire_type.red})
  lamp.get_or_create_control_behavior().use_colors = true
  lamp.get_or_create_control_behavior().circuit_condition =
    {condition = {comparator = ">", first_signal = {type = "virtual", name = "signal-anything"}}}

  if output == nil then
    output = entity.surface.create_entity{name = CTM_STOP_OUTPUT, position = posOut, direction = rotOut, force = entity.force}
  end
  output.operable = false
  output.minable = false
  output.destructible = false

  -- enable reading contents and sending signals to trains
  entity.get_or_create_control_behavior().send_to_train = true
  entity.get_or_create_control_behavior().read_from_train = true

  return { lamp = lamp, lampCtrl = lampCtrl, output = output }
end

