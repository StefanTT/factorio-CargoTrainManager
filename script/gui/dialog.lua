-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Close the dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function close_dialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]
  if dialog then
    dialog.visible = false
    close_resource_details_dialog(player)
  end
end


--
-- Toggle the dialog for a player.
--
-- @param player The player to toggle the dialog for
-- 
function toggle_dialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]
  local visible = nil

  if dialog == nil then
    dialog = open_dialog(player, true)
  elseif dialog.visible then
    dialog.visible = false
    close_resource_details_dialog(player)
  else
    --open_dialog(player)
    open_dialog(player, true) -- always do a full dialog refresh during development
  end

  player.opened = visible and dialog or nil
end


--
-- Add the title bar to the dialog
--
-- @param dialog The dialog to add the titlebar
--
local function dialog_add_tilebar(dialog)
  local titlebar = dialog.add{type = "flow", name = "flow_titlebar", direction = "horizontal"}
  titlebar.drag_target = dialog
  
  local title = titlebar.add{type = "label", style = "caption_label", caption = {"caption.dialog"}}
  title.drag_target = dialog
  --title.style.font = "caption_label"

  local handle = titlebar.add{type = "empty-widget", style = "draggable_space"}
  handle.drag_target = dialog
  handle.style.horizontally_stretchable = true
  handle.style.top_margin = 2
  handle.style.height = 24
  handle.style.width = 260

  local flow_buttonbar = titlebar.add{type = "flow", direction = "horizontal"}
  flow_buttonbar.style.top_margin = 4

  local closeButton = flow_buttonbar.add{type = "sprite-button", name = DIALOG_CLOSE_NAME, style = "frame_action_button",
                                         sprite = "utility/close_white", mouse_button_filter = {"left"}}
  closeButton.style.left_margin = 2
end


--
-- Open the main dialog for a player.
--
-- @param player The player to open the dialog for
--
function open_dialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]

--  if dialog then
--    dialog.destroy()
--    dialog = nil
--  end

  if dialog == nil then 
    dialog = player.gui.screen.add{type = "frame", name = DIALOG_NAME, direction = "vertical",
                                   auto_center = true}
    dialog.location = {100, 100}
    dialog.style.minimal_height = 400;
    dialog.style.maximal_height = 900;

    dialog_add_tilebar(dialog)

    local tabbedPane = dialog.add{type = "tabbed-pane", name = "tm-dialog-pane"}
    tabbedPane.selected_tab_index = 1

    local contents
    contents = tabbedPane.add{type = "scroll-pane", horizontal_scroll_policy = "never" }
    tabbedPane.add_tab(tabbedPane.add{type = "tab", name = "resources", caption = {"caption.dialog-tab-resources"}}, contents)

    contents = tabbedPane.add{type = "scroll-pane", horizontal_scroll_policy = "never" }
    tabbedPane.add_tab(tabbedPane.add{type = "tab", name = "provider", caption = {"caption.dialog-tab-provider"}}, contents)

    contents = tabbedPane.add{type = "scroll-pane", horizontal_scroll_policy = "never" }
    tabbedPane.add_tab(tabbedPane.add{type = "tab", name = "requester", caption = {"caption.dialog-tab-requester"}}, contents)

    contents = tabbedPane.add{type = "scroll-pane", horizontal_scroll_policy = "never" }
    tabbedPane.add_tab(tabbedPane.add{type = "tab", name = "deliveries", caption = {"caption.dialog-tab-deliveries"}}, contents)

    contents = tabbedPane.add{type = "scroll-pane", horizontal_scroll_policy = "never" }
    tabbedPane.add_tab(tabbedPane.add{type = "tab", name = "pending", caption = {"caption.dialog-tab-pending"}}, contents)
  end

  dialog_tab_changed(player.index, dialog["tm-dialog-pane"])
  dialog.visible = true

  return dialog
end


--
-- The selected tab was changed
--
-- @param playerId The player index
-- @param element :: LuaGuiElement: The tabbed pane whose selected tab changed
--
function dialog_tab_changed(playerId, element)
  local player = game.players[playerId]
  if element.name == "tm-dialog-pane" then
    local tabAndContent = element.tabs[element.selected_tab_index]
    if tabAndContent.tab.name == "resources" then
      update_dialog_tab_resources(tabAndContent.content, player)
    elseif tabAndContent.tab.name == "provider" then
      update_dialog_tab_provider(tabAndContent.content, player)
    elseif tabAndContent.tab.name == "requester" then
      update_dialog_tab_requester(tabAndContent.content, player)
    elseif tabAndContent.tab.name == "pending" then
      update_dialog_tab_pending(tabAndContent.content, player)
    elseif tabAndContent.tab.name == "deliveries" then
      update_dialog_tab_deliveries(tabAndContent.content, player)
    end
  end
end

