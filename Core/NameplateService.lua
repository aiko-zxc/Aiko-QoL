local addonName, ns = ...

local NameplateService = {}
ns.Core.NameplateService = NameplateService

function NameplateService:ApplyCVar(cvar, state)
    local expected = state and "1" or "0"
    if C_CVar.GetCVar(cvar) ~= expected then
        C_CVar.SetCVar(cvar, expected)
        return true
    end
    return false
end

function NameplateService:ApplyForZone(zoneKey)
    local profile = ns.Core.Repository:GetProfile()
    if not profile.modules.nameplates.enabled then return false, nil end

    local zone = profile.zones[zoneKey]
    if not zone then return false, nil end

    local changed = false
    if self:ApplyCVar("nameplateShowFriendlyPlayers", zone.players) then changed = true end
    if self:ApplyCVar("nameplateShowFriendlyNPCs", zone.npcs) then changed = true end
    return changed, zone
end
