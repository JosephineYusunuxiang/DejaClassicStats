local _, namespace = ... 	--localization
local L = namespace.L 				--localization

local _, addon = ...
addon.duraMean = 0

local _, gdbprivate = ...

local ipairs = ipairs
local DCS_CharacterShirtSlot = CharacterShirtSlot
local getItemQualityColor = GetItemQualityColor

-- ---------------------------
-- -- DCS Durability Frames --
-- ---------------------------

local DCSITEM_SLOT_FRAMES = {
	CharacterHeadSlot,CharacterNeckSlot,CharacterShoulderSlot,CharacterBackSlot,CharacterChestSlot,CharacterWristSlot,
	CharacterHandsSlot,CharacterWaistSlot,CharacterLegsSlot,CharacterFeetSlot,
	CharacterFinger0Slot,CharacterFinger1Slot,CharacterTrinket0Slot,CharacterTrinket1Slot,
	CharacterMainHandSlot,CharacterSecondaryHandSlot,CharacterRangedSlot,
}

local DCSITEM_SLOT_FRAMES_RIGHT = {
	[CharacterHeadSlot]={},[CharacterShoulderSlot]={},[CharacterChestSlot]={},[CharacterWristSlot]={},
}

local DCSITEM_SLOT_NECK_BACK_SHIRT = {
	[CharacterNeckSlot]={},[CharacterBackSlot]={},[DCS_CharacterShirtSlot]={},
}

local DCSITEM_TWO_HANDED_WEAPONS = {
	"Bows","Crossbows","Guns","Fishing Poles","Polearms","Staves","Two-Handed Axes","Two-Handed Maces","Two-Handed Swords",
}
	
--local duraMean
local duraTotal
local duraMaxTotal
local duraFinite = 0

--------------------
-- Create Objects --
--------------------
local duraMeanFS = DCS_CharacterShirtSlot:CreateFontString("FontString","OVERLAY","GameTooltipText") --text for average durability on shirt
	duraMeanFS:SetPoint("CENTER",DCS_CharacterShirtSlot,"CENTER",1,-2) --poisiton will be influenced by DCS_Set_Dura_Item_Positions()
	duraMeanFS:SetFont("Fonts\\FRIZQT__.TTF", 15, "THINOUTLINE")
	duraMeanFS:SetFormattedText("")

local duraMeanTexture = DCS_CharacterShirtSlot:CreateTexture(nil,"ARTWORK") --bar for average durability on shirt 

local duraDurabilityFrameFS = DurabilityFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	duraDurabilityFrameFS:SetPoint("CENTER",DurabilityFrame,"CENTER",0,0)
	duraDurabilityFrameFS:SetFont("Fonts\\FRIZQT__.TTF", 16, "THINOUTLINE")
	duraDurabilityFrameFS:SetFormattedText("")
	
for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
	v.duratexture = v:CreateTexture(nil,"ARTWORK")

    v.durability = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
    v.durability:SetFormattedText("")

    v.itemrepair = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
    v.itemrepair:SetFormattedText("")
	
    v.ilevel = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
    v.ilevel:SetFormattedText("")

    v.enchant = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.enchant:SetFormattedText("")
	
	v.itemcolor = v:CreateTexture(nil,"ARTWORK")
	v.itemcolor:SetAllPoints(v)

	v.ItemFrameOutlineTexture = v:CreateTexture(nil,"OVERLAY",nil)
	v.ItemFrameOutlineTexture:SetPoint("TOPLEFT", v, "TOPLEFT", -2, 2);
	v.ItemFrameOutlineTexture:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 2, -2);
	v.ItemFrameOutlineTexture:SetTexture("Interface\\Addons\\DejaClassicStats\\DCSArt\\WhiteIconFrame.blp")

	v.ItemFramehighlightTexture = v:CreateTexture(nil, "HIGHLIGHT",nil)
	v.ItemFramehighlightTexture:SetPoint("TOPLEFT", v, "TOPLEFT", -2, 2);
	v.ItemFramehighlightTexture:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 2, -2);
	v.ItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
end

local function DCS_Set_Item_Quality_Color_Outlines()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.ItemFrameOutlineTexture:SetVertexColor(0, 0, 0, 0);
		v.ItemFramehighlightTexture:SetVertexColor(0, 0, 0, 0);
		local itemLink = GetInventoryItemLink("player", v:GetID())
		if (itemLink==nil) then
			local iLikeCake = true
		else
			local qualityBordersChecked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked
			local qualityBordersAlpha
			if qualityBordersChecked then 
				qualityBordersAlpha = gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue
			else
				qualityBordersAlpha = 0
			end
			local item = Item:CreateFromEquipmentSlot(v:GetID())
			local itemName, itemLink = GetItemInfo(itemLink)
			local r, g, b, hex = getItemQualityColor(C_Item.GetItemQualityByID(itemLink))
			v.ItemFrameOutlineTexture:SetVertexColor(r, g, b, qualityBordersAlpha);
			v.ItemFramehighlightTexture:SetVertexColor(r, g, b, qualityBordersAlpha);
		end
	end
end

	
gdbprivate.gdbdefaults.gdbdefaults.QCOA_SetSliderValue = {
	QCOA_SliderValue = 0.75,
}

-- Quality Color Outlines Alpha Slider:
local QCOA_Slider = CreateFrame("Slider", "QCOA_Slider", DejaClassicStatsPanel, "OptionsSliderTemplate")
	QCOA_Slider:RegisterEvent("PLAYER_LOGIN")
	QCOA_Slider:SetPoint("TOPLEFT", DejaClassicStatsPanel, "TOP", -25, -265)
	QCOA_Slider:SetWidth(200)
	QCOA_Slider:SetHeight(10)
	QCOA_Slider:SetOrientation('HORIZONTAL')
	QCOA_Slider:SetMinMaxValues(0.25, 1.0)
	QCOA_Slider.minValue, QCOA_Slider.maxValue = QCOA_Slider:GetMinMaxValues() 
	QCOA_Slider:SetValueStep(0.05)
	QCOA_Slider:SetObeyStepOnDrag(true)

	QCOA_Slider.tooltipText = "装备物品依据品质染色的彩色边框发光强度（alpha）设置为递增或递减0.05。默认值为0.75。" --Creates a tooltip on mouseover.

	getglobal(QCOA_Slider:GetName() .. 'Low'):SetText(QCOA_Slider.minValue); --Sets the left-side slider text (default is "Low").
	getglobal(QCOA_Slider:GetName() .. 'High'):SetText(QCOA_Slider.maxValue); --Sets the right-side slider text (default is "High").

	QCOA_Slider:Show()
			
	QCOA_Slider:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local slideValue = gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue
			self:SetValue(slideValue)
			getglobal(QCOA_Slider:GetName() .. 'Text'):SetFormattedText(L["Item Quality Glow"].." = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		end
	end)

	QCOA_Slider:SetScript("OnValueChanged", function(self, value) 
	local slideValue = QCOA_Slider:GetValue()			
		getglobal(QCOA_Slider:GetName() .. 'Text'):SetFormattedText(L["Item Quality Glow"].." = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue = slideValue
		if PaperDollFrame:IsVisible() then
			DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
		end
	end)

--TODO - setting of their values and checkbox states in frame meant for this purpose

local showavgdur --display of average durability on shirt
local showtextures --display of durability textures
local showdura --display of durability percentage on items
local showrepair --display of item repair cost
local showitemlevel --display of item's item level
local showenchant --display of item's enchant
local simpleitemcolor -- blacking out of item textures for easier seeing of info
local darkeritemcolor -- darkening but not blacking out of item textures for easier seeing of info
local otherinfoplacement --alternate display position of item repair cost, durability, and ilvl

local function puttop(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",6,0)
		else
			fontstring:SetPoint("TOPRIGHT",slot,"TOPLEFT",-6,-2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("RIGHT",slot,"LEFT",-2,-2)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,15)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"TOPRIGHT",4,-8)
		end
	else
		fontstring:SetPoint("TOP",slot,"TOP",3,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putcenter(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",10,-2)
		else
			fontstring:SetPoint("RIGHT",slot,"LEFT",-10,-2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("RIGHT",slot,"LEFT",-2,-6)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPLEFT",slot,"BOTTOMRIGHT",8,0)
		end
	else
		fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putbottom(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("BOTTOMLEFT",slot,"BOTTOMRIGHT",6,2)
		else
			fontstring:SetPoint("RIGHT",slot,"LEFT",-6,0)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMRIGHT",slot,"BOTTOMLEFT",-2,0)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"BOTTOMRIGHT",4,-2)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMRIGHT",slot,"TOPRIGHT",20,15)
		end
	else
		fontstring:SetPoint("BOTTOM",slot,"BOTTOM",1,0)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putothercenter(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",6,-4)
		else
			fontstring:SetPoint("TOPRIGHT",slot,"TOPLEFT",-6,-9)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
	else
		fontstring:SetPoint("TOP",slot,"TOP",3,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

function putenchant(fontstring,slot,size)
	if showenchant then
		ShowDefaultStats = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefaultStats.ShowDefaultStatsChecked
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("TOPLEFT",slot,"TOPRIGHT",6,-2)
		else
			fontstring:SetPoint("BOTTOMRIGHT",slot,"BOTTOMLEFT",-6,2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"BOTTOMRIGHT",4,4)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPLEFT",slot,"BOTTOMLEFT",-4,4)
		end
		if ShowDefaultStats then
			if (slot == CharacterSecondaryHandSlot) then
				fontstring:ClearAllPoints()
				fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,2)
			end
			if (slot == CharacterWristSlot) then
				fontstring:SetPoint("TOPLEFT",slot,"TOPRIGHT",6,-10)
			end
		else
			if (slot == CharacterSecondaryHandSlot) then
				fontstring:ClearAllPoints()
				fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,6)
			end
		end
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putilevel(fontstring,slot,size)
	fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function DCS_Set_Dura_Item_Positions()
	--It encompasses item repair, durability and, indirectly, durability bars.
	--making it work with local to DCSDuraRepair.lua variable
	local showdura = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
	local showrepair = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
	local showenchant = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked
	local abbrevEnchants = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked
	local otherinfoplacement = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked
	--print("called DCS_Set_Dura_Item_Positions") --debug for later
	duraMeanFS:ClearAllPoints()

	putcenter(duraMeanFS,DCS_CharacterShirtSlot,15)
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.durability:ClearAllPoints()
		v.itemrepair:ClearAllPoints()
		v.ilevel:ClearAllPoints()
		v.enchant:ClearAllPoints()
		if showitemlevel then
			if showdura then 
				if showrepair then
					puttop(v.durability,v,11)
					putbottom(v.itemrepair,v,11)
				else --not showrepair
					if otherinfoplacement then
						putothercenter(v.durability,v,15)
					else
						puttop(v.durability,v,11)
					end
				end
			else --not showdura
				if showrepair then
					if otherinfoplacement then
						putothercenter(v.itemrepair,v,15)
					else
						putbottom(v.itemrepair,v,11)
					end
				end
			end
			if otherinfoplacement then
				putilevel(v.ilevel,v,16)
			else
				if not (showdura or showrepair) then
					putilevel(v.ilevel,v,16)
				else
					putilevel(v.ilevel,v,14)
				end
			end
		else
			if showdura then 
				if showrepair then
					puttop(v.durability,v,11)
					putbottom(v.itemrepair,v,11)
				else --not showrepair
					if otherinfoplacement then
						putothercenter(v.durability,v,15)
					else
						putcenter(v.durability,v,15)
					end
				end
			else --not showdura
				if showrepair then
					if otherinfoplacement then
						putothercenter(v.itemrepair,v,15)
					else
						putcenter(v.itemrepair,v,15)
					end
				end
			end
		end
		if showenchant then
			putenchant(v.enchant,v,11)
		end
	end
end

---------------------------------
-- Durability Mean Calculation --
---------------------------------
function DCS_Mean_DurabilityCalc()
	addon.duraMean = 0
	duraTotal = 0
	duraMaxTotal = 0
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		-- --------------------------
		-- -- Mean Durability Calc --
		-- --------------------------
		if durCur == nil then durCur = 0 end
		if durMax == nil then durMax = 0 end
		
		duraTotal = duraTotal + durCur
		duraMaxTotal = duraMaxTotal + durMax
	end
	if duraMaxTotal == 0 then 
		duraMaxTotal = 1
		duraTotal = 1 --if nothing to break then durability should be 100%
	end --puting outside of for loop
	addon.duraMean = ((duraTotal/duraMaxTotal)*100)
end		

-----------------------------------
-- Durability Frame Mean Display --
-----------------------------------
local function DCS_Durability_Frame_Mean_Display()
	--DCS_Mean_DurabilityCalc() -- DCS_Mean_DurabilityCalc called already before
	duraDurabilityFrameFS:SetFormattedText("%.0f%%", addon.duraMean)
	duraDurabilityFrameFS:Show()
--	print(addon.duraMean)
	if addon.duraMean == 100 then --If mean is 100 hide text % display
		duraDurabilityFrameFS:Hide()
	elseif addon.duraMean >= 80 then --If mean is 80% or greater color the text off-white.
		duraDurabilityFrameFS:SetTextColor(0.753, 0.753, 0.753)
	elseif addon.duraMean > 66 then --If mean is 66% or greater then color the text green.
		duraDurabilityFrameFS:SetTextColor(0, 1, 0)
	elseif addon.duraMean > 33 then --If mean is 33% or greater then color the text yellow.
		duraDurabilityFrameFS:SetTextColor(1, 1, 0)
	elseif addon.duraMean >= 0 then --If mean is 0% or greater then color the text red. Is this check needed?
		duraDurabilityFrameFS:SetTextColor(1, 0, 0)
	end
end

-----------------------------------
-- Mean Durability Shirt Display --
-----------------------------------
local function DCS_Mean_Durability()
	DCS_Mean_DurabilityCalc()
    if addon.duraMean < 10 then
		duraMeanFS:SetTextColor(1, 0, 0)
	elseif addon.duraMean < 33 then
		duraMeanFS:SetTextColor(1, 0, 0)
	elseif addon.duraMean < 66 then
	    duraMeanFS:SetTextColor(1, 1, 0)
	elseif addon.duraMean < 80 then
		duraMeanFS:SetTextColor(0, 1, 0)
	elseif addon.duraMean < 100 then
		duraMeanFS:SetTextColor(0.753, 0.753, 0.753)
	end
	if DurabilityFrame:IsVisible() then
		DCS_Durability_Frame_Mean_Display()
	end
end

----------------------------
-- Item Durability Colors --
----------------------------
local function DCS_Item_DurabilityTop()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		--if durCur == nil or durMax == nil then
		--	v.duratexture:SetColorTexture(0, 0, 0, 0)
		--	v.durability:SetFormattedText("")
		--elseif ( durCur == durMax ) then
		if ( durCur == durMax ) then
			--v.duratexture:SetColorTexture(0, 0, 0, 0) --moving texture stuff to textures
			v.durability:SetFormattedText("")
		else --if ( durCur ~= durMax ) then -- no need to check, can remain as comment for easier understanding
			duraFinite = ((durCur/durMax)*100)
			--print(duraFinite)
		    v.durability:SetFormattedText("%.0f%%", duraFinite)
			--if duraFinite == 100 then --this should be covered by durCur == durMax
			--	v.duratexture:SetColorTexture(0,  0, 0, 0)
			--	v.durability:SetTextColor(0, 0, 0, 0)
			--	print ("what is this")
			--elseif duraFinite > 66 then
			if duraFinite > 66 then
				--v.duratexture:SetColorTexture(0, 1, 0)
				v.durability:SetTextColor(0, 1, 0)
			elseif duraFinite > 33 then
				--v.duratexture:SetColorTexture(1, 1, 0)
				v.durability:SetTextColor(1, 1, 0)
			elseif duraFinite > 10 then
				--v.duratexture:SetColorTexture(1, 0, 0)
				v.durability:SetTextColor(1, 0, 0)
			else --if duraFinite <= 10 then -- no need to check, can remain as comment for easier understanding
				--v.duratexture:SetAllPoints(v) -Removed so green boxes do not appear when durability is at zero.
				--v.duratexture:SetColorTexture(1, 0, 0, 0.10)
				v.durability:SetTextColor(1, 0, 0)
			end
		end
		--DCS_Mean_DurabilityCalc() -- moving outside for loop
	end
	--DCS_Mean_DurabilityCalc() -- seems like it gets called even before this
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDuraChecked = {
	ShowDuraSetChecked = true,
}	

local DCS_ShowDuraCheck = CreateFrame("CheckButton", "DCS_ShowDuraCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowDuraCheck:ClearAllPoints()
	DCS_ShowDuraCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -75)
	DCS_ShowDuraCheck:SetScale(1)
	DCS_ShowDuraCheck.tooltipText = L["Displays each equipped item's durability."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraCheck:GetName() .. "Text"]:SetText(L["Item Durability"])

local event	--TODO: delete second variable event that might appear after merging
DCS_ShowDuraCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showdura = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
		self:SetChecked(showdura)
		DCS_Set_Dura_Item_Positions()
	end
	if PaperDollFrame:IsVisible() then
		if showdura then
			DCS_Item_DurabilityTop()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.durability:SetFormattedText("")
			end
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
		self:SetChecked(checked)
		DCS_Set_Dura_Item_Positions()
		if checked then
			DCS_Item_DurabilityTop()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.durability:SetFormattedText("")
			end
		end
	end
end)

DCS_ShowDuraCheck:SetScript("OnClick", function(self)
	showdura = not showdura
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked = showdura
	DCS_Set_Dura_Item_Positions() --same line irrespectfully of the condtition
	if showdura then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked = checked
	DCS_Set_Dura_Item_Positions() --same line irrespectfully of the condtition
	if checked then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
end)

--------------------------------------
-- Durability Bar Textures Creation --
--------------------------------------
local function DCS_Durability_Bar_Textures()
	-- I see really similar loop in DCS_Item_DurabilityTop(), can't they be merged (of course, need to check whether they get called within the same condition)
	duraTotal = 0 --calculation of average for shirt bar is also here
	duraMaxTotal = 0
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		if durCur == nil then durCur = 0 end
		if durMax == nil then durMax = 0 end
		duraTotal = duraTotal + durCur
		duraMaxTotal = duraMaxTotal + durMax
		if ( durCur == durMax ) then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		else --if ( durCur ~= durMax ) then -- no need to check, can remain as comment for easier understanding
			duraFinite = durCur/durMax
            if duraFinite > 0.66 then
	            v.duratexture:SetColorTexture(0, 1, 0)
		    elseif duraFinite > 0.33 then
				v.duratexture:SetColorTexture(1, 1, 0)
			elseif duraFinite > 0.10 then
				v.duratexture:SetColorTexture(1, 0, 0)
			else --if duraFinite <= 0.10 then -- no need to check, can remain as comment for easier understanding
				v.duratexture:SetColorTexture(1, 0, 0, 0.10)
			end
		    if DCSITEM_SLOT_FRAMES_RIGHT[v] then
		        v.duratexture:SetPoint("BOTTOMLEFT",v,"BOTTOMRIGHT",1,3)
			    v.duratexture:SetSize(4, (31*duraFinite))
			else
                v.duratexture:SetPoint("BOTTOMRIGHT",v,"BOTTOMLEFT",-2,3)
				v.duratexture:SetSize(3, (31*duraFinite))
			end
		    v.duratexture:Show()
		end
	end
	if duraMaxTotal == 0 then 
		duraMaxTotal = 1
		duraTotal = 1 --if nothing to break then durability should be 100%
	end
	local duraMean = duraTotal/duraMaxTotal
	duraMeanTexture:SetSize(4, 31*duraMean)
	if duraMean == 1 then 
		duraMeanTexture:SetColorTexture(0, 0, 0, 0)
	elseif duraMean < 0.10 then
		--duraMeanTexture:SetColorTexture(1, 0, 0)
		duraMeanTexture:SetColorTexture(1, 0, 0, 0.15)
	elseif duraMean < 0.33 then
		duraMeanTexture:SetColorTexture(1, 0, 0)
	elseif duraMean < 0.66 then
		duraMeanTexture:SetColorTexture(1, 1, 0)
	elseif duraMean < 0.80 then
		duraMeanTexture:SetColorTexture(0, 1, 0)
	else --if duraMean < 1 then -- no need to check, can remain as comment for easier understanding
		duraMeanTexture:SetColorTexture(0.753, 0.753, 0.753)
	end
	duraMeanTexture:ClearAllPoints()
	if duraMean > 0.10 then 
		duraMeanTexture:SetPoint("BOTTOMLEFT",DCS_CharacterShirtSlot,"BOTTOMRIGHT",1,3)
	else --if duraMean <= 0.10 then -- no need to check, can remain as comment for easier understanding
		duraMeanTexture:SetAllPoints(DCS_CharacterShirtSlot)
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDuraTextureChecked = {
	ShowDuraTextureSetChecked = true,
}	

local DCS_ShowDuraTextureCheck = CreateFrame("CheckButton", "DCS_ShowDuraTextureCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraTextureCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraTextureCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraTextureCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowDuraTextureCheck:ClearAllPoints()
	DCS_ShowDuraTextureCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -35)
	DCS_ShowDuraTextureCheck:SetScale(1) 
	DCS_ShowDuraTextureCheck.tooltipText = L["Displays a durability bar next to each item."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraTextureCheck:GetName() .. "Text"]:SetText(L["Durability Bars"])
	
DCS_ShowDuraTextureCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showtextures = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked
		self:SetChecked(showtextures)
	end
	--print("DCS_ShowDuraTextureCheck:SetScript(OnEvent)")
	if PaperDollFrame:IsVisible() then
		--print("PaperDollFrame:IsVisible()")
		if showtextures then
			--print("showtextures")
			DCS_Durability_Bar_Textures()
			--DCS_Mean_Durability() --average durability for bar near shirt should be in DCS_Durability_Bar_Textures()
			--DCS_Item_DurabilityTop() --all single item durability stuff should be in DCS_Durability_Bar_Textures()
			duraMeanTexture:Show()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.duratexture:Hide()
			end
			duraMeanTexture:Hide()
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked
		self:SetChecked(checked)
		if checked then
			DCS_Durability_Bar_Textures()
			DCS_Mean_Durability()
			DCS_Item_DurabilityTop()
			duraMeanTexture:Show()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.duratexture:Hide()
			end
			duraMeanTexture:Hide()
		end
	end
end)

DCS_ShowDuraTextureCheck:SetScript("OnClick", function(self)
	showtextures = not showtextures
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked = showtextures
	if showtextures then
		DCS_Durability_Bar_Textures()
		--DCS_Mean_Durability() --average durability for bar near shirt should be in DCS_Durability_Bar_Textures()
		--DCS_Item_DurabilityTop() --all single item durability stuff should be in DCS_Durability_Bar_Textures()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked = checked
	if checked then
		DCS_Durability_Bar_Textures()
		DCS_Mean_Durability()
		DCS_Item_DurabilityTop()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
end)

------------------------
-- Average Durability --
------------------------

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowAverageRepairChecked = {
	ShowAverageRepairSetChecked = true,
}	

local DCS_ShowAverageDuraCheck = CreateFrame("CheckButton", "DCS_ShowAverageDuraCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowAverageDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowAverageDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowAverageDuraCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowAverageDuraCheck:ClearAllPoints()
	DCS_ShowAverageDuraCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -55)
	DCS_ShowAverageDuraCheck:SetScale(1)
	DCS_ShowAverageDuraCheck.tooltipText = L["Displays average item durability on the character shirt slot and durability frames."] --Creates a tooltip on mouseover.
	_G[DCS_ShowAverageDuraCheck:GetName() .. "Text"]:SetText(L["Average Durability"])
	
	DCS_ShowAverageDuraCheck:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			showavgdur = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowAverageRepairChecked.ShowAverageRepairSetChecked
			self:SetChecked(showavgdur)
		end
		--print(..., DurabilityFrame:IsVisible(),DurabilityFrame:IsShown())
		if showavgdur and (DurabilityFrame:IsVisible() or PaperDollFrame:IsVisible()) then
			DCS_Mean_Durability()
			if addon.duraMean == 100 then --check after calculation
				duraMeanFS:SetFormattedText("")
			else
				duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
			end
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
		end
	end)

	DCS_ShowAverageDuraCheck:SetScript("OnClick", function(self)
		showavgdur = not showavgdur
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowAverageRepairChecked.ShowAverageRepairSetChecked = showavgdur
		if showavgdur then
			DCS_Mean_Durability()
			if addon.duraMean == 100 then --check after calculation
				duraMeanFS:SetFormattedText("")
			else
				duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
			end
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
		end
	end)
	
----------------------
-- Item Repair Cost --
----------------------
local function DCS_Item_RepairCostBottom()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local scanTool = CreateFrame("GameTooltip")
			scanTool:ClearLines()
		local repairitemCost = select(3, scanTool:SetInventoryItem("player", slotId))
		if (repairitemCost<=0) then
			v.itemrepair:SetFormattedText("")
		elseif (repairitemCost>999999) then -- 99G 99s 99c
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.0fg", (repairitemCost/10000))
		elseif (repairitemCost>9999) then -- 99s 99c
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.2fg", (repairitemCost/10000))
		elseif (repairitemCost>99) then -- 99c
			v.itemrepair:SetTextColor(0.753, 0.753, 0.753)
			v.itemrepair:SetFormattedText("%.2fs", (repairitemCost/100))
		else
			v.itemrepair:SetTextColor(0.722, 0.451, 0.200)
			v.itemrepair:SetFormattedText("%.0fc", repairitemCost)
		end
	end
end


gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowItemRepairChecked = {
	ShowItemRepairSetChecked = true,
}	

local DCS_ShowItemRepairCheck = CreateFrame("CheckButton", "DCS_ShowItemRepairCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowItemRepairCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowItemRepairCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowItemRepairCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowItemRepairCheck:RegisterEvent("MERCHANT_SHOW")
	DCS_ShowItemRepairCheck:RegisterEvent("MERCHANT_CLOSED") --without this event repair cost should remain unchanged from the last vendor
	DCS_ShowItemRepairCheck:ClearAllPoints()
	DCS_ShowItemRepairCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -95)
	DCS_ShowItemRepairCheck:SetScale(1)
	DCS_ShowItemRepairCheck.tooltipText = L["Displays each equipped item's repair cost."] --Creates a tooltip on mouseover.
	_G[DCS_ShowItemRepairCheck:GetName() .. "Text"]:SetText(L["Item Repair Cost"])
	
DCS_ShowItemRepairCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		-- print(self:GetChecked())
		showrepair = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
		self:SetChecked(showrepair)
		DCS_Set_Dura_Item_Positions()
	end
	--print("want to recalculate repairs")
	if PaperDollFrame:IsVisible() then
		--print("recalculating repairs")
		if showrepair then
			DCS_Item_RepairCostBottom()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.itemrepair:SetFormattedText("")
			end
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
		self:SetChecked(checked)
		DCS_Set_Dura_Item_Positions()
		if checked then
			DCS_Item_RepairCostBottom()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.itemrepair:SetFormattedText("")
			end
		end
	end
end)

