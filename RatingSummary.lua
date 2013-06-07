--local StatLogic = LibStub("LibStatLogic-1.2")
local InspectLess = LibStub("LibInspectLess-1.0")
local ISP = LibStub("LibItemStatsPlus")
local itemlink_buff = {}
local OFFSET_X, OFFSET_Y = 2, 2;

local function SetOrHookScript(frame, scriptName, func)
	if( frame:GetScript(scriptName) ) then
		frame:HookScript(scriptName, func);
	else
		frame:SetScript(scriptName, func);
	end
end

function RatingSummary_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");

	InspectLess:RegisterCallback("InspectLess_InspectItemReady", RatingSummary_InspectItemReady)
	InspectLess:RegisterCallback("InspectLess_InspectReady", RatingSummary_InspectReady)
	SetOrHookScript(GearManagerDialogPopup, "OnShow", RatingSummary_InspectFrame_OnHide)
	if CoreDependCall then
		CoreDependCall("Blizzard_TradeSkillUI", function()
			SetOrHookScript(TradeSkillFrame, "OnShow", RatingSummary_InspectFrame_OnHide)
		end)
	end
end

function RatingSummary_SetupHook()
	hooksecurefunc("InspectPaperDollFrame_OnShow", RatingSummary_InspectFrame_SetGuild);
	SetOrHookScript(InspectFrame, "OnShow", RatingSummary_InspectFrame_SetGuild);
	SetOrHookScript(InspectFrame, "OnHide", RatingSummary_InspectFrame_OnHide);
	hooksecurefunc("InspectFrame_UnitChanged", RatingSummary_InspectFrame_UnitChanged);
end

function RatingSummary_UpdateAnchor(doll, insp)
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
	if RatingSummaryTargetFrame:IsVisible() then
		RatingSummarySelfFrame:ClearAllPoints()
		RatingSummarySelfFrame:SetPoint("TOPLEFT", RatingSummaryTargetFrame, "TOPRIGHT", E and 2 or 0, 0)
		if E~= nil then
			RatingSummarySelfFrame:SetTemplate("Transparent")
			RatingSummaryTargetFrame:SetFrameLevel(CharacterFrame:GetFrameLevel())
			if E == 1 then
				unpack(ElvUI).Skins:HandleCloseButton(RatingSummarySelfFrameCloseButton)
				unpack(ElvUI).Skins:HandleCloseButton(RatingSummaryTargetFrameCloseButton)
			else
				RatingSummarySelfFrameCloseButton:SkinCloseButton()
				RatingSummaryTargetFrameCloseButton:SkinCloseButton()
			end
			RatingSummaryTargetFrame:SetTemplate("Transparent")
		end
		af = RatingSummaryTargetFrame
	elseif RatingSummarySelfFrame:IsVisible() then
		if E~= nil then
			RatingSummarySelfFrame:SetFrameLevel(CharacterFrame:GetFrameLevel())
			if E == 1 then
				unpack(ElvUI).Skins:HandleCloseButton(RatingSummarySelfFrameCloseButton)
			else
				RatingSummarySelfFrameCloseButton:SkinCloseButton()
			end
			RatingSummarySelfFrame:SetTemplate("Transparent")
		end
		af = RatingSummarySelfFrame
	end

	if(at and af) then
		af:ClearAllPoints();
		af:SetPoint("TOPLEFT", at, "TOPRIGHT", ax, E and 0 or ay)
	end

end

