local wbfs = core:get_static_object("kafka_wbfs")

-- Tracks besiegingCharacter, besiegedSettlement, turn
wbfs.tracker_key = "kafka_wbfs_latest_settlement"
wbfs.tracker = {}

core:add_listener(
	"kafka_wbfs_on_load",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		wbfs:loadTables()
	end,
	true
)

-- Notices when character besieges settlement
core:add_listener(
	"kafka_wbfs_on_siege",
	"CharacterBesiegesSettlement",
	true,
	function(context)
		local region = context:region()
		local settlement = region:settlement()
		local character = region:garrison_residence():besieging_character()
		local faction = character:faction()
		if wbfs:checkIfApplyToFaction(faction) then
			return
		end
		wbfs:registerSiege(character, settlement)
	end,
	true
)

-- Updates besieged settlements
core:add_listener(
	"kafka_wbfs_turn_start",
	"FactionTurnStart",
	true,
	function(context)
		local faction = context:faction()
		if wbfs:checkIfApplyToFaction(faction) then
			return
		end
		local characters = faction:character_list()
		for i = 0, characters:num_items() - 1 do
			local character = characters:item_at(i)
			wbfs:updateBreaches(character)
		end
		wbfs:saveTables()
	end,
	true
)

function wbfs:checkIfApplyToFaction(faction)
	local isHuman = faction:is_human()
	if isHuman and not wbfs:getConfigApplyToPlayer() then
		return true
	end
	if not isHuman and not wbfs:getConfigApplyToAi() then
		return true
	end
	return false
end

function wbfs:loadTables()
	wbfs.tracker = cm:get_saved_value(wbfs.tracker_key)
	if not wbfs.tracker then
		wbfs.tracker = {}
	end
end

function wbfs:saveTables()
	cm:set_saved_value(wbfs.tracker_key, bfs.tracker);
end

function wbfs:saveTableEntry(characterBesieger, settlementBesieged2, turn2)
	local cqi = characterBesieger:command_queue_index()
	wbfs.tracker[cqi] = { settlementBesieged = settlementBesieged2, turn = turn2 }
end

function wbfs:clearTableEntry(characterBesieger)
	local cqi = characterBesieger:command_queue_index()
	wbfs.tracker[cqi] = nil
end

function wbfs:loadTableEntry(characterBesieger)
	local cqi = characterBesieger:command_queue_index()
	return wbfs.tracker[cqi]
end

-- Starts tracking a new siege
function wbfs:registerSiege(characterBesieger, settlementBesieged)
	if not settlementBesieged:is_walled_settlement() then
		return
	end
	wbfs:log("New siege: " .. characterBesieger:get_surname() .. " at " .. settlementBesieged:region():name())
	local breachesBase = wbfs:getConfigBreachesBaseCount()
	wbfs:breachSettlement(settlementBesieged, breachesBase)
	wbfs:saveTableEntry(characterBesieger, settlementBesieged, 0)
end

-- Updates values for an ongoing siege
function wbfs:updateBreaches(characterBesieger)
	-- Check siege status
	if not characterBesieger:is_besieging() then
		wbfs:clearTableEntry(characterBesieger)
		return
	end
	-- Load data
	local data = wbfs:loadTableEntry(characterBesieger)
	if not data then
		wbfs:log("No data on siege for " .. characterBesieger)
		return
	end
	local turn = data.turn
	local settlementBesieged = data.settlementBesieged
	turn = turn + 1
	wbfs:saveTableEntry(characterBesieger, settlementBesieged, turn)
	-- Apply breaches
	local breachesBase = wbfs:getConfigBreachesBaseCount()
	local breachesPerTurn = wbfs:getConfigBreachesTurnCount() * turn
	local breachesTotal = breachesBase + breachesPerTurn
	wbfs:log(tostring(breachesBase))
	wbfs:log(tostring(turn))
	wbfs:log(tostring(breachesPerTurn))
	wbfs:log(tostring(breachesTotal))
	wbfs:log("Updating siege: At " .. settlementBesieged:region():name() .. " with " .. tostring(breachesTotal))
	wbfs:breachSettlement(settlementBesieged, breachesTotal)
end

function wbfs:breachSettlement(settlementBesieged, totalBreaches)
	if settlementBesieged:number_of_wall_breaches() >= totalBreaches then
		return
	end
	cm:set_settlement_wall_health(settlementBesieged, totalBreaches)
end