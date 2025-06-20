if not get_mct then
    return
end
local mct = get_mct();
if not mct then
    return
end

local mct_mod = mct:register_mod("kafka_randomized_aversion")

mct_mod:set_title("Randomized aversion", false);
mct_mod:set_author("Kafka");
mct_mod:set_description("Randomized all aversion between factions by applying an additional modifer to the start of the game.", false);

local option_lower_bound = mct_mod:add_new_option("lower_bound", "slider");
option_lower_bound:set_text("Lower bound");
option_lower_bound:set_tooltip_text("Lower bound for the randomized aversion modifier.");
option_lower_bound:slider_set_min_max(-1000, 0);
option_lower_bound:slider_set_step_size(1);
option_lower_bound:set_default_value(-100);

local option_lower_bound = mct_mod:add_new_option("upper_bound", "slider");
option_lower_bound:set_text("Upper bound");
option_lower_bound:set_tooltip_text("Upper bound for the randomized aversion modifier.");
option_lower_bound:slider_set_min_max(0, 1000);
option_lower_bound:slider_set_step_size(1);
option_lower_bound:set_default_value(100);