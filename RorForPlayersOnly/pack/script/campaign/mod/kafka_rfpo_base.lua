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
	rfpo:log("Removing RoR from recruitment pools")
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
			local custom_eb = cm:create_new_custom_effect_bundle("kafka_rfpo_bundle")
			cm:apply_custom_effect_bundle_to_faction(custom_eb, faction)
		end
	end
	cm:set_saved_value(rfpo.applied_key, true);
	rfpo:log("Done")
end