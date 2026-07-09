hg.Appearance = hg.Appearance or {}
local APmodule = hg.Appearance
local PANEL = {}

local colors = {}
colors.secondary = Color(30,30,30,195)
colors.mainText = Color(240,240,240,255)
colors.secondaryText = Color(60,60,60,125)
colors.selectionBG = Color(180,180,180,225)
colors.highlightText = Color(80,80,80)
colors.presetBG = Color(40,40,40,220)
colors.presetBorder = Color(100,100,100,255)
colors.presetHover = Color(50,50,50,240)
colors.scrollbarBG = Color(25,25,25,200)
colors.scrollbarGrip = Color(80,80,80,255)
colors.scrollbarGripHover = Color(120,120,120,255)
colors.scrollbarBorder = Color(110,110,110,200)
colors.previewBorder = Color(200,200,200,255)

do
	local scale = math.min(ScrW(), ScrH()) / 1000
	surface.CreateFont("ZCity_Menu_Settings_Medium", {
		font = "IBM Plex Mono",
		size = math.max(16, math.floor(32 * scale)),
		weight = 400,
		antialias = true,
	})
	surface.CreateFont("ZCity_Menu_Settings_Small", {
		font = "IBM Plex Mono",
		size = math.max(14, math.floor(22 * scale)),
		weight = 400,
		antialias = true,
	})
	surface.CreateFont("ZCity_Menu_Settings_Tiny", {
		font = "IBM Plex Mono",
		size = math.max(12, math.floor(16 * scale)),
		weight = 400,
		antialias = true,
	})
end

local presetsDir = "zcity/appearances/presets/"
local SOUND_APPEARANCE_SUCCESS = "ui/rem_success.wav"

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
        draw.RoundedBox(4, 0, 0, w, h, Color(18, 16, 14, 220))
        surface.SetDrawColor(100, 90, 78, 180)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    function sbar.btnGrip:Paint(w, h)
        local col = self:IsHovered() and Color(130, 120, 105, 240) or Color(90, 82, 70, 240)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, col)
        surface.SetDrawColor(130, 120, 105, 200)
        surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 1)
    end
    
    return scroll
end

local clr_ico, clr_menu = Color(26, 24, 20, 255), Color(14, 13, 11, 250)
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
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(10), Color(22, 20, 17, 220), true, true, false, false)
        surface.SetDrawColor(appearance_color_white.r, appearance_color_white.g, appearance_color_white.b, 60)
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
        spawnIcon:SetAmbientLight(Color(80, 80, 80))
        spawnIcon:SetDirectionalLight(BOX_TOP, Color(120, 120, 120))
        spawnIcon:SetDirectionalLight(BOX_RIGHT, Color(100, 100, 100))
        spawnIcon:SetDirectionalLight(BOX_LEFT, Color(100, 100, 100))
        spawnIcon:SetDirectionalLight(BOX_FRONT, Color(90, 90, 90))
        spawnIcon:SetDirectionalLight(BOX_BACK, Color(90, 90, 90))
        spawnIcon:SetDirectionalLight(BOX_BOTTOM, Color(60, 60, 60))
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
            if not IsValid(spawnIcon) or not IsValid(spawnIcon.Entity) then return end
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
    self:SetAlpha(255)

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

local appearance_color_white = Color(240,240,240,240)
local appearance_color_text = Color(220,220,220)
local appearance_color_text_dim = Color(140,140,140)
local appearance_color_dim = Color(50,50,50,180)
local appearance_clr_1 = Color(80,80,80,35)
local appearance_clr_verygray = Color(12,12,12,235)
local appearance_gradient_right = Color(15,15,15,65)

local appearance_accent = Color(225, 225, 225, 255)       -- bright accent (near white)
local appearance_accent_dim = Color(150, 150, 150, 120)   -- dim accent for borders
local appearance_accent_faint = Color(200, 200, 200, 60)  -- faint accent for lines
local appearance_panel_hi = Color(60, 60, 60, 235)        -- hovered panel bg
local appearance_panel_act = Color(48, 48, 48, 220)       -- active panel bg
local appearance_panel_bg = Color(28, 28, 28, 180)        -- idle panel bg
local appearance_panel_border = Color(180, 180, 180, 90)  -- unified panel border

local appearance_gold = appearance_accent
local appearance_gold_dim = appearance_accent_dim
local appearance_silver = Color(200, 200, 200, 255)
local appearance_dark_bg = Color(8, 8, 8, 255)

local appearance_preview_shift_x = 180
local appearance_preview_shift_y = 140
local appearance_name_width = 360
local appearance_preview_move_time = 0.25
local appearance_preview_fov = 15
local appearance_preview_cam_pos = Vector(118, 0, 60)
local appearance_preview_look_ang = Angle(11, 180, 0)

local appearance_thumb_fov = 24
local appearance_thumb_cam_pos = Vector(60, 0, 35)
local appearance_thumb_look_at = Vector(0, 0, 30)

