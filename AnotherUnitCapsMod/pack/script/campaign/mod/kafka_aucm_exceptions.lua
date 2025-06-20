local aucm = core:get_static_object("aucm")

aucm.exceptions = {
	free_factions = {
		"wh2_dlc10_def_blood_voyage"
	},
	free_heroes = {
		"wh_dlc07_brt_cha_green_knight_0",
		"wh_dlc06_dwf_cha_master_engineer_ghost_0",
		"wh_dlc06_dwf_cha_runesmith_ghost_0",
		"wh_dlc06_dwf_cha_thane_ghost_0",
		"wh_dlc06_dwf_cha_thane_ghost_1"
	},
	free_military_force_types = {
		"DISCIPLE_ARMY"
	},
	free_military_force_effects = {
		"wh2_dlc12_bundle_underempire_army_spawn" -- The Vermintide army
	},
	free_units = {
		"wh_dlc07_brt_cha_green_knight_0"
	},
	custom_heroes = {
		"wh2_dlc11_cst_inf_count_noctilus_0",
		"wh2_dlc11_cst_inf_count_noctilus_1"
	}
}

function aucm:isFreeArmy(character)
	local militaryForce = character:military_force()
	for _, free_military_force_type in pairs(aucm.exceptions.free_military_force_types) do
		if free_military_force_type == militaryForce:force_type():key() then
			return false
		end
	end
	for _, free_military_force_effect in pairs(aucm.exceptions.free_military_force_effects) do
		return not militaryForce:has_effect_bundle(free_military_force_effect)
	end
	return true
end

function aucm:isFreeFaction(faction)
	return
		faction:name() ~= "rebels" and
		not faction:name():find("_intervention") and
		not faction:name():find("_incursion") and
		not table.contains(aucm.exceptions.free_factions, faction:name())
end

function aucm:isFreeUnit(unitKey)
	return table.contains(aucm.exceptions.free_units, unitKey)
end

function aucm:isFreeHero(unitKey)
	return table.contains(aucm.exceptions.free_heroes, unitKey)
end

function aucm:isCustomHero(unitKey)
	return table.contains(aucm.exceptions.custom_heroes, unitKey)
end