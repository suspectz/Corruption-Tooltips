local addonName, addon = ...
local R = addon.R
local W = addon.W
local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")
local P, I

CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("CorruptionTooltips", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

local defaults = {
    profile = {
        append = true,
        icon = true,
        summary = true,
        showlevel = false,
        itemicon = true,
        english = false,
    }
}

local slotNames = {
    "HeadSlot", -- [1]
    "NeckSlot", -- [2]
    "ShoulderSlot", -- [3]
    "ShirtSlot", -- [4]
    "ChestSlot", -- [5]
    "WaistSlot", -- [6]
    "LegsSlot", -- [7]
    "FeetSlot", -- [8]
    "WristSlot", -- [9]
    "HandsSlot", -- [10]
    "Finger0Slot", -- [11]
    "Finger1Slot", -- [12]
    "Trinket0Slot", -- [13]
    "Trinket1Slot", -- [14]
    "BackSlot", -- [15]
    "MainHandSlot", -- [16]
    "SecondaryHandSlot", -- [17]
    "TabardSlot",
    "AmmoSlot"
}

function CorruptionTooltips:OnInitialize()
    CorruptionTooltips.db = LibStub("AceDB-3.0"):New("CorruptionTooltipsDB", defaults)
    self:RegisterEvent('ADDON_LOADED', 'OnLoad')
    self:RegisterEvent('PLAYER_LOGIN', 'OnLogin')
end

function CorruptionTooltips:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(CharacterStatsPane.ItemLevelFrame.Corruption, 'OnEnter', 'SummaryEnter')
    self:SecureHookScript(CharacterStatsPane.ItemLevelFrame.Corruption, 'OnLeave', 'SummaryLeave')
end

function CorruptionTooltips:OnLoad(event, ...)
    if (...) == "Blizzard_InspectUI" then
        self:UnregisterEvent(event)
        I = CreateFrame("Frame", nil, _G.InspectPaperDollFrame)
        CorruptionTooltips:SetupCharacterFrame(I)
        CorruptionTooltips_AddHookInspectUI()
    end
end

function CorruptionTooltips:OnLogin(event, ...)
    self:UnregisterEvent(event)
    P = CreateFrame("Frame", nil, _G.PaperDollFrame)
    CorruptionTooltips:SetupCharacterFrame(P)
end

local function GetItemSplit(itemLink)
  local itemString = string.match(itemLink, "item:([%-?%d:]+)")
  local itemSplit = {}

  -- Split data into a table
  for _, v in ipairs({strsplit(":", itemString)}) do
    if v == "" then
      itemSplit[#itemSplit + 1] = 0
    else
      itemSplit[#itemSplit + 1] = tonumber(v)
    end
  end

  return itemSplit
end

function CorruptionTooltips:TooltipHook(tooltip)
	local name, item = tooltip:GetItem()
  	if not name then return end

  	if IsCorruptedItem(item) then
        local itemSplit = GetItemSplit(item)
        local bonuses = {}

        for index=1, itemSplit[13] do
            bonuses[#bonuses + 1] = itemSplit[13 + index]
        end

        -- local lookup for items without bonuses, like in the EJ
        if itemSplit[13] == 1 then
            local itemID = tostring(itemSplit[1])
            if W[itemID] ~= nil then
                bonuses[#bonuses + 1] = W[itemID]
            end
        end

		local corruption = CorruptionTooltips:GetCorruption(bonuses)

		if corruption then
			local name = corruption[1]
			local icon = corruption[2]
            local line = '|T'..icon..':0|t '..'|cff956dd1'..name..'|r'
            if CorruptionTooltips.db.profile.icon ~= true then
                line = '|cff956dd1'..name..'|r'
            end
			if CorruptionTooltips:Append(tooltip, line) ~= true then
                tooltip:AddLine(" ")
                tooltip:AddLine(line)
			end
		end
	end
end

function CorruptionTooltips:GetCorruption(bonuses)
    if #bonuses > 0 then
        for i, bonus_id in pairs(bonuses) do
            bonus_id = tostring(bonus_id)
            if R[bonus_id] ~= nil then
                local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(R[bonus_id][3])
                if R[bonus_id][2] ~= "" then
                    rank = L[R[bonus_id][2]]
                else
                    rank = ""
                end
                if CorruptionTooltips.db.profile.english then
                    name = R[bonus_id][1]
                    rank = R[bonus_id][2]
                end
                return {
                    name.." "..rank,
                    icon,
                }
            end
        end
    end
end

function CorruptionTooltips:Append(tooltip, line)
    if CorruptionTooltips.db.profile.append then
        for i = 1, tooltip:NumLines() do
            local left = _G[tooltip:GetName().."TextLeft"..i]
            local text = left:GetText()
            if (text ~= nil) then
                local detected = string.find(text, ITEM_MOD_CORRUPTION)
                if (detected ~= nil and ((strsub(text, 1, 1) == "+") or (GetLocale() == "koKR"))) then
                    left:SetText(left:GetText().." / "..line)
                    return true
                end
            end
        end
    end
end

function CorruptionTooltips:SummaryEnter(frame)
    CorruptionTooltips:CharacterFrameShow(P)
    CorruptionTooltips:SummaryHook(frame)
end

function CorruptionTooltips:SummaryLeave(frame)
    CorruptionTooltips:CharacterFrameShow(P)
end

function CorruptionTooltips:SummaryHook(frame)
    if CorruptionTooltips.db.profile.summary then
        local corruptions = CorruptionTooltips:GetCorruptions()
        if #corruptions > 0 then
            GameTooltip:AddLine(" ")

            local buckets = {}
            for i=1, #corruptions do
                local name = corruptions[i][1]
                local icon = corruptions[i][2]
                local line = '|T'..icon..':0|t |cff956dd1'..name..'|r'
                if CorruptionTooltips.db.profile.icon ~= true then
                    line = '|cff956dd1'..name..'|r'
                end

                if buckets[name] == nil then
                    buckets[name] = {
                        1,
                        line,
                    }
                else
                    buckets[name][1]= buckets[name][1] + 1
                end
            end
            table.sort(buckets)
            for name, _ in pairs(buckets) do
                GameTooltip:AddLine("|cff956dd1"..buckets[name][1]..' x '..buckets[name][2].."|r")
            end

            GameTooltip:Show()
        end
    end
end

function CorruptionTooltips:GetCorruptions()
    local corruptions = {}
    for slotNum=1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slotNum])
        local itemLink = GetInventoryItemLink('player', slotId)
        if itemLink then
            local itemSplit = GetItemSplit(itemLink)
            local bonuses = {}

            for index=1, itemSplit[13] do
                bonuses[#bonuses + 1] = itemSplit[13 + index]
            end

            local corruption = CorruptionTooltips:GetCorruption(bonuses)
            if corruption then
                corruptions[#corruptions + 1] = corruption
            end
        end
    end

    return corruptions
end

function CorruptionTooltips:returnPoints(slotId)
    if slotId <= 5 or slotId == 15 or slotId == 9 then -- Left side
        return "LEFT", "RIGHT", 8, 0, "LEFT", "MIDDLE"
    elseif slotId <= 14 then -- Right side
        return "RIGHT", "LEFT", -8, 0, "RIGHT", "MIDDLE"
    else -- Weapon slots
        return "BOTTOM", "TOP", 2, 3, "CENTER", "MIDDLE"
    end
end

function CorruptionTooltips:SetupCharacterFrame(frame)
    if #frame > 0 then return end

    if frame == P then
        frame:SetFrameLevel(_G.CharacterHeadSlot:GetFrameLevel())
        self:SecureHook("PaperDollItemSlotButton_Update", 'CharacterFrameUpdate')
        self:SecureHookScript(frame, "OnShow", 'CharacterFrameShow')
    else
        frame:SetFrameLevel(_G.InspectHeadSlot:GetFrameLevel())
        self:SecureHook("InspectPaperDollItemSlotButton_Update", 'CharacterFrameUpdate')
    end

    for i = 1, #slotNames do
        frame[i] = CreateFrame("Frame", nil, frame)
        local s = frame[i]:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline") -- Revert the previous fix, the smaller text size made it bit too hard to read the icons
        frame[i]:SetAllPoints(s) -- Fontstring anchoring hack by SDPhantom https://www.wowinterface.com/forums/showpost.php?p=280136&postcount=6
        frame[i].string = s;
    end

    local point
    if frame == P then
        point = "Character"
    else
        point = "Inspect"
    end

    for i = 1, #slotNames do -- Set Point and Justify
        local parent = _G[ point..slotNames[i] ]
        local myPoint, parentPoint, x, y, justifyH, justifyV = CorruptionTooltips:returnPoints(i)
        frame[i].string:ClearAllPoints()
        frame[i].string:SetPoint(myPoint, parent, parentPoint, x, y)
        frame[i].string:SetJustifyH(justifyH)
        frame[i].string:SetJustifyV(justifyV)
        frame[i].string:SetFormattedText("")
    end
end

function CorruptionTooltips:CharacterFrameShow(frame)
    C_Timer.After(0, function()
        for slotId = 1, #slotNames do
            CorruptionTooltips:UpdateCharacterFrame(frame, "player", slotId)
        end
    end)
end

function CorruptionTooltips:CharacterFrameUpdate(button)
    local slotId = button:GetID()
    local frame, unit

    if (button:GetParent():GetName() == "PaperDollItemsFrame") then
        frame, unit = P, "player"
    elseif (button:GetParent():GetName()) == "InspectPaperDollItemsFrame" then
        frame, unit = I, _G.InspectFrame.unit or "target"
    end
    CorruptionTooltips:UpdateCharacterFrame(frame, unit, slotId)
end

function CorruptionTooltips:UpdateCharacterFrame(frame, unit, slotId)
    if unit and slotId <= #slotNames then
        local itemLink = GetInventoryItemLink(unit, slotId)
        if CorruptionTooltips.db.profile.showlevel == true and itemLink then
            if IsCorruptedItem(itemLink) and CharacterStatsPane.ItemLevelFrame.Corruption.tooltipShowing then
                local item = Item:CreateFromItemLink(itemLink)
                item:ContinueOnItemLoad(function()
                    local corruption = GetItemStats(item:GetItemLink())
                    if corruption["ITEM_MOD_CORRUPTION"] > 0 then
                        local line = '|cff956dd1'..corruption["ITEM_MOD_CORRUPTION"]..'|r'
                        frame[slotId].string:SetFormattedText(line)
                    end
                end)
                return
            end
        end
        frame[slotId].string:SetFormattedText("")
    end
end


--[[
    Corruption Icons on Item buttons
]]
local function GetCorruptionBonus(itemLink)  -- helper function, duplocate code, should be refactored
    local itemSplit = GetItemSplit(itemLink)
    local bonuses = {}

    for index=1, itemSplit[13] do
        bonuses[#bonuses + 1] = itemSplit[13 + index]
    end

    -- local lookup for items without bonuses, like in the EJ
    if itemSplit[13] == 1 then
        local itemID = tostring(itemSplit[1])
        if W[itemID] ~= nil then
            bonuses[#bonuses + 1] = W[itemID]
        end
    end

    local corruption = CorruptionTooltips:GetCorruption(bonuses)

    if corruption then
        local name = corruption[1]
        local icon = corruption[2]
        return name, icon
    end
end

local function CreateCorruptionIcon(button, icon)
    if not button.corruption then
        button.corruption = CreateFrame("Frame", "$parent.corruption", button);
        button.corruption:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
        button.corruption:SetSize(37, 18)
    else
        button.corruption:ClearAllPoints()
        button.corruption:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
        button.corruption:Show()
    end
    if not button.corruption.icon then
        -- Icon
        button.corruption.icon = button.corruption:CreateTexture("CorruptionIcon", "OVERLAY", button.corruption)
        button.corruption.icon:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
        button.corruption.icon:SetSize(16, 16)
        button.corruption.icon:SetTexture(icon)
        -- Glow Border
        button.corruption.icon.overlay = button.corruption:CreateTexture(nil, "ARTWORK", nil, 7)
        button.corruption.icon.overlay:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
        button.corruption.icon.overlay:SetVertexColor(1.0,0.0,0.0,0.8)
        button.corruption.icon.overlay:SetPoint("TOPLEFT", button.corruption.icon, -3, 3)
        button.corruption.icon.overlay:SetPoint("BOTTOMRIGHT", button.corruption.icon, 3, -3)
        button.corruption.icon.overlay:SetBlendMode("ADD")
    else
        button.corruption.icon:ClearAllPoints()
        button.corruption.icon:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
        button.corruption.icon:SetTexture(icon)
    end
end

local function AddNzothIconOverlay(button)
    button.IconOverlay:SetAtlas("Nzoth-inventory-icon");
    button.IconOverlay:Show();
end

local function SetPaperDollCorruption(button, unit)
    local slotId = button:GetID()
    local textureName = GetInventoryItemTexture(unit, slotId);
    local hasItem = textureName ~= nil;

    if hasItem then
        local itemLink = GetInventoryItemLink(unit, slotId)
        if (itemLink) then
            if IsCorruptedItem(itemLink) then
                _, icon = GetCorruptionBonus(itemLink)
                CreateCorruptionIcon(button, icon)
                AddNzothIconOverlay(button)
            else
                if button.corruption then
                    button.corruption:Hide()
                end
            end
        end
    else
        if button.corruption then
            button.corruption:Hide()
        end
    end
end


local function SetEquipmentFlyoutCorruption(button)
    if button.corruption then
        button.corruption:Hide()
    end

    if ( not button.location ) then
        return;
    end

    if ( button.location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION ) then
        return;
    end

    local _, _, _, _, slot, bag = EquipmentManager_UnpackLocation(button.location)
    local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)

    if not bag then return end

    if not button then
        return
    end;

    local itemLink = C_Item.GetItemLink(itemLoc)
    if IsCorruptedItem(itemLink) then
        _, icon = GetCorruptionBonus(itemLink)
        CreateCorruptionIcon(button, icon)
        AddNzothIconOverlay(button)
    end
end

local function SetContainerButtonCorruption(button, bag)
    if button.corruption then
        button.corruption:Hide()
    end

    local slot = button:GetID()
    local item = Item:CreateFromBagAndSlot(bag, slot)
    if item:IsItemEmpty() then
        return
    end

    -- item:ContinueOnItemLoad(function()
        local itemLink = GetContainerItemLink(bag, slot)
        if IsCorruptedItem(itemLink) then
            _, icon = GetCorruptionBonus(itemLink)
            CreateCorruptionIcon(button, icon)
            AddNzothIconOverlay(button)
        end
    -- end)
end

local function SetLootCorruption(index)
    local button = _G["LootButton"..index]
    if button.corruption then
        button.corruption:Hide()
    end

    local numLootToShow = LOOTFRAME_NUMBUTTONS
    local slot = (numLootToShow * (LootFrame.page - 1)) + index
    if (LootSlotHasItem(slot)) then
        local itemLink = GetLootSlotLink(slot)
        if itemLink and IsCorruptedItem(itemLink) then
            _, icon = GetCorruptionBonus(itemLink)
            CreateCorruptionIcon(button, icon)
        end
    end
end

hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
    if not CorruptionTooltips.db.profile.itemicon then return end
    SetPaperDollCorruption(button, "player")
end)

function CorruptionTooltips_AddHookInspectUI()
    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        if not CorruptionTooltips.db.profile.itemicon then return end
        SetPaperDollCorruption(button, "target")
    end)
end

hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
    if not CorruptionTooltips.db.profile.itemicon then return end
    SetEquipmentFlyoutCorruption(button)
end)

hooksecurefunc("ContainerFrame_Update", function(container)
    if not CorruptionTooltips.db.profile.itemicon then return end
    local bag = container:GetID()
    local name = container:GetName()
    for i = 1, container.size, 1 do
        local button = _G[name .. "Item" .. i]
        SetContainerButtonCorruption(button, bag)
    end
end)

hooksecurefunc("BankFrameItemButton_Update", function(button)
    if not CorruptionTooltips.db.profile.itemicon then return end
    if not button.isBag then
        SetContainerButtonCorruption(button, -1)
    end
end)

hooksecurefunc("LootFrame_UpdateButton", function(index)
    if not CorruptionTooltips.db.profile.itemicon then return end
    SetLootCorruption(index)
end)
