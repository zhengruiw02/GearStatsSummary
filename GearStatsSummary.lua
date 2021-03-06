local InspectLess = LibStub("LibInspectLess-1.0")
local ISP = LibStub("LibItemStatsPlus")
local itemlink_buff = {}
local OFFSET_X, OFFSET_Y = 2, 2;
local INVSLOT_AVALIABLE = 15

local function SetOrHookScript(frame, scriptName, func)
	if( frame:GetScript(scriptName) ) then
		frame:HookScript(scriptName, func);
	else
		frame:SetScript(scriptName, func);
	end
end

function GearStatsSummary_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE");
	self:RegisterEvent("REPLACE_ENCHANT");

	InspectLess:RegisterCallback("InspectLess_InspectItemReady", GearStatsSummary_InspectItemReady)
	InspectLess:RegisterCallback("InspectLess_InspectReady", GearStatsSummary_InspectReady)
	SetOrHookScript(GearManagerDialogPopup, "OnShow", GearStatsSummary_InspectFrame_OnHide)
	if CoreDependCall then --why do this?
		CoreDependCall("Blizzard_TradeSkillUI", function()
			SetOrHookScript(TradeSkillFrame, "OnShow", GearStatsSummary_InspectFrame_OnHide)
		end)
	end
end

function GearStatsSummary_SetupHook()
	hooksecurefunc("InspectPaperDollFrame_OnShow", GearStatsSummary_InspectFrame);
	SetOrHookScript(InspectFrame, "OnShow", GearStatsSummary_InspectFrame);
	SetOrHookScript(InspectFrame, "OnHide", GearStatsSummary_InspectFrame_OnHide);
	hooksecurefunc("InspectFrame_UnitChanged", GearStatsSummary_InspectFrame_UnitChanged);
end

local tip
if not tip then
	-- Create a custom tooltip for scanning
	tip = CreateFrame("GameTooltip", "GearStatsSummaryTooltip", nil, "GameTooltipTemplate")
	tip:SetOwner(UIParent, "ANCHOR_NONE")
	for i = 1, 40 do
		tip[i] = _G["GearStatsSummaryTooltipTextLeft"..i]
		if not tip[i] then
			tip[i] = tip:CreateFontString()
			tip:AddFontStrings(tip[i], tip:CreateFontString())
			_G["GearStatsSummaryTooltipTextLeft"..i] = tip[i]
		end
	end
elseif not _G["GearStatsSummaryTooltipTextLeft40"] then
	for i = 1, 40 do
		_G["GearStatsSummaryTooltipTextLeft"..i] = tip[i]
	end
end

local GemSlots = {
	EMPTY_SOCKET = true,
	EMPTY_SOCKET_BLUE = true,
	EMPTY_SOCKET_COGWHEEL = true,
	EMPTY_SOCKET_HYDRAULIC = true,
	EMPTY_SOCKET_META = true,
	EMPTY_SOCKET_NO_COLOR = true,
	EMPTY_SOCKET_PRISMATIC = true,
	EMPTY_SOCKET_RED = true,
	EMPTY_SOCKET_YELLOW = true,
}

local function AddGem(Gems, gem)
	if Gems[gem] == nil then
		Gems[gem] = 1
	else
		Gems[gem] = Gems[gem] + 1
	end
end

function GearStatsSummary_UpdateAnchor(doll, insp)
	if not doll then doll = PaperDollFrame:IsVisible() elseif doll<0 then doll = nil end
	if not insp then insp = InspectFrame and InspectFrame:IsVisible() elseif insp<0 then insp = nil end

	local at, ax, ay = nil, 0, 0
	if InspectEquip_InfoWindow and InspectEquip_InfoWindow:IsVisible() then
		at = InspectEquip_InfoWindow; ax=1; ay=-1
	elseif(doll) then
		at = PaperDollFrame; ax=OFFSET_X; ay=OFFSET_Y
	elseif(insp) then
		at = InspectFrame; ax=OFFSET_X; ay=OFFSET_Y
	end

	local af = nil;
	local E = nil;
	if IsAddOnLoaded("ElvUI") then
		E = 1
	elseif IsAddOnLoaded("Tukui") then
		E = 2
	end
	if GearStatsSummaryTargetFrame:IsVisible() then
		GearStatsSummarySelfFrame:ClearAllPoints()
		GearStatsSummarySelfFrame:SetPoint("TOPLEFT", GearStatsSummaryTargetFrame, "TOPRIGHT", E and 2 or 0, 0)
		if E~= nil then
			GearStatsSummarySelfFrame:SetTemplate("Transparent")
			GearStatsSummaryTargetFrame:SetFrameLevel(CharacterFrame:GetFrameLevel())
			if E == 1 then
				unpack(ElvUI).Skins:HandleCloseButton(GearStatsSummarySelfFrameCloseButton)
				unpack(ElvUI).Skins:HandleCloseButton(GearStatsSummaryTargetFrameCloseButton)
			else
				GearStatsSummarySelfFrameCloseButton:SkinCloseButton()
				GearStatsSummaryTargetFrameCloseButton:SkinCloseButton()
			end
			GearStatsSummaryTargetFrame:SetTemplate("Transparent")
		end
		af = GearStatsSummaryTargetFrame
	elseif GearStatsSummarySelfFrame:IsVisible() then
		if E~= nil then
			GearStatsSummarySelfFrame:SetFrameLevel(CharacterFrame:GetFrameLevel())
			if E == 1 then
				unpack(ElvUI).Skins:HandleCloseButton(GearStatsSummarySelfFrameCloseButton)
			else
				GearStatsSummarySelfFrameCloseButton:SkinCloseButton()
			end
			GearStatsSummarySelfFrame:SetTemplate("Transparent")
		end
		af = GearStatsSummarySelfFrame
	end

	if(at and af) then
		af:ClearAllPoints();
		af:SetPoint("TOPLEFT", at, "TOPRIGHT", ax, E and 0 or ay)
	end

