local addonName, _ = ...
local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("Config", "AceConsole-3.0")

local db, version, author

local defaults = {
    global = {
        perchar = true,
    },
    profile = {
        english = false,
        append = true,
        icon = true,
        summary = true,
        showlevel = false,
        nzothlabel = true,
        itemicon = false,
        iconposition = "BOTTOMLEFT",
        iconcolor = {
            ["r"] = 1.0,
            ["g"] = 0,
            ["b"] = 0,
            ["a"] = 0.8,
        }
    },
}

local function ResetConfig()
    -- todo: implement resetting config
end

function Module:GetOption(option)
    if option ~= "perchar" then
        return db.profile[option]
    else
        return db.global["perchar"]
    end
end

function Module:SetOption(option, val)
    if option ~= "perchar" then
        db.profile[option] = val
    else
        db.global[option] = val
    end
end

local function AddConfig()
    local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
    local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

    -- is's easier to reload UI to clear all frames and do less in hook functions
    StaticPopupDialogs["CorruptionTooltips_ReloadPopup"] = {
        text = L["Reload UI to apply changes?"],
        button1 = L["Reload"],
        button2 = L["Later"],
        OnAccept = function()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local options =
    {
        name = "|T"..mediaPath.."CT_logo:22:22:-1:10|tCorruption Tooltips",
        type = "group",
        args = {
            info = {
                type = "group",
                name = "",
                desc = "",
                guiInline = true,
                order = 10,
                args = {
                    version = {
                        type = "description",
                        name = L["Version"] .. ": " .. version,
                        order = 10,
                    },
                    author = {
                        type = "description",
                        name = L["Author"] .. ": " .. author .. "\n",
                        order = 20,
                    },
                },
            },
            general = {
                type = "group",
                name = "General",
                desc = "General",
                guiInline = true,
                order = 20,
                args = {
                    perchar = {
                        type = "toggle",
                        name = "Per-character configuration",
                        desc = "Per-character configuration",
                        set = function(_, val)
                            Module:SetOption("perchar", val)
                        end,
                        get = function() return Module:GetOption("perchar") end,
                        width = "full",
                        order = 10,
                    },
                    english = {
                        type = "toggle",
                        name = L["Display in English"],
                        desc = L["Don't translate the corruption effect names."],
                        set = function(_, val)
                            Module:SetOption("english", val)
                        end,
                        get = function() return Module:GetOption("english") end,
                        width = "full",
                        order = 20,
                    },
                },
            },
            tooltip = {
                type = "group",
                name = L["Item Tooltips"],
                desc = L["Item Tooltips"],
                guiInline = true,
                order = 30,
                args = {
                    toggle = {
                        type = "toggle",
                        name = L["Append to corruption stat"],
                        desc = L["Use the new style tooltip."],
                        set = function(_, val)
                            Module:SetOption("append", val)
                        end,
                        get = function() return Module:GetOption("append") end,
                        width = "full",
                        order = 10,
                    },
                    icon = {
                        type = "toggle",
                        name = L["Show icon"],
                        desc = L["Show the spell icon along with the name."],
                        set = function(_, val)
                            Module:SetOption("icon", val)
                        end,
                        get = function() return Module:GetOption("icon") end,
                        width = "full",
                        order = 20,
                    },
                },
            },
            summary = {
                type = "group",
                name = L["Summary"],
                desc = L["Summary"],
                guiInline = true,
                order = 40,
                args = {
                    summary = {
                        type = "toggle",
                        name = L["Show summary on the corruption tooltip"],
                        desc = L["List your corruptions in the eye tooltip in the character screen."],
                        set = function(_, val)
                            Module:SetOption("summary", val)
                        end,
                        get = function() return Module:GetOption("summary") end,
                        width = "full",
                        order = 10,
                    },
                    itemlevel = {
                        type = "toggle",
                        name = L["Show corruption amount in the character screen"],
                        desc = L["Show corruption stat on items in the character screen when displaying the corruption tooltip."],
                        set = function(_, val)
                            Module:SetOption("showlevel", val)
                        end,
                        get = function() return Module:GetOption("showlevel") end,
                        width = "full",
                        order = 20,
                    },
                },
            },
            icons = {
                type = "group",
                name = L["Icons"],
                desc = L["Icons"],
                guiInline = true,
                order = 50,
                args = {
                    nzothlabel = {
                        type = "toggle",
                        name = "Show nzoth label on all corrupted items",
                        desc = "",
                        set = function(_, val) end,
                        get = function() return true end,
                        width = "full",
                        order = 10,
                    },
                    itemicon = {
                        type = "toggle",
                        name = L["Show corruption icon atop of item in character screen and bags"],
                        desc = L["Show corruption icon atop of item in character screen and bags."],
                        set = function(_, val)
                            StaticPopup_Show("CorruptionTooltips_ReloadPopup")
                            Module:SetOption("itemicon", val)
                        end,
                        get = function() return Module:GetOption("itemicon") end,
                        width = "full",
                        order = 20,
                    },
                    iconposition = {
                        type = "select",
                        name = "Icon Position",
                        desc = "",
                        values = {},
                        set = function(_, val) end,
                        get = function() return "" end,
                        order = 30,
                    },
                    iconcolor = {
                        type = "color",
                        name = "Icon border color",
                        desc = "",
                        hasAlpha = false,
                        set = function(_, r, g, b, a)
                            Module:SetOption("iconcolor", { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a })
                        end,
                        get = function()
                            local color = Module:GetOption("iconcolor")
                            return color["r"], color["g"], color["b"], color["a"]
                        end,
                        width = "full",
                        order = 30,
                    }
                },
            },
        },
    }

    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfig:RegisterOptionsTable("CorruptionTooltips", options, {"ct"})
    local frame = AceConfigDialog:AddToBlizOptions("CorruptionTooltips", "Corruption Tooltips", nil)
    frame.default = ResetConfig
end

function Module:OnInitialize()
    db = LibStub("AceDB-3.0"):New("CorruptionTooltipsDB", defaults)
    version = GetAddOnMetadata(addonName, "Version")
    author = GetAddOnMetadata(addonName, "Author")
    AddConfig()
end