DCS_ShowItemRepairCheck:SetScript("OnClick", function(self)
	showrepair = not showrepair
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked = showrepair
	DCS_Set_Dura_Item_Positions()
	if showrepair then
		DCS_Item_RepairCostBottom()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked = checked
	DCS_Set_Dura_Item_Positions()
	if checked then
		DCS_Item_RepairCostBottom()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
end)

local function attempt_ilvl(v,attempts)
	if attempts > 0 then
		local item = Item:CreateFromEquipmentSlot(v:GetID())
		local value = item:GetCurrentItemLevel()
		if value then --ilvl of nil probably indicates that there's no tem in that slot
			if value > 0 then --ilvl of 0 probably indicates that item is not fully loaded
				v.ilevel:SetTextColor(getItemQualityColor(item:GetItemQuality())) --upvalue call
				v.ilevel:SetText(value)
			else
				C_Timer.After(0.2, function() attempt_ilvl(v,attempts-1) end)
			end
		else
			v.ilevel:SetText("")
		end
	end
end

local function DCS_Item_Level_Center()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		attempt_ilvl(v,20)
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowItemLevelChecked = {
	ShowItemLevelSetChecked = true,
}

local DCS_ShowItemLevelCheck = CreateFrame("CheckButton", "DCS_ShowItemLevelCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowItemLevelCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowItemLevelCheck:ClearAllPoints()
	DCS_ShowItemLevelCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -15)
	DCS_ShowItemLevelCheck:SetScale(1)
	DCS_ShowItemLevelCheck.tooltipText = L["Displays the item level of each equipped item. Caveat; Item level is relatively meaningless in Classic."] --Creates a tooltip on mouseover.
	_G[DCS_ShowItemLevelCheck:GetName() .. "Text"]:SetText(L["Item Level"])
	
DCS_ShowItemLevelCheck:SetScript("OnEvent", function(self, event, ...)
	showitemlevel = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemLevelChecked.ShowItemLevelSetChecked
	self:SetChecked(showitemlevel)
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Level_Center() --why it is called
end)

DCS_ShowItemLevelCheck:SetScript("OnClick", function(self)
	showitemlevel = not showitemlevel
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemLevelChecked.ShowItemLevelSetChecked = showitemlevel
	DCS_Set_Dura_Item_Positions() --is this call needed? (Yes, it is -Deja)
	if showitemlevel then --TODO: rewrite of DCS_Item_Level_Center because in 3 places the same code
		DCS_Item_Level_Center()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.ilevel:SetFormattedText("")
		end
	end
end)

local DCS_ShowItemLevelChange = CreateFrame("Frame", "DCS_ShowItemLevelChange", UIParent)
	DCS_ShowItemLevelChange:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	
