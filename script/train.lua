-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


local TRAIN_STATE_NAME = {
  [defines.train_state.on_the_path] = "on_the_path",
  [defines.train_state.path_lost] = "path_lost",
  [defines.train_state.no_schedule] = "no_schedule",
  [defines.train_state.no_path] = "no_path",
  [defines.train_state.arrive_signal] = "arrive_signal",
  [defines.train_state.wait_signal] = "wait_signal",
  [defines.train_state.arrive_station] = "arrive_station",
  [defines.train_state.wait_station] = "wait_station",
  [defines.train_state.manual_control_stop] = "manual_control_stop",
  [defines.train_state.manual_control] = "manual_control"
}


--
-- Translate a train state to the state as string.
--
-- @param state The state to translate
-- @return The state as string or "???" if the state is unknown
--
function train_state_name(state)
  local name = TRAIN_STATE_NAME[state];
  if name == nil then return "???" end
  return name;
end


--
-- Get the main locomotive of a train.
--
-- @param train LuaTrain train to query
-- @return LuaEntity of the locomotive or nil if the train is not valid or has no locomotive
--
function main_locomotive(train)
  if train.valid and train.locomotives and (#train.locomotives.front_movers > 0 or #train.locomotives.back_movers > 0) then
    return train.locomotives.front_movers and train.locomotives.front_movers[1] or train.locomotives.back_movers[1]
  end
end


-- 
-- Get the name of the train's front locomotive
--
-- @param train The LuaTrain train to query
-- @return The name of the locomotive, nil if the train has none
--
function train_name(train)
  local loco = main_locomotive(train)
  return loco and loco.backer_name
end


--
-- Get the cargo item of the train. If the train contains multiple items then the
-- item with the highest amount is returned. If the train contains no items then
-- the fluid with the highest amount is returned.
--
-- @param train The LuaTrain train to query
-- @return The cargo item or fluid, e.g. "i-stone" or "f-water", nil if the train is empty
--
function train_cargo(train)
  if not train.valid then return nil end

  local name = nil
  local amount = 0

  for nm,amt in pairs(train.get_contents()) do
    if amt > amount then
      name = nm
      amount = amt
    end
  end
  if name then
    return "i-"..name
  end

  for nm,amt in pairs(train.get_fluid_contents()) do
    if amt > amount then
      name = nm
      amount = amt
    end
  end
  if name then
    return "f-"..name
  end

  return nil
end


--
-- Get the total fuel value of a locomotive.
--
-- @param loco The locomotive to check
-- @return the total fuel value of the locomotive
--
local function locomotive_fuel_value(loco, minFuel)
  local fuelInv = loco.get_fuel_inventory()
  if not fuelInv then return false end

  local contents = fuelInv.get_contents()
  local fuelSum = 0;

  for name,count in pairs(contents) do
    local fuelItem = game.item_prototypes[name]
    fuelSum = fuelSum + fuelItem.fuel_value * count
  end

  return fuelSum
end


--
-- Test if any of the locomotives need fuel.
--
-- @param locos A list of locomotives to check
-- @param minFuel The minimum fuel that a locomotive must have
-- @return True if any locomotive of the list needs fuel
-- 
local function locomotives_need_fuel(locos, minFuel)
	for _,loc in pairs(locos) do
		if locomotive_fuel_value(loc) < minFuel then
			return true
		end
	end
	return false
end


--
-- Test if a train needs to refuel.
--
-- @param train The LuaTrain to test
-- @return true if the train needs to refuel, false if not or if automatic refuel is disabled
--
function train_needs_fuel(train)
  local minFuel = settings.global['minFuelValue'].value
  if minFuel <= 0 then return false end

  minFuel = minFuel * 1000000

  local locos = train.locomotives
  return locomotives_need_fuel(locos.front_movers, minFuel) or locomotives_need_fuel(locos.back_movers, minFuel)
end


--
-- Get the station name for refueling the given train.
--
-- @param train The LuaTrain to get the name for
-- @return The name of the refuel station
--
function train_refuel_station_name(train)
  return settings.global['refuelStationName'].value..(#train.locomotives.front_movers + #train.locomotives.back_movers)
end


--
-- Send a train to the refuel station by appending the appropriate refuel station to the
-- end of the train's schedule.
--
-- @param train The LuaTrain to send to refuel
--
function train_schedule_refuel(train)
  local refuelStationName = train_refuel_station_name(train)

  local schedule = train.schedule or {}
  if not schedule.records then
    schedule.records = {}
  end

  for _,rec in pairs(schedule.records) do
    if rec.station == refuelStationName then
      return
    end
  end

  local rec = {station = refuelStationName, wait_conditions = {
    {type = "inactivity", compare_type = "and", ticks = 120}
  }}

  schedule.records[#schedule.records + 1] = rec
	train_set_schedule(train, schedule)

  --printmsg({"message.send-refuel", train_name(train), refuelStationName})
end


--
-- Send a train to a station for delivery. The delivery is added to the end of the
-- train's schedule and the train is sent to the next station in it's schedule.
--
-- @param train The LuaTrain to send
-- @param stationName The name of the target station for the delivery
--
function train_schedule_delivery(train, stationName)
  local schedule = train.schedule or {}
  if not schedule.records then
    schedule.records = {}
  end

  local rec = {station = stationName, wait_conditions = {
    {type = "empty", compare_type = "or"},
    {type = "inactivity", compare_type = "or", ticks = 300},
    {type = "time", compare_type = "or", ticks = 7200} -- 2min
  }}

  schedule.current = (schedule.current or 0) + 1
  table.insert(schedule.records, schedule.current, rec)

  train_set_schedule(train, schedule)
end


--
-- Test if the schedule of the train contains a specific station.
--
-- @param train The LuaTrain to inspect
-- @param stationName The name of the station to find
-- @return True if the station was found, false if not
--
function train_schedule_contains_station(train, stationName)
  if train.valid and train.schedule then
    for _,rec in pairs(train.schedule.records) do
      if rec.station == stationName then
        return true
      end
    end
  end
  return false
end


--
-- Remove a train's schedule entry.
--
-- @param train The LuaTrain to modify
-- @param stationName The name of the station to remove from the schedule
-- return True if the station was found, false if not
--
function train_schedule_remove_station(train, stationName)
  if train.valid and train.schedule then
    for index,rec in pairs(train.schedule.records) do
      if rec.station == stationName then
        local recs = train.schedule.records
        local current = train.schedule.current or 1
        log("removing train schedule #"..index.." (current #"..current..")")
        table.remove(recs, index)
        if index <= current then current = current - 1 end
        train_set_schedule(train, { records = recs, current = current })
        return true
      end
    end
  end
  return false
end


--
-- Replace a train's schedule. The current station is taken from the
-- train's current schedule if it is unset in the given schedule.
--
-- @param train The LuaTrain to modify
-- @param schedule The schedule to set
--
function train_set_schedule(train, schedule)
  if not schedule.current then
    schedule.current = train.schedule.current
  end
  if schedule.current > #schedule.records then
    schedule.current = 1
  elseif schedule.current < 1 then
    schedule.current = #schedule.records
  end

  local manualMode = train.manual_mode
  train.manual_mode = true
  train.schedule = schedule
  train.manual_mode = manualMode
end


--
-- Set the train's current destination to the next entry of the schedule.
--
-- @param train The LuaTrain to modify
-- 
function train_schedule_next(train)
  local schedule = train.schedule
  schedule.current = (schedule.current or 0) + 1
  if schedule.current > #schedule.records then
    schedule.current = 1
  end

  local manualMode = train.manual_mode
  train.manual_mode = true
  train.schedule = schedule
  train.manual_mode = manualMode
end

