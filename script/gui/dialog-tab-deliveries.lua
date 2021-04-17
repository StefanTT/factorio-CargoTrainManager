-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Update the deliveries tab.
--
-- @param parent The LuaGuiElement of the tab's parent element
-- @param player The player
--
function update_dialog_tab_deliveries(parent, player)
  parent.clear()

  local playerSurfaceId = player.surface.index
  local table = parent.add{type = "table", direction = "vertical", column_count = 5 }

  table.add{type = "label", caption = {"label.dialog-col-resource"}, tooltip = {"tooltip.dialog-col-resource"}}
  table.add{type = "label", caption = {"label.dialog-col-network"}, tooltip = {"tooltip.dialog-col-network"}}
  table.add{type = "label", caption = {"label.dialog-col-stopName"}}
  table.add{type = "label", caption = {"label.dialog-col-since"}}
  table.add{type = "empty-widget"}

  local signal, sprite, stop
  local now = game.tick

  local idx = 0
  for trainId,delivery in pairs(global.deliveries) do
    idx = idx + 1
    local requester = delivery.requester
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

    stop = global.stops[requester.stopId]
    if stop then
      table.add{type = "label", caption = stop.entity.backer_name}
    else
      table.add{type = "label", caption = " "}
    end

    local wait = math.floor((now - delivery.startTime) / 60)
    if wait < 0 then wait = 71582788 + wait end

    if wait > 3600 then
      table.add{type = "label", caption = {"time.hours", math.floor(wait / 360 + 0.5) / 10}}
    elseif wait >= 60 then
      table.add{type = "label", caption = {"time.minutes", math.floor(wait / 6 + 0.5) / 10}}
    else
      table.add{type = "label", caption = {"time.seconds", wait}}
    end

    local locomotive = main_locomotive(delivery.train)
    if locomotive and locomotive.surface.index == playerSurfaceId then
      table.add{type = "sprite-button", sprite = "utility/center", style = "tool_button", tooltip = {"tooltip.show-on-map"},
                name = BTN_SHOW_TRAIN_PREFIX..trainId..":"..idx}
    else
      table.add{type = "empty-widget"}
    end
  end
end

