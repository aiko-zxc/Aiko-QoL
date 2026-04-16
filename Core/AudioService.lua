local addonName, ns = ...

local AudioService = {}
ns.Core.AudioService = AudioService

function AudioService:GetChannelCVar(channel)
    if channel == "music" then return "Sound_EnableMusic" end
    if channel == "effects" then return "Sound_EnableSFX" end
    if channel == "ambience" then return "Sound_EnableAmbience" end
    if channel == "dialog" then return "Sound_EnableDialog" end
end

function AudioService:GetVolumeCVar(channel)
    if channel == "master" then return "Sound_MasterVolume" end
    if channel == "music" then return "Sound_MusicVolume" end
    if channel == "effects" then return "Sound_SFXVolume" end
    if channel == "ambience" then return "Sound_AmbienceVolume" end
    if channel == "dialog" then return "Sound_DialogVolume" end
end

function AudioService:ApplyBooleanCVar(cvar, state)
    local expected = state and "1" or "0"
    if C_CVar.GetCVar(cvar) ~= expected then
        C_CVar.SetCVar(cvar, expected)
        return true
    end
    return false
end

function AudioService:ApplyVolumeCVar(cvar, value)
    local formatted = string.format("%.2f", tonumber(value) or 1)
    if C_CVar.GetCVar(cvar) ~= formatted then
        C_CVar.SetCVar(cvar, formatted)
        return true
    end
    return false
end

function AudioService:ApplyConfiguredVolumes()
    local profile = ns.Core.Repository:GetProfile()
    local volumes = profile.audio and profile.audio.volumes
    if type(volumes) ~= "table" then
        return false
    end

    local changed = false
    for _, channel in ipairs({ "master", "music", "effects", "ambience", "dialog" }) do
        local cvar = self:GetVolumeCVar(channel)
        local value = volumes[channel]
        if cvar and value ~= nil and self:ApplyVolumeCVar(cvar, value) then
            changed = true
        end
    end
    return changed
end

function AudioService:ApplyForZone(zoneKey)
    local profile = ns.Core.Repository:GetProfile()
    if not profile.modules.audio.enabled then
        return false, nil
    end

    local changed = false
    local enabledNow = {}
    local disabledNow = {}

    for _, channel in ipairs({ "music", "effects", "ambience", "dialog" }) do
        local shouldEnable = profile.audio.enabledRules[channel]
            and profile.audio.enabledRules[channel][zoneKey]
            and true or false

        local cvar = self:GetChannelCVar(channel)
        if cvar and self:ApplyBooleanCVar(cvar, shouldEnable) then
            changed = true
        end

        if shouldEnable then
            enabledNow[#enabledNow + 1] = channel
        else
            disabledNow[#disabledNow + 1] = channel
        end
    end

    return changed, { enabled = enabledNow, disabled = disabledNow }
end

function AudioService:ApplyOptimizedDefaults()
    local repo = ns.Core.Repository

    repo:Set("audio.volumes.master", 0.70)
    repo:Set("audio.volumes.music", 0.05)
    repo:Set("audio.volumes.effects", 0.05)
    repo:Set("audio.volumes.ambience", 0.05)
    repo:Set("audio.volumes.dialog", 0.05)

    repo:Set("audio.enabledRules.music.raid", false)
    repo:Set("audio.enabledRules.music.dungeon", false)
    repo:Set("audio.enabledRules.music.arena", false)
    repo:Set("audio.enabledRules.music.battleground", false)
    repo:Set("audio.enabledRules.music.openWorld", true)

    for _, channel in ipairs({ "effects", "ambience", "dialog" }) do
        repo:Set("audio.enabledRules." .. channel .. ".raid", false)
        repo:Set("audio.enabledRules." .. channel .. ".dungeon", false)
        repo:Set("audio.enabledRules." .. channel .. ".arena", true)
        repo:Set("audio.enabledRules." .. channel .. ".battleground", true)
        repo:Set("audio.enabledRules." .. channel .. ".openWorld", true)
    end

    self:ApplyConfiguredVolumes()
end
