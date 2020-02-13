local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

local myOptions =
{
    name = "Corruption Tooltips",
    type = "group",
    args =
    {
        toggle =
        {
            type = "toggle",
            name = L["Append to corruption stat"],
            desc = L["Use the new style tooltip."],
            set = function(info, val)
                CorruptionTooltips.db.profile.append = val
            end,
            get = function() return CorruptionTooltips.db.profile.append end,
            width = "full",
        },
        summary =
        {
            type = "toggle",
            name = L["Show summary on the corruption tooltip"],
            desc = L["List your corruptions in the eye tooltip in the character screen."],
            set = function(info, val)
                CorruptionTooltips.db.profile.summary = val
            end,
            get = function() return CorruptionTooltips.db.profile.summary end,
            width = "full",
        },
        english =
        {
            type = "toggle",
            name = L["Display in English"],
            desc = L["Don't translate the corruption effect names."],
            set = function(info, val)
                CorruptionTooltips.db.profile.english = val
            end,
            get = function() return CorruptionTooltips.db.profile.english end,
            width = "full",
        }
    },
}

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfig:RegisterOptionsTable("CorruptionTooltips", myOptions, {"ct"})
AceConfigDialog:AddToBlizOptions("CorruptionTooltips", "Corruption Tooltips", nil)
