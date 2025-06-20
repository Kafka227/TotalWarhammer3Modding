local aucm = core:get_static_object("aucm")

-- Set garrison cost tooltip
-- RegionSelected?
core:add_listener(
	"kafka_aucm_setGarrisonCostTooltip",
	"SettlementSelected",
	true,
	function(context)
		aucm:setGarrisonCostTooltip(context:garrison_residence():region())
	end,
	true)

function aucm:setGarrisonCostTooltip(region)
	if not aucm:getConfigGuiGarrison() then
		return
	end
	if region:is_abandoned() then
		return
	end
	local garrison_commander = cm:get_garrison_commander_of_region(region)
	if not garrison_commander then
		return
	end
	local armyCqi = garrison_commander:military_force():command_queue_index()
	cm:callback(function()
		aucm:setGarrisonCostTooltipInternal(region, armyCqi)
	end, 0.1)
end

function aucm:setGarrisonCostTooltipInternal(region, cqi)
	if cqi == -1 then
		return
	end
	local settlementInfoButton = find_uicomponent(core:get_ui_root(), "settlement_panel", "button_info")
	if not settlementInfoButton then
		return
	end
	local armyCost = aucm:getGarrisonCost(cqi)
	local regionName = common.get_localised_string("regions_onscreen_" .. region:name())
	local tt_text = regionName .. " garrison value overview:\n"
	local tt_text = tt_text .. "Current value: " .. armyCost
	settlementInfoButton:SetTooltipText(tt_text, true)
end



