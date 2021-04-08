-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

data.raw["gui-style"].default["ctm_button_icon"] =
{
  type = "button_style",
  parent = "button",
  default_font_color = {},
  size = 38,
  top_padding = 1,
  right_padding = 0,
  bottom_padding = 1,
  left_padding = 0,
  left_click_sound = {{ filename = "__core__/sound/gui-square-button.ogg", volume = 1 }},
  default_graphical_set =
  {
    filename = "__core__/graphics/gui.png",
    corner_size = 3,
    position = {8, 0},
    scale = 1
  }
};

local btnIconStatesTab = { off = 0, on = 36 }
for state, y in pairs(btnIconStatesTab) do
  data.raw["gui-style"].default["ctm_button_icon_" .. state] = {
    type = "button_style",
    parent = "ctm_button_icon",
    default_graphical_set =
    {
        filename = "__CargoTrainManager__/graphics/styles/button_backgrounds.png",
        priority = "extra-high-no-scale",
        position = {0, y},
        size = 36,
        border = 1,
        scale = 1
    },
    disabled_graphical_set = 
    {
        filename = "__CargoTrainManager__/graphics/styles/button_backgrounds.png",
        priority = "extra-high-no-scale",
        position = {0, y},
        size = 36,
        border = 1,
        scale = 1
    },
    hovered_graphical_set =
    {
        filename = "__CargoTrainManager__/graphics/styles/button_backgrounds.png",
        priority = "extra-high-no-scale",
        position = {36, y},
        size = 36,
        border = 1,
        scale = 1
    },
    clicked_graphical_set =
    {
        filename = "__CargoTrainManager__/graphics/styles/button_backgrounds.png",
        priority = "extra-high-no-scale",
        position = {72, y},
        size = 36,
        border = 1,
        scale = 1
    }
  }
end


data.raw["gui-style"].default["tm-error-text"] = {
  type = "label_style",
  parent = "label",
  font_color = {r=230, g=145, b=145}
}


data.raw["gui-style"].default["tm-label-right"] = {
  type = "label_style",
  parent = "label",
  horizontal_align = "right"
}


data.raw["gui-style"].default["ctm_small_button"] = {
  type = "button_style",
  padding = 0,
  size = 24
}

