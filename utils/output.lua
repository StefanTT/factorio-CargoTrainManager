-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


-- Write a message to the player. Does nothing if the player index is unset
-- 
-- @param playerId The index of the player to write to
-- @param msg The message to write
function print_player(playerId, msg)
  if playerId then
    local player = game.players[playerId]
    if player then
      player.print{msg}
    end
  end
end


-- Write a message to the console of everybody or all members of a force
-- @param msg The message to write
-- @param force The force to write to, nil to write to everybody
function printmsg(msg, force)
  if force and force.valid then
    force.print(msg)
  else
    game.print(msg)
  end
  log(msg)
end

