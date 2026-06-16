hg.Appearance = hg.Appearance or {}
local APmodule = hg.Appearance
local PANEL = {}

local colors = {}
colors.secondary = Color(25,25,35,195)
colors.mainText = Color(255,255,255,255)
colors.secondaryText = Color(45,45,45,125)
colors.selectionBG = Color(20,130,25,225)
colors.highlightText = Color(120,35,35)
colors.presetBG = Color(35,35,45,220)
colors.presetBorder = Color(80,80,100,255)
colors.presetHover = Color(50,50,65,240)
colors.scrollbarBG = Color(20,20,30,200)
colors.scrollbarGrip = Color(70,70,90,255)
colors.scrollbarGripHover = Color(100,100,130,255)
colors.scrollbarBorder = Color(100,100,120,200)
colors.previewBorder = Color(255,200,50,255)

local presetsDir = "zcity/appearances/presets/"

local function SavePreset(strName, tblAppearance)
    file.CreateDir(presetsDir)
    file.Write(presetsDir .. strName .. ".json", util.TableToJSON(tblAppearance, true))
end

local function LoadPreset(strName)
    if not file.Exists(presetsDir .. strName .. ".json", "DATA") then return nil end
    return util.JSONToTable(file.Read(presetsDir .. strName .. ".json", "DATA"))
end

local function GetPresetList()
    file.CreateDir(presetsDir)
    local files = file.Find(presetsDir .. "*.json", "DATA")
    local presets = {}
    for _, f in ipairs(files or {}) do
        table.insert(presets, string.StripExtension(f))
    end
    return presets
end

local function DeletePreset(strName)
    if file.Exists(presetsDir .. strName .. ".json", "DATA") then
        file.Delete(presetsDir .. strName .. ".json")
        return true
    end
    return false
end

hg.Appearance.SavePreset = SavePreset
hg.Appearance.LoadPreset = LoadPreset
hg.Appearance.GetPresetList = GetPresetList
hg.Appearance.DeletePreset = DeletePreset

local modelsPrecached = false
local function PrecacheAccessoryModels()
    if modelsPrecached then return end
    modelsPrecached = true
    
    timer.Simple(0.1, function()
        if APmodule.PlayerModels then
            for _, sexModels in SortedPairs(APmodule.PlayerModels) do
                for _, modelData in SortedPairs(sexModels) do
                    if modelData.mdl then
                        util.PrecacheModel(modelData.mdl)
                    end
                end
            end
        end
        
        if hg.Accessories then
            for _, accessory in SortedPairs(hg.Accessories) do
                if accessory.model then
                    util.PrecacheModel(accessory.model)
                end
            end
        end
    end)
end


hook.Add("InitPostEntity", "HG_PrecacheAppearanceModels", function()
    timer.Simple(5, PrecacheAccessoryModels)
end)

hg.Appearance.PrecacheModels = PrecacheAccessoryModels


local function CreateStyledScrollPanel(parent)
    local scroll = vgui.Create("DScrollPanel", parent)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(ScreenScale(4))
    sbar:SetHideButtons(true)
    
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, colors.scrollbarBG)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    function sbar.btnGrip:Paint(w, h)
        local col = self:IsHovered() and colors.scrollbarGripHover or colors.scrollbarGrip
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, col)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 1)
    end
    
    return scroll
end

