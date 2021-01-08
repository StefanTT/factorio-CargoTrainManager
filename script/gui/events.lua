-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- A GUI element was clicked.
--
-- @param event The event containing
--        element :: LuaGuiElement: The clicked element
--        player_index :: uint: The player who did the clicking
--        button :: defines.mouse_button_type: The mouse button used if any
--        alt :: boolean: If alt was pressed
--        control :: boolean: If control was pressed
--        shift :: boolean: If shift was pressed
--
function onGuiClick(event)
  local name = event.element.name
  if name == TOOLBUTTON_NAME then
    toggle_dialog(game.players[event.player_index])
  elseif name == DIALOG_CLOSE_NAME then
    close_dialog(game.players[event.player_index])
  elseif name == RESOURCE_DETAILS_CLOSE_NAME then
    close_resource_details_dialog(game.players[event.player_index])
  elseif string.find(name, BTN_SHOW_ON_MAP_PREFIX) then
    local parts = str_split(name, ":")
    player_zoom_to_world(event.player_index, tonumber(parts[2]), tonumber(parts[3]))
  elseif string.find(name, BTN_SHOW_TRAIN_PREFIX) then
    player_open_map_at_train(event.player_index, tonumber(string.sub(name, string.len(BTN_SHOW_TRAIN_PREFIX) + 1)))
  elseif string.find(name, BTN_RESOURCE_DETAILS_PREFIX) then
    open_resource_details_dialog(string.sub(name, string.len(BTN_RESOURCE_DETAILS_PREFIX) + 1), game.players[event.player_index])
  elseif string.find(name, BTN_RESOURCE_DOWN_PREFIX) then
    resource_details_down(tonumber(string.sub(name, string.len(BTN_RESOURCE_DOWN_PREFIX) + 1)), game.players[event.player_index])
  elseif string.find(name, BTN_RESOURCE_UP_PREFIX) then
    resource_details_up(tonumber(string.sub(name, string.len(BTN_RESOURCE_UP_PREFIX) + 1)), game.players[event.player_index])
  elseif string.find(name, BTN_OPEN_REQUESTER_PREFIX) then
    local entityId = tonumber(string.sub(name, string.len(BTN_OPEN_REQUESTER_PREFIX) + 1))
    player_open_entity(event.player_index, global.requesters[entityId].entity)
  end
end


--
-- A GUI element was changed.
--
-- @param event The event containing
--        element :: LuaGuiElement: The element whose state changed
--        player_index :: uint: The player who did the change
--
function onGuiElemChanged(event)
  --log("gui element changed")
  if string.sub(event.element.name, 1, 8) == "tm-stop-" then
    stop_dialog_elem_changed(event.player_index, event.element)
  elseif string.sub(event.element.name, 1, 13) == "tm-requester-" then
    requester_dialog_elem_changed(event.player_index, event.element)
  end
end


--
-- A GUI element was opened.
--
-- @param event The event containing
--        player_index :: uint: The player
--        gui_type :: defines.gui_type: The GUI type that was opened
--        entity :: LuaEntity (optional): The entity that was opened
--        item :: LuaItemStack (optional): The item that was opened
--        equipment :: LuaEquipment (optional): The equipment that was opened
--        other_player :: LuaPlayer (optional): The other player that was opened
--        element :: LuaGuiElement (optional): The custom GUI element that was opened
--
function onGuiOpened(event)
  --log("gui element opened "..event.gui_type)
  if not event.element then
    local player = game.players[event.player_index]

    -- hide the mod's dialogs if a game GUI is opened
    close_dialog(player)
    close_stop_dialog(player)
    close_requester_dialog(player)
    close_resource_details_dialog(player)

    if event.entity then
      if event.entity.type == STOP_TYPE and event.entity.name == CTM_STOP then
        open_stop_dialog(player, event.entity.unit_number)
      elseif event.entity.type == REQUESTER_TYPE and event.entity.name == CTM_REQUESTER then
        open_requester_dialog(player, event.entity.unit_number)
      end
    end
  end
end


--
-- A GUI element was closed.
--
-- @param event The event containing
--        player_index :: uint: The player
--        gui_type :: defines.gui_type: The GUI type that was open
--        entity :: LuaEntity (optional): The entity that was open
--        item :: LuaItemStack (optional): The item that was open
--        equipment :: LuaEquipment (optional): The equipment that was open
--        other_player :: LuaPlayer (optional): The other player that was open
--        element :: LuaGuiElement (optional): The custom GUI element that was open
--        technology :: LuaTechnology (optional): The technology that was automatically selected when opening the research GUI
--        tile_position :: TilePosition (optional): The tile position that was open
--
function onGuiClosed(event)
  --log("gui element closed "..event.gui_type)
  if event.entity then
    if event.entity.type == STOP_TYPE and event.entity.name == CTM_STOP then
      close_stop_dialog(game.players[event.player_index])
    elseif event.entity.type == REQUESTER_TYPE and event.entity.name == CTM_REQUESTER then
      close_requester_dialog(game.players[event.player_index])
    end
  end
end


--
-- The selected tab was changed.
--
-- @param event The event containing
--        element :: LuaGuiElement: The tabbed pane whose selected tab changed
--        player_index :: uint: The player
--
function onGuiSelectedTabChanged(event)
  if string.sub(event.element.name, 1, 10) == "tm-dialog-" then
    dialog_tab_changed(event.player_index, event.element)
  end
end


--
-- Register the event callbacks.
--
function registerGuiEvents()
  script.on_event(defines.events.on_gui_click, onGuiClick)
  script.on_event(defines.events.on_gui_opened, onGuiOpened)
  script.on_event(defines.events.on_gui_closed, onGuiClosed)
  script.on_event(defines.events.on_gui_elem_changed, onGuiElemChanged)
  script.on_event(defines.events.on_gui_selected_tab_changed, onGuiSelectedTabChanged)
end

