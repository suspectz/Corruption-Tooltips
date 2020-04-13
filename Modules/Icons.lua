local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("Icons", "AceEvent-3.0", "AceHook-3.0")

local Config, Scanner

function Module:OnInitialize()
    Config = Addon:GetModule("Config")
    Scanner = Addon:GetModule("Scanner")
    self:RegisterEvent('ADDON_LOADED', 'OnLoad')

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
                local _, icon = Scanner:GetCorruptionByItemLink(itemLink)
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
        local _, icon = Scanner:GetCorruptionByItemLink(itemLink)
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
            local _, icon = Scanner:GetCorruptionByItemLink(itemLink)
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
            local _, icon = Scanner:GetCorruptionByItemLink(itemLink)
            CreateCorruptionIcon(button, icon)
        end
    end
end

function Module:OnLoad(event, ...)
    if (...) == "Blizzard_InspectUI" then
        self:UnregisterEvent(event)
        self:SecureHook("InspectPaperDollItemSlotButton_Update", function(button)
            SetPaperDollCorruption(button, "target")
        end)
    end
end

function Module:OnEnable()
    if Config:GetOption("itemicon") ~= false then
        -- inspecing a player
        self:SecureHook("PaperDollItemSlotButton_Update", function(button)
            SetPaperDollCorruption(button, "player")
        end)
        -- no idea?
        self:SecureHook("EquipmentFlyout_DisplayButton", function(button)
            SetEquipmentFlyoutCorruption(button)
        end)
        -- bag?
        self:SecureHook("ContainerFrame_Update", function(container)
            local bag = container:GetID()
            local name = container:GetName()
            for i = 1, container.size, 1 do
                local button = _G[name .. "Item" .. i]
                SetContainerButtonCorruption(button, bag)
            end
        end)
        -- bank?
        self:SecureHook("BankFrameItemButton_Update", function(button)
            if not button.isBag then
                SetContainerButtonCorruption(button, -1)
            end
        end)
        -- loot
        self:SecureHook("LootFrame_UpdateButton", function(index)
            SetLootCorruption(index)
        end)
    end
end