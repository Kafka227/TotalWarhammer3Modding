local ranav = core:get_static_object("kafka_randomized_aversion")

core:add_listener(
	"kafka_ranav_onstart",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		ranav:applyAversionRandomizerInternal("kafka_ranav_diplomod_base_effect_bundle", "kafka_ranav_applied")
	end,
	true
);

function ranav:applyAversionRandomizerInternal(effectBundleName, savegameMarkerKey)
	ranav:log("Applying " .. effectBundleName)
	local applied = cm:get_saved_value(savegameMarkerKey);
	if applied then
		ranav:log("Already applied")
		return
	end
	local lowerBound = ranav.settings.lower_bound
	local upperBound = ranav.settings.upper_bound
	local factionList = cm:model():world():faction_list()
	for i = 0, factionList:num_items() - 1 do
		local faction = factionList:item_at(i)
		ranav:applyAversionRandomizerToFaction(faction, effectBundleName, upperBound, lowerBound)
	end
	cm:set_saved_value(savegameMarkerKey, true);
	ranav:log("Done")
end

function ranav:applyAversionRandomizerToFaction(faction, effectBundleName, upperBound, lowerBound)
	local custom_eb = cm:create_new_custom_effect_bundle(effectBundleName)
	if not custom_eb then
		return
	end
	local maxBoundAdjusted = upperBound - lowerBound
	for j = 0, custom_eb:effects():num_items() - 1 do
		local custom_effect = custom_eb:effects():item_at(j)
		local rand = cm:random_number(maxBoundAdjusted, 0)
		rand = rand + lowerBound
		custom_eb:set_effect_value(custom_effect, rand)
	end
	cm:apply_custom_effect_bundle_to_faction(custom_eb, faction)
end