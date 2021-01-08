-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

mod_gui = require("mod-gui")


--
-- Close the train stop dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function close_stop_dialog(player)
  local dialog = mod_gui.get_frame_flow(player)[STOP_DIALOG_NAME]
  if dialog then
    dialog.destroy()
  end
end


--
-- Open the train stop dialog in requester mode for a player.
--
-- @param entityId The entity ID of the stop
-- @param stop The stop
-- @param dialog The dialog frame to use
--
local function open_requester_stop_dialog(entityId, stop, dialog)

  dialog.caption = {"caption.requester-stop"}

  local topPane = dialog.add{name = "top-pane", type = "scroll-pane", horizontal_scroll_policy = "never"}

  topPane.add{type = "label", caption = {"label.requester-stop-table"}}
  local table = topPane.add{name = "table", type = "table", column_count = 7}
  
  local idx = 0
  for id,requester in pairs(global.requesters) do
    if requester.stopId == entityId then
      if requester.resourceName then
        table.add{type = "sprite", sprite = signalToSpritePath(strToSignalId(requester.resourceName))}
      else
        table.add{type = "sprite", sprite = "ctm-empty"}
      end
      if requester.networkName then
        table.add{type = "sprite", sprite = signalToSpritePath(strToSignalId(requester.networkName))}
      else
        table.add{type = "sprite", sprite = "ctm-empty"}
      end
      table.add{type = "button", name = BTN_OPEN_REQUESTER_PREFIX..id, caption = "...", style = "tool_button",
                tooltip = "{tooltip.stop_open_requester}"}

      idx = idx + 1
      if idx % 2 == 1 then
        table.add{ type = "empty-widget" }.style.width = 32
      end
    end
  end
end


--
-- Open the train stop dialog in provider mode for a player.
--
-- @param entityId The entity ID of the stop
-- @param stop The stop
-- @param dialog The dialog frame to use
--
local function open_provider_stop_dialog(entityId, stop, dialog)
  local table = dialog.add{ name = "table", type = "table", column_count = 2 }

  dialog.caption = {"caption.provider-stop"}

  lblResource = table.add{ type = "label", caption = {"label.stop_resource"}, name = "tm-stop-resource-lbl" }
  btnResource = table.add{ type = "choose-elem-button", name = "tm-stop-resource",
                           elem_type = "signal", signal = strToSignalId(stop.resourceName) }

  table.add{ type = "label", caption = {"label.stop_network"}, tooltip = {"tooltip.stop_network"} }
  btnNetwork = table.add{ type = "choose-elem-button", name = "tm-stop-network",
                          elem_type = "signal", signal = strToSignalId(stop.networkName) }
end


--
-- Open the train stop dialog for a player.
--
-- @param player The player to show the dialog for
-- @param entityId The entity ID of the stop
--
function open_stop_dialog(player, entityId)

  local stop = global.stops[entityId]
  if not stop then return end
  
  local lblResource, btnResource, btnNetwork

  local flow = mod_gui.get_frame_flow(player)
  local dialog = flow.add{ type = "frame", name = STOP_DIALOG_NAME, direction = "vertical" }

  if stop.numRequesters and stop.numRequesters > 0 then
    open_requester_stop_dialog(entityId, stop, dialog)
  else
    open_provider_stop_dialog(entityId, stop, dialog)
  end

  global.dialogData[player.index] = { stopEntityId = entityId }
end


--
-- The value of a dialog element was changed by a player.
--
-- @param playerId The index of the player wo changed it
-- @param elem The LuaGuiElement which was changed
--
function stop_dialog_elem_changed(playerId, elem)
  local dialogData = global.dialogData[playerId]
  if not dialogData then return end

  local stop = global.stops[dialogData.stopEntityId]

  if elem.name == "tm-stop-resource" then
    log("updating stop resource to "..tostring(signalIdToStr(elem.elem_value)))
    update_stop_config(stop, signalIdToStr(elem.elem_value), stop.networkName)
  elseif elem.name == "tm-stop-network" then
    update_stop_config(stop, stop.resourceName, signalIdToStr(elem.elem_value))
  end
end

