-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Get or create a resource.
--
-- @param req The stop or requester
-- @return The resource, never nil
--
local function get_or_create_resource(req)
  local id = dispatcher_id(req)
  local resource = global.resources[id]
  if not resource then
    resource = {
      surfaceId = req.surfaceId,
      forceId = req.forceId,
      networkName = req.networkName,
      resourceName = req.resourceName,
      stops = {},
      pending = {}
    }
    global.resources[id] = resource
  end
  return resource
end


--
-- Delete the resource if it is unused.
--
-- @param resource The resource to consider for deletion
-- @param id The ID of the resource (optional)
--
local function delete_resource_if_unused(resource, id)
  if #resource.stops == 0 and #resource.pending == 0 then
    if not id then
      id = dispatcher_id(resource)
    end
    global.resources[id] = nil
    log("deleted unused resource "..id)
  end
end


--
-- Calculate the dispatcher ID of a stop or a requester.
--
-- @param req The stop or requester
-- @return The network ID string
function dispatcher_id(req)
  return tostring(req.forceId)..':'..tostring(req.surfaceId)..':'..tostring(req.networkName)..':'..tostring(req.resourceName)
end


--
-- Register a stop as provider for a resource.
--
-- @param stop The stop to register
--
function dispatcher_register_stop(stop)
  if stop.numRequesters == 0 then
    log("registered stop "..stop.entity.backer_name)
    local stops = get_or_create_resource(stop).stops
    stops[#stops + 1] = stop

    stop.canDeliver = false
    local train = stop.entity.get_stopped_train()
    if train then
      dispatcher_train_waiting_station(train)
    end
  end
end


--
-- Unregister a stop as provider of a resource.
--
-- @param stop The stop to unregister
--
function dispatcher_unregister_stop(stop)
  local id = dispatcher_id(stop)
  local resource = global.resources[id]
  if resource then
    for i,s in pairs(resource.stops) do
      if s.entityId == stop.entityId then
        log("unregistered stop "..stop.entity.backer_name)
        table.remove(resource.stops, i)
        break
      end
    end
    delete_resource_if_unused(resource, id)
    if #resource.stops == 0 then
      log("removing resource")
      global.resources[id] = nil
    end
  end
end


--
-- A requester is being removed.
--
-- @param requester The requester that is being removed
--
function dispatcher_unregister_requester(requester)
  log("unregistering requester")
  dispatcher_cancel_delivery(requester)
  local id = dispatcher_id(requester)
  local resource = global.resources[id]
  if resource then
    delete_resource_if_unused(resource, id)
  end
end


--
-- Update the status of the stop.
--
-- @param stop The stop to update
--
function dispatcher_update_stop_status(stop)
  --log("update status of stop "..stop.entity.backer_name)

  local params = {}
  local lampColor = nil
  local stoppedTrain = stop.entity.get_stopped_train()

  if stop.numRequesters > 0 then
    params[#params + 1] = {index = #params + 1, signal = {type = "virtual", name = "signal-cyan"}, count = stop.numRequesters}
  elseif stoppedTrain then
    params[#params + 1] = {index = #params + 1, signal = strToSignalId(stop.resourceName), count = 1}
  end

  if next(stop.deliveringTrains) then
    local signals = {}
    local numTrains = 0
    for _,resource in pairs(stop.deliveringTrains) do
      signals[resource] = (signals[resource] or 0) + 1
      numTrains = numTrains + 1
    end
    for signal,count in pairs(signals) do
      params[#params + 1] = {index = #params + 1, signal = strToSignalId(signal), count = -count}
    end
    params[#params + 1] = {index = #params + 1, signal = {type = "virtual", name = CTM_COUNTER_SIGNAL}, count = numTrains}
    lampColor = "yellow"
  elseif stoppedTrain then
    if stop.numRequesters == 0 and (not stop.resourceName or not stop.networkName) then
      lampColor = "red"
    else
      lampColor = "green"
    end
  end

  set_stop_lamp(stop, lampColor)
  stop.output.get_control_behavior().parameters = params
end


--
-- Test if the train is waiting at a train manager provider station.
--
-- @param train The train to test
-- @return True if the dispatcher shall handle the train, false if not
--
function dispatcher_shall_handle_train(train)
  if not train.valid or train.manual_mode or not train.station or not train.schedule or not train.schedule.records then
    return false
  end

  local stop = global.stops[train.station.unit_number]
  return stop and stop.numRequesters == 0
end


--
-- Manage a train that is waiting at a train manager station.
--
-- @param train The train to manage
--
function dispatcher_train_waiting_station(train)
  log("dispatcher shall handle train "..train_name(train))
  local stop = global.stops[train.station.unit_number]
  if not stop then return end

  if stop.numRequesters == 0 and not stop.resourceName then
    local cargo = train_cargo(train)
    if cargo then
      log("stop "..stop.entity.backer_name.." has no resource set, setting it from the train's cargo: "..cargo)
      update_stop_config(stop, cargo, stop.networkName)
    end
  end

  stop.canDeliver = true
  log("stop "..stop.entity.backer_name.." is ready for delivery")

  local resource = get_or_create_resource(stop)
  if #resource.pending > 0 and dispatcher_train_schedule_delivery(stop, resource.pending[1]) then
    table.remove(resource.pending, 1)
  else
    dispatcher_update_stop_status(stop)
  end
end


--
-- Schedule a delivery of a train at a stop.
--
-- @param stop The stop from where the train to send
-- @param requester The target requester
-- @return True if the train is being sent, false if there was no train
--
function dispatcher_train_schedule_delivery(stop, requester)
  local train = stop.entity.get_stopped_train()
  if not train then
    log("WARN no train found to deliver at stop "..stop.entity.backer_name)
    stop.canDeliver = false
    return false
  end

  local targetStop = global.stops[requester.stopId or -1]
  if not targetStop or targetStop.entity.trains_count >= targetStop.entity.trains_limit then
    --log("not sending delivery train to "..targetStop.entity.backer_name..", reason: stop's train limit reached")
    return false
  end

  log("sending delivery train from "..stop.entity.backer_name.." to "..targetStop.entity.backer_name)
  targetStop.deliveringTrains[train.id] = requester.resourceName
  stop.canDeliver = false

  train_schedule_delivery(train, targetStop.entity.backer_name)
  dispatcher_update_stop_status(targetStop)

  global.deliveries[train.id] = {
    requester = requester,
    startTime = game.tick,
    train = train
  }

  return true
end


--
-- A train delivery has just finished and the train is leaving the station.
--
-- @param train The train that finished the delivery
-- @param stop The stop where the delivery happened
--
function dispatcher_train_delivery_done(train, stop)
  log("train finished delivery at "..stop.entity.backer_name)

  local delivery = global.deliveries[train.id] or {}
  if delivery.requester then
    delivery.requester.trainRequested = false
  end

  global.deliveries[train.id] = nil
  stop.deliveringTrains[train.id] = nil

  train_schedule_remove_station(train, stop.entity.backer_name)
  dispatcher_update_stop_status(stop)
  dispatcher_handle_requesters()
end


--
-- Request a delivery to a requester.
--
-- @param requester The requester to handle
--
function dispatcher_request_delivery(requester)
  local resource = get_or_create_resource(requester)
  for _,stop in pairs(resource.stops) do
    if stop.canDeliver and dispatcher_train_schedule_delivery(stop, requester) then
      log("requesting delivery for requester #"..requester.entityId..": "..requester.resourceName)
      requester.statusSince = game.tick
      requester.trainRequested = true
      return
    end
  end

  log("no train ready for delivery of "..resource.resourceName.." to "..global.stops[requester.stopId].entity.backer_name..", waiting")
  for i,req in pairs(resource.pending) do
    if req.entityId == requester.entityId then
      return
    end
  end
  table.insert(resource.pending, requester)
end


--
-- Cancel a delivery to a requester.
--
-- @param requester The requester to handle
--
function dispatcher_cancel_delivery(requester)
  log("canceling delivery for requester #"..requester.entityId)
  requester.trainRequested = false

  local id = dispatcher_id(requester)
  local resource = global.resources[id]
  if not resource then
    log("WARN no resource found for requester id "..id)
    return
  end

  for i,req in pairs(resource.pending) do
    if req.entityId == requester.entityId then
      table.remove(resource.pending, i)
      break
    end
  end
end


--
-- Abort an ongoing delivery.
--
-- @param delivery The delivery to abort
-- @param messageId The message to print to the owning force
--
function dispatcher_abort_delivery(delivery, messageId)
  local stop = global.stops[delivery.requester.stopId]
  local train = delivery.train

  if stop then
    log("Aborting delivery to "..stop.entity.backer_name..", reason: "..tostring(messageId))

    if messageId then
      printmsg({messageId, stop.entity.backer_name}, stop.entity.force)
    end

    if train.valid then
      if train_schedule_remove_station(train, stop.entity.backer_name) then
        train_schedule_next(train)
      end
    end
  end

  if delivery.requester then
    delivery.requester.trainRequested = false
  end

  global.deliveries[train.id] = nil

  if stop then
    stop.deliveringTrains[train.id] = nil
    dispatcher_update_stop_status(stop)
  end

  dispatcher_handle_requesters()
end


--
-- Test if the control behaviour's condition is met.
--
-- @param ctrl The control behaviour to test
-- @return True if the behaviour's condition is met, false if not
--
local function control_behaviour_met(ctrl)
  return not ctrl.disabled and
    ((ctrl.circuit_condition and ctrl.circuit_condition.fulfilled) or
     (ctrl.logistic_condition and ctrl.logistic_condition.fulfilled))
end


--
-- Handle requesters.
-- Called every couple of seconds or when a train finishes a delivery.
--
function dispatcher_handle_requesters()
  for _,requester in pairs(global.requesters) do
    if requester.stopId then
      local ctrl = requester.entity.get_or_create_control_behavior()
      if control_behaviour_met(ctrl) and requester.resourceName and requester.networkName then
        if not requester.trainRequested then
          dispatcher_request_delivery(requester)
        end
      else
        if requester.trainRequested then
          dispatcher_cancel_delivery(requester)
        end
      end
    end
  end
end


--
-- Handle delivery timeouts.
-- Called every couple of seconds.
--
function dispatcher_handle_deliveries()
  if not next(global.deliveries) then return end

  local timeout = settings.global['deliveryTimeout'].value * 60
  local timeoutTime = game.tick - timeout

  for trainId,delivery in pairs(global.deliveries) do
    if delivery.startTime < timeoutTime then
      dispatcher_abort_delivery(delivery, "message.delivery-timeout")
    end
  end
end