end

function GearStatsSummary_OnEvent(self, event, ...)
	local arg1, arg2, arg3 = ...;

	if event == "VARIABLES_LOADED" then
		if RATING_SUMMARY_ANNOUNCE then DEFAULT_CHAT_FRAME:AddMessage(RATING_SUMMARY_ANNOUNCE) end
		--GearStatsSummarySelfFrame:SetScale(0.90)
		--GearStatsSummaryTargetFrame:SetScale(0.90)

		SetOrHookScript(PaperDollFrame, "OnShow", GearStatsSummary_PaperDollFrame_OnShow);
		SetOrHookScript(PaperDollFrame, "OnHide", GearStatsSummary_PaperDollFrame_OnHide);
	end

	if event == "ADDON_LOADED" and arg1=="Blizzard_InspectUI" then
		GearStatsSummary_SetupHook();
	end

	if event == "UNIT_INVENTORY_CHANGED" then
		if ((arg1 == "player") and GearStatsSummarySelfFrame:IsVisible()) then
			GearStatsSummary_HideFrame(GearStatsSummarySelfFrame);
			if (GearStatsSummaryTargetFrame:IsVisible()) then
				GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,GearStatsSummaryTargetFrame,UnitName("player"),0,0);
			else
				GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,PaperDollFrame,UnitName("player"),OFFSET_X,OFFSET_Y);
			end
		elseif ( InspectFrame and InspectFrame:IsVisible() and arg1 == InspectFrame.unit and GearStatsSummaryTargetFrame:IsVisible()) then
			GearStatsSummary_HideFrame(GearStatsSummaryTargetFrame);
			GearStatsSummary_ShowFrame(GearStatsSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y);
			GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,GearStatsSummaryTargetFrame,UnitName("player"),0,0);
		end
	end
	
	if event == "ITEM_UPGRADE_MASTER_UPDATE" or event == "REPLACE_ENCHANT" then
		if GearStatsSummarySelfFrame:IsVisible() then
			GearStatsSummary_HideFrame(GearStatsSummarySelfFrame);
			GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,PaperDollFrame,UnitName("player"),OFFSET_X,OFFSET_Y);
		end
	end
end

function GearStatsSummary_PaperDollFrame_OnShow()
	if not InspectFrame or not InspectFrame:IsVisible() then
		GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,PaperDollFrame,UnitName("player"),OFFSET_X,OFFSET_Y);
	end
	GearStatsSummary_UpdateAnchor(1)
end

function GearStatsSummary_PaperDollFrame_OnHide()
	if not InspectFrame or not InspectFrame:IsVisible() then
		GearStatsSummary_HideFrame(GearStatsSummarySelfFrame);
	end
	GearStatsSummary_UpdateAnchor(-1)
end

function GearStatsSummary_InspectFrame(self)
	if not self.unit then return end
	if InspectLess:IsDone() and InspectLess:GetGUID()==UnitGUID(self.unit) then
		GearStatsSummary_InspectItemReady("InspectLess_InspectItemReady", self.unit, InspectLess:GetGUID(), InspectLess:IsDone());
	end
	if not IsAddOnLoaded("ElvUI") and not IsAddOnLoaded("Tukui") then
		local guild, level, levelid = GetGuildInfo(self.unit)
		if(guild) then
			InspectTitleText:Show();
			InspectTitleText:SetText("<"..guild.."> "..level.." ["..levelid.."]"); -- edited
		else
			InspectTitleText:SetText("");
		end
	end
end

function GearStatsSummary_InspectItemReady(event, unit, guid, ready)
	if(not InspectFrame or not InspectFrame:IsVisible()) then return end;
	GearStatsSummary_ShowFrame(GearStatsSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y,ready);
	GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,GearStatsSummaryTargetFrame,UnitName("player"),0,0);
	GearStatsSummary_UpdateAnchor(nil, 1, nil)
end

local function GetTalentSpec(unit)
	local spec
	if not unit then
		spec = GetSpecialization()
	else
		spec = GetInspectSpecialization(unit)
	end
	if(spec ~= nil and spec > 0) then
		if unit ~= nil then
			local _, name = GetSpecializationInfoByID(spec);
			return name
		else
			local _, name = GetSpecializationInfo(spec)
			return name
		end
	end
end

function GearStatsSummary_InspectReady(event, unit, guid, done)
	if done then
		local frame = GearStatsSummaryTargetFrame;

		if frame:IsVisible() and not frame.talented then
			local tiptext = getglobal(frame:GetName().."Text"):GetText();

			--主天赋显示在装备等级后
		--	local talent = GetInspectSpecialization(unit);
			
		--	talent = talent and talent>0 and select(2, GetSpecializationInfoByID(talent))
		--	if talent then tiptext = tiptext:gsub("([^\n]*"..RATING_SUMMARY_ITEM_LEVEL_SHORT.."：".."[^\n]*)", "%1 ("..select(2, GetSpecializationInfo(talent, true)).." ) ") end
			local talent = GetTalentSpec(unit)
			if talent then tiptext = tiptext:gsub("([^\n]*"..RATING_SUMMARY_ITEM_LEVEL_SHORT.."：".."[^\n]*)", "%1 ("..talent.." ) ") end
			
			tiptext = tiptext.."\n\n"..GearStatsSummary_GetTalentString(true)
			frame.talented = true;
			GearStatsSummary_SetFrameText(frame, nil, tiptext, InspectFrame.unit);
		end
	end
