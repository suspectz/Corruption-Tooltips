local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("Tooltips", "AceHook-3.0")

local Config, Scanner

function Module:OnInitialize()
    Config = Addon:GetModule("Config")
    Scanner = Addon:GetModule("Scanner")
end

function Module:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')
end

function Module:TooltipHook(tooltip)
    local name, itemLink = tooltip:GetItem()
    if not name then return end

    local corruption, icon, _ = Scanner:GetCorruptionByItemLink(itemLink)
    if corruption ~= nil then
        local line = '|T'..icon..':0|t '..'|cff956dd1'..corruption..'|r'
        if Config:GetOption("icon") ~= true then
            line = '|cff956dd1'..corruption..'|r'
        end
        if Config:GetOption("append") == true then
            for i = 1, tooltip:NumLines() do
                local left = _G[tooltip:GetName().."TextLeft"..i]
                local text = left:GetText()
                if (text ~= nil) then
                    local detected = string.find(text, ITEM_MOD_CORRUPTION)
                    if (detected ~= nil and ((strsub(text, 1, 1) == "+") or (GetLocale() == "koKR"))) then
                        left:SetText(left:GetText().." / "..line)
                        return
                    end
                end
            end
        end
        -- couldn't or shouldn't append, so add to the end
        tooltip:AddLine(" ")
        tooltip:AddLine(line)
    end
end