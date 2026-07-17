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

local CLR = {}
CLR.white = Color(240,240,240,240)
CLR.text = Color(220,220,220)
CLR.dim = Color(140,140,140)
CLR.accent = Color(225,225,225,255)
CLR.accentDim = Color(150,150,150,120)
CLR.panelHi = Color(60,60,60,235)
CLR.panelAct = Color(48,48,48,220)
CLR.panelBg = Color(28,28,28,180)
CLR.panelBorder = Color(180,180,180,90)
CLR.gold = Color(225,225,225,255)
CLR.goldDim = Color(150,150,150,120)
CLR.darkBg = Color(8,8,8,255)

local CFG = {
    previewFov = 15,
    previewCamPos = Vector(118,0,60),
    previewLookAng = Angle(11,180,0),
    previewShiftX = 180,
    previewShiftY = 140,
    previewSelectorShiftX = 165,
    nameWidth = 320,
    selectorWidth = 340,
    headerH = 52,
    slideSpeed = 8,
    fadeSpeed = 0.18,
    returnMoveTime = 0.32,
    unsavedW = 380,
    unsavedH = 150,
    unsavedBtnW = 120,
    unsavedBtnH = 30,
    unsavedMsg = "You havent saved your changes.",
    unsavedFadeIn = 0.12,
    unsavedFadeOut = 0.1,
    unsavedRise = 8,
    rowH = 60,
    textBtnH = 34,
    actBtnH = 30,
    selectorRowH = 30,
}

local THUMB = {
    main   = {fov=50, cam_pos=Vector(57,0,40), look_at=Vector(0,0,30)},
    pants  = {fov=50, cam_pos=Vector(57,0,40), look_at=Vector(0,0,30)},
    boots  = {fov=22, cam_pos=Vector(30,0,5),  look_at=Vector(0,0,5)},
    HANDS  = {fov=50, cam_pos=Vector(57,0,40), look_at=Vector(0,0,30)},
    TORSO  = {fov=50, cam_pos=Vector(57,0,40), look_at=Vector(0,0,30)},
    LEGS   = {fov=50, cam_pos=Vector(57,0,40), look_at=Vector(0,0,30)},
    Hat    = {fov=10, cam_pos=Vector(25,0,10), look_at=Vector(0,0,10)},
    Face   = {fov=6,  cam_pos=Vector(20,0,8),  look_at=Vector(0,0,8)},
    Body   = {fov=10, cam_pos=Vector(35,0,15), look_at=Vector(0,0,15)},
    Hair   = {fov=10, cam_pos=Vector(25,0,12), look_at=Vector(0,0,12)},
    Mask   = {fov=6,  cam_pos=Vector(20,0,8),  look_at=Vector(0,0,8)},
    ["Body 2"] = {fov=10, cam_pos=Vector(35,0,15), look_at=Vector(0,0,15)},
}

local SND = {
    success = "ui/rem_success.wav",
    tap = "shitty/tap-resonant.wav",
    ok = "buttons/button14.wav",
    cancel = "buttons/button10.wav",
    del = "buttons/button15.wav",
    cloth = "player/clothes_generic_foley_0",
    draw = "player/weapon_draw_0",
}

do
    local s = math.min(ScrW(), ScrH()) / 1000
    surface.CreateFont("ZCity_Menu_Settings_Medium", {font="IBM Plex Mono", size=math.max(16, math.floor(32*s)), weight=400, antialias=true})
    surface.CreateFont("ZCity_Menu_Settings_Small", {font="IBM Plex Mono", size=math.max(14, math.floor(22*s)), weight=400, antialias=true})
    surface.CreateFont("ZCity_Menu_Settings_Tiny", {font="IBM Plex Mono", size=math.max(12, math.floor(16*s)), weight=400, antialias=true})
end

local presetsDir = "zcity/appearances/presets/"

local function SavePreset(n, t) file.CreateDir(presetsDir) file.Write(presetsDir..n..".json", util.TableToJSON(t, true)) end
local function LoadPreset(n) if not file.Exists(presetsDir..n..".json","DATA") then return nil end return util.JSONToTable(file.Read(presetsDir..n..".json","DATA")) end
local function GetPresetList() file.CreateDir(presetsDir) local f=file.Find(presetsDir.."*.json","DATA") local p={} for _,v in ipairs(f or {}) do table.insert(p, string.StripExtension(v)) end return p end
local function DeletePreset(n) if file.Exists(presetsDir..n..".json","DATA") then file.Delete(presetsDir..n..".json") return true end return false end

hg.Appearance.SavePreset = SavePreset
hg.Appearance.LoadPreset = LoadPreset
hg.Appearance.GetPresetList = GetPresetList
hg.Appearance.DeletePreset = DeletePreset

local modelsPrecached = false
local function PrecacheModels()
    if modelsPrecached then return end
    modelsPrecached = true
    timer.Simple(0.1, function()
        if APmodule.PlayerModels then for _,sm in SortedPairs(APmodule.PlayerModels) do for _,md in SortedPairs(sm) do if md.mdl then util.PrecacheModel(md.mdl) end end end end
        if hg.Accessories then for _,a in SortedPairs(hg.Accessories) do if a.model then util.PrecacheModel(a.model) end end end
    end)
end

hook.Add("InitPostEntity","HG_PrecacheAppearanceModels",function() timer.Simple(5, PrecacheModels) end)
hg.Appearance.PrecacheModels = PrecacheModels

local sizeX, sizeY = ScrW(), ScrH()

local function MU(n) return math.floor(n * math.min(ScrW(), ScrH()) / 1000) end

local gradient_r = surface.GetTextureID("vgui/gradient-r")
local gradient_l = surface.GetTextureID("vgui/gradient-l")

local function NormalizeColor(c)
    if IsColor(c) then return c end
    if istable(c) then return Color(c.r or c[1] or 255, c.g or c[2] or 255, c.b or c[3] or 255, c.a or c[4] or 255) end
    return color_white
end

local function PlayCloth() surface.PlaySound(SND.cloth..math.random(5)..".wav") end
local function PlayDraw() surface.PlaySound(SND.draw..math.random(2,5)..".wav") end

local function CreateScrollPanel(parent)
    local scroll = vgui.Create("DScrollPanel", parent)
    local sbar = scroll:GetVBar()
    sbar:SetWide(ScreenScale(4))
    sbar:SetHideButtons(true)
    function sbar:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(18,16,14,220))
        surface.SetDrawColor(100,90,78,180)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    function sbar.btnGrip:Paint(w,h)
        local c = self:IsHovered() and Color(130,120,105,240) or Color(90,82,70,240)
        draw.RoundedBox(4,2,2,w-4,h-4,c)
    end
    return scroll
end

local function GetThumbPreset(section)
    local p = THUMB[section]
    if not p then return 24, Vector(60,0,35), Vector(0,0,30) end
    return p.fov or 24, p.cam_pos or Vector(60,0,35), p.look_at or Vector(0,0,30)
end

local function ApplyAppearanceToModel(ent, modelData, tbl, oKey, oMat, oBgKey, oBgID)
    if not modelData then return end
    local sexID = modelData.sex and 2 or 1
    local clothes = tbl.AClothes or {}
    for ck, slotMat in SortedPairs(modelData.submatSlots or {}) do
        local cKey = clothes[ck]
        local cMat = cKey and hg.Appearance.Clothes[sexID] and hg.Appearance.Clothes[sexID][cKey]
        if cMat then
            local mats = ent:GetMaterials()
            for i=1,#mats do if mats[i]==slotMat then ent:SetSubMaterial(i-1,cMat) break end end
        end
    end
    if oKey and oMat then
        local ms = modelData.submatSlots and modelData.submatSlots[oKey]
        if ms then
            local mats = ent:GetMaterials()
            for i=1,#mats do if mats[i]==ms then ent:SetSubMaterial(i-1,oMat) break end end
        end
    end
    local bgs = tbl.ABodygroups or {}
    for bgk,bgv in pairs(bgs) do
        local bge = hg.Appearance.Bodygroups[bgk] and hg.Appearance.Bodygroups[bgk][sexID] and hg.Appearance.Bodygroups[bgk][sexID][bgv]
        if bge then
            local bgs2 = istable(bge) and bge[1] or nil
            if bgs2 then
                local mBGs = ent:GetBodyGroups()
                for bI,bD in ipairs(mBGs) do for sI=0,#bD.submodels do if bD.submodels[sI]==bgs2 then ent:SetBodygroup(bI-1,sI) break end end end
            end
        end
    end
    if oBgKey and oBgID then
        local mBGs = ent:GetBodyGroups()
        for bI,bD in ipairs(mBGs) do for sI=0,#bD.submodels do if bD.submodels[sI]==oBgID then ent:SetBodygroup(bI-1,sI) break end end end
    end
end

