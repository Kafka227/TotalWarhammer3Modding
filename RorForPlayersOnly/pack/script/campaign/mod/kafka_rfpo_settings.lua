local rfpo = core:get_static_object("kafka_rfpo")

rfpo.settings = {
	apply_player = false,
	apply_ai = true,
	debug_internal = false
}

-- Load setting from mct when available
core:add_listener("kafka_rfpo_settings_init",
	"MctInitialized",
	true,
	function(context)
        rfpo:updateSettings()
	end,
	true
)

function rfpo:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_rfpo")

	local option_apply_player = my_mod:get_option_by_key("apply_player")
	local apply_player_setting = option_apply_player:get_finalized_setting()
	option_apply_player:set_read_only(true)

	local option_apply_ai = my_mod:get_option_by_key("apply_ai")
	local apply_ai_setting = option_apply_ai:get_finalized_setting()
	option_apply_ai:set_read_only(true)

	rfpo.settings.apply_player = apply_player_setting
	rfpo.settings.apply_ai = apply_ai_setting
end