-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Update the requesters tab.
--
-- @param parent The LuaGuiElement of the tab's parent element
-- @param player The player
--
function update_dialog_tab_requester(parent, player)
  parent.clear()

  local playerSurfaceId = player.surface.index
  local table = parent.add{type = "table", direction = "vertical", column_count = 5 }

  table.add{type = "label", caption = {"label.dialog-col-resource"}, tooltip = {"tooltip.dialog-col-resource"}}
  table.add{type = "label", caption = {"label.dialog-col-network"}, tooltip = {"tooltip.dialog-col-network"}}
  table.add{type = "label", caption = {"label.dialog-col-stopName"}}
  table.add{type = "label", caption = {"label.dialog-col-surface"}}
  table.add{type = "empty-widget"}

  local stops = global.stops
  local requesters = global.requesters
  local signal, sprite, stopName, stopEntity

  for _,requester in pairs(requesters) do
    if requester.stopId then
      stopName = stops[requester.stopId].entity.backer_name
    else
      stopName = "zzz"
    end
    requester._stopName = stopName
    requester._sort = (requester.resourceName or 'zzz')..'^'..(requester.networkName or 'zzz')..'^'..stopName
  end

  local comp = function(a,b)
    return requesters[a]._sort < requesters[b]._sort
  end

  for _,requester in sorted_pairs(requesters, comp) do
    signal = strToSignalId(requester.resourceName)
    if signal then
      sprite = signalToSpritePath(signal)
      table.add{type = "sprite", sprite = sprite, tooltip = sprite}
    else
      table.add{type = "empty-widget"}
    end

    signal = strToSignalId(requester.networkName)
    if signal then
      sprite = signalToSpritePath(signal)
      table.add{type = "sprite", sprite = sprite, tooltip = sprite}
    else
      table.add{type = "empty-widget"}
    end

    table.add{type = "label", caption = requester._stopName}

    local surface = game.surfaces[requester.surfaceId]
    if surface and surface.valid then
      table.add{type = "label", caption = surface.name}
    else
      table.add{type = "empty-widget"}
    end

    if requester.entity.surface.index == playerSurfaceId then
      table.add{type = "sprite-button", sprite = "utility/center", style = "tool_button", tooltip = {"tooltip.show-on-map"},
                name = BTN_SHOW_ON_MAP_PREFIX..requester.entity.position.x..":"..requester.entity.position.y}
    else
      table.add{type = "empty-widget"}
    end
  end

  for _,requester in pairs(requesters) do
    requester._sort = nil
    requester._stopName = nil
  end
end