end
function GearStatsSummary_InspectFrame_OnHide()
	GearStatsSummary_HideFrame(GearStatsSummaryTargetFrame);
	GearStatsSummary_HideFrame(GearStatsSummarySelfFrame);
	GearStatsSummary_UpdateAnchor(nil, -1, nil)
end

function GearStatsSummary_InspectFrame_UnitChanged()
	if ( InspectFrame and InspectFrame:IsVisible() and GearStatsSummaryTargetFrame:IsVisible()) then
		GearStatsSummary_HideFrame(GearStatsSummaryTargetFrame);
		GearStatsSummary_ShowFrame(GearStatsSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y);
		GearStatsSummary_ShowFrame(GearStatsSummarySelfFrame,GearStatsSummaryTargetFrame,UnitName("player"),0,0);
	end
end

function GearStatsSummary_GetTalentString(isInspecting)
	local active, inact

	if(isInspecting)then
		local unit = InspectFrame.unit
		if(unit)then
			active = GetInspectSpecialization(unit)
			if(active and active>0) then active = select(2, GetSpecializationInfoByID(active)) end
		end
	else
		active = GetActiveSpecGroup();
		inact = active and (3-active)
		active = GetSpecialization(false, false, active);
		inact = GetSpecialization(false, false, inact);
		active = active and select(2, GetSpecializationInfo(active))
		inact = inact and select(2, GetSpecializationInfo(inact))
	end

	if(active or inact)then
		if(inact)then
			return active, inact
		else
			return active
		end
		--return talentString
	else
		return ""
	end
end

function RS_GetTalentFormat(active , inact)
	if(active or inact)then
		local talentString = SPECIALIZATION..": ";
		talentString=talentString..NORMAL_FONT_COLOR_CODE..(active or EMPTY)..FONT_COLOR_CODE_CLOSE
		if(inact)then
			talentString=talentString.." / "..GRAY_FONT_COLOR_CODE..inact..FONT_COLOR_CODE_CLOSE
		end
		return talentString
	else
		return ""
	end
end

function GearStatsSummary_SetFrameText(frame, tiptitle, tiptext, unit)

	local text = getglobal(frame:GetName().."Text");
	local title = getglobal(frame:GetName().."Title");

	if(tiptitle) then title:SetText(tiptitle); end

	text:SetText(tiptext);
	local height = text:GetStringHeight();
	local width = text:GetStringWidth();
	if(width < title:GetStringWidth()) then
		width = title:GetStringWidth();
	end
	frame:SetHeight(height+30);
	frame:SetWidth(width+10);

end