local clr_ico, clr_menu = Color(30, 30, 40, 255), Color(15, 15, 20, 250)
local function CreateStyledAccessoryMenu(parent, title)
    local menu = vgui.Create("DFrame")
    menu:SetTitle(title or "")
    menu:SetSize(ScreenScale(90), ScreenScale(140))
    local cx,cy = input.GetCursorPos()
    menu:SetPos(cx,cy)
    menu:MakePopup()
    menu:SetDraggable(false)
    menu:ShowCloseButton(false)
    
    menu.CurrentPreviewIcon = nil  
    
    function menu:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, clr_menu)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(10), colors.secondary, true, true, false, false)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawLine(0, ScreenScale(10), w, ScreenScale(10))
    end

    local scroll = CreateStyledScrollPanel(menu)
    scroll:Dock(FILL)
    scroll:DockMargin(ScreenScale(2), ScreenScale(2), ScreenScale(2), ScreenScale(2))

    local iconLayout = vgui.Create("DIconLayout", scroll)
    iconLayout:Dock(TOP)
    iconLayout:SetSpaceX(ScreenScale(2))
    iconLayout:SetSpaceY(ScreenScale(2))

    menu.IconLayout = iconLayout
    menu.ScrollPanel = scroll

    function menu:AddAccessoryIcon(model, accessorKey, accessoryData, onSelect, onRightClick, isPreview)
        local ico = vgui.Create("DPanel", self.IconLayout)
        local icoSize = ScreenScale(36)
        ico:SetSize(icoSize, icoSize)
        ico.Accessor = accessorKey
        ico.bIsHovered = false
        ico.IsPreviewing = false

        local spawnIcon = vgui.Create( "DModelPanel", ico )
        spawnIcon:Dock(FILL)
        spawnIcon:DockMargin(2,2,2,2)
        spawnIcon:SetModel(model or "models/error.mdl")
        spawnIcon:SetTooltip(string.NiceName(accessoryData and accessoryData.name or accessorKey))
        spawnIcon:SetFOV(15)
        spawnIcon:SetLookAt( accessoryData.vpos or Vector(0,0,0) )
        function spawnIcon:PreDrawModel(ent)
            if accessoryData.bSetColor then
                local colorDraw = accessoryData.vecColorOveride or ( lply.GetPlayerColor and lply:GetPlayerColor() or lply:GetNWVector("PlayerColor",Vector(1,1,1)) )
                render.SetColorModulation( colorDraw[1],colorDraw[2],colorDraw[3] )
            end
        end

        function spawnIcon:PostDrawModel(ent)
            if accessoryData.bSetColor then
                render.SetColorModulation( 1, 1, 1 )
            end
        end
        timer.Simple(0,function()
            spawnIcon.Entity:SetSkin((isfunction(accessoryData.skin) and accessoryData.skin()) or (accessoryData.skin or 0))
            spawnIcon.Entity:SetBodyGroups(accessoryData.bodygroups or "0000000")
            if accessoryData.SubMat then
                spawnIcon.Entity:SetSubMaterial( 0, accessoryData.SubMat )
            end
        end)

        function spawnIcon:DoClick()
            if onSelect then onSelect(accessorKey) end
            surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
            menu:Close()
        end
        
        function spawnIcon:Think()
            if onRightClick and self:IsHovered() then
                ico.IsPreviewing = true

                if ico.IsPreviewing then
                    menu.CurrentPreviewIcon = ico
                else
                    menu.CurrentPreviewIcon = nil
                end

                onRightClick(accessorKey, ico.IsPreviewing)
            end
        end

        function ico:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, clr_ico)
        end

        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self or vgui.GetHoveredPanel() == spawnIcon
        end

        return ico
    end
    
    function menu:AddNoneOption(onSelect)
        local ico = vgui.Create("DPanel", self.IconLayout)
        local icoSize = ScreenScale(36)
        ico:SetSize(icoSize, icoSize)
        ico.Accessor = "none"
        ico.bIsHovered = false
        
        function ico:Paint(w, h)
            local borderCol = self.bIsHovered and colors.scrollbarGripHover or colors.scrollbarBorder
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 255))
            surface.SetDrawColor(borderCol)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            surface.SetDrawColor(colors.highlightText)
            local margin = ScreenScale(8)
            surface.DrawLine(margin, margin, w - margin, h - margin)
            surface.DrawLine(w - margin, margin, margin, h - margin)
            
            draw.SimpleText("None", "DermaDefault", w/2, h - ScreenScale(4), colors.mainText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
        
        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self
        end
        
        function ico:OnMousePressed(mc)
            if mc == MOUSE_LEFT then
                if onSelect then onSelect("none") end
                surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
                menu:Close()
            end
        end
        
        function ico:OnCursorEntered()
            self:SetCursor("hand")
        end
        
        return ico
    end
    
    return menu
end

function PANEL:SetAppearance( tAppearacne )
    self.AppearanceTable = tAppearacne
end

function PANEL:CallbackAppearance()

end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

local sizeX, sizeY = ScrW() * 1, ScrH() * 1

local function MenuUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local gradient_d = surface.GetTextureID("vgui/gradient-d")
local gradient_l = surface.GetTextureID("vgui/gradient-l")
local gradient_r = surface.GetTextureID("vgui/gradient-r")

local appearance_color_white = Color(255,255,255,240)
local appearance_color_text = Color(225,225,225)
local appearance_color_text_dim = Color(160,160,160)
local appearance_color_dim = Color(60,60,60,180)
local appearance_clr_1 = Color(100,100,100,35)
local appearance_clr_verygray = Color(10,10,19,235)
local appearance_gradient_right = Color(18,18,18,65)
local appearance_preview_shift_x = 180
local appearance_preview_shift_y = 140
local appearance_name_width = 360
local appearance_preview_move_time = 0.25
local appearance_preview_fov = 15
local appearance_preview_cam_pos = Vector(118, 0, 60)
local appearance_preview_look_ang = Angle(11, 180, 0)
local appearance_selector_width = 360
local appearance_preview_selector_shift_x = 165
local appearance_name_fade_speed = 0.18
local appearance_return_move_time = 0.32
local appearance_header_height = 70
local appearance_unsaved_box_width = 420
local appearance_unsaved_box_height = 170
local appearance_unsaved_button_width = 140
local appearance_unsaved_button_height = 34
local appearance_unsaved_message = "You havent saved your changes."
local appearance_unsaved_fade_in_time = 0.12
local appearance_unsaved_fade_out_time = 0.1
local appearance_unsaved_box_rise = 10

local function BuildComparableAppearanceTable(tblAppearance)
    local appearance = table.Copy(tblAppearance or {})
    appearance.AAttachments = appearance.AAttachments or {}
    appearance.AAttachments[1] = appearance.AAttachments[1] or "none"
    appearance.AAttachments[2] = appearance.AAttachments[2] or "none"
    appearance.AAttachments[3] = appearance.AAttachments[3] or "none"
    appearance.AClothes = appearance.AClothes or {}
    appearance.ABodygroups = appearance.ABodygroups or {}
    if IsColor(appearance.AColor) then
        appearance.AColor = {
            r = appearance.AColor.r,
            g = appearance.AColor.g,
            b = appearance.AColor.b,
            a = appearance.AColor.a
        }
    elseif istable(appearance.AColor) then
        appearance.AColor = {
            r = appearance.AColor.r or appearance.AColor[1] or 255,
            g = appearance.AColor.g or appearance.AColor[2] or 255,
            b = appearance.AColor.b or appearance.AColor[3] or 255,
            a = appearance.AColor.a or appearance.AColor[4] or 255
        }
    else
        appearance.AColor = {
            r = 255,
            g = 255,
            b = 255,
            a = 255
        }
    end
    return appearance
end

local function AppearanceValueEqual(a, b)
    if istable(a) and istable(b) then
        for k, v in pairs(a) do
            if not AppearanceValueEqual(v, b[k]) then
                return false
            end
        end
        for k, v in pairs(b) do
            if not AppearanceValueEqual(v, a[k]) then
                return false
            end
        end
        return true
    end
    return a == b
end

local function CreateAppearanceTextButton(pParent, strTitle, fnClick, fnIsActive)
    local btn = vgui.Create("DLabel", pParent)
    btn:SetText(string.rep("#", #strTitle))
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Menu_Settings_Small")
    btn:SetTall(MenuUnit(42))
    btn:Dock(TOP)
    btn:DockMargin(MenuUnit(15), MenuUnit(2), 0, 0)
    btn.RColor = Color(225,225,225)
    btn.OpenTime = CurTime()
    btn.LineLerp = 0
    btn.HoverLerp = 0

    function btn:DoClick()
        if fnClick then
            fnClick()
        end
    end

    function btn:Think()
        local isHovered = self:IsHovered()
        local isActive = fnIsActive and fnIsActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, (isHovered or isActive) and 1 or 0)
        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local targetText = isActive and ("[ " .. strTitle .. " ]") or strTitle
        local len = #targetText
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. targetText:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    function btn:Paint(w, h)
        local isHovered = self:IsHovered()
        local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = self.RColor
        local outlineColor = Color(0, 0, 0, 255)
        if isHovered then
            local v = flash * 255
            textColor = Color(v, v, v, 255)
            local inv = 255 - v
            outlineColor = Color(inv, inv, inv, 255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * (self.HoverScale or 0.02)
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        cam.PopModelMatrix()
        return true
    end

    return btn
end

local function CreateAppearanceInfoRow(pParent, strTitle, fnValue)
    local row = vgui.Create("DPanel", pParent)
    row:Dock(TOP)
    row:SetTall(MenuUnit(56))
    row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
    row.Paint = function(self, w, h)
        surface.SetDrawColor(20, 20, 30, 120)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 90)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        draw.SimpleText(strTitle, "ZCity_Menu_Settings_Small", MenuUnit(12), MenuUnit(8), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(fnValue(), "ZCity_Menu_Settings_Tiny", MenuUnit(12), MenuUnit(31), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    return row
end

function PANEL:Paint(w,h)
    if hg.DrawBlur then hg.DrawBlur(self, 5) end
    draw.RoundedBox(0, 0, 0, w, h, appearance_clr_verygray)
    surface.SetDrawColor(appearance_gradient_right)
    surface.SetTexture(gradient_r)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(appearance_clr_verygray)
    surface.SetTexture(gradient_l)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(appearance_clr_1)
    surface.SetTexture(gradient_d)
    surface.DrawTexturedRect(0,0,w,h)
end

function PANEL:GetCurrentModelData()
    if not self.AppearanceTable then return end
    return APmodule.PlayerModels[1][self.AppearanceTable.AModel] or APmodule.PlayerModels[2][self.AppearanceTable.AModel]
end

function PANEL:SyncSharedPreview()
    local parent = self:GetParent()
    local luaMenu = IsValid(parent) and parent:GetParent()
    if not IsValid(luaMenu) or not IsValid(luaMenu.previewModel) then return end
    self.SharedMenu = luaMenu
    self.SharedPreview = luaMenu.previewModel
    self.SharedPreviewHolder = luaMenu.previewHolder
    if not self.SharedPreviewOriginal then
        local baseAppearance = luaMenu.previewModel.AppearanceTable
        if not baseAppearance and luaMenu.GetPreviewAppearance then
            baseAppearance = select(1, luaMenu:GetPreviewAppearance())
        end
        self.SharedPreviewOriginal = table.Copy(baseAppearance or self.AppearanceTable or {})
    end
    luaMenu.previewModel.AppearanceTable = self.AppearanceTable
    luaMenu.previewModel:SetVisible(true)
    luaMenu.previewModel:SetAlpha(255)
    luaMenu.previewModel.EntityAngleOverride = self.PreviewRotated and Angle(0, 180, 0) or nil
    luaMenu.previewModel.SequenceNameOverride = nil
    luaMenu.previewModel.SequencePlaybackRate = nil
    luaMenu.previewModel.ActiveSequenceName = nil
    luaMenu.previewModel.CamPosOverride = appearance_preview_cam_pos
    luaMenu.previewModel.FOVOverride = appearance_preview_fov
    luaMenu.previewModel.LookAngOverride = appearance_preview_look_ang
    if IsValid(luaMenu.previewHolder) then
        if not self.SharedPreviewHolderOriginal then
            self.SharedPreviewHolderOriginal = {
                x = luaMenu.previewHolder.TargetX or luaMenu.previewHolder:GetX(),
                y = luaMenu.previewHolder.TargetY or luaMenu.previewHolder:GetY(),
                w = luaMenu.previewHolder:GetWide(),
                h = luaMenu.previewHolder:GetTall(),
                closedY = luaMenu.previewHolder.ClosedY
            }
        end
        local targetX = (self.AppearancePreviewX or luaMenu.previewHolder:GetX()) - math.floor((self.PreviewSelectorShiftX or 0) * (self.SelectorOpenLerp or 0))
        local targetY = self.AppearancePreviewY or luaMenu.previewHolder:GetY()
        luaMenu.previewHolder.TargetX = targetX
        luaMenu.previewHolder.TargetY = targetY
        luaMenu.previewHolder.AppearanceFollow = true
        luaMenu.previewHolder:SetVisible(true)
        luaMenu.previewHolder:SetAlpha(255)
        luaMenu.previewHolder:MoveToFront()
    end
end

function PANEL:RestoreSharedPreview()
    if not IsValid(self.SharedPreview) then return end
    self.SharedPreview.AppearanceTable = table.Copy(self.SharedPreviewOriginal or self.AppearanceTable or {})
    self.SharedPreview.EntityAngleOverride = nil
    self.SharedPreview.SequenceNameOverride = nil
    self.SharedPreview.SequencePlaybackRate = nil
    self.SharedPreview.ActiveSequenceName = nil
    self.SharedPreview.CamPosOverride = nil
    self.SharedPreview.FOVOverride = nil
    self.SharedPreview.LookAngOverride = nil
    if IsValid(self.SharedPreviewHolder) and self.SharedPreviewHolderOriginal then
        self.SharedPreviewHolder.AppearanceFollow = false
        self.SharedPreviewHolder.TargetX = self.SharedPreviewHolderOriginal.x
        self.SharedPreviewHolder.TargetY = self.SharedPreviewHolderOriginal.y
        self.SharedPreviewHolder:SetSize(self.SharedPreviewHolderOriginal.w, self.SharedPreviewHolderOriginal.h)
        self.SharedPreviewHolder.ClosedY = self.SharedPreviewHolderOriginal.closedY
        self.SharedPreviewHolder:MoveTo(self.SharedPreviewHolderOriginal.x, self.SharedPreviewHolderOriginal.y, appearance_return_move_time, 0, 0, function()
            if IsValid(self.SharedPreviewHolder) then
                self.SharedPreviewHolder:SetPos(self.SharedPreviewHolderOriginal.x, self.SharedPreviewHolderOriginal.y)
            end
        end)
    end
end

function PANEL:ReturnToMenu()
    self.RestoringToMenu = true
    self.SelectorOpenLerp = 0
    self:RestoreSharedPreview()
    local parent = self:GetParent()
    local luaMenu = IsValid(parent) and parent:GetParent()
    if IsValid(luaMenu) and luaMenu.UseDefaultMenuMusic then
        luaMenu:UseDefaultMenuMusic()
    end
    if IsValid(parent) then
        parent:AlphaTo(0, 0.2, 0, function()
            if IsValid(parent) then
                parent:Remove()
            end
        end)
    end
    if IsValid(luaMenu) then
        for _, child in ipairs(luaMenu:GetChildren()) do
            if child ~= parent then
                child:SetVisible(true)
                child:AlphaTo(255, 0.2, 0)
            end
        end
        if luaMenu.ResetCurrentPanel then
            luaMenu:ResetCurrentPanel()
        end
    end
end

function PANEL:PostInit()
    local main = self
    self:SetBorder(false)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    if IsValid(self.btnClose) then
        self.btnClose:SetVisible(false)
        self.btnClose:SetMouseInputEnabled(false)
    end
    local parent = self:GetParent()
    local luaMenu = IsValid(parent) and parent:GetParent()
    if IsValid(luaMenu) and luaMenu.UseAppearanceMenuMusic then
        luaMenu:UseAppearanceMenuMusic()
    end
    self.AppearanceTable = table.Copy(self.AppearanceTable or hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString()) or APmodule.GetRandomAppearance())
    self.AppearanceTable.AAttachments = self.AppearanceTable.AAttachments or {"none", "none", "none"}
    self.AppearanceTable.AClothes = self.AppearanceTable.AClothes or {}
    self.AppearanceTable.ABodygroups = self.AppearanceTable.ABodygroups or {}
    self.AppearanceTable.AColor = self.AppearanceTable.AColor or color_white
    self.PreviewRotated = false
    self.ActiveSection = "Model"
    self.SelectorOpenLerp = 0
    self.PreviewSelectorShiftX = MenuUnit(appearance_preview_selector_shift_x)

    local nameEntry
    local previewNameLabel
    local selectorPanel
    local selectorHeaderTitle
    local selectorHeaderHint
    local selectorContent
    local currentSelectorSection
    local CloseSelectorPanel
    local savedAppearanceSnapshot
    local unsavedOverlay

    local function CloseAllAccessoryMenus()
    end

    local function AddSelectorTextRow(parent, strTitle, fnIsActive, fnClick, strTooltip)
        local row = vgui.Create("DLabel", parent)
        row:Dock(TOP)
        row:SetTall(MenuUnit(42))
        row:DockMargin(MenuUnit(12), MenuUnit(2), MenuUnit(12), 0)
        row:SetFont("ZCity_Menu_Settings_Small")
        row:SetText("")
        row:SetMouseInputEnabled(true)
        row.Title = strTitle
        if strTooltip and strTooltip != "" then
            row:SetTooltip(strTooltip)
        end
        function row:DoClick()
            if fnClick then
                fnClick()
            end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            self.LineLerp = LerpFT(0.2, self.LineLerp or 0, (self:IsHovered() or self.IsActive) and 1 or 0)
        end
        function row:Paint(w, h)
            local isHovered = self:IsHovered()
            local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
            local textColor = appearance_color_text
            local outlineColor = Color(0, 0, 0, 255)
            if self.IsActive then
                textColor = appearance_color_white
            end
            if isHovered then
                local v = flash * 255
                textColor = Color(v, v, v, 255)
                local inv = 255 - v
                outlineColor = Color(inv, inv, inv, 255)
            end
            draw.SimpleTextOutlined(self.Title, self:GetFont(), 0, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
            if self.LineLerp and self.LineLerp > 0.01 then
                surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
                local tw, th = surface.GetTextSize(self.Title)
                surface.DrawRect(0, h * 0.5 + th * 0.5, tw * self.LineLerp, math.max(1, MenuUnit(1)))
            end
            return true
        end
        return row
    end

    local function AddSelectorModelRow(parent, strTitle, modelData, fnIsActive, fnClick, strSubtitle)
        local row = vgui.Create("DButton", parent)
        row:Dock(TOP)
        row:SetTall(MenuUnit(94))
        row:DockMargin(MenuUnit(12), MenuUnit(4), MenuUnit(12), 0)
        row:SetText("")
        row:SetCursor("hand")
        row.Title = strTitle
        function row:DoClick()
            if fnClick then
                fnClick()
            end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime() * 18 * (self.HoverLerp or 0)
        end
        function row:Paint(w, h)
            local bg = self.IsActive and Color(28, 28, 38, 220) or Color(18, 18, 26, 180)
            if self:IsHovered() then
                bg = Color(34, 34, 46, 235)
            end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, self.IsActive and 180 or 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MenuUnit(86), MenuUnit(18), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(strSubtitle or (self.IsActive and "Selected" or "Model"), "ZCity_Menu_Settings_Tiny", MenuUnit(86), MenuUnit(46), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        local icon = vgui.Create("DModelPanel", row)
        icon:SetPos(MenuUnit(8), MenuUnit(8))
        icon:SetSize(MenuUnit(68), MenuUnit(78))
        icon:SetMouseInputEnabled(false)
        local iconModel = tostring(modelData and (modelData.mdl or modelData.model) or "")
        icon:SetModel(iconModel != "" and iconModel or "models/error.mdl")
        icon:SetFOV(24)
        function icon:PreDrawModel(ent)
            if modelData and modelData.bSetColor then
                local colorDraw = modelData.vecColorOveride or (lply.GetPlayerColor and lply:GetPlayerColor() or lply:GetNWVector("PlayerColor", Vector(1, 1, 1)))
                render.SetColorModulation(colorDraw[1], colorDraw[2], colorDraw[3])
            end
        end
        function icon:PostDrawModel(ent)
            if modelData and modelData.bSetColor then
                render.SetColorModulation(1, 1, 1)
            end
        end
        function icon:LayoutEntity(ent)
            ent:SetAngles(Angle(0, row.SpinAngle or 20, 0))
            if modelData and modelData.skin then
                ent:SetSkin(isfunction(modelData.skin) and modelData.skin() or modelData.skin)
            end
            if modelData and modelData.bodygroups then
                ent:SetBodyGroups(modelData.bodygroups)
            end
            if modelData and modelData.SubMat then
                ent:SetSubMaterial(0, modelData.SubMat)
            end
            local mn, mx = ent:GetRenderBounds()
            local center = (mn + mx) * 0.5
            local extents = mx - mn
            local radius = math.max(extents:Length() * 0.65, 10)
            self:SetLookAt(center)
            self:SetCamPos(center + Vector(radius * 1.7, radius * 0.3, radius * 0.08))
        end
        return row
    end

    local function AddSelectorNoneRow(parent, fnIsActive, fnClick)
        local row = vgui.Create("DButton", parent)
        row:Dock(TOP)
        row:SetTall(MenuUnit(94))
        row:DockMargin(MenuUnit(12), MenuUnit(4), MenuUnit(12), 0)
        row:SetText("")
        row:SetCursor("hand")
        function row:DoClick()
            if fnClick then
                fnClick()
            end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        end
        function row:Paint(w, h)
            local bg = self.IsActive and Color(28, 28, 38, 220) or Color(18, 18, 26, 180)
            if self:IsHovered() then
                bg = Color(34, 34, 46, 235)
            end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, self.IsActive and 180 or 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, self.IsActive and 160 or 90)
            surface.DrawOutlinedRect(MenuUnit(8), MenuUnit(8), MenuUnit(68), MenuUnit(78), 1)
            draw.SimpleText("X", "ZCity_Menu_Settings_Medium", MenuUnit(42), MenuUnit(47), appearance_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("None", "ZCity_Menu_Settings_Small", MenuUnit(86), MenuUnit(18), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(self.IsActive and "Clear slot" or "Clear slot", "ZCity_Menu_Settings_Tiny", MenuUnit(86), MenuUnit(46), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        return row
    end

    local function OpenSelectorPanel(strSection, strTitle, strHint, fnBuild)
        if not IsValid(selectorPanel) or not IsValid(selectorContent) then return end
        if currentSelectorSection == strSection and selectorPanel.TargetX == selectorPanel.OpenX then
            currentSelectorSection = nil
            main.ActiveSection = ""
            CloseSelectorPanel()
            return false
        end
        currentSelectorSection = strSection
        main.ActiveSection = strSection
        selectorContent:Clear()
        selectorHeaderTitle:SetText(string.upper(strTitle))
        selectorHeaderTitle:SizeToContents()
        selectorHeaderHint:SetText(strHint or "")
        selectorHeaderHint:SizeToContents()
        local scroll = CreateStyledScrollPanel(selectorContent)
        scroll:Dock(FILL)
        scroll.Paint = function() end
        if fnBuild then
            fnBuild(scroll)
        end
        selectorPanel.TargetX = selectorPanel.OpenX
        return true
    end

    CloseSelectorPanel = function()
        if IsValid(selectorPanel) then
            currentSelectorSection = nil
            selectorPanel.TargetX = selectorPanel.ClosedX
        end
    end

    local function GetClothesValue(key)
        return main.AppearanceTable.AClothes and main.AppearanceTable.AClothes[key] or "normal"
    end

    local function GetAttachmentValue(id)
        local value = main.AppearanceTable.AAttachments and main.AppearanceTable.AAttachments[id]
        return value and value != "" and value or "none"
    end

    local function UpdateAppearance(tbl)
        main.AppearanceTable = table.Copy(tbl or main.AppearanceTable or {})
        main.AppearanceTable.AAttachments = main.AppearanceTable.AAttachments or {"none", "none", "none"}
        main.AppearanceTable.AClothes = main.AppearanceTable.AClothes or {}
        main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
        main.AppearanceTable.AColor = main.AppearanceTable.AColor or color_white
        local modelData = main:GetCurrentModelData()
        if modelData and modelData.mdl then
            local facemapKey = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelData.mdl]
            local facemapSet = facemapKey and hg.Appearance.FacemapsSlots[facemapKey]
            if facemapSet and not facemapSet[main.AppearanceTable.AFacemap] then
                main.AppearanceTable.AFacemap = "Default"
            end
        end
        if IsValid(nameEntry) and nameEntry:GetValue() != (main.AppearanceTable.AName or "") then
            nameEntry:SetText(main.AppearanceTable.AName or "")
        end
        main:SyncSharedPreview()
    end

    local function ApplyAppearance()
        hg.Appearance.CreateAppearanceFile(hg.Appearance.SelectedAppearance:GetString(), main.AppearanceTable)
        net.Start("OnlyGet_Appearance")
            net.WriteTable(main.AppearanceTable)
        net.SendToServer()
        main.SharedPreviewOriginal = table.Copy(main.AppearanceTable)
        savedAppearanceSnapshot = BuildComparableAppearanceTable(main.AppearanceTable)
        surface.PlaySound("pwb2/weapons/iron.wav")
    end

    local function HasUnsavedChanges()
        return not AppearanceValueEqual(savedAppearanceSnapshot or {}, BuildComparableAppearanceTable(main.AppearanceTable))
    end

    local function CloseUnsavedPrompt(fnOnClosed)
        if IsValid(unsavedOverlay) then
            if unsavedOverlay.IsClosing then return end
            unsavedOverlay.IsClosing = true
            local overlay = unsavedOverlay
            local box = overlay.BoxPanel
            if IsValid(box) then
                box:MoveTo(box:GetX(), box.TargetY or box:GetY(), appearance_unsaved_fade_out_time, 0, -1)
                box:AlphaTo(0, appearance_unsaved_fade_out_time, 0)
            end
            overlay:AlphaTo(0, appearance_unsaved_fade_out_time, 0, function()
                if IsValid(overlay) then
                    overlay:Remove()
                end
                if fnOnClosed then
                    fnOnClosed()
                end
            end)
        end
        unsavedOverlay = nil
    end

    local function ShowUnsavedPrompt()
        if IsValid(unsavedOverlay) then return end
        unsavedOverlay = vgui.Create("DButton", main)
        unsavedOverlay:SetText("")
        unsavedOverlay:SetCursor("arrow")
        unsavedOverlay:SetSize(main:GetWide(), main:GetTall())
        unsavedOverlay:SetPos(0, 0)
        unsavedOverlay:SetAlpha(0)
        unsavedOverlay:MakePopup()
        unsavedOverlay.Paint = function(this, w, h)
            surface.SetDrawColor(0, 0, 0, 170)
            surface.DrawRect(0, 0, w, h)
        end

        local box = vgui.Create("DPanel", unsavedOverlay)
        box:SetSize(MenuUnit(appearance_unsaved_box_width), MenuUnit(appearance_unsaved_box_height))
        box:Center()
        box.TargetY = box:GetY()
        box:SetY(box.TargetY + MenuUnit(appearance_unsaved_box_rise))
        box:SetAlpha(0)
        box.Paint = function(this, w, h)
            surface.SetDrawColor(0, 0, 0, 245)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(appearance_unsaved_message, "ZCity_Menu_Settings_Small", w * 0.5, MenuUnit(42), appearance_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        unsavedOverlay.BoxPanel = box
        unsavedOverlay:AlphaTo(255, appearance_unsaved_fade_in_time, 0)
        box:MoveTo(box:GetX(), box.TargetY, appearance_unsaved_fade_in_time, 0, -1)
        box:AlphaTo(255, appearance_unsaved_fade_in_time, 0)

        local saveBtn = vgui.Create("DButton", box)
        saveBtn:SetSize(MenuUnit(appearance_unsaved_button_width), MenuUnit(appearance_unsaved_button_height))
        saveBtn:SetPos(MenuUnit(35), box:GetTall() - MenuUnit(56))
        saveBtn:SetText("")
        saveBtn.Paint = function(this, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText("Save", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, appearance_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        saveBtn.DoClick = function()
            ApplyAppearance()
            CloseUnsavedPrompt(function()
                main:ReturnToMenu()
            end)
        end

        local dontSaveBtn = vgui.Create("DButton", box)
        dontSaveBtn:SetSize(MenuUnit(appearance_unsaved_button_width), MenuUnit(appearance_unsaved_button_height))
        dontSaveBtn:SetPos(box:GetWide() - MenuUnit(35) - dontSaveBtn:GetWide(), box:GetTall() - MenuUnit(56))
        dontSaveBtn:SetText("")
        dontSaveBtn.Paint = function(this, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText("Dont Save", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, appearance_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        dontSaveBtn.DoClick = function()
            CloseUnsavedPrompt(function()
                main:ReturnToMenu()
            end)
        end
    end

    local function TryExitAppearance()
        CloseAllAccessoryMenus()
        if HasUnsavedChanges() then
            ShowUnsavedPrompt()
            return
        end
        main:ReturnToMenu()
    end

    local function SaveCurrentPreset()
        Derma_StringRequest("Save Preset", "Preset name", main.AppearanceTable.AName or "", function(presetName)
            if not isstring(presetName) then return end
            presetName = string.Trim(presetName)
            if presetName == "" or #presetName < 2 then
                surface.PlaySound("buttons/button10.wav")
                notification.AddLegacy("Enter a preset name (min 2 chars)", NOTIFY_ERROR, 3)
                return
            end
            presetName = string.gsub(presetName, "[^%w%s_-]", "")
            SavePreset(presetName, main.AppearanceTable)
            surface.PlaySound("buttons/button14.wav")
            notification.AddLegacy("Preset '" .. presetName .. "' saved!", NOTIFY_GENERIC, 3)
        end)
    end

    local function LoadCurrentPreset()
        local presetList = GetPresetList()
        if #presetList == 0 then
            surface.PlaySound("buttons/button10.wav")
            notification.AddLegacy("No presets saved yet!", NOTIFY_ERROR, 3)
            return
        end
        local presetMenu = vgui.Create("DFrame")
        presetMenu:SetTitle("Load Preset")
        presetMenu:SetSize(ScreenScale(120), ScreenScale(100))
        presetMenu:Center()
        presetMenu:MakePopup()
        presetMenu:SetDraggable(false)
        function presetMenu:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 28, 250))
            surface.SetDrawColor(colors.presetBorder)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(12), colors.secondary, true, true, false, false)
        end
        local scroll = CreateStyledScrollPanel(presetMenu)
        scroll:Dock(FILL)
        scroll:DockMargin(ScreenScale(2), ScreenScale(2), ScreenScale(2), ScreenScale(2))
        for _, presetName in SortedPairs(presetList) do
            local presetBtn = vgui.Create("DButton", scroll)
            presetBtn:Dock(TOP)
            presetBtn:DockMargin(2, 2, 2, 0)
            presetBtn:SetTall(ScreenScale(14))
            presetBtn:SetFont("ZCity_Menu_Tiny")
            presetBtn:SetText(presetName)
            presetBtn:SetTextColor(colors.mainText)
            function presetBtn:Paint(w, h)
                local bgCol = self:IsHovered() and colors.presetHover or colors.presetBG
                draw.RoundedBox(4, 0, 0, w, h, bgCol)
                surface.SetDrawColor(colors.scrollbarBorder)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            function presetBtn:DoClick()
                local loadedPreset = LoadPreset(presetName)
                if loadedPreset then
                    UpdateAppearance(loadedPreset)
                    surface.PlaySound("buttons/button14.wav")
                    notification.AddLegacy("Preset '" .. presetName .. "' loaded!", NOTIFY_GENERIC, 3)
                else
                    surface.PlaySound("buttons/button10.wav")
                    notification.AddLegacy("Failed to load preset!", NOTIFY_ERROR, 3)
                end
                presetMenu:Close()
            end
            function presetBtn:DoRightClick()
                local confirmMenu = DermaMenu()
                confirmMenu:AddOption("Delete '" .. presetName .. "'", function()
                    DeletePreset(presetName)
                    surface.PlaySound("buttons/button15.wav")
                    notification.AddLegacy("Preset deleted!", NOTIFY_HINT, 2)
                    presetBtn:Remove()
                end):SetIcon("icon16/cross.png")
                confirmMenu:Open()
            end
        end
    end

    local function DeleteCurrentPreset()
        Derma_StringRequest("Delete Preset", "Preset name", main.AppearanceTable.AName or "", function(presetName)
            if not isstring(presetName) then return end
            presetName = string.Trim(presetName)
            if presetName == "" then
                surface.PlaySound("buttons/button10.wav")
                notification.AddLegacy("Enter preset name to delete", NOTIFY_ERROR, 3)
                return
            end
            if DeletePreset(presetName) then
                surface.PlaySound("buttons/button15.wav")
                notification.AddLegacy("Preset '" .. presetName .. "' deleted!", NOTIFY_HINT, 3)
            else
                surface.PlaySound("buttons/button10.wav")
                notification.AddLegacy("Preset not found!", NOTIFY_ERROR, 3)
            end
        end)
    end

    local function OpenModelMenu()
        local models = {}
        for k, v in pairs(APmodule.PlayerModels[1] or {}) do
            models[k] = v
        end
        for k, v in pairs(APmodule.PlayerModels[2] or {}) do
            models[k] = v
        end
        OpenSelectorPanel("Model", "Model", "Select a player model", function(scroll)
            for k, v in SortedPairs(models) do
                AddSelectorTextRow(scroll, k, function()
                    return main.AppearanceTable.AModel == k
                end, function()
                    main.AppearanceTable.AModel = k
                    UpdateAppearance(main.AppearanceTable)
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end)
            end
        end)
    end

    local function OpenAccessorySlot(slotID, title, placements)
        OpenSelectorPanel(title, title, "Select " .. title, function(scroll)
            AddSelectorNoneRow(scroll, function()
                return GetAttachmentValue(slotID) == "none"
            end, function()
                main.AppearanceTable.AAttachments[slotID] = "none"
                main:SyncSharedPreview()
                surface.PlaySound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav")
            end)
            for k, v in SortedPairs(hg.Accessories or {}) do
                if not placements[v.placement] then continue end
                if not lply:PS_HasItem(k) and v.bPointShop and not hg.Appearance.GetAccessToAll(lply) then continue end
                AddSelectorModelRow(scroll, string.NiceName(v.name or k), v, function()
                    return GetAttachmentValue(slotID) == k
                end, function()
                    main.AppearanceTable.AAttachments[slotID] = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav")
                end, v.placement or title)
            end
        end)
    end

    local function OpenClothesMenu(key, title, includeColor)
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelectorPanel(title, title, "Select " .. title, function(scroll)
            for k, _ in SortedPairs(hg.Appearance.Clothes[modelData.sex and 2 or 1] or {}) do
                local tip = hg.Appearance.ClothesDesc[k] and hg.Appearance.ClothesDesc[k].desc or nil
                AddSelectorTextRow(scroll, k, function()
                    return GetClothesValue(key) == k
                end, function()
                    main.AppearanceTable.AClothes[key] = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end, tip)
            end
            if includeColor then
                if not IsColor(main.AppearanceTable.AColor) or (main.AppearanceTable.AColor.r == 255 and main.AppearanceTable.AColor.g == 0 and main.AppearanceTable.AColor.b == 0) then
                    main.AppearanceTable.AColor = color_white
                end
                local colorSelector = vgui.Create("DColorCombo", scroll)
                colorSelector:Dock(TOP)
                colorSelector:DockMargin(MenuUnit(12), MenuUnit(12), MenuUnit(12), MenuUnit(12))
                function colorSelector:OnValueChanged(clr)
                    main.AppearanceTable.AColor = clr
                    main:SyncSharedPreview()
                end
                colorSelector:SetColor(main.AppearanceTable.AColor)
                colorSelector.Paint = function(this, w, h)
                    surface.SetDrawColor(20, 20, 20, 240)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 120)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                    draw.SimpleText("Jacket Color", "ZCity_Menu_Settings_Tiny", MenuUnit(10), h * 0.5, appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    local clr = main.AppearanceTable.AColor or color_white
                    surface.SetDrawColor(clr.r, clr.g, clr.b, 255)
                    surface.DrawRect(w - MenuUnit(30), MenuUnit(6), MenuUnit(18), h - MenuUnit(12))
                    surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 120)
                    surface.DrawOutlinedRect(w - MenuUnit(30), MenuUnit(6), MenuUnit(18), h - MenuUnit(12), 1)
                end
            end
        end)
    end

    local function OpenGlovesMenu()
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelectorPanel("Gloves", "Gloves", "Select gloves", function(scroll)
            for k, v in SortedPairs((hg.Appearance.Bodygroups["HANDS"] and hg.Appearance.Bodygroups["HANDS"][modelData.sex and 2 or 1]) or {}) do
                if not lply:PS_HasItem(v["ID"]) and v[2] and not hg.Appearance.GetAccessToAll(lply) then continue end
                AddSelectorTextRow(scroll, k, function()
                    return (main.AppearanceTable.ABodygroups and main.AppearanceTable.ABodygroups["HANDS"]) == k
                end, function()
                    main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
                    main.AppearanceTable.ABodygroups["HANDS"] = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end)
            end
        end)
    end

    local function OpenFacemapMenu()
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        local facemapKey = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelData.mdl]
        local facemapSet = facemapKey and hg.Appearance.FacemapsSlots[facemapKey]
        if not facemapSet then return end
        OpenSelectorPanel("Facemap", "Facemap", "Select facemap", function(scroll)
            for k, _ in SortedPairs(facemapSet) do
                AddSelectorTextRow(scroll, k, function()
                    return (main.AppearanceTable.AFacemap or "Default") == k
                end, function()
                    main.AppearanceTable.AFacemap = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end)
            end
        end)
    end

    local function ToggleRotate()
        OpenSelectorPanel("Rotate", "Rotate", "Select silhouette direction", function(scroll)
            AddSelectorTextRow(scroll, "Front", function()
                return not main.PreviewRotated
            end, function()
                main.PreviewRotated = false
                main:SyncSharedPreview()
                surface.PlaySound("pwb2/weapons/iron.wav")
            end)
            AddSelectorTextRow(scroll, "Back", function()
                return main.PreviewRotated
            end, function()
                main.PreviewRotated = true
                main:SyncSharedPreview()
                surface.PlaySound("pwb2/weapons/iron.wav")
            end)
        end)
    end

    local sidebarWidth = math.floor(sizeX / 3.6)
    local sidebar = vgui.Create("DPanel", self)
    sidebar:SetSize(sidebarWidth, sizeY)
    sidebar:SetPos(0, 0)
    sidebar.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 15, 120))
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 90)
        surface.DrawRect(w - MenuUnit(1), 0, MenuUnit(1), h)
    end

    local sidebarHeader = vgui.Create("DPanel", sidebar)
    sidebarHeader:Dock(TOP)
    sidebarHeader:SetTall(MenuUnit(appearance_header_height))
    sidebarHeader.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local sidebarHeaderTitle = vgui.Create("DLabel", sidebarHeader)
    sidebarHeaderTitle:SetPos(MenuUnit(15), MenuUnit(18))
    sidebarHeaderTitle:SetFont("ZCity_Menu_Settings_Small")
    sidebarHeaderTitle:SetTextColor(appearance_color_white)
    sidebarHeaderTitle:SetText("APPEARANCE")
    sidebarHeaderTitle:SizeToContents()
    sidebarHeaderTitle.OpenTime = CurTime()
    function sidebarHeaderTitle:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local charsToShow = math.floor(elapsed * 18)
        local target = "APPEARANCE"
        local len = #target
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    local mainPanel = vgui.Create("DPanel", self)
    mainPanel:SetSize(sizeX - sidebarWidth, sizeY)
    mainPanel:SetPos(sidebarWidth, 0)
    mainPanel.Paint = function() end
    self.AppearancePreviewX = sidebarWidth + MenuUnit(appearance_preview_shift_x)
    self.AppearancePreviewY = MenuUnit(appearance_preview_shift_y)
    self:SyncSharedPreview()

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MenuUnit(appearance_header_height))
    header.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetPos(MenuUnit(25), MenuUnit(18))
    headerTitle:SetFont("ZCity_Menu_Settings_Medium")
    headerTitle:SetTextColor(appearance_color_white)
    headerTitle:SetText("YOU")
    headerTitle:SizeToContents()

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MenuUnit(25), MenuUnit(45))
    headerHint:SetFont("ZCity_Menu_Settings_Tiny")
    headerHint:SetTextColor(appearance_color_text_dim)
    headerHint:SetText("How you look.")
    headerHint:SizeToContents()

    selectorPanel = vgui.Create("DPanel", mainPanel)
    selectorPanel:SetSize(MenuUnit(appearance_selector_width), mainPanel:GetTall())
    selectorPanel.ClosedX = mainPanel:GetWide()
    selectorPanel.OpenX = mainPanel:GetWide() - selectorPanel:GetWide()
    selectorPanel.TargetX = selectorPanel.ClosedX
    selectorPanel:SetPos(selectorPanel.ClosedX, 0)
    selectorPanel.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 15, 185))
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 90)
        surface.DrawRect(0, 0, MenuUnit(1), h)
    end
    selectorPanel.Think = function(this)
        local x = this:GetX()
        local targetX = this.TargetX or x
        local nextX = LerpFT(0.18, x, targetX)
        if math.abs(targetX - nextX) < 1 then
            nextX = targetX
        end
        if not main.RestoringToMenu then
            main.SelectorOpenLerp = LerpFT(appearance_name_fade_speed, main.SelectorOpenLerp or 0, targetX == this.OpenX and 1 or 0)
            if IsValid(previewNameLabel) then
                previewNameLabel:SetAlpha(math.Round(255 * (1 - (main.SelectorOpenLerp or 0))))
            end
            if IsValid(nameEntry) then
                nameEntry:SetAlpha(math.Round(255 * (1 - (main.SelectorOpenLerp or 0))))
                nameEntry:SetMouseInputEnabled((main.SelectorOpenLerp or 0) < 0.05)
            end
            if IsValid(main.SharedPreviewHolder) then
                main.SharedPreviewHolder.TargetX = (main.AppearancePreviewX or main.SharedPreviewHolder.TargetX or main.SharedPreviewHolder:GetX()) - math.floor((main.PreviewSelectorShiftX or 0) * (main.SelectorOpenLerp or 0))
                main.SharedPreviewHolder.TargetY = main.AppearancePreviewY or main.SharedPreviewHolder.TargetY or main.SharedPreviewHolder:GetY()
            end
        end
        this:SetPos(math.Round(nextX), 0)
    end

    local selectorHeader = vgui.Create("DPanel", selectorPanel)
    selectorHeader:Dock(TOP)
    selectorHeader:SetTall(MenuUnit(appearance_header_height))
    selectorHeader.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 130))
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 100)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    selectorHeaderTitle = vgui.Create("DLabel", selectorHeader)
    selectorHeaderTitle:SetPos(MenuUnit(18), MenuUnit(18))
    selectorHeaderTitle:SetFont("ZCity_Menu_Settings_Small")
    selectorHeaderTitle:SetTextColor(appearance_color_white)
    selectorHeaderTitle:SetText("")
    selectorHeaderTitle:SizeToContents()

    selectorHeaderHint = vgui.Create("DLabel", selectorHeader)
    selectorHeaderHint:SetPos(MenuUnit(18), MenuUnit(45))
    selectorHeaderHint:SetFont("ZCity_Menu_Settings_Tiny")
    selectorHeaderHint:SetTextColor(appearance_color_text_dim)
    selectorHeaderHint:SetText("")
    selectorHeaderHint:SizeToContents()

    selectorContent = vgui.Create("DPanel", selectorPanel)
    selectorContent:Dock(FILL)
    selectorContent:DockMargin(0, 0, 0, MenuUnit(8))
    selectorContent.Paint = function() end

    previewNameLabel = vgui.Create("DLabel", mainPanel)
    previewNameLabel:SetFont("ZCity_Menu_Settings_Tiny")
    previewNameLabel:SetTextColor(appearance_color_text_dim)
    previewNameLabel:SetText("NAME")
    previewNameLabel:SizeToContents()
    previewNameLabel:SetPos(self.AppearancePreviewX - sidebarWidth, MenuUnit(86))

    nameEntry = vgui.Create("DTextEntry", mainPanel)
    nameEntry:SetSize(MenuUnit(appearance_name_width), MenuUnit(28))
    nameEntry:SetPos(self.AppearancePreviewX - sidebarWidth - MenuUnit(8), MenuUnit(102))
    nameEntry:SetFont("ZCity_Menu_Settings_Small")
    nameEntry:SetText(main.AppearanceTable.AName or "")
    nameEntry:SetUpdateOnType(true)
    nameEntry:SetContentAlignment(5)
    nameEntry.Paint = function(this, w, h)
        surface.SetDrawColor(20, 20, 20, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 120)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        this:DrawTextEntryText(color_white, Color(120, 130, 180), color_white)
    end
    function nameEntry:OnValueChange(val)
        main.AppearanceTable.AName = val
        main:SyncSharedPreview()
    end

    savedAppearanceSnapshot = BuildComparableAppearanceTable(main.AppearanceTable)

    CreateAppearanceTextButton(sidebar, "Model", function() OpenModelMenu() end, function() return main.ActiveSection == "Model" end)
    CreateAppearanceTextButton(sidebar, "Hat", function() OpenAccessorySlot(1, "Hat", {head = true, ears = true}) end, function() return main.ActiveSection == "Hat" end)
    CreateAppearanceTextButton(sidebar, "Face", function() OpenAccessorySlot(2, "Face", {face = true}) end, function() return main.ActiveSection == "Face" end)
    CreateAppearanceTextButton(sidebar, "Body", function() OpenAccessorySlot(3, "Body", {torso = true, spine = true}) end, function() return main.ActiveSection == "Body" end)
    CreateAppearanceTextButton(sidebar, "Jacket", function() OpenClothesMenu("main", "Jacket", true) end, function() return main.ActiveSection == "Jacket" end)
    CreateAppearanceTextButton(sidebar, "Pants", function() OpenClothesMenu("pants", "Pants") end, function() return main.ActiveSection == "Pants" end)
    CreateAppearanceTextButton(sidebar, "Boots", function() OpenClothesMenu("boots", "Boots") end, function() return main.ActiveSection == "Boots" end)
    CreateAppearanceTextButton(sidebar, "Gloves", function() OpenGlovesMenu() end, function() return main.ActiveSection == "Gloves" end)
    CreateAppearanceTextButton(sidebar, "Facemap", function() OpenFacemapMenu() end, function() return main.ActiveSection == "Facemap" end)

    local returnBtn = vgui.Create("DLabel", sidebar)
    returnBtn:Dock(BOTTOM)
    returnBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(20))
    returnBtn:SetFont("ZCity_Menu_Settings_Small")
    returnBtn:SetTextColor(appearance_color_text)
    returnBtn:SetText(string.rep("#", #"<- Return"))
    returnBtn:SetMouseInputEnabled(true)
    returnBtn:SizeToContents()
    returnBtn:SetTall(MenuUnit(42))
    returnBtn.OpenTime = CurTime()
    returnBtn.HoverLerp = 0
    returnBtn.LineLerp = 0
    returnBtn.HoverScale = 0.008
    function returnBtn:DoClick()
        TryExitAppearance()
    end
    function returnBtn:Think()
        local isHovered = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)
        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local target = "<- Return"
        local len = #target
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end
    function returnBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = appearance_color_text
        local outlineColor = Color(0, 0, 0, 255)
        if isHovered then
            local v = flash * 255
            textColor = Color(v, v, v, 255)
            local inv = 255 - v
            outlineColor = Color(inv, inv, inv, 255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * (self.HoverScale or 0.02)
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        cam.PopModelMatrix()
        return true
    end

    local lowerActions = vgui.Create("DPanel", sidebar)
    lowerActions:Dock(BOTTOM)
    lowerActions:DockMargin(0, 0, 0, MenuUnit(2))
    lowerActions:SetTall(MenuUnit(42) * 5 + MenuUnit(10))
    lowerActions.Paint = function() end

    local rotateBtn = CreateAppearanceTextButton(lowerActions, "Rotate", function() ToggleRotate() end, function() return main.ActiveSection == "Rotate" end)
    local applyBtn = CreateAppearanceTextButton(lowerActions, "Apply", function() main.ActiveSection = "Apply" CloseSelectorPanel() ApplyAppearance() end, function() return main.ActiveSection == "Apply" end)
    local savePresetBtn = CreateAppearanceTextButton(lowerActions, "Save Preset", function() main.ActiveSection = "Save Preset" CloseSelectorPanel() SaveCurrentPreset() end, function() return main.ActiveSection == "Save Preset" end)
    local loadPresetBtn = CreateAppearanceTextButton(lowerActions, "Load Preset", function() main.ActiveSection = "Load Preset" CloseSelectorPanel() LoadCurrentPreset() end, function() return main.ActiveSection == "Load Preset" end)
    local deletePresetBtn = CreateAppearanceTextButton(lowerActions, "Delete Preset", function() main.ActiveSection = "Delete Preset" CloseSelectorPanel() DeleteCurrentPreset() end, function() return main.ActiveSection == "Delete Preset" end)
    rotateBtn.HoverScale = 0.008
    applyBtn.HoverScale = 0.008
    savePresetBtn.HoverScale = 0.008
    loadPresetBtn.HoverScale = 0.008
    deletePresetBtn.HoverScale = 0.008

    function self:Close()
        TryExitAppearance()
    end
    self:CallbackAppearance()
end

vgui.Register( "HG_AppearanceMenu", PANEL, "ZFrame")

concommand.Add("hg_appearance_menu",function()
    print('use esc menu')
end)

function hg.CreateApperanceMenu(ParentPanel)
    if hg.Appearance.PrecacheModels then
        hg.Appearance.PrecacheModels()
    end

    hg.PointShop:SendNET( "SendPointShopVars", nil, function( data )
        if IsValid(zpan) then
            zpan:Close()
        end
        zpan = vgui.Create("HG_AppearanceMenu",ParentPanel)
        zpan:SetSize(ParentPanel:GetWide(),ParentPanel:GetTall())
        zpan:SetPos(0,0)
    end)
    
end
