-- Copyright (c) 2019 StefanT <stt1@gmx.at>
--
-- Original from Logistics Train Network, Copyright (c) 2017 Optera, MIT license
--
-- See LICENSE.md in the project directory for license information.
--

local ctmStop = copy_prototype(data.raw["train-stop"]["train-stop"], CTM_STOP)
ctmStop.icon = "__CargoTrainManager__/graphics/icons/train-stop.png"
ctmStop.icon_size = 32
ctmStop.next_upgrade = nil
ctmStop.selection_box = {{-0.6, -0.6}, {0.6, 0.6}}
ctmStop.collision_box = {{-0.5, -0.1}, {0.5, 0.4}}

local ctmStopLamp = copy_prototype(data.raw["lamp"]["small-lamp"], CTM_STOP_LAMP)
ctmStopLamp.icon = "__CargoTrainManager__/graphics/icons/train-stop.png"
ctmStopLamp.icon_size = 32
ctmStopLamp.next_upgrade = nil
ctmStopLamp.minable = nil
ctmStopLamp.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ctmStopLamp.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
ctmStopLamp.energy_usage_per_tick = "10W"
ctmStopLamp.light = { intensity = 1, size = 6 }
ctmStopLamp.energy_source = {type="void"}

local ctmStopOut = copy_prototype(data.raw["constant-combinator"]["constant-combinator"], CTM_STOP_OUTPUT)
ctmStopOut.icon = "__CargoTrainManager__/graphics/icons/output.png"
ctmStopOut.icon_size = 32
ctmStopOut.next_upgrade = nil
ctmStopOut.minable = nil
ctmStopOut.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ctmStopOut.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
ctmStopOut.item_slot_count = 50
ctmStopOut.sprites = make_4way_animation_from_spritesheet(
  { layers =
    {
      {
        filename = "__CargoTrainManager__/graphics/entity/output.png",
        width = 58,
        height = 52,
        frame_count = 1,
        shift = util.by_pixel(0, 5),
        hr_version =
        {
          scale = 0.5,
          filename = "__CargoTrainManager__/graphics/entity/hr-output.png",
          width = 114,
          height = 102,
          frame_count = 1,
          shift = util.by_pixel(0, 5),
        },
      },
      {
        filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
        width = 50,
        height = 34,
        frame_count = 1,
        shift = util.by_pixel(9, 6),
        draw_as_shadow = true,
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
          width = 98,
          height = 66,
          frame_count = 1,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true,
        },
      },
    },
  })

local controlConnectionPoints = {
  red = util.by_pixel(-3, -7),
  green = util.by_pixel(-1, 0)
}

local controlLampSprite = {
  filename = "__CargoTrainManager__/graphics/icons/empty.png",
  x = 0,
  y = 0,
  width = 1,
  height = 1,
  frame_count = 1,
  shift = {0, 0},
}

local controlLampActivityLedSprite = {
  filename = "__CargoTrainManager__/graphics/icons/empty.png",
  width = 1,
  height = 1,
  frame_count = 1,
  shift = {0.0, 0.0},
}

local ctmStopLampCtrl = copy_prototype(data.raw["constant-combinator"]["constant-combinator"], CTM_STOP_LAMP_CTRL)
ctmStopLampCtrl.icon = "__CargoTrainManager__/graphics/icons/empty.png"
ctmStopLampCtrl.icon_size = 32
ctmStopLampCtrl.next_upgrade = nil
ctmStopLampCtrl.minable = nil
ctmStopLampCtrl.selection_box = {{-0.0, -0.0}, {0.0, 0.0}}
ctmStopLampCtrl.collision_box = {{-0.0, -0.0}, {0.0, 0.0}}
ctmStopLampCtrl.collision_mask = { "resource-layer" }
ctmStopLampCtrl.item_slot_count = 50
ctmStopLampCtrl.flags = {"not-blueprintable", "not-deconstructable"}
ctmStopLampCtrl.sprites = { north = controlLampSprite, east = controlLampSprite, south = controlLampSprite, west = controlLampSprite }
ctmStopLampCtrl.activity_led_sprites = { north = controlLampActivityLedSprite, east = controlLampActivityLedSprite,
                                        south = controlLampActivityLedSprite, west = controlLampActivityLedSprite }
ctmStopLampCtrl.activity_led_light =
{
  intensity = 0.0,
  size = 0,
}
ctmStopLampCtrl.circuit_wire_connection_points =
{
  { shadow = controlConnectionPoints, wire = controlConnectionPoints },
  { shadow = controlConnectionPoints, wire = controlConnectionPoints },
  { shadow = controlConnectionPoints, wire = controlConnectionPoints },
  { shadow = controlConnectionPoints, wire = controlConnectionPoints },
}


local ctmRequester = copy_prototype(data.raw["lamp"]["small-lamp"], CTM_REQUESTER)
ctmRequester.icon = "__CargoTrainManager__/graphics/icons/requester.png"
ctmRequester.icon_size = 32
ctmRequester.next_upgrade = nil
ctmRequester.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ctmRequester.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
ctmRequester.energy_usage_per_tick = "10W"
ctmRequester.light = { intensity = 1, size = 6 }
ctmRequester.energy_source = {type = "void"}


data:extend({
  ctmStop,
  ctmStopLamp,
  ctmStopLampCtrl,
  ctmStopOut,
  ctmRequester
})