--local get_unit_gem_info = U1GetUnitGemInfo
--local get_unit_enchant_info = U1GetUnitEnchantInfo
local SpecIDToSpecIndex = {
70, 64, 252, 258, 255, 249, 261, 61, 264, 267, 101,
}
local ArmorBonusForSpec = {
	["CASTER"] = {
		PALADIN = "INT",
		PRIEST = "INT",
		WARLOCK = "INT",
		SHAMAN = "INT",
		MAGE = "INT",
		DRUID = "INT",
		MONK = "INT",
	},
	["TANK"] = {
		DRUID = "AGI",
		PALADIN = "STA",
		DEATHKNIGHT = "STA",
		MONK = "AGI",
	},
	["MELEE"] = {
		WARRIOR = "STR",
		SHAMAN = "AGI",
		ROGUE = "AGI",
		DRUID = "AGI",
		MONK = "AGI",
		DEATHKNIGHT = "STR",
		PALADIN = "STR",
	},
	["RANGED"] = {
		HUNTER = "AGI",
	},
}
function GearStatsSummary_ShowFrame(frame,target,tiptitle,anchorx,anchory,ready)
	local unit = "player";
	if(GearStatsSummaryTargetFrame == frame) then
		if(InspectFrame.unit) then
			unit = InspectFrame.unit;
		else
			return;
		end
	end
	local inspecting = unit~="player"
	local sum = GearStatsSummary_Sum(inspecting);
	local uclocale, uc, ucindex = UnitClass(unit)
	local _, ur = UnitRace(unit)
	local ul = UnitLevel(unit)
	tiptitle = tiptitle .."  |c"..RAID_CLASS_COLORS[uc]["colorStr"]..uclocale..FONT_COLOR_CODE_CLOSE --add class in title
	local spec, active, inact
	if inspecting then
		spec = GetInspectSpecialization(unit)
	else
		spec = GetSpecialization(false, false, GetActiveSpecGroup())
		if spec ~= nil then
			spec = GetSpecializationInfo(spec)
		end
	end
	--[[if spec ~= nil then
		local role = GetSpecializationRoleByID(spec)
	end]]
	if not inspecting then
		active, inact = GearStatsSummary_GetTalentString(false);
	elseif ready then
		active = GearStatsSummary_GetTalentString(true);
	end
	
	--DevTools_Dump(sum);
	local tiptext = "";
	
	local avgLevel = (sum["ITEMLEVEL"] or 0) / sum["ITEMSLOTFORCALC"]
	
	color = HIGHLIGHT_FONT_COLOR_CODE
	if(avgLevel and avgLevel>0) then
		tiptext=tiptext.."\n"..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_ITEM_LEVEL_SHORT..": "..FONT_COLOR_CODE_CLOSE..color..format("%.1f",avgLevel)..FONT_COLOR_CODE_CLOSE
	end
	
	tiptext=tiptext.."\n\n"..NORMAL_FONT_COLOR_CODE..RS_STATS_ONLY_FROM_GEARS..FONT_COLOR_CODE_CLOSE

	local cat, v;
	local Catalog;
	if spec~=nil and GearStatsSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]] ~= nil then
		Catalog = GearStatsSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]];
		--print(spec - SpecIDToSpecIndex[ucindex])
		if sum.ArmorBonus ~= nil then
			local ABS = GearStatsSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]][2]
			ABS = ArmorBonusForSpec[ABS][uc]
			ABS = StatToStatName[ABS]
			--print(sum[ABS])
			if sum[ABS]~=nil then
				sum[ABS] = floor(sum[ABS] * 1.05)
			end
			--print(sum[ABS])
		end
	else
		Catalog = GearStatsSummary_CLASS_STAT["ALL"]
		--print("Catalog")
		spec = 0
	end
	--print(spec.." "..(spec - SpecIDToSpecIndex[ucindex]))
	for _, cat in pairs(Catalog) do
		local catStr = "";
		for _, stat in pairs(GearStatsSummary_STAT[cat]) do
			--ChatFrame1:AddMessage(stat);
			local func = GearStatsSummary_Calc[stat]
			local s1,s2;
			if not func then
				s1 = sum[StatToStatName[stat]] or 0
			else
				s1,s2 = func(sum, StatToStatName[stat], sum[StatToStatName[stat]] or 0, uc, ul, spec)
			end
			local ff = GearStatsSummary_FORMAT[stat] or GREEN_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE;
			if(type(s1)~="number") then
				--ChatFrame1:AddMessage(stat..":"..tostring(s1))
			elseif(s1 and s1>0) then
				local sname = _G[StatToStatName[stat]];
				
				sname = NORMAL_FONT_COLOR_CODE..sname..":"..FONT_COLOR_CODE_CLOSE;
				ff = sname..ff; 
				if stat == "MASTERY" and active~=nil then
					catStr = catStr.."\n"..format(ff, s1, active, s2)
					if sum.ArmorBonus == nil then catStr = catStr.."\n\n".."|cffff0000"..NONE..ARMOR..SPECIALIZATION.."!|r" end
				else
					if not s2 then s2 = '' end
					if pcall(format, ff, s1, s2) then
						catStr = catStr.."\n"..format(ff, s1, s2)
					end
				end
				--ChatFrame1:AddMessage(format(ff, s1, s2, s3, s4))
			end
		end
		if catStr ~="" then
			if tiptext ~= "" then tiptext = tiptext.."\n"; end
			tiptext = tiptext.."\n"..HIGHLIGHT_FONT_COLOR_CODE..(GearStatsSummary_STATS_CAT[cat] or cat)..":"..FONT_COLOR_CODE_CLOSE;
			tiptext = tiptext..catStr;
		end
	end
	--item levels
	if tiptext ~= "" then tiptext = tiptext.."\n"; end
	tiptext = tiptext.."\n"..HIGHLIGHT_FONT_COLOR_CODE..RATING_SUMMARY_ITEM_LEVEL_TITLE..":"..FONT_COLOR_CODE_CLOSE;
	for v = 7, 2, -1 do
		if(sum["ITEMCOUNT"..v]) then
			local _,_,_,colorCode = GetItemQualityColor(v)
			tiptext = tiptext.."\n"..format("|c"..colorCode.."%s "..RATING_SUMMARY_ITEM_LEVEL_FORMAT.."|r", RATING_SUMMARY_ITEM_QUANLITY_NAME[v], sum["ITEMCOUNT"..v], floor(sum["ITEMLEVEL"..v]/sum["ITEMCOUNT"..v]))
		end
	end
	
	if sum["Gems"] ~= nil then
		local total_gem, has_gem, missing_gem = sum["Gems"]["GemSlotCount"], sum["Gems"]["GemSlotCount"] - (sum["Gems"]["EmptyGemSlotCount"] or 0), sum["Gems"]["EmptyGemSlotCount"]
		local gem_info = string.format((missing_gem == nil and "%d" or "|cffff0000%d|r")..'/%d  (',has_gem, total_gem)
		for v = 5, 2, -1 do
			gem_info = gem_info..string.format('%s%d|r', ITEM_QUALITY_COLORS[v].hex, sum["Gems"][v])
			if v > 2 then gem_info = gem_info.."/" end
		end
		tiptext = tiptext ..'\n\n'..RATING_SUMMARY_GEM..': '.. gem_info..")"
	end

	local total_enchant, has_enchant, missing_enchant = (sum["CanEnchant"] or 0), (sum["HasEnchant"] or 0), sum["EnchantMissing"]
	if total_enchant ~= 0 then
		tiptext = tiptext .. ('\n'..RATING_SUMMARY_ENCHANT..': '..(total_enchant==has_enchant and "%d" or "|cffff0000%d|r")..'/%d |cffff0000%s|r'):format(has_enchant, total_enchant, missing_enchant)
	end

	local total_extra_socket, has_extra_socket, missing_extra_socket = (sum["CanExtraSocket"] or 0), (sum["HasExtraSocket"] or 0), sum["ExtraSocketMissing"]
	if total_extra_socket ~= 0 then
		tiptext = tiptext .. ('\n'..RATING_SUMMARY_EXTRA_SOCKET..': '..(total_extra_socket==has_extra_socket and "%d" or "|cffff0000%d|r")..'/%d |cffff0000%s|r'):format(has_extra_socket, total_extra_socket, missing_extra_socket)
	end
	
	-- local total_tinker, has_tinker, missing_tinker = (sum["CanTinker"] or 0), (sum["HasTinker"] or 0), sum["TinkerMissing"]
	-- if total_tinker ~= 0 then
		-- tiptext = tiptext .. ('\n'..RATING_SUMMARY_TINKER..': '..(total_tinker==has_tinker and "%d" or "|cffff0000%d|r")..'/%d |cffff0000%s|r'):format(has_tinker, total_tinker, missing_tinker)
	-- end

	--talent
	if not inspecting then
		tiptext = tiptext.."\n\n"..RS_GetTalentFormat(active, inact);
	elseif ready then
		tiptext = tiptext.."\n\n"..RS_GetTalentFormat(active);
	else
		frame.talented=false;
	end
	GearStatsSummary_SetFrameText(frame, tiptitle, tiptext, unit);
	frame:Show();