DCS_ShowItemLevelChange:SetScript("OnEvent", function(self, event, ...)
	if PaperDollFrame:IsVisible() then
		--print("PaperDollFrame:IsVisible")
		if showitemlevel then
		--print("showitemlevel")
			C_Timer.After(0.25, DCS_Item_Level_Center) --Event fires before Artifact changes so we have to wait a fraction of a second.
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.ilevel:SetFormattedText("")
			end
		end
	end
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsSimpleItemColorChecked = {
	SimpleItemColorChecked = false,
	DarkerItemColorChecked = false,
}

local function paintblack()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		if simpleitemcolor then
			v.itemcolor:SetColorTexture(0, 0, 0, 1)
			v.itemcolor:Show()
		elseif darkeritemcolor then
			v.itemcolor:SetColorTexture(0, 0, 0, 0.6)
			v.itemcolor:Show()
		else
			v.itemcolor:Hide()
		end
	end
end

local DCS_SimpleItemColorCheck = CreateFrame("CheckButton", "DCS_SimpleItemColorCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_SimpleItemColorCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_SimpleItemColorCheck:ClearAllPoints()
	DCS_SimpleItemColorCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -135)
	DCS_SimpleItemColorCheck:SetScale(1)
	DCS_SimpleItemColorCheck.tooltipText = L["Black item icons to make text more visible."] --Creates a tooltip on mouseover.
	_G[DCS_SimpleItemColorCheck:GetName() .. "Text"]:SetText(L["Black Item Icons"])

local DCS_DarkerItemColorCheck = CreateFrame("CheckButton", "DCS_DarkerItemColorCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DarkerItemColorCheck:ClearAllPoints()
	DCS_DarkerItemColorCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -115)
	DCS_DarkerItemColorCheck:SetScale(1)
	DCS_DarkerItemColorCheck.tooltipText = L["Darken item icons to make text more visible."] --Creates a tooltip on mouseover.
	_G[DCS_DarkerItemColorCheck:GetName() .. "Text"]:SetText(L["Darken Item Icons"])

DCS_SimpleItemColorCheck:SetScript("OnEvent", function(self, event, ...)
	simpleitemcolor = gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked
	darkeritemcolor = gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked
	self:SetChecked(simpleitemcolor)
	DCS_DarkerItemColorCheck:SetChecked(darkeritemcolor)
	paintblack()
end)

DCS_SimpleItemColorCheck:SetScript("OnClick", function(self)
	simpleitemcolor = not simpleitemcolor
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked = simpleitemcolor
	if simpleitemcolor then
		DCS_DarkerItemColorCheck:SetChecked(false)
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked = false
		darkeritemcolor = false
	end
	paintblack()
end)

DCS_DarkerItemColorCheck:SetScript("OnClick", function(self)
	darkeritemcolor = not darkeritemcolor
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked = darkeritemcolor
	if darkeritemcolor then
		DCS_SimpleItemColorCheck:SetChecked(false)
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked = false
		simpleitemcolor = false
	end
	paintblack()
end)

-- local DCS_SimpleItemColor = CreateFrame("Frame", "DCS_SimpleItemColor", UIParent) --Needed? Doesn't seem so.
-- 	DCS_SimpleItemColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	
-- 	DCS_SimpleItemColor:SetScript("OnEvent", function(self, event, ...)
-- 		if PaperDollFrame:IsVisible() then
-- 			paintblack()
-- 		end
-- 	end)

local DCS_ENCHANT_IDS = {
	[1] = "Rockbiter 3",
	[2] = "Frostbrand 1",
	[3] = "Flametongue 3",
	[4] = "Flametongue 2",
	[5] = "Flametongue 1",
	[6] = "Rockbiter 2",
	[7] = "Deadly Poison",
	[8] = "Deadly Poison II",
	[9] = "Poison (15 Dmg)",
	[10] = "Poison (20 Dmg)",
	[11] = "Poison (25 Dmg)",
	[12] = "Frostbrand 2",
	[13] = "Sharpened +3",
	[14] = "Sharpened +4",
	[15] = "Reinforced Armor +8",
	[16] = "Reinforced Armor +16",
	[17] = "Reinforced Armor +24",
	[18] = "Reinforced Armor +32",
	[19] = "Weighted +2",
	[20] = "Weighted +3",
	[21] = "Weighted +4",
	[22] = "Crippling Poison",
	[23] = "Mind-numbing Poison II",
	[24] = "Mana +5",
	[25] = "Shadow Oil",
	[26] = "Frost Oil",
	[27] = "Sundered",
	[28] = "+4 All Resistances",
	[29] = "Rockbiter 1",
	[30] = "Scope (+1 Damage)",
	[31] = "Beastslaying +4",
	[32] = "Scope (+2 Damage)",
	[33] = "Scope (+3 Damage)",
	[34] = "Counterweight +3% Attack Speed",
	[35] = "Mind Numbing Poison",
	[36] = "Enchant: Fiery Blaze",
	[37] = "Weapon Chain - Immune Disarm",
	[38] = "Defense Skill +3",
	[39] = "Sharpened +1",
	[40] = "Sharpened +2",
	[41] = "Health +5",
	[42] = "Poison (Instant 20)",
	[43] = "Iron Spike (8-12)",
	[44] = "Absorption (10)",
	[63] = "Absorption (25)",
	[64] = "Spirit +3",
	[65] = "+1 All Resistances",
	[66] = "Stamina +1",
	[67] = "+1 Damage",
	[68] = "+1 Strength",
	[69] = "+2 Strength",
	[70] = "+3 Strength",
	[71] = "+1 Stamina",
	[72] = "+2 Stamina",
	[73] = "+3 Stamina",
	[74] = "+1 Agility",
	[75] = "+2 Agility",
	[76] = "+3 Agility",
	[77] = "+2 Damage",
	[78] = "+3 Damage",
	[79] = "+1 Intellect",
	[80] = "+2 Intellect",
	[81] = "+3 Intellect",
	[82] = "+1 Spirit",
	[83] = "+2 Spirit",
	[84] = "+3 Spirit",
	[85] = "+3 Armor",
	[86] = "+8 Armor",
	[87] = "+12 Armor",
	[89] = "+16 Armor",
	[90] = "+4 Agility",
	[91] = "+5 Agility",
	[92] = "+6 Agility",
	[93] = "+7 Agility",
	[94] = "+4 Intellect",
	[95] = "+5 Intellect",
	[96] = "+6 Intellect",
	[97] = "+7 Intellect",
	[98] = "+4 Spirit",
	[99] = "+5 Spirit",
	[100] = "+6 Spirit",
	[101] = "+7 Spirit",
	[102] = "+4 Stamina",
	[103] = "+5 Stamina",
	[104] = "+6 Stamina",
	[105] = "+7 Stamina",
	[106] = "+4 Strength",
	[107] = "+5 Strength",
	[108] = "+6 Strength",
	[109] = "+7 Strength",
	[110] = "+1 Defense",
	[111] = "+1 Defense",
	[112] = "+2 Defense",
	[113] = "+3 Defense",
	[114] = "+3 Defense",
	[115] = "+4 Defense",
	[116] = "+5 Defense",
	[117] = "+4 Damage",
	[118] = "+5 Damage",
	[119] = "+6 Damage",
	[120] = "+7 Damage",
	[121] = "+20 Armor",
	[122] = "+24 Armor",
	[123] = "+28 Armor",
	[124] = "Flametongue Totem 1",
	[125] = "Sword Skill +1",
	[126] = "Sword Skill +2",
	[127] = "Sword Skill +3",
	[128] = "Sword Skill +4",
	[129] = "Sword Skill +5",
	[130] = "Sword Skill +6",
	[131] = "Sword Skill +7",
	[132] = "Two-Handed Sword Skill +1",
	[133] = "Two-Handed Sword Skill +2",
	[134] = "Two-Handed Sword Skill +3",
	[135] = "Two-Handed Sword Skill +4",
	[136] = "Two-Handed Sword Skill +5",
	[137] = "Two-Handed Sword Skill +6",
	[138] = "Two-Handed Sword Skill +7",
	[139] = "Mace Skill +1",
	[140] = "Mace Skill +2",
	[141] = "Mace Skill +3",
	[142] = "Mace Skill +4",
	[143] = "Mace Skill +5",
	[144] = "Mace Skill +6",
	[145] = "Mace Skill +7",
	[146] = "Two-Handed Mace Skill +1",
	[147] = "Two-Handed Mace Skill +2",
	[148] = "Two-Handed Mace Skill +3",
	[149] = "Two-Handed Mace Skill +4",
	[150] = "Two-Handed Mace Skill +5",
	[151] = "Two-Handed Mace Skill +6",
	[152] = "Two-Handed Mace Skill +7",
	[153] = "Axe Skill +1",
	[154] = "Axe Skill +2",
	[155] = "Axe Skill +3",
	[156] = "Axe Skill +4",
	[157] = "Axe Skill +5",
	[158] = "Ase Skill +6",
	[159] = "Axe Skill +7",
	[160] = "Two-Handed Axe Skill +1",
	[161] = "Two-Handed Axe Skill +2",
	[162] = "Two-Handed Axe Skill +3",
	[163] = "Two-Handed Axe Skill +4",
	[164] = "Two-Handed Axe Skill +5",
	[165] = "Two-Handed Axe Skill +6",
	[166] = "Two-Handed Axe Skill +7",
	[167] = "Dagger Skill +1",
	[168] = "Dagger Skill +2",
	[169] = "Dagger Skill +3",
	[170] = "Dagger Skill +4",
	[171] = "Dagger Skill +5",
	[172] = "Dagger Skill +6",
	[173] = "Dagger Skill +7",
	[174] = "Gun Skill +1",
	[175] = "Gun Skill +2",
	[176] = "Gun Skill +3",
	[177] = "Gun Skill +4",
	[178] = "Gun Skill +5",
	[179] = "Gun Skill +6",
	[180] = "Gun Skill +7",
	[181] = "Bow Skill +1",
	[182] = "Bow Skill +2",
	[183] = "Bow Skill +3",
	[184] = "Bow Skill +4",
	[185] = "Bow Skill +5",
	[186] = "Bow Skill +6",
	[187] = "Bow Skill +7",
	[188] = "+2 Beast Slaying",
	[189] = "+4 Beast Slaying",
	[190] = "+6 Beast Slaying",
	[191] = "+8 Beast Slaying",
	[192] = "+10 Beast Slaying",
	[193] = "+12 Beast Slaying",
	[194] = "+14 Beast Slaying",
	[195] = "Critical Hit +1%",
	[196] = "Critical Hit +2%",
	[197] = "Critical Hit +3%",
	[198] = "Critical Hit +4%",
	[199] = "10% On Get Hit: Shadow Bolt (10 Damage)",
	[200] = "10% On Get Hit: Shadow Bolt (20 Damage)",
	[201] = "10% On Get Hit: Shadow Bolt (30 Damage)",
	[202] = "10% On Get Hit: Shadow Bolt (40 Damage)",
	[203] = "10% On Get Hit: Shadow Bolt (50 Damage)",
	[204] = "10% On Get Hit: Shadow Bolt (60 Damage)",
	[205] = "10% On Get Hit: Shadow Bolt (70 Damage)",
	[206] = "Increases Healing +2",
	[207] = "Increases Healing +4",
	[208] = "Increases Healing +7",
	[209] = "Increases Healing +9",
	[210] = "Increases Healing +11",
	[211] = "Increases Healing +13",
	[212] = "Increases Healing +15",
	[213] = "Increase Fire Effects +1",
	[214] = "Increases Fire Effects +3",
	[215] = "Increases Fire Effects +4",
	[216] = "Increases Fire Effects +6",
	[217] = "Increases Fire Effects +7",
	[218] = "Increases Fire Damage +9",
	[219] = "Increases Fire Damage +10",
	[220] = "Increases Nature Effects +1",
	[221] = "Increases Nature Effects +3",
	[222] = "Increases Nature Effects +4",
	[223] = "Increases Nature Effects +6",
	[224] = "Increases Nature Effects +7",
	[225] = "Increases Nature Effects +9",
	[226] = "Increases Nature Effects +10",
	[227] = "Increases Frost Effects +1",
	[228] = "Increases Frost Effects +3",
	[229] = "Increases Frost Effects +4",
	[230] = "Increases Frost Effects +6",
	[231] = "Increases Frost Effects +7",
	[232] = "Increases Frost Effects +9",
	[233] = "Increases Frost Effects +10",
	[234] = "Increases Shadow Effects +1",
	[235] = "Increases Shadow Effects +3",
	[236] = "Increases Shadow Effects +4",
	[237] = "Increases Shadow Effects +6",
	[238] = "Increases Shadow Effects +7",
	[239] = "Increases Shadow Effects +9",
	[240] = "Increases Shadow Effects +10",
	[241] = "Weapon Damage +2",
	[242] = "Health +15",
	[243] = "Spirit +1",
	[244] = "Intellect +4",
	[245] = "Armor +5",
	[246] = "Mana +20",
	[247] = "Agility +1",
	[248] = "Strength +1",
	[249] = "Beastslaying +2",
	[250] = "Weapon Damage +1 ",
	[251] = "Intellect +1",
	[252] = "Spirit +6",
	[253] = "Absorption (50)",
	[254] = "Health +25",
	[255] = "Spirit +3",
	[256] = "+5 Fire Resistance",
	[257] = "Armor +10",
	[263] = "Fishing Lure +25",
	[264] = "Fishing Lure +50",
	[265] = "Fishing Lure +75",
	[266] = "Fishing Lure +100",
	[283] = "Windfury 1",
	[284] = "Windfury 2",
	[285] = "Flametongue Totem 2",
	[286] = "+2 Weapon Fire Damage",
	[287] = "+4 Weapon Fire Damage",
	[288] = "+6 Weapon Fire Damage",
	[289] = "+8 Weapon Fire Damage",
	[290] = "+10 Weapon Fire Damage",
	[291] = "+12 Weapon Fire Damage",
	[292] = "+14 Weapon Fire Damage",
	[303] = "Orb of Fire",
	[323] = "Instant Poison",
	[324] = "Instant Poison II",
	[325] = "Instant Poison III",
	[343] = "+8 Agility",
	[344] = "+32 Armor",
	[345] = "+40 Armor",
	[346] = "+36 Armor",
	[347] = "+44 Armor",
	[348] = "+48 Armor",
	[349] = "+9 Agility",
	[350] = "+8 Intellect",
	[351] = "+8 Spirit",
	[352] = "+8 Strength",
	[353] = "+8 Stamina",
	[354] = "+9 Intellect",
	[355] = "+9 Spirit",
	[356] = "+9 Stamina",
	[357] = "+9 Strength",
	[358] = "+10 Agility",
	[359] = "+10 Intellect",
	[360] = "+10 Spirit",
	[361] = "+10 Stamina",
	[362] = "+10 Strength",
	[363] = "+11 Agility",
	[364] = "+11 Intellect",
	[365] = "+11 Spirit",
	[366] = "+11 Stamina",
	[367] = "+11 Strength",
	[368] = "+12 Agility",
	[369] = "+12 Intellect",
	[370] = "+12 Spirit",
	[371] = "+12 Stamina",
	[372] = "+12 Strength",
	[383] = "+52 Armor",
	[384] = "+56 Armor",
	[385] = "+60 Armor",
	[386] = "+16 Armor",
	[387] = "+17 Armor",
	[388] = "+18 Armor",
	[389] = "+19 Armor",
	[403] = "+13 Agility",
	[404] = "+14 Agility",
	[405] = "+13 Intellect",
	[406] = "+14 Intellect",
	[407] = "+13 Spirit",
	[408] = "+14 Spirit",
	[409] = "+13 Stamina",
	[410] = "+13 Strength",
	[411] = "+14 Stamina",
	[412] = "+14 Strength",
	[423] = "Increase Spell Damage +1",
	[424] = "Increase Spell Damage +2",
	[425] = "Increase Spell Damage +4",
	[426] = "Increase Spell Damage +5",
	[427] = "Increase Spell Damage +6",
	[428] = "Increase Spell Damage +7",
	[429] = "Increase Spell Damage +8",
	[430] = "Increase Spell Damage +9",
	[431] = "Increase Spell Damage +11",
	[432] = "Increase Spell Damage +12",
	[433] = "Increase Fire Damage +11",
	[434] = "Increase Fire Damage +13",
	[435] = "Increases Fire Damage +14",
	[436] = "Critical Hit +5%",
	[437] = "Increases Frost Effects +11",
	[438] = "Increases Frost Effects +13",
	[439] = "Increases Frost Effects +14",
	[440] = "Increases Healing +12",
	[441] = "Increases Healing +20",
	[442] = "Increases Healing +22",
	[443] = "Increases Nature Effects +11",
	[444] = "Increases Nature Effects +13",
	[445] = "Increases Nature Effects +14",
	[446] = "Increases Shadow Effects +11",
	[447] = "Increases Shadow Effects +13",
	[448] = "Increases Shadow Effects +14",
	[463] = "Mithril Spike (16-20)",
	[464] = "Mithril Spurs",
	[483] = "Sharpened +6",
	[484] = "Weighted +6",
	[503] = "Rockbiter 4",
	[504] = "Rockbiter +80",
	[523] = "Flametongue 4",
	[524] = "Frostbrand 3",
	[525] = "Windfury 3",
	[543] = "Flametongue Totem 3",
	[563] = "Windfury Totem 2",
	[564] = "Windfury Totem 3",
	[583] = "+1 Agility / +1 Spirit",
	[584] = "+1 Agility / +1 Intellect",
	[585] = "+1 Agility / +1 Stamina",
	[586] = "+1 Agility / +1 Strength",
	[587] = "+1 Intellect / +1 Spirit",
	[588] = "+1 Intellect / +1 Stamina",
	[589] = "+1 Intellect / +1 Strength",
	[590] = "+1 Spirit / +1 Stamina",
	[591] = "+1 Spirit / +1 Strength",
	[592] = "+1 Stamina / +1 Strength",
	[603] = "Crippling Poison II",
	[623] = "Instant Poison IV",
	[624] = "Instant Poison V",
	[625] = "Instant Poison VI",
	[626] = "Deadly Poison III",
	[627] = "Deadly Poison IV",
	[643] = "Mind-Numbing Poison III",
	[663] = "Scope (+5 Damage)",
	[664] = "Scope (+7 Damage)",
	[683] = "Rockbiter 6",
	[684] = "+15 Strength",
	[703] = "Wound Poison",
	[704] = "Wound Poison II",
	[705] = "Wound Poison III",
	[706] = "Wound Poison IV",
	[723] = "Intellect +3",
	[724] = "Stamina +3",
	[743] = "Stealth +2",
	[744] = "Armor +20",
	[763] = "Block +1%",
	[783] = "Armor +10",
	[803] = "Fiery Weapon",
	[804] = "+10 Shadow Resistance",
	[805] = "Weapon Damage +4",
	[823] = "Strength +3",
	[843] = "Mana +30",
	[844] = "Mining +2",
	[845] = "Herbalism +2",
	[846] = "Fishing +2",
	[847] = "All Stats +1",
	[848] = "Armor +30",
	[849] = "Agility +3",
	[850] = "Health +35",
	[851] = "Spirit +5",
	[852] = "Stamina +5",
	[853] = "Beastslaying +6",
	[854] = "Elemental Slayer +6",
	[855] = "+5 Fire Resistance",
	[856] = "Strength +5",
	[857] = "Mana +50",
	[863] = "Blocking +2%",
	[864] = "Weapon Damage +4",
	[865] = "Skinning +5",
	[866] = "All Stats +2",
	[883] = "+15 Agility",
	[884] = "Armor +50",
	[903] = "+3 All Resistances",
	[904] = "Agility +5",
	[905] = "Intellect +5",
	[906] = "Mining +5",
	[907] = "Spirit +7",
	[908] = "Health +50",
	[909] = "Herbalism +5",
	[910] = "Increased Stealth",
	[911] = "Minor Speed Increase",
	[912] = "Demonslaying",
	[913] = "Mana +65",
	[923] = "Defense +3",
	[924] = "Defense +1",
	[925] = "Defense +2",
	[926] = "+8 Frost Resistance",
	[927] = "Strength +7",
	[928] = "All Stats +3",
	[929] = "Stamina +7",
	[930] = "Minor Mount Speed Increase",
	[931] = "Attack Speed +1%",
	[943] = "Weapon Damage +3",
	[963] = "Weapon Damage +7",
	[983] = "+16 Agility",
	[1003] = "Venomhide Poison",
	[1023] = "Feedback 1",
	[1043] = "+16 Strength",
	[1044] = "+17 Strength",
	[1045] = "+18 Strength",
	[1046] = "+19 Strength",
	[1047] = "+20 Strength",
	[1048] = "+21 Strength",
	[1049] = "+22 Strength",
	[1050] = "+23 Strength",
	[1051] = "+24 Strength",
	[1052] = "+25 Strength",
	[1053] = "+26 Strength",
	[1054] = "+27 Strength",
	[1055] = "+28 Strength",
	[1056] = "+29 Strength",
	[1057] = "+30 Strength",
	[1058] = "+31 Strength",
	[1059] = "+32 Strength",
	[1060] = "+33 Strength",
	[1061] = "+34 Strength",
	[1062] = "+35 Strength",
	[1063] = "+36 Strength",
	[1064] = "+37 Strength",
	[1065] = "+38 Strength",
	[1066] = "+39 Strength",
	[1067] = "+40 Strength",
	[1068] = "+15 Stamina",
	[1069] = "+16 Stamina",
	[1070] = "+17 Stamina",
	[1071] = "+18 Stamina",
	[1072] = "+19 Stamina",
	[1073] = "+20 Stamina",
	[1074] = "+21 Stamina",
	[1075] = "+22 Stamina",
	[1076] = "+23 Stamina",
	[1077] = "+24 Stamina",
	[1078] = "+25 Stamina",
	[1079] = "+26 Stamina",
	[1080] = "+27 Stamina",
	[1081] = "+28 Stamina",
	[1082] = "+29 Stamina",
	[1083] = "+30 Stamina",
	[1084] = "+31 Stamina",
	[1085] = "+32 Stamina",
	[1086] = "+33 Stamina",
	[1087] = "+34 Stamina",
	[1088] = "+35 Stamina",
	[1089] = "+36 Stamina",
	[1090] = "+37 Stamina",
	[1091] = "+38 Stamina",
	[1092] = "+39 Stamina",
	[1093] = "+40 Stamina",
	[1094] = "+17 Agility",
	[1095] = "+18 Agility",
	[1096] = "+19 Agility",
	[1097] = "+20 Agility",
	[1098] = "+21 Agility",
	[1099] = "+22 Agility",
	[1100] = "+23 Agility",
	[1101] = "+24 Agility",
	[1102] = "+25 Agility",
	[1103] = "+26 Agility",
	[1104] = "+27 Agility",
	[1105] = "+28 Agility",
	[1106] = "+29 Agility",
	[1107] = "+30 Agility",
	[1108] = "+31 Agility",
	[1109] = "+32 Agility",
	[1110] = "+33 Agility",
	[1111] = "+34 Agility",
	[1112] = "+35 Agility",
	[1113] = "+36 Agility",
	[1114] = "+37 Agility",
	[1115] = "+38 Agility",
	[1116] = "+39 Agility",
	[1117] = "+40 Agility",
	[1118] = "+15 Intellect",
	[1119] = "+16 Intellect",
	[1120] = "+17 Intellect",
	[1121] = "+18 Intellect",
	[1122] = "+19 Intellect",
	[1123] = "+20 Intellect",
	[1124] = "+21 Intellect",
	[1125] = "+22 Intellect",
	[1126] = "+23 Intellect",
	[1127] = "+24 Intellect",
	[1128] = "+25 Intellect",
	[1129] = "+26 Intellect",
	[1130] = "+27 Intellect",
	[1131] = "+28 Intellect",
	[1132] = "+29 Intellect",
	[1133] = "+30 Intellect",
	[1134] = "+31 Intellect",
	[1135] = "+32 Intellect",
	[1136] = "+33 Intellect",
	[1137] = "+34 Intellect",
	[1138] = "+35 Intellect",
	[1139] = "+36 Intellect",
	[1140] = "+37 Intellect",
	[1141] = "+38 Intellect",
	[1142] = "+39 Intellect",
	[1143] = "+40 Intellect",
	[1144] = "+15 Spirit",
	[1145] = "+16 Spirit",
	[1146] = "+17 Spirit",
	[1147] = "+18 Spirit",
	[1148] = "+19 Spirit",
	[1149] = "+20 Spirit",
	[1150] = "+21 Spirit",
	[1151] = "+22 Spirit",
	[1152] = "+23 Spirit",
	[1153] = "+24 Spirit",
	[1154] = "+25 Spirit",
	[1155] = "+26 Spirit",
	[1156] = "+27 Spirit",
	[1157] = "+28 Spirit",
	[1158] = "+29 Spirit",
	[1159] = "+30 Spirit",
	[1160] = "+31 Spirit",
	[1161] = "+32 Spirit",
	[1162] = "+33 Spirit",
	[1163] = "+34 Spirit",
	[1164] = "+36 Spirit",
	[1165] = "+37 Spirit",
	[1166] = "+38 Spirit",
	[1167] = "+39 Spirit",
	[1168] = "+40 Spirit",
	[1183] = "+35 Spirit",
	[1203] = "+41 Strength",
	[1204] = "+42 Strength",
	[1205] = "+43 Strength",
	[1206] = "+44 Strength",
	[1207] = "+45 Strength",
	[1208] = "+46 Strength",
	[1209] = "+41 Stamina",
	[1210] = "+42 Stamina",
	[1211] = "+43 Stamina",
	[1212] = "+44 Stamina",
	[1213] = "+45 Stamina",
	[1214] = "+46 Stamina",
	[1215] = "+41 Agility",
	[1216] = "+42 Agility",
	[1217] = "+43 Agility",
	[1218] = "+44 Agility",
	[1219] = "+45 Agility",
	[1220] = "+46 Agility",
	[1221] = "+41 Intellect",
	[1222] = "+42 Intellect",
	[1223] = "+43 Intellect",
	[1224] = "+44 Intellect",
	[1225] = "+45 Intellect",
	[1226] = "+46 Intellect",
	[1227] = "+41 Spirit",
	[1228] = "+42 Spirit",
	[1229] = "+43 Spirit",
	[1230] = "+44 Spirit",
	[1231] = "+45 Spirit",
	[1232] = "+46 Spirit",
	[1243] = "+1 Arcane Resistance",
	[1244] = "+2 Arcane Resistance",
	[1245] = "+3 Arcane Resistance",
	[1246] = "+4 Arcane Resistance",
	[1247] = "+5 Arcane Resistance",
	[1248] = "+6 Arcane Resistance",
	[1249] = "+7 Arcane Resistance",
	[1250] = "+8 Arcane Resistance",
	[1251] = "+9 Arcane Resistance",
	[1252] = "+10 Arcane Resistance",
	[1253] = "+11 Arcane Resistance",
	[1254] = "+12 Arcane Resistance",
	[1255] = "+13 Arcane Resistance",
	[1256] = "+14 Arcane Resistance",
	[1257] = "+15 Arcane Resistance",
	[1258] = "+16 Arcane Resistance",
	[1259] = "+17 Arcane Resistance",
	[1260] = "+18 Arcane Resistance",
	[1261] = "+19 Arcane Resistance",
	[1262] = "+20 Arcane Resistance",
	[1263] = "+21 Arcane Resistance",
	[1264] = "+22 Arcane Resistance",
	[1265] = "+23 Arcane Resistance",
	[1266] = "+24 Arcane Resistance",
	[1267] = "+25 Arcane Resistance",
	[1268] = "+26 Arcane Resistance",
	[1269] = "+27 Arcane Resistance",
	[1270] = "+28 Arcane Resistance",
	[1271] = "+29 Arcane Resistance",
	[1272] = "+30 Arcane Resistance",
	[1273] = "+31 Arcane Resistance",
	[1274] = "+32 Arcane Resistance",
	[1275] = "+33 Arcane Resistance",
	[1276] = "+34 Arcane Resistance",
	[1277] = "+35 Arcane Resistance",
	[1278] = "+36 Arcane Resistance",
	[1279] = "+37 Arcane Resistance",
	[1280] = "+38 Arcane Resistance",
	[1281] = "+39 Arcane Resistance",
	[1282] = "+40 Arcane Resistance",
	[1283] = "+41 Arcane Resistance",
	[1284] = "+42 Arcane Resistance",
	[1285] = "+43 Arcane Resistance",
	[1286] = "+44 Arcane Resistance",
	[1287] = "+45 Arcane Resistance",
	[1288] = "+46 Arcane Resistance",
	[1289] = "+1 Frost Resistance",
	[1290] = "+2 Frost Resistance",
	[1291] = "+3 Frost Resistance",
	[1292] = "+4 Frost Resistance",
	[1293] = "+5 Frost Resistance",
	[1294] = "+6 Frost Resistance",
	[1295] = "+7 Frost Resistance",
	[1296] = "+8 Frost Resistance",
	[1297] = "+9 Frost Resistance",
	[1298] = "+10 Frost Resistance",
	[1299] = "+11 Frost Resistance",
	[1300] = "+12 Frost Resistance",
	[1301] = "+13 Frost Resistance",
	[1302] = "+14 Frost Resistance",
	[1303] = "+15 Frost Resistance",
	[1304] = "+16 Frost Resistance",
	[1305] = "+17 Frost Resistance",
	[1306] = "+18 Frost Resistance",
	[1307] = "+19 Frost Resistance",
	[1308] = "+20 Frost Resistance",
	[1309] = "+21 Frost Resistance",
	[1310] = "+22 Frost Resistance",
	[1311] = "+23 Frost Resistance",
	[1312] = "+24 Frost Resistance",
	[1313] = "+25 Frost Resistance",
	[1314] = "+26 Frost Resistance",
	[1315] = "+27 Frost Resistance",
	[1316] = "+28 Frost Resistance",
	[1317] = "+29 Frost Resistance",
	[1318] = "+30 Frost Resistance",
	[1319] = "+31 Frost Resistance",
	[1320] = "+32 Frost Resistance",
	[1321] = "+33 Frost Resistance",
	[1322] = "+34 Frost Resistance",
	[1323] = "+35 Frost Resistance",
	[1324] = "+36 Frost Resistance",
	[1325] = "+37 Frost Resistance",
	[1326] = "+38 Frost Resistance",
	[1327] = "+39 Frost Resistance",
	[1328] = "+40 Frost Resistance",
	[1329] = "+41 Frost Resistance",
	[1330] = "+42 Frost Resistance",
	[1331] = "+43 Frost Resistance",
	[1332] = "+44 Frost Resistance",
	[1333] = "+45 Frost Resistance",
	[1334] = "+46 Frost Resistance",
	[1335] = "+1 Fire Resistance",
	[1336] = "+2 Fire Resistance",
	[1337] = "+3 Fire Resistance",
	[1338] = "+4 Fire Resistance",
	[1339] = "+5 Fire Resistance",
	[1340] = "+6 Fire Resistance",
	[1341] = "+7 Fire Resistance",
	[1342] = "+8 Fire Resistance",
	[1343] = "+9 Fire Resistance",
	[1344] = "+10 Fire Resistance",
	[1345] = "+11 Fire Resistance",
	[1346] = "+12 Fire Resistance",
	[1347] = "+13 Fire Resistance",
	[1348] = "+14 Fire Resistance",
	[1349] = "+15 Fire Resistance",
	[1350] = "+16 Fire Resistance",
	[1351] = "+17 Fire Resistance",
	[1352] = "+18 Fire Resistance",
	[1353] = "+19 Fire Resistance",
	[1354] = "+20 Fire Resistance",
	[1355] = "+21 Fire Resistance",
	[1356] = "+22 Fire Resistance",
	[1357] = "+23 Fire Resistance",
	[1358] = "+24 Fire Resistance",
	[1359] = "+25 Fire Resistance",
	[1360] = "+26 Fire Resistance",
	[1361] = "+27 Fire Resistance",
	[1362] = "+28 Fire Resistance",
	[1363] = "+29 Fire Resistance",
	[1364] = "+30 Fire Resistance",
	[1365] = "+31 Fire Resistance",
	[1366] = "+32 Fire Resistance",
	[1367] = "+33 Fire Resistance",
	[1368] = "+34 Fire Resistance",
	[1369] = "+35 Fire Resistance",
	[1370] = "+36 Fire Resistance",
	[1371] = "+37 Fire Resistance",
	[1372] = "+38 Fire Resistance",
	[1373] = "+39 Fire Resistance",
	[1374] = "+40 Fire Resistance",
	[1375] = "+41 Fire Resistance",
	[1376] = "+42 Fire Resistance",
	[1377] = "+43 Fire Resistance",
	[1378] = "+44 Fire Resistance",
	[1379] = "+45 Fire Resistance",
	[1380] = "+46 Fire Resistance",
	[1381] = "+1 Nature Resistance",
	[1382] = "+2 Nature Resistance",
	[1383] = "+3 Nature Resistance",
	[1384] = "+4 Nature Resistance",
	[1385] = "+5 Nature Resistance",
	[1386] = "+6 Nature Resistance",
	[1387] = "+7 Nature Resistance",
	[1388] = "+8 Nature Resistance",
	[1389] = "+9 Nature Resistance",
	[1390] = "+10 Nature Resistance",
	[1391] = "+11 Nature Resistance",
	[1392] = "+12 Nature Resistance",
	[1393] = "+13 Nature Resistance",
	[1394] = "+14 Nature Resistance",
	[1395] = "+15 Nature Resistance",
	[1396] = "+16 Nature Resistance",
	[1397] = "+17 Nature Resistance",
	[1398] = "+18 Nature Resistance",
	[1399] = "+19 Nature Resistance",
	[1400] = "+20 Nature Resistance",
	[1401] = "+21 Nature Resistance",
	[1402] = "+22 Nature Resistance",
	[1403] = "+23 Nature Resistance",
	[1404] = "+24 Nature Resistance",
	[1405] = "+25 Nature Resistance",
	[1406] = "+26 Nature Resistance",
	[1407] = "+27 Nature Resistance",
	[1408] = "+28 Nature Resistance",
	[1409] = "+29 Nature Resistance",
	[1410] = "+30 Nature Resistance",
	[1411] = "+31 Nature Resistance",
	[1412] = "+32 Nature Resistance",
	[1413] = "+33 Nature Resistance",
	[1414] = "+34 Nature Resistance",
	[1415] = "+35 Nature Resistance",
	[1416] = "+36 Nature Resistance",
	[1417] = "+37 Nature Resistance",
	[1418] = "+38 Nature Resistance",
	[1419] = "+39 Nature Resistance",
	[1420] = "+40 Nature Resistance",
	[1421] = "+41 Nature Resistance",
	[1422] = "+42 Nature Resistance",
	[1423] = "+43 Nature Resistance",
	[1424] = "+44 Nature Resistance",
	[1425] = "+45 Nature Resistance",
	[1426] = "+46 Nature Resistance",
	[1427] = "+1 Shadow Resistance",
	[1428] = "+2 Shadow Resistance",
	[1429] = "+3 Shadow Resistance",
	[1430] = "+4 Shadow Resistance",
	[1431] = "+5 Shadow Resistance",
	[1432] = "+6 Shadow Resistance",
	[1433] = "+7 Shadow Resistance",
	[1434] = "+8 Shadow Resistance",
	[1435] = "+9 Shadow Resistance",
	[1436] = "+10 Shadow Resistance",
	[1437] = "+11 Shadow Resistance",
	[1438] = "+12 Shadow Resistance",
	[1439] = "+13 Shadow Resistance",
	[1440] = "+14 Shadow Resistance",
	[1441] = "+15 Shadow Resistance",
	[1442] = "+16 Shadow Resistance",
	[1443] = "+17 Shadow Resistance",
	[1444] = "+18 Shadow Resistance",
	[1445] = "+19 Shadow Resistance",
	[1446] = "+20 Shadow Resistance",
	[1447] = "+21 Shadow Resistance",
	[1448] = "+22 Shadow Resistance",
	[1449] = "+23 Shadow Resistance",
	[1450] = "+24 Shadow Resistance",
	[1451] = "+25 Shadow Resistance",
	[1452] = "+26 Resist Shadow",
	[1453] = "+27 Shadow Resistance",
	[1454] = "+28 Shadow Resistance",
	[1455] = "+29 Shadow Resistance",
	[1456] = "+30 Shadow Resistance",
	[1457] = "+31 Shadow Resistance",
	[1458] = "+32 Shadow Resistance",
	[1459] = "+33 Shadow Resistance",
	[1460] = "+34 Shadow Resistance",
	[1461] = "+35 Shadow Resistance",
	[1462] = "+36 Shadow Resistance",
	[1463] = "+37 Shadow Resistance",
	[1464] = "+38 Shadow Resistance",
	[1465] = "+39 Shadow Resistance",
	[1466] = "+40 Shadow Resistance",
	[1467] = "+41 Shadow Resistance",
	[1468] = "+42 Shadow Resistance",
	[1469] = "+43 Shadow Resistance",
	[1470] = "+44 Shadow Resistance",
	[1471] = "+45 Shadow Resistance",
	[1472] = "+46 Shadow Resistance",
	[1483] = "Mana +150",
	[1503] = "HP +100",
	[1504] = "Armor +125",
	[1505] = "+20 Fire Resistance",
	[1506] = "Strength +8",
	[1507] = "Stamina +8",
	[1508] = "Agility +8",
	[1509] = "Intellect +8",
	[1510] = "Spirit +8",
	[1523] = "MANA/FR +85/14",
	[1524] = "HP/FR +75/14",
	[1525] = "AC/FR +110/14",
	[1526] = "STR/FR +10/14",
	[1527] = "STA/FR +10/14",
	[1528] = "AGI/FR +10/14",
	[1529] = "INT/FR +10/14",
	[1530] = "SPI/FR +10/14",
	[1531] = "STR/STA +10/10",
	[1532] = "STR/STA/AC/FR +10/10/110/15",
	[1543] = "INT/SPI/MANA/FR +10/10/100/15",
	[1563] = "+2 Attack Power",
	[1583] = "+4 Attack Power",
	[1584] = "+6 Attack Power",
	[1585] = "+8 Attack Power",
	[1586] = "+10 Attack Power",
	[1587] = "+12 Attack Power",
	[1588] = "+14 Attack Power",
	[1589] = "+16 Attack Power",
	[1590] = "+18 Attack Power",
	[1591] = "+20 Attack Power",
	[1592] = "+22 Attack Power",
	[1593] = "+24 Attack Power",
	[1594] = "+26 Attack Power",
	[1595] = "+28 Attack Power",
	[1596] = "+30 Attack Power",
	[1597] = "+32 Attack Power",
	[1598] = "+34 Attack Power",
	[1599] = "+36 Attack Power",
	[1600] = "+38 Attack Power",
	[1601] = "+40 Attack Power",
	[1602] = "+42 Attack Power",
	[1603] = "+44 Attack Power",
	[1604] = "+46 Attack Power",
	[1605] = "+48 Attack Power",
	[1606] = "+50 Attack Power",
	[1607] = "+52 Attack Power",
	[1608] = "+54 Attack Power",
	[1609] = "+56 Attack Power",
	[1610] = "+58 Attack Power",
	[1611] = "+60 Attack Power",
	[1612] = "+62 Attack Power",
	[1613] = "+64 Attack Power",
	[1614] = "+66 Attack Power",
	[1615] = "+68 Attack Power",
	[1616] = "+70 Attack Power",
	[1617] = "+72 Attack Power",
	[1618] = "+74 Attack Power",
	[1619] = "+76 Attack Power",
	[1620] = "+78 Attack Power",
	[1621] = "+80 Attack Power",
	[1622] = "+82 Attack Power",
	[1623] = "+84 Attack Power",
	[1624] = "+86 Attack Power",
	[1625] = "+88 Attack Power",
	[1626] = "+90 Attack Power",
	[1627] = "+92 Attack Power",
	[1643] = "Sharpened +8",
	[1663] = "Rockbiter 5",
	[1664] = "Rockbiter 7",
	[1665] = "Flametongue 5",
	[1666] = "Flametongue 6",
	[1667] = "Frostbrand 4",
	[1668] = "Frostbrand 5",
	[1669] = "Windfury 4",
	[1683] = "Flametongue Totem 4",
	[1703] = "Weighted +8",
	[1704] = "Thorium Spike (20-30)",
	[1723] = "Omen of Clarity",
	[1743] = "MHTest02",
	[1763] = "Cold Blood",
	[1783] = "Windfury Totem 1",
	[1803] = "Firestone 1",
	[1823] = "Firestone 2",
	[1824] = "Firestone 3",
	[1825] = "Firestone 4",
	[1843] = "Reinforced Armor +40",
	[1863] = "Feedback 2",
	[1864] = "Feedback 3",
	[1865] = "Feedback 4",
	[1866] = "Feedback 5",
	[1883] = "Intellect +7",
	[1884] = "Spirit +9",
	[1885] = "Strength +9",
	[1886] = "Stamina +9",
	[1887] = "Agility +7",
	[1888] = "+5 All Resistances",
	[1889] = "Armor +70",
	[1890] = "Spirit +9",
	[1891] = "All Stats +4",
	[1892] = "Health +100",
	[1893] = "Mana +100",
	[1894] = "Icy Weapon",
	[1895] = "Damage +9",
	[1896] = "Weapon Damage +9",
	[1897] = "Weapon Damage +5",
	[1898] = "Lifestealing",
	[1899] = "Unholy Weapon",
	[1900] = "Crusader",
	[1901] = "Intellect +9",
	[1903] = "Spirit +9",
	[1904] = "Intellect +9",
	[1923] = "+3 Fire Resistance",
	[1943] = "+8 Defense",
	[1944] = "+5 Defense",
	[1945] = "+6 Defense",
	[1946] = "+7 Defense",
	[1947] = "+7 Defense",
	[1948] = "+9 Defense",
	[1949] = "+9 Defense",
	[1950] = "+10 Defense",
	[1951] = "+11 Defense",
	[1952] = "+13 Defense",
	[1953] = "+15 Defense",
	[1954] = "+17 Defense",
	[1955] = "+21 Defense",
	[1956] = "+11 Defense",
	[1957] = "+12 Defense",
	[1958] = "+13 Defense",
	[1959] = "+14 Defense",
	[1960] = "+15 Defense",
	[1961] = "+16 Defense",
	[1962] = "+17 Defense",
	[1963] = "+18 Defense",
	[1964] = "+19 Defense",
	[1965] = "+19 Defense",
	[1966] = "+20 Defense",
	[1967] = "+21 Defense",
	[1968] = "+22 Defense",
	[1969] = "+23 Defense",
	[1970] = "+23 Defense",
	[1971] = "+24 Defense",
	[1972] = "+25 Defense",
	[1973] = "+25 Defense",
	[1983] = "+1% Block",
	[1984] = "+2% Block",
	[1985] = "+3% Block",
	[1986] = "+4% Block",
	[1987] = "Block Level 14",
	[1988] = "Block Level 15",
	[1989] = "Block Level 16",
	[1990] = "Block Level 17",
	[1991] = "Block Level 18",
	[1992] = "Block Level 19",
	[1993] = "Block Level 20",
	[1994] = "Block Level 21",
	[1995] = "Block Level 22",
	[1996] = "Block Level 23",
	[1997] = "Block Level 24",
	[1998] = "Block Level 25",
	[1999] = "Block Level 26",
	[2000] = "Block Level 27",
	[2001] = "Block Level 28",
	[2002] = "Block Level 29",
	[2003] = "Block Level 30",
	[2004] = "Block Level 31",
	[2005] = "Block Level 32",
	[2006] = "Block Level 33",
	[2007] = "Block Level 34",
	[2008] = "Block Level 35",
	[2009] = "Block Level 36",
	[2010] = "Block Level 37",
	[2011] = "Block Level 38",
	[2012] = "Block Level 39",
	[2013] = "Block Level 40",
	[2014] = "Block Level 41",
	[2015] = "Block Level 42",
	[2016] = "Block Level 43",
	[2017] = "Block Level 44",
	[2018] = "Block Level 45",
	[2019] = "Block Level 46",
	[2020] = "Block Level 47",
	[2021] = "Block Level 48",
	[2022] = "Block Level 49",
	[2023] = "Block Level 50",
	[2024] = "Block Level 51",
	[2025] = "Block Level 52",
	[2026] = "Block Level 53",
	[2027] = "Block Level 54",
	[2028] = "Block Level 55",
	[2029] = "Block Level 56",
	[2030] = "Block Level 57",
	[2031] = "Block Level 58",
	[2032] = "Block Level 59",
	[2033] = "Block Level 60",
	[2034] = "Block Level 61",
	[2035] = "Block Level 62",
	[2036] = "Block Level 63",
	[2037] = "Block Level 64",
	[2038] = "Block Level 65",
	[2039] = "Block Level 66",
	[2040] = "+2 Ranged Attack Power",
	[2041] = "+5 Ranged Attack Power",
	[2042] = "+7 Ranged Attack Power",
	[2043] = "+10 Ranged Attack Power",
	[2044] = "+12 Ranged Attack Power",
	[2045] = "+14 Ranged Attack Power",
	[2046] = "+17 Ranged Attack Power",
	[2047] = "+19 Ranged Attack Power",
	[2048] = "+22 Ranged Attack Power",
	[2049] = "+24 Ranged Attack Power",
	[2050] = "+26 Ranged Attack Power",
	[2051] = "+29 Ranged Attack Power",
	[2052] = "+31 Ranged Attack Power",
	[2053] = "+34 Ranged Attack Power",
	[2054] = "+36 Ranged Attack Power",
	[2055] = "+38 Ranged Attack Power",
	[2056] = "+41 Ranged Attack Power",
	[2057] = "+43 Ranged Attack Power",
	[2058] = "+46 Ranged Attack Power",
	[2059] = "+48 Ranged Attack Power",
	[2060] = "+50 Ranged Attack Power",
	[2061] = "+53 Ranged Attack Power",
	[2062] = "+55 Ranged Attack Power",
	[2063] = "+58 Ranged Attack Power",
	[2064] = "+60 Ranged Attack Power",
	[2065] = "+62 Ranged Attack Power",
	[2066] = "+65 Ranged Attack Power",
	[2067] = "+67 Ranged Attack Power",
	[2068] = "+70 Ranged Attack Power",
	[2069] = "+72 Ranged Attack Power",
	[2070] = "+74 Ranged Attack Power",
	[2071] = "+77 Ranged Attack Power",
	[2072] = "+79 Ranged Attack Power",
	[2073] = "+82 Ranged Attack Power",
	[2074] = "+84 Ranged Attack Power",
	[2075] = "+86 Ranged Attack Power",
	[2076] = "+89 Ranged Attack Power",
	[2077] = "+91 Ranged Attack Power",
	[2078] = "+1% Dodge",
	[2079] = "+1 Arcane Spell Damage",
	[2080] = "+3 Arcane Spell Damage",
	[2081] = "+4 Arcane Spell Damage",
	[2082] = "+6 Arcane Spell Damage",
	[2083] = "+7 Arcane Spell Damage",
	[2084] = "+9 Arcane Spell Damage",
	[2085] = "+10 Arcane Spell Damage",
	[2086] = "+11 Arcane Spell Damage",
	[2087] = "+13 Arcane Spell Damage",
	[2088] = "+14 Arcane Spell Damage",
	[2089] = "+16 Arcane Spell Damage",
	[2090] = "+17 Arcane Spell Damage",
	[2091] = "+19 Arcane Spell Damage",
	[2092] = "+20 Arcane Spell Damage",
	[2093] = "+21 Arcane Spell Damage",
	[2094] = "+23 Arcane Spell Damage",
	[2095] = "+24 Arcane Spell Damage",
	[2096] = "+26 Arcane Spell Damage",
	[2097] = "+27 Arcane Spell Damage",
	[2098] = "+29 Arcane Spell Damage",
	[2099] = "+30 Arcane Spell Damage",
	[2100] = "+31 Arcane Spell Damage",
	[2101] = "+33 Arcane Spell Damage",
	[2102] = "+34 Arcane Spell Damage",
	[2103] = "+36 Arcane Spell Damage",
	[2104] = "+37 Arcane Spell Damage",
	[2105] = "+39 Arcane Spell Damage",
	[2106] = "+40 Arcane Spell Damage",
	[2107] = "+41 Arcane Spell Damage",
	[2108] = "+43 Arcane Spell Damage",
	[2109] = "+44 Arcane Spell Damage",
	[2110] = "+46 Arcane Spell Damage",
	[2111] = "+47 Arcane Spell Damage",
	[2112] = "+49 Arcane Spell Damage",
	[2113] = "+50 Arcane Spell Damage",
	[2114] = "+51 Arcane Spell Damage",
	[2115] = "+53 Arcane Spell Damage",
	[2116] = "+54 Arcane Spell Damage",
	[2117] = "+1 Shadow Spell Damage",
	[2118] = "+3 Shadow Spell Damage",
	[2119] = "+4 Shadow Spell Damage",
	[2120] = "+6 Shadow Spell Damage",
	[2121] = "+7 Shadow Spell Damage",
	[2122] = "+9 Shadow Spell Damage",
	[2123] = "+10 Shadow Spell Damage",
	[2124] = "+11 Shadow Spell Damage",
	[2125] = "+13 Shadow Spell Damage",
	[2126] = "+14 Shadow Spell Damage",
	[2127] = "+16 Shadow Spell Damage",
	[2128] = "+17 Shadow Spell Damage",
	[2129] = "+19 Shadow Spell Damage",
	[2130] = "+20 Shadow Spell Damage",
	[2131] = "+21 Shadow Spell Damage",
	[2132] = "+23 Shadow Spell Damage",
	[2133] = "+24 Shadow Spell Damage",
	[2134] = "+26 Shadow Spell Damage",
	[2135] = "+27 Shadow Spell Damage",
	[2136] = "+29 Shadow Spell Damage",
	[2137] = "+30 Shadow Spell Damage",
	[2138] = "+31 Shadow Spell Damage",
	[2139] = "+33 Shadow Spell Damage",
	[2140] = "+34 Shadow Spell Damage",
	[2141] = "+36 Shadow Spell Damage",
	[2142] = "+37 Shadow Spell Damage",
	[2143] = "+39 Shadow Spell Damage",
	[2144] = "+40 Shadow Spell Damage",
	[2145] = "+41 Shadow Spell Damage",
	[2146] = "+43 Shadow Spell Damage",
	[2147] = "+44 Shadow Spell Damage",
	[2148] = "+46 Shadow Spell Damage",
	[2149] = "+47 Shadow Spell Damage",
	[2150] = "+49 Shadow Spell Damage",
	[2151] = "+50 Shadow Spell Damage",
	[2152] = "+51 Shadow Spell Damage",
	[2153] = "+53 Shadow Spell Damage",
	[2154] = "+54 Shadow Spell Damage",
	[2155] = "+1 Fire Spell Damage",
	[2156] = "+3 Fire Spell Damage",
	[2157] = "+4 Fire Spell Damage",
	[2158] = "+6 Fire Spell Damage",
	[2159] = "+7 Fire Spell Damage",
	[2160] = "+9 Fire Spell Damage",
	[2161] = "+10 Fire Spell Damage",
	[2162] = "+11 Fire Spell Damage",
	[2163] = "+13 Fire Spell Damage",
	[2164] = "+14 Fire Spell Damage",
	[2165] = "+16 Fire Spell Damage",
	[2166] = "+17 Fire Spell Damage",
	[2167] = "+19 Fire Spell Damage",
	[2168] = "+20 Fire Spell Damage",
	[2169] = "+21 Fire Spell Damage",
	[2170] = "+23 Fire Spell Damage",
	[2171] = "+24 Fire Spell Damage",
	[2172] = "+26 Fire Spell Damage",
	[2173] = "+27 Fire Spell Damage",
	[2174] = "+29 Fire Spell Damage",
	[2175] = "+30 Fire Spell Damage",
	[2176] = "+31 Fire Spell Damage",
	[2177] = "+33 Fire Spell Damage",
	[2178] = "+34 Fire Spell Damage",
	[2179] = "+36 Fire Spell Damage",
	[2180] = "+37 Fire Spell Damage",
	[2181] = "+39 Fire Spell Damage",
	[2182] = "+40 Fire Spell Damage",
	[2183] = "+41 Fire Spell Damage",
	[2184] = "+43 Fire Spell Damage",
	[2185] = "+44 Fire Spell Damage",
	[2186] = "+46 Fire Spell Damage",
	[2187] = "+47 Fire Spell Damage",
	[2188] = "+49 Fire Spell Damage",
	[2189] = "+50 Fire Spell Damage",
	[2190] = "+51 Fire Spell Damage",
	[2191] = "+53 Fire Spell Damage",
	[2192] = "+54 Fire Spell Damage",
	[2193] = "+1 Holy Spell Damage",
	[2194] = "+3 Holy Spell Damage",
	[2195] = "+4 Holy Spell Damage",
	[2196] = "+6 Holy Spell Damage",
	[2197] = "+7 Holy Spell Damage",
	[2198] = "+9 Holy Spell Damage",
	[2199] = "+10 Holy Spell Damage",
	[2200] = "+11 Holy Spell Damage",
	[2201] = "+13 Holy Spell Damage",
	[2202] = "+14 Holy Spell Damage",
	[2203] = "+16 Holy Spell Damage",
	[2204] = "+17 Holy Spell Damage",
	[2205] = "+19 Holy Spell Damage",
	[2206] = "+20 Holy Spell Damage",
	[2207] = "+21 Holy Spell Damage",
	[2208] = "+23 Holy Spell Damage",
	[2209] = "+24 Holy Spell Damage",
	[2210] = "+26 Holy Spell Damage",
	[2211] = "+27 Holy Spell Damage",
	[2212] = "+29 Holy Spell Damage",
	[2213] = "+30 Holy Spell Damage",
	[2214] = "+31 Holy Spell Damage",
	[2215] = "+33 Holy Spell Damage",
	[2216] = "+34 Holy Spell Damage",
	[2217] = "+36 Holy Spell Damage",
	[2218] = "+37 Holy Spell Damage",
	[2219] = "+39 Holy Spell Damage",
	[2220] = "+40 Holy Spell Damage",
	[2221] = "+41 Holy Spell Damage",
	[2222] = "+43 Holy Spell Damage",
	[2223] = "+44 Holy Spell Damage",
	[2224] = "+46 Holy Spell Damage",
	[2225] = "+47 Holy Spell Damage",
	[2226] = "+49 Holy Spell Damage",
	[2227] = "+50 Holy Spell Damage",
	[2228] = "+51 Holy Spell Damage",
	[2229] = "+53 Holy Spell Damage",
	[2230] = "+54 Holy Spell Damage",
	[2231] = "+1 Frost Spell Damage",
	[2232] = "+3 Frost Spell Damage",
	[2233] = "+4 Frost Spell Damage",
	[2234] = "+6 Frost Spell Damage",
	[2235] = "+7 Frost Spell Damage",
	[2236] = "+9 Frost Spell Damage",
	[2237] = "+10 Frost Spell Damage",
	[2238] = "+11 Frost Spell Damage",
	[2239] = "+13 Frost Spell Damage",
	[2240] = "+14 Frost Spell Damage",
	[2241] = "+16 Frost Spell Damage",
	[2242] = "+17 Frost Spell Damage",
	[2243] = "+19 Frost Spell Damage",
	[2244] = "+20 Frost Spell Damage",
	[2245] = "+21 Frost Spell Damage",
	[2246] = "+23 Frost Spell Damage",
	[2247] = "+24 Frost Spell Damage",
	[2248] = "+26 Frost Spell Damage",
	[2249] = "+27 Frost Spell Damage",
	[2250] = "+29 Frost Spell Damage",
	[2251] = "+30 Frost Spell Damage",
	[2252] = "+31 Frost Spell Damage",
	[2253] = "+33 Frost Spell Damage",
	[2254] = "+34 Frost Spell Damage",
	[2255] = "+36 Frost Spell Damage",
	[2256] = "+37 Frost Spell Damage",
	[2257] = "+39 Frost Spell Damage",
	[2258] = "+40 Frost Spell Damage",
	[2259] = "+41 Frost Spell Damage",
	[2260] = "+43 Frost Spell Damage",
	[2261] = "+44 Frost Spell Damage",
	[2262] = "+46 Frost Spell Damage",
	[2263] = "+47 Frost Spell Damage",
	[2264] = "+49 Frost Spell Damage",
	[2265] = "+50 Frost Spell Damage",
	[2266] = "+51 Frost Spell Damage",
	[2267] = "+53 Frost Spell Damage",
	[2268] = "+54 Frost Spell Damage",
	[2269] = "+1 Nature Spell Damage",
	[2270] = "+3 Nature Spell Damage",
	[2271] = "+4 Nature Spell Damage",
	[2272] = "+6 Nature Spell Damage",
	[2273] = "+7 Nature Spell Damage",
	[2274] = "+9 Nature Spell Damage",
	[2275] = "+10 Nature Spell Damage",
	[2276] = "+11 Nature Spell Damage",
	[2277] = "+13 Nature Spell Damage",
	[2278] = "+14 Nature Spell Damage",
	[2279] = "+16 Nature Spell Damage",
	[2280] = "+17 Nature Spell Damage",
	[2281] = "+19 Nature Spell Damage",
	[2282] = "+20 Nature Spell Damage",
	[2283] = "+21 Nature Spell Damage",
	[2284] = "+23 Nature Spell Damage",
	[2285] = "+24 Nature Spell Damage",
	[2286] = "+26 Nature Spell Damage",
	[2287] = "+27 Nature Spell Damage",
	[2288] = "+29 Nature Spell Damage",
	[2289] = "+30 Nature Spell Damage",
	[2290] = "+31 Nature Spell Damage",
	[2291] = "+33 Nature Spell Damage",
	[2292] = "+34 Nature Spell Damage",
	[2293] = "+36 Nature Spell Damage",
	[2294] = "+37 Nature Spell Damage",
	[2295] = "+39 Nature Spell Damage",
	[2296] = "+40 Nature Spell Damage",
	[2297] = "+41 Nature Spell Damage",
	[2298] = "+43 Nature Spell Damage",
	[2299] = "+44 Nature Spell Damage",
	[2300] = "+46 Nature Spell Damage",
	[2301] = "+47 Nature Spell Damage",
	[2302] = "+49 Nature Spell Damage",
	[2303] = "+50 Nature Spell Damage",
	[2304] = "+51 Nature Spell Damage",
	[2305] = "+53 Nature Spell Damage",
	[2306] = "+54 Nature Spell Damage",
	[2307] = "+2 Healing Spells",
	[2308] = "+4 Healing Spells",
	[2309] = "+7 Healing Spells",
	[2310] = "+9 Healing Spells",
	[2311] = "+11 Healing Spells",
	[2312] = "+13 Healing Spells",
	[2313] = "+15 Healing Spells",
	[2314] = "+18 Healing Spells",
	[2315] = "+20 Healing Spells",
	[2316] = "+22 Healing Spells",
	[2317] = "+24 Healing Spells",
	[2318] = "+26 Healing Spells",
	[2319] = "+29 Healing Spells",
	[2320] = "+31 Healing Spells",
	[2321] = "+33 Healing Spells",
	[2322] = "+35 Healing Spells",
	[2323] = "+37 Healing Spells",
	[2324] = "+40 Healing Spells",
	[2325] = "+42 Healing Spells",
	[2326] = "+44 Healing Spells",
	[2327] = "+46 Healing Spells",
	[2328] = "+48 Healing Spells",
	[2329] = "+51 Healing Spells",
	[2330] = "+53 Healing Spells",
	[2331] = "+55 Healing Spells",
	[2332] = "+57 Healing Spells",
	[2333] = "+59 Healing Spells",
	[2334] = "+62 Healing Spells",
	[2335] = "+64 Healing Spells",
	[2336] = "+66 Healing Spells",
	[2337] = "+68 Healing Spells",
	[2338] = "+70 Healing Spells",
	[2339] = "+73 Healing Spells",
	[2340] = "+75 Healing Spells",
	[2341] = "+77 Healing Spells",
	[2342] = "+79 Healing Spells",
	[2343] = "+81 Healing Spells",
	[2344] = "+84 Healing Spells",
	[2363] = "+1 mana every 5 sec.",
	[2364] = "+1 mana every 5 sec.",
	[2365] = "+1 mana every 5 sec.",
	[2366] = "+2 mana every 5 sec.",
	[2367] = "+2 mana every 5 sec.",
	[2368] = "+2 mana every 5 sec.",
	[2369] = "+3 mana every 5 sec.",
	[2370] = "+3 mana every 5 sec.",
	[2371] = "+4 mana every 5 sec.",
	[2372] = "+4 mana every 5 sec.",
	[2373] = "+4 mana every 5 sec.",
	[2374] = "+5 mana every 5 sec.",
	[2375] = "+5 mana every 5 sec.",
	[2376] = "+6 mana every 5 sec.",
	[2377] = "+6 mana every 5 sec.",
	[2378] = "+6 mana every 5 sec.",
	[2379] = "+7 mana every 5 sec.",
	[2380] = "+7 mana every 5 sec.",
	[2381] = "+8 mana every 5 sec.",
	[2382] = "+8 mana every 5 sec.",
	[2383] = "+8 mana every 5 sec.",
	[2384] = "+9 mana every 5 sec.",
	[2385] = "+9 mana every 5 sec.",
	[2386] = "+10 mana every 5 sec.",
	[2387] = "+10 mana every 5 sec.",
	[2388] = "+10 mana every 5 sec.",
	[2389] = "+11 mana every 5 sec.",
	[2390] = "+11 mana every 5 sec.",
	[2391] = "+12 mana every 5 sec.",
	[2392] = "+12 mana every 5 sec.",
	[2393] = "+12 mana every 5 sec.",
	[2394] = "+13 mana every 5 sec.",
	[2395] = "+13 mana every 5 sec.",
	[2396] = "+14 mana every 5 sec.",
	[2397] = "+14 mana every 5 sec.",
	[2398] = "+14 mana every 5 sec.",
	[2399] = "+15 mana every 5 sec.",
	[2400] = "+15 mana every 5 sec.",
	[2401] = "+1 health every 5 sec.",
	[2402] = "+1 health every 5 sec.",
	[2403] = "+1 health every 5 sec.",
	[2404] = "+1 health every 5 sec.",
	[2405] = "+1 health every 5 sec.",
	[2406] = "+2 health every 5 sec.",
	[2407] = "+2 health every 5 sec.",
	[2408] = "+2 health every 5 sec.",
	[2409] = "+2 health every 5 sec.",
	[2410] = "+3 health every 5 sec.",
	[2411] = "+3 health every 5 sec.",
	[2412] = "+3 health every 5 sec.",
	[2413] = "+3 health every 5 sec.",
	[2414] = "+4 health every 5 sec.",
	[2415] = "+4 health every 5 sec.",
	[2416] = "+4 health every 5 sec.",
	[2417] = "+4 health every 5 sec.",
	[2418] = "+5 health every 5 sec.",
	[2419] = "+5 health every 5 sec.",
	[2420] = "+5 health every 5 sec.",
	[2421] = "+5 health every 5 sec.",
	[2422] = "+6 health every 5 sec.",
	[2423] = "+6 health every 5 sec.",
	[2424] = "+6 health every 5 sec.",
	[2425] = "+6 health every 5 sec.",
	[2426] = "+7 health every 5 sec.",
	[2427] = "+7 health every 5 sec.",
	[2428] = "+7 health every 5 sec.",
	[2429] = "+7 health every 5 sec.",
	[2430] = "+8 health every 5 sec.",
	[2431] = "+8 health every 5 sec.",
	[2432] = "+8 health every 5 sec.",
	[2433] = "+8 health every 5 sec.",
	[2434] = "+9 health every 5 sec.",
	[2435] = "+9 health every 5 sec.",
	[2436] = "+9 health every 5 sec.",
	[2437] = "+9 health every 5 sec.",
	[2438] = "+10 health every 5 sec.",
	[2443] = "Frost Spell Damage +7",
	[2463] = "+7 Fire Resistance",
	[2483] = "+5 Fire Resistance",
	[2484] = "+5 Frost Resistance",
	[2485] = "+5 Arcane Resistance",
	[2486] = "+5 Nature Resistance",
	[2487] = "+5 Shadow Resistance",
	[2488] = "+5 All Resistances",
	[2503] = "Defense +3",
	[2504] = "Spell Damage +30",
	[2505] = "Healing Spells +55",
	[2506] = "Critical +2%",
	[2523] = "+3% Hit",
	[2543] = "Attack Speed +1%",
	[2544] = "Healing and Spell Damage +8",
	[2545] = "Dodge +1%",
	[2563] = "Strength +15",
	[2564] = "Agility +15",
	[2565] = "Mana Regen 4 per 5 sec.",
	[2566] = "Healing Spells +24",
	[2567] = "Spirit +20",
	[2568] = "Intellect +22",
	[2583] = "Defense +7/Stamina +10/Block Value +15",
	[2584] = "Defense +7/Stamina +10/Healing Spells +24",
	[2585] = "Attack Power +28/Dodge +1%",
	[2586] = "Ranged Attack Power +24/Stamina +10/Hit +1%",
	[2587] = "Healing and Spell Damage +13/Intellect +15",
	[2588] = "Healing and Spell Damage +18/Spell Hit +1%",
	[2589] = "Healing and Spell Damage +18/Stamina +10",
	[2590] = "Mana Regen +4/Stamina +10/Healing Spells +24",
	[2591] = "Intellect +10/Stamina +10/Healing Spells +24",
	[2603] = "Eternium Line",
	[2604] = "+33 Healing Spells",
	[2605] = "+18 Spell Damage and Healing",
	[2606] = "+30 Attack Power",
	[2607] = "+12 Damage and Healing Spells",
	[2608] = "+13 Damage and Healing Spells",
	[2609] = "+15 Damage and Healing Spells",
	[2610] = "+14 Damage and Healing Spells",
	[2611] = "REUSE Random - 15 Spells All",
	[2612] = "+18 Damage and Healing Spells",
	[2613] = "Threat +2%",
	[2614] = "Shadow Damage +20",
	[2615] = "Frost Damage +20",
	[2616] = "Fire Damage +20",
	[2617] = "Healing Spells +30",
	[2618] = "Agility +15",
	[2619] = "+15 Fire Resistance",
	[2620] = "+15 Nature Resistance",
	[2621] = "Subtlety",
	[2622] = "Dodge +1%",
	[2623] = "Minor Wizard Oil",
	[2624] = "Minor Mana Oil",
	[2625] = "Lesser Mana Oil",
	[2626] = "Lesser Wizard Oil",
	[2627] = "Wizard Oil",
	[2628] = "Brilliant Wizard Oil",
	[2629] = "Brilliant Mana Oil",
	[2630] = "Deadly Poison V",
	[2646] = "Agility +25",
	[2681] = "+10 Nature Resistance",
	[2682] = "+10 Frost Resistance",
	[2683] = "+10 Shadow Resistance",
	[2684] = "+100 Attack Power vs Undead",
	[2685] = "+60 Spell Damage vs Undead",
	[2715] = "Healing +31 and 5 mana per 5 sec.",
	[2716] = "Stamina +16 and Armor +100",
	[2717] = "Attack Power +26 and +1% Critical Strike",
	[2721] = "Spell Damage +15 and +1% Spell Critical Strike",
	[2802] = "+$i Agility",
	[2803] = "+$i Stamina",
	[2804] = "+$i Intellect",
	[2805] = "+$i Strength",
	[2806] = "+$i Spirit",
	[2815] = "+$i Dodge",
	[2817] = "+$i Arcane Resistance",
	[2818] = "+$i Fire Resistance",
	[2819] = "+$i Frost Resistance",
	[2820] = "+$i Nature Resistance",
	[2821] = "+$i Shadow Resistance",
	[2823] = "+$i Critical Strike",
	[2825] = "+$i Attack Power",
	[2826] = "+$i Block",
	[3726] = "+$i Haste",		
}

local DCS_ABBREV_ENCHANT_IDS = {
	[1] = "石化3",
	[2] = "冰封1",
	[3] = "火舌3",
	[4] = "火舌2",
	[5] = "火舌1",
	[6] = "石化2",
	[7] = "致命药膏I",
	[8] = "致命药膏II",
	[9] = "毒药(15Dmg)",
	[10] = "毒药(20Dmg)",
	[11] = "毒药(25Dmg)",
	[12] = "冰封2",
	[13] = "锋利+3",
	[14] = "锋利+4",
	[15] = "强化护甲+8",
	[16] = "强化护甲+16",
	[17] = "强化护甲+24",
	[18] = "强化护甲+32",
	[19] = "稳固+2",
	[20] = "稳固+3",
	[21] = "稳固+4",
	[22] = "减速药膏I",
	[23] = "麻痹药膏II",
	[24] = "法力值+5",
	[25] = "暗影之油",
	[26] = "冰霜之油",
	[27] = "碎裂",
	[28] = "所有抗性+4",
	[29] = "石化 1",
	[30] = "瞄准镜(+1伤害)",
	[31] = "野兽增伤+4",
	[32] = "瞄准镜(+2伤害)",
	[33] = "瞄准镜(+3伤害)",
	[34] = "平衡石 +3%攻速",
	[35] = "麻痹药膏I",
	[36] = "炽热魔符",
	[37] = "武器链-防缴械",
	[38] = "防御等级+3",
	[39] = "锋利+1",
	[40] = "锋利+2",
	[41] = "生命值+5",
	[42] = "毒药(速效20)",
	[43] = "铁盾刺(8-12)",
	[44] = "吸收(10)",
	[63] = "吸收(25)",
	[64] = "精神+3",
	[65] = "所有抗性+1",
	[66] = "耐力+1",
	[67] = "+1伤害",
	[68] = "+1力量",
	[69] = "+2力量",
	[70] = "+3力量",
	[71] = "+1耐力",
	[72] = "+2耐力",
	[73] = "+3耐力",
	[74] = "+1敏捷",
	[75] = "+2敏捷",
	[76] = "+3敏捷",
	[77] = "+2伤害",
	[78] = "+3伤害",
	[79] = "+1智力",
	[80] = "+2智力",
	[81] = "+3智力",
	[82] = "+1精神",
	[83] = "+2精神",
	[84] = "+3精神",
	[85] = "+3护甲",
	[86] = "+8护甲",
	[87] = "+12护甲",
	[89] = "+16护甲",
	[90] = "+4敏捷",
	[91] = "+5敏捷",
	[92] = "+6敏捷",
	[93] = "+7敏捷",
	[94] = "+4智力",
	[95] = "+5智力",
	[96] = "+6智力",
	[97] = "+7智力",
	[98] = "+4精神",
	[99] = "+5精神",
	[100] = "+6精神",
	[101] = "+7精神",
	[102] = "+4耐力",
	[103] = "+5耐力",
	[104] = "+6耐力",
	[105] = "+7耐力",
	[106] = "+4力量",
	[107] = "+5力量",
	[108] = "+6力量",
	[109] = "+7力量",
	[110] = "+1防御",
	[111] = "+1防御",
	[112] = "+2防御",
	[113] = "+3防御",
	[114] = "+3防御",
	[115] = "+4防御",
	[116] = "+5防御",
	[117] = "+4伤害",
	[118] = "+5伤害",
	[119] = "+6伤害",
	[120] = "+7伤害",
	[121] = "+20护甲",
	[122] = "+24护甲",
	[123] = "+28护甲",
	[124] = "火舌图腾I",
	[125] = "单手剑技能+1",
	[126] = "单手剑技能+2",
	[127] = "单手剑技能+3",
	[128] = "单手剑技能+4",
	[129] = "单手剑技能+5",
	[130] = "单手剑技能+6",
	[131] = "单手剑技能+7",
	[132] = "双手剑技能+1",
	[133] = "双手剑技能+2",
	[134] = "双手剑技能+3",
	[135] = "双手剑技能+4",
	[136] = "双手剑技能+5",
	[137] = "双手剑技能+6",
	[138] = "双手剑技能+7",
	[139] = "单手锤技能+1",
	[140] = "单手锤技能+2",
	[141] = "单手锤技能+3",
	[142] = "单手锤技能+4",
	[143] = "单手锤技能+5",
	[144] = "单手锤技能+6",
	[145] = "单手锤技能+7",
	[146] = "双手锤技能+1",
	[147] = "双手锤技能+2",
	[148] = "双手锤技能+3",
	[149] = "双手锤技能+4",
	[150] = "双手锤技能+5",
	[151] = "双手锤技能+6",
	[152] = "双手锤技能+7",
	[153] = "斧技能+1",
	[154] = "斧技能+2",
	[155] = "斧技能+3",
	[156] = "斧技能+4",
	[157] = "斧技能+5",
	[158] = "斧技能+6",
	[159] = "斧技能+7",
	[160] = "双手斧技能+1",
	[161] = "双手斧技能+2",
	[162] = "双手斧技能+3",
	[163] = "双手斧技能+4",
	[164] = "双手斧技能+5",
	[165] = "双手斧技能+6",
	[166] = "双手斧技能+7",
	[167] = "匕首技能+1",
	[168] = "匕首技能+2",
	[169] = "匕首技能+3",
	[170] = "匕首技能+4",
	[171] = "匕首技能+5",
	[172] = "匕首技能+6",
	[173] = "匕首技能+7",
	[174] = "枪械技能+1",
	[175] = "枪械技能+2",
	[176] = "枪械技能+3",
	[177] = "枪械技能+4",
	[178] = "枪械技能+5",
	[179] = "枪械技能+6",
	[180] = "枪械技能+7",
	[181] = "弓技能+1",
	[182] = "弓技能+2",
	[183] = "弓技能+3",
	[184] = "弓技能+4",
	[185] = "弓技能+5",
	[186] = "弓技能+6",
	[187] = "弓技能+7",
	[188] = "+2野兽增伤",
	[189] = "+4野兽增伤",
	[190] = "+6野兽增伤",
	[191] = "+8野兽增伤",
	[192] = "+10野兽增伤",
	[193] = "+12野兽增伤",
	[194] = "+14野兽增伤",
	[195] = "爆击率+1%",
	[196] = "爆击率+2%",
	[197] = "爆击率+3%",
	[198] = "爆击率+4%",
	[199] = "10%被击中反弹: 暗影箭(10伤害)",
	[200] = "10%被击中反弹: 暗影箭(20伤害)",
	[201] = "10%被击中反弹: 暗影箭(30伤害)",
	[202] = "10%被击中反弹: 暗影箭(40伤害)",
	[203] = "10%被击中反弹: 暗影箭(50伤害)",
	[204] = "10%被击中反弹: 暗影箭(60伤害)",
	[205] = "10%被击中反弹: 暗影箭(70伤害)",
	[206] = "治疗法术+2",
	[207] = "治疗法术+4",
	[208] = "治疗法术+7",
	[209] = "治疗法术+9",
	[210] = "治疗法术+11",
	[211] = "治疗法术+13",
	[212] = "治疗法术+15",
	[213] = "增加火焰效果+1",
	[214] = "增加火焰效果+3",
	[215] = "增加火焰效果+4",
	[216] = "增加火焰效果+6",
	[217] = "增加火焰效果+7",
	[218] = "增加火焰伤害+9",
	[219] = "增加火焰伤害+10",
	[220] = "增加自然效果+1",
	[221] = "增加自然效果+3",
	[222] = "增加自然效果+4",
	[223] = "增加自然效果+6",
	[224] = "增加自然效果+7",
	[225] = "增加自然效果+9",
	[226] = "增加自然效果+10",
	[227] = "增加冰霜效果+1",
	[228] = "增加冰霜效果+3",
	[229] = "增加冰霜效果+4",
	[230] = "增加冰霜效果+6",
	[231] = "增加冰霜效果+7",
	[232] = "增加冰霜效果+9",
	[233] = "增加冰霜效果+10",
	[234] = "增加暗影效果+1",
	[235] = "增加暗影效果+3",
	[236] = "增加暗影效果+4",
	[237] = "增加暗影效果+6",
	[238] = "增加暗影效果+7",
	[239] = "增加暗影效果+9",
	[240] = "增加暗影效果+10",
	[241] = "武器伤害+2",
	[242] = "生命值+15",
	[243] = "精神+1",
	[244] = "智力+4",
	[245] = "护甲+5",
	[246] = "法力值+20",
	[247] = "敏捷+1",
	[248] = "力量+1",
	[249] = "野兽增伤+2",
	[250] = "武器伤害+1 ",
	[251] = "智力+1",
	[252] = "精神+6",
	[253] = "吸收(50)",
	[254] = "生命值+25",
	[255] = "精神+3",
	[256] = "+5火焰抗性",
	[257] = "护甲+10",
	[263] = "强化钓鱼+25",
	[264] = "强化钓鱼+50",
	[265] = "强化钓鱼+75",
	[266] = "强化钓鱼+100",
	[283] = "风怒1",
	[284] = "风怒2",
	[285] = "火舌图腾II",
	[286] = "+2武器火焰伤害",
	[287] = "+4武器火焰伤害",
	[288] = "+6武器火焰伤害",
	[289] = "+8武器火焰伤害",
	[290] = "+10武器火焰伤害",
	[291] = "+12武器火焰伤害",
	[292] = "+14武器火焰伤害",
	[303] = "火焰法珠",
	[323] = "速效药膏",
	[324] = "速效药膏 II",
	[325] = "速效药膏 III",
	[343] = "+8敏捷",
	[344] = "+32护甲",
	[345] = "+40护甲",
	[346] = "+36护甲",
	[347] = "+44护甲",
	[348] = "+48护甲",
	[349] = "+9敏捷",
	[350] = "+8智力",
	[351] = "+8精神",
	[352] = "+8力量",
	[353] = "+8耐力",
	[354] = "+9智力",
	[355] = "+9精神",
	[356] = "+9耐力",
	[357] = "+9力量",
	[358] = "+10敏捷",
	[359] = "+10智力",
	[360] = "+10精神",
	[361] = "+10耐力",
	[362] = "+10力量",
	[363] = "+11敏捷",
	[364] = "+11智力",
	[365] = "+11精神",
	[366] = "+11耐力",
	[367] = "+11力量",
	[368] = "+12敏捷",
	[369] = "+12智力",
	[370] = "+12精神",
	[371] = "+12耐力",
	[372] = "+12力量",
	[383] = "+52护甲",
	[384] = "+56护甲",
	[385] = "+60护甲",
	[386] = "+16护甲",
	[387] = "+17护甲",
	[388] = "+18护甲",
	[389] = "+19护甲",
	[403] = "+13敏捷",
	[404] = "+14敏捷",
	[405] = "+13智力",
	[406] = "+14智力",
	[407] = "+13精神",
	[408] = "+14精神",
	[409] = "+13耐力",
	[410] = "+13力量",
	[411] = "+14耐力",
	[412] = "+14力量",
	[423] = "增加法术伤害+1",
	[424] = "增加法术伤害+2",
	[425] = "增加法术伤害+4",
	[426] = "增加法术伤害+5",
	[427] = "增加法术伤害+6",
	[428] = "增加法术伤害+7",
	[429] = "增加法术伤害+8",
	[430] = "增加法术伤害+9",
	[431] = "增加法术伤害+11",
	[432] = "增加法术伤害+12",
	[433] = "增加火焰伤害+11",
	[434] = "增加火焰伤害+13",
	[435] = "增加火焰伤害+14",
	[436] = "爆击率+5%",
	[437] = "增加冰霜效果+11",
	[438] = "增加冰霜效果+13",
	[439] = "增加冰霜效果+14",
	[440] = "治疗法术+12",
	[441] = "治疗法术+20",
	[442] = "治疗法术+22",
	[443] = "增加自然效果+11",
	[444] = "增加自然效果+13",
	[445] = "增加自然效果+14",
	[446] = "增加暗影效果+11",
	[447] = "增加暗影效果+13",
	[448] = "增加暗影效果+14",
	[463] = "秘银盾刺(16-20)",
	[464] = "秘银马刺（骑速+3%）",
	[483] = "锋利+6",
	[484] = "稳固+6",
	[503] = "石化4",
	[504] = "石化+80",
	[523] = "火舌4",
	[524] = "冰封3",
	[525] = "风怒3",
	[543] = "火舌图腾III",
	[563] = "风怒图腾II",
	[564] = "风怒图腾III",
	[583] = "+1敏捷/+1精神",
	[584] = "+1敏捷/+1智力",
	[585] = "+1敏捷/+1耐力",
	[586] = "+1敏捷/+1力量",
	[587] = "+1智力/+1精神",
	[588] = "+1智力/+1耐力",
	[589] = "+1智力/+1力量",
	[590] = "+1精神/+1耐力",
	[591] = "+1精神/+1力量",
	[592] = "+1耐力/+1力量",
	[603] = "致残毒药II",
	[623] = "速效药膏IV",
	[624] = "速效药膏V",
	[625] = "速效药膏VI",
	[626] = "致命药膏III",
	[627] = "致命药膏IV",
	[643] = "麻痹药膏III",
	[663] = "瞄准镜(+5伤害)",
	[664] = "瞄准镜(+7伤害)",
	[683] = "石化6",
	[684] = "+15力量",
	[703] = "致伤药膏I",
	[704] = "致伤药膏II",
	[705] = "致伤药膏III",
	[706] = "致伤药膏IV",
	[723] = "智力+3",
	[724] = "耐力+3",
	[743] = "潜行+2",
	[744] = "护甲+20",
	[763] = "格挡值+1%",
	[783] = "护甲+10",
	[803] = "烈焰",
	[804] = "+10暗影抗性",
	[805] = "武器伤害+4",
	[823] = "力量+3",
	[843] = "法力值+30",
	[844] = "采矿+2",
	[845] = "草药学+2",
	[846] = "钓鱼+2",
	[847] = "所有属性+1",
	[848] = "护甲+30",
	[849] = "敏捷+3",
	[850] = "生命值+35",
	[851] = "精神+5",
	[852] = "耐力+5",
	[853] = "野兽增伤+6",
	[854] = "元素生物增伤+6",
	[855] = "+5火焰抗性",
	[856] = "力量+5",
	[857] = "法力值+50",
	[863] = "格挡值+2%",
	[864] = "武器伤害+4",
	[865] = "剥皮+5",
	[866] = "所有属性+2",
	[883] = "+15敏捷",
	[884] = "护甲+50",
	[903] = "所有抗性+3",
	[904] = "敏捷+5",
	[905] = "智力+5",
	[906] = "采矿+5",
	[907] = "精神+7",
	[908] = "生命值+50",
	[909] = "草药学+5",
	[910] = "强化潜行",
	[911] = "移动速度略微提升（8%）",
	[912] = "屠魔",
	[913] = "法力值+65",
	[923] = "防御等级 +3",
	[924] = "防御等级 +1",
	[925] = "防御等级 +2",
	[926] = "+8冰霜抗性",
	[927] = "力量+7",
	[928] = "所有属性+3",
	[929] = "耐力+7",
	[930] = "坐骑移动速度略微提升（3%）",
	[931] = "攻速+1%",
	[943] = "武器伤害+3",
	[963] = "武器伤害+7",
	[983] = "+16敏捷",
	[1003] = "毒皮毒药",
	[1023] = "反馈1",
	[1043] = "+16力量",
	[1044] = "+17力量",
	[1045] = "+18力量",
	[1046] = "+19力量",
	[1047] = "+20力量",
	[1048] = "+21力量",
	[1049] = "+22力量",
	[1050] = "+23力量",
	[1051] = "+24力量",
	[1052] = "+25力量",
	[1053] = "+26力量",
	[1054] = "+27力量",
	[1055] = "+28力量",
	[1056] = "+29力量",
	[1057] = "+30力量",
	[1058] = "+31力量",
	[1059] = "+32力量",
	[1060] = "+33力量",
	[1061] = "+34力量",
	[1062] = "+35力量",
	[1063] = "+36力量",
	[1064] = "+37力量",
	[1065] = "+38力量",
	[1066] = "+39力量",
	[1067] = "+40力量",
	[1068] = "+15耐力",
	[1069] = "+16耐力",
	[1070] = "+17耐力",
	[1071] = "+18耐力",
	[1072] = "+19耐力",
	[1073] = "+20耐力",
	[1074] = "+21耐力",
	[1075] = "+22耐力",
	[1076] = "+23耐力",
	[1077] = "+24耐力",
	[1078] = "+25耐力",
	[1079] = "+26耐力",
	[1080] = "+27耐力",
	[1081] = "+28耐力",
	[1082] = "+29耐力",
	[1083] = "+30耐力",
	[1084] = "+31耐力",
	[1085] = "+32耐力",
	[1086] = "+33耐力",
	[1087] = "+34耐力",
	[1088] = "+35耐力",
	[1089] = "+36耐力",
	[1090] = "+37耐力",
	[1091] = "+38耐力",
	[1092] = "+39耐力",
	[1093] = "+40耐力",
	[1094] = "+17敏捷",
	[1095] = "+18敏捷",
	[1096] = "+19敏捷",
	[1097] = "+20敏捷",
	[1098] = "+21敏捷",
	[1099] = "+22敏捷",
	[1100] = "+23敏捷",
	[1101] = "+24敏捷",
	[1102] = "+25敏捷",
	[1103] = "+26敏捷",
	[1104] = "+27敏捷",
	[1105] = "+28敏捷",
	[1106] = "+29敏捷",
	[1107] = "+30敏捷",
	[1108] = "+31敏捷",
	[1109] = "+32敏捷",
	[1110] = "+33敏捷",
	[1111] = "+34敏捷",
	[1112] = "+35敏捷",
	[1113] = "+36敏捷",
	[1114] = "+37敏捷",
	[1115] = "+38敏捷",
	[1116] = "+39敏捷",
	[1117] = "+40敏捷",
	[1118] = "+15智力",
	[1119] = "+16智力",
	[1120] = "+17智力",
	[1121] = "+18智力",
	[1122] = "+19智力",
	[1123] = "+20智力",
	[1124] = "+21智力",
	[1125] = "+22智力",
	[1126] = "+23智力",
	[1127] = "+24智力",
	[1128] = "+25智力",
	[1129] = "+26智力",
	[1130] = "+27智力",
	[1131] = "+28智力",
	[1132] = "+29智力",
	[1133] = "+30智力",
	[1134] = "+31智力",
	[1135] = "+32智力",
	[1136] = "+33智力",
	[1137] = "+34智力",
	[1138] = "+35智力",
	[1139] = "+36智力",
	[1140] = "+37智力",
	[1141] = "+38智力",
	[1142] = "+39智力",
	[1143] = "+40智力",
	[1144] = "+15精神",
	[1145] = "+16精神",
	[1146] = "+17精神",
	[1147] = "+18精神",
	[1148] = "+19精神",
	[1149] = "+20精神",
	[1150] = "+21精神",
	[1151] = "+22精神",
	[1152] = "+23精神",
	[1153] = "+24精神",
	[1154] = "+25精神",
	[1155] = "+26精神",
	[1156] = "+27精神",
	[1157] = "+28精神",
	[1158] = "+29精神",
	[1159] = "+30精神",
	[1160] = "+31精神",
	[1161] = "+32精神",
	[1162] = "+33精神",
	[1163] = "+34精神",
	[1164] = "+36精神",
	[1165] = "+37精神",
	[1166] = "+38精神",
	[1167] = "+39精神",
	[1168] = "+40精神",
	[1183] = "+35精神",
	[1203] = "+41力量",
	[1204] = "+42力量",
	[1205] = "+43力量",
	[1206] = "+44力量",
	[1207] = "+45力量",
	[1208] = "+46力量",
	[1209] = "+41耐力",
	[1210] = "+42耐力",
	[1211] = "+43耐力",
	[1212] = "+44耐力",
	[1213] = "+45耐力",
	[1214] = "+46耐力",
	[1215] = "+41敏捷",
	[1216] = "+42敏捷",
	[1217] = "+43敏捷",
	[1218] = "+44敏捷",
	[1219] = "+45敏捷",
	[1220] = "+46敏捷",
	[1221] = "+41智力",
	[1222] = "+42智力",
	[1223] = "+43智力",
	[1224] = "+44智力",
	[1225] = "+45智力",
	[1226] = "+46智力",
	[1227] = "+41精神",
	[1228] = "+42精神",
	[1229] = "+43精神",
	[1230] = "+44精神",
	[1231] = "+45精神",
	[1232] = "+46精神",
	[1243] = "+1奥术抗性",
	[1244] = "+2奥术抗性",
	[1245] = "+3奥术抗性",
	[1246] = "+4奥术抗性",
	[1247] = "+5奥术抗性",
	[1248] = "+6奥术抗性",
	[1249] = "+7奥术抗性",
	[1250] = "+8奥术抗性",
	[1251] = "+9奥术抗性",
	[1252] = "+10奥术抗性",
	[1253] = "+11奥术抗性",
	[1254] = "+12奥术抗性",
	[1255] = "+13奥术抗性",
	[1256] = "+14奥术抗性",
	[1257] = "+15奥术抗性",
	[1258] = "+16奥术抗性",
	[1259] = "+17奥术抗性",
	[1260] = "+18奥术抗性",
	[1261] = "+19奥术抗性",
	[1262] = "+20奥术抗性",
	[1263] = "+21奥术抗性",
	[1264] = "+22奥术抗性",
	[1265] = "+23奥术抗性",
	[1266] = "+24奥术抗性",
	[1267] = "+25奥术抗性",
	[1268] = "+26奥术抗性",
	[1269] = "+27奥术抗性",
	[1270] = "+28奥术抗性",
	[1271] = "+29奥术抗性",
	[1272] = "+30奥术抗性",
	[1273] = "+31奥术抗性",
	[1274] = "+32奥术抗性",
	[1275] = "+33奥术抗性",
	[1276] = "+34奥术抗性",
	[1277] = "+35奥术抗性",
	[1278] = "+36奥术抗性",
	[1279] = "+37奥术抗性",
	[1280] = "+38奥术抗性",
	[1281] = "+39奥术抗性",
	[1282] = "+40奥术抗性",
	[1283] = "+41奥术抗性",
	[1284] = "+42奥术抗性",
	[1285] = "+43奥术抗性",
	[1286] = "+44奥术抗性",
	[1287] = "+45奥术抗性",
	[1288] = "+46奥术抗性",
	[1289] = "+1冰霜抗性",
	[1290] = "+2冰霜抗性",
	[1291] = "+3冰霜抗性",
	[1292] = "+4冰霜抗性",
	[1293] = "+5冰霜抗性",
	[1294] = "+6冰霜抗性",
	[1295] = "+7冰霜抗性",
	[1296] = "+8冰霜抗性",
	[1297] = "+9冰霜抗性",
	[1298] = "+10冰霜抗性",
	[1299] = "+11冰霜抗性",
	[1300] = "+12冰霜抗性",
	[1301] = "+13冰霜抗性",
	[1302] = "+14冰霜抗性",
	[1303] = "+15冰霜抗性",
	[1304] = "+16冰霜抗性",
	[1305] = "+17冰霜抗性",
	[1306] = "+18冰霜抗性",
	[1307] = "+19冰霜抗性",
	[1308] = "+20冰霜抗性",
	[1309] = "+21冰霜抗性",
	[1310] = "+22冰霜抗性",
	[1311] = "+23冰霜抗性",
	[1312] = "+24冰霜抗性",
	[1313] = "+25冰霜抗性",
	[1314] = "+26冰霜抗性",
	[1315] = "+27冰霜抗性",
	[1316] = "+28冰霜抗性",
	[1317] = "+29冰霜抗性",
	[1318] = "+30冰霜抗性",
	[1319] = "+31冰霜抗性",
	[1320] = "+32冰霜抗性",
	[1321] = "+33冰霜抗性",
	[1322] = "+34冰霜抗性",
	[1323] = "+35冰霜抗性",
	[1324] = "+36冰霜抗性",
	[1325] = "+37冰霜抗性",
	[1326] = "+38冰霜抗性",
	[1327] = "+39冰霜抗性",
	[1328] = "+40冰霜抗性",
	[1329] = "+41冰霜抗性",
	[1330] = "+42冰霜抗性",
	[1331] = "+43冰霜抗性",
	[1332] = "+44冰霜抗性",
	[1333] = "+45冰霜抗性",
	[1334] = "+46冰霜抗性",
	[1335] = "+1火焰抗性",
	[1336] = "+2火焰抗性",
	[1337] = "+3火焰抗性",
	[1338] = "+4火焰抗性",
	[1339] = "+5火焰抗性",
	[1340] = "+6火焰抗性",
	[1341] = "+7火焰抗性",
	[1342] = "+8火焰抗性",
	[1343] = "+9火焰抗性",
	[1344] = "+10火焰抗性",
	[1345] = "+11火焰抗性",
	[1346] = "+12火焰抗性",
	[1347] = "+13火焰抗性",
	[1348] = "+14火焰抗性",
	[1349] = "+15火焰抗性",
	[1350] = "+16火焰抗性",
	[1351] = "+17火焰抗性",
	[1352] = "+18火焰抗性",
	[1353] = "+19火焰抗性",
	[1354] = "+20火焰抗性",
	[1355] = "+21火焰抗性",
	[1356] = "+22火焰抗性",
	[1357] = "+23火焰抗性",
	[1358] = "+24火焰抗性",
	[1359] = "+25火焰抗性",
	[1360] = "+26火焰抗性",
	[1361] = "+27火焰抗性",
	[1362] = "+28火焰抗性",
	[1363] = "+29火焰抗性",
	[1364] = "+30火焰抗性",
	[1365] = "+31火焰抗性",
	[1366] = "+32火焰抗性",
	[1367] = "+33火焰抗性",
	[1368] = "+34火焰抗性",
	[1369] = "+35火焰抗性",
	[1370] = "+36火焰抗性",
	[1371] = "+37火焰抗性",
	[1372] = "+38火焰抗性",
	[1373] = "+39火焰抗性",
	[1374] = "+40火焰抗性",
	[1375] = "+41火焰抗性",
	[1376] = "+42火焰抗性",
	[1377] = "+43火焰抗性",
	[1378] = "+44火焰抗性",
	[1379] = "+45火焰抗性",
	[1380] = "+46火焰抗性",
	[1381] = "+1自然抗性",
	[1382] = "+2自然抗性",
	[1383] = "+3自然抗性",
	[1384] = "+4自然抗性",
	[1385] = "+5自然抗性",
	[1386] = "+6自然抗性",
	[1387] = "+7自然抗性",
	[1388] = "+8自然抗性",
	[1389] = "+9自然抗性",
	[1390] = "+10自然抗性",
	[1391] = "+11自然抗性",
	[1392] = "+12自然抗性",
	[1393] = "+13自然抗性",
	[1394] = "+14自然抗性",
	[1395] = "+15自然抗性",
	[1396] = "+16自然抗性",
	[1397] = "+17自然抗性",
	[1398] = "+18自然抗性",
	[1399] = "+19自然抗性",
	[1400] = "+20自然抗性",
	[1401] = "+21自然抗性",
	[1402] = "+22自然抗性",
	[1403] = "+23自然抗性",
	[1404] = "+24自然抗性",
	[1405] = "+25自然抗性",
	[1406] = "+26自然抗性",
	[1407] = "+27自然抗性",
	[1408] = "+28自然抗性",
	[1409] = "+29自然抗性",
	[1410] = "+30自然抗性",
	[1411] = "+31自然抗性",
	[1412] = "+32自然抗性",
	[1413] = "+33自然抗性",
	[1414] = "+34自然抗性",
	[1415] = "+35自然抗性",
	[1416] = "+36自然抗性",
	[1417] = "+37自然抗性",
	[1418] = "+38自然抗性",
	[1419] = "+39自然抗性",
	[1420] = "+40自然抗性",
	[1421] = "+41自然抗性",
	[1422] = "+42自然抗性",
	[1423] = "+43自然抗性",
	[1424] = "+44自然抗性",
	[1425] = "+45自然抗性",
	[1426] = "+46自然抗性",
	[1427] = "+1暗影抗性",
	[1428] = "+2暗影抗性",
	[1429] = "+3暗影抗性",
	[1430] = "+4暗影抗性",
	[1431] = "+5暗影抗性",
	[1432] = "+6暗影抗性",
	[1433] = "+7暗影抗性",
	[1434] = "+8暗影抗性",
	[1435] = "+9暗影抗性",
	[1436] = "+10暗影抗性",
	[1437] = "+11暗影抗性",
	[1438] = "+12暗影抗性",
	[1439] = "+13暗影抗性",
	[1440] = "+14暗影抗性",
	[1441] = "+15暗影抗性",
	[1442] = "+16暗影抗性",
	[1443] = "+17暗影抗性",
	[1444] = "+18暗影抗性",
	[1445] = "+19暗影抗性",
	[1446] = "+20暗影抗性",
	[1447] = "+21暗影抗性",
	[1448] = "+22暗影抗性",
	[1449] = "+23暗影抗性",
	[1450] = "+24暗影抗性",
	[1451] = "+25暗影抗性",
	[1452] = "+26暗影抗性",
	[1453] = "+27暗影抗性",
	[1454] = "+28暗影抗性",
	[1455] = "+29暗影抗性",
	[1456] = "+30暗影抗性",
	[1457] = "+31暗影抗性",
	[1458] = "+32暗影抗性",
	[1459] = "+33暗影抗性",
	[1460] = "+34暗影抗性",
	[1461] = "+35暗影抗性",
	[1462] = "+36暗影抗性",
	[1463] = "+37暗影抗性",
	[1464] = "+38暗影抗性",
	[1465] = "+39暗影抗性",
	[1466] = "+40暗影抗性",
	[1467] = "+41暗影抗性",
	[1468] = "+42暗影抗性",
	[1469] = "+43暗影抗性",
	[1470] = "+44暗影抗性",
	[1471] = "+45暗影抗性",
	[1472] = "+46暗影抗性",
	[1483] = "法力值+150",
	[1503] = "生命值+100",
	[1504] = "护甲+125",
	[1505] = "+20火焰抗性",
	[1506] = "力量+8",
	[1507] = "耐力+8",
	[1508] = "敏捷+8",
	[1509] = "智力+8",
	[1510] = "精神+8",
	[1523] = "法力值+85 火焰抵抗+14",
	[1524] = "生命值+75 火焰抵抗+14",
	[1525] = "护甲+110 火焰抵抗+14",
	[1526] = "力量+10 火焰抵抗+14",
	[1527] = "耐力+10 火焰抵抗+14",
	[1528] = "敏捷+10 火焰抵抗+14",
	[1529] = "智力+10 火焰抵抗+14",
	[1530] = "精神+10 火焰抵抗+14",
	[1531] = "力量+10 耐力+10",
	[1532] = "力量+10 敏捷+10 护甲+110 火焰抵抗+15",
	[1543] = "智力+10 精神+10 法力值+100 火焰抵抗+15",
	[1563] = "+2攻击强度",
	[1583] = "+4攻击强度",
	[1584] = "+6攻击强度",
	[1585] = "+8攻击强度",
	[1586] = "+10攻击强度",
	[1587] = "+12攻击强度",
	[1588] = "+14攻击强度",
	[1589] = "+16攻击强度",
	[1590] = "+18攻击强度",
	[1591] = "+20攻击强度",
	[1592] = "+22攻击强度",
	[1593] = "+24攻击强度",
	[1594] = "+26攻击强度",
	[1595] = "+28攻击强度",
	[1596] = "+30攻击强度",
	[1597] = "+32攻击强度",
	[1598] = "+34攻击强度",
	[1599] = "+36攻击强度",
	[1600] = "+38攻击强度",
	[1601] = "+40攻击强度",
	[1602] = "+42攻击强度",
	[1603] = "+44攻击强度",
	[1604] = "+46攻击强度",
	[1605] = "+48攻击强度",
	[1606] = "+50攻击强度",
	[1607] = "+52攻击强度",
	[1608] = "+54攻击强度",
	[1609] = "+56攻击强度",
	[1610] = "+58攻击强度",
	[1611] = "+60攻击强度",
	[1612] = "+62攻击强度",
	[1613] = "+64攻击强度",
	[1614] = "+66攻击强度",
	[1615] = "+68攻击强度",
	[1616] = "+70攻击强度",
	[1617] = "+72攻击强度",
	[1618] = "+74攻击强度",
	[1619] = "+76攻击强度",
	[1620] = "+78攻击强度",
	[1621] = "+80攻击强度",
	[1622] = "+82攻击强度",
	[1623] = "+84攻击强度",
	[1624] = "+86攻击强度",
	[1625] = "+88攻击强度",
	[1626] = "+90攻击强度",
	[1627] = "+92攻击强度",
	[1643] = "锋利+8",
	[1663] = "石化5",
	[1664] = "石化7",
	[1665] = "火舌5",
	[1666] = "火舌6",
	[1667] = "冰封4",
	[1668] = "冰封5",
	[1669] = "风怒4",
	[1683] = "火舌图腾IV",
	[1703] = "稳固+8",
	[1704] = "瑟银盾刺(20-30)",
	[1723] = "清晰预兆",
	[1743] = "MHTest02",
	[1763] = "冷血",
	[1783] = "风怒图腾I",
	[1803] = "火焰石1",
	[1823] = "火焰石2",
	[1824] = "火焰石3",
	[1825] = "火焰石4",
	[1843] = "加固护甲+40",
	[1863] = "反弹2",
	[1864] = "反弹3",
	[1865] = "反弹4",
	[1866] = "反弹5",
	[1883] = "智力+7",
	[1884] = "精神+9",
	[1885] = "力量+9",
	[1886] = "耐力+9",
	[1887] = "敏捷+7",
	[1888] = "所有抗性+5",
	[1889] = "护甲+70",
	[1890] = "精神+9",
	[1891] = "所有属性+4",
	[1892] = "生命值+100",
	[1893] = "法力值+100",
	[1894] = "冰霜武器",
	[1895] = "伤害+9",
	[1896] = "武器伤害+9",
	[1897] = "武器伤害+5",
	[1898] = "生命窃取",
	[1899] = "不洁武器",
	[1900] = "十字军",
	[1901] = "智力+9",
	[1903] = "精神+9",
	[1904] = "智力+9",
	[1923] = "+3火焰抗性",
	[1943] = "+8防御",
	[1944] = "+5防御",
	[1945] = "+6防御",
	[1946] = "+7防御",
	[1947] = "+7防御",
	[1948] = "+9防御",
	[1949] = "+9防御",
	[1950] = "+10防御",
	[1951] = "+11防御",
	[1952] = "+13防御",
	[1953] = "+15防御",
	[1954] = "+17防御",
	[1955] = "+21防御",
	[1956] = "+11防御",
	[1957] = "+12防御",
	[1958] = "+13防御",
	[1959] = "+14防御",
	[1960] = "+15防御",
	[1961] = "+16防御",
	[1962] = "+17防御",
	[1963] = "+18防御",
	[1964] = "+19防御",
	[1965] = "+19防御",
	[1966] = "+20防御",
	[1967] = "+21防御",
	[1968] = "+22防御",
	[1969] = "+23防御",
	[1970] = "+23防御",
	[1971] = "+24防御",
	[1972] = "+25防御",
	[1973] = "+25防御",
	[1983] = "+1%格挡值",
	[1984] = "+2%格挡值",
	[1985] = "+3%格挡值",
	[1986] = "+4%格挡值",
	[1987] = "格挡值等级14",
	[1988] = "格挡值等级15",
	[1989] = "格挡值等级16",
	[1990] = "格挡值等级17",
	[1991] = "格挡值等级18",
	[1992] = "格挡值等级19",
	[1993] = "格挡值等级20",
	[1994] = "格挡值等级21",
	[1995] = "格挡值等级22",
	[1996] = "格挡值等级23",
	[1997] = "格挡值等级24",
	[1998] = "格挡值等级25",
	[1999] = "格挡值等级26",
	[2000] = "格挡值等级27",
	[2001] = "格挡值等级28",
	[2002] = "格挡值等级29",
	[2003] = "格挡值等级30",
	[2004] = "格挡值等级31",
	[2005] = "格挡值等级32",
	[2006] = "格挡值等级33",
	[2007] = "格挡值等级34",
	[2008] = "格挡值等级35",
	[2009] = "格挡值等级36",
	[2010] = "格挡值等级37",
	[2011] = "格挡值等级38",
	[2012] = "格挡值等级39",
	[2013] = "格挡值等级40",
	[2014] = "格挡值等级41",
	[2015] = "格挡值等级42",
	[2016] = "格挡值等级43",
	[2017] = "格挡值等级44",
	[2018] = "格挡值等级45",
	[2019] = "格挡值等级46",
	[2020] = "格挡值等级47",
	[2021] = "格挡值等级48",
	[2022] = "格挡值等级49",
	[2023] = "格挡值等级50",
	[2024] = "格挡值等级51",
	[2025] = "格挡值等级52",
	[2026] = "格挡值等级53",
	[2027] = "格挡值等级54",
	[2028] = "格挡值等级55",
	[2029] = "格挡值等级56",
	[2030] = "格挡值等级57",
	[2031] = "格挡值等级58",
	[2032] = "格挡值等级59",
	[2033] = "格挡值等级60",
	[2034] = "格挡值等级61",
	[2035] = "格挡值等级62",
	[2036] = "格挡值等级63",
	[2037] = "格挡值等级64",
	[2038] = "格挡值等级65",
	[2039] = "格挡值等级66",
	[2040] = "+2远程攻击强度",
	[2041] = "+5远程攻击强度",
	[2042] = "+7远程攻击强度",
	[2043] = "+10远程攻击强度",
	[2044] = "+12远程攻击强度",
	[2045] = "+14远程攻击强度",
	[2046] = "+17远程攻击强度",
	[2047] = "+19远程攻击强度",
	[2048] = "+22远程攻击强度",
	[2049] = "+24远程攻击强度",
	[2050] = "+26远程攻击强度",
	[2051] = "+29远程攻击强度",
	[2052] = "+31远程攻击强度",
	[2053] = "+34远程攻击强度",
	[2054] = "+36远程攻击强度",
	[2055] = "+38远程攻击强度",
	[2056] = "+41远程攻击强度",
	[2057] = "+43远程攻击强度",
	[2058] = "+46远程攻击强度",
	[2059] = "+48远程攻击强度",
	[2060] = "+50远程攻击强度",
	[2061] = "+53远程攻击强度",
	[2062] = "+55远程攻击强度",
	[2063] = "+58远程攻击强度",
	[2064] = "+60远程攻击强度",
	[2065] = "+62远程攻击强度",
	[2066] = "+65远程攻击强度",
	[2067] = "+67远程攻击强度",
	[2068] = "+70远程攻击强度",
	[2069] = "+72远程攻击强度",
	[2070] = "+74远程攻击强度",
	[2071] = "+77远程攻击强度",
	[2072] = "+79远程攻击强度",
	[2073] = "+82远程攻击强度",
	[2074] = "+84远程攻击强度",
	[2075] = "+86远程攻击强度",
	[2076] = "+89远程攻击强度",
	[2077] = "+91远程攻击强度",
	[2078] = "+1%躲闪",
	[2079] = "+1奥术法术伤害",
	[2080] = "+3奥术法术伤害",
	[2081] = "+4奥术法术伤害",
	[2082] = "+6奥术法术伤害",
	[2083] = "+7奥术法术伤害",
	[2084] = "+9奥术法术伤害",
	[2085] = "+10奥术法术伤害",
	[2086] = "+11奥术法术伤害",
	[2087] = "+13奥术法术伤害",
	[2088] = "+14奥术法术伤害",
	[2089] = "+16奥术法术伤害",
	[2090] = "+17奥术法术伤害",
	[2091] = "+19奥术法术伤害",
	[2092] = "+20奥术法术伤害",
	[2093] = "+21奥术法术伤害",
	[2094] = "+23奥术法术伤害",
	[2095] = "+24奥术法术伤害",
	[2096] = "+26奥术法术伤害",
	[2097] = "+27奥术法术伤害",
	[2098] = "+29奥术法术伤害",
	[2099] = "+30奥术法术伤害",
	[2100] = "+31奥术法术伤害",
	[2101] = "+33奥术法术伤害",
	[2102] = "+34奥术法术伤害",
	[2103] = "+36奥术法术伤害",
	[2104] = "+37奥术法术伤害",
	[2105] = "+39奥术法术伤害",
	[2106] = "+40奥术法术伤害",
	[2107] = "+41奥术法术伤害",
	[2108] = "+43奥术法术伤害",
	[2109] = "+44奥术法术伤害",
	[2110] = "+46奥术法术伤害",
	[2111] = "+47奥术法术伤害",
	[2112] = "+49奥术法术伤害",
	[2113] = "+50奥术法术伤害",
	[2114] = "+51奥术法术伤害",
	[2115] = "+53奥术法术伤害",
	[2116] = "+54奥术法术伤害",
	[2117] = "+1暗影法术伤害",
	[2118] = "+3暗影法术伤害",
	[2119] = "+4暗影法术伤害",
	[2120] = "+6暗影法术伤害",
	[2121] = "+7暗影法术伤害",
	[2122] = "+9暗影法术伤害",
	[2123] = "+10暗影法术伤害",
	[2124] = "+11暗影法术伤害",
	[2125] = "+13暗影法术伤害",
	[2126] = "+14暗影法术伤害",
	[2127] = "+16暗影法术伤害",
	[2128] = "+17暗影法术伤害",
	[2129] = "+19暗影法术伤害",
	[2130] = "+20暗影法术伤害",
	[2131] = "+21暗影法术伤害",
	[2132] = "+23暗影法术伤害",
	[2133] = "+24暗影法术伤害",
	[2134] = "+26暗影法术伤害",
	[2135] = "+27暗影法术伤害",
	[2136] = "+29暗影法术伤害",
	[2137] = "+30暗影法术伤害",
	[2138] = "+31暗影法术伤害",
	[2139] = "+33暗影法术伤害",
	[2140] = "+34暗影法术伤害",
	[2141] = "+36暗影法术伤害",
	[2142] = "+37暗影法术伤害",
	[2143] = "+39暗影法术伤害",
	[2144] = "+40暗影法术伤害",
	[2145] = "+41暗影法术伤害",
	[2146] = "+43暗影法术伤害",
	[2147] = "+44暗影法术伤害",
	[2148] = "+46暗影法术伤害",
	[2149] = "+47暗影法术伤害",
	[2150] = "+49暗影法术伤害",
	[2151] = "+50暗影法术伤害",
	[2152] = "+51暗影法术伤害",
	[2153] = "+53暗影法术伤害",
	[2154] = "+54暗影法术伤害",
	[2155] = "+1火焰法术伤害",
	[2156] = "+3火焰法术伤害",
	[2157] = "+4火焰法术伤害",
	[2158] = "+6火焰法术伤害",
	[2159] = "+7火焰法术伤害",
	[2160] = "+9火焰法术伤害",
	[2161] = "+10火焰法术伤害",
	[2162] = "+11火焰法术伤害",
	[2163] = "+13火焰法术伤害",
	[2164] = "+14火焰法术伤害",
	[2165] = "+16火焰法术伤害",
	[2166] = "+17火焰法术伤害",
	[2167] = "+19火焰法术伤害",
	[2168] = "+20火焰法术伤害",
	[2169] = "+21火焰法术伤害",
	[2170] = "+23火焰法术伤害",
	[2171] = "+24火焰法术伤害",
	[2172] = "+26火焰法术伤害",
	[2173] = "+27火焰法术伤害",
	[2174] = "+29火焰法术伤害",
	[2175] = "+30火焰法术伤害",
	[2176] = "+31火焰法术伤害",
	[2177] = "+33火焰法术伤害",
	[2178] = "+34火焰法术伤害",
	[2179] = "+36火焰法术伤害",
	[2180] = "+37火焰法术伤害",
	[2181] = "+39火焰法术伤害",
	[2182] = "+40火焰法术伤害",
	[2183] = "+41火焰法术伤害",
	[2184] = "+43火焰法术伤害",
	[2185] = "+44火焰法术伤害",
	[2186] = "+46火焰法术伤害",
	[2187] = "+47火焰法术伤害",
	[2188] = "+49火焰法术伤害",
	[2189] = "+50火焰法术伤害",
	[2190] = "+51火焰法术伤害",
	[2191] = "+53火焰法术伤害",
	[2192] = "+54火焰法术伤害",
	[2193] = "+1神圣法术伤害",
	[2194] = "+3神圣法术伤害",
	[2195] = "+4神圣法术伤害",
	[2196] = "+6神圣法术伤害",
	[2197] = "+7神圣法术伤害",
	[2198] = "+9神圣法术伤害",
	[2199] = "+10神圣法术伤害",
	[2200] = "+11神圣法术伤害",
	[2201] = "+13神圣法术伤害",
	[2202] = "+14神圣法术伤害",
	[2203] = "+16神圣法术伤害",
	[2204] = "+17神圣法术伤害",
	[2205] = "+19神圣法术伤害",
	[2206] = "+20神圣法术伤害",
	[2207] = "+21神圣法术伤害",
	[2208] = "+23神圣法术伤害",
	[2209] = "+24神圣法术伤害",
	[2210] = "+26神圣法术伤害",
	[2211] = "+27神圣法术伤害",
	[2212] = "+29神圣法术伤害",
	[2213] = "+30神圣法术伤害",
	[2214] = "+31神圣法术伤害",
	[2215] = "+33神圣法术伤害",
	[2216] = "+34神圣法术伤害",
	[2217] = "+36神圣法术伤害",
	[2218] = "+37神圣法术伤害",
	[2219] = "+39神圣法术伤害",
	[2220] = "+40神圣法术伤害",
	[2221] = "+41神圣法术伤害",
	[2222] = "+43神圣法术伤害",
	[2223] = "+44神圣法术伤害",
	[2224] = "+46神圣法术伤害",
	[2225] = "+47神圣法术伤害",
	[2226] = "+49神圣法术伤害",
	[2227] = "+50神圣法术伤害",
	[2228] = "+51神圣法术伤害",
	[2229] = "+53神圣法术伤害",
	[2230] = "+54神圣法术伤害",
	[2231] = "+1冰霜法术伤害",
	[2232] = "+3冰霜法术伤害",
	[2233] = "+4冰霜法术伤害",
	[2234] = "+6冰霜法术伤害",
	[2235] = "+7冰霜法术伤害",
	[2236] = "+9冰霜法术伤害",
	[2237] = "+10冰霜法术伤害",
	[2238] = "+11冰霜法术伤害",
	[2239] = "+13冰霜法术伤害",
	[2240] = "+14冰霜法术伤害",
	[2241] = "+16冰霜法术伤害",
	[2242] = "+17冰霜法术伤害",
	[2243] = "+19冰霜法术伤害",
	[2244] = "+20冰霜法术伤害",
	[2245] = "+21冰霜法术伤害",
	[2246] = "+23冰霜法术伤害",
	[2247] = "+24冰霜法术伤害",
	[2248] = "+26冰霜法术伤害",
	[2249] = "+27冰霜法术伤害",
	[2250] = "+29冰霜法术伤害",
	[2251] = "+30冰霜法术伤害",
	[2252] = "+31冰霜法术伤害",
	[2253] = "+33冰霜法术伤害",
	[2254] = "+34冰霜法术伤害",
	[2255] = "+36冰霜法术伤害",
	[2256] = "+37冰霜法术伤害",
	[2257] = "+39冰霜法术伤害",
	[2258] = "+40冰霜法术伤害",
	[2259] = "+41冰霜法术伤害",
	[2260] = "+43冰霜法术伤害",
	[2261] = "+44冰霜法术伤害",
	[2262] = "+46冰霜法术伤害",
	[2263] = "+47冰霜法术伤害",
	[2264] = "+49冰霜法术伤害",
	[2265] = "+50冰霜法术伤害",
	[2266] = "+51冰霜法术伤害",
	[2267] = "+53冰霜法术伤害",
	[2268] = "+54冰霜法术伤害",
	[2269] = "+1自然法术伤害",
	[2270] = "+3自然法术伤害",
	[2271] = "+4自然法术伤害",
	[2272] = "+6自然法术伤害",
	[2273] = "+7自然法术伤害",
	[2274] = "+9自然法术伤害",
	[2275] = "+10自然法术伤害",
	[2276] = "+11自然法术伤害",
	[2277] = "+13自然法术伤害",
	[2278] = "+14自然法术伤害",
	[2279] = "+16自然法术伤害",
	[2280] = "+17自然法术伤害",
	[2281] = "+19自然法术伤害",
	[2282] = "+20自然法术伤害",
	[2283] = "+21自然法术伤害",
	[2284] = "+23自然法术伤害",
	[2285] = "+24自然法术伤害",
	[2286] = "+26自然法术伤害",
	[2287] = "+27自然法术伤害",
	[2288] = "+29自然法术伤害",
	[2289] = "+30自然法术伤害",
	[2290] = "+31自然法术伤害",
	[2291] = "+33自然法术伤害",
	[2292] = "+34自然法术伤害",
	[2293] = "+36自然法术伤害",
	[2294] = "+37自然法术伤害",
	[2295] = "+39自然法术伤害",
	[2296] = "+40自然法术伤害",
	[2297] = "+41自然法术伤害",
	[2298] = "+43自然法术伤害",
	[2299] = "+44自然法术伤害",
	[2300] = "+46自然法术伤害",
	[2301] = "+47自然法术伤害",
	[2302] = "+49自然法术伤害",
	[2303] = "+50自然法术伤害",
	[2304] = "+51自然法术伤害",
	[2305] = "+53自然法术伤害",
	[2306] = "+54自然法术伤害",
	[2307] = "+2治疗法术",
	[2308] = "+4治疗法术",
	[2309] = "+7治疗法术",
	[2310] = "+9治疗法术",
	[2311] = "+11治疗法术",
	[2312] = "+13治疗法术",
	[2313] = "+15治疗法术",
	[2314] = "+18治疗法术",
	[2315] = "+20治疗法术",
	[2316] = "+22治疗法术",
	[2317] = "+24治疗法术",
	[2318] = "+26治疗法术",
	[2319] = "+29治疗法术",
	[2320] = "+31治疗法术",
	[2321] = "+33治疗法术",
	[2322] = "+35治疗法术",
	[2323] = "+37治疗法术",
	[2324] = "+40治疗法术",
	[2325] = "+42治疗法术",
	[2326] = "+44治疗法术",
	[2327] = "+46治疗法术",
	[2328] = "+48治疗法术",
	[2329] = "+51治疗法术",
	[2330] = "+53治疗法术",
	[2331] = "+55治疗法术",
	[2332] = "+57治疗法术",
	[2333] = "+59治疗法术",
	[2334] = "+62治疗法术",
	[2335] = "+64治疗法术",
	[2336] = "+66治疗法术",
	[2337] = "+68治疗法术",
	[2338] = "+70治疗法术",
	[2339] = "+73治疗法术",
	[2340] = "+75治疗法术",
	[2341] = "+77治疗法术",
	[2342] = "+79治疗法术",
	[2343] = "+81治疗法术",
	[2344] = "+84治疗法术",
	[2363] = "每5秒回复+1",
	[2364] = "每5秒回复+1",
	[2365] = "每5秒回复+1",
	[2366] = "每5秒回复+2",
	[2367] = "每5秒回复+2",
	[2368] = "每5秒回复+2",
	[2369] = "每5秒回复+3",
	[2370] = "每5秒回复+3",
	[2371] = "每5秒回复+4",
	[2372] = "每5秒回复+4",
	[2373] = "每5秒回复+4",
	[2374] = "每5秒回复+5",
	[2375] = "每5秒回复+5",
	[2376] = "每5秒回复+6",
	[2377] = "+每5秒回复6",
	[2378] = "每5秒回复+6",
	[2379] = "每5秒回复+7",
	[2380] = "每5秒回复+7",
	[2381] = "每5秒回复+8",
	[2382] = "每5秒回复+8",
	[2383] = "每5秒回复+8",
	[2384] = "每5秒回复+9",
	[2385] = "每5秒回复+9",
	[2386] = "每5秒回复+10",
	[2387] = "每5秒回复+10",
	[2388] = "每5秒回复+10",
	[2389] = "每5秒回复+11",
	[2390] = "每5秒回复+11",
	[2391] = "每5秒回复+12",
	[2392] = "每5秒回复+12",
	[2393] = "每5秒回复+12",
	[2394] = "每5秒回复+13",
	[2395] = "每5秒回复+13",
	[2396] = "每5秒回复+14",
	[2397] = "每5秒回复+14",
	[2398] = "每5秒回复+14",
	[2399] = "每5秒回复+15",
	[2400] = "每5秒回复+15",
	[2401] = "每5秒回复生命+1",
	[2402] = "每5秒回复生命+1",
	[2403] = "每5秒回复生命+1",
	[2404] = "每5秒回复生命+1",
	[2405] = "每5秒回复生命+1",
	[2406] = "每5秒回复生命+2",
	[2407] = "每5秒回复生命+2",
	[2408] = "每5秒回复生命+2",
	[2409] = "每5秒回复生命+2",
	[2410] = "每5秒回复生命+3",
	[2411] = "每5秒回复生命+3",
	[2412] = "每5秒回复生命+3",
	[2413] = "每5秒回复生命+3",
	[2414] = "每5秒回复生命+4",
	[2415] = "每5秒回复生命+4",
	[2416] = "每5秒回复生命+4",
	[2417] = "每5秒回复生命+4",
	[2418] = "每5秒回复生命+5",
	[2419] = "每5秒回复生命+5",
	[2420] = "每5秒回复生命+5",
	[2421] = "每5秒回复生命+5",
	[2422] = "每5秒回复生命+6",
	[2423] = "每5秒回复生命+6",
	[2424] = "每5秒回复生命+6",
	[2425] = "每5秒回复生命+6",
	[2426] = "每5秒回复生命+7",
	[2427] = "每5秒回复生命+7",
	[2428] = "每5秒回复生命+7",
	[2429] = "每5秒回复生命+7",
	[2430] = "每5秒回复生命+8",
	[2431] = "每5秒回复生命+8",
	[2432] = "每5秒回复生命+8",
	[2433] = "每5秒回复生命+8",
	[2434] = "每5秒回复生命+9",
	[2435] = "每5秒回复生命+9",
	[2436] = "每5秒回复生命+9",
	[2437] = "每5秒回复生命+9",
	[2438] = "每5秒回复生命+10",
	[2443] = "冰霜法术伤害 +7",
	[2463] = "+7火焰抗性",
	[2483] = "+5火焰抗性",
	[2484] = "+5冰霜抗性",
	[2485] = "+5奥术抗性",
	[2486] = "+5自然抗性",
	[2487] = "+5暗影抗性",
	[2488] = "所有抗性+5",
	[2503] = "防御等级+3",
	[2504] = "法术伤害+30",
	[2505] = "治疗法术+55",
	[2506] = "爆击率+2%",
	[2523] = "+3%命中",
	[2543] = "攻速+1%",
	[2544] = "治疗和法术伤害+8",
	[2545] = "躲闪+1%",
	[2563] = "力量+15",
	[2564] = "敏捷+15",
	[2565] = "每5秒回复4点法力值",
	[2566] = "治疗法术+24",
	[2567] = "精神+20",
	[2568] = "智力+22",
	[2583] = "防御等级+7/耐力+10/格挡值+15",
	[2584] = "防御等级+7/耐力+10/治疗法术+24",
	[2585] = "攻击强度+28/躲闪 +1%",
	[2586] = "远程攻击强度+24/耐力+10/爆击率+1%",
	[2587] = "治疗和法术伤害+13/智力+15",
	[2588] = "治疗和法术伤害+18/法术命中+1%",
	[2589] = "治疗和法术伤害+18/耐力+10",
	[2590] = "法力回复+4/耐力+10/治疗法术+24",
	[2591] = "智力+10/耐力+10/治疗法术+24",
	[2603] = "恒金渔线",
	[2604] = "+33治疗法术",
	[2605] = "+18法术伤害和治疗",
	[2606] = "+30攻击强度",
	[2607] = "+12治疗和法术伤害",
	[2608] = "+13治疗和法术伤害",
	[2609] = "+15治疗和法术伤害",
	[2610] = "+14治疗和法术伤害",
	[2611] = "重新使用随机 - 15所有法术",
	[2612] = "+18法术伤害和治疗",
	[2613] = "仇恨+2%",
	[2614] = "暗影伤害+20",
	[2615] = "冰霜伤害+20",
	[2616] = "火焰伤害+20",
	[2617] = "治疗法术+30",
	[2618] = "敏捷+15",
	[2619] = "+15火焰抗性",
	[2620] = "+15自然抗性",
	[2621] = "狡诈（威胁降低2%）",
	[2622] = "躲闪 +1%",
	[2623] = "初级巫师之油",
	[2624] = "初级法力之油",
	[2625] = "次级法力之油",
	[2626] = "次级巫师之油",
	[2627] = "无视之油",
	[2628] = "卓越巫师之油",
	[2629] = "卓越法力之油",
	[2630] = "致命药膏 V",
	[2646] = "敏捷+25",
	[2681] = "+10自然抗性",
	[2682] = "+10冰霜抗性",
	[2683] = "+10暗影抗性",
	[2684] = "+100攻击强度亡灵增伤",
	[2685] = "+60法术伤害亡灵增伤",
	[2715] = "治疗法术+31 每5秒回复5法力值",
	[2716] = "耐力+16护甲+100",
	[2717] = "攻击强度+26点，爆击率+1%",
	[2721] = "法术伤害+15 法术爆击率+1%",
	[2802] = "+$i敏捷",
	[2803] = "+$i耐力",
	[2804] = "+$i智力",
	[2805] = "+$i力量",
	[2806] = "+$i精神",
	[2815] = "+$i躲闪",
	[2817] = "+$i奥术抗性",
	[2818] = "+$i火焰抗性",
	[2819] = "+$i冰霜抗性",
	[2820] = "+$i自然抗性",
	[2821] = "+$i暗影抗性",
	[2823] = "+$i爆击率",
	[2825] = "+$i攻击强度",
	[2826] = "+$i防御",
	[3726] = "+$i急速",		
}

--------------------------
-- Item Enchant Display --
--------------------------
addon.hasBiznicks = false

local function DCS_Item_Enchant_GetText()
	local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')
	local ENCHANT_PATTERN = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)') --moving outside of the function might not be warranted but moving outside of for loop is
	local tooltip = CreateFrame("GameTooltip", "DCSScanTooltip", nil, "GameTooltipTemplate") --TODO: use the same frame for both repairs and itemlevel
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.enchant:SetText("")
		-- local slotId, textureName = GetInventorySlotInfo(v) --Call for string parsing instead of table lookup, bleh.
		local item = Item:CreateFromEquipmentSlot(v:GetID())
		local itemLink = GetInventoryItemLink("player", v:GetID())
		if itemLink then
			local itemName, itemStringLink = GetItemInfo(itemLink)
			if itemStringLink then
				local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(itemStringLink,
				"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				-- print(Enchant) --Enchant ID...because, ya know, let's not be logical, Blizzard...
				-- if (slot == CharacterHandsSlot) then
				-- 	if 
				if (Enchant == "2523") then
					addon.hasBiznicks = true
				end
				if showenchant then
					v.enchant:SetTextColor(getItemQualityColor(item:GetItemQuality())) --upvalue call
					if abbrevEnchants then
						v.enchant:SetText(DCS_ABBREV_ENCHANT_IDS[tonumber(""..Enchant.."")])
					else
						v.enchant:SetText(DCS_ENCHANT_IDS[tonumber(""..Enchant.."")])
					end
				else
					v.enchant:SetText("")
				end
			end
			tooltip:ClearLines()
			tooltip:SetHyperlink(itemLink)
		end
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowEnchantChecked = {
	ShowEnchantSetChecked = true,
}

local DCS_ShowEnchantCheck = CreateFrame("CheckButton", "DCS_ShowEnchantCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowEnchantCheck:RegisterEvent("PLAYER_LOGIN")
DCS_ShowEnchantCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DCS_ShowEnchantCheck:RegisterEvent("UNIT_STATS")

DCS_ShowEnchantCheck:ClearAllPoints()
	DCS_ShowEnchantCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -175)
	DCS_ShowEnchantCheck:SetScale(1)
	DCS_ShowEnchantCheck.tooltipText = L["Displays each equipped item's enchantment."].."" --Creates a tooltip on mouseover.
	_G[DCS_ShowEnchantCheck:GetName() .. "Text"]:SetText(L["Enchants"])
	
DCS_ShowEnchantCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showenchant = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked
		self:SetChecked(showenchant)
	end
	if PaperDollFrame:IsVisible() then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_Enchant_GetText() --Shouldn't be needed as there is never a time when the paperdoll wont have to be opened to display this.
		DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
	end
end)

