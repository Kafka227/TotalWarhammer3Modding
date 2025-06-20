local rfpo = core:get_static_object("kafka_rfpo")

-- Savegame marker
rfpo.applied_key = "kafka_rfpo_applied"

core:add_listener(
	"kafka_rfpo_onstart",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		rfpo:apply()
	end,
	true
)

function rfpo:apply()
	rfpo:log("Removing RoR from AI recruitment pools")
	local applied = cm:get_saved_value(rfpo.applied_key);
	if applied then
		rfpo:log("Already applied")
		return
	end
	--
	local factionList = cm:model():world():faction_list()
	for factionIndex = 0, factionList:num_items() - 1 do
		local faction = factionList:item_at(factionIndex)
		if (faction:is_human() and rfpo.settings.apply_player) or (not faction:is_human() and rfpo.settings.apply_ai) then
			local factionName = faction:name()
			for i = 1, #rfpo.ror do
				local unitName = rfpo.ror[i]
				cm:add_unit_to_faction_mercenary_pool(faction, unitName, "mercenary_recruitment", 0, 0, 0, 0, "", "", "", false, unitName)
			end
		end
	end
	cm:set_saved_value(rfpo.applied_key, true);
	rfpo:log("Done")
end