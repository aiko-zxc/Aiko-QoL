local addonName, ns = ...

local NotificationService = {}
ns.Core.NotificationService = NotificationService

local PREFIX_COLOR = "A330C9"

local function Colorize(text)
    return string.format("|cff%s%s|r", PREFIX_COLOR, text)
end

local function Prefix()
    return Colorize("Aiko QoL:")
end

local function JoinChannels(channels)
    if not channels or #channels == 0 then return nil end

    local names = {
        music = ns.L["MUSIC"] or "Music",
        effects = ns.L["EFFECTS"] or "Effects",
        ambience = ns.L["AMBIENCE"] or "Ambience",
        dialog = ns.L["DIALOG"] or "Dialog",
    }

    local result = {}
    for _, channel in ipairs(channels) do
        result[#result + 1] = names[channel] or channel
    end
    return table.concat(result, ", ")
end

function NotificationService:PrintLoadMessage()
    print(string.format("%s %s", Prefix(), ns.L["LOAD_MESSAGE"] or "Loaded."))
end

function NotificationService:PrintNameplateUpdate(zoneName, zone)
    local playersState = zone.players and "enabled" or "disabled"
    local npcsState = zone.npcs and "enabled" or "disabled"
    print(string.format("%s Nameplates updated for %s: friendly players %s, friendly NPCs %s.", Prefix(), zoneName, playersState, npcsState))
end

function NotificationService:PrintAudioUpdate(zoneName, state)
    local enabledText = JoinChannels(state.enabled)
    local disabledText = JoinChannels(state.disabled)

    if enabledText and disabledText then
        print(string.format("%s Audio updated for %s: enabled %s, disabled %s.", Prefix(), zoneName, enabledText, disabledText))
    elseif enabledText then
        print(string.format("%s Audio updated for %s: enabled %s.", Prefix(), zoneName, enabledText))
    elseif disabledText then
        print(string.format("%s Audio updated for %s: disabled %s.", Prefix(), zoneName, disabledText))
    end
end
