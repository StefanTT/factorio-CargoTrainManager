--[[ Copyright (c) 2019 Optera
 * Part of Optera's Function Library
 *
 * See LICENSE.md in the project directory for license information.
--]]

--
-- Copies prototypes and assigns new name and minable.
--
-- @param prototype
-- @param new_name
-- @return The copied prototype
--
function copy_prototype(prototype, new_name)
  if not prototype.type or not prototype.name then
    error("Invalid prototype: prototypes must have name and type properties.")
    return nil
  end
  local p = table.deepcopy(prototype)
  p.name = new_name
  if p.minable and p.minable.result then
    p.minable.result = new_name
  end
  if p.place_result then
    p.place_result = new_name
  end
  if p.result then
    p.result = new_name
  end
  if p.results then
    for _,result in pairs(p.results) do
      if result.name == prototype.name then
        result.name = new_name
      end
    end
  end
  return p
end

