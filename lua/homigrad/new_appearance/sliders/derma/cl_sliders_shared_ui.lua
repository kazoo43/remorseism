if SERVER then return end

hg = hg or {}
hg.Appearance = hg.Appearance or {}

local APmodule = hg.Appearance
APmodule.Sliders = APmodule.Sliders or {}

if APmodule.Sliders.__SharedUILoaded then
    APmodule.Sliders.__SharedUILoaded = nil
end
APmodule.Sliders.__SharedUILoaded = true

local colors = {}
colors.secondary = Color(25, 25, 35, 195)
colors.mainText = Color(255, 255, 255, 255)
colors.scrollbarBorder = Color(100, 100, 120, 200)

local function NormalizePanelAppearance(panel)
    if not IsValid(panel) then return nil end

    if not istable(panel.AppearanceTable) then
        panel.AppearanceTable = APmodule.NormalizeAppearanceTable({})
        return panel.AppearanceTable
    end

    local appearance = panel.AppearanceTable
    local normalized = APmodule.NormalizeAppearanceTable(appearance)
    if not istable(normalized) then
        return appearance
    end

    if normalized ~= appearance then
        for key in pairs(appearance) do
            appearance[key] = nil
        end

        for key, value in pairs(normalized) do
            appearance[key] = value
        end
    end

    panel.AppearanceTable = appearance
    return appearance
end

local function GetOwnerPanel(node)
    if not IsValid(node) then return nil end

    if IsValid(node.__HGScaleOwnerPanel) then
        return node.__HGScaleOwnerPanel
    end

    local parent = node:GetParent()
    while IsValid(parent) do
        if IsValid(parent.__HGScaleOwnerPanel) then
            return parent.__HGScaleOwnerPanel
        end

        local className = parent.GetClassName and parent:GetClassName() or ""
        local name = parent.GetName and parent:GetName() or ""
        if className == "HG_AppearanceMenu" or name == "HG_AppearanceMenu" then
            return parent
        end

        parent = parent:GetParent()
    end
end

local function FindFirstChildByClass(parent, className)
    if not IsValid(parent) or not parent.GetChildren then return nil end

    for _, child in ipairs(parent:GetChildren()) do
        if child.GetClassName and child:GetClassName() == className then
            return child
        end

        local nested = FindFirstChildByClass(child, className)
        if IsValid(nested) then
            return nested
        end
    end
end

local function LooksLikeModelPanel(panel)
    if not IsValid(panel) then return false end

    local className = panel.GetClassName and panel:GetClassName() or ""
    if className == "DModelPanel" then
        return true
    end

    if panel.SetCamPos and panel.SetLookAt and panel.SetFOV then
        return true
    end

    if panel.LayoutEntity and panel.Entity ~= nil then
        return true
    end

    return false
end

local function FindPreviewPanel(parent)
    if not IsValid(parent) or not parent.GetChildren then return nil end

    local bestPanel
    local bestArea = -1

    local function Walk(node)
        if not IsValid(node) or not node.GetChildren then return end

        for _, child in ipairs(node:GetChildren()) do
            if IsValid(child) then
                if LooksLikeModelPanel(child) then
                    local area = (child.GetWide and child:GetWide() or 0) * (child.GetTall and child:GetTall() or 0)
                    if area > bestArea then
                        bestArea = area
                        bestPanel = child
                    end
                end

                Walk(child)
            end
        end
    end

    Walk(parent)
    return bestPanel
end

local function FindButtonByText(parent, text)
    if not IsValid(parent) or not parent.GetChildren then return nil end

    for _, child in ipairs(parent:GetChildren()) do
        local isButton = (child.GetClassName and child:GetClassName() == "DButton") or child:GetName() == "DButton"
        if isButton and string.lower((child:GetText() or "")) == string.lower(text) then
            return child
        end

        local nested = FindButtonByText(child, text)
        if IsValid(nested) then
            return nested
        end
    end
end

