-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


MOD_NAME = "Cargo Train Manager"
TECHNOLOGY_NAME = "cargo-train-manager"

-- entity types
STOP_TYPE = "train-stop"
REQUESTER_TYPE = "lamp"

-- entity names
CTM_STOP = "cargo-train-manager-stop"
CTM_STOP_LAMP = "cargo-train-manager-stop-lamp"
CTM_STOP_LAMP_CTRL = "cargo-train-manager-stop-lamp-control"
CTM_STOP_OUTPUT = "cargo-train-manager-stop-output"
CTM_REQUESTER = "cargo-train-manager-requester"

-- named GUI elements
TOOLBUTTON_NAME = "ctm_toolbutton"
DIALOG_NAME = "ctm_main_dialog"
DIALOG_CLOSE_NAME = "ctm_main_dialog_close"
STOP_DIALOG_NAME = "ctm_stop_dialog"
REQUESTER_DIALOG_NAME = "ctm_requester_dialog"
RESOURCE_DETAILS_DIALOG_NAME = "ctm_resource_details_dialog"
RESOURCE_DETAILS_CLOSE_NAME = "ctm_resource_details_dialogclose"

BTN_SHOW_ON_MAP_PREFIX = "ctm_show_map:"
BTN_SHOW_TRAIN_PREFIX = "ctm_show_train:"
BTN_OPEN_REQUESTER_PREFIX = "ctm_open_requester:"
BTN_RESOURCE_DETAILS_PREFIX = "ctm_resource:"
BTN_RESOURCE_DOWN_PREFIX = "ctm_resource_down:"
BTN_RESOURCE_UP_PREFIX = "ctm_resource_up:"

-- prefix letter is i=item, f=fluid, v=virtual
DEFAULT_NETWORK_NAME = "v-signal-1"

-- the maximum distance in tiles between a requester and a train stop
MAX_REQUESTER_STOP_DISTANCE = 2.5

-- signal names
CTM_COUNTER_SIGNAL = "ctm-train-counter"

-- default zoom level when opening a map view
DEFAULT_MAP_ZOOM = 0.25

-- default zoom level when opening a world view
DEFAULT_WORLD_ZOOM = 1.25

-- default zoom level when opening a world view for a train
DEFAULT_TRAIN_WORLD_ZOOM = 0.5

