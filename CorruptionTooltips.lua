CorruptionTooltips = LibStub("AceAddon-3.0"):NewAddon("CorruptionTooltips")
CorruptionTooltips.frame = CreateFrame("Frame", "CorruptionTooltipsFrame", UIParent)

-- wrapper for Narcisus fix
function CorruptionTooltips:SummaryHook(frame)
    -- Summary = CorruptionTooltips:GetModule("Summary")
    -- Summary:SummaryHook(frame)
end