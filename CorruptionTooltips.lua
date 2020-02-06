CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("Corruption Tooltips", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

local defaults = {
    profile = {
        append = true,
    }
}

function CorruptionTooltips:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CorruptionTooltipsDB", defaults)
end

function CorruptionTooltips:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')

    self:RegisterChatCommand("ct", "Command")
end

function CorruptionTooltips:OnDisable()
    self:UnregisterChatCommand("ct")
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

function CorruptionTooltips:CreateTooltip(self)
	local name, item = self:GetItem()
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
			if CorruptionTooltips:Append(self, line) ~= true then
                self:AddLine(" ")
                self:AddLine(line)
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
                return {
                    name.." "..R[bonus_id][2],
                    icon,
                }
            end
        end
    end
end

function CorruptionTooltips:Append(tooltip, line)
    if self.db.profile.append then
        local detected
        for i = 1, tooltip:NumLines() do
            local left = _G[tooltip:GetName().."TextLeft"..i]
            detected = string.match(left:GetText(), "+(%d+) "..L["Corruption"])
            if detected ~= nil then
                left:SetText(left:GetText().." / "..line)
                return true
            end
        end
    end
end

function CorruptionTooltips:TooltipHook(frame)
	self:CreateTooltip(frame)
end

function CorruptionTooltips:Command(args)
    if (args == "toggle") then
        self.db.profile.append = not self.db.profile.append
    end
end