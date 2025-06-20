if not get_mct then
    return
end
local mct = get_mct();
if not mct then
    return
end

local mct_mod = mct:register_mod("kafka_rfpo")

mct_mod:set_title("Regiments of Renown for player only", false);
mct_mod:set_author("Kafka");
mct_mod:set_description("Removes access to Regiments of Renown.", false);

local option_apply_player = mct_mod:add_new_option("apply_player", "checkbox");
option_apply_player:set_text("Apply to player");
option_apply_player:set_tooltip_text("Removes access to Regiments of Renown for human players.");
option_apply_player:set_default_value(false);

local option_apply_ai = mct_mod:add_new_option("apply_ai", "checkbox");
option_apply_ai:set_text("Apply to ai");
option_apply_ai:set_tooltip_text("Removes access to Regiments of Renown for ai players.");
option_apply_ai:set_default_value(true);