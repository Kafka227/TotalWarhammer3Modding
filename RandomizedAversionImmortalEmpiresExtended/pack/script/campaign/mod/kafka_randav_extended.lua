local ranav = core:get_static_object("kafka_randomized_aversion")

core:add_listener(
	"kafka_ranav_ex_onstart",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		ranav:applyAversionRandomizerInternal("kafka_ranav_diplomod_extended_effect_bundle", "kafka_ranav_extended_applied")
	end,
	true
);