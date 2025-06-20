if not get_mct then
    return
end
local mct = get_mct();
if not mct then
    return
end

local mct_mod = mct:register_mod("kafka_garrisoned_army_upkeep")

mct_mod:set_title("Garrisoned Army Upkeep Reduction", false);
mct_mod:set_author("Kafka");
mct_mod:set_description("Garrisoned armies gain a stacking upkeep reduction per turn.", false);

local option_lower_bound = mct_mod:add_new_option("upper_bound", "slider");
option_lower_bound:set_text("Upper bound");
option_lower_bound:set_tooltip_text("Upper bound of the upkeep reduction");
option_lower_bound:slider_set_min_max(0, 100);
option_lower_bound:slider_set_step_size(1);
option_lower_bound:set_default_value(80);

local option_lower_bound = mct_mod:add_new_option("step_size_increase", "slider");
option_lower_bound:set_text("Increase step size");
option_lower_bound:set_tooltip_text("The amount of upkeep reduction a garrisoned army gains per turn.");
option_lower_bound:slider_set_min_max(0, 100);
option_lower_bound:slider_set_step_size(5);
option_lower_bound:set_default_value(10);

local option_apply_to_ai = mct_mod:add_new_option("apply_to_ai", "checkbox");
option_apply_to_ai:set_text("Applies to ai");
option_apply_to_ai:set_tooltip_text("Upkeep reduction also applies to ai.");
option_apply_to_ai:set_default_value(false);