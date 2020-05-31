local Addon = LibStub("AceAddon-3.0"):GetAddon("CorruptionTooltips")
local Module = Addon:NewModule("DB")

local bonuses = {
    ["6483"] = {"Avoidant", "I", 315607},
    ["6484"] = {"Avoidant", "II", 315608},
    ["6485"] = {"Avoidant", "III", 315609},
    ["6474"] = {"Expedient", "I", 315544},
    ["6475"] = {"Expedient", "II", 315545},
    ["6476"] = {"Expedient", "III", 315546},
    ["6471"] = {"Masterful", "I", 315529},
    ["6472"] = {"Masterful", "II", 315530},
    ["6473"] = {"Masterful", "III", 315531},
    ["6480"] = {"Severe", "I", 315554},
    ["6481"] = {"Severe", "II", 315557},
    ["6482"] = {"Severe", "III", 315558},
    ["6477"] = {"Versatile", "I", 315549},
    ["6478"] = {"Versatile", "II", 315552},
    ["6479"] = {"Versatile", "III", 315553},
    ["6493"] = {"Siphoner", "I", 315590},
    ["6494"] = {"Siphoner", "II", 315591},
    ["6495"] = {"Siphoner", "III", 315592},
    ["6437"] = {"Strikethrough", "I", 315277},
    ["6438"] = {"Strikethrough", "II", 315281},
    ["6439"] = {"Strikethrough", "III", 315282},
    ["6555"] = {"Racing Pulse", "I", 318266},
    ["6559"] = {"Racing Pulse", "II", 318492},
    ["6560"] = {"Racing Pulse", "III", 318496},
    ["6556"] = {"Deadly Momentum", "I", 318268},
    ["6561"] = {"Deadly Momentum", "II", 318493},
    ["6562"] = {"Deadly Momentum", "III", 318497},
    ["6558"] = {"Surging Vitality", "I", 318270},
    ["6565"] = {"Surging Vitality", "II", 318495},
    ["6566"] = {"Surging Vitality", "III", 318499},
    ["6557"] = {"Honed Mind", "I", 318269},
    ["6563"] = {"Honed Mind", "II", 318494},
    ["6564"] = {"Honed Mind", "III", 318498},
    ["6549"] = {"Echoing Void", "I", 318280},
    ["6550"] = {"Echoing Void", "II", 318485},
    ["6551"] = {"Echoing Void", "III", 318486},
    ["6552"] = {"Infinite Stars", "I", 318274},
    ["6553"] = {"Infinite Stars", "II", 318487},
    ["6554"] = {"Infinite Stars", "III", 318488},
    ["6547"] = {"Ineffable Truth", "I", 318303},
    ["6548"] = {"Ineffable Truth", "II", 318484},
    ["6537"] = {"Twilight Devastation", "I", 318276},
    ["6538"] = {"Twilight Devastation", "II", 318477},
    ["6539"] = {"Twilight Devastation", "III", 318478},
    ["6543"] = {"Twisted Appendage", "I", 318481},
    ["6544"] = {"Twisted Appendage", "II", 318482},
    ["6545"] = {"Twisted Appendage", "III", 318483},
    ["6540"] = {"Void Ritual", "I", 318286},
    ["6541"] = {"Void Ritual", "II", 318479},
    ["6542"] = {"Void Ritual", "III", 318480},
    ["6573"] = {"Gushing Wound", "", 318272},
    ["6546"] = {"Glimpse of Clarity", "", 318239},
    ["6571"] = {"Searing Flames", "", 318293},
    ["6572"] = {"Obsidian Skin", "", 316651},
    ["6567"] = {"Devour Vitality", "", 318294},
    ["6568"] = {"Whispered Truths", "", 316780},
    ["6570"] = {"Flash of Insight", "", 318299},
    ["6569"] = {"Lash of the Void", "", 317290},
}

local loot = { -- fixed loot bonuses for EncounterJournal
    ["172199"] = "6571", -- Faralos, Empire's Dream
    ["172200"] = "6572", -- Sk'shuul Vaz
    ["172191"] = "6567", -- An'zig Vra
    ["172193"] = "6568", -- Whispering Eldritch Bow
    ["172198"] = "6570", -- Mar'kowa, the Mindpiercer
    ["172197"] = "6569", -- Unguent Caress
    ["172227"] = "6544", -- Shard of the Black Empire
    ["172196"] = "6541", -- Vorzz Yoq'al
    ["174106"] = "6550", -- Qwor N'lyeth
    ["172189"] = "6548", -- Eyestalk of Il'gynoth
    ["174108"] = "6553", -- Shgla'yos, Astral Malignity
    ["172187"] = "6539", -- Devastation's Hour
}

