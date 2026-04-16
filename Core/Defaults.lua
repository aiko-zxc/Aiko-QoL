local addonName, ns = ...

ns.Defaults = {
    version = "1.9.1",
    profile = {
        modules = {
            nameplates = { enabled = false, notifications = false },
            audio = { enabled = false, notifications = false },
        },
        zones = {
            raid = { players = false, npcs = false },
            dungeon = { players = false, npcs = false },
            arena = { players = false, npcs = false },
            battleground = { players = false, npcs = false },
            openWorld = { players = false, npcs = false },
        },
        audio = {
            enabledRules = {
                music = { raid = true, dungeon = true, arena = true, battleground = true, openWorld = true },
                effects = { raid = true, dungeon = true, arena = true, battleground = true, openWorld = true },
                ambience = { raid = true, dungeon = true, arena = true, battleground = true, openWorld = true },
                dialog = { raid = true, dungeon = true, arena = true, battleground = true, openWorld = true },
            },
            volumes = nil,
        },
    },
}
