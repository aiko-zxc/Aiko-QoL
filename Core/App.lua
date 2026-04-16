local addonName, ns = ...

local App = {}
ns.Core.App = App

function App:GetProfile()
    return ns.Core.Repository:GetProfile()
end

function App:Update(isInitialLogin)
    if not self.initialized then return end

    local zoneKey, zoneName = ns.Core.ZoneService:GetCurrentZone()
    local nameplatesChanged, zone = ns.Core.NameplateService:ApplyForZone(zoneKey)
    local audioChanged, audioState = ns.Core.AudioService:ApplyForZone(zoneKey)
    local profile = self:GetProfile()

    if isInitialLogin then
        return
    end

    if nameplatesChanged and profile.modules.nameplates.notifications and zone then
        ns.Core.NotificationService:PrintNameplateUpdate(zoneName, zone)
    end

    if audioChanged and profile.modules.audio.notifications and audioState then
        ns.Core.NotificationService:PrintAudioUpdate(zoneName, audioState)
    end
end

function App:InitEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ADDON_LOADED")

    frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == addonName then
            ns.Core.Repository:EnsureDB()
            if ns.UI.SettingsPanel then
                ns.UI.SettingsPanel:Register()
            end
            ns.Core.NotificationService:PrintLoadMessage()
            return
        end

        C_Timer.After(0.3, function()
            self:Update(event == "PLAYER_ENTERING_WORLD")
        end)
    end)

    self.eventFrame = frame
end

function App:Init()
    if self.initialized then return end
    ns.Core.Repository:EnsureDB()
    self:InitEvents()
    self.initialized = true
end

App:Init()