local function FindAnchorButton(panel)
    if not IsValid(panel) then return nil end

    return FindButtonByText(panel, "Save")
        or FindButtonByText(panel, "Load")
        or FindButtonByText(panel, "Apply")
end

local function FindPanelWithButton(parent, text)
    if not IsValid(parent) or not parent.GetChildren then return nil end

    for _, child in ipairs(parent:GetChildren()) do
        local found = FindButtonByText(child, text)
        if IsValid(found) then
            return child, found
        end
    end
end

local function FindAnchorParent(panel, anchorBtn)
    if not IsValid(panel) then return nil end
    if not IsValid(anchorBtn) then return panel end

    local anchorParent = panel
    local anchorText = anchorBtn.GetText and anchorBtn:GetText() or ""
    local foundParent = anchorText ~= "" and FindPanelWithButton(panel, anchorText) or nil
    if IsValid(foundParent) then
        anchorParent = foundParent
    end

    return anchorParent
end

local function InstallPreviewScaleHook(panel, viewer)
    if not IsValid(panel) or not IsValid(viewer) or viewer.__HGSlidersPreviewHooked then return end

    viewer.__HGSlidersPreviewHooked = true
    local oldLayoutEntity = viewer.LayoutEntity

    function viewer:LayoutEntity(ent, ...)
        if isfunction(oldLayoutEntity) then
            oldLayoutEntity(self, ent, ...)
        end

        if IsValid(ent) and IsValid(panel) then
            APmodule.ApplyPreviewScale(ent, panel.AppearanceTable or {})
        end
    end
end

local function PanelHasNativeScaleUI(panel)
    local foundLabels = {}
    local sliderCount = 0

    local function Walk(node)
        if not IsValid(node) or not node.GetChildren then return end

        for _, child in ipairs(node:GetChildren()) do
            if child.GetClassName and child:GetClassName() == "DSlider" then
                sliderCount = sliderCount + 1
            elseif child.GetClassName and child:GetClassName() == "DLabel" then
                local text = string.lower(child:GetText() or "")
                if text == "height" or text == "weight" then
                    foundLabels[text] = true
                end
            end

            Walk(child)
        end
    end

    Walk(panel)

    return sliderCount >= 2 and foundLabels.height and foundLabels.weight
end

local function CreateScaleRow(parent, yPos, title, valueKey)
    local row = vgui.Create("DPanel", parent)
    row:SetPos(0, yPos)
    row:SetSize(parent:GetWide(), ScreenScale(14))

    function row:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 16, 245))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local titleLabel = vgui.Create("DLabel", row)
    titleLabel:SetPos(ScreenScale(2), 0)
    titleLabel:SetSize(ScreenScale(30), ScreenScale(10))
    titleLabel:SetFont("ZCity_Tiny")
    titleLabel:SetText(title)
    titleLabel:SetTextColor(colors.mainText)
    titleLabel:SetContentAlignment(4)

    local valueLabel = vgui.Create("DLabel", row)
    valueLabel:SetPos(ScreenScale(33), ScreenScale(3))
    valueLabel:SetSize(ScreenScale(22), ScreenScale(8))
    valueLabel:SetFont("ZCity_Tiny")
    valueLabel:SetTextColor(colors.mainText)
    valueLabel:SetContentAlignment(4)

    local slider = vgui.Create("DSlider", row)
    slider:SetPos(ScreenScale(56), ScreenScale(0))
    slider:SetSize(ScreenScale(55), ScreenScale(10))
    slider:SetTrapInside(true)

    function slider:Paint(w, h)
        draw.RoundedBox(0, 0, h / 2 - 1, w, 2, Color(25, 25, 35, 255))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, h / 2 - 1, w, 2, 1)
    end

    function slider.Knob:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, colors.secondary)
        surface.SetDrawColor(colors.mainText)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    function row:RefreshScaleRow()
        local panel = GetOwnerPanel(self)
        if not IsValid(panel) then return end

        local appearance = NormalizePanelAppearance(panel)
        local value = APmodule.NormalizeHeight(appearance[valueKey])
        appearance[valueKey] = value
        valueLabel:SetText(value .. "%")

        slider._hgLock = true
        slider:SetSlideX((value - APmodule.HeightMin) / (APmodule.HeightMax - APmodule.HeightMin))
        slider._hgLock = nil
    end

    function slider:OnValueChanged(fraction)
        if self._hgLock then return end

        local panel = GetOwnerPanel(row)
        if not IsValid(panel) then return end

        local appearance = NormalizePanelAppearance(panel)
        local value = math.Round(APmodule.HeightMin + (APmodule.HeightMax - APmodule.HeightMin) * fraction)
        value = APmodule.NormalizeHeight(value)

        self._hgLock = true
        self:SetSlideX((value - APmodule.HeightMin) / (APmodule.HeightMax - APmodule.HeightMin))
        self._hgLock = nil

        appearance[valueKey] = value
        valueLabel:SetText(value .. "%")

        local viewer = panel.__HGAppearanceScaleViewer
        if IsValid(viewer) and IsValid(viewer.Entity) then
            APmodule.ApplyPreviewScale(viewer.Entity, appearance)
        end
    end

    row:RefreshScaleRow()

    return row
