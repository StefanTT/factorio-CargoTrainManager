-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Update the provider stops tab.
--
-- @param parent The LuaGuiElement of the tab's parent element
-- @param player The player
--
function update_dialog_tab_provider(parent, player)
  parent.clear()

  local playerSurfaceId = player.surface.index
  local table = parent.add{type = "table", direction = "vertical", column_count = 5 }

  table.add{type = "label", caption = {"label.dialog-col-resource"}, tooltip = {"tooltip.dialog-col-resource"}}
  table.add{type = "label", caption = {"label.dialog-col-network"}, tooltip = {"tooltip.dialog-col-network"}}
  table.add{type = "label", caption = {"label.dialog-col-stopName"}}
  table.add{type = "label", caption = {"label.dialog-col-surface"}}
  table.add{type = "empty-widget"}

  local stops = {}
  local signal, sprite

  for _,stop in pairs(global.stops) do
    if stop.numRequesters == 0 and stop.entity.valid then
      stop._sort = (stop.resourceName or 'zzz')..'^'..(stop.networkName or 'zzz')..'^'..stop.entity.backer_name
      stops[#stops + 1] = stop
    end
  end

  local comp = function(a,b)
    return stops[a]._sort < stops[b]._sort
  end

  for _,stop in sorted_pairs(stops, comp) do
    if stop.resourceName then
      signal = strToSignalId(stop.resourceName)
      if signal then
        sprite = signalToSpritePath(signal)
        table.add{type = "sprite", sprite = sprite, tooltip = sprite }
      else
        table.add{type = "empty-widget"}
      end
      
      signal = strToSignalId(stop.networkName)
      if signal then
        sprite = signalToSpritePath(signal)
        table.add{type = "sprite", sprite = sprite, tooltip = sprite, tooltip = {"tooltip.show-on-map"} }
      else
        table.add{type = "empty-widget"}
      end

      table.add{type = "label", caption = stop.entity.backer_name}

      local surface = game.surfaces[stop.surfaceId]
      if surface and surface.valid then
        table.add{type = "label", caption = surface.name}
      else
        table.add{type = "empty-widget"}
      end

      if stop.entity.surface.index == playerSurfaceId then
        table.add{type = "sprite-button", sprite = "utility/center", style = "tool_button", tooltip = {"tooltip.show-on-map"},
                  name = BTN_SHOW_ON_MAP_PREFIX..stop.entity.position.x..":"..stop.entity.position.y}
      else
        table.add{type = "empty-widget"}
      end
    end
  end

  for _,stop in pairs(stops) do
    stop._sort = nil
  end
end

