local gaur = core:get_static_object("gaur")

-- Tracks the latest settlement and bonus of armies
gaur.latest_settlement_key = "kafka_gaur_latest_settlement"
gaur.latest_settlement = {}
gaur.latest_bonus_key = "kafka_gaur_latest_bonus"
gaur.latest_bonus = {}

core:add_listener(
	"kafka_garrisoned_army_upkeep_turn_start",
	"FactionTurnStart",
	true,
	function(context)
		if not gaur.settings.apply_to_ai and not context:faction():is_human() then
			return
		end
		gaur:loadTables()
		local characters = context:faction():character_list()
		for i = 0, characters:num_items() - 1 do
			local character = characters:item_at(i)
			gaur:updateEffect(character)
		end
		gaur:saveTables()
	end,
	true
)

function gaur:loadTables()
	gaur.latest_settlement = cm:get_saved_value(gaur.latest_settlement_key);
	gaur.latest_bonus  = cm:get_saved_value(gaur.latest_bonus_key);
	if not gaur.latest_settlement then
		gaur.latest_settlement = {}
	end
	if not gaur.latest_bonus then
		gaur.latest_bonus = {}
	end
end

function gaur:saveTables()
	cm:set_saved_value(gaur.latest_settlement_key, gaur.latest_settlement);
	cm:set_saved_value(gaur.latest_bonus_key, gaur.latest_bonus);
end

function gaur:updateEffect(character)
	gaur:log("-----")
	local cqi = character:command_queue_index()
	gaur:log("CQI: " .. tostring(cqi))
	if not cm:char_is_mobile_general_with_army(character) then
		gaur.latest_settlement[cqi] = ""
		gaur.latest_bonus[cqi] = 0
		return
  	end
	-- Fill empty values
	if not gaur.latest_settlement[cqi] then
		gaur.latest_settlement[cqi] = ""
	end
	if not gaur.latest_bonus[cqi] then
		gaur.latest_bonus[cqi] = 0
	end
	--- Check for garrison status
	local force = character:military_force()
	if not force:has_garrison_residence() then
		gaur:log("Not in garrison")
		gaur:removeEffect(cqi, force)
		return
	end
	--- Check current settlement
	local currentRegionName = force:garrison_residence():settlement_interface():region():name()
	gaur:log("Latest region: " .. gaur.latest_settlement[cqi])
	gaur:log("Current region: " .. currentRegionName)
	if gaur.latest_settlement[cqi] ~= "" then
		local previousRegionName = gaur.latest_settlement[cqi]
		if previousRegionName ~= currentRegionName then
			gaur:log("Region mismatch")
			gaur:removeEffect(cqi, force)
			return
		end
	end
	--- Adjust value
	local effectValue = gaur.latest_bonus[cqi]
	gaur:log("Current value: " .. tostring(effectValue))
	effectValue = effectValue + gaur.settings.step_size_increase
	local upperBound = gaur.settings.upper_bound
	if effectValue > upperBound then
		effectValue = upperBound
	end
	gaur:log("New value: " .. tostring(effectValue))
	--- Apply anew with new value
	local effectBundleNew = cm:create_new_custom_effect_bundle("kafka_garrisoned_army_upkeep_bundle")
	local effectNew = gaur:getEffectFromEffectBundle(effectBundleNew)
	effectBundleNew:set_effect_value(effectNew, -1 * effectValue)
	cm:apply_custom_effect_bundle_to_force(effectBundleNew, force)
	--- Update table
	gaur.latest_settlement[cqi] = currentRegionName
	gaur.latest_bonus[cqi] = effectValue
end

function gaur:removeEffect(cqi, force)
	gaur.latest_settlement[cqi] = ""
	gaur.latest_bonus[cqi] = 0
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