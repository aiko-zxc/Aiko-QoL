local addonName, ns = ...

local Repository = {}
ns.Core.Repository = Repository

local DB_NAME = "AikoQoL_DB"
local TableUtils = ns.Core.TableUtils
local PathUtils = ns.Core.PathUtils

local function EnsureZoneTables(profile, defaults)
    TableUtils:EnsureTable(profile, "zones", defaults.profile.zones)
    for _, zone in ipairs({ "raid", "dungeon", "arena", "battleground", "openWorld" }) do
        TableUtils:EnsureTable(profile.zones, zone, defaults.profile.zones[zone])
    end
end

local function EnsureModuleTables(profile, defaults)
    TableUtils:EnsureTable(profile, "modules", defaults.profile.modules)
    TableUtils:EnsureTable(profile.modules, "nameplates", defaults.profile.modules.nameplates)
    TableUtils:EnsureTable(profile.modules, "audio", defaults.profile.modules.audio)
end

local function EnsureAudioTables(profile, defaults)
    TableUtils:EnsureTable(profile, "audio", defaults.profile.audio)
    TableUtils:EnsureTable(profile.audio, "enabledRules", defaults.profile.audio.enabledRules)

    for _, channel in ipairs({ "music", "effects", "ambience", "dialog" }) do
        TableUtils:EnsureTable(profile.audio.enabledRules, channel, defaults.profile.audio.enabledRules[channel])
    end

    if type(profile.audio.runtime) ~= "table" then
        profile.audio.runtime = nil
    end
end

function Repository:EnsureDB()
    local defaults = ns.Defaults

    if type(_G[DB_NAME]) ~= "table" then
        _G[DB_NAME] = {
            version = defaults.version,
            profile = TableUtils:DeepCopy(defaults.profile),
        }
    end

    self.db = _G[DB_NAME]

    if type(self.db.profile) ~= "table" then
        self.db.profile = TableUtils:DeepCopy(defaults.profile)
    end

    local profile = self.db.profile
    EnsureModuleTables(profile, defaults)
    EnsureZoneTables(profile, defaults)
    EnsureAudioTables(profile, defaults)

    self.db.version = defaults.version
    return self.db
end

function Repository:GetProfile()
    self:EnsureDB()
    return self.db.profile
end

function Repository:Get(path)
    local value = self:GetProfile()
    for _, key in ipairs(PathUtils:Split(path)) do
        if type(value) ~= "table" then return nil end
        value = value[key]
    end
    return value
end

function Repository:Set(path, newValue)
    local target = self:GetProfile()
    local keys = PathUtils:Split(path)

    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(target[key]) ~= "table" then
            target[key] = {}
        end
        target = target[key]
    end

    target[keys[#keys]] = newValue
end
