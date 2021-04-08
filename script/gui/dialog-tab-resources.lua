-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

--
-- Update the resources tab.
--
-- @param parent The LuaGuiElement of the tab's parent element
--
function update_dialog_tab_resources(parent)
  parent.clear()

  local table = parent.add{type = "table", direction = "vertical", column_count = 7 }
  local signal, sprite, elem, num, cnt

  table.add{type = "label", caption = {"label.dialog-col-resource"}, tooltip = {"tooltip.dialog-col-resource"}}
  table.add{type = "label", caption = {"label.dialog-col-network"}, tooltip = {"tooltip.dialog-col-network"}}
  table.add{type = "label", caption = {"label.dialog-col-name"}}
  table.add{type = "label", caption = {"label.dialog-col-surface"}}

  elem = table.add{type = "label", caption = {"label.dialog-col-numPending"}, tooltip = {"tooltip.dialog-col-numPending"}, style = "tm-label-right"}
  elem.style.width = 40

  elem = table.add{type = "label", caption = {"label.dialog-col-numStops"}, tooltip = {"tooltip.dialog-col-numStops"}, style = "tm-label-right"}
  elem.style.width = 40

  table.add{type = "label", caption = ""}

  local resources = global.resources

  for _,resource in pairs(resources) do
    local surface = game.surfaces[resource.surfaceId] or {}
    resource._label = signalIdToLocalName(strToSignalId(resource.resourceName)) or {}
    resource._sort = (resource._label[1] or 'zzz')..'^'..(resource.networkName or 'zzz')..'^'..surface.name
  end

  local comp = function(a,b)
    return resources[a]._sort < resources[b]._sort
  end

  for id,resource in sorted_pairs(resources, comp) do
    if resource.resourceName then
      signal = strToSignalId(resource.resourceName)
      if signal then
        sprite = signalToSpritePath(signal)
        table.add{type = "sprite", sprite = sprite, tooltip = sprite}
      else
        table.add{type = "label", caption=" "}
      end
      
      signal = strToSignalId(resource.networkName)
      if signal then
        sprite = signalToSpritePath(signal)
        table.add{type = "sprite", sprite = sprite, tooltip = sprite}
      else
        table.add{type = "label", caption=" "}
      end

      table.add{type = "label", caption=resource._label}

      local surface = game.surfaces[resource.surfaceId]
      if surface and surface.valid then
        elem = table.add{type = "label", caption = surface.name}
      else
        elem = table.add{type = "label", caption = ""}
      end
      elem.style.width = 200

      num = #resource.pending
      if num == 0 then num = '-' end
      elem = table.add{type = "label", caption = num, tooltip = {"tooltip.dialog-col-numPending"}, style = "tm-label-right"}
      elem.style.width = 40

      num = #resource.stops
      if num == 0 then
        elem = table.add{type = "label", caption = "0", tooltip = {"tooltip.dialog-col-numStops"}, style = "tm-label-right"}
      else
        cnt = 0
        for _,stop in pairs(resource.stops) do
          if stop.canDeliver then
            cnt = cnt + 1
          end
        end
        elem = table.add{type = "label", caption = cnt.."/"..num, tooltip = {"tooltip.dialog-col-numStops"}, style = "tm-label-right"}
      end
      elem.style.width = 40

      local btn = table.add{type = "button", name = BTN_RESOURCE_DETAILS_PREFIX..id, caption = "...", style = "tool_button",
                 tooltip={"tooltip.dialog-resource-open-details"}}
      if num == 0 then
        btn.enabled = false
      end
    end
  end

  for _,resource in pairs(resources) do
    resource._sort = nil
    resource._label = nil
  end
end

