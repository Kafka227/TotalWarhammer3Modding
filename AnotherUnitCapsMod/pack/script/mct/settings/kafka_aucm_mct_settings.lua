if not get_mct then
	return
end
local mct = get_mct()

if not mct then
	return
end
local mct_mod = mct:register_mod("kafka_another_unit_caps_mod")

mct_mod:set_title("Another Army Caps Mod", false)
mct_mod:set_author("Kafka. Original by Wolfy & Jadawin")
mct_mod:set_description("Cost limit for all armies based on the units' cost.\n" ..
                        "Heavily based on Cost-based Army Caps by Wolfy & Jadawin.", false)

mct_mod:add_new_section("aucm_base", "Base Options", false)

local option_army_limit_player = mct_mod:add_new_option("army_limit_point_divider", "slider")
option_army_limit_player:set_text("Point Divider")
option_army_limit_player:set_tooltip_text("The amount the mp-cost of the units get divided by to reach the actual point value (rounded up).\n" .. "[[col:yellow]]" ..
				                          "All other options have to be adjusted manually with this value in mind.\n" ..
				                          "An army limit of 50 with a divider of 200 equals a limit of 10000 with a divider of 1." .. "[[/col]]")
option_army_limit_player:slider_set_min_max(1, 1000)
option_army_limit_player:slider_set_step_size(50)
option_army_limit_player:set_default_value(200)

local option_army_limit_player = mct_mod:add_new_option("army_limit_base", "slider")
option_army_limit_player:set_text("Army limit")
option_army_limit_player:set_tooltip_text("The amount of points allowed per army.")
option_army_limit_player:slider_set_min_max(1, 99000)
option_army_limit_player:slider_set_step_size(1)
option_army_limit_player:set_default_value(70)

local option_army_limit_ai = mct_mod:add_new_option("army_limit_ai_adjust", "slider")
option_army_limit_ai:set_text("AI army limit bonus")
option_army_limit_ai:set_tooltip_text("The amount of points, that gets applied to the army limit for ai armies.")
option_army_limit_ai:slider_set_min_max(-99000, 99000)
option_army_limit_ai:slider_set_step_size(1)
option_army_limit_ai:set_default_value(0)

local option_hero_cap = mct_mod:add_new_option("army_limit_hero_cap", "slider")
option_hero_cap:set_text("Army hero count")
option_hero_cap:set_tooltip_text("The amount heroes allowed per army.\n" .. "[[col:yellow]]Applies to the player only.[[/col]]")
option_hero_cap:slider_set_min_max(0, 19)
option_hero_cap:slider_set_step_size(1)
option_hero_cap:set_default_value(2)

mct_mod:add_new_section("aucm_advanced", "Advanced Options", false)

local option_gui_army_cost_tooltip = mct_mod:add_new_option("gui_army_cost_tooltip", "checkbox")
option_gui_army_cost_tooltip:set_text("Army value tooltip")
option_gui_army_cost_tooltip:set_tooltip_text("Show the army's value in the gui by hovering the name of the army")
option_gui_army_cost_tooltip:set_default_value(false)

local option_gui_army_cost_counter = mct_mod:add_new_option("gui_army_cost_counter", "checkbox")
option_gui_army_cost_counter:set_text("Army value counter")
option_gui_army_cost_counter:set_tooltip_text("Show the army's value in the gui beside the upkeep counter")
option_gui_army_cost_counter:set_default_value(true)

local option_gui_army_recruiting = mct_mod:add_new_option("gui_army_cost_recruiting", "checkbox")
option_gui_army_recruiting:set_text("Recruiting values")
option_gui_army_recruiting:set_tooltip_text("Extends the tooltips for the army's value by the value of the units it is currently recruiting.")
option_gui_army_recruiting:set_default_value(true)

local option_gui_army_breakdown = mct_mod:add_new_option("gui_army_breakdown", "checkbox")
option_gui_army_breakdown:set_text("Army value breakdown tooltip")
option_gui_army_breakdown:set_tooltip_text("Show a breakdown of the faction's units in the gui by hovering the info button in the top right of the army panel. Player only.")
option_gui_army_breakdown:set_default_value(true)

local option_gui_garrison = mct_mod:add_new_option("gui_garrison", "checkbox")
option_gui_garrison:set_text("Garrison value tooltip")
option_gui_garrison:set_tooltip_text("Show the garrison's value in the gui by hovering the info button in the top right of the city panel.")
option_gui_garrison:set_default_value(true)

local option_logging_enabled = mct_mod:add_new_option("logging_enabled", "checkbox")
option_logging_enabled:set_text("Logging")
option_logging_enabled:set_tooltip_text("Outputs the mod's logging to kafka.txt in the game's root folder.")
option_logging_enabled:set_default_value(false)