CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("Corruption Tooltips", "AceEvent-3.0", "AceHook-3.0")

function CorruptionTooltips:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')
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
			self:AddLine(" ")
			self:AddLine(line)
		end
	end
end

function CorruptionTooltips:GetCorruption(bonuses)
    if #bonuses > 0 then
        for i, bonus_id in pairs(bonuses) do
            bonus_id = tostring(bonus_id)
            if R[bonus_id] ~= nil then
                return {
                    L[R[bonus_id][1]].." "..R[bonus_id][2],
                    R[bonus_id][3],
                }
            end
        end
    end
end

function CorruptionTooltips:TooltipHook(frame)
	self:CreateTooltip(frame)
end
