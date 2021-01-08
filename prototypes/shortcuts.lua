-- Copyright (c) 2020 StefanT <stt1@gmx.at>
--
-- See LICENSE.md in the project directory for license information.
--
data:extend{{
  type = "shortcut",
  action = "lua",
  name = "ctm-toggle-console",
  order = "m[ctm-console]",
  toggleable = false,
  associated_control_input = "ctm-toggle-console",
  icon = {
    filename = "__CargoTrainManager__/graphics/icons/tool-button.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 32
  },
  small_icon = {
    filename = "__CargoTrainManager__/graphics/icons/tool-button.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 24
  },
  disabled_small_icon = {
    filename = "__CargoTrainManager__/graphics/icons/tool-button.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 24
  },
}}

