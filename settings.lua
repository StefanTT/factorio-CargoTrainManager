-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

data:extend({
	{
		type = "int-setting",
		name = "minFuelValue",
		description = "minFuelValue",
		setting_type = "runtime-global",
		default_value = 60,
		minimum_value = 0
	},
	{
		type = "string-setting",
		name = "refuelStationName",
		description = "refuelStationName",
		setting_type = "runtime-global",
		default_value = "Refuel-"
	},	
	{
		type = "int-setting",
		name = "deliveryTimeout",
		description = "deliveryTimeout",
		setting_type = "runtime-global",
		default_value = 300,
		minimum_value = 0
	},
  {
    type = "bool-setting",
    default_value = false,
    name = "showToolButton",
    setting_type = "runtime-per-user"
  },
})

