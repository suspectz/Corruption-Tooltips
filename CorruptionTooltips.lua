local addonName, addon = ...
local R = addon.R
local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("CorruptionTooltips", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

local defaults = {
    profile = {
        append = true,
        summary = true,
        english = false,
    }
}

function CorruptionTooltips:OnInitialize()
    CorruptionTooltips.db = LibStub("AceDB-3.0"):New("CorruptionTooltipsDB", defaults)
end

function CorruptionTooltips:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(CharacterStatsPane.ItemLevelFrame.Corruption, 'OnEnter', 'SummaryHook')
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

function CorruptionTooltips:CreateTooltip(tooltip)
	local name, item = tooltip:GetItem()
  	if not name then return end

  	if IsCorruptedItem(item) then
        local itemSplit = GetItemSplit(item)
        local bonuses = {}

        for index=1, itemSplit[13] do
            bonuses[#bonuses + 1] = itemSplit[13 + index]
        end

		local corruption = CorruptionTooltips:GetCorruption(bonuses)

		if corruption then
			local name = corruption[1]
			local icon = corruption[2]
			local line = '|T'..icon..':12:12:0:0|t '.."|cff956dd1"..name.."|r"
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
        local detected
        for i = 1, tooltip:NumLines() do
            local left = _G[tooltip:GetName().."TextLeft"..i]
            local text = left:GetText()
            if text ~= nil and strsub(text, 1, 1) == "+" then
                detected = string.find(text, L["Corruption"])
                if detected ~= nil then
                    left:SetText(left:GetText().." / "..line)
                    return true
                end
            end
        end
    end
end

function CorruptionTooltips:TooltipHook(frame)
	self:CreateTooltip(frame)
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
                local line = '|T'..icon..':12:12:0:0|t '.."|cff956dd1"..name.."|r"
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
    local slotNames = {
        "HeadSlot", -- [1]
        "NeckSlot", -- [2]
        "ShoulderSlot", -- [3]
        "BackSlot", -- [4]
        "ChestSlot", -- [5]
        "ShirtSlot", -- [6]
        "TabardSlot", -- [7]
        "WristSlot", -- [8]
        "HandsSlot", -- [9]
        "WaistSlot", -- [10]
        "LegsSlot", -- [11]
        "FeetSlot", -- [12]
        "Finger0Slot", -- [13]
        "Finger1Slot", -- [14]
        "Trinket0Slot", -- [15]
        "Trinket1Slot", -- [16]
        "MainHandSlot", -- [17]
        "SecondaryHandSlot", -- [18]
        "AmmoSlot" -- [19]
    }
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
