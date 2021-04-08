-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- An entity was created.
--
-- @param event The event containing
--        created_entity or entity :: LuaEntity
--        player_index :: uint
--
function onEntityCreated(event)
  local entity = event.created_entity or event.entity
  if not entity or not entity.valid then return end

  if entity.type == STOP_TYPE and entity.name == CTM_STOP then
    onStopCreated(entity, event.player_index)
  elseif entity.type == REQUESTER_TYPE and entity.name == CTM_REQUESTER then
    onRequesterCreated(entity, event.player_index)
  end
end


--
-- An entity was removed.
--
-- @param event The event containing
--        entity :: LuaEntity: The entity being removed
-- 
--
function onEntityRemoved(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  if entity.train then
    onTrainRemoved(entity.train)
  elseif entity.type == STOP_TYPE and entity.name == CTM_STOP then
    onStopRemoved(entity)
  elseif entity.type == REQUESTER_TYPE and entity.name == CTM_REQUESTER then
    onRequesterRemoved(entity)
  end
end


--
-- A research was finished.
--
-- @param event The event containing
--        research :: LuaTechnology: The researched technology
--        by_script :: boolean: If the technology was researched by script
--
function onResearchFinished(event)
  if event.research.name == TECHNOLOGY_NAME then
    show_toolbutton_all()
  end
end


--
-- Toggle the console window.
--
-- @param event The event
--
function onToggleConsole(event)
	toggle_dialog(game.players[event.player_index])
end


--
-- Handle a shortcut event.
--
-- @param event The event
--
local function onShortcut(event)
  if event.prototype_name == "ctm-toggle-console" then
    toggle_dialog(game.players[event.player_index])
  end
end


--
-- Register the event callbacks.
--
function registerEvents()
  log("registering events")

  registerGuiEvents()

  script.on_event(defines.events.on_train_changed_state, onTrainChangedState)
  script.on_event(defines.events.on_train_created, onTrainCreated)
  script.on_event(defines.events.on_research_finished, onResearchFinished)
  script.on_event("ctm-toggle-console", onToggleConsole)
  script.on_event(defines.events.on_lua_shortcut, onShortcut)

  script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
  }, onEntityCreated)

  script.on_event({
    defines.events.on_pre_player_mined_item,
    defines.events.on_robot_pre_mined,
    defines.events.on_entity_died,
    script_raised_destroy
  }, onEntityRemoved)

--  TODO?
--  script.on_event({
--    defines.events.on_pre_surface_deleted,
--    defines.events.on_pre_surface_cleared,
--  }, onSurfaceRemoved)

  script.on_nth_tick(nil)
  script.on_nth_tick(113, dispatcher_handle_requesters)
  script.on_nth_tick(307, dispatcher_handle_deliveries)
end

