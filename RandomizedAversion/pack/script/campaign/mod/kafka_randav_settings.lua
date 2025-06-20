local ranav = core:get_static_object("kafka_randomized_aversion")

-- Default settings
ranav.settings = {
	lower_bound = -100,
	upper_bound = 100,
	debug_internal = false
}

-- Load setting from mct when available
core:add_listener("kafka_ranav_settings_init",
	"MctInitialized",
	true,
	function(context)
        ranav:updateSettings()
	end,
	true
)

function ranav:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_randomized_aversion")
	local option_lower_bound = my_mod:get_option_by_key("lower_bound")
	local lower_bound_setting = option_lower_bound:get_finalized_setting()
	option_lower_bound:set_read_only(true)
	local option_upper_bound = my_mod:get_option_by_key("upper_bound")
	local upper_bound_setting = option_upper_bound:get_finalized_setting()
	option_upper_bound:set_read_only(true)
	ranav.settings.lower_bound = lower_bound_setting
	ranav.settings.upper_bound = upper_bound_setting
end