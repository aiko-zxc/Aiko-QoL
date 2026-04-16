local addonName, ns = ...

local SettingsPanel = {}
ns.UI.SettingsPanel = SettingsPanel

local Controls = ns.UI.SettingsControls
local Descriptors = ns.UI.SettingsDescriptors

function SettingsPanel:CreateRegistry()
    return {
        items = {},
        RefreshAll = function(self)
            for _, item in ipairs(self.items) do
                if item.widget.Refresh then item.widget:Refresh() end
            end
            Controls:ApplyModuleStates(self)
        end,
    }
end

function SettingsPanel:CreateCanvas(name)
    local canvas = CreateFrame("Frame")
    canvas.name = name
    canvas:Hide()
    return canvas
end

function SettingsPanel:CreateScrollContainer(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(680, 1)
    scrollFrame:SetScrollChild(content)

    parent.scrollFrame = scrollFrame
    parent.content = content
    return content
end

function SettingsPanel:BuildControl(parent, moduleKey, control, y, registry)
    if control.type == "checkbox" then
        Controls:CreateModuleCheckbox(parent, control.label, control.path, y, registry, moduleKey)
        return y - 30
    end
    if control.type == "optimizeButton" then
        Controls:CreateOptimizeButton(parent, control.label, moduleKey, y, registry)
        return y - 34
    end
    if control.type == "spacer" then
        return y - 8
    end
    if control.type == "headerRow" then
        Controls:BuildZoneHeader(parent, y, registry)
        return y - 28
    end
    if control.type == "zoneRow" then
        Controls:BuildZoneRow(parent, control.label, control.pathBase, y, registry)
        return y - 32
    end
    if control.type == "audioMatrix" then
        return Controls:BuildAudioMatrix(parent, y, registry)
    end
    return y
end

function SettingsPanel:BuildSubPanel(moduleKey, descriptor)
    local panel = self:CreateCanvas(descriptor.title)
    local content = self:CreateScrollContainer(panel)
    local registry = self:CreateRegistry()

    Controls:CreateSectionTitle(content, descriptor.title, 16, -16)
    Controls:CreateDescription(content, descriptor.description, 16, -44, 620)

    local y = -96
    for _, control in ipairs(descriptor.controls) do
        y = self:BuildControl(content, moduleKey, control, y, registry)
    end

    content:SetHeight(math.abs(y) + 40)
    panel.refresh = function() registry:RefreshAll() end
    panel.registry = registry
    registry:RefreshAll()
    return panel
end

function SettingsPanel:RegisterLegacy(root, children)
    InterfaceOptions_AddCategory(root)
    for _, panel in pairs(children) do
        panel.parent = root.name
        InterfaceOptions_AddCategory(panel)
    end
end

function SettingsPanel:RegisterModern(root, children)
    local rootCategory = Settings.RegisterCanvasLayoutCategory(root, root.name, root.name)
    Settings.RegisterAddOnCategory(rootCategory)
    self.rootCategory = rootCategory

    self.categories = {}
    for key, panel in pairs(children) do
        local category = Settings.RegisterCanvasLayoutSubcategory(rootCategory, panel, panel.name, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.categories[key] = category
    end
end

function SettingsPanel:Register()
    if self.isRegistered then return end

    local root = self:CreateCanvas(ns.L["ADDON_NAME"])

    local title = root:CreateFontString(nil, "ARTWORK", "QuestTitleFont")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(ns.L["ADDON_NAME"])
    title:SetTextColor(1, 0.82, 0)

    local subtitle = root:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    subtitle:SetPoint("TOPLEFT", 16, -52)
    subtitle:SetText(ns.L["ROOT_SUBTITLE"])
    subtitle:SetTextColor(1, 0.82, 0)

    local description = root:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", 16, -84)
    description:SetWidth(650)
    description:SetJustifyH("LEFT")
    description:SetText(ns.L["ROOT_DESC"])

    local discord = root:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    discord:SetPoint("TOPLEFT", 16, -154)
    discord:SetText(ns.L["DISCORD_TAG"])
    discord:SetTextColor(0.64, 0.19, 0.79)

    local hint = root:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    hint:SetPoint("TOPLEFT", 16, -194)
    hint:SetWidth(650)
    hint:SetJustifyH("LEFT")
    hint:SetText(ns.L["ROOT_HINT"])

    root.refresh = function() end

    local panels = {
        nameplates = self:BuildSubPanel("nameplates", Descriptors.nameplates),
        audio = self:BuildSubPanel("audio", Descriptors.audio),
    }

    self.rootPanel = root
    self.panels = panels

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterCanvasLayoutSubcategory and Settings.RegisterAddOnCategory then
        self:RegisterModern(root, panels)
    elseif InterfaceOptions_AddCategory then
        self:RegisterLegacy(root, panels)
    end

    self.isRegistered = true
end

function SettingsPanel:Open()
    self:Register()

    if Settings and Settings.OpenToCategory and self.rootCategory then
        Settings.OpenToCategory(self.rootCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory and self.rootPanel then
        InterfaceOptionsFrame_OpenToCategory(self.rootPanel)
        InterfaceOptionsFrame_OpenToCategory(self.rootPanel)
    end
end

SLASH_AIKOQOL1 = "/aiko"
SLASH_AIKOQOL2 = "/aqol"
SLASH_AIKOQOL3 = "/aikoqol"
SlashCmdList["AIKOQOL"] = function()
    SettingsPanel:Open()
end
