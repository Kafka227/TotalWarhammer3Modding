local aucm = core:get_static_object("aucm")

core:add_listener(
    "kafka_aucm_enforceArmyCostLimitForPlayerFaction",
    "FactionTurnStart",
    function(context)
        return context:faction():is_human()
    end, 
    function(context)
        local currentFaction = context:faction()
		if aucm:isFreeFaction(currentFaction) then
			return
		end
        cm:callback(
            function()
                aucm:enforceArmyCostLimitForFaction(currentFaction)
            end,
            0.1)
    end,
    true)

-- Checks and enforces the army cost limit for all amries of a faction
function aucm:enforceArmyCostLimitForFaction(faction)
	for i = 0, faction:character_list():num_items() - 1 do
		aucm:enforceArmyCostLimitForCharacter(faction:character_list():item_at(i))
	end
end

-- Checks and enforces the army cost limit for an army
function aucm:enforceArmyCostLimitForCharacter(character)
	if not cm:char_is_mobile_general_with_army(character) then
		return
	end
	if aucm:isFreeArmy(character) then
		return
	end
	local armyCqi = character:military_force():command_queue_index()
	local armyLimit = aucm:getArmyLimit(character)
	local armyCost = aucm:getArmyCost(character)
	local armyCostOverLimit = armyCost > armyLimit
	local armyHeroCount = aucm:getArmyHeroCount()
	local armyHeroLimit = aucm:getConfigArmyLimitHeroCap()
	local armyHeroOverLimit = armyHeroCount > armyHeroLimit
    local effectName = "kafka_army_cost_limit_penalty"
	if armyCostOverLimit or armyHeroOverLimit then
		cm:apply_effect_bundle_to_force(effectName, armyCqi, 1)
		return
	else
		cm:remove_effect_bundle_from_force(effectName, armyCqi)
		return
	end
end