-- camera overrides
local appearance_thumb_presets = {
    main   = { fov = 50, cam_pos = Vector(57, 0, 40), look_at = Vector(0, 0, 30) },
    pants  = { fov = 50, cam_pos = Vector(57, 0, 40), look_at = Vector(0, 0, 30) },
    boots  = { fov = 22, cam_pos = Vector(30, 0, 5),  look_at = Vector(0, 0, 5) },
    HANDS  = { fov = 50, cam_pos = Vector(57, 0, 40), look_at = Vector(0, 0, 30) },
    TORSO  = { fov = 50, cam_pos = Vector(57, 0, 40), look_at = Vector(0, 0, 30) },
    LEGS   = { fov = 50, cam_pos = Vector(57, 0, 40), look_at = Vector(0, 0, 30) },
    Hat   = { fov = 10, cam_pos = Vector(25, 0, 10), look_at = Vector(0, 0, 10) },
    Face  = { fov = 6,  cam_pos = Vector(20, 0, 8),  look_at = Vector(0, 0, 8) },
    Body  = { fov = 10, cam_pos = Vector(35, 0, 15), look_at = Vector(0, 0, 15) },
    Hair  = { fov = 10, cam_pos = Vector(25, 0, 12), look_at = Vector(0, 0, 12) },
    Mask  = { fov = 6,  cam_pos = Vector(20, 0, 8),  look_at = Vector(0, 0, 8) },
    ["Body 2"] = { fov = 10, cam_pos = Vector(35, 0, 15), look_at = Vector(0, 0, 15) },
}

local function GetThumbPreset(section)
    local p = appearance_thumb_presets[section]
    if not p then return appearance_thumb_fov, appearance_thumb_cam_pos, appearance_thumb_look_at end
    return p.fov or appearance_thumb_fov, p.cam_pos or appearance_thumb_cam_pos, p.look_at or appearance_thumb_look_at
end

-- shared: apply full appearance + optional override to a DModelPanel entity
local function ApplyAppearanceToModel(ent, modelData, tbl, overrideKey, overrideMat, overrideBgKey, overrideBgID)
    if not modelData then return end
    local sexID = modelData.sex and 2 or 1

    -- apply all current clothes
    local clothes = tbl.AClothes or {}
    for ck, slotMat in SortedPairs(modelData.submatSlots or {}) do
        local clothKey = clothes[ck]
        local clothMat = clothKey and hg.Appearance.Clothes[sexID] and hg.Appearance.Clothes[sexID][clothKey]
        if clothMat then
            local mats = ent:GetMaterials()
            for i = 1, #mats do
                if mats[i] == slotMat then
                    ent:SetSubMaterial(i - 1, clothMat)
                    break
                end
            end
        end
    end

    -- override previewed clothing
    if overrideKey and overrideMat then
        local matSlot = modelData.submatSlots and modelData.submatSlots[overrideKey]
        if matSlot then
            local mats = ent:GetMaterials()
            for i = 1, #mats do
                if mats[i] == matSlot then
                    ent:SetSubMaterial(i - 1, overrideMat)
                    break
                end
            end
        end
    end

    -- apply all current bodygroups
    local bgs = tbl.ABodygroups or {}
    for bgk, bgv in pairs(bgs) do
        local bgEntry = hg.Appearance.Bodygroups[bgk] and hg.Appearance.Bodygroups[bgk][sexID] and hg.Appearance.Bodygroups[bgk][sexID][bgv]
        if bgEntry then
            local bgStr = istable(bgEntry) and bgEntry[1] or nil
            if bgStr then
                local modelBGs = ent:GetBodyGroups()
                for bgIdx, bgData in ipairs(modelBGs) do
                    for subIdx = 0, #bgData.submodels do
                        if bgData.submodels[subIdx] == bgStr then
                            ent:SetBodygroup(bgIdx - 1, subIdx)
                            break
                        end
                    end
                end
            end
        end
    end

    -- override previewed bodygroup
    if overrideBgKey and overrideBgID then
        local modelBGs = ent:GetBodyGroups()
        for bgIdx, bgData in ipairs(modelBGs) do
            for subIdx = 0, #bgData.submodels do
                if bgData.submodels[subIdx] == overrideBgID then
                    ent:SetBodygroup(bgIdx - 1, subIdx)
                    break
                end
            end
        end
    end
end

-- shared: create a full-appearance thumbnail DModelPanel in a row
local function CreateThumbnailIcon(row, section, modelData, fnExtraSetup)
    local preset = appearance_thumb_presets[section]
    local fov = preset and preset.fov or appearance_thumb_fov
    local camPos = preset and preset.cam_pos or appearance_thumb_cam_pos
    local lookAt = preset and preset.look_at or appearance_thumb_look_at

    local icon = vgui.Create("DModelPanel", row)
    icon:SetPos(MenuUnit(8), MenuUnit(8))
    icon:SetSize(MenuUnit(68), MenuUnit(78))
    icon:SetMouseInputEnabled(false)
    icon:SetModel(modelData.mdl)
    icon:SetFOV(fov)
    icon:SetCamPos(camPos)
    icon:SetLookAt(lookAt)
    icon:SetAmbientLight(Color(80, 80, 80))
    icon:SetDirectionalLight(BOX_TOP, Color(120, 120, 120))
    icon:SetDirectionalLight(BOX_RIGHT, Color(100, 100, 100))
    icon:SetDirectionalLight(BOX_LEFT, Color(100, 100, 100))
    icon:SetDirectionalLight(BOX_FRONT, Color(90, 90, 90))
    icon:SetDirectionalLight(BOX_BACK, Color(90, 90, 90))
    icon:SetDirectionalLight(BOX_BOTTOM, Color(60, 60, 60))

    function icon:PreDrawModel(ent) end
    function icon:PostDrawModel(ent) end
    function icon:LayoutEntity(ent)
        ent:SetAngles(Angle(0, row.SpinAngle or 20, 0))
        ent:SetSequence(ent:LookupSequence("mp_storage_1h_medium"))
        fnExtraSetup(ent)
        self:SetLookAt(lookAt)
    end
    return icon
