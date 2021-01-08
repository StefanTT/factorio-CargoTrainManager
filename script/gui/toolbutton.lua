-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

mod_gui = require("mod-gui")


--
-- Show the toolbutton for a specific player.
--
-- @param player The player to create the toolbutton for
--
function showToolbuttonPlayer(player)
  local flow = mod_gui.get_button_flow(player)

  local button = flow.ctm_toolbutton
  if button then return end

  flow.add{ type = "sprite-button", name = TOOLBUTTON_NAME, sprite = "ctm-tool-button",
            style = mod_gui.button_style, tooltip = {"tooltip.toolbutton"} }
end


--
-- Hide the toolbutton for a specific player.
--
-- @param player The player to remove the toolbutton for
--
function hideToolbuttonPlayer(player)
  local flow = mod_gui.get_button_flow(player)

  local button = flow.ctm_toolbutton
  if button then
    button.destroy()
  end
end


--
-- Update the visibility of the toolbutton for a player.
--
-- @param player The player to update for
--
function updateToolbuttonVisibility(player)
  local flow = mod_gui.get_button_flow(player)

  local settings = settings.get_player_settings(player)
  if settings["showToolButton"].value then
    showToolbuttonPlayer(player)
  else
    hideToolbuttonPlayer(player)
  end
end


--
-- Show the toolbutton for all players.
--
function show_toolbutton_all()
  for _,player in pairs(game.players) do
    updateToolbuttonVisibility(player)
  end
end