end

function GearStatsSummary_HideFrame(frame)
	frame:Hide();
end

local ClassArmorBonus = 
{ 5, 5, 4, 3, 2, 5, 4, 2, 2, 3, 3,}
-- 2=布甲,3=皮甲,4=鎖甲,5=鎧甲
function GearStatsSummary_Sum(inspecting, tipUnit)
	--local slotID;
	--[[ 0 = ammo 1 = head 2 = neck 3 = shoulder 4 = shirt 5 = chest 6 = belt 7 = legs 8 = feet 9 = wrist 10 = gloves 11 = finger 1 12 = finger 2 13 = trinket 1 14 = trinket 2 15 = back 16 = main hand 17 = off hand 18 = ranged 19 = tabard ]]--

	local unit = "player";
	if(inspecting) then unit=InspectFrame.unit end
	if(tipUnit) then unit=tipUnit end
	local _, _, ucindex = UnitClass(unit)
	--local _, ur = UnitRace(unit)
	--local ul = UnitLevel(unit)
	
	local isEnchanting, isBlacksmithing--, isEngineering
	if unit == "player" then
		local prof1, prof2, _, _, _, _ = GetProfessions()
		if prof1 then
			local _, prof1_texture, prof1_lv, _, _, _, _, _ = GetProfessionInfo(prof1)
			if (prof1_texture:find('Trade_Engraving') and prof1_lv >= 550) then
				isEnchanting = true
			elseif (prof1_texture:find('Trade_BlackSmithing') and prof1_lv >= 550) then
				isBlacksmithing = true
			-- elseif (prof1_texture:find('Trade_Engineering') and prof1_lv >= 550) then
				-- isEngineering = true
			end
		end
		if prof2 then
			local _, prof2_texture, prof2_lv, _, _, _, _, _ = GetProfessionInfo(prof2)
			if (prof2_texture:find('Trade_Engraving') and prof2_lv >= 550) then
				isEnchanting = true
			elseif (prof2_texture:find('Trade_BlackSmithing') and prof2_lv >= 550) then
				isBlacksmithing = true
			-- elseif (prof2_texture:find('Trade_Engineering') and prof2_lv >= 550) then
				-- isEngineering = true
			end
		end
	end

	local sum = {};
	sum["EnchantMissing"] = ""
	sum["ExtraSocketMissing"] = ""
	--sum["TinkerMissing"] = ""
	sum.ArmorBonus = ClassArmorBonus[ucindex];
	sum["ITEMSLOTFORCALC"] = INVSLOT_AVALIABLE
	local not2hand
	for i=INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do --zhengruiw02
		local link = GetInventoryItemLink(unit, i);
		if (link) and i ~= INVSLOT_BODY and i ~= INVSLOT_TABARD then
			local _, _, quality, _, _, itemType, itemSubType, _, ItemEquipLoc = GetItemInfo(link); --TO DO: ADD UPGRADES
			local iLevel = ISP:GetUpgradeLevel(link)
			--[[# 2 - Uncommon # 3 - Rare # 4 - Epic # 5 - Legendary # 7 Account]]
			if(quality >=2 and quality <=7) then
				sum["ITEMCOUNT"..quality] = (sum["ITEMCOUNT"..quality] or 0) + 1;
				sum["ITEMLEVEL"..quality] = (sum["ITEMLEVEL"..quality] or 0) + iLevel;
			end
			if iLevel then
				sum["ITEMLEVEL"] = (sum["ITEMLEVEL"] or 0) + iLevel
			end

			local stats = ISP:GetItemStats(link);

			if (i ~= INVSLOT_NECK and 
				i ~= INVSLOT_FINGER1 and 
				i ~= INVSLOT_FINGER2 and 
				i ~= INVSLOT_TRINKET1 and 
				i ~= INVSLOT_TRINKET2 and 
				i ~= INVSLOT_BACK and 
				i ~= INVSLOT_MAINHAND and 
				i ~= INVSLOT_OFFHAND and 
				select(ClassArmorBonus[ucindex],GetAuctionItemSubClasses(2))~=itemSubType 
				)then
				sum.ArmorBonus = nil
			end
			
			if ((i == INVSLOT_OFFHAND) or (i == INVSLOT_MAINHAND and ItemEquipLoc ~= "INVTYPE_2HWEAPON")) and not not2hand then
				sum["ITEMSLOTFORCALC"] = sum["ITEMSLOTFORCALC"] + 1
				not2hand = true
			end
			
			for k,v in pairs(stats) do --newitemStat
			--if i == INVSLOT_MAINHAND then print(k..":"..v) end
				if(k~="itemType" and k~="link" and k~="Gems" and k~="Enchanted" and k~="Set") then
					--if (k=="ITEM_MOD_STAMINA_SHORT") then print(v) end
					if(not sum[k]) then sum[k] = 0 end
					sum[k] = sum[k] + v;
				end
			end
------			
			tip:ClearLines() -- this is required or SetX won't work the second time its called
			for i = 1,4 do
				if _G["GearStatsSummaryTooltipTexture"..i] then
					_G["GearStatsSummaryTooltipTexture"..i]:SetTexture("")-- = nil
				end
			end
			tip:SetHyperlink(link)
			
			stats["Gems"] = {}
			stats["Gems"]["GemSlotCount"] = 0
			for i = 1,4 do
				local texture = _G["GearStatsSummaryTooltipTexture"..i]:GetTexture();
				if ( texture ) then
					--if string.find(texture, "gem") then
						AddGem(stats["Gems"], "GemSlotCount")
						if string.find(texture, "EmptySocket") then
							AddGem(stats["Gems"], "EmptyGemSlotCount")
						end
					--end
				end
			end
			
			local OriGemSlotCount = 0
			for k, v in next, GetItemStats(link) do
				if(GemSlots[k]) then
					OriGemSlotCount = OriGemSlotCount + v
				end
			end
			if OriGemSlotCount < stats["Gems"]["GemSlotCount"] then
				stats["Gems"]["ExtraSlot"] = 1
			end

			for i = 1, 3 do
				local gemname, gemlink = GetItemGem(link, i)
				if(gemlink) then
					local name, link, quality, iLevel, reqLevel, itype, subType = GetItemInfo(gemlink)
					AddGem(stats["Gems"], quality)
				end
			end
			
			local check, _, color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Reforge, Upgrade, Name = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%d*)|?h?%[?([^%[%]c]*)%]?|?h?|?r?");

			if tonumber(Enchant) > 0 then --func for RS
				stats["Enchanted"] = 1
			end
------
	
			if (stats["Gems"] ~= nil) then
				if sum["Gems"] == nil then sum["Gems"] = {} end
				for k,v in pairs(stats["Gems"]) do
					if sum["Gems"][k] == nil then sum["Gems"][k] = 0 end
					sum["Gems"][k] = sum["Gems"][k] + v
				end
			end
			
			for slot, shortname in next, RATING_SUMMARY_ENCHANTABLES do
				if i == slot then
					if sum["CanEnchant"] == nil then sum["CanEnchant"] = 0 end
					if sum["HasEnchant"] == nil then sum["HasEnchant"] = 0 end
					if (i ~= INVSLOT_FINGER1) and (i ~= INVSLOT_FINGER2) then
						sum["CanEnchant"] = sum["CanEnchant"] + 1
					end
					if (i ~= INVSLOT_FINGER1) and (i ~= INVSLOT_FINGER2) and stats["Enchanted"] then 
						sum["HasEnchant"] = sum["HasEnchant"] + 1
					elseif ((i == INVSLOT_FINGER1) or (i == INVSLOT_FINGER2)) then
						if (unit == "player") and isEnchanting then -- finger enchant
							sum["CanEnchant"] = sum["CanEnchant"] + 1
							if stats["Enchanted"] then
								sum["HasEnchant"] = sum["HasEnchant"] + 1
							else
								sum["EnchantMissing"] = sum["EnchantMissing"]..shortname
							end
						else
							if stats["Enchanted"] then
								sum["CanEnchant"] = sum["CanEnchant"] + 1
								sum["HasEnchant"] = sum["HasEnchant"] + 1
							end
						end
					else
						sum["EnchantMissing"] = sum["EnchantMissing"]..shortname
					end
				end
			end
			
			for slot, shortname in next, RATING_SUMMARY_BLACKSMITH do
				if i == slot then
					if sum["CanExtraSocket"] == nil then sum["CanExtraSocket"] = 0 end
					if sum["HasExtraSocket"] == nil then sum["HasExtraSocket"] = 0 end
					if (i == INVSLOT_WAIST) then
						sum["CanExtraSocket"] = sum["CanExtraSocket"] + 1
						if not stats["Gems"]["ExtraSlot"] then
							sum["ExtraSocketMissing"] = sum["ExtraSocketMissing"]..shortname
						else
							sum["HasExtraSocket"] = sum["HasExtraSocket"] + 1
						end
					elseif (unit == "player") and isBlacksmithing then
						sum["CanExtraSocket"] = sum["CanExtraSocket"] + 1
						if not stats["Gems"]["ExtraSlot"] then
							sum["ExtraSocketMissing"] = sum["ExtraSocketMissing"]..shortname
						else
							sum["HasExtraSocket"] = sum["HasExtraSocket"] + 1
						end
					end
				end
			end
			
			-- if (i == INVSLOT_WAIST or i == INVSLOT_HAND or i == INVSLOT_BACK) then --and isEngineering then
				-- for slot, shortname in next, RATING_SUMMARY_ENGINEERING do
					-- if i == slot then
						-- --tip:ClearLines() -- this is required or SetX won't work the second time its called
						-- --tip:SetHyperlink(link)
						-- local hasTinker
						-- for i = 2, tip:NumLines() do
							-- local text = tip[i]:GetText();
							-- print(text)
							-- --local r, g, b = tip[i]:GetTextColor()
							-- if string.find(text, USE) then
								-- hasTinker = true
							-- end
						-- end
						-- if sum["CanTinker"] == nil then sum["CanTinker"] = 0 end
						-- if sum["HasTinker"] == nil then sum["HasTinker"] = 0 end
						-- sum["CanTinker"] = sum["CanTinker"] + 1
						-- if hasTinker then
							-- sum["HasTinker"] = sum["HasTinker"] + 1
						-- else
							-- sum["TinkerMissing"] = sum["TinkerMissing"]..shortname
						-- end
					-- end
				-- end
			-- end
			
			if (stats["Set"] ~= nil) then
				for k,v in pairs(stats["Set"]) do
					if sum["Set"] == nil then sum["Set"] = {} end
					if sum["Set"][k] == nil then sum["Set"][k] = v end
				end
			end
			
		end
	end

	if sum["Set"]~=nil and unit=="player" then
		for k,v in pairs(sum["Set"]) do
			sum["ITEM_MOD_PVP_POWER_SHORT"] = sum["ITEM_MOD_PVP_POWER_SHORT"] + v
		end
	end

	return sum;
end

GearStatsSummary_STATS_CAT = {
	BASE = PLAYERSTAT_BASE_STATS,
	MELEE = PLAYERSTAT_MELEE_COMBAT,
	RANGED = PLAYERSTAT_RANGED_COMBAT,
	TANK = PLAYERSTAT_DEFENSES,
	CASTER = PLAYERSTAT_SPELL_COMBAT,
	OTHER = PVP,
}

GearStatsSummary_STAT = {
	BASE = { "STR", "AGI", "STA", "INT", "SPI", "MASTERY", },
	MELEE = { "AP", "EXPERTISE", "MELEE_HASTE", "MELEE_HIT", "MELEE_CRIT",},
	RANGED = { "RANGED_AP", "EXPERTISE", "RANGED_HASTE", "RANGED_HIT", "RANGED_CRIT",},
	TANK = { "ARMOR", "DODGE", "PARRY", "BLOCK",},
	CASTER = { "SPELL_DMG", "SPELL_HASTE", "SPELL_HIT", "SPELL_CRIT",},
	--HEAL = { "SPELL_DMG", "SPELL_CRIT", "SPELL_HASTE",},
	OTHER = { "RESILIENCE_REDUCTION", "PVP_POWER", }
}

GearStatsSummary_CLASS_STAT = {
	PALADIN = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "TANK", "MELEE", "OTHER", },
		[6] = {"BASE", "MELEE", "OTHER", },
	},
	PRIEST = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "CASTER", "OTHER", },
		[3] = {"BASE", "CASTER", "OTHER", },
	},
	WARLOCK = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "CASTER", "OTHER", },
		[3] = {"BASE", "CASTER", "OTHER", },
	},
	WARRIOR = {
		[1] = {"BASE", "MELEE", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },
		[3] = {"BASE", "TANK", "MELEE", "OTHER", },
	},
	HUNTER = {
		[1] = {"BASE", "RANGED", "OTHER", },
		[2] = {"BASE", "RANGED", "OTHER", },
		[3] = {"BASE", "RANGED", "OTHER", },
	},
	SHAMAN = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },
		[3] = {"BASE", "CASTER", "OTHER", },	
	},
	ROGUE = {
		[1] = {"BASE", "MELEE", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },
		[3] = {"BASE", "MELEE", "OTHER", },
	},
	MAGE = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "CASTER", "OTHER", },
		[3] = {"BASE", "CASTER", "OTHER", },
	},
	DEATHKNIGHT = {
		[1] = {"BASE", "TANK", "MELEE", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },
		[3] = {"BASE", "MELEE", "OTHER", },
	},
	DRUID = {
		[1] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },
		[3] = {"BASE", "TANK", "MELEE", "OTHER", },
		[4] = {"BASE", "CASTER", "OTHER"},
	},
	MONK = {
		[1] = {"BASE", "TANK", "MELEE", "OTHER", },
		[3] = {"BASE", "CASTER", "OTHER", },
		[2] = {"BASE", "MELEE", "OTHER", },	
	},
	ALL = {"BASE", "TANK", "MELEE", "CASTER", "OTHER",}
}

