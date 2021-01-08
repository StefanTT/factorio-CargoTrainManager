-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Initialize the global variables.
--
local function initGlobalVariables()
  log("init global variables")

  -- The last station a train was at.
  -- Key is the LuaTrain::id, value is the LuaEntity of the stop.
  global.lastTrainStation = global.lastTrainStation or {}

  -- The mod's data for train manager train stops.
  -- Key is the LuaEntity::entity_number of the stop, value is a structure with:
  --   entityId The entity_number of the entity
  --   entity The stop's LuaEntity entity
  --   lamp The stop's lamp entity
  --   lampCtrl The stop's lamp controller entity
  --   output The stop's constant comparator
  --   surfaceId The number of the surface
  --   forceId The number of the owning force
  --   networkName The name of the network
  --   resourceName The name of the resource
  --   canDeliver True if the stop has a train ready to do a delivery
  --   deliveringTrains A map of inbound delivery trains: key is the train ID, value is the resourceName
  --   numRequesters The number of associated requesters
  global.stops = global.stops or {}

  -- The mod's data for requesters.
  -- Key is the LuaEntity::entity_number of the requester, value is a structure with:
  --   entityId The entity_number of the entity
  --   entity The requester's LuaEntity entity
  --   stopId The entity_number of the train stop's entity
  --   surfaceId The number of the surface
  --   forceId The number of the owning force
  --   networkName The name of the network
  --   resourceName The name of the resource
  --   trainRequested True if a train has been requested for this requester, even if a train is already delivering
  --   statusSince The game time of the last status change
  global.requesters = global.requesters or {}

  -- The networked resources.
  -- Key is the dispatcher ID, value is a structure with:
  --   surfaceId The number of the surface
  --   forceId The number of the owning force
  --   networkName The name of the network
  --   resourceName The name of the resource
  --   stops A list of all stops that provide the resource in this network, ordered by the stop's priority
  --   pending A queue of requesters that are waiting for a train to be sent to them
  global.resources = global.resources or {}

  -- The ongoing deliveries.
  -- Key is the LuaTrain::id of the delivering train, value is a structure with:
  --   requester The requester at the destination of the delivery
  --   startTime The game time of the time when the train started the delivery run
  --   train The LuaTrain doing the delivery
  global.deliveries = global.deliveries or {}

  -- Dialog private data per player.
  -- Key is the player number, value depends on the currently opened dialog.
  global.dialogData = global.dialogData or {}
end


--
-- Called every time a save file is loaded except for the instance when a mod is loaded into
-- a save file that it previously wasn't part of. Must not change the game state.
--
script.on_load(function()
  log("loading")
  registerEvents()
  log("loaded")
end)


--
-- Called once when a new save game is created or once when a save file is loaded that previously
-- didn't contain the mod.
--
script.on_init(function()
  log("initializing")
  initGlobalVariables()
  registerEvents()
  log("initialized")
end)


--
-- Called any time the game version changes, prototypes change, startup mod settings change,
-- and any time mod versions change including adding or removing mods.
--
-- @param data The ConfigurationChangedData
--
script.on_configuration_changed(function(data)
  log("configuration changed")
  initGlobalVariables()
  registerEvents()
  log("mod "..script.mod_name.." configuration updated")
end)


--
-- Called when a runtime mod setting is changed by a player.
--
-- @param event containing:
--      - player_index The player who changed the setting or nil if changed by script
--      - setting The setting name that changed
--      - setting_type The setting type: "runtime-per-user", or "runtime-global"
-- 
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-per-user" then
    local player = game.get_player(event.player_index)
    if event.setting == "showToolButton" then
        updateToolbuttonVisibility(player)
    end
  end
end)