DCS_ShowEnchantCheck:SetScript("OnClick", function(self)
	showenchant = not showenchant
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked = showenchant
	DCS_Set_Dura_Item_Positions() --is this call needed? (Yes, it is -Deja)
	DCS_Item_Enchant_GetText()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked = {
	AbbrevEnchantsSetChecked = true,
}

local DCS_AbbrevEnchantsCheck = CreateFrame("CheckButton", "DCS_AbbrevEnchantsCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_AbbrevEnchantsCheck:RegisterEvent("PLAYER_LOGIN")
DCS_AbbrevEnchantsCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DCS_AbbrevEnchantsCheck:RegisterEvent("UNIT_STATS")

DCS_AbbrevEnchantsCheck:ClearAllPoints()
	DCS_AbbrevEnchantsCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -195)
	DCS_AbbrevEnchantsCheck:SetScale(1)
	DCS_AbbrevEnchantsCheck.tooltipText = L["Displays an abbreviated label of each equipped item's enchantment."] --Creates a tooltip on mouseover.
	_G[DCS_AbbrevEnchantsCheck:GetName() .. "Text"]:SetText(L["Abbreviated Enchant Labels"])
	
DCS_AbbrevEnchantsCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		abbrevEnchants = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked
		self:SetChecked(abbrevEnchants)
	end
	if PaperDollFrame:IsVisible() then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_Enchant_GetText() --Shouldn't be needed as there is never a time when the paperdoll wont have to be opened to display this.
		DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
	end
end)