local ratingToEffect = function(sum, stat, val, class, level) return ISP:GetRatingsFromStat(val, level, stat , class, specid ) or 0,val end

GearStatsSummary_Calc = {
	STR = nil,
	AGI = function(sum, stat, val, class, level) return val, ISP:GetCritFromAgi(val, level, class) end,
	STA = function(sum, stat, val, class, level) return val, ISP:GetHPFromSta(val, level) end,
	INT = function(sum, stat, val, class, level) return val, ISP:GetCritFromInt(val, level, class) end,
	SPI = function(sum, stat, val, class, level) return val, ISP:GetMPFromSpt(val, class) end,
	MASTERY = function(sum, stat, val, class, level, specid) return val, ISP:GetRatingsFromStat(val, level, stat , class, specid ) end,

	AP = function(sum, stat, val, class, level) return val + ISP:GetAPFromAgi(sum[StatToStatName["AGI"]] or 0, class) + ISP:GetAPFromStr(sum[StatToStatName["STR"]] or 0, class) end,
	MELEE_HIT = ratingToEffect,
	MELEE_CRIT = function(sum, stat, val, class, level)  local e = ISP:GetRatingsFromStat( val, level, stat ) return e + ISP:GetCritFromAgi(sum[StatToStatName["AGI"]] or 0, level, class), val end,
	MELEE_HASTE = ratingToEffect,
	EXPERTISE = ratingToEffect,

	RANGED_AP = function(sum, stat, val, class, level) return val + (sum["AP"] or 0) + ISP:GetRAPFromAgi(sum["AGI"] or 0, class),val end,
	RANGED_HIT = ratingToEffect,
	RANGED_CRIT = function(sum, stat, val, class, level)  local e = ISP:GetRatingsFromStat( val, level, stat ) return e + ISP:GetCritFromAgi(sum[StatToStatName["AGI"]] or 0, level, class), val end,
	RANGED_HASTE = ratingToEffect,

	ARMOR = nil,
	DODGE = ratingToEffect,
	PARRY = ratingToEffect,
	BLOCK = nil,

	RESILIENCE_REDUCTION = ratingToEffect,
	PVP_POWER = ratingToEffect,
	SPELL_DMG = function(sum, stat, val, class, level) return val + ISP:GetSPFromInt(sum[StatToStatName["INT"]] or 0, class) end,
	SPELL_HIT = function(sum, stat, val, class, level) local v = val + ( sum[StatToStatName["EXPERTISE"]] or 0 ) return ISP:GetRatingsFromStat(v, level, stat) or 0, v end,
	SPELL_CRIT = function(sum, stat, val, class, level)  local e = ISP:GetRatingsFromStat( val, level, stat ) return e + ISP:GetCritFromInt(sum[StatToStatName["AGI"]] or 0, level, class), val end,
	SPELL_HASTE = ratingToEffect,

}