function RatingSummary_OnEvent(self, event, ...)
	local arg1, arg2, arg3 = ...;

	if event == "VARIABLES_LOADED" then
		if RATING_SUMMARY_ANNOUNCE then DEFAULT_CHAT_FRAME:AddMessage(RATING_SUMMARY_ANNOUNCE) end
		--RatingSummarySelfFrame:SetScale(0.90)
		--RatingSummaryTargetFrame:SetScale(0.90)

		SetOrHookScript(PaperDollFrame, "OnShow", RatingSummary_PaperDollFrame_OnShow);
		SetOrHookScript(PaperDollFrame, "OnHide", RatingSummary_PaperDollFrame_OnHide);
	end

	if event == "ADDON_LOADED" and arg1=="Blizzard_InspectUI" then
		RatingSummary_SetupHook();
	end

	if  event == "UNIT_INVENTORY_CHANGED" then
		if ((arg1 == "player") and RatingSummarySelfFrame:IsVisible()) then
			RatingSummary_HideFrame(RatingSummarySelfFrame);
			if (RatingSummaryTargetFrame:IsVisible()) then
				RatingSummary_ShowFrame(RatingSummarySelfFrame,RatingSummaryTargetFrame,UnitName("player"),0,0);
			else
				RatingSummary_ShowFrame(RatingSummarySelfFrame,PaperDollFrame,UnitName("player"),OFFSET_X,OFFSET_Y);
			end
		elseif ( InspectFrame and InspectFrame:IsVisible() and arg1 == InspectFrame.unit and RatingSummaryTargetFrame:IsVisible()) then
			RatingSummary_HideFrame(RatingSummaryTargetFrame);
			RatingSummary_ShowFrame(RatingSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y);
			RatingSummary_ShowFrame(RatingSummarySelfFrame,RatingSummaryTargetFrame,UnitName("player"),0,0);
		end
	end
end

function RatingSummary_PaperDollFrame_OnShow()
	if not InspectFrame or not InspectFrame:IsVisible() then
		RatingSummary_ShowFrame(RatingSummarySelfFrame,PaperDollFrame,UnitName("player"),OFFSET_X,OFFSET_Y);
	end
	RatingSummary_UpdateAnchor(1)
end

function RatingSummary_PaperDollFrame_OnHide()
	if not InspectFrame or not InspectFrame:IsVisible() then
		RatingSummary_HideFrame(RatingSummarySelfFrame);
	end
	RatingSummary_UpdateAnchor(-1)
end

function RatingSummary_InspectFrame_SetGuild(self)
	if not self.unit then return end
	--print("RatingSummary_InspectFrame_SetGuild called")
	if InspectLess:IsDone() and InspectLess:GetGUID()==UnitGUID(self.unit) then
		RatingSummary_InspectItemReady("InspectLess_InspectItemReady", self.unit, InspectLess:GetGUID(), InspectLess:IsDone());
	end
	local guild, level, levelid = GetGuildInfo(self.unit)
	if(guild) then
		InspectTitleText:Show();
		InspectTitleText:SetText("<"..guild.."> "..level.." ["..levelid.."]"); -- edited
	else
		InspectTitleText:SetText("");
	end
end

function RatingSummary_InspectItemReady(event, unit, guid, ready)
	if(not InspectFrame or not InspectFrame:IsVisible()) then return end;
	RatingSummary_ShowFrame(RatingSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y,ready);
	RatingSummary_ShowFrame(RatingSummarySelfFrame,RatingSummaryTargetFrame,UnitName("player"),0,0);
	RatingSummary_UpdateAnchor(nil, 1, nil)
end

function RatingSummary_InspectReady(event, unit, guid, done)
	if done then
		local frame = RatingSummaryTargetFrame;

		if frame:IsVisible() and not frame.talented then
			local tiptext = getglobal(frame:GetName().."Text"):GetText();

			--主天赋显示在装备等级后
			local talent = GetInspectSpecialization(unit);
			talent = talent and talent>0 and select(2, GetSpecializationInfoByID(talent))
			if talent then tiptext = tiptext:gsub("([^\n]*"..RATING_SUMMARY_ITEM_LEVEL_SHORT.."：".."[^\n]*)", "%1 ("..select(2, GetSpecializationInfo(talent, true)).." ) ") end

			tiptext = tiptext.."\n\n"..RatingSummary_GetTalentString(true)
			frame.talented = true;
			RatingSummary_SetFrameText(frame, nil, tiptext, InspectFrame.unit);
		end
	end
