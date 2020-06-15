local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("Scanner")
local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

local Config, DB

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
    "TabardSlot", -- [18]
    "AmmoSlot" -- [19]
}

local function GetCorruptionByID(bonusID)
    local corruption = DB:GetBonus(bonusID)
    if corruption ~= nil then
        local rank
        local name, _, icon, _, _, _ = GetSpellInfo(corruption[3])
        if corruption[2] ~= "" then
            rank = L[corruption[2]]
        else
            rank = ""
        end
        if Config:GetOption("english") ~= false then
            name = corruption[1]
            rank = corruption[2]
        end

        return name.." "..rank, icon, rank
    end
end

function Module:OnInitialize()
    Config = Addon:GetModule("Config")
    DB = Addon:GetModule("DB")
end

function Module:GetItemSplit(itemLink)
    local itemString = string.match(itemLink, "item:([%-?%d:]+)")
    local itemSplit = {}

    if itemString ~= nil then
        -- Split data into a table
        for _, v in ipairs({strsplit(":", itemString)}) do
            if v == "" then
                itemSplit[#itemSplit + 1] = 0
            else
                itemSplit[#itemSplit + 1] = tonumber(v)
            end
        end
    end

    return itemSplit
end

function Module:GetCorruptionByItemLink(itemLink)
    local itemSplit = self:GetItemSplit(itemLink)
    local bonuses = {}

    if IsCorruptedItem(itemLink) then
        for index=1, itemSplit[13] do
            bonuses[#bonuses + 1] = itemSplit[13 + index]
        end

        -- if the item is in the EncounterJournal, add in the missing bonus
        if itemSplit[13] == 1 then
            local itemID = itemSplit[1]
            local lootBonus = DB:GetLoot(itemID)
            if lootBonus ~= nil then
                bonuses[#bonuses + 1] = lootBonus
            end
        end
    else
        local itemID = itemSplit[1]
        local purchasable = DB:GetPurchasable(itemID)
        if purchasable ~= nil then
            bonuses[#bonuses + 1] = purchasable
        end
    end

    if #bonuses > 0 then
        for _, bonusID in pairs(bonuses) do
            local name, icon, rank = GetCorruptionByID(bonusID)
            if name ~= nil then
                return name, icon, rank
            end
        end
    end
end

function Module:GetCharacterCorruptions()
    local corruptions = {}
    for slotNum=1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slotNum])
        local itemLink = GetInventoryItemLink('player', slotId)
        if itemLink then
            local name, icon, _ = self:GetCorruptionByItemLink(itemLink)
            if name ~= nil then
                corruptions[#corruptions + 1] = { name, icon }
            end
        end
    end

    return corruptions
end

function Module:GetSlots()
    return slotNames
end