local FI = "%d";
local FP = "%.2f%%";
local FL = "%.1f";
local FR = GREEN_FONT_COLOR_CODE..FP..FONT_COLOR_CODE_CLOSE.." ( "..FI.." ) ";
local CFI = GREEN_FONT_COLOR_CODE..FI..FONT_COLOR_CODE_CLOSE
local BFI = GREEN_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE
local FCRI = GREEN_FONT_COLOR_CODE..FP..FONT_COLOR_CODE_CLOSE.." ( "..FI.." ) ";

GearStatsSummary_FORMAT = {
	STR = BFI,
	AGI = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_MELEE_CRIT..FONT_COLOR_CODE_CLOSE.." %.2f%%".." ) ",
	STA = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_STA_NO_BONUS..FONT_COLOR_CODE_CLOSE.." ) ",
	INT = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_SPELL_CRIT..FONT_COLOR_CODE_CLOSE..FP.." ) ",
	--SPI = BFI.." ( "..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_MANA_REGEN..FONT_COLOR_CODE_CLOSE.." %.2f".." ) ",
	SPI = BFI,
	MASTERY = BFI.." ("..NORMAL_FONT_COLOR_CODE.."%s: "..FONT_COLOR_CODE_CLOSE..FP.." ) ",

	AP = CFI,
	FERAL_AP = CFI,
	MELEE_HIT = FR,
	MELEE_CRIT = FCRI,
	MELEE_HASTE = FR,
	EXPERTISE = FR,

	RANGED_AP = CFI.." ( "..FI.." ) ",
	RANGED_HIT = FR,
	RANGED_CRIT = FCRI,
	RANGED_HASTE = FR,

	ARMOR = CFI,
	DODGE = FR,
	PARRY = FR,
	BLOCK = FR,

	RESILIENCE_REDUCTION = FR,
	PVP_POWER = FR,

	SPELL_DMG = CFI,
	HEAL = CFI,
	SPELL_HIT = FR,
	SPELL_CRIT = FCRI,
	SPELL_HASTE = FR,
}