end
function RatingSummary_InspectFrame_OnHide()
	RatingSummary_HideFrame(RatingSummaryTargetFrame);
	RatingSummary_HideFrame(RatingSummarySelfFrame);
	RatingSummary_UpdateAnchor(nil, -1, nil)
end

function RatingSummary_InspectFrame_UnitChanged()
	if ( InspectFrame and InspectFrame:IsVisible() and RatingSummaryTargetFrame:IsVisible()) then
		RatingSummary_HideFrame(RatingSummaryTargetFrame);
		RatingSummary_ShowFrame(RatingSummaryTargetFrame,InspectFrame,UnitName(InspectFrame.unit),OFFSET_X,OFFSET_Y);
		RatingSummary_ShowFrame(RatingSummarySelfFrame,RatingSummaryTargetFrame,UnitName("player"),0,0);
	end
end

function RatingSummary_GetTalentString(isInspecting)
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

function RatingSummary_SetFrameText(frame, tiptitle, tiptext, unit)

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
function RatingSummary_ShowFrame(frame,target,tiptitle,anchorx,anchory,ready)
	local unit = "player";
	if(RatingSummaryTargetFrame == frame) then
		if(InspectFrame.unit) then
			unit = InspectFrame.unit;
		else
			return;
		end
	end
	local inspecting = unit~="player"
	local sum = RatingSummary_Sum(inspecting);
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
		active, inact = RatingSummary_GetTalentString(false);
	elseif ready then
		active = RatingSummary_GetTalentString(true);
	end
	
	--DevTools_Dump(sum);
	local tiptext = "";
	
	--local avgLevel, color, resilience, totalLevel, count, slotCount, itemLinks = U1GetInventoryLevel(unit)
	local avgLevel = (sum["ITEMLEVEL"] or 0) / ( sum["ITEMCOUNT"] or 1)
	--local r,g,b = U1GetInventoryLevelColor(avgLevel)
	color = HIGHLIGHT_FONT_COLOR_CODE
	if(avgLevel and avgLevel>0) then
		tiptext=tiptext.."\n"..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_ITEM_LEVEL_SHORT.."："..FONT_COLOR_CODE_CLOSE..color..format("%.1f",avgLevel)..FONT_COLOR_CODE_CLOSE
		if IsAddOnLoaded("GearScoreLite") then
			local score = GearScore_GetScore(UnitName(unit), unit) or "no_cache"
			if type(score)=="number" then
				r,g,b = GearScore_GetQuality(score)
				color = "|cff"..string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
			end
			tiptext=tiptext.."\n"..NORMAL_FONT_COLOR_CODE.." GS ".."："..FONT_COLOR_CODE_CLOSE..color..score..FONT_COLOR_CODE_CLOSE
		elseif GearScoreL then
			local score, gs_color = GearScoreL:GetPlayerInfo(unit)
			tiptext=tiptext.."\n"..NORMAL_FONT_COLOR_CODE.." GS ".."："..FONT_COLOR_CODE_CLOSE.."|cff"..color..score..FONT_COLOR_CODE_CLOSE
		elseif IsAddOnLoaded("GearScore") and not inspecting then
			local score = TenTonHammer.PlayerInfo['GearScore'] or "no_cache"
			if type(score)=="number" then
				_, _, _, color = TenTonHammer:GetColor(score)
			else
				color = "|cff"..color
			end
			tiptext=tiptext.."\n"..NORMAL_FONT_COLOR_CODE.." GS ".."："..FONT_COLOR_CODE_CLOSE..color..score..FONT_COLOR_CODE_CLOSE
		end
	end
	
	tiptext=tiptext.."\n\n"..NORMAL_FONT_COLOR_CODE..RS_STATS_ONLY_FROM_GEARS..FONT_COLOR_CODE_CLOSE

	local cat, v;
	local Catalog;
	if spec~=nil and RatingSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]] ~= nil then
		Catalog = RatingSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]];
		--print(spec - SpecIDToSpecIndex[ucindex])
		if sum.ArmorBonus ~= nil then
			local ABS = RatingSummary_CLASS_STAT[uc][spec - SpecIDToSpecIndex[ucindex]][2]
			ABS = ArmorBonusForSpec[ABS][uc]
			ABS = StatToStatName[ABS]
			--print(sum[ABS])
			if sum[ABS]~=nil then
				sum[ABS] = floor(sum[ABS] * 1.05)
			end
			--print(sum[ABS])
		end
	else
		Catalog = RatingSummary_CLASS_STAT["ALL"]
		--print("Catalog")
		spec = 0
	end
	--print(spec.." "..(spec - SpecIDToSpecIndex[ucindex]))
	for _, cat in pairs(Catalog) do
		local catStr = "";
		for _, stat in pairs(RatingSummary_STAT[cat]) do
			--ChatFrame1:AddMessage(stat);
			local func = RatingSummary_Calc[stat]
			local s1,s2,s3,s4;
			if not func then
				s1 = sum[StatToStatName[stat]] or 0
			else
				s1,s2,s3,s4 = func(sum, StatToStatName[stat], sum[StatToStatName[stat]] or 0, uc, ul, spec)
			end
			local ff = RatingSummary_FORMAT[stat] or GREEN_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE;
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
					catStr = catStr.."\n"..format(ff, s1, s2, s3, s4)
				end
				--ChatFrame1:AddMessage(format(ff, s1, s2, s3, s4))
			end
		end
		if catStr ~="" then
			if tiptext ~= "" then tiptext = tiptext.."\n"; end
			tiptext = tiptext.."\n"..HIGHLIGHT_FONT_COLOR_CODE..(RatingSummary_STATS_CAT[cat] or cat)..":"..FONT_COLOR_CODE_CLOSE;
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
	tiptext = tiptext .. ('\n'..RATING_SUMMARY_ENCHANT..': '..(total_enchant==has_enchant and "%d" or "|cffff0000%d|r")..'/%d |cffff0000%s|r'):format(has_enchant, total_enchant, missing_enchant)

	--talent
	if not inspecting then
		tiptext = tiptext.."\n\n"..RS_GetTalentFormat(active, inact);
	elseif ready then
		tiptext = tiptext.."\n\n"..RS_GetTalentFormat(active);
	else
		frame.talented=false;
	end
	RatingSummary_SetFrameText(frame, tiptitle, tiptext, unit);
	frame:Show();
