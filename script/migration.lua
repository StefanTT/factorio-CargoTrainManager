-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

--
-- Migrate the game's entities / data if required
--
-- @param version The current version of the game's data
-- @return The new version of the game's data
--
function migrateData(version)
  if version < 1 then
    migrateData_v1()
  end
  return 1
end


--
-- Migrate to version 1:
-- Update requester logic to use the "item>0" syntax if possible
--
function migrateData_v1()
  log("Migrating requester logic conditions")

  local stops = {}
  for _,stop in pairs(game.get_train_stops()) do
    stops[stop.unit_number] = stop
  end

  for _,requester in pairs(global.requesters) do
    local ctrl = requester.entity.get_or_create_control_behavior()
    local cond = ctrl.circuit_condition.condition
    --log("Requester for "..(requester.resourceName or "nil")..": "..serpent.line(cond))
    if cond.comparator == ">" and signalIdToStr(cond.first_signal) == requester.resourceName
       and cond.constant == nil and signalIdToStr(cond.second_signal) == "v-"..CTM_COUNTER_SIGNAL then
      log("Migrating requester for "..(requester.resourceName or "nil").." at ["..requester.entity.position.x..";"..requester.entity.position.y.."]: condition is "..serpent.line(cond));

      ctrl.circuit_condition = {condition = {
        comparator = cond.comparator,
        first_signal = cond.first_signal,
        second_signal = nil,
        constant = 0
      }}

      local stop = stops[requester.stopId or 0]
      if stop ~= nil and stop.trains_limit > 10000 then
        log("Train stop limit of "..stop.backer_name.." is unset, setting it to 1")
        stop.trains_limit = 1
      end
    end
  end
end