local function CreateThumb(row, section, modelData, fnExtra)
    local fov, camPos, lookAt = GetThumbPreset(section)
    local icon = vgui.Create("DModelPanel", row)
    icon:SetPos(MU(4), MU(4))
    icon:SetSize(MU(48), MU(52))
    icon:SetMouseInputEnabled(false)
    icon:SetModel(modelData.mdl)
    icon:SetFOV(fov)
    icon:SetCamPos(camPos)
    icon:SetLookAt(lookAt)
    icon:SetAmbientLight(Color(80,80,80))
    icon:SetDirectionalLight(BOX_TOP, Color(120,120,120))
    icon:SetDirectionalLight(BOX_RIGHT, Color(100,100,100))
    icon:SetDirectionalLight(BOX_LEFT, Color(100,100,100))
    icon:SetDirectionalLight(BOX_FRONT, Color(90,90,90))
    icon:SetDirectionalLight(BOX_BACK, Color(90,90,90))
    icon:SetDirectionalLight(BOX_BOTTOM, Color(60,60,60))
    function icon:PreDrawModel(ent) end
    function icon:PostDrawModel(ent) end
    function icon:LayoutEntity(ent)
        ent:SetAngles(Angle(0, row.SpinAngle or 20, 0))
        ent:SetSequence(ent:LookupSequence("mp_storage_1h_medium"))
        fnExtra(ent)
        self:SetLookAt(lookAt)
    end
    return icon
end

local function BuildComparable(tbl)
    local a = table.Copy(tbl or {})
    a.AAttachments = a.AAttachments or {}
    for i=1,6 do a.AAttachments[i] = a.AAttachments[i] or "none" end
    a.AClothes = a.AClothes or {}
    a.ABodygroups = a.ABodygroups or {}
    if IsColor(a.AColor) then
        a.AColor = {r=a.AColor.r, g=a.AColor.g, b=a.AColor.b, a=a.AColor.a}
    elseif istable(a.AColor) then
        a.AColor = {r=a.AColor.r or a.AColor[1] or 255, g=a.AColor.g or a.AColor[2] or 255, b=a.AColor.b or a.AColor[3] or 255, a=a.AColor.a or a.AColor[4] or 255}
    else
        a.AColor = {r=255, g=255, b=255, a=255}
    end
    return a
end

local function DeepEqual(a, b)
    if istable(a) and istable(b) then
        for k,v in pairs(a) do if not DeepEqual(v, b[k]) then return false end end
        for k,v in pairs(b) do if not DeepEqual(v, a[k]) then return false end end
        return true
    end
    return a == b
end

local clr_ico, clr_menu = Color(26,24,20,255), Color(14,13,11,250)
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
    function menu:Paint(w,h)
        draw.RoundedBox(8,0,0,w,h,clr_menu)
        surface.SetDrawColor(CLR.white.r,CLR.white.g,CLR.white.b,100)
        surface.DrawOutlinedRect(0,0,w,h,2)
        draw.RoundedBoxEx(8,0,0,w,ScreenScale(10),Color(22,20,17,220),true,true,false,false)
    end
    local scroll = CreateScrollPanel(menu)
    scroll:Dock(FILL)
    scroll:DockMargin(ScreenScale(2),ScreenScale(2),ScreenScale(2),ScreenScale(2))
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
        local spawnIcon = vgui.Create("DModelPanel", ico)
        spawnIcon:Dock(FILL)
        spawnIcon:DockMargin(2,2,2,2)
        spawnIcon:SetModel(model or "models/error.mdl")
        spawnIcon:SetTooltip(string.NiceName(accessoryData and accessoryData.name or accessorKey))
        spawnIcon:SetFOV(15)
        spawnIcon:SetLookAt(accessoryData.vpos or Vector(0,0,0))
        spawnIcon:SetAmbientLight(Color(80,80,80))
        spawnIcon:SetDirectionalLight(BOX_TOP, Color(120,120,120))
        spawnIcon:SetDirectionalLight(BOX_RIGHT, Color(100,100,100))
        spawnIcon:SetDirectionalLight(BOX_LEFT, Color(100,100,100))
        spawnIcon:SetDirectionalLight(BOX_FRONT, Color(90,90,90))
        spawnIcon:SetDirectionalLight(BOX_BACK, Color(90,90,90))
        spawnIcon:SetDirectionalLight(BOX_BOTTOM, Color(60,60,60))
        function spawnIcon:PreDrawModel(ent)
            if accessoryData.bSetColor then
                local cd = accessoryData.vecColorOveride or (lply.GetPlayerColor and lply:GetPlayerColor() or lply:GetNWVector("PlayerColor",Vector(1,1,1)))
                render.SetColorModulation(cd[1],cd[2],cd[3])
            end
        end
        function spawnIcon:PostDrawModel(ent)
            if accessoryData.bSetColor then render.SetColorModulation(1,1,1) end
        end
        timer.Simple(0,function()
            if not IsValid(spawnIcon) or not IsValid(spawnIcon.Entity) then return end
            spawnIcon.Entity:SetSkin((isfunction(accessoryData.skin) and accessoryData.skin()) or (accessoryData.skin or 0))
            spawnIcon.Entity:SetBodyGroups(accessoryData.bodygroups or "0000000")
            if accessoryData.SubMat then spawnIcon.Entity:SetSubMaterial(0, accessoryData.SubMat) end
        end)
        function spawnIcon:DoClick()
            if onSelect then onSelect(accessorKey) end
            PlayCloth()
            menu:Close()
        end
        function spawnIcon:Think()
            if onRightClick and self:IsHovered() then
                ico.IsPreviewing = true
                menu.CurrentPreviewIcon = ico
                onRightClick(accessorKey, ico.IsPreviewing)
            end
        end
        function ico:Paint(w,h) draw.RoundedBox(4,0,0,w,h,clr_ico) end
        function ico:Think() self.bIsHovered = vgui.GetHoveredPanel()==self or vgui.GetHoveredPanel()==spawnIcon end
        return ico
    end
    function menu:AddNoneOption(onSelect)
        local ico = vgui.Create("DPanel", self.IconLayout)
        local icoSize = ScreenScale(36)
        ico:SetSize(icoSize, icoSize)
        ico.Accessor = "none"
        ico.bIsHovered = false
        function ico:Paint(w,h)
            local bc = self.bIsHovered and colors.scrollbarGripHover or colors.scrollbarBorder
            draw.RoundedBox(4,0,0,w,h,Color(30,30,40,255))
            surface.SetDrawColor(bc)
            surface.DrawOutlinedRect(0,0,w,h,1)
            surface.SetDrawColor(colors.highlightText)
            local m = ScreenScale(8)
            surface.DrawLine(m,m,w-m,h-m)
            surface.DrawLine(w-m,m,m,h-m)
            draw.SimpleText("None","DermaDefault",w/2,h-ScreenScale(4),colors.mainText,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function ico:Think() self.bIsHovered = vgui.GetHoveredPanel()==self end
        function ico:OnMousePressed(mc)
            if mc==MOUSE_LEFT then if onSelect then onSelect("none") end PlayCloth() menu:Close() end
        end
        function ico:OnCursorEntered() self:SetCursor("hand") end
        return ico
    end
    return menu
end

function PANEL:SetAppearance(t) self.AppearanceTable = t end
function PANEL:CallbackAppearance() end
function PANEL:First(ply)
    self:SetAlpha(255)
    if self.PostInit then self:PostInit() end
end

function PANEL:Paint(w,h)
    if hg.DrawBlur then hg.DrawBlur(self, 5) end
    draw.RoundedBox(0,0,0,w,h,CLR.darkBg)
    local t = RealTime()
    for i=0,h,64 do
        for j=0,w,64 do
            local n = math.sin(j*12.9898+i*78.233+t*0.008)*43758.5453
            n = n - math.floor(n)
            local alpha = 1 + n*3
            local v = 80 + n*30
            surface.SetDrawColor(v,v,v,alpha)
            surface.DrawRect(j,i,64,64)
        end
    end
    surface.SetDrawColor(0,0,0,100)
    surface.DrawRect(0,0,w,h)
    surface.SetDrawColor(80,80,80,15)
    surface.SetTexture(gradient_r)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(20,20,20,80)
    surface.SetTexture(gradient_l)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(100,100,100,40)
    surface.DrawRect(0,0,w,1)
    surface.DrawRect(0,h-1,w,1)
    surface.DrawRect(0,0,1,h)
    surface.DrawRect(w-1,0,1,h)
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
        local base = luaMenu.previewModel.AppearanceTable
        if not base and luaMenu.GetPreviewAppearance then base = select(1, luaMenu:GetPreviewAppearance()) end
        self.SharedPreviewOriginal = table.Copy(base or self.AppearanceTable or {})
    end
    luaMenu.previewModel.AppearanceTable = self.AppearanceTable
    luaMenu.previewModel:SetVisible(true)
    luaMenu.previewModel:SetAlpha(255)
    luaMenu.previewModel.EntityAngleOverride = Angle(0, self.PreviewRotation or 0, 0)
    luaMenu.previewModel.SequenceNameOverride = nil
    luaMenu.previewModel.SequencePlaybackRate = nil
    luaMenu.previewModel.ActiveSequenceName = nil
    luaMenu.previewModel.CamPosOverride = CFG.previewCamPos
    luaMenu.previewModel.FOVOverride = CFG.previewFov
    luaMenu.previewModel.LookAngOverride = CFG.previewLookAng
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
        local tx = (self.AppearancePreviewX or luaMenu.previewHolder:GetX()) - math.floor((self.PreviewSelectorShiftX or 0) * (self.SelectorOpenLerp or 0))
        local ty = self.AppearancePreviewY or luaMenu.previewHolder:GetY()
        luaMenu.previewHolder.TargetX = tx
        luaMenu.previewHolder.TargetY = ty
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
        self.SharedPreviewHolder:MoveTo(self.SharedPreviewHolderOriginal.x, self.SharedPreviewHolderOriginal.y, CFG.returnMoveTime, 0, 0, function()
            if IsValid(self.SharedPreviewHolder) then self.SharedPreviewHolder:SetPos(self.SharedPreviewHolderOriginal.x, self.SharedPreviewHolderOriginal.y) end
        end)
    end
end

function PANEL:ReturnToMenu()
    self.RestoringToMenu = true
    self.SelectorOpenLerp = 0
    self:RestoreSharedPreview()
    local parent = self:GetParent()
    local luaMenu = IsValid(parent) and parent:GetParent()
    if IsValid(luaMenu) and luaMenu.UseDefaultMenuMusic then luaMenu:UseDefaultMenuMusic() end
    if IsValid(luaMenu) then
        for _,child in ipairs(luaMenu:GetChildren()) do
            if child ~= parent then child:SetAlpha(255) child:SetVisible(true) end
        end
        if luaMenu.ResetCurrentPanel then luaMenu:ResetCurrentPanel() end
    end
    if IsValid(parent) then parent:Remove() end
end

local UI = {}

local function PaintRowBg(self, w, h, isActive, isHovered)
    local bg = isActive and CLR.panelAct or CLR.panelBg
    if isHovered then bg = CLR.panelHi end
    surface.SetDrawColor(bg)
    surface.DrawRect(0,0,w,h)
    surface.SetDrawColor(CLR.panelBorder.r, CLR.panelBorder.g, CLR.panelBorder.b, isActive and 140 or 50)
    surface.DrawOutlinedRect(0,0,w,h,1)
    if isActive then
        surface.SetDrawColor(CLR.accent.r, CLR.accent.g, CLR.accent.b, 160)
        surface.DrawRect(0, MU(3), MU(2), h - MU(6))
    end
end

function UI.TextButton(parent, title, fnClick, fnActive)
    local btn = vgui.Create("DLabel", parent)
    btn:SetText(string.rep("#", #title))
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Menu_Settings_Small")
    btn:SetTall(MU(CFG.textBtnH))
    btn:Dock(TOP)
    btn:DockMargin(MU(10), MU(1), MU(10), 0)
    btn.OpenTime = CurTime()
    btn.StartDelay = 0
    btn.LineLerp = 0
    btn.HoverLerp = 0
    function btn:DoClick() if fnClick then fnClick() end end
    function btn:Think()
        local hov = self:IsHovered()
        local act = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, hov and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, (hov or act) and 1 or 0)
        local elapsed = CurTime() - self.OpenTime - self.StartDelay
        if elapsed < 0 then if self:GetText() ~= "" then self:SetText("") end return end
        local chars = math.floor(elapsed * 15)
        local target = act and ("[ "..title.." ]") or title
        local len = #target
        if chars > len then chars = len end
        local ntxt = ""
        for i=1,len do if i<=chars then ntxt=ntxt..target:sub(i,i) else ntxt=ntxt.."#" end end
        if self:GetText() ~= ntxt then surface.PlaySound(SND.tap) self:SetText(ntxt) self:SizeToContents() end
    end
    function btn:Paint(w,h)
        local hov = self:IsHovered()
        local tc = CLR.text
        if hov then tc = Color(235,225,210,255) end
        if self.IsActive then tc = CLR.accent end
        if self.IsActive then
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,160)
            surface.DrawRect(0, MU(3), MU(2), h - MU(6))
        end
        surface.SetFont(self:GetFont())
        local tw,th = surface.GetTextSize(self:GetText())
        local sc = 1 + (self.HoverLerp or 0) * 0.01
        local m = Matrix()
        m:Translate(Vector(0, h*(1-sc)*0.5, 0))
        m:Scale(Vector(sc,sc,1))
        cam.PushModelMatrix(m)
        if hov or self.IsActive then
            draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h/2, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,200))
        else
            draw.SimpleText(self:GetText(), self:GetFont(), 0, h/2, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b, 140*self.LineLerp)
            surface.DrawRect(0, h/2+th/2, tw*self.LineLerp, 1)
        end
        cam.PopModelMatrix()
        return true
    end
    return btn
