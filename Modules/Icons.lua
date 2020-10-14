local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("Icons", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

local Config, Scanner

function Module:OnInitialize()
    Config = Addon:GetModule("Config")
    Scanner = Addon:GetModule("Scanner")
    self:RegisterEvent('ADDON_LOADED', 'OnLoad')
    self:RegisterEvent('MERCHANT_SHOW', 'HookMerchant')
end

local function CreateCorruptionIcon(button, icon, rank)
    local position = Config:GetOption("iconposition")
    local color = Config:GetOption("iconcolor")
    local itemrank = Config:GetOption("itemrank")
    local offset = {
        ["TOPLEFT"] = {1, -1},
        ["TOPRIGHT"] = { -1, -1 },
        ["BOTTOMLEFT"] = { 1, 1 },
        ["BOTTOMRIGHT"] = { -1, 1 }
    }
    local iconsize = 14
    local offset_x = 2 * offset[position][1]
    local offset_y = 2 * offset[position][2]
    if itemrank ~= true then
        rank = ""
    end
    if not button.corruption then
        -- Parent
        button.corruption = CreateFrame("Frame", "$parent.corruption", button);
        button.corruption:SetPoint(position, button, position)
        button.corruption:SetSize(37, 18)
        -- Icon
        button.corruption.icon = button.corruption:CreateTexture("CorruptionIcon", "OVERLAY", button.corruption)
        button.corruption.icon:SetPoint(position, button, position, offset_x, offset_y)
        button.corruption.icon:SetSize(iconsize, iconsize)
        button.corruption.icon:SetTexture(icon)
        -- Glow Border
        button.corruption.icon.overlay = button.corruption:CreateTexture(nil, "ARTWORK", nil, 7)
        button.corruption.icon.overlay:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
        button.corruption.icon.overlay:SetVertexColor(color["r"], color["g"], color["b"], color["a"])
        button.corruption.icon.overlay:SetPoint("TOPLEFT", button.corruption.icon, -3, 3)
        button.corruption.icon.overlay:SetPoint("BOTTOMRIGHT", button.corruption.icon, 3, -3)
        button.corruption.icon.overlay:SetBlendMode("ADD")
        -- Rank
        button.corruption.rank = button.corruption:CreateFontString(nil,"ARTWORK")
        button.corruption.rank:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        if ((position == "TOPLEFT") or (position == "BOTTOMLEFT")) then
            button.corruption.rank:SetPoint("TOPLEFT", iconsize + 5, -3)
            button.corruption.rank:SetJustifyH("LEFT")
        else
            button.corruption.rank:SetPoint("TOPRIGHT", -5 - iconsize, -3)
            button.corruption.rank:SetJustifyH("RIGHT")
        end
        button.corruption.rank:SetText(rank)
    else
        button.corruption:ClearAllPoints()
        button.corruption:SetPoint(position, button, position)
        button.corruption:Show()

        button.corruption.icon:ClearAllPoints()
        button.corruption.icon:SetPoint(position, button, position, offset_x, offset_y)
        button.corruption.icon:SetTexture(icon)
        button.corruption.icon.overlay:SetVertexColor(color["r"], color["g"], color["b"], color["a"])
        if ((position == "TOPLEFT") or (position == "BOTTOMLEFT")) then
            button.corruption.rank:SetPoint("TOPLEFT", iconsize + 5, -3)
            button.corruption.rank:SetJustifyH("LEFT")
        else
            button.corruption.rank:SetPoint("TOPRIGHT", -5 - iconsize, -3)
            button.corruption.rank:SetJustifyH("RIGHT")
        end
        button.corruption.rank:SetText(rank)
    end
end

local function AddNzothIconOverlay(button)
    if Config:GetOption("nzothlabel") ~= false then
        button.IconOverlay:SetAtlas("Nzoth-inventory-icon");
        button.IconOverlay:Show();
    end
end

local function SetPaperDollCorruption(button, unit)
    Module:ClearIcon(button)

    local slotId = button:GetID()
    local textureName = GetInventoryItemTexture(unit, slotId);
    local hasItem = textureName ~= nil;

    if hasItem then
        local itemLink = GetInventoryItemLink(unit, slotId)
        Module:ApplyIcon(button, itemLink)
    end
end

local function SetEquipmentFlyoutCorruption(button)
    Module:ClearIcon(button)

    if (not button) or (not button.location) or (button.location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION) then
        return
    end

    local _, _, _, _, slot, bag = EquipmentManager_UnpackLocation(button.location)
    local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)

    if not bag then return end

    local itemLink = C_Item.GetItemLink(itemLoc)
    Module:ApplyIcon(button, itemLink)
