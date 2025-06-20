local aucm = core:get_static_object("aucm")

-- Set army cost tooltip
core:add_listener(
	"kafka_aucm_setArmyCostTooltip",
	"CharacterSelected", 
    function(context)
      return context:character():has_military_force()
    end,
	function(context)
		local character = context:character()
		cm:set_saved_value("aucm_last_selected_char_cqi", character:command_queue_index())
		cm:callback( function()
			aucm:setUnitCostBreakdownTooltip(character)
			aucm:setArmyCostTooltipAndCounter(character)
		end, 0.1)
	end,
	true
)

core:add_listener(
	"kafka_aucm_clearLastSelectedCharacter",
	"CharacterSelected",
	function(context)
		return not context:character():has_military_force()
	end,
	function()
		cm:set_saved_value("aucm_last_selected_char_cqi", "")
	end,
	true
)

-- Catch all clicks to refresh the army cost tt if the units_panel is open
-- Fires also when player cancels recruitment of a unit, adds a unit to the queue etc
core:add_listener(
	"kafka_aucm_setArmyCostTooltip_clicked",
	"ComponentLClickUp",
	function(context)
		return cm.campaign_ui_manager:is_panel_open("units_panel")
	end,
	function(context)
		cm:callback(function()
			local savedCqi = cm:get_saved_value("aucm_last_selected_char_cqi")
			if not savedCqi then
				return
			end
			local lastSelectedCharacter = cm:get_character_by_cqi(savedCqi)
			if not(lastSelectedCharacter and lastSelectedCharacter ~= "") then
				return
			end
			if lastSelectedCharacter:is_wounded() then
				return
			end
			if not cm:char_is_mobile_general_with_army(lastSelectedCharacter) then
				return
			end
			aucm:setUnitCostBreakdownTooltip(lastSelectedCharacter)
			aucm:setArmyCostTooltipAndCounter(lastSelectedCharacter)
		end, 0.3)
	end,
	true
)

-- Sets the breakdown tooltip to the army info button
function aucm:setUnitCostBreakdownTooltip(character)
	if not aucm:getConfigGuiArmyBreakdown() then
		return
	end
	local infoButton = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "tr_element_list", "button_info_holder", "button_info")
	if not infoButton then
		return
	end
	local faction = character:faction()
	if not faction:is_human() then
		infoButton:SetTooltipText("Help me, I'm trapped in this video game!", true)
		return
	end
	local unitPool = aucm:getUnitPool(faction)
	infoButton:SetTooltipText(aucm:getUnitListCostTooltip(unitPool), true)
end

-- Creates a tooltip with the unit types in the army and their cost
function aucm:getUnitListCostTooltip(unitCosts)
	local tt_text = "Faction unit value overview:\n"
	local unitCostsKeys = aucm:getTableKeys(unitCosts)
	table.sort(unitCostsKeys, function(keyLhs, keyRhs)
		return unitCosts[keyLhs] < unitCosts[keyRhs]
	end)
	for _, unitKey in pairs(unitCostsKeys) do
		local unitCost = unitCosts[unitKey]
		local unitName = common.get_localised_string("land_units_onscreen_name_" .. unitKey)
		if not aucm:isHero(unitKey) then
			tt_text = tt_text .. unitName .. ": " .. unitCost .. "\n"
		end
	end
	return tt_text
end

-- Shows the army cost values in tooltip and army panel
function aucm:setArmyCostTooltipAndCounter(character)
	if not aucm:getConfigGuiArmyCostTooltip() and not aucm:getConfigGuiArmyCostCounter() then
		return
	end
	if not character:has_military_force() then
		return
	end
	local armyCost = aucm:getArmyCost(character)
	local armyLimit = aucm:getArmyLimit(character)
	local armyQueueCost = 0
	if aucm:getConfigGuiArmyCostRecruiting() then
		armyQueueCost = aucm:getArmyQueuedUnitsCost()
	end
	local armyHeroCount = aucm:getArmyHeroCount(character)
	local armyHeroLimit = aucm:getConfigArmyLimitHeroCap()
	--
	aucm:setArmyCostToolTip(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
    aucm:createArmyCounter(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
end

-- Shows the army cost in the army name tooltip
function aucm:setArmyCostToolTip(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
	if not aucm:getConfigGuiArmyCostTooltip() then
		return
	end
    local zoom_component = find_uicomponent(core:get_ui_root(), "main_units_panel", "button_focus")
	if not zoom_component then
		return
	end
	local ttText = aucm:buildTooltipText(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
	zoom_component:SetTooltipText(ttText, true)
end

-- Shows the army cost in the army panel besides the army upkeep
function aucm:createArmyCounter(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
	if not aucm:getConfigGuiArmyCostCounter() then
		return
	end
	local iconList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "icon_list");
  	if not iconList then
    	return;
  	end
  	local surplusCounter = find_uicomponent(iconList, "surplus_counter");
  	if not surplusCounter then
		-- this initalises component data to copy the upkeep component
		local cargo = find_uicomponent(iconList, "dy_upkeep");
		if not cargo then
			aucm:log("Failed to init army counter")
			return;
		else
		surplusCounter = UIComponent(cargo:CopyComponent("surplus_counter"));
		end
	end
	--
	local armyCostNew = armyCost + armyQueueCost
	local overLimitArmyCost = armyCost > armyLimit
	local overLimitArmyCostNew = armyCostNew > armyLimit
	local overLimitHeroCount = armyHeroCount > armyHeroLimit
	local text = ""
	if overLimitArmyCostNew or overLimitHeroCount then
		text = text .. "[[col:red]]"
	end
	text = "" .. armyCost
	if armyQueueCost > 0 then
		text = text .. "(+" .. armyQueueCost .. ")"
	end
	if overLimitArmyCostNew or overLimitHeroCount then
		text = text .. "[[/col]]"
	end
	local ttText = aucm:buildTooltipText(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
	surplusCounter:SetText(text)
	surplusCounter:SetTooltipText(ttText, true)
	surplusCounter:SetImagePath("ui/skins/default/wulfhart_imperial_supplies.png", 1)
	surplusCounter:SetVisible(true)
end

-- Builds the tooltip for all the army values
function aucm:buildTooltipText(armyCost, armyLimit, armyQueueCost, armyHeroCount, armyHeroLimit)
	local armyCostNew = armyCost + armyQueueCost
	local overLimitArmyCost = armyCost > armyLimit
	local overLimitArmyCostNew = armyCostNew > armyLimit
	local overLimitHeroCount = armyHeroCount > armyHeroLimit
	local ttText = "Army unit value summary:\n"
	-- Normal units
	if overLimitArmyCost then
		ttText = ttText .. "[[col:red]]"
	end
	ttText = ttText .. "Current value: " .. armyCost .. "/" .. armyLimit
	if overLimitArmyCost then
		ttText = ttText .. "[[/col]]"
	end
	ttText = ttText .. "\n"
	-- Queded Units
	if armyQueueCost > 0 then
		if overLimitArmyCostNew then
			ttText = ttText .. "[[col:red]]"
		end
		ttText = ttText .. "Expected value: " .. armyCostNew .. "/" .. armyLimit
		if overLimitArmyCostNew then
			ttText = ttText .. "[[/col]]"
		end
		ttText = ttText .. "\n"
	end
	-- Heroes
	if overLimitHeroCount then
		ttText = ttText .. "[[col:red]]"
	end
	ttText = ttText .. "Heroes: " .. armyHeroCount .. "/" .. armyHeroLimit
	if overLimitHeroCount then
		ttText = ttText .. "[[/col]]"
	end
	return ttText
end