StatToStatName = {
	["STR"] = "ITEM_MOD_STRENGTH_SHORT",
	["AGI"] = "ITEM_MOD_AGILITY_SHORT",
	["STA"] = "ITEM_MOD_STAMINA_SHORT",
	["INT"] = "ITEM_MOD_INTELLECT_SHORT",
	["SPI"] = "ITEM_MOD_SPIRIT_SHORT",
	["MASTERY"] = "ITEM_MOD_MASTERY_RATING_SHORT",

	["AP"] = "ITEM_MOD_ATTACK_POWER_SHORT",
	["MELEE_HIT"] = "ITEM_MOD_HIT_RATING_SHORT",
	["MELEE_CRIT"] = "ITEM_MOD_CRIT_RATING_SHORT",
	["MELEE_HASTE"] = "ITEM_MOD_HASTE_RATING_SHORT",
	["EXPERTISE"] = "ITEM_MOD_EXPERTISE_RATING_SHORT",

	["RANGED_AP"] = "ITEM_MOD_ATTACK_POWER_SHORT",
	["RANGED_HIT"] = "ITEM_MOD_HIT_RATING_SHORT",
	["RANGED_CRIT"] = "ITEM_MOD_CRIT_RATING_SHORT",
	["RANGED_HASTE"] = "ITEM_MOD_HASTE_RATING_SHORT",

	["ARMOR"] = "RESISTANCE0_NAME",
	--["DEFENSE"] = "",
	["DODGE"] = "ITEM_MOD_DODGE_RATING_SHORT",
	["PARRY"] = "ITEM_MOD_PARRY_RATING_SHORT",
	["BLOCK"] = "ITEM_MOD_BLOCK_RATING_SHORT",
	--["BLOCK_VALUE"] = "",
	--["TOTAL_AVOID"] = "",
	["RESILIENCE_REDUCTION"] = "ITEM_MOD_RESILIENCE_RATING_SHORT",
	["PVP_POWER"] = "ITEM_MOD_PVP_POWER_SHORT",

	["SPELL_DMG"] = "ITEM_MOD_SPELL_POWER_SHORT",
	["SPELL_HIT"] = "ITEM_MOD_HIT_RATING_SHORT",
	["SPELL_CRIT"] = "ITEM_MOD_CRIT_RATING_SHORT",
	["SPELL_HASTE"] = "ITEM_MOD_HASTE_RATING_SHORT",

	["MANA_REG"] = "ITEM_MOD_MANA_REGENERATION_SHORT",
}