end
local appearance_selector_width = 360
local appearance_preview_selector_shift_x = 165
local appearance_name_fade_speed = 0.18
local appearance_return_move_time = 0.32
local appearance_header_height = 70
local appearance_panel_slide_speed = 8
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
    for i = 1, 6 do
        appearance.AAttachments[i] = appearance.AAttachments[i] or "none"
    end
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
    btn:SetFont("ZCity_Menu_Settings_Medium")
    btn:SetTall(MenuUnit(54))
    btn:Dock(TOP)
    btn:DockMargin(MenuUnit(15), MenuUnit(4), 0, 0)
    btn.RColor = Color(225,225,225)
    btn.OpenTime = CurTime()
    btn.StartDelay = 0
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
        local elapsed = CurTime() - self.OpenTime - self.StartDelay
        if elapsed < 0 then
            if self:GetText() ~= "" then self:SetText("") end
            return
        end
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
        local textColor = appearance_color_text
        if isHovered then
            textColor = Color(235, 225, 210, 255)
        end
        if self.IsActive then
            textColor = appearance_accent
        end

        if self.IsActive then
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 220)
            surface.DrawRect(0, MenuUnit(6), MenuUnit(3), h - MenuUnit(12))
        end

        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * (self.HoverScale or 0.02)
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        if isHovered or self.IsActive then
            draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        else
            draw.SimpleText(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 200 * self.LineLerp)
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
        surface.SetDrawColor(25, 25, 25, 120)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(140, 140, 140, 70)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        draw.SimpleText(strTitle, "ZCity_Menu_Settings_Small", MenuUnit(12), MenuUnit(8), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(fnValue(), "ZCity_Menu_Settings_Tiny", MenuUnit(12), MenuUnit(31), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    return row
end

function PANEL:Paint(w,h)
	if hg.DrawBlur then hg.DrawBlur(self, 5) end
	draw.RoundedBox(0, 0, 0, w, h, appearance_dark_bg)

	local t = RealTime()
	for i = 0, h, 64 do
		for j = 0, w, 64 do
			local n = math.sin(j * 12.9898 + i * 78.233 + t * 0.008) * 43758.5453
			n = n - math.floor(n)
		local alpha = 1 + n * 3
		local v = 80 + n * 30
		surface.SetDrawColor(v, v, v, alpha)
		surface.DrawRect(j, i, 64, 64)
		end
	end

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(80, 80, 80, 15)
	surface.SetTexture(gradient_r)
	surface.DrawTexturedRect(0,0,w,h)
	surface.SetDrawColor(20, 20, 20, 80)
	surface.SetTexture(gradient_l)
	surface.DrawTexturedRect(0,0,w,h)

	surface.SetDrawColor(100, 100, 100, 40)
	surface.DrawRect(0, 0, w, 1)
	surface.DrawRect(0, h - 1, w, 1)
	surface.DrawRect(0, 0, 1, h)
	surface.DrawRect(w - 1, 0, 1, h)
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
    luaMenu.previewModel.EntityAngleOverride = Angle(0, self.PreviewRotation or 0, 0)
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
    if IsValid(luaMenu) then
        for _, child in ipairs(luaMenu:GetChildren()) do
            if child ~= parent then
                child:SetAlpha(255)
                child:SetVisible(true)
            end
        end
        if luaMenu.ResetCurrentPanel then
            luaMenu:ResetCurrentPanel()
        end
    end
    if IsValid(parent) then
        parent:Remove()
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
    self.AppearanceTable.AAttachments = self.AppearanceTable.AAttachments or {"none", "none", "none", "none", "none", "none"}
    self.AppearanceTable.AClothes = self.AppearanceTable.AClothes or {}
    self.AppearanceTable.ABodygroups = self.AppearanceTable.ABodygroups or {}
    self.AppearanceTable.AColor = self.AppearanceTable.AColor or color_white
    self.AppearanceTable.AHeight = APmodule.NormalizeHeight(self.AppearanceTable.AHeight)
    self.AppearanceTable.ABodySize = APmodule.NormalizeHeight(self.AppearanceTable.ABodySize)
    self.PreviewRotation = 0
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
                textColor = appearance_accent
                surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 40)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 180)
                surface.DrawRect(0, MenuUnit(6), MenuUnit(3), h - MenuUnit(12))
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
            if fnClick then fnClick() end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime() * 18 * (self.HoverLerp or 0)
        end
        function row:Paint(w, h)
            local bg = self.IsActive and appearance_panel_act or appearance_panel_bg
            if self:IsHovered() then bg = appearance_panel_hi end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, self.IsActive and 180 or 90)
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
        icon:SetFOV(15)
        icon:SetAmbientLight(Color(80, 80, 80))
        icon:SetDirectionalLight(BOX_TOP, Color(120, 120, 120))
        icon:SetDirectionalLight(BOX_RIGHT, Color(100, 100, 100))
        icon:SetDirectionalLight(BOX_LEFT, Color(100, 100, 100))
        icon:SetDirectionalLight(BOX_FRONT, Color(90, 90, 90))
        icon:SetDirectionalLight(BOX_BACK, Color(90, 90, 90))
        icon:SetDirectionalLight(BOX_BOTTOM, Color(60, 60, 60))
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
            self:SetLookAt(modelData and modelData.vpos or Vector(0, 0, 0))
        end
        return row
    end

    local function AddSelectorClothingRow(parent, strTitle, clothingKey, clothingMat, fnIsActive, fnClick, strSubtitle)
        local modelData = main:GetCurrentModelData()
        if not modelData then return AddSelectorTextRow(parent, strTitle, fnIsActive, fnClick, strSubtitle) end
        local row = vgui.Create("DButton", parent)
        row:Dock(TOP)
        row:SetTall(MenuUnit(94))
        row:DockMargin(MenuUnit(12), MenuUnit(4), MenuUnit(12), 0)
        row:SetText("")
        row:SetCursor("hand")
        row.Title = strTitle
        function row:DoClick()
            if fnClick then fnClick() end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime() * 18 * (self.HoverLerp or 0)
        end
        function row:Paint(w, h)
            local bg = self.IsActive and appearance_panel_act or appearance_panel_bg
            if self:IsHovered() then bg = appearance_panel_hi end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, self.IsActive and 180 or 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MenuUnit(86), MenuUnit(18), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(strSubtitle or (self.IsActive and "Selected" or "Clothes"), "ZCity_Menu_Settings_Tiny", MenuUnit(86), MenuUnit(46), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        CreateThumbnailIcon(row, clothingKey or "main", modelData, function(ent)
            ApplyAppearanceToModel(ent, modelData, main.AppearanceTable, clothingKey, clothingMat, nil, nil)
        end)
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
            local bg = self.IsActive and appearance_panel_act or appearance_panel_bg
            if self:IsHovered() then
                bg = appearance_panel_hi
            end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, self.IsActive and 180 or 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, self.IsActive and 150 or 90)
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
        main.AppearanceTable.AAttachments = main.AppearanceTable.AAttachments or {"none", "none", "none", "none", "none", "none"}
        main.AppearanceTable.AClothes = main.AppearanceTable.AClothes or {}
        main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
        main.AppearanceTable.AColor = main.AppearanceTable.AColor or color_white
        main.AppearanceTable.AHeight = APmodule.NormalizeHeight(main.AppearanceTable.AHeight)
        main.AppearanceTable.ABodySize = APmodule.NormalizeHeight(main.AppearanceTable.ABodySize)
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
        surface.PlaySound(SOUND_APPEARANCE_SUCCESS)
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
            surface.SetDrawColor(14, 13, 11, 250)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            draw.SimpleText(appearance_unsaved_message, "ZCity_Menu_Settings_Small", w * 0.5, MenuUnit(42), appearance_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            surface.SetDrawColor(22, 20, 17, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 180)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText("Save", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, appearance_gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            surface.SetDrawColor(22, 20, 17, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 180)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText("Dont Save", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, appearance_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            draw.RoundedBox(8, 0, 0, w, h, Color(16, 14, 12, 250))
            surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 140)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(12), Color(22, 20, 17, 220), true, true, false, false)
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
                local bgCol = self:IsHovered() and Color(34, 32, 28, 240) or Color(22, 20, 17, 220)
                draw.RoundedBox(4, 0, 0, w, h, bgCol)
                surface.SetDrawColor(appearance_gold_dim.r, appearance_gold_dim.g, appearance_gold_dim.b, 120)
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

    local function GetAccessoryDisplayName(accessoryKey)
        if not accessoryKey or accessoryKey == "" or accessoryKey == "none" then
            return nil
        end
        local data = hg.Accessories and hg.Accessories[accessoryKey]
        if data and data.name and data.name != "" then
            return tostring(data.name)
        end
        return string.NiceName(tostring(accessoryKey))
    end

    local function GetColorableEquippedAccessories()
        local result, seen = {}, {}
        for _, accessoryKey in ipairs(main.AppearanceTable.AAttachments or {}) do
            local data = hg.Accessories and hg.Accessories[accessoryKey]
            if data and data.bSetColor and not seen[accessoryKey] then
                seen[accessoryKey] = true
                table.insert(result, accessoryKey)
            end
        end
        return result
    end

    local function OpenAccessoryColorMenu()
        local colorable = GetColorableEquippedAccessories()

        OpenSelectorPanel("Acc. Tint", "Acc. Tint", "Accessory Color", function(scroll)
            if #colorable == 0 then
                local infoLabel = vgui.Create("DLabel", scroll)
                infoLabel:Dock(TOP)
                infoLabel:DockMargin(MenuUnit(8), MenuUnit(8), MenuUnit(8), MenuUnit(8))
                infoLabel:SetFont("ZCity_Menu_Settings_Tiny")
                infoLabel:SetTextColor(appearance_color_text_dim)
                infoLabel:SetText("Equip an accessory with color support to tint it.")
                infoLabel:SizeToContents()
                return
            end

            local targetKey = colorable[1]

            local function getTargetColor()
                local base = main.AppearanceTable.AColor or color_white
                local stored = main.AppearanceTable.AAttachmentColors and main.AppearanceTable.AAttachmentColors[targetKey]
                if IsColor(stored) then return stored end
                if istable(stored) and stored.r and stored.g and stored.b then
                    return Color(stored.r, stored.g, stored.b)
                end
                return base
            end

            local selectLabel = vgui.Create("DLabel", scroll)
            selectLabel:Dock(TOP)
            selectLabel:DockMargin(MenuUnit(8), MenuUnit(8), MenuUnit(8), MenuUnit(4))
            selectLabel:SetFont("ZCity_Menu_Settings_Tiny")
            selectLabel:SetTextColor(appearance_color_text)
            selectLabel:SetText("Select accessory:")
            selectLabel:SizeToContents()

            local accessoryPicker = vgui.Create("DComboBox", scroll)
            accessoryPicker:Dock(TOP)
            accessoryPicker:DockMargin(MenuUnit(8), MenuUnit(4), MenuUnit(8), MenuUnit(8))
            accessoryPicker:SetTall(MenuUnit(24))
            for _, key in ipairs(colorable) do
                accessoryPicker:AddChoice(GetAccessoryDisplayName(key) or key, key, key == targetKey)
            end
            accessoryPicker:SetValue(GetAccessoryDisplayName(targetKey) or targetKey)

            local mixer = vgui.Create("DColorMixer", scroll)
            mixer:Dock(TOP)
            mixer:DockMargin(MenuUnit(8), MenuUnit(4), MenuUnit(8), MenuUnit(8))
            mixer:SetTall(MenuUnit(180))
            mixer:SetPalette(false)
            mixer:SetAlphaBar(false)
            mixer:SetWangs(true)
            mixer:SetColor(getTargetColor())

            main.AppearanceTable.AAttachmentColors = main.AppearanceTable.AAttachmentColors or {}
            function mixer:ValueChanged(clr)
                main.AppearanceTable.AAttachmentColors[targetKey] = IsColor(clr) and clr or Color(clr.r, clr.g, clr.b)
            end

            function accessoryPicker:OnSelect(index, value, data)
                targetKey = data
                mixer:SetColor(getTargetColor())
            end

            local resetBtn = vgui.Create("DButton", scroll)
            resetBtn:Dock(TOP)
            resetBtn:DockMargin(MenuUnit(8), MenuUnit(4), MenuUnit(8), MenuUnit(8))
            resetBtn:SetTall(MenuUnit(28))
            resetBtn:SetText("Reset Color")
            resetBtn:SetFont("ZCity_Menu_Settings_Tiny")
            function resetBtn:Paint(w, h)
                surface.SetDrawColor(22, 20, 17, 220)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                draw.SimpleText("Reset Color", "ZCity_Menu_Settings_Tiny", w * 0.5, h * 0.5, appearance_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function resetBtn:DoClick()
                if not main.AppearanceTable.AAttachmentColors then
                    main.AppearanceTable.AAttachmentColors = {}
                end
                main.AppearanceTable.AAttachmentColors[targetKey] = nil
                mixer:SetColor(main.AppearanceTable.AColor or color_white)
            end
        end)
    end

    local function OpenClothesMenu(key, title, includeColor)
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelectorPanel(title, title, "Select " .. title, function(scroll)
            local clothes = hg.Appearance.Clothes[modelData.sex and 2 or 1] or {}
            for k, mat in SortedPairs(clothes) do
                if type(mat) != "string" then continue end
                local tip = hg.Appearance.ClothesDesc[k] and hg.Appearance.ClothesDesc[k].desc or nil
                AddSelectorClothingRow(scroll, k, key, mat, function()
                    return GetClothesValue(key) == k
                end, function()
                    main.AppearanceTable.AClothes[key] = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end, tip)
            end
            if includeColor then
                if not IsColor(main.AppearanceTable.AColor) then
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
                    surface.SetDrawColor(16, 15, 13, 245)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 100)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                    draw.SimpleText("Jacket Color", "ZCity_Menu_Settings_Tiny", MenuUnit(10), h * 0.5, appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    local clr = main.AppearanceTable.AColor or color_white
                    surface.SetDrawColor(clr.r, clr.g, clr.b, 255)
                    surface.DrawRect(w - MenuUnit(30), MenuUnit(6), MenuUnit(18), h - MenuUnit(12))
                    surface.SetDrawColor(appearance_gold.r, appearance_gold.g, appearance_gold.b, 100)
                    surface.DrawOutlinedRect(w - MenuUnit(30), MenuUnit(6), MenuUnit(18), h - MenuUnit(12), 1)
                end
            end
        end)
    end

    local function AddSelectorBodygroupRow(parent, strTitle, bgKey, bgStringID, fnIsActive, fnClick, strSubtitle)
        local modelData = main:GetCurrentModelData()
        if not modelData then return AddSelectorTextRow(parent, strTitle, fnIsActive, fnClick, strSubtitle) end
        local row = vgui.Create("DButton", parent)
        row:Dock(TOP)
        row:SetTall(MenuUnit(94))
        row:DockMargin(MenuUnit(12), MenuUnit(4), MenuUnit(12), 0)
        row:SetText("")
        row:SetCursor("hand")
        row.Title = strTitle
        function row:DoClick()
            if fnClick then fnClick() end
        end
        function row:Think()
            self.IsActive = fnIsActive and fnIsActive() or false
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime() * 18 * (self.HoverLerp or 0)
        end
        function row:Paint(w, h)
            local bg = self.IsActive and appearance_panel_act or appearance_panel_bg
            if self:IsHovered() then bg = appearance_panel_hi end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, self.IsActive and 180 or 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MenuUnit(86), MenuUnit(18), appearance_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(strSubtitle or (self.IsActive and "Selected" or "Bodygroup"), "ZCity_Menu_Settings_Tiny", MenuUnit(86), MenuUnit(46), appearance_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        CreateThumbnailIcon(row, bgKey or "main", modelData, function(ent)
            ApplyAppearanceToModel(ent, modelData, main.AppearanceTable, nil, nil, bgKey, bgStringID)
        end)
        return row
    end

    local function OpenBodygroupMenu(bgKey, title)
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelectorPanel(title, title, "Select " .. title, function(scroll)
            for k, v in SortedPairs((hg.Appearance.Bodygroups[bgKey] and hg.Appearance.Bodygroups[bgKey][modelData.sex and 2 or 1]) or {}) do
                local bgID = istable(v) and v[1] or nil
                AddSelectorBodygroupRow(scroll, k, bgKey, bgID, function()
                    return (main.AppearanceTable.ABodygroups and main.AppearanceTable.ABodygroups[bgKey]) == k
                end, function()
                    main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
                    main.AppearanceTable.ABodygroups[bgKey] = k
                    main:SyncSharedPreview()
                    surface.PlaySound("player/weapon_draw_0" .. math.random(2, 5) .. ".wav")
                end)
            end
        end)
    end

    local function OpenGlovesMenu()
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelectorPanel("Gloves", "Gloves", "Select gloves", function(scroll)
            for k, v in SortedPairs((hg.Appearance.Bodygroups["HANDS"] and hg.Appearance.Bodygroups["HANDS"][modelData.sex and 2 or 1]) or {}) do
                if not lply:PS_HasItem(v["ID"]) and v[2] and not hg.Appearance.GetAccessToAll(lply) then continue end
                local bgID = istable(v) and v[1] or nil
                AddSelectorBodygroupRow(scroll, k, "HANDS", bgID, function()
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

    local sidebarWidth = math.floor(sizeX / 3.6)
    local sidebar = vgui.Create("DScrollPanel", self)
    sidebar:SetSize(sidebarWidth, sizeY)
    local sbar = sidebar:GetVBar()
    sbar:SetWide(ScreenScale(4))
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(18, 18, 18, 200))
    end
    function sbar.btnGrip:Paint(w, h)
        local col = self:IsHovered() and Color(200, 200, 200, 240) or Color(140, 140, 140, 240)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, col)
    end
    sidebar:SetPos(-sidebarWidth, 0)
    sidebar.TargetX = 0
    sidebar.Think = function(this)
        local x, y = this:GetPos()
        local targetX = this.TargetX or x
        local nextX = Lerp(FrameTime() * appearance_panel_slide_speed, x, targetX)
        if math.abs(targetX - nextX) < 1 then
            nextX = targetX
        end
        this:SetPos(math.Round(nextX), y)
    end
    sidebar.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 220))
        surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 60)
        surface.DrawRect(w - MenuUnit(1), 0, MenuUnit(1), h)
    end

    local sidebarHeader = vgui.Create("DPanel", self)
    sidebarHeader:SetSize(sidebarWidth, MenuUnit(appearance_header_height))
    sidebarHeader:SetPos(0, 0)
    sidebarHeader.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(24, 24, 24, 210))
        surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 120)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    do
        local topSpacer = vgui.Create("DPanel", sidebar)
        topSpacer:Dock(TOP)
        topSpacer:SetTall(MenuUnit(appearance_header_height))
        topSpacer.Paint = function() end
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
    mainPanel:SetPos(sizeX, 0)
    mainPanel.TargetX = sidebarWidth
    mainPanel.Think = function(this)
        local x, y = this:GetPos()
        local targetX = this.TargetX or x
        local nextX = Lerp(FrameTime() * appearance_panel_slide_speed, x, targetX)
        if math.abs(targetX - nextX) < 1 then
            nextX = targetX
        end
        this:SetPos(math.Round(nextX), y)
    end
    mainPanel.Paint = function() end
    self.AppearancePreviewX = sidebarWidth + MenuUnit(appearance_preview_shift_x)
    self.AppearancePreviewY = MenuUnit(appearance_preview_shift_y)
    self:SyncSharedPreview()

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MenuUnit(appearance_header_height))
    header.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(24, 24, 24, 210))
        surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 120)
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
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 230))
        surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 60)
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
        draw.RoundedBox(0, 0, 0, w, h, Color(24, 24, 24, 210))
        surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 120)
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
        draw.RoundedBox(4, 0, 0, w, h, Color(16, 16, 16, 245))
        local col = this:HasFocus() and appearance_accent or appearance_accent_dim
        surface.SetDrawColor(col.r, col.g, col.b, 180)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        this:DrawTextEntryText(Color(235, 235, 235), Color(140, 140, 140), appearance_accent)
    end
    function nameEntry:OnValueChange(val)
        main.AppearanceTable.AName = val
        main:SyncSharedPreview()
    end

    do
        local rotPanel = vgui.Create("DPanel", mainPanel)
        rotPanel:SetSize(MenuUnit(300), MenuUnit(36))
        rotPanel:SetPos(mainPanel:GetWide() / 2 - MenuUnit(150), mainPanel:GetTall() - MenuUnit(50))
        rotPanel.Paint = function(this, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(22, 22, 22, 210))
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 80)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local rotLabel = vgui.Create("DLabel", rotPanel)
        rotLabel:SetPos(MenuUnit(6), MenuUnit(2))
        rotLabel:SetSize(MenuUnit(40), MenuUnit(32))
        rotLabel:SetFont("ZCity_Menu_Settings_Tiny")
        rotLabel:SetTextColor(appearance_color_text_dim)
        rotLabel:SetText("Rotate")
        rotLabel:SizeToContents()

        local rotSlider = vgui.Create("DSlider", rotPanel)
        rotSlider:SetPos(MenuUnit(44), MenuUnit(12))
        rotSlider:SetSize(MenuUnit(210), MenuUnit(12))
        rotSlider:SetTrapInside(true)
        function rotSlider:Paint(w, h)
            draw.RoundedBox(4, 0, h * 0.5 - 4, w, 8, Color(40, 40, 40, 220))
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 90)
            surface.DrawOutlinedRect(0, h * 0.5 - 4, w, 8, 1)
        end
        function rotSlider.Knob:Paint(w, h)
            draw.RoundedBox(4, 2, MenuUnit(1), w - 4, h - MenuUnit(2), appearance_accent)
            surface.SetDrawColor(255, 255, 255, 160)
            surface.DrawOutlinedRect(2, MenuUnit(1), w - 4, h - MenuUnit(2), 1)
        end
        function rotSlider:OnValueChanged(fraction)
            main.PreviewRotation = fraction * 360
            main:SyncSharedPreview()
        end

        local rotVal = vgui.Create("DLabel", rotPanel)
        rotVal:SetPos(MenuUnit(258), MenuUnit(2))
        rotVal:SetSize(MenuUnit(36), MenuUnit(32))
        rotVal:SetFont("ZCity_Menu_Settings_Tiny")
        rotVal:SetTextColor(appearance_color_text_dim)
        rotVal:SetText("0" .. string.upper("°"))
        rotVal:SetContentAlignment(6)
        function rotSlider:OnValueChanged(fraction)
            main.PreviewRotation = fraction * 360
            rotVal:SetText(tostring(math.Round(main.PreviewRotation)) .. string.upper("°"))
            main:SyncSharedPreview()
        end
        rotSlider:SetSlideX(0)
    end

    savedAppearanceSnapshot = BuildComparableAppearanceTable(main.AppearanceTable)

    CreateAppearanceTextButton(sidebar, "Model", function() OpenModelMenu() end, function() return main.ActiveSection == "Model" end)
    CreateAppearanceTextButton(sidebar, "Hat", function() OpenAccessorySlot(1, "Hat", {head = true, ears = true}) end, function() return main.ActiveSection == "Hat" end)
    CreateAppearanceTextButton(sidebar, "Face", function() OpenAccessorySlot(2, "Face", {face = true}) end, function() return main.ActiveSection == "Face" end)
    CreateAppearanceTextButton(sidebar, "Body", function() OpenAccessorySlot(3, "Body", {torso = true, spine = true}) end, function() return main.ActiveSection == "Body" end)
    CreateAppearanceTextButton(sidebar, "Hair", function() OpenAccessorySlot(4, "Hair", {head1 = true}) end, function() return main.ActiveSection == "Hair" end)
    CreateAppearanceTextButton(sidebar, "Mask", function() OpenAccessorySlot(5, "Mask", {face2 = true}) end, function() return main.ActiveSection == "Mask" end)
    CreateAppearanceTextButton(sidebar, "Body 2", function() OpenAccessorySlot(6, "Body 2", {spine2 = true}) end, function() return main.ActiveSection == "Body 2" end)
    CreateAppearanceTextButton(sidebar, "Acc. Tint", function() OpenAccessoryColorMenu() end, function() return main.ActiveSection == "Acc. Tint" end)

    do
        local spacer = vgui.Create("DPanel", sidebar)
        spacer:Dock(TOP)
        spacer:SetTall(MenuUnit(18))
        spacer.Paint = function() end
    end

    CreateAppearanceTextButton(sidebar, "Jacket", function() OpenClothesMenu("main", "Jacket", true) end, function() return main.ActiveSection == "Jacket" end)
    CreateAppearanceTextButton(sidebar, "Pants", function() OpenClothesMenu("pants", "Pants") end, function() return main.ActiveSection == "Pants" end)
    CreateAppearanceTextButton(sidebar, "Boots", function() OpenClothesMenu("boots", "Boots") end, function() return main.ActiveSection == "Boots" end)
    CreateAppearanceTextButton(sidebar, "Gloves", function() OpenGlovesMenu() end, function() return main.ActiveSection == "Gloves" end)

    do
        local spacer2 = vgui.Create("DPanel", sidebar)
        spacer2:Dock(TOP)
        spacer2:SetTall(MenuUnit(18))
        spacer2.Paint = function() end
    end

    CreateAppearanceTextButton(sidebar, "Facemap", function() OpenFacemapMenu() end, function() return main.ActiveSection == "Facemap" end)
    CreateAppearanceTextButton(sidebar, "Torso Shape", function() OpenBodygroupMenu("TORSO", "Torso Shape") end, function() return main.ActiveSection == "Torso Shape" end)
    CreateAppearanceTextButton(sidebar, "Legs Shape", function() OpenBodygroupMenu("LEGS", "Legs Shape") end, function() return main.ActiveSection == "Legs Shape" end)

    do
        local scalePanel = vgui.Create("DPanel", sidebar)
        scalePanel:Dock(TOP)
        scalePanel:DockMargin(MenuUnit(10), MenuUnit(26), MenuUnit(10), MenuUnit(4))
        scalePanel:SetTall(MenuUnit(96))
        scalePanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(22, 22, 22, 180))
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 90)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 70)
            surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        end

        local function addSlider(parent, title, valueKey)
            local row = vgui.Create("DPanel", parent)
            row:Dock(TOP)
            row:SetTall(MenuUnit(42))
            row:DockMargin(MenuUnit(2), 0, MenuUnit(2), MenuUnit(2))
            row.Paint = function() end

            local titleLabel = vgui.Create("DLabel", row)
            titleLabel:Dock(LEFT)
            titleLabel:SetWidth(MenuUnit(34))
            titleLabel:SetFont("ZCity_Menu_Settings_Tiny")
            titleLabel:SetText(title)
            titleLabel:SetTextColor(appearance_color_text)
            titleLabel:SetContentAlignment(4)

            local valueLabel = vgui.Create("DLabel", row)
            valueLabel:Dock(RIGHT)
            valueLabel:SetWidth(MenuUnit(34))
            valueLabel:SetFont("ZCity_Menu_Settings_Tiny")
            valueLabel:SetTextColor(appearance_color_text)
            valueLabel:SetContentAlignment(6)

            local slider = vgui.Create("DSlider", row)
            slider:Dock(FILL)
            slider:DockMargin(MenuUnit(4), MenuUnit(6), MenuUnit(4), MenuUnit(6))
            slider:SetTrapInside(true)

            function slider:Paint(w, h)
                draw.RoundedBox(4, 0, h * 0.5 - 4, w, 8, Color(40, 40, 40, 220))
                surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 90)
                surface.DrawOutlinedRect(0, h * 0.5 - 4, w, 8, 1)
            end
            function slider.Knob:Paint(w, h)
                draw.RoundedBox(4, 2, MenuUnit(2), w - 4, h - MenuUnit(4), appearance_accent)
                surface.SetDrawColor(255, 255, 255, 160)
                surface.DrawOutlinedRect(2, MenuUnit(2), w - 4, h - MenuUnit(4), 1)
            end

            local function refresh()
                local val = APmodule.NormalizeHeight(main.AppearanceTable[valueKey])
                main.AppearanceTable[valueKey] = val
                valueLabel:SetText(val .. "%")
                slider._lock = true
                slider:SetSlideX((val - APmodule.HeightMin) / (APmodule.HeightMax - APmodule.HeightMin))
                slider._lock = nil
            end

            function slider:OnValueChanged(fraction)
                if self._lock then return end
                local val = math.Round(APmodule.HeightMin + (APmodule.HeightMax - APmodule.HeightMin) * fraction)
                val = APmodule.NormalizeHeight(val)
                self._lock = true
                slider:SetSlideX((val - APmodule.HeightMin) / (APmodule.HeightMax - APmodule.HeightMin))
                self._lock = nil
                main.AppearanceTable[valueKey] = val
                valueLabel:SetText(val .. "%")
                main:SyncSharedPreview()
            end

            refresh()

            return row
        end

        addSlider(scalePanel, "Height", "AHeight")
        addSlider(scalePanel, "Weight", "ABodySize")
    end

    local returnBtn = vgui.Create("DLabel", self)
    returnBtn:SetPos(MenuUnit(15), sizeY - MenuUnit(30))
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
        local textColor = appearance_color_text
        if isHovered then
            textColor = Color(235, 225, 210, 255)
        end
        if isHovered then
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 220)
            surface.DrawRect(0, MenuUnit(6), MenuUnit(3), h - MenuUnit(12))
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * (self.HoverScale or 0.02)
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        draw.SimpleText(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 200 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        cam.PopModelMatrix()
        return true
    end

    local lowerActions = vgui.Create("DPanel", sidebar)
    lowerActions:Dock(TOP)
    lowerActions:DockMargin(MenuUnit(10), MenuUnit(8), MenuUnit(10), MenuUnit(4))
    lowerActions:SetTall(MenuUnit(52) * 4)
    lowerActions.Paint = function() end

    local function CreateActionButton(title, fnClick, fnActive)
        local btn = vgui.Create("DButton", lowerActions)
        btn:SetText("")
        btn:Dock(TOP)
        btn:SetTall(MenuUnit(48))
        btn:DockMargin(0, MenuUnit(2), 0, MenuUnit(2))
        btn.ClickFunc = fnClick
        btn.ActiveFunc = fnActive
        btn.HoverLerp = 0
        btn.Title = title
        function btn:Think()
            self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        end
        function btn:DoClick()
            if self.ClickFunc then self.ClickFunc() end
        end
        function btn:Paint(w, h)
            local isActive = self.ActiveFunc and self.ActiveFunc() or false
            local bg = isActive and appearance_panel_act or appearance_panel_bg
            if self:IsHovered() then bg = appearance_panel_hi end
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(appearance_panel_border.r, appearance_panel_border.g, appearance_panel_border.b, isActive and 200 or 120)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            if isActive then
                surface.SetDrawColor(appearance_accent.r, appearance_accent.g, appearance_accent.b, 255)
                surface.DrawRect(0, 0, MenuUnit(3), h)
            end
            local textColor = isActive and appearance_accent or appearance_color_text
            draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return btn
    end

    local applyBtn = CreateActionButton("Apply", function() main.ActiveSection = "Apply" CloseSelectorPanel() ApplyAppearance() end, function() return main.ActiveSection == "Apply" end)
    local savePresetBtn = CreateActionButton("Save Preset", function() main.ActiveSection = "Save Preset" CloseSelectorPanel() SaveCurrentPreset() end, function() return main.ActiveSection == "Save Preset" end)
    local loadPresetBtn = CreateActionButton("Load Preset", function() main.ActiveSection = "Load Preset" CloseSelectorPanel() LoadCurrentPreset() end, function() return main.ActiveSection == "Load Preset" end)
    local deletePresetBtn = CreateActionButton("Delete Preset", function() main.ActiveSection = "Delete Preset" CloseSelectorPanel() DeleteCurrentPreset() end, function() return main.ActiveSection == "Delete Preset" end)
    applyBtn.StartDelay = 0
    savePresetBtn.StartDelay = 0.04
    loadPresetBtn.StartDelay = 0.08
    deletePresetBtn.StartDelay = 0.12

    function self:Close()
        TryExitAppearance()
    end
    self:CallbackAppearance()
    hook.Run("HG_AppearanceMenuReady", main)
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