local purchaseable = {
    ["177970"] = "6483", -- Preserved Containment: Avoidant I
    ["177971"] = "6484", -- Preserved Containment: Avoidant II
    ["177972"] = "6485", -- Preserved Containment: Avoidant III
    ["177973"] = "6474", -- Preserved Containment: Expedient I
    ["177974"] = "6475", -- Preserved Containment: Expedient II
    ["177975"] = "6476", -- Preserved Containment: Expedient III
    ["177986"] = "6471", -- Preserved Containment: Masterful I
    ["177987"] = "6472", -- Preserved Containment: Masterful II
    ["177988"] = "6473", -- Preserved Containment: Masterful III
    ["177992"] = "6480", -- Preserved Containment: Severe I
    ["177993"] = "6481", -- Preserved Containment: Severe II
    ["177994"] = "6482", -- Preserved Containment: Severe III
    ["178010"] = "6477", -- Preserved Containment: Versatile I
    ["178011"] = "6478", -- Preserved Containment: Versatile II
    ["178012"] = "6479", -- Preserved Containment: Versatile III
    ["177995"] = "6493", -- Preserved Containment: Siphoner II
    ["177996"] = "6494", -- Preserved Containment: Siphoner II
    ["177997"] = "6495", -- Preserved Containment: Siphoner III
    ["177998"] = "6437", -- Preserved Containment: Strikethrough I
    ["177999"] = "6438", -- Preserved Containment: Strikethrough II
    ["178000"] = "6439", -- Preserved Containment: Strikethrough II
    ["177989"] = "6555", -- Preserved Containment: Racing Pulse I
    ["177990"] = "6559", -- Preserved Containment: Racing Pulse II
    ["177991"] = "6560", -- Preserved Containment: Racing Pulse III
    ["177955"] = "6556", -- Preserved Containment: Deadly Momentum I
    ["177965"] = "6561", -- Preserved Containment: Deadly Momentum II
    ["177966"] = "6562", -- Preserved Containment: Deadly Momentum III
    ["178001"] = "6558", -- Preserved Containment: Surging Vitality I
    ["178002"] = "6565", -- Preserved Containment: Surging Vitality II
    ["178003"] = "6566", -- Preserved Containment: Surging Vitality III
    ["177978"] = "6557", -- Preserved Containment: Honed Mind I
    ["177979"] = "6563", -- Preserved Containment: Honed Mind II
    ["177980"] = "6564", -- Preserved Containment: Honed Mind III
    ["177969"] = "6549", -- Preserved Containment: Echoing Void I
    ["177968"] = "6550", -- Preserved Containment: Echoing Void II
    ["177967"] = "6551", -- Preserved Containment: Echoing Void III
    ["177983"] = "6552", -- Preserved Containment: Infinite Stars I
    ["177984"] = "6553", -- Preserved Containment: Infinite Stars II
    ["177985"] = "6554", -- Preserved Containment: Infinite Stars III
    ["177981"] = "6547", -- Preserved Containment: Ineffable Truth I
    ["177982"] = "6548", -- Preserved Containment: Ineffable Truth II

    ["178007"] = "6543", -- Preserved Containment: Twisted Appendage I
    ["178008"] = "6544", -- Preserved Containment: Twisted Appendage II
    ["178009"] = "6545", -- Preserved Containment: Twisted Appendage III
    ["178013"] = "6540", -- Preserved Containment: Void Ritual I
    ["178014"] = "6541", -- Preserved Containment: Void Ritual I
    ["178015"] = "6542", -- Preserved Containment: Void Ritual I
    ["177977"] = "6573", -- Preserved Containment: Gushing Wound
    ["177976"] = "6546", -- Preserved Containment: Glimpse of Clarity
}

function Module:GetBonus(bonusID)
    return bonuses[bonusID]
end

function Module:GetLoot(itemID)
    return loot[itemID]
end

function Module:GetPurchasable(itemID)
    return purchaseable[itemID]
end