end

function RatingSummary_HideFrame(frame)
	frame:Hide();
end

local ClassArmorBonus = 
{ 5, 5, 4, 3, 2, 5, 4, 2, 2, 3, 3,}
-- 2=布甲,3=皮甲,4=鎖甲,5=鎧甲
function RatingSummary_Sum(inspecting, tipUnit)
	--local slotID;
	--[[ 0 = ammo 1 = head 2 = neck 3 = shoulder 4 = shirt 5 = chest 6 = belt 7 = legs 8 = feet 9 = wrist 10 = gloves 11 = finger 1 12 = finger 2 13 = trinket 1 14 = trinket 2 15 = back 16 = main hand 17 = off hand 18 = ranged 19 = tabard ]]--

	local unit = "player";
	if(inspecting) then unit=InspectFrame.unit end
	if(tipUnit) then unit=tipUnit end
	local _, _, ucindex = UnitClass(unit)
	--local _, ur = UnitRace(unit)
	--local ul = UnitLevel(unit)
	
	local sum = {};
	sum["EnchantMissing"] = ""
	sum.ArmorBonus = ClassArmorBonus[ucindex];
	for i=INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do --zhengruiw02
		local link = GetInventoryItemLink(unit, i);
		if (link) and i ~= INVSLOT_BODY and i ~= INVSLOT_TABARD then
			local _, _, quality, _, _, itemType, itemSubType = GetItemInfo(link); --TO DO: ADD UPGRADES
			local iLevel = ISP:GetUpgradeLevel(link)
			--[[# 2 - Uncommon # 3 - Rare # 4 - Epic # 5 - Legendary # 7 Account]]
			if(quality >=2 and quality <=7) then
				sum["ITEMCOUNT"..quality] = (sum["ITEMCOUNT"..quality] or 0) + 1;
				sum["ITEMLEVEL"..quality] = (sum["ITEMLEVEL"..quality] or 0) + iLevel;
			end
			if iLevel then
				sum["ITEMCOUNT"] = (sum["ITEMCOUNT"] or 0) + 1;
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
			
			for k,v in pairs(stats) do --newitemStat
			--if i == INVSLOT_MAINHAND then print(k..":"..v) end
				if(k~="itemType" and k~="link" and k~="Gems" and k~="Enchanted") then
					--if (k=="ITEM_MOD_STAMINA_SHORT") then print(v) end
					if(not sum[k]) then sum[k] = 0 end
					sum[k] = sum[k] + v;
				end
			end
			
			if(stats["Gems"] ~= nil) then
				if sum["Gems"] == nil then sum["Gems"] = {} end
				for k,v in pairs(stats["Gems"]) do
					if sum["Gems"][k] == nil then sum["Gems"][k] = 0 end
					sum["Gems"][k] = sum["Gems"][k] + v
				end
			end
			
			for slot, shortname in next, RATING_SUMMARY_ENCHANTABLES do
				if i == slot then
					if sum["CanEnchant"] == nil then sum["CanEnchant"] = 0 end
					sum["CanEnchant"] = sum["CanEnchant"] + 1
					if ((i == INVSLOT_WAIST) and (stats["Gems"]["ExtraSlot"])) or stats["Enchanted"] then 
						if sum["HasEnchant"] == nil then sum["HasEnchant"] = 0 end
						sum["HasEnchant"] = sum["HasEnchant"] + 1
					else
						sum["EnchantMissing"] = sum["EnchantMissing"]..shortname
					end
				end
			end

		end
	end

	return sum;
end

RatingSummary_STATS_CAT = {
	BASE = PLAYERSTAT_BASE_STATS,
	MELEE = PLAYERSTAT_MELEE_COMBAT,
	RANGED = PLAYERSTAT_RANGED_COMBAT,
	TANK = PLAYERSTAT_DEFENSES,
	CASTER = PLAYERSTAT_SPELL_COMBAT,
	OTHER = "PvP",
}

RatingSummary_STAT = {
	BASE = { "STR", "AGI", "STA", "INT", "SPI", "MASTERY", },
	MELEE = { "AP", "EXPERTISE", "MELEE_HASTE", "MELEE_HIT", "MELEE_CRIT",},
	RANGED = { "RANGED_AP", "EXPERTISE", "RANGED_HASTE", "RANGED_HIT", "RANGED_CRIT",},
	TANK = { "ARMOR", "DODGE", "PARRY", "BLOCK",},
	CASTER = { "SPELL_DMG", "SPELL_HASTE", "SPELL_HIT", "SPELL_CRIT",},
	--HEAL = { "SPELL_DMG", "SPELL_CRIT", "SPELL_HASTE",},
	OTHER = { "RESILIENCE_REDUCTION", "PVP_POWER", }
}

RatingSummary_CLASS_STAT = {
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

local SL = StatLogic;
RatingSummary_Calc = {
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

	RESILIENCE_REDUCTION = nil,--ratingToEffect,
	PVP_POWER = nil,--ratingToEffect,
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

RatingSummary_FORMAT = {
	STR = BFI,
	AGI = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_MELEE_CRIT..FONT_COLOR_CODE_CLOSE.." %.2f%%".." ) ",
	STA = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_STA_NO_BONUS..FONT_COLOR_CODE_CLOSE.." ) ",
	INT = BFI.." ("..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_SPELL_CRIT..FONT_COLOR_CODE_CLOSE.." %.2f%%".." ) ",
	--SPI = BFI.." ( "..NORMAL_FONT_COLOR_CODE..RATING_SUMMARY_MANA_REGEN..FONT_COLOR_CODE_CLOSE..FI.." ) ",
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

	RESILIENCE_REDUCTION = BFI,--FR,
	PVP_POWER = BFI,--FR,

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