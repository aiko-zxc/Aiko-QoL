local addonName, ns = ...

local L = ns.L

ns.UI.SettingsDescriptors = {
    nameplates = {
        moduleKey = "nameplates",
        title = L["TAB_FRIENDLY_NAMEPLATES"],
        description = L["DESC_NAMEPLATES"],
        controls = {
            { type = "checkbox", path = "modules.nameplates.enabled", label = L["MODULE_ENABLED"] },
            { type = "checkbox", path = "modules.nameplates.notifications", label = L["CHAT_NOTIFICATIONS"] },
            { type = "optimizeButton", label = L["OPTIMIZE_FRIENDLY_NAMEPLATES_SETTINGS"] },
            { type = "spacer" },
            { type = "headerRow" },
            { type = "zoneRow", label = L["RAIDS"], pathBase = "zones.raid" },
            { type = "zoneRow", label = L["DUNGEONS"], pathBase = "zones.dungeon" },
            { type = "zoneRow", label = L["ARENA"], pathBase = "zones.arena" },
            { type = "zoneRow", label = L["BATTLEGROUNDS"], pathBase = "zones.battleground" },
            { type = "zoneRow", label = L["OPEN_WORLD"], pathBase = "zones.openWorld" },
        },
    },
    audio = {
        moduleKey = "audio",
        title = L["TAB_AUDIO"],
        description = L["DESC_AUDIO"],
        controls = {
            { type = "checkbox", path = "modules.audio.enabled", label = L["MODULE_ENABLED"] },
            { type = "checkbox", path = "modules.audio.notifications", label = L["CHAT_NOTIFICATIONS"] },
            { type = "optimizeButton", label = L["OPTIMIZE_AUDIO_SETTINGS"] },
            { type = "spacer" },
            { type = "audioMatrix" },
        },
    },
}
