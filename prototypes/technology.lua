-- Copyright (c) 2019 StefanT <stt1@gmx.at>
--
-- Original from Logistics Train Network, Copyright (c) 2017 Optera, MIT license
--
-- See LICENSE.md in the project directory for license information.
--

data:extend({
  {
    type = "technology",
    name = TECHNOLOGY_NAME,
    icon = "__CargoTrainManager__/thumbnail.png",
    icon_size = 144,
    prerequisites = {"automated-rail-transportation", "circuit-network"},
    effects =
    {
      { type = "unlock-recipe", recipe = CTM_STOP },
      { type = "unlock-recipe", recipe = CTM_REQUESTER }
    },
    unit =
    {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "c-g-c"
  }
})

