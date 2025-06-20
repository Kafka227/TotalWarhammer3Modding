local gaur = core:get_static_object("gaur")

-- Default settings
gaur.settings = {
	upper_bound = 80,
	step_size_increase = 10,
	apply_to_ai = false,
	debug_internal = false
}

-- Load setting from mct when available
core:add_listener(
	"kafka_garrisoned_army_upkeep_settings_init",
	"MctInitialized",
	true,
	function(context)
        gaur:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_garrisoned_army_upkeep_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        gaur:updateSettings()
    end,
    true
)

function gaur:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct()
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_garrisoned_army_upkeep")
	gaur.settings.upper_bound = my_mod:get_option_by_key("upper_bound"):get_finalized_setting()
	gaur.settings.step_size_increase = my_mod:get_option_by_key("step_size_increase"):get_finalized_setting()
	gaur.settings.apply_to_ai = my_mod:get_option_by_key("apply_to_ai"):get_finalized_setting()
end
