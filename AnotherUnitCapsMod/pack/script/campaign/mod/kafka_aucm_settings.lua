local aucm = core:get_static_object("aucm")

-- Default settings
aucm.settings = {
	army_limit_point_divider = 200,
	army_limit_base = 70,
	army_limit_ai_adjust = 0,
	army_limit_hero_cap = 2,
	gui_army_cost_tooltip = true,
	gui_army_cost_counter = true,
	gui_army_cost_recruiting = true,
	gui_army_breakdown = true,
	gui_garrison = true,
	logging_enabled = false
}

function aucm:getConfigArmyLimitDivider()
	return self.settings.army_limit_point_divider
end

function aucm:getConfigArmyLimit()
	return self.settings.army_limit_base
end

function aucm:getConfigArmyLimitAiAdjust()
	return self.settings.army_limit_ai_adjust
end

function aucm:getConfigArmyLimitHeroCap()
	return self.settings.army_limit_hero_cap
end

function aucm:getConfigGuiArmyCostTooltip()
	return self.settings.gui_army_cost_tooltip
end

function aucm:getConfigGuiArmyCostCounter()
	return self.settings.gui_army_cost_counter
end

function aucm:getConfigGuiArmyCostRecruiting()
	return self.settings.gui_army_cost_recruiting
end

function aucm:getConfigGuiArmyBreakdown()
	return self.settings.gui_army_breakdown
end

function aucm:getConfigGuiGarrison()
	return self.settings.gui_garrison
end

function aucm:getConfigEnableLogging()
	return self.settings.enable_logging
end

-- Load setting at campaign start
core:add_listener(
	"kafka_aucm_settings_init",
	"MctInitialized",
	true,
	function(context)
        aucm:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_aucm_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        aucm:updateSettings()
    end,
    true
)

function aucm:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct()
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_another_unit_caps_mod")
	aucm.settings.army_limit_point_divider = my_mod:get_option_by_key("army_limit_point_divider"):get_finalized_setting()
	aucm.settings.army_limit_base = my_mod:get_option_by_key("army_limit_base"):get_finalized_setting()
	aucm.settings.army_limit_ai_adjust = my_mod:get_option_by_key("army_limit_ai_adjust"):get_finalized_setting()
	aucm.settings.army_limit_hero_cap = my_mod:get_option_by_key("army_limit_hero_cap"):get_finalized_setting()

	aucm.settings.gui_army_cost_tooltip = my_mod:get_option_by_key("gui_army_cost_tooltip"):get_finalized_setting()
	aucm.settings.gui_army_cost_counter = my_mod:get_option_by_key("gui_army_cost_counter"):get_finalized_setting()
	aucm.settings.gui_army_cost_recruiting = my_mod:get_option_by_key("gui_army_cost_recruiting"):get_finalized_setting()
	aucm.settings.gui_army_breakdown = my_mod:get_option_by_key("gui_army_breakdown"):get_finalized_setting()
	aucm.settings.gui_garrison = my_mod:get_option_by_key("gui_garrison"):get_finalized_setting()

	aucm.settings.enable_logging = my_mod:get_option_by_key("logging_enabled"):get_finalized_setting()
end