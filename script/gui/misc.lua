-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

mod_gui = require("mod-gui")

local networkIdNames = "0123456789"


--
-- Open the world view for a player at a specific position
--
-- @param playerId The player index to open the map for
-- @param x The x position on the map
-- @param y The y position on the map
-- @param zoom The zoom level (optional)
--
function player_zoom_to_world(playerId, x, y, zoom)
  local player = game.players[playerId]
  player.opened = nil
  close_dialog(player)
  close_resource_details_dialog(player)
  player.zoom_to_world({x = x, y = y }, zoom or DEFAULT_WORLD_ZOOM)
end


--
-- Open the map for a player at a specific position
--
-- @param playerId The player index to open the map for
-- @param x The x position on the map
-- @param y The y position on the map
-- @param zoom The zoom level (optional)
--
function player_open_map(playerId, x, y, zoom)
  local player = game.players[playerId]
  player.opened = nil
  close_dialog(player)
  close_resource_details_dialog(player)
  player.open_map({x = x, y = y }, zoom or DEFAULT_MAP_ZOOM)
end


--
-- Open the map for a player at the current position of the train with the given index.
-- Trains are searched on the player's surface.
--
-- @param playerId The player index to open the map for
-- @param trainId The LuaTrain::id of the train
--
function player_open_map_at_train(playerId, trainId)
  local player = game.players[playerId]
  for _,train in pairs(player.surface.get_trains(player.force)) do
    if train.id == trainId then
      local locomotive = main_locomotive(train)
      if locomotive then
        player.selected = locomotive
        player_zoom_to_world(playerId, locomotive.position.x, locomotive.position.y, DEFAULT_TRAIN_WORLD_ZOOM)
      end
      return
    end
  end
end


--
-- Open an entity for a player
--
-- @param playerId The player index to open the entity for
-- @param entity The entity to open
--
function player_open_entity(playerId, entity)
  local player = game.players[playerId]
  if player and entity and entity.valid then
    player.opened = entity
  end
end

