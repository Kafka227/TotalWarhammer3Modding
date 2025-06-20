local ranav = core:get_static_object("kafka_randomized_aversion")

-- Savegame marker
ranav.applied_key = "kafka_ranav_applied"

core:add_listener(
	"kafka_ranav_onstart",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		ranav:applyAversionRandomizer()
	end,
	true
);

function ranav:applyAversionRandomizer()
	ranav:log("Starting")
	local applied = cm:get_saved_value(ranav.applied_key);
	if applied then
		ranav:log("Already applied")
		return
	end
	ranav:log("Applying")
	local lowerBound = ranav.settings.lower_bound
	local upperBound = ranav.settings.upper_bound
	local maxBoundAdjusted = upperBound - lowerBound
	local factionList = cm:model():world():faction_list()
	for i = 0, factionList:num_items() - 1 do
		local faction = factionList:item_at(i)
		local custom_eb = cm:create_new_custom_effect_bundle("kafka_generic_diplomod_effect_bundle")
		for j = 0, custom_eb:effects():num_items() - 1 do
			local custom_effect = custom_eb:effects():item_at(j)
			local rand = cm:random_number(maxBoundAdjusted, 0)
			rand = rand + lowerBound
			custom_eb:set_effect_value(custom_effect, rand)
		end
		cm:apply_custom_effect_bundle_to_faction(custom_eb, faction)
	end
	cm:set_saved_value(ranav.applied_key, true);
	ranav:log("Done")
end