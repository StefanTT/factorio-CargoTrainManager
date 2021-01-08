-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- A train arrived at a station.
--
-- @param train The train
--
local function trainArrivedAtStation(train)
  if not train.station or not train.station.valid then return end
  log("train "..train_name(train).." arrived at station "..train.station.backer_name)

  if dispatcher_shall_handle_train(train) then
    dispatcher_train_waiting_station(train, stop)
  end
end


--
-- A train leaves a station.
--
-- @param train The train
--
local function trainLeavesStation(train)
  local station = global.lastTrainStation[train.id]
  if not station or not station.valid then return end

  log("train "..train_name(train).." left station "..station.backer_name)

  local stop = global.stops[station.unit_number]
  if stop then
    -- train left a TrainManager stop
    if stop.deliveringTrains[train.id] then
      dispatcher_train_delivery_done(train, stop)
    else
      dispatcher_update_stop_status(stop)
    end
  elseif string.find(station.backer_name, settings.global['refuelStationName'].value, 1, true) == 1 then
    -- train left a refuel station
    log("removing refuel station from train "..train_name(train))
    train_schedule_remove_station(train, station.backer_name)
  end

  if train_needs_fuel(train) then
    train_schedule_refuel(train)
  end
end


--
-- A train is at a station and is switched to manual control.
--
-- @param train The train
--
local function trainStationManualControl(train)
  local station = global.lastTrainStation[train.id]
  if not station or not station.valid then return end

  --log("train "..train_name(train).." switched to manual control")

  local stop = global.stops[station.unit_number]
  if stop then
    dispatcher_update_stop_status(stop)
  end
end


--
-- Called when a train changes state (started to stopped and vice versa).
--
-- @param event The event containing train, oldState
--
function onTrainChangedState(event)
  local train = event.train
  --log("train "..train_name(train).." state changed from "..train_state_name(event.old_state).." to "..train_state_name(train.state))

  -- Train (starts to) wait at a station
  if train.state == defines.train_state.wait_station then
    global.lastTrainStation[train.id] = train.station
    trainArrivedAtStation(train)

  -- Train leaves a station
  elseif event.old_state == defines.train_state.wait_station and train.state == defines.train_state.on_the_path then
    trainLeavesStation(train)

  -- Train is at a station and is switched to manual control
  elseif event.old_state == defines.train_state.wait_station and train.state == defines.train_state.manual_control then
    trainStationManualControl(train)
  end
end


--
-- Update a train.
--
-- @param train The new train
-- @param oldTrainId The ID of the train before modification
--
local function trainModified(train, oldTrainId)
  global.lastTrainStation[oldTrainId] = nil

  local delivery = global.deliveries[oldTrainId]
  if delivery then
    log("train "..oldTrainId.." changed, updating delivery to train "..train.id)

    delivery.train = train
    global.deliveries[oldTrainId] = nil
    global.deliveries[train.id] = delivery

    local stop = global.stops[delivery.requester.stopId]
    stop.deliveringTrains[train.id] = stop.deliveringTrains[oldTrainId]
    stop.deliveringTrains[oldTrainId] = nil
  end
end


--
-- Called when a new train is created either through disconnecting/connecting an existing one or building a new one.
--
-- @param event The event, containing:
--        train :: LuaTrain
--        old_train_id_1 :: uint (optional): The first old train id when splitting/merging trains.
--        old_train_id_2 :: uint (optional): The second old train id when splitting/merging trains.
--
function onTrainCreated(event)
  if event.old_train_id_1 then
    trainModified(event.train, event.old_train_id_1)
  end
  if event.old_train_id_2 then
    trainModified(event.train, event.old_train_id_2)
  end
end


--
-- Called when a train was removed.
--
-- @param train The LuaTrain that is being removed
--
function onTrainRemoved(train)
  global.lastTrainStation[train.id] = nil

  local delivery = global.deliveries[train.id]
  if delivery then
    dispatcher_abort_delivery(delivery, "message.train-removed")
  end
end

