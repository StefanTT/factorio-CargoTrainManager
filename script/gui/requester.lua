-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

mod_gui = require("mod-gui")


--
-- Close the requester dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function close_requester_dialog(player)
  local dialog = player.gui.relative[REQUESTER_DIALOG_NAME]
  if dialog then
    dialog.destroy()
  end
end


--
-- Open the requester dialog for a player.
--
-- @param player The player to refresh the dialog for
-- @param entityId The entity ID of the requester
--
function open_requester_dialog(player, entityId)
  local dialog = player.gui.relative[REQUESTER_DIALOG_NAME]
  if dialog then
    dialog.destroy()
  end

  local btnResource, btnNetwork

  dialog = player.gui.relative.add{type = "frame", name = REQUESTER_DIALOG_NAME, direction = "vertical",
             anchor = {gui = defines.relative_gui_type.lamp_gui, position = defines.relative_gui_position.right},
             caption = {"caption.requester-frame"}}
  local table = dialog.add{ name = "table", type = "table", column_count = 2 }
  table.add{ type = "label", caption = {"label.requester_resource"}, tooltip = {"tooltip.requester_resource"} }
  btnResource = table.add{ type = "choose-elem-button", name = "tm-requester-resource", elem_type = "signal" }
  table.add{ type = "label", caption = {"label.requester_network"}, tooltip = {"tooltip.requester_network"} }
  btnNetwork = table.add{ type = "choose-elem-button", name = "tm-requester-network", elem_type = "signal" }

  local requester = global.requesters[entityId] or {}
  btnResource.elem_value = strToSignalId(requester.resourceName)
  btnNetwork.elem_value = strToSignalId(requester.networkName)

  dialog.add{ type = "label", caption = {"caption.requester-stop"}, style= "caption_label" }

  local stops = find_stops_near(requester.entity)

  if #stops == 0 then
      dialog.add{ type = "label", style = "tm-error-text", caption = {"message.requester-no-stop-nearby"},
                  tooltip = {"error.noStopFound"},}
  else
    dialog.add{ type = "label", caption = stops[1].backer_name }
  end

  local ctrl = requester.entity.get_control_behavior()
  if #stops > 0 and not ctrl.get_circuit_network(defines.wire_type.red)
         and not ctrl.get_circuit_network(defines.wire_type.green) then
    dialog.add{ type = "label", style = "tm-error-text", caption = {"message.requester-not-connected"},
                tooltip = {"tooltip.requester-not-connected"},}
  end

  global.dialogData[player.index] = { requesterEntityId = entityId }
end


--
-- The value of a requester dialog element was changed by a player.
--
-- @param playerId The index of the player wo changed it
-- @param elem The LuaGuiElement which was changed
--
function requester_dialog_elem_changed(playerId, elem)
  local dialogData = global.dialogData[playerId]
  if not dialogData then return end

  local requester = global.requesters[dialogData.requesterEntityId]

  if elem.name == "tm-requester-resource" then
    update_requester_config(requester, signalIdToStr(elem.elem_value), requester.networkName)
  elseif elem.name == "tm-requester-network" then
    update_requester_config(requester, requester.resourceName, signalIdToStr(elem.elem_value))
  end
end