end

function UI.SelectorRow(parent, title, fnActive, fnClick, tooltip)
    local row = vgui.Create("DLabel", parent)
    row:Dock(TOP)
    row:SetTall(MU(CFG.selectorRowH))
    row:DockMargin(MU(6), MU(1), MU(6), 0)
    row:SetFont("ZCity_Menu_Settings_Small")
    row:SetText("")
    row:SetMouseInputEnabled(true)
    row.Title = title
    if tooltip and tooltip != "" then row:SetTooltip(tooltip) end
    function row:DoClick() if fnClick then fnClick() end end
    function row:Think()
        self.IsActive = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, (self:IsHovered() or self.IsActive) and 1 or 0)
    end
    function row:Paint(w,h)
        local hov = self:IsHovered()
        local tc = CLR.text
        local oc = Color(0,0,0,160)
        if self.IsActive then
            tc = CLR.accent
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,20)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,140)
            surface.DrawRect(0, MU(3), MU(2), h - MU(6))
        end
        if hov then
            local flash = 0.5 + 0.5*math.sin(CurTime()*10)
            local v = flash*255
            tc = Color(v,v,v,255)
            oc = Color(255-v,255-v,255-v,160)
        end
        draw.SimpleTextOutlined(self.Title, self:GetFont(), MU(4), h*0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, oc)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255,255,255,180*self.LineLerp)
            local tw,th = surface.GetTextSize(self.Title)
            surface.DrawRect(MU(4), h*0.5+th*0.5, tw*self.LineLerp, 1)
        end
        return true
    end
    return row
end