end

local function SetContainerButtonCorruption(button, bag)
    Module:ClearIcon(button)

    -- ignore reagent bank tab
    if (bag == BANK_CONTAINER and _G.BankFrame.selectedTab == 2) then
        return
    end

    local slot = button:GetID()
    local item = Item:CreateFromBagAndSlot(bag, slot)
    if item:IsItemEmpty() then
        return
    end

    local itemLink = GetContainerItemLink(bag, slot)
    Module:ApplyIcon(button, itemLink)
end

local function SetLootCorruption(index)
    local button = _G["LootButton"..index]

    Module:ClearIcon(button)

    local numLootToShow = LOOTFRAME_NUMBUTTONS
    local slot = (numLootToShow * (LootFrame.page - 1)) + index
    if (LootSlotHasItem(slot)) then
        local itemLink = GetLootSlotLink(slot)
        Module:ApplyIcon(button, itemLink)
    end
end

function Module:OnLoad(event, ...)
    if (...) == "Blizzard_InspectUI" then
        self:UnregisterEvent(event)
        if Config:GetOption("itemicon2") ~= false then
            self:SecureHook("InspectPaperDollItemSlotButton_Update", function(button)
                SetPaperDollCorruption(button, InspectFrame.unit)
            end)
        end
    end
end

function Module:OnEnable()
    if Config:GetOption("itemicon2") ~= false then
        -- inspecing a player
        self:SecureHook("PaperDollItemSlotButton_Update", function(button)
            SetPaperDollCorruption(button, "player")
        end)
        -- wardrobe
        self:SecureHook("EquipmentFlyout_DisplayButton", function(button)
            SetEquipmentFlyoutCorruption(button)
        end)
        -- bag
        self:SecureHook("ContainerFrame_Update", function(container)
            local bag = container:GetID()
            local name = container:GetName()
            for i = 1, container.size, 1 do
                local button = _G[name .. "Item" .. i]
                SetContainerButtonCorruption(button, bag)
            end
        end)
        -- bank
        self:SecureHook("BankFrameItemButton_Update", function(button)
            if not button.isBag then
                SetContainerButtonCorruption(button, BANK_CONTAINER)
            end
        end)
        -- loot
        self:SecureHook("LootFrame_UpdateButton", function(index)
            SetLootCorruption(index)
        end)
    end
end

function Module:ApplyIcon(button, itemLink)
    if button and itemLink then
        local name, icon, rank = Scanner:GetCorruptionByItemLink(itemLink)
        if name ~= nil then
            CreateCorruptionIcon(button, icon, rank)
            if IsCorruptedItem(itemLink) then
                AddNzothIconOverlay(button)
            end
        end
    end
end

function Module:ClearIcon(button)
    if not button then return end

    if button.corruption then
        button.corruption:Hide()
    end

    if button.IconOverlay and (button.IconOverlay:GetAtlas() == "Nzoth-inventory-icon") then
        button.IconOverlay:Hide();
    end
end

function Module:HookMerchantFrame()
    self:CancelAllTimers()
    for i=1, MERCHANT_ITEMS_PER_PAGE do
        local button = _G["MerchantItem"..i.."ItemButton"]
        if button then
            local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
            self:ClearIcon(button)
            self:ScheduleTimer(function()
                local itemLink = GetMerchantItemLink(index)
                self:ApplyIcon(button, itemLink)
            end, 0.6)
        end
    end
end

function Module:HookMerchant()
    self:HookMerchantFrame()

    if _G["MerchantNextPageButton"] then
        _G["MerchantNextPageButton"]:HookScript("OnClick", function()
            self:HookMerchantFrame()
        end)
    end
    if _G["MerchantPrevPageButton"] then
        _G["MerchantPrevPageButton"]:HookScript("OnClick", function()
            self:HookMerchantFrame()
        end)
    end
    if _G["MerchantFrame"] then
        _G["MerchantFrame"]:HookScript("OnMouseWheel", function()
            self:HookMerchantFrame()
        end)
    end
end