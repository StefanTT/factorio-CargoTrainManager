-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

--
-- Update the pending requests tab.
--
-- @param parent The LuaGuiElement of the tab's parent element
-- @param player The player
--
function update_dialog_tab_pending(parent, player)
  parent.clear()

  local playerSurfaceId = player.surface.index
  local table = parent.add{type = "table", direction = "vertical", column_count = 5}

  table.add{type = "label", caption = {"label.dialog-col-resource"}, tooltip = {"tooltip.dialog-col-resource"}}
  table.add{type = "label", caption = {"label.dialog-col-network"}, tooltip = {"tooltip.dialog-col-network"}}
  table.add{type = "label", caption = {"label.dialog-col-stopName"}}
  table.add{type = "label", caption = {"label.dialog-col-wait"}}
  table.add{type = "empty-widget"}

  local resources = global.resources
  local requesters = global.requesters
  local stops = global.stops
  local pending = {}

  -- collect pending deliveries
  for _,resource in pairs(resources) do
    for __,requester in pairs(resource.pending) do
      pending[#pending + 1] = requester
      log("pending delivery: "..resource.resourceName.." / "..resource.networkName)
    end
  end

  local signal, sprite, stop
  local now = game.tick

  for i,requester in pairs(pending) do
    if requester.statusSince then
      requester._sort = math.floor((now - requester.statusSince) / 60)
      if requester._sort < 0 then requester._sort = 71582788 + requester._sort end
    else
      requester._sort = -i
    end
  end

  local comp = function(a,b)
    return pending[a]._sort > pending[b]._sort
  end

  for idx,requester in sorted_pairs(pending, comp) do
    signal = strToSignalId(requester.resourceName)
    if signal then
      sprite = signalToSpritePath(signal)
      table.add{type = "sprite", sprite = sprite, tooltip = sprite }
    else
      table.add{type = "label", caption = " "}
    end
    
    signal = strToSignalId(requester.networkName)
    if signal then
      sprite = signalToSpritePath(signal)
      table.add{type = "sprite", sprite = sprite, tooltip = sprite }
    else
      table.add{type = "label", caption = " "}
    end

    stop = stops[requester.stopId]
    if stop then
      table.add{type = "label", caption = stop.entity.backer_name}
    else
      table.add{type = "label", caption = " "}
    end

    if requester.statusSince then
      local wait = math.floor((now - requester.statusSince) / 60)
      if wait < 0 then wait = 71582788 + wait end

      if wait > 3600 then
        table.add{type = "label", caption = {"time.hours", math.floor(wait / 360 + 0.5) / 10}}
      elseif wait >= 60 then
        table.add{type = "label", caption = {"time.minutes", math.floor(wait / 6 + 0.5) / 10}}
      else
        table.add{type = "label", caption = {"time.seconds", wait}}
      end
    else
      table.add{type = "label", caption = " "}
    end

    if requester.entity.surface.index == playerSurfaceId then
      table.add{type = "sprite-button", sprite = "utility/center", style = "tool_button", tooltip = {"tooltip.show-on-map"},
                name = BTN_SHOW_ON_MAP_PREFIX..requester.entity.position.x..":"..requester.entity.position.y..":"..idx}
    else
      table.add{type = "empty-widget"}
    end
  end

  for _,requester in pairs(pending) do
    requester._sort = nil
  end
end

