-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

mod_gui = require("mod-gui")


--
-- Close the requester dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function close_requester_dialog(player)
  local dialog = mod_gui.get_frame_flow(player)[REQUESTER_DIALOG_NAME]
  if dialog then
    dialog.visible = false
  end
end


--
-- Open the requester dialog for a player.
--
-- @param player The player to refresh the dialog for
-- @param entityId The entity ID of the requester
--
function open_requester_dialog(player, entityId)
  local flow = mod_gui.get_frame_flow(player)
  local dialog = flow[REQUESTER_DIALOG_NAME]
  
  if dialog then
    dialog.destroy()
    dialog = nil
  end

  local btnResource, btnNetwork

  if dialog then
    dialog.visible = true
    btnResource = dialog["table"]["tm-requester-resource"]
    btnNetwork = dialog["table"]["tm-requester-network"]
  else
    dialog = flow.add{ type = "frame", name = REQUESTER_DIALOG_NAME, direction = "vertical", caption = {"caption.requester"} }
    local table = dialog.add{ name = "table", type = "table", column_count = 2 }
    table.add{ type = "label", caption = {"label.requester_resource"}, tooltip = {"tooltip.requester_resource"} }
    btnResource = table.add{ type = "choose-elem-button", name = "tm-requester-resource", elem_type = "signal" }
    table.add{ type = "label", caption = {"label.requester_network"}, tooltip = {"tooltip.requester_network"} }
    btnNetwork = table.add{ type = "choose-elem-button", name = "tm-requester-network", elem_type = "signal" }
  end

  local config = global.requesters[entityId] or {}
  btnResource.elem_value = strToSignalId(config.resourceName)
  btnNetwork.elem_value = strToSignalId(config.networkName)

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

