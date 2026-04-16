local addonName, ns = ...

local ZoneService = {}
ns.Core.ZoneService = ZoneService

function ZoneService:GetCurrentZone()
    local L = ns.L
    local _, instanceType = GetInstanceInfo()

    if instanceType == "raid" then return "raid", L["RAIDS"] end
    if instanceType == "arena" then return "arena", L["ARENA"] end
    if instanceType == "pvp" then return "battleground", L["BATTLEGROUNDS"] end
    if instanceType == "party" or instanceType == "scenario" then return "dungeon", L["DUNGEONS"] end
    return "openWorld", L["OPEN_WORLD"]
end
