local aucm = core:get_static_object("aucm")

--A unit pool is a list, with all unit types, the faction currently possesses in armies or garrisons

aucm.unitPools = {}
aucm.unitPoolsTurn = {}

core:add_listener(
	"kafka_aucm_update_unit_pool",
	"FactionTurnStart",
	true,
	function(context)
		local turnNumber = cm:turn_number()
		local faction = context:faction()
		if not faction:is_human() then
			return
		end
		aucm:getUnitPool(faction)
	end,
	true
)

function aucm:getUnitPoolX(faction)
	return aucm.unitPools[faction:name()]
end

function aucm:setUnitPoolX(faction, unitPool)
	aucm.unitPools[faction:name()] = unitPool
end

function aucm:getUnitPoolTurnX(faction)
	return aucm.unitPoolsTurn[faction:name()]
end

function aucm:setUnitPoolTurnX(faction, unitPoolsTurn)
	aucm.unitPoolsTurn[faction:name()] = unitPoolsTurn
end

-- Returns the unit pool for the given faction. Recreates it if its to old.
function aucm:getUnitPool(faction)
	local unitPool = aucm:getUnitPoolX(faction)
	if not unitPool then
		aucm:generateUnitPool(faction)
	end
	-- Regenerate if from last round
	local turnNumber = cm:turn_number()
	local unitPoolTurn = aucm:getUnitPoolTurnX(faction)
	if not unitPoolTurn then
		unitPoolTurn = turnNumber
	end
	aucm:log(tostring(turnNumber))
	aucm:log(tostring(unitPoolTurn))
	if turnNumber - unitPoolTurn >= 1 then
		aucm:generateUnitPool(faction)
	end
	-- return
	return aucm:getUnitPoolX(faction)
end

-- Generates the unit pool for that faction
function aucm:generateUnitPool(faction)
	aucm:log("Generating unitPool for " .. tostring(faction:name()))
	local unitPool = aucm:generateUnitPoolInternal(faction)
	local turnNumber = cm:turn_number()
	aucm:setUnitPoolX(faction, unitPool)
	aucm:setUnitPoolTurnX(faction, turnNumber)
end

function aucm:generateUnitPoolInternal(faction)
	local unitPool = {}
	local characters = faction:character_list()
	for i = 0, characters:num_items() - 1 do
		local character = characters:item_at(i)
		if character:has_military_force() then
			aucm:addUnitsToUnitPool(character:military_force():unit_list(), unitPool)
		end
	end
	return unitPool
end

function aucm:addUnitsToUnitPool(unitList, unitPool)
	for i = 1, unitList:num_items() - 1 do
		local unit = unitList:item_at(i)
		local unitKey = unit:unit_key()
		if not unitPool[unitKey] == nil then
			return
		end
		if aucm:isHero(unitKey) then
			return
		end
		local unitCost = aucm:getUnitCost(unit)
		if unitCost == 0 then
			return
		end
		unitPool[unitKey] = unitCost
	end
end
