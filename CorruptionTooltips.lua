CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("Corruption Tooltips", "AceEvent-3.0", "AceHook-3.0")

function CorruptionTooltips:OnEnable()
    self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', 'TooltipHook')
    self:SecureHookScript(EmbeddedItemTooltip, 'OnTooltipSetItem', 'TooltipHook')
end

function CorruptionTooltips:CreateTooltip(self)
	local name, item = self:GetItem()
  	if not name then return end

  	if IsCorruptedItem(item) then

		local corruption = CorruptionTooltips:GetCorruption(self)

		if corruption then
			local name = corruption[1]
			local icon = corruption[2]
			local line = '|T'..icon..':12:12:0:0|t '.."|cff956dd1"..name.."|r"
			self:AddLine(" ")
			self:AddLine(line)
		end
	end
end

function CorruptionTooltips:GetCorruption(tooltip)
	local amount, corruption
	for i = 1, tooltip:NumLines() do
		local left = _G[tooltip:GetName().."TextLeft"..i]
		local text = left:GetText()
		local detected = string.match(text, "+(%d+) "..L["Corruption"])

		if detected and amount == nil then
			amount = detected
		end

		for j,k in pairs(R) do
			if string.find(text, L[j][2]) then
				corruption = {j, L[j][1]}
			end
		end

		if amount ~= nil and corruption ~= nil then
			if R[corruption[1]][1][amount] ~= nil then
				return {
					corruption[2].." "..R[corruption[1]][1][amount],
					R[corruption[1]][2],
				}
			else
				return {
					corruption[2].." ?",
					R[corruption[1]][2],
				}
			end
		end
	end
end

function CorruptionTooltips:TooltipHook(frame)
	self:CreateTooltip(frame)
end
