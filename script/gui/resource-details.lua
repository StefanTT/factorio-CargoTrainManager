-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

--
-- Close the resource details dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function close_resource_details_dialog(player)
  local dialog = player.gui.screen[RESOURCE_DETAILS_DIALOG_NAME]
  if dialog then
    dialog.visible = false
  end
end


--
-- Add the title bar to the dialog
--
-- @param dialog The dialog to add the titlebar
--
local function dialog_add_tilebar(dialog)
  local titlebar = dialog.add{type = "flow", name = "flow_titlebar", direction = "horizontal"}
  titlebar.drag_target = dialog
  
  local title = titlebar.add{type = "label", style = "large_caption_label", caption = {"caption.resource-details"}}
  title.drag_target = dialog

  local handle = titlebar.add{type = "empty-widget", style = "draggable_space"}
  handle.drag_target = dialog
  handle.style.horizontally_stretchable = true
  handle.style.top_margin = 2
  handle.style.height = 24
  handle.style.width = 120

  local flow_buttonbar = titlebar.add{type = "flow", direction = "horizontal"}
  flow_buttonbar.style.top_margin = 4

  local closeButton = flow_buttonbar.add{type = "sprite-button", name = RESOURCE_DETAILS_CLOSE_NAME, style = "close_button",
                                         sprite = "utility/close_white", mouse_button_filter = {"left"}}
  closeButton.style.left_margin = 2
end


--
-- Setup the table of the provider train stops
--
-- @param id The delivery ID of the resource
-- @param parent The parent GUI element
--
local function setup_table(id, parent)
  local table = parent.add{type = "table", direction = "vertical", column_count = 4 }

  local resource = global.resources[id]
  if not resource then return end

  local btnUp, btnDown, lbl
  local first = true
  for idx,stop in pairs(resource.stops) do
    if stop.entity.valid then

      table.add{type = "sprite", sprite = "item/train-stop"}

      lbl = table.add{type = "label", caption = stop.entity.backer_name}
      lbl.style.width = 200
      
      if first then
        first = false
        table.add{type = "empty-widget"}
      else
        table.add{type = "sprite-button", sprite = "ctm-up", style = "ctm_small_button",
                tooltip = {"tooltip.resource-priority-up"}, name = BTN_RESOURCE_UP_PREFIX..idx}
      end
      btnDown = table.add{type = "sprite-button", sprite = "ctm-down", style = "ctm_small_button",
                tooltip = {"tooltip.resource-priority-down"}, name = BTN_RESOURCE_DOWN_PREFIX..idx}
    end
  end

  if btnDown then
    btnDown.destroy()
  end
end


--
-- Open the resource details dialog for a player.
--
-- @param id The delivery ID of the resource
-- @param player The player to open the dialog for
--
function open_resource_details_dialog(id, player)
  local dialog = player.gui.screen[RESOURCE_DETAILS_DIALOG_NAME]

--  if dialog then
--    dialog.destroy()
--    dialog = nil
--  end

  if dialog == nil then 
    dialog = player.gui.screen.add{type = "frame", name = RESOURCE_DETAILS_DIALOG_NAME, direction = "vertical",
                                   auto_center = true}
    dialog.location = {200, 150}
    dialog.style.minimal_height = 300;
    dialog.style.maximal_height = 800;

    dialog_add_tilebar(dialog)
    dialog.add{type = "scroll-pane", horizontal_scroll_policy = "never", name = "pane" }
  else
    dialog["pane"].clear()
    dialog.visible = true  
  end

  setup_table(id, dialog["pane"])
  global.dialogData[player.index] = { deliveryId = id }
end


--
-- Decrease the priority of a provider stop for providing the currently opened resource.
--
-- @param index The index of the resource
-- @param player The player
--
function resource_details_down(index, player)
  local id = global.dialogData[player.index]["deliveryId"]
  if not id then return end

  local resource = global.resources[id]
  if not resource or #resource.stops < index then return end

  local stop = table.remove(resource.stops, index)
  table.insert(resource.stops, index + 1, stop)

  open_resource_details_dialog(id, player)
end


--
-- Increase the priority of a provider stop for providing the currently opened resource.
--
-- @param index The index of the resource
-- @param player The player
--
function resource_details_up(index, player)
  local id = global.dialogData[player.index]["deliveryId"]
  if not id then return end

  local resource = global.resources[id]
  if not resource or #resource.stops < index then return end

  local stop = table.remove(resource.stops, index)
  table.insert(resource.stops, index - 1, stop)

  open_resource_details_dialog(id, player)
end