end

function APmodule.Sliders.AttachScaleBlock(panel)
    if not IsValid(panel) then return false end
    if IsValid(panel.__HGAppearanceScalePanel) then
        return true
    end
    if PanelHasNativeScaleUI(panel) then
        return false
    end

    local viewer = panel.__HGAppearanceScaleViewer or FindFirstChildByClass(panel, "DModelPanel") or FindPreviewPanel(panel)
    local anchorBtn = FindAnchorButton(panel)
    if not IsValid(anchorBtn) then return false end

    NormalizePanelAppearance(panel)

    panel.__HGAppearanceScaleViewer = viewer
    InstallPreviewScaleHook(panel, viewer)

    local anchorParent = FindAnchorParent(panel, anchorBtn) or panel

    local scalePanel = vgui.Create("DPanel", anchorParent)
    scalePanel:SetSize(ScreenScale(118), ScreenScale(30))
    scalePanel.__HGScalePanel = true
    scalePanel.__HGScaleOwnerPanel = panel

    function scalePanel:Paint() end

    function scalePanel:Think()
        if not IsValid(anchorBtn) then
            anchorBtn = FindAnchorButton(panel)
        end

        if not IsValid(anchorBtn) then return end

        local screenX, screenY = anchorBtn:LocalToScreen(0, 0)
        local _, localY = anchorParent:ScreenToLocal(screenX, screenY)

        local padding = ScreenScale(8)
        local x = anchorParent:GetWide() - self:GetWide() - ScreenScale(-0)
        local y = localY - self:GetTall() + ScreenScale(-230)

        self:SetPos(
            math.max(padding, x),
            math.Clamp(y, padding, math.max(padding, anchorParent:GetTall() - self:GetTall() - padding))
        )
    end

    local heightRow = CreateScaleRow(scalePanel, 0, "Height", "AHeight")
    local weightRow = CreateScaleRow(scalePanel, ScreenScale(16), "Weight", "ABodySize")

    function scalePanel:RefreshRows()
        heightRow:RefreshScaleRow()
        weightRow:RefreshScaleRow()

        if not IsValid(viewer) then
            viewer = panel.__HGAppearanceScaleViewer or FindPreviewPanel(panel)
            panel.__HGAppearanceScaleViewer = viewer
            InstallPreviewScaleHook(panel, viewer)
        end

        if IsValid(viewer.Entity) then
            APmodule.ApplyPreviewScale(viewer.Entity, panel.AppearanceTable)
        end
    end

    panel.__HGAppearanceScalePanel = scalePanel
    panel.__HGAppearanceScaleRows = {
        heightRow = heightRow,
        weightRow = weightRow
    }

    return true
end

function APmodule.Sliders.RefreshScaleBlock(panel)
    if not IsValid(panel) or not IsValid(panel.__HGAppearanceScalePanel) then return end
    panel.__HGAppearanceScalePanel:RefreshRows()
end
