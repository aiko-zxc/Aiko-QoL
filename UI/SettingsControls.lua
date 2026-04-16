local addonName, ns = ...

local Controls = {}
ns.UI.SettingsControls = Controls

local Repository = ns.Core.Repository

local function RegisterWidget(registry, kind, widget, moduleKey, path)
    registry.items[#registry.items + 1] = {
        kind = kind,
        widget = widget,
        module = moduleKey,
        path = path,
    }
end

local function ResolveCheckboxTextRegion(checkbox)
    return checkbox.Text or _G[checkbox:GetName() and (checkbox:GetName() .. "Text") or ""]
end

local function CreateCheckbox(parent, label, path, x, y, registry, moduleKey)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)

    local textRegion = ResolveCheckboxTextRegion(checkbox)
    if textRegion then
        textRegion:SetText(label or "")
        textRegion:SetWidth(260)
        textRegion:SetJustifyH("LEFT")
    end

    checkbox:SetScript("OnClick", function(self)
        Repository:Set(path, self:GetChecked() and true or false)
        ns.Core.App:Update()
        if registry and registry.RefreshAll then registry:RefreshAll() end
    end)

    function checkbox:Refresh()
        self:SetChecked(Repository:Get(path) and true or false)
    end

    function checkbox:SetLogicalEnabled(enabled)
        if enabled then
            self:Enable()
            if textRegion then textRegion:SetTextColor(1, 0.82, 0) end
        else
            self:Disable()
            if textRegion then textRegion:SetTextColor(0.5, 0.5, 0.5) end
        end
    end

    RegisterWidget(registry, "checkbox", checkbox, moduleKey, path)
    return checkbox
end

function Controls:CreateSectionTitle(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

function Controls:CreateDescription(parent, text, x, y, width)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", x, y)
    fs:SetWidth(width)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetNonSpaceWrap(true)
    fs:SetText(text)
    return fs
end

function Controls:CreateHeaderText(parent, text, x, y, registry, moduleKey, template, width)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    fs:SetPoint("TOPLEFT", x, y)
    if width then fs:SetWidth(width) end
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    RegisterWidget(registry, "text", fs, moduleKey)
    return fs
end

function Controls:CreateOptimizeButton(parent, label, moduleKey, y, registry)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", 16, y)
    button:SetSize(300, 24)
    button:SetText(label)

    button:SetScript("OnClick", function()
        if moduleKey == "nameplates" then
            Repository:Set("zones.raid.players", true)
            Repository:Set("zones.raid.npcs", false)
            Repository:Set("zones.dungeon.players", true)
            Repository:Set("zones.dungeon.npcs", false)
            Repository:Set("zones.arena.players", false)
            Repository:Set("zones.arena.npcs", false)
            Repository:Set("zones.battleground.players", false)
            Repository:Set("zones.battleground.npcs", false)
            Repository:Set("zones.openWorld.players", true)
            Repository:Set("zones.openWorld.npcs", false)
        elseif moduleKey == "audio" then
            ns.Core.AudioService:ApplyOptimizedDefaults()
        end

        ns.Core.App:Update()
        if registry and registry.RefreshAll then registry:RefreshAll() end
    end)

    function button:Refresh()
        local enabled = Repository:Get("modules." .. moduleKey .. ".enabled") and true or false
        if enabled then self:Enable() else self:Disable() end
    end

    RegisterWidget(registry, "button", button, moduleKey, nil)
    return button
end

function Controls:CreateModuleCheckbox(parent, label, path, y, registry, moduleKey)
    return CreateCheckbox(parent, label, path, 16, y, registry, moduleKey)
end

function Controls:BuildZoneHeader(parent, y, registry)
    self:CreateHeaderText(parent, ns.L["ZONE"], 16, y, registry, "nameplates")
    self:CreateHeaderText(parent, ns.L["PLAYERS"], 250, y, registry, "nameplates")
    self:CreateHeaderText(parent, ns.L["NPCS"], 360, y, registry, "nameplates")
end

function Controls:BuildZoneRow(parent, label, pathBase, y, registry)
    self:CreateHeaderText(parent, label, 16, y - 4, registry, "nameplates", "GameFontHighlight", 180)
    CreateCheckbox(parent, "", pathBase .. ".players", 255, y, registry, "nameplates")
    CreateCheckbox(parent, "", pathBase .. ".npcs", 365, y, registry, "nameplates")
end

function Controls:BuildAudioMatrix(parent, y, registry)
    local L = ns.L
    local zoneDefs = {
        { key = "raid", label = L["RAID"] },
        { key = "dungeon", label = L["DUNGEON"] },
        { key = "arena", label = L["ARENA"] },
        { key = "battleground", label = L["BG"] },
        { key = "openWorld", label = L["OPEN_WORLD"] },
    }
    local channels = {
        { key = "music", label = L["MUSIC"] },
        { key = "effects", label = L["EFFECTS"] },
        { key = "ambience", label = L["AMBIENCE"] },
        { key = "dialog", label = L["DIALOG"] },
    }

    self:CreateHeaderText(parent, L["CHANNEL"], 16, y, registry, "audio", "GameFontNormal", 100)
    local startX, stepX = 128, 74
    for i, zone in ipairs(zoneDefs) do
        self:CreateHeaderText(parent, zone.label, startX + ((i - 1) * stepX), y, registry, "audio", "GameFontNormalSmall", 68)
    end

    y = y - 28
    for _, channel in ipairs(channels) do
        self:CreateHeaderText(parent, channel.label, 16, y - 4, registry, "audio", "GameFontHighlight", 100)
        for i, zone in ipairs(zoneDefs) do
            CreateCheckbox(parent, "", string.format("audio.enabledRules.%s.%s", channel.key, zone.key), startX + ((i - 1) * stepX), y, registry, "audio")
        end
        y = y - 32
    end

    return y
end

function Controls:ApplyModuleStates(registry)
    local nameplatesEnabled = Repository:Get("modules.nameplates.enabled") and true or false
    local audioEnabled = Repository:Get("modules.audio.enabled") and true or false

    for _, item in ipairs(registry.items) do
        local enabled = true
        if item.module == "nameplates" and item.path ~= "modules.nameplates.enabled" then
            enabled = nameplatesEnabled
        elseif item.module == "audio" and item.path ~= "modules.audio.enabled" then
            enabled = audioEnabled
        end

        if item.kind == "checkbox" then
            item.widget:SetLogicalEnabled(enabled)
        elseif item.kind == "text" then
            item.widget:SetTextColor(enabled and 1 or 0.5, enabled and 0.82 or 0.5, 0)
        elseif item.kind == "button" then
            if enabled then item.widget:Enable() else item.widget:Disable() end
        end
    end
end
