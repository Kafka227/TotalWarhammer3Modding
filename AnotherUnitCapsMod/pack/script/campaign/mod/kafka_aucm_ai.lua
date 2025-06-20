local aucm = core:get_static_object("aucm")

core:add_listener(
	"kafka_aucm_enforceArmyCostLimitForAiFaction",
	"FactionTurnStart",
	function(context)
		return not context:faction():is_human()
	end,
	function(context)
		local currentFaction = context:faction()
		if aucm:isFreeFaction(currentFaction) then
			return
		end
		aucm:enforceArmyCostLimitForAiFaction(currentFaction)
	end,
	true
)

-- Enforces the army cost limits on an ai faction by replacing army units
function aucm:enforceArmyCostLimitForAiFaction(faction)
	-- Get all armies, that require adjustment
	local charactersAll = faction:character_list()
	local charactersOverLimit = {}
	for i = 0, charactersAll:num_items() - 1 do
		local character = charactersAll:item_at(i)
		local armyCostOverLimit = aucm:getArmyCostOverLimit(character)
		if armyCostOverLimit > 0 then
			charactersOverLimit[character] = armyCostOverLimit
		end
	end
	if #charactersOverLimit <= 0 then
		return
	end
	-- Fix the armies
	local recruitmentPool = aucm:getUnitPool(faction)
	for character, armyCostOverLimit in pairs(charactersOverLimit) do
		aucm:enforceAmryCostLimitOnArmy(character, recruitmentPool, armyCostOverLimit)
	end
end

-- The amount the armycost is over limit
function aucm:getArmyCostOverLimit(character)
	if not cm:char_is_mobile_general_with_army(character) then
		return 0
	end
	-- TODO check for free army
	local armyCostLimit = aucm:getArmyLimit(character)
	local armyCost = aucm:getArmyCost(character)
	-- Positive diff means overlimit
	local armyCostDifference = armyCost - armyCostLimit
	if armyCostDifference <= 0 then
		return 0
	end
	return armyCostDifference
end

-- Downgrades the units in the army to reach the cost limit
function aucm:enforceAmryCostLimitOnArmy(character, recruitmentPool, savingsRequired)
	-- Randomize the unit list
	local unitList = character:military_force():unit_list()
	local unitIndex = {}
	for i = 1, unitList:num_items() - 1 do
		table.insert(unitIndex, i)
	end
	unitIndex = shuffleTable(unitIndex)

	-- Try to downgrade all units once
	local savingsReached = 0
	for i = 1, #unitIndex do
		local currentUnitKey = unitIndex[i]:unit_key()
		local downgradeUnitKey, reimbursement = aucm:getRandomDowngradeUnitKey(currentUnitKey, recruitmentPool)
		if downgradeUnitKey then
			aucm:replaceUnitForCharacter(currentUnitKey, downgradeUnitKey, character)
			-- TODO reimburses divided value, no actual gold cost
			cm:treasury_mod(character:faction():name(), reimbursement)
			savingsReached = savingsReached + reimbursement
		end
		if savingsRequired <= savingsReached then
			return
		end
	end
end

-- Gets a random unit key that has lower armycost or nil
function aucm:getRandomDowngradeUnitKey(unitKey, recruitmentPool)
	local unitCost = recruitmentPool[unitKey]

	if not unitCost or unitCost == 0 then
		return 0
	end

	local recruitmentPoolKeys = aucm:getTableKeys(recruitmentPool)
	local randomOffset = math.floor(math.random(0, #recruitmentPoolKeys - 1))
	-- Start at a random point in the table, looping around, trying to find a cheaper unit
	for i = 0, #recruitmentPoolKeys - 1 do
		local recruitmentPoolKeyIndex = (i + randomOffset) % #recruitmentPoolKeys + 1
		local replacementUnitKey = recruitmentPoolKeys[recruitmentPoolKeyIndex]
		local replacementUnitCost = recruitmentPool[replacementUnitKey]
		if replacementUnitCost < unitCost then
			return replacementUnitKey, replacementUnitCost
		end
	end
	return nil, 0
end

-- Replaces a unit for a character, reimbursing the faction
function aucm:replaceUnitForCharacter(oldUnitKey, newUnitKey, character)
	local characterLookup = cm:char_lookup_str(character)
	cm:remove_unit_from_character(characterLookup, oldUnitKey)
	cm:grant_unit_to_character(characterLookup, newUnitKey)
end
