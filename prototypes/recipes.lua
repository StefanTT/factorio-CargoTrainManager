-- Copyright (c) 2019 StefanT <stt1@gmx.at>
--
-- Original from Logistics Train Network, Copyright (c) 2017 Optera, MIT license
--
-- See LICENSE.md in the project directory for license information.
--

local trainStop = copy_prototype(data.raw["recipe"]["train-stop"], CTM_STOP)
trainStop.enabled = false
trainStop.ingredients = {
  {"train-stop", 1},
  {"constant-combinator", 1},
  {"small-lamp", 1},
  {"green-wire", 2},
  {"red-wire", 2}
}

local requester = copy_prototype(data.raw["recipe"]["small-lamp"], CTM_REQUESTER)
requester.enabled = false
requester.ingredients = {
  {"small-lamp", 1},
  {"electronic-circuit", 2}
}


data:extend({
  trainStop,
  requester
})

