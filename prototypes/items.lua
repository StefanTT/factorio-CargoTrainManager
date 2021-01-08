-- Copyright (c) 2019 StefanT <stt1@gmx.at>
--
-- Original from Logistics Train Network, Copyright (c) 2017 Optera, MIT license
--
-- See LICENSE.md in the project directory for license information.
--

local ctmStop = copy_prototype(data.raw["item"]["train-stop"], CTM_STOP)
ctmStop.icon = "__CargoTrainManager__/graphics/icons/train-stop.png"
ctmStop.icon_size = 32
ctmStop.order = ctmStop.order.."-c"

local ctmStopLamp = copy_prototype(data.raw["item"]["small-lamp"], CTM_STOP_LAMP)
ctmStopLamp.flags = {"hidden"}

local ctmStopLampCtrl = copy_prototype(data.raw["item"]["constant-combinator"], CTM_STOP_LAMP_CTRL)
ctmStopLampCtrl.flags = {"hidden"}
ctmStopLampCtrl.icon = "__CargoTrainManager__/graphics/icons/empty.png"
ctmStopLampCtrl.icon_size = 32

local ctmStopOut = copy_prototype(data.raw["item"]["constant-combinator"], CTM_STOP_OUTPUT)
ctmStopOut.flags = {"hidden"}
ctmStopOut.icon = "__CargoTrainManager__/graphics/icons/output.png"
ctmStopOut.icon_size = 32

local ctmRequester = copy_prototype(data.raw["item"]["small-lamp"], CTM_REQUESTER)
ctmRequester.icon = "__CargoTrainManager__/graphics/icons/requester.png"
ctmRequester.icon_size = 32
ctmRequester.subgroup = ctmStop.subgroup
ctmRequester.order = ctmStop.order.."-d"


data:extend({
  ctmStop,
  ctmStopLamp,
  ctmStopLampCtrl,
  ctmStopOut,
  ctmRequester
})

