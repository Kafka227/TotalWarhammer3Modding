local gaur = core:get_static_object("gaur")

-- Tracks the latest settlement
gaur.latest_settlement_key = "kafka_gaur_latest_settlement"
gaur.latest_settlement = {}
-- Tracks the latest upkeep bonus
gaur.latest_bonus_key = "kafka_gaur_latest_bonus"
gaur.latest_bonus = {}
-- Tracks the latest sum of unit cost
gaur.latest_unit_cost_sum_key = "kafka_gaur_latest_unit_cost_sum"
gaur.latest_unit_cost_sum = {}

core:add_listener(
	"kafka_garrisoned_army_upkeep_turn_start",
	"FactionTurnStart",
	true,
	function(context)
		if not gaur.settings.apply_to_ai and not context:faction():is_human() then
			return
		end
		gaur:log("--x--")
		gaur:loadTables()
		local forces = context:faction():military_force_list()
		for i = 0, forces:num_items() - 1 do
			local force = forces:item_at(i)
			gaur:updateEffect(force)
		end
		gaur:saveTables()
	end,
	true
)

function gaur:loadTables()
	gaur.latest_settlement = cm:get_saved_value(gaur.latest_settlement_key)
	gaur.latest_bonus  = cm:get_saved_value(gaur.latest_bonus_key)
	gaur.latest_unit_cost_sum  = cm:get_saved_value(gaur.latest_unit_cost_sum_key)
	if not gaur.latest_settlement then
		gaur.latest_settlement = {}
	end
	if not gaur.latest_bonus then
		gaur.latest_bonus = {}
	end
	if not gaur.latest_unit_cost_sum then
		gaur.latest_unit_cost_sum = {}
	end
end

function gaur:saveTables()
	cm:set_saved_value(gaur.latest_settlement_key, gaur.latest_settlement)
	cm:set_saved_value(gaur.latest_bonus_key, gaur.latest_bonus)
	cm:set_saved_value(gaur.latest_unit_cost_sum_key, gaur.latest_unit_cost_sum)
end

function gaur:initValuesForCqi(cqi)
	if not gaur.latest_settlement[cqi] then
		gaur.latest_settlement[cqi] = ""
	end
	if not gaur.latest_bonus[cqi] then
		gaur.latest_bonus[cqi] = 0
	end
	if not gaur.latest_unit_cost_sum[cqi] then
		gaur.latest_unit_cost_sum[cqi] = 0
	end
end

function gaur:updateEffect(force)
	local general = force:general_character()
	if not cm:char_is_mobile_general_with_army(general) then
		return
	end
	gaur:log("-----")
	local cqi = force:command_queue_index()
	local generalName = common.get_localised_string(general:get_forename())
	gaur:log("General: " .. tostring(generalName))
	gaur:log("CQI: " .. tostring(cqi))
	gaur:initValuesForCqi(cqi)
	--- Check for garrison status
	if not force:has_garrison_residence() then
		gaur:log("Not in garrison")
		gaur:removeEffect(cqi, force)
		return
	end
	--- Check current settlement
	local currentRegionName = force:garrison_residence():settlement_interface():region():name()
	local previousRegionName = gaur.latest_settlement[cqi]
	gaur:log("Previous region: " .. previousRegionName)
	gaur:log("Current region: " .. currentRegionName)
	if previousRegionName ~= "" then
		if previousRegionName ~= currentRegionName then
			gaur:log("Region mismatch")
			gaur:removeEffect(cqi, force)
			return
		end
	end
	--- Check army cost
	local currentUnitCost = 0
	if gaur.settings.track_army_cost then
		currentUnitCost = gaur:calculateArmyCost(force)
		local previousUnitCost = gaur.latest_unit_cost_sum[cqi]
		gaur:log("Previous cost: " .. previousUnitCost)
		gaur:log("Current cost: " .. currentUnitCost)
		if previousUnitCost ~= 0 then
			if previousUnitCost ~= currentUnitCost then
				gaur:log("Cost mismatch")
				gaur:removeEffect(cqi, force)
				return
			end
		end
	end
	--- Adjust bonus value
	local effectValue = gaur.latest_bonus[cqi]
	gaur:log("Current value: " .. tostring(effectValue))
	effectValue = effectValue + gaur.settings.step_size_increase
	local upperBound = gaur.settings.upper_bound
	if effectValue > upperBound then
		effectValue = upperBound
	end
	gaur:log("New value: " .. tostring(effectValue))
	--- Apply anew with new bonus value
	local effectBundleNew = cm:create_new_custom_effect_bundle("kafka_garrisoned_army_upkeep_bundle")
	local effectNew = gaur:getEffectFromEffectBundle(effectBundleNew)
	effectBundleNew:set_effect_value(effectNew, -1 * effectValue)
	cm:apply_custom_effect_bundle_to_force(effectBundleNew, force)
	--- Update table
	gaur.latest_settlement[cqi] = currentRegionName
	gaur.latest_bonus[cqi] = effectValue
	gaur.latest_unit_cost_sum[cqi] = currentUnitCost
end

function gaur:removeEffect(cqi, force)
	gaur.latest_settlement[cqi] = ""
	gaur.latest_bonus[cqi] = 0
	gaur.latest_unit_cost_sum[cqi] = 0
	cm:remove_effect_bundle_from_force("kafka_garrisoned_army_upkeep_bundle", force:command_queue_index())
end

function gaur:getEffectFromEffectBundle(effectBundle)
	local effectsList = effectBundle:effects()
	for i = 0, effectsList:num_items() - 1 do
		local effect = effectsList:item_at(i)
		if effect:key() == "kafka_garrisoned_army_upkeep_effect" then
			return effect
		end
	end
	return nil
end

function gaur:calculateArmyCost(force)
	local armyCost = 0
	local unitList = force:unit_list()
	for i = 0, unitList:num_items() - 1 do
		local unit = unitList:item_at(i)
		armyCost = armyCost + unit:get_unit_custom_battle_cost()
	end
	return armyCost
end