DCS_AbbrevEnchantsCheck:SetScript("OnClick", function(self)
	abbrevEnchants = not abbrevEnchants
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked = abbrevEnchants
	DCS_Set_Dura_Item_Positions() --is this call needed? (Yes, it is -Deja)
	DCS_Item_Enchant_GetText()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsAlternateInfoPlacement = {
	AlternateInfoPlacementChecked = false,
}

PaperDollFrame:HookScript("OnShow", function(self)
	if showitemlevel then
		DCS_Item_Level_Center()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.ilevel:SetFormattedText("")
		end
	end
	if showrepair then
		DCS_Item_RepairCostBottom()
		DCS_Set_Dura_Item_Positions()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
	if showavgdur then
		DCS_Mean_Durability()
		if addon.duraMean == 100 then --check after calculation
			duraMeanFS:SetFormattedText("")
		else
			duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
		end
	else
		duraMeanFS:SetFormattedText("")
		duraDurabilityFrameFS:Hide()
	end
	if showdura then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
	if showtextures then
		DCS_Durability_Bar_Textures()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
	if showenchant then
		DCS_Item_Enchant_GetText()
	end
	DCS_Set_Item_Quality_Color_Outlines()
end)


-- local tempEnchantID = {
-- 	[256] = 600, -- (+75)
-- 	[263] = 600, -- (+25)
-- 	[264] = 600, -- (+50)
-- 	[265] = 600, -- (+75)
-- 	[266] = 600, -- (+100)
-- 	[3868] = 3600, -- (+100)
-- 	[4225] = 900, -- (+150)
-- 	[4264] = 600, -- (+15)
-- 	[4919] = 600, -- (+150)
-- 	[5386] = 600, -- (+200)
-- }

-- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
-- itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
-- 	GetItemInfo(itemID or "itemString" or "itemName" or "itemLink")
	
-- local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
-- print()
-- local duration = tempEnchantID[mainHandEnchantID] or 3600

local DCS_AlternateInfoPlacementCheck = CreateFrame("CheckButton", "DCS_AlternateInfoPlacementCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_AlternateInfoPlacementCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_AlternateInfoPlacementCheck:ClearAllPoints()
	--DCS_AlternateInfoPlacementCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_AlternateInfoPlacementCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -155)
	DCS_AlternateInfoPlacementCheck:SetScale(1)
	DCS_AlternateInfoPlacementCheck.tooltipText = L["Displays the item's info beside each item's slot."] --Creates a tooltip on mouseover.
	_G[DCS_AlternateInfoPlacementCheck:GetName() .. "Text"]:SetText(L["Display Info Beside Items"])

DCS_AlternateInfoPlacementCheck:SetScript("OnEvent", function(self, event, ...)
	otherinfoplacement = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked
	self:SetChecked(otherinfoplacement)
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Level_Center()
	DCS_Item_Enchant_GetText()
end)

DCS_AlternateInfoPlacementCheck:SetScript("OnClick", function(self)
	otherinfoplacement = not otherinfoplacement
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked = otherinfoplacement
	DCS_Set_Dura_Item_Positions()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsItemQualityBorders = {
	ItemQualityBordersChecked = true,
}

local DCS_ItemQualityBordersCheck = CreateFrame("CheckButton", "DCS_ItemQualityBordersCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemQualityBordersCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemQualityBordersCheck:ClearAllPoints()
	--DCS_ItemQualityBordersCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_ItemQualityBordersCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -215)
	DCS_ItemQualityBordersCheck:SetScale(1)
	DCS_ItemQualityBordersCheck.tooltipText = L["Displays a colored border around each item's slot indicating its quality."] --Creates a tooltip on mouseover.
	_G[DCS_ItemQualityBordersCheck:GetName() .. "Text"]:SetText(L["Item Quality Borders"])

DCS_ItemQualityBordersCheck:SetScript("OnEvent", function(self, event, ...)
	qualityBordersChecked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked
	self:SetChecked(qualityBordersChecked)
	-- DCS_Set_Item_Quality_Color_Outlines() -- Don't use at login (only set check) as items are not cached until paperdoll has been opened thus error occurs as all item info is nil
end)

DCS_ItemQualityBordersCheck:SetScript("OnClick", function(self)
	qualityBordersChecked = not qualityBordersChecked
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked = qualityBordersChecked
	DCS_Set_Item_Quality_Color_Outlines()
end)