function UI.ModelRow(parent, title, modelData, fnActive, fnClick, subtitle)
    local row = vgui.Create("DButton", parent)
    row:Dock(TOP)
    row:SetTall(MU(CFG.rowH))
    row:DockMargin(MU(6), MU(1), MU(6), 0)
    row:SetText("")
    row:SetCursor("hand")
    row.Title = title
    function row:DoClick() if fnClick then fnClick() end end
    function row:Think()
        self.IsActive = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime()*18*(self.HoverLerp or 0)
    end
    function row:Paint(w,h)
        PaintRowBg(self, w, h, self.IsActive, self:IsHovered())
        draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MU(56), MU(10), CLR.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(subtitle or (self.IsActive and "Selected" or "Model"), "ZCity_Menu_Settings_Tiny", MU(56), MU(28), CLR.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    local icon = vgui.Create("DModelPanel", row)
    icon:SetPos(MU(4), MU(4))
    icon:SetSize(MU(48), MU(52))
    icon:SetMouseInputEnabled(false)
    local im = tostring(modelData and (modelData.mdl or modelData.model) or "")
    icon:SetModel(im != "" and im or "models/error.mdl")
    icon:SetFOV(15)
    icon:SetAmbientLight(Color(80,80,80))
    icon:SetDirectionalLight(BOX_TOP, Color(120,120,120))
    icon:SetDirectionalLight(BOX_RIGHT, Color(100,100,100))
    icon:SetDirectionalLight(BOX_LEFT, Color(100,100,100))
    icon:SetDirectionalLight(BOX_FRONT, Color(90,90,90))
    icon:SetDirectionalLight(BOX_BACK, Color(90,90,90))
    icon:SetDirectionalLight(BOX_BOTTOM, Color(60,60,60))
    function icon:PreDrawModel(ent)
        if modelData and modelData.bSetColor then
            local cd = modelData.vecColorOveride or (lply.GetPlayerColor and lply:GetPlayerColor() or lply:GetNWVector("PlayerColor",Vector(1,1,1)))
            render.SetColorModulation(cd[1],cd[2],cd[3])
        end
    end
    function icon:PostDrawModel(ent)
        if modelData and modelData.bSetColor then render.SetColorModulation(1,1,1) end
    end
    function icon:LayoutEntity(ent)
        ent:SetAngles(Angle(0, row.SpinAngle or 20, 0))
        if modelData and modelData.skin then ent:SetSkin(isfunction(modelData.skin) and modelData.skin() or modelData.skin) end
        if modelData and modelData.bodygroups then ent:SetBodyGroups(modelData.bodygroups) end
        if modelData and modelData.SubMat then ent:SetSubMaterial(0, modelData.SubMat) end
        self:SetLookAt(modelData and modelData.vpos or Vector(0,0,0))
    end
    return row
end

function UI.ClothingRow(parent, title, clothingKey, clothingMat, main, fnActive, fnClick, subtitle)
    local modelData = main:GetCurrentModelData()
    if not modelData then return UI.SelectorRow(parent, title, fnActive, fnClick, subtitle) end
    local row = vgui.Create("DButton", parent)
    row:Dock(TOP)
    row:SetTall(MU(CFG.rowH))
    row:DockMargin(MU(6), MU(1), MU(6), 0)
    row:SetText("")
    row:SetCursor("hand")
    row.Title = title
    function row:DoClick() if fnClick then fnClick() end end
    function row:Think()
        self.IsActive = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime()*18*(self.HoverLerp or 0)
    end
    function row:Paint(w,h)
        PaintRowBg(self, w, h, self.IsActive, self:IsHovered())
        draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MU(56), MU(10), CLR.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(subtitle or (self.IsActive and "Selected" or "Clothing"), "ZCity_Menu_Settings_Tiny", MU(56), MU(28), CLR.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    CreateThumb(row, clothingKey or "main", modelData, function(ent)
        ApplyAppearanceToModel(ent, modelData, main.AppearanceTable, clothingKey, clothingMat, nil, nil)
    end)
    return row
end

function UI.BodygroupRow(parent, title, bgKey, bgStringID, main, fnActive, fnClick, subtitle)
    local modelData = main:GetCurrentModelData()
    if not modelData then return UI.SelectorRow(parent, title, fnActive, fnClick, subtitle) end
    local row = vgui.Create("DButton", parent)
    row:Dock(TOP)
    row:SetTall(MU(CFG.rowH))
    row:DockMargin(MU(6), MU(1), MU(6), 0)
    row:SetText("")
    row:SetCursor("hand")
    row.Title = title
    function row:DoClick() if fnClick then fnClick() end end
    function row:Think()
        self.IsActive = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        self.SpinAngle = (self.SpinAngle or 20) + RealFrameTime()*18*(self.HoverLerp or 0)
    end
    function row:Paint(w,h)
        PaintRowBg(self, w, h, self.IsActive, self:IsHovered())
        draw.SimpleText(self.Title, "ZCity_Menu_Settings_Small", MU(56), MU(10), CLR.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(subtitle or (self.IsActive and "Selected" or "Bodygroup"), "ZCity_Menu_Settings_Tiny", MU(56), MU(28), CLR.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    CreateThumb(row, bgKey or "main", modelData, function(ent)
        ApplyAppearanceToModel(ent, modelData, main.AppearanceTable, nil, nil, bgKey, bgStringID)
    end)
    return row
end

function UI.NoneRow(parent, fnActive, fnClick)
    local row = vgui.Create("DButton", parent)
    row:Dock(TOP)
    row:SetTall(MU(CFG.rowH))
    row:DockMargin(MU(6), MU(1), MU(6), 0)
    row:SetText("")
    row:SetCursor("hand")
    function row:DoClick() if fnClick then fnClick() end end
    function row:Think()
        self.IsActive = fnActive and fnActive() or false
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
    end
    function row:Paint(w,h)
        PaintRowBg(self, w, h, self.IsActive, self:IsHovered())
        surface.SetDrawColor(CLR.panelBorder.r, CLR.panelBorder.g, CLR.panelBorder.b, 60)
        surface.DrawOutlinedRect(MU(4), MU(4), MU(48), MU(52), 1)
        draw.SimpleText("X", "ZCity_Menu_Settings_Small", MU(28), MU(30), CLR.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("None", "ZCity_Menu_Settings_Small", MU(56), MU(10), CLR.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Clear slot", "ZCity_Menu_Settings_Tiny", MU(56), MU(28), CLR.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    return row
end

function UI.ActionButton(parent, title, fnClick, fnActive)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:Dock(TOP)
    btn:SetTall(MU(CFG.actBtnH))
    btn:DockMargin(0, MU(1), 0, MU(1))
    btn.ClickFunc = fnClick
    btn.ActiveFunc = fnActive
    btn.HoverLerp = 0
    btn.Title = title
    function btn:Think() self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0) end
    function btn:DoClick() if self.ClickFunc then self.ClickFunc() end end
    function btn:Paint(w,h)
        local act = self.ActiveFunc and self.ActiveFunc() or false
        local bg = act and CLR.panelAct or CLR.panelBg
        if self:IsHovered() then bg = CLR.panelHi end
        surface.SetDrawColor(bg)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(CLR.panelBorder.r, CLR.panelBorder.g, CLR.panelBorder.b, act and 140 or 60)
        surface.DrawOutlinedRect(0,0,w,h,1)
        if act then
            surface.SetDrawColor(CLR.accent.r, CLR.accent.g, CLR.accent.b, 180)
            surface.DrawRect(0,0,MU(2),h)
        end
        local tc = act and CLR.accent or CLR.text
        draw.SimpleText(self.Title, "ZCity_Menu_Settings_Tiny", w*0.5, h*0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return btn
end

function PANEL:PostInit()
    local main = self
    self:SetBorder(false)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    if IsValid(self.btnClose) then self.btnClose:SetVisible(false) self.btnClose:SetMouseInputEnabled(false) end
    local parent = self:GetParent()
    local luaMenu = IsValid(parent) and parent:GetParent()
    if IsValid(luaMenu) and luaMenu.UseAppearanceMenuMusic then luaMenu:UseAppearanceMenuMusic() end

    self.AppearanceTable = table.Copy(self.AppearanceTable or hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString()) or APmodule.GetRandomAppearance())
    self.AppearanceTable.AAttachments = self.AppearanceTable.AAttachments or {"none","none","none","none","none","none"}
    self.AppearanceTable.AClothes = self.AppearanceTable.AClothes or {}
    self.AppearanceTable.ABodygroups = self.AppearanceTable.ABodygroups or {}
    self.AppearanceTable.AColor = NormalizeColor(self.AppearanceTable.AColor)
    self.AppearanceTable.AHeight = APmodule.NormalizeHeight(self.AppearanceTable.AHeight)
    self.AppearanceTable.ABodySize = APmodule.NormalizeHeight(self.AppearanceTable.ABodySize)
    self.PreviewRotation = 0
    self.ActiveSection = "Model"
    self.SelectorOpenLerp = 0
    self.PreviewSelectorShiftX = MU(CFG.previewSelectorShiftX)

    local nameEntry, previewNameLabel, selectorPanel, selectorHeaderTitle, selectorHeaderHint, selectorContent, currentSelectorSection, CloseSelectorPanel, savedSnapshot, unsavedOverlay

    local function GetClothesValue(key) return main.AppearanceTable.AClothes and main.AppearanceTable.AClothes[key] or "normal" end
    local function GetAttachmentValue(id) local v = main.AppearanceTable.AAttachments and main.AppearanceTable.AAttachments[id] return v and v != "" and v or "none" end

    local function UpdateAppearance(tbl)
        main.AppearanceTable = table.Copy(tbl or main.AppearanceTable or {})
        main.AppearanceTable.AAttachments = main.AppearanceTable.AAttachments or {"none","none","none","none","none","none"}
        main.AppearanceTable.AClothes = main.AppearanceTable.AClothes or {}
        main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
        main.AppearanceTable.AColor = NormalizeColor(main.AppearanceTable.AColor)
        main.AppearanceTable.AHeight = APmodule.NormalizeHeight(main.AppearanceTable.AHeight)
        main.AppearanceTable.ABodySize = APmodule.NormalizeHeight(main.AppearanceTable.ABodySize)
        local md = main:GetCurrentModelData()
        if md and md.mdl then
            local fk = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[md.mdl]
            local fs = fk and hg.Appearance.FacemapsSlots[fk]
            if fs and not fs[main.AppearanceTable.AFacemap] then main.AppearanceTable.AFacemap = "Default" end
        end
        if IsValid(nameEntry) and nameEntry:GetValue() != (main.AppearanceTable.AName or "") then nameEntry:SetText(main.AppearanceTable.AName or "") end
        main:SyncSharedPreview()
    end

    local function ApplyAppearance()
        hg.Appearance.CreateAppearanceFile(hg.Appearance.SelectedAppearance:GetString(), main.AppearanceTable)
        net.Start("OnlyGet_Appearance")
            net.WriteTable(main.AppearanceTable)
        net.SendToServer()
        main.SharedPreviewOriginal = table.Copy(main.AppearanceTable)
        savedSnapshot = BuildComparable(main.AppearanceTable)
        surface.PlaySound(SND.success)
    end

    local function HasUnsaved() return not DeepEqual(savedSnapshot or {}, BuildComparable(main.AppearanceTable)) end

    local function CloseUnsaved(fn)
        if IsValid(unsavedOverlay) then
            if unsavedOverlay.IsClosing then return end
            unsavedOverlay.IsClosing = true
            local ov = unsavedOverlay
            local box = ov.BoxPanel
            if IsValid(box) then box:MoveTo(box:GetX(), box.TargetY or box:GetY(), CFG.unsavedFadeOut, 0, -1) box:AlphaTo(0, CFG.unsavedFadeOut, 0) end
            ov:AlphaTo(0, CFG.unsavedFadeOut, 0, function() if IsValid(ov) then ov:Remove() end if fn then fn() end end)
        end
        unsavedOverlay = nil
    end

    local function ShowUnsaved()
        if IsValid(unsavedOverlay) then return end
        unsavedOverlay = vgui.Create("DButton", main)
        unsavedOverlay:SetText("")
        unsavedOverlay:SetCursor("arrow")
        unsavedOverlay:SetSize(main:GetWide(), main:GetTall())
        unsavedOverlay:SetPos(0,0)
        unsavedOverlay:SetAlpha(0)
        unsavedOverlay:MakePopup()
        unsavedOverlay.Paint = function(this,w,h) surface.SetDrawColor(0,0,0,170) surface.DrawRect(0,0,w,h) end

        local box = vgui.Create("DPanel", unsavedOverlay)
        box:SetSize(MU(CFG.unsavedW), MU(CFG.unsavedH))
        box:Center()
        box.TargetY = box:GetY()
        box:SetY(box.TargetY + MU(CFG.unsavedRise))
        box:SetAlpha(0)
        box.Paint = function(this,w,h)
            surface.SetDrawColor(14,13,11,250)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(CLR.gold.r,CLR.gold.g,CLR.gold.b,200)
            surface.DrawOutlinedRect(0,0,w,h,2)
            draw.SimpleText(CFG.unsavedMsg, "ZCity_Menu_Settings_Small", w*0.5, MU(36), CLR.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        unsavedOverlay.BoxPanel = box
        unsavedOverlay:AlphaTo(255, CFG.unsavedFadeIn, 0)
        box:MoveTo(box:GetX(), box.TargetY, CFG.unsavedFadeIn, 0, -1)
        box:AlphaTo(255, CFG.unsavedFadeIn, 0)

        local saveBtn = vgui.Create("DButton", box)
        saveBtn:SetSize(MU(CFG.unsavedBtnW), MU(CFG.unsavedBtnH))
        saveBtn:SetPos(MU(30), box:GetTall()-MU(48))
        saveBtn:SetText("")
        saveBtn.Paint = function(this,w,h)
            surface.SetDrawColor(22,20,17,255)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(CLR.gold.r,CLR.gold.g,CLR.gold.b,160)
            surface.DrawOutlinedRect(0,0,w,h,1)
            draw.SimpleText("Save", "ZCity_Menu_Settings_Tiny", w*0.5, h*0.5, CLR.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        saveBtn.DoClick = function() ApplyAppearance() CloseUnsaved(function() main:ReturnToMenu() end) end

        local dsBtn = vgui.Create("DButton", box)
        dsBtn:SetSize(MU(CFG.unsavedBtnW), MU(CFG.unsavedBtnH))
        dsBtn:SetPos(box:GetWide()-MU(30)-dsBtn:GetWide(), box:GetTall()-MU(48))
        dsBtn:SetText("")
        dsBtn.Paint = function(this,w,h)
            surface.SetDrawColor(22,20,17,255)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(CLR.gold.r,CLR.gold.g,CLR.gold.b,160)
            surface.DrawOutlinedRect(0,0,w,h,1)
            draw.SimpleText("Dont Save", "ZCity_Menu_Settings_Tiny", w*0.5, h*0.5, CLR.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        dsBtn.DoClick = function() CloseUnsaved(function() main:ReturnToMenu() end) end
    end

    local function TryExit()
        if HasUnsaved() then ShowUnsaved() return end
        main:ReturnToMenu()
    end

    local function SavePresetUI()
        Derma_StringRequest("Save Preset", "Preset name", main.AppearanceTable.AName or "", function(name)
            if not isstring(name) then return end
            name = string.Trim(name)
            if name == "" or #name < 2 then surface.PlaySound(SND.cancel) notification.AddLegacy("Enter a preset name (min 2 chars)", NOTIFY_ERROR, 3) return end
            name = string.gsub(name, "[^%w%s_-]", "")
            SavePreset(name, main.AppearanceTable)
            surface.PlaySound(SND.ok)
            notification.AddLegacy("Preset '"..name.."' saved!", NOTIFY_GENERIC, 3)
        end)
    end

    local function LoadPresetUI()
        local list = GetPresetList()
        if #list == 0 then surface.PlaySound(SND.cancel) notification.AddLegacy("No presets saved yet!", NOTIFY_ERROR, 3) return end
        local pm = vgui.Create("DFrame")
        pm:SetTitle("Load Preset")
        pm:SetSize(ScreenScale(120), ScreenScale(100))
        pm:Center()
        pm:MakePopup()
        pm:SetDraggable(false)
        function pm:Paint(w,h)
            draw.RoundedBox(8,0,0,w,h,Color(16,14,12,250))
            surface.SetDrawColor(CLR.gold.r,CLR.gold.g,CLR.gold.b,140)
            surface.DrawOutlinedRect(0,0,w,h,2)
            draw.RoundedBoxEx(8,0,0,w,ScreenScale(12),Color(22,20,17,220),true,true,false,false)
        end
        local scroll = CreateScrollPanel(pm)
        scroll:Dock(FILL)
        scroll:DockMargin(ScreenScale(2),ScreenScale(2),ScreenScale(2),ScreenScale(2))
        for _,pn in SortedPairs(list) do
            local btn = vgui.Create("DButton", scroll)
            btn:Dock(TOP)
            btn:DockMargin(2,2,2,0)
            btn:SetTall(ScreenScale(14))
            btn:SetFont("ZCity_Menu_Tiny")
            btn:SetText(pn)
            btn:SetTextColor(colors.mainText)
            function btn:Paint(w,h)
                local bg = self:IsHovered() and Color(34,32,28,240) or Color(22,20,17,220)
                draw.RoundedBox(4,0,0,w,h,bg)
                surface.SetDrawColor(CLR.goldDim.r,CLR.goldDim.g,CLR.goldDim.b,100)
                surface.DrawOutlinedRect(0,0,w,h,1)
            end
            function btn:DoClick()
                local loaded = LoadPreset(pn)
                if loaded then
                    UpdateAppearance(loaded)
                    surface.PlaySound(SND.ok)
                    notification.AddLegacy("Preset '"..pn.."' loaded!", NOTIFY_GENERIC, 3)
                else
                    surface.PlaySound(SND.cancel)
                    notification.AddLegacy("Failed to load preset!", NOTIFY_ERROR, 3)
                end
                pm:Close()
            end
            function btn:DoRightClick()
                local dm = DermaMenu()
                dm:AddOption("Delete '"..pn.."'", function()
                    DeletePreset(pn)
                    surface.PlaySound(SND.del)
                    notification.AddLegacy("Preset deleted!", NOTIFY_HINT, 2)
                    btn:Remove()
                end):SetIcon("icon16/cross.png")
                dm:Open()
            end
        end
    end

    local function DeletePresetUI()
        Derma_StringRequest("Delete Preset", "Preset name", main.AppearanceTable.AName or "", function(name)
            if not isstring(name) then return end
            name = string.Trim(name)
            if name == "" then surface.PlaySound(SND.cancel) notification.AddLegacy("Enter preset name to delete", NOTIFY_ERROR, 3) return end
            if DeletePreset(name) then
                surface.PlaySound(SND.del)
                notification.AddLegacy("Preset '"..name.."' deleted!", NOTIFY_HINT, 3)
            else
                surface.PlaySound(SND.cancel)
                notification.AddLegacy("Preset not found!", NOTIFY_ERROR, 3)
            end
        end)
    end

    local function OpenSelector(section, title, hint, fnBuild)
        if not IsValid(selectorPanel) or not IsValid(selectorContent) then return end
        if currentSelectorSection == section and selectorPanel.TargetX == selectorPanel.OpenX then
            currentSelectorSection = nil
            main.ActiveSection = ""
            CloseSelectorPanel()
            return false
        end
        currentSelectorSection = section
        main.ActiveSection = section
        selectorContent:Clear()
        selectorHeaderTitle:SetText(string.upper(title))
        selectorHeaderTitle:SizeToContents()
        selectorHeaderHint:SetText(hint or "")
        selectorHeaderHint:SizeToContents()
        local scroll = CreateScrollPanel(selectorContent)
        scroll:Dock(FILL)
        scroll.Paint = function() end
        if fnBuild then fnBuild(scroll) end
        selectorPanel.TargetX = selectorPanel.OpenX
        return true
    end

    CloseSelectorPanel = function()
        if IsValid(selectorPanel) then
            currentSelectorSection = nil
            selectorPanel.TargetX = selectorPanel.ClosedX
        end
    end

    local function OpenModelMenu()
        local models = {}
        for k,v in pairs(APmodule.PlayerModels[1] or {}) do models[k]=v end
        for k,v in pairs(APmodule.PlayerModels[2] or {}) do models[k]=v end
        OpenSelector("Model", "Model", "Select a player model", function(scroll)
            for k,v in SortedPairs(models) do
                UI.SelectorRow(scroll, k, function() return main.AppearanceTable.AModel==k end, function()
                    main.AppearanceTable.AModel = k
                    UpdateAppearance(main.AppearanceTable)
                    PlayDraw()
                end)
            end
        end)
    end

    local function OpenAccessorySlot(slotID, title, placements)
        OpenSelector(title, title, "Select "..title, function(scroll)
            UI.NoneRow(scroll, function() return GetAttachmentValue(slotID)=="none" end, function()
                main.AppearanceTable.AAttachments[slotID] = "none"
                main:SyncSharedPreview()
                PlayCloth()
            end)
            for k,v in SortedPairs(hg.Accessories or {}) do
                if not placements[v.placement] then continue end
                if not lply:PS_HasItem(k) and v.bPointShop and not hg.Appearance.GetAccessToAll(lply) then continue end
                UI.ModelRow(scroll, string.NiceName(v.name or k), v, function() return GetAttachmentValue(slotID)==k end, function()
                    main.AppearanceTable.AAttachments[slotID] = k
                    main:SyncSharedPreview()
                    PlayCloth()
                end, v.placement or title)
            end
        end)
    end

    local function GetAccessoryName(key)
        if not key or key=="" or key=="none" then return nil end
        local d = hg.Accessories and hg.Accessories[key]
        if d and d.name and d.name != "" then return tostring(d.name) end
        return string.NiceName(tostring(key))
    end

    local function GetColorableAccessories()
        local result, seen = {}, {}
        for _,key in ipairs(main.AppearanceTable.AAttachments or {}) do
            local d = hg.Accessories and hg.Accessories[key]
            if d and d.bSetColor and not seen[key] then seen[key]=true table.insert(result, key) end
        end
        return result
    end

    local function OpenAccessoryColorMenu()
        local colorable = GetColorableAccessories()
        OpenSelector("Acc. Tint", "Acc. Tint", "Accessory Color", function(scroll)
            if #colorable == 0 then
                local lbl = vgui.Create("DLabel", scroll)
                lbl:Dock(TOP)
                lbl:DockMargin(MU(6),MU(6),MU(6),MU(6))
                lbl:SetFont("ZCity_Menu_Settings_Tiny")
                lbl:SetTextColor(CLR.dim)
                lbl:SetText("Equip an accessory with color support to tint it.")
                lbl:SizeToContents()
                return
            end
            local targetKey = colorable[1]
            local function getClr()
                local base = main.AppearanceTable.AColor or color_white
                local stored = main.AppearanceTable.AAttachmentColors and main.AppearanceTable.AAttachmentColors[targetKey]
                if IsColor(stored) then return stored end
                if istable(stored) and stored.r and stored.g and stored.b then return Color(stored.r,stored.g,stored.b) end
                return base
            end
            local lbl = vgui.Create("DLabel", scroll)
            lbl:Dock(TOP)
            lbl:DockMargin(MU(6),MU(6),MU(6),MU(3))
            lbl:SetFont("ZCity_Menu_Settings_Tiny")
            lbl:SetTextColor(CLR.text)
            lbl:SetText("Select accessory:")
            lbl:SizeToContents()
            local picker = vgui.Create("DComboBox", scroll)
            picker:Dock(TOP)
            picker:DockMargin(MU(6),MU(3),MU(6),MU(6))
            picker:SetTall(MU(22))
            for _,key in ipairs(colorable) do picker:AddChoice(GetAccessoryName(key) or key, key, key==targetKey) end
            picker:SetValue(GetAccessoryName(targetKey) or targetKey)
            local mixer = vgui.Create("DColorMixer", scroll)
            mixer:Dock(TOP)
            mixer:DockMargin(MU(6),MU(3),MU(6),MU(6))
            mixer:SetTall(MU(160))
            mixer:SetPalette(false)
            mixer:SetAlphaBar(false)
            mixer:SetWangs(true)
            mixer:SetColor(getClr())
            main.AppearanceTable.AAttachmentColors = main.AppearanceTable.AAttachmentColors or {}
            function mixer:ValueChanged(c) main.AppearanceTable.AAttachmentColors[targetKey] = IsColor(c) and c or Color(c.r,c.g,c.b) end
            function picker:OnSelect(i,v,d) targetKey=d mixer:SetColor(getClr()) end
            local resetBtn = vgui.Create("DButton", scroll)
            resetBtn:Dock(TOP)
            resetBtn:DockMargin(MU(6),MU(3),MU(6),MU(6))
            resetBtn:SetTall(MU(24))
            resetBtn:SetText("Reset Color")
            resetBtn:SetFont("ZCity_Menu_Settings_Tiny")
            function resetBtn:Paint(w,h)
                surface.SetDrawColor(22,20,17,220)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(CLR.gold.r,CLR.gold.g,CLR.gold.b,80)
                surface.DrawOutlinedRect(0,0,w,h,1)
                draw.SimpleText("Reset Color", "ZCity_Menu_Settings_Tiny", w*0.5, h*0.5, CLR.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function resetBtn:DoClick()
                main.AppearanceTable.AAttachmentColors = main.AppearanceTable.AAttachmentColors or {}
                main.AppearanceTable.AAttachmentColors[targetKey] = nil
                mixer:SetColor(main.AppearanceTable.AColor or color_white)
            end
        end)
    end

    local function OpenClothesMenu(key, title, includeColor)
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelector(title, title, "Select "..title, function(scroll)
            local clothes = hg.Appearance.Clothes[modelData.sex and 2 or 1] or {}
            for k,mat in SortedPairs(clothes) do
                if type(mat) != "string" then continue end
                local tip = hg.Appearance.ClothesDesc[k] and hg.Appearance.ClothesDesc[k].desc or nil
                UI.ClothingRow(scroll, k, key, mat, main, function() return GetClothesValue(key)==k end, function()
                    main.AppearanceTable.AClothes[key] = k
                    main:SyncSharedPreview()
                    PlayDraw()
                end, tip)
            end
            if includeColor then
                local curClr = NormalizeColor(main.AppearanceTable.AColor)
                main.AppearanceTable.AColor = curClr
                local mixer = vgui.Create("DColorMixer", scroll)
                mixer:Dock(TOP)
                mixer:DockMargin(MU(6),MU(6),MU(6),MU(6))
                mixer:SetTall(MU(160))
                mixer:SetPalette(false)
                mixer:SetAlphaBar(false)
                mixer:SetWangs(true)
                mixer:SetColor(curClr)
                function mixer:ValueChanged(c)
                    main.AppearanceTable.AColor = c
                    main:SyncSharedPreview()
                end
            end
        end)
    end

    local function OpenBodygroupMenu(bgKey, title)
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelector(title, title, "Select "..title, function(scroll)
            for k,v in SortedPairs((hg.Appearance.Bodygroups[bgKey] and hg.Appearance.Bodygroups[bgKey][modelData.sex and 2 or 1]) or {}) do
                local bgID = istable(v) and v[1] or nil
                UI.BodygroupRow(scroll, k, bgKey, bgID, main, function() return (main.AppearanceTable.ABodygroups and main.AppearanceTable.ABodygroups[bgKey])==k end, function()
                    main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
                    main.AppearanceTable.ABodygroups[bgKey] = k
                    main:SyncSharedPreview()
                    PlayDraw()
                end)
            end
        end)
    end

    local function OpenGlovesMenu()
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        OpenSelector("Gloves", "Gloves", "Select gloves", function(scroll)
            for k,v in SortedPairs((hg.Appearance.Bodygroups["HANDS"] and hg.Appearance.Bodygroups["HANDS"][modelData.sex and 2 or 1]) or {}) do
                if not lply:PS_HasItem(v["ID"]) and v[2] and not hg.Appearance.GetAccessToAll(lply) then continue end
                local bgID = istable(v) and v[1] or nil
                UI.BodygroupRow(scroll, k, "HANDS", bgID, main, function() return (main.AppearanceTable.ABodygroups and main.AppearanceTable.ABodygroups["HANDS"])==k end, function()
                    main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
                    main.AppearanceTable.ABodygroups["HANDS"] = k
                    main:SyncSharedPreview()
                    PlayDraw()
                end)
            end
        end)
    end

    local function OpenFacemapMenu()
        local modelData = main:GetCurrentModelData()
        if not modelData then return end
        local fk = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelData.mdl]
        local fs = fk and hg.Appearance.FacemapsSlots[fk]
        if not fs then return end
        OpenSelector("Facemap", "Facemap", "Select facemap", function(scroll)
            for k,_ in SortedPairs(fs) do
                UI.SelectorRow(scroll, k, function() return (main.AppearanceTable.AFacemap or "Default")==k end, function()
                    main.AppearanceTable.AFacemap = k
                    main:SyncSharedPreview()
                    PlayDraw()
                end)
            end
        end)
    end

    local sidebarW = math.floor(sizeX / 3.6)
    local sidebar = vgui.Create("DScrollPanel", self)
    sidebar:SetSize(sidebarW, sizeY)
    local sbar = sidebar:GetVBar()
    sbar:SetWide(ScreenScale(4))
    sbar:SetHideButtons(true)
    function sbar:Paint(w,h) draw.RoundedBox(4,0,0,w,h,Color(18,18,18,200)) end
    function sbar.btnGrip:Paint(w,h) local c = self:IsHovered() and Color(200,200,200,240) or Color(140,140,140,240) draw.RoundedBox(4,2,2,w-4,h-4,c) end
    sidebar:SetPos(-sidebarW, 0)
    sidebar.TargetX = 0
    sidebar.Think = function(this)
        local x,y = this:GetPos()
        local tx = this.TargetX or x
        local nx = Lerp(FrameTime()*CFG.slideSpeed, x, tx)
        if math.abs(tx-nx)<1 then nx=tx end
        this:SetPos(math.Round(nx), y)
    end
    sidebar.Paint = function(this,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(16,16,16,220))
        surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
        surface.DrawRect(w-1,0,1,h)
    end

    local sidebarHeader = vgui.Create("DPanel", self)
    sidebarHeader:SetSize(sidebarW, MU(CFG.headerH))
    sidebarHeader:SetPos(0,0)
    sidebarHeader.Paint = function(this,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(24,24,24,210))
        surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,100)
        surface.DrawRect(0,h-1,w,1)
    end

    do local sp = vgui.Create("DPanel", sidebar) sp:Dock(TOP) sp:SetTall(MU(CFG.headerH)) sp.Paint = function() end end

    local sidebarTitle = vgui.Create("DLabel", sidebarHeader)
    sidebarTitle:SetPos(MU(12), MU(14))
    sidebarTitle:SetFont("ZCity_Menu_Settings_Small")
    sidebarTitle:SetTextColor(CLR.white)
    sidebarTitle:SetText("APPEARANCE")
    sidebarTitle:SizeToContents()
    sidebarTitle.OpenTime = CurTime()
    function sidebarTitle:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local chars = math.floor(elapsed*18)
        local target = "APPEARANCE"
        local len = #target
        if chars>len then chars=len end
        local ntxt = ""
        for i=1,len do if i<=chars then ntxt=ntxt..target:sub(i,i) else ntxt=ntxt.."#" end end
        if self:GetText() ~= ntxt then surface.PlaySound(SND.tap) self:SetText(ntxt) self:SizeToContents() end
    end

    local mainPanel = vgui.Create("DPanel", self)
    mainPanel:SetSize(sizeX-sidebarW, sizeY)
    mainPanel:SetPos(sizeX, 0)
    mainPanel.TargetX = sidebarW
    mainPanel.Think = function(this)
        local x,y = this:GetPos()
        local tx = this.TargetX or x
        local nx = Lerp(FrameTime()*CFG.slideSpeed, x, tx)
        if math.abs(tx-nx)<1 then nx=tx end
        this:SetPos(math.Round(nx), y)
    end
    mainPanel.Paint = function() end
    self.AppearancePreviewX = sidebarW + MU(CFG.previewShiftX)
    self.AppearancePreviewY = MU(CFG.previewShiftY)
    self:SyncSharedPreview()

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MU(CFG.headerH))
    header.Paint = function(this,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(24,24,24,210))
        surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,100)
        surface.DrawRect(0,h-1,w,1)
    end

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetPos(MU(18), MU(12))
    headerTitle:SetFont("ZCity_Menu_Settings_Small")
    headerTitle:SetTextColor(CLR.white)
    headerTitle:SetText("APPEARANCE")
    headerTitle:SizeToContents()

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MU(18), MU(30))
    headerHint:SetFont("ZCity_Menu_Settings_Tiny")
    headerHint:SetTextColor(CLR.dim)
    headerHint:SetText("Customize your look")
    headerHint:SizeToContents()

    selectorPanel = vgui.Create("DPanel", mainPanel)
    selectorPanel:SetSize(MU(CFG.selectorWidth), mainPanel:GetTall())
    selectorPanel.ClosedX = mainPanel:GetWide()
    selectorPanel.OpenX = mainPanel:GetWide() - selectorPanel:GetWide()
    selectorPanel.TargetX = selectorPanel.ClosedX
    selectorPanel:SetPos(selectorPanel.ClosedX, 0)
    selectorPanel.Paint = function(this,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(20,20,20,230))
        surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
        surface.DrawRect(0,0,1,h)
    end
    selectorPanel.Think = function(this)
        local x = this:GetX()
        local tx = this.TargetX or x
        local nx = LerpFT(0.18, x, tx)
        if math.abs(tx-nx)<1 then nx=tx end
        if not main.RestoringToMenu then
            main.SelectorOpenLerp = LerpFT(CFG.fadeSpeed, main.SelectorOpenLerp or 0, tx==this.OpenX and 1 or 0)
            if IsValid(previewNameLabel) then previewNameLabel:SetAlpha(math.Round(255*(1-(main.SelectorOpenLerp or 0)))) end
            if IsValid(nameEntry) then
                nameEntry:SetAlpha(math.Round(255*(1-(main.SelectorOpenLerp or 0))))
                nameEntry:SetMouseInputEnabled((main.SelectorOpenLerp or 0) < 0.05)
            end
            if IsValid(main.SharedPreviewHolder) then
                main.SharedPreviewHolder.TargetX = (main.AppearancePreviewX or main.SharedPreviewHolder.TargetX or main.SharedPreviewHolder:GetX()) - math.floor((main.PreviewSelectorShiftX or 0)*(main.SelectorOpenLerp or 0))
                main.SharedPreviewHolder.TargetY = main.AppearancePreviewY or main.SharedPreviewHolder.TargetY or main.SharedPreviewHolder:GetY()
            end
        end
        this:SetPos(math.Round(nx), 0)
    end

    local selectorHeader = vgui.Create("DPanel", selectorPanel)
    selectorHeader:Dock(TOP)
    selectorHeader:SetTall(MU(CFG.headerH))
    selectorHeader.Paint = function(this,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(24,24,24,210))
        surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,100)
        surface.DrawRect(0,h-1,w,1)
    end

    selectorHeaderTitle = vgui.Create("DLabel", selectorHeader)
    selectorHeaderTitle:SetPos(MU(10), MU(12))
    selectorHeaderTitle:SetFont("ZCity_Menu_Settings_Small")
    selectorHeaderTitle:SetTextColor(CLR.white)
    selectorHeaderTitle:SetText("")
    selectorHeaderTitle:SizeToContents()

    selectorHeaderHint = vgui.Create("DLabel", selectorHeader)
    selectorHeaderHint:SetPos(MU(10), MU(30))
    selectorHeaderHint:SetFont("ZCity_Menu_Settings_Tiny")
    selectorHeaderHint:SetTextColor(CLR.dim)
    selectorHeaderHint:SetText("")
    selectorHeaderHint:SizeToContents()

    selectorContent = vgui.Create("DPanel", selectorPanel)
    selectorContent:Dock(FILL)
    selectorContent:DockMargin(0,0,0,MU(6))
    selectorContent.Paint = function() end

    previewNameLabel = vgui.Create("DLabel", mainPanel)
    previewNameLabel:SetFont("ZCity_Menu_Settings_Tiny")
    previewNameLabel:SetTextColor(CLR.dim)
    previewNameLabel:SetText("NAME")
    previewNameLabel:SizeToContents()
    previewNameLabel:SetPos(self.AppearancePreviewX - sidebarW, MU(68))

    nameEntry = vgui.Create("DTextEntry", mainPanel)
    nameEntry:SetSize(MU(CFG.nameWidth), MU(22))
    nameEntry:SetPos(self.AppearancePreviewX - sidebarW - MU(6), MU(84))
    nameEntry:SetFont("ZCity_Menu_Settings_Tiny")
    nameEntry:SetText(main.AppearanceTable.AName or "")
    nameEntry:SetUpdateOnType(true)
    nameEntry:SetContentAlignment(5)
    nameEntry.Paint = function(this,w,h)
        draw.RoundedBox(4,0,0,w,h,Color(16,16,16,245))
        local c = this:HasFocus() and CLR.accent or CLR.accentDim
        surface.SetDrawColor(c.r,c.g,c.b,160)
        surface.DrawOutlinedRect(0,0,w,h,1)
        this:DrawTextEntryText(Color(235,235,235), Color(140,140,140), CLR.accent)
    end
    function nameEntry:OnValueChange(val) main.AppearanceTable.AName=val main:SyncSharedPreview() end

    do
        local rp = vgui.Create("DPanel", mainPanel)
        rp:SetSize(MU(240), MU(26))
        rp:SetPos(mainPanel:GetWide()/2-MU(120), mainPanel:GetTall()-MU(36))
        rp.Paint = function(this,w,h)
            draw.RoundedBox(4,0,0,w,h,Color(22,22,22,200))
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
            surface.DrawOutlinedRect(0,0,w,h,1)
        end
        local rl = vgui.Create("DLabel", rp)
        rl:SetPos(MU(5), MU(2))
        rl:SetSize(MU(34), MU(22))
        rl:SetFont("ZCity_Menu_Settings_Tiny")
        rl:SetTextColor(CLR.dim)
        rl:SetText("Rotate")
        rl:SizeToContents()
        local rs = vgui.Create("DSlider", rp)
        rs:SetPos(MU(38), MU(7))
        rs:SetSize(MU(164), MU(12))
        rs:SetTrapInside(true)
        function rs:Paint(w,h)
            draw.RoundedBox(3,0,h*0.5-3,w,6,Color(40,40,40,220))
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
            surface.DrawOutlinedRect(0,h*0.5-3,w,6,1)
        end
        function rs.Knob:Paint(w,h)
            draw.RoundedBox(3,2,MU(1),w-4,h-MU(2),CLR.accent)
        end
        local rv = vgui.Create("DLabel", rp)
        rv:SetPos(MU(206), MU(2))
        rv:SetSize(MU(30), MU(22))
        rv:SetFont("ZCity_Menu_Settings_Tiny")
        rv:SetTextColor(CLR.dim)
        rv:SetText("0"..string.upper("\194\176"))
        rv:SetContentAlignment(6)
        function rs:OnValueChanged(fr)
            main.PreviewRotation = fr*360
            rv:SetText(tostring(math.Round(main.PreviewRotation))..string.upper("\194\176"))
            main:SyncSharedPreview()
        end
        rs:SetSlideX(0)
    end

    savedSnapshot = BuildComparable(main.AppearanceTable)

    UI.TextButton(sidebar, "Model", function() OpenModelMenu() end, function() return main.ActiveSection=="Model" end)
    UI.TextButton(sidebar, "Hat", function() OpenAccessorySlot(1,"Hat",{head=true,ears=true}) end, function() return main.ActiveSection=="Hat" end)
    UI.TextButton(sidebar, "Face", function() OpenAccessorySlot(2,"Face",{face=true}) end, function() return main.ActiveSection=="Face" end)
    UI.TextButton(sidebar, "Body", function() OpenAccessorySlot(3,"Body",{torso=true,spine=true}) end, function() return main.ActiveSection=="Body" end)
    UI.TextButton(sidebar, "Hair", function() OpenAccessorySlot(4,"Hair",{head1=true}) end, function() return main.ActiveSection=="Hair" end)
    UI.TextButton(sidebar, "Mask", function() OpenAccessorySlot(5,"Mask",{face2=true}) end, function() return main.ActiveSection=="Mask" end)
    UI.TextButton(sidebar, "Body 2", function() OpenAccessorySlot(6,"Body 2",{spine2=true}) end, function() return main.ActiveSection=="Body 2" end)
    UI.TextButton(sidebar, "Acc. Tint", function() OpenAccessoryColorMenu() end, function() return main.ActiveSection=="Acc. Tint" end)

    do local sp = vgui.Create("DPanel", sidebar) sp:Dock(TOP) sp:SetTall(MU(6)) sp.Paint = function() end end

    UI.TextButton(sidebar, "Jacket", function() OpenClothesMenu("main","Jacket",true) end, function() return main.ActiveSection=="Jacket" end)
    UI.TextButton(sidebar, "Pants", function() OpenClothesMenu("pants","Pants") end, function() return main.ActiveSection=="Pants" end)
    UI.TextButton(sidebar, "Boots", function() OpenClothesMenu("boots","Boots") end, function() return main.ActiveSection=="Boots" end)
    UI.TextButton(sidebar, "Gloves", function() OpenGlovesMenu() end, function() return main.ActiveSection=="Gloves" end)

    do local sp = vgui.Create("DPanel", sidebar) sp:Dock(TOP) sp:SetTall(MU(6)) sp.Paint = function() end end

    UI.TextButton(sidebar, "Facemap", function() OpenFacemapMenu() end, function() return main.ActiveSection=="Facemap" end)
    UI.TextButton(sidebar, "Torso Shape", function() OpenBodygroupMenu("TORSO","Torso Shape") end, function() return main.ActiveSection=="Torso Shape" end)
    UI.TextButton(sidebar, "Legs Shape", function() OpenBodygroupMenu("LEGS","Legs Shape") end, function() return main.ActiveSection=="Legs Shape" end)

    do
        local sp = vgui.Create("DPanel", sidebar)
        sp:Dock(TOP)
        sp:DockMargin(MU(6), MU(12), MU(6), MU(3))
        sp:SetTall(MU(66))
        sp.Paint = function(self,w,h)
            draw.RoundedBox(4,0,0,w,h,Color(22,22,22,180))
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
            surface.DrawOutlinedRect(0,0,w,h,1)
        end
        local function addSlider(parent, title, valueKey)
            local row = vgui.Create("DPanel", parent)
            row:Dock(TOP)
            row:SetTall(MU(30))
            row:DockMargin(MU(2),0,MU(2),MU(1))
            row.Paint = function() end
            local tl = vgui.Create("DLabel", row)
            tl:Dock(LEFT)
            tl:SetWidth(MU(28))
            tl:SetFont("ZCity_Menu_Settings_Tiny")
            tl:SetText(title)
            tl:SetTextColor(CLR.text)
            tl:SetContentAlignment(4)
            local vl = vgui.Create("DLabel", row)
            vl:Dock(RIGHT)
            vl:SetWidth(MU(28))
            vl:SetFont("ZCity_Menu_Settings_Tiny")
            vl:SetTextColor(CLR.text)
            vl:SetContentAlignment(6)
            local slider = vgui.Create("DSlider", row)
            slider:Dock(FILL)
            slider:DockMargin(MU(3),MU(4),MU(3),MU(4))
            slider:SetTrapInside(true)
            function slider:Paint(w,h)
                draw.RoundedBox(3,0,h*0.5-3,w,6,Color(40,40,40,220))
                surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,50)
                surface.DrawOutlinedRect(0,h*0.5-3,w,6,1)
            end
            function slider.Knob:Paint(w,h)
                draw.RoundedBox(3,2,MU(1),w-4,h-MU(2),CLR.accent)
            end
            local function refresh()
                local val = APmodule.NormalizeHeight(main.AppearanceTable[valueKey])
                main.AppearanceTable[valueKey] = val
                vl:SetText(val.."%")
                slider._lock = true
                slider:SetSlideX((val-APmodule.HeightMin)/(APmodule.HeightMax-APmodule.HeightMin))
                slider._lock = nil
            end
            function slider:OnValueChanged(fr)
                if self._lock then return end
                local val = math.Round(APmodule.HeightMin+(APmodule.HeightMax-APmodule.HeightMin)*fr)
                val = APmodule.NormalizeHeight(val)
                self._lock = true
                slider:SetSlideX((val-APmodule.HeightMin)/(APmodule.HeightMax-APmodule.HeightMin))
                self._lock = nil
                main.AppearanceTable[valueKey] = val
                vl:SetText(val.."%")
                main:SyncSharedPreview()
            end
            refresh()
            return row
        end
        addSlider(sp, "Height", "AHeight")
        addSlider(sp, "Weight", "ABodySize")
    end

    local returnBtn = vgui.Create("DLabel", self)
    returnBtn:SetPos(MU(10), sizeY - MU(26))
    returnBtn:SetFont("ZCity_Menu_Settings_Tiny")
    returnBtn:SetTextColor(CLR.text)
    returnBtn:SetText(string.rep("#", #"<- Return"))
    returnBtn:SetMouseInputEnabled(true)
    returnBtn:SizeToContents()
    returnBtn:SetTall(MU(24))
    returnBtn.OpenTime = CurTime()
    returnBtn.HoverLerp = 0
    returnBtn.LineLerp = 0
    returnBtn.HoverScale = 0.008
    function returnBtn:DoClick() TryExit() end
    function returnBtn:Think()
        local hov = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, hov and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, hov and 1 or 0)
        local elapsed = CurTime() - self.OpenTime
        local chars = math.floor(elapsed*15)
        local target = "<- Return"
        local len = #target
        if chars>len then chars=len end
        local ntxt = ""
        for i=1,len do if i<=chars then ntxt=ntxt..target:sub(i,i) else ntxt=ntxt.."#" end end
        if self:GetText() ~= ntxt then surface.PlaySound(SND.tap) self:SetText(ntxt) self:SizeToContents() end
    end
    function returnBtn:Paint(w,h)
        local hov = self:IsHovered()
        local tc = CLR.text
        if hov then tc = Color(235,225,210,255) end
        if hov then
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b,160)
            surface.DrawRect(0, MU(3), MU(2), h-MU(6))
        end
        surface.SetFont(self:GetFont())
        local tw,th = surface.GetTextSize(self:GetText())
        local sc = 1 + (self.HoverLerp or 0)*(self.HoverScale or 0.02)
        local m = Matrix()
        m:Translate(Vector(0, h*(1-sc)*0.5, 0))
        m:Scale(Vector(sc,sc,1))
        cam.PushModelMatrix(m)
        draw.SimpleText(self:GetText(), self:GetFont(), 0, h/2, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(CLR.accent.r,CLR.accent.g,CLR.accent.b, 160*self.LineLerp)
            surface.DrawRect(0, h/2+th/2, tw*self.LineLerp, 1)
        end
        cam.PopModelMatrix()
        return true
    end

    local lowerActions = vgui.Create("DPanel", sidebar)
    lowerActions:Dock(TOP)
    lowerActions:DockMargin(MU(6), MU(6), MU(6), MU(3))
    lowerActions:SetTall(MU(CFG.actBtnH)*4 + MU(6))
    lowerActions.Paint = function() end

    local applyBtn = UI.ActionButton(lowerActions, "Apply", function() main.ActiveSection="Apply" CloseSelectorPanel() ApplyAppearance() end, function() return main.ActiveSection=="Apply" end)
    local saveBtn = UI.ActionButton(lowerActions, "Save Preset", function() main.ActiveSection="Save Preset" CloseSelectorPanel() SavePresetUI() end, function() return main.ActiveSection=="Save Preset" end)
    local loadBtn = UI.ActionButton(lowerActions, "Load Preset", function() main.ActiveSection="Load Preset" CloseSelectorPanel() LoadPresetUI() end, function() return main.ActiveSection=="Load Preset" end)
    local delBtn = UI.ActionButton(lowerActions, "Delete Preset", function() main.ActiveSection="Delete Preset" CloseSelectorPanel() DeletePresetUI() end, function() return main.ActiveSection=="Delete Preset" end)
    applyBtn.StartDelay = 0
    saveBtn.StartDelay = 0.04
    loadBtn.StartDelay = 0.08
    delBtn.StartDelay = 0.12

    function self:Close() TryExit() end
    self:CallbackAppearance()
    hook.Run("HG_AppearanceMenuReady", main)
end

vgui.Register("HG_AppearanceMenu", PANEL, "ZFrame")

concommand.Add("hg_appearance_menu", function()
    print('use esc menu')
end)

function hg.CreateApperanceMenu(ParentPanel)
    if hg.Appearance.PrecacheModels then
        hg.Appearance.PrecacheModels()
    end

    hg.PointShop:SendNET("SendPointShopVars", nil, function(data)
        if IsValid(zpan) then
            zpan:Close()
        end
        zpan = vgui.Create("HG_AppearanceMenu", ParentPanel)
        zpan:SetSize(ParentPanel:GetWide(), ParentPanel:GetTall())
        zpan:SetPos(0, 0)
    end)
end