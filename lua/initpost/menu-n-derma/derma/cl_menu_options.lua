hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString, category )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false, category }
end
local hg_firstperson_death = CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 1)
local hg_font = CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

xbars = 17
ybars = 30

gradient_l = Material("vgui/gradient-l")

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local sw, sh = ScrW(), ScrH()

local font = function()
    local usefont = "Verily Serif Mono"

    if hg_font:GetString() != "" and hg_font:GetString() != "Bahnschrift" then
        usefont = hg_font:GetString()
    end

    return usefont
end

local function MenuUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local settings_header_height = 70

local function CreateSettingsFonts()
    local usefont = font()
    local scale = math.min(ScrW(), ScrH()) / 1000

    surface.CreateFont("ZCity_Settings_Medium", {
        font = usefont,
        size = math.max(16, math.floor(32 * scale)),
        weight = 300,
    })
    surface.CreateFont("ZCity_Settings_Small", {
        font = usefont,
        size = math.max(14, math.floor(22 * scale)),
        weight = 300,
    })
    surface.CreateFont("ZCity_Settings_Tiny", {
        font = usefont,
        size = math.max(12, math.floor(16 * scale)),
        weight = 300,
    })
end
hook.Add("OnScreenSizeChanged", "ZCity_Settings_Fonts", CreateSettingsFonts)
CreateSettingsFonts()

surface.CreateFont("ZCity_setiings_tiny", {
	font = font(),
	size = ScreenScale(7),
	weight = 100
})

surface.CreateFont("ZCity_setiings_fine", {
	font = font(),
	size = ScreenScale(10),
	weight = 100
})

surface.CreateFont("ZCity_setiings_category", {
	font = font(),
	size = ScreenScale(15),
	weight = 100
})


hg.settings:AddOpt("Gameplay","hg_old_notificate", "Old Notifications")
hg.settings:AddOpt("Gameplay","hg_cheats", "Enable Cheats")
hg.settings:AddOpt("Gameplay","hg_showthoughts", "Show thoughts")
hg.settings:AddOpt("Gameplay","hg_hints", "Show hints")
hg.settings:AddOpt("Gameplay","hg_gary", "HG GARY")
hg.settings:AddOpt("Gameplay","hg_deathfadeout", "Death fade out")
if not game.IsDedicated() then
	hg.settings:AddOpt("Serverside gameplay","hg_toughnpcs", "Tough npcs")
	hg.settings:AddOpt("Serverside gameplay","hg_thirdperson", "Thirdperson (WIP)")
	hg.settings:AddOpt("Serverside gameplay","hg_legacycam", "Legacy camera")
	hg.settings:AddOpt("Serverside gameplay","hg_ragdollcombat", "Ragdoll combat mode")
	hg.settings:AddOpt("Serverside gameplay","hg_movement_stamina_debuff", "Movement stamina debuff")
	hg.settings:AddOpt("Serverside gameplay","hg_furcity", "Furcity")
	hg.settings:AddOpt("Serverside gameplay","hg_appearance_access_for_all", "Appearance full access for all", nil, nil, "bool")
	hg.settings:AddOpt("Serverside gameplay","hg_healanims", "Heal & food animations")
	hg.settings:AddOpt("Serverside gameplay","hg_aimtoshoot", "DarkRP-like shoot system (aim to shoot)")
	hg.settings:AddOpt("Serverside gameplay","hg_slings", "Sling system")
    hg.settings:AddOpt("Serverside gameplay","homicide_traitoramount", "Homicide: Traitor Amount", nil, nil, "int")
end

hg.settings:AddOpt("Debug","hg_show_hitposmuzzle", "Show weapon hitpos")
hg.settings:AddOpt("Debug","hg_setzoompos", "Edit weapon zoompos, check console for results")
hg.settings:AddOpt("Debug","hg_show_hitbox", "Show hitboxes")

hg.settings:AddOpt("Optimization","hg_potatopc", "Potato PC Mode")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "Animations Draw Distance", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_anim_fps", "Animations FPS", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "Attachment Draw Distance", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "Maximum Smoke Trails", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK Render Distance", true, nil, "int")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "Blood Draw Distance")
hg.settings:AddOpt("Blood","hg_blood_fps", "Blood FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "Blood Sprites (DISABLED FOR EVERYONE)")
hg.settings:AddOpt("Blood","hg_old_blood", "Old blood")

hg.settings:AddOpt("UI","hg_font", "Change Custom Font", false, true)

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "Shooting Blur")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "Dynamic Ammo Inspect")
hg.settings:AddOpt("Weapons","hg_zoomsensitivity", "Scope sensitivity")
hg.settings:AddOpt("Weapons","hg_highpitchgunfire", "Toggle high pitched gunfire sounds inside buildings")

hg.settings:AddOpt("View","hg_firstperson_death", "First-Person Death")
hg.settings:AddOpt("View","hg_fov", "Field Of View")
hg.settings:AddOpt("View","hg_newspectate", "Smooth Spectator Camera")
hg.settings:AddOpt("View","hg_cshs_fake", "C'sHS Ragdoll Camera")
hg.settings:AddOpt("View","hg_gun_cam", "Gun Camera (ADMIN ONLY)")
hg.settings:AddOpt("View","hg_nofovzoom", "Disable/Enable FOV Zoom")
hg.settings:AddOpt("View","hg_realismcam", "Realism camera (shitty)")
hg.settings:AddOpt("View","hg_gopro", "GoPro camera")
hg.settings:AddOpt("View","hg_newfakecam", "New fake camera")
hg.settings:AddOpt("View","hg_leancam_mul", "Lean camera mul", true, nil, "int")
hg.settings:AddOpt("View","hg_gun_cam", "Gun camera (WIP Admin only)")
hg.settings:AddOpt("Sound","hg_dmusic", "Dynamic Music")
hg.settings:AddOpt("Sound","hg_quietshots", "Enable/Disable Quietshoot Sounds")


function hg.CreateCategory(ctgName, ParentPanel, yPos)
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide() / 1.05, ParentPanel:GetTall() * 0.07)
    pppanel:SetPos(ParentPanel:GetWide() / 2 -pppanel:GetWide() / 2, yPos)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(60,60,60,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(42, 42, 42, 184)
		surface.DrawRect(0, h-5, w, 5)
    
        draw.SimpleText(ctgName, 'ZCity_setiings_category', w / 2, h / 2, color3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return pppanel
end

function hg.GetConVarType(convar)
    local stringv = convar:GetString()
    local floatVal = convar:GetFloat()
    local intVal = convar:GetInt()
    local boolVal = convar:GetBool()

    if (stringv == '0' and not boolVal) or (stringv == '1' and boolVal) then
        return 'bool'
    end

    if tonumber(stringv) and math.floor(stringv) == floatVal then
        if intVal == floatVal then
            return "int"
        end
    end

    return "string"
end

local function SetConVarValue(convar, value)
    if not convar then
        return
    end

    local name = convar.GetName and convar:GetName()
    if not name or name == "" then
        return
    end

    if isbool(value) then
        RunConsoleCommand(name, value and "1" or "0")
        return
    end

    RunConsoleCommand(name, tostring(value))
end

local clr_1 = Color(255,255,255,104)
local clr_2 = Color(122,122,122,104)
local clr_3 = Color(28,28,28)
local clr_4 = Color(0, 0, 0, 30)
local clr_5 = Color(30, 29, 29, 30)
local clr_6 = Color(255, 255, 255, 100)
local clr_7 = Color(255, 255, 255, 200)
local clr_8 = Color(70, 130, 180)

local settings_color_blacky = Color(25,25,30,220)
local settings_color_whitey = Color(255,255,255,240)
local settings_color_dim = Color(60,60,60,180)
local settings_color_text = Color(225,225,225)
local settings_color_text_dim = Color(160,160,160)
local settings_color_accent = Color(192,57,43)

local tex_gradient_d = surface.GetTextureID("vgui/gradient-d")
local tex_gradient_r = surface.GetTextureID("vgui/gradient-r")
local tex_gradient_l = surface.GetTextureID("vgui/gradient-l")
local settings_menu_gradient_right = Color(18,18,18,65)
local settings_clr_1 = Color(100,100,100,35)
local settings_clr_verygray = Color(10,10,19,235)

local settings_sw, settings_sh = ScrW(), ScrH()
local settings_active_category = nil
local settings_buttons = {}
local settings_category_buttons = {}
local settings_content_panel = nil
local settings_sidebar_panel = nil
local settings_main_panel = nil
local settings_header_label = nil
local isValidMainMenuPanel = false

local function SettingsCreateCategoryButton(pParent, strTitle, categoryKey)
    local id = #settings_category_buttons + 1
    settings_category_buttons[id] = vgui.Create("DLabel", pParent)
    local btn = settings_category_buttons[id]
    btn:SetText(string.rep("#", #strTitle))
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Settings_Small")
    btn:SetTall(MenuUnit(42))
    btn:Dock(TOP)
    btn:DockMargin(MenuUnit(15), MenuUnit(2), 0, 0)
    btn.CategoryKey = categoryKey
    btn.RColor = Color(225,225,225)
    btn.OpenTime = CurTime()
    btn.LineLerp = 0
    btn.HoverLerp = 0
    btn.MouseDriftX = 0
    btn.MouseDriftY = 0
    btn.ShakeX = 0
    btn.ShakeY = 0

    function btn:DoClick()
        if not IsValid(self) then return end
        surface.PlaySound("shitty/tap_depress.wav")
        settings_active_category = self.CategoryKey
        SettingsRefreshContent()
    end

    function btn:Think()
        local isHovered = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)

        if isValidMainMenuPanel then
            local mx, my = self.MouseDriftX, self.MouseDriftY
            local sx, sy = self.ShakeX, self.ShakeY
            self:DockMargin(
                math.Round(MenuUnit(15) + mx * 0.3 + sx + self.HoverLerp * MenuUnit(2)),
                math.Round(MenuUnit(2) + my * 0.1 + sy),
                0, 0
            )
        end

        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local isActive = (settings_active_category == self.CategoryKey)
        local targetText = isActive and ('[ '..strTitle..' ]') or strTitle
        local len = #targetText
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. targetText:sub(i, i)
            else ntxt = ntxt .. "#" end
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
        local scale = 1 + (self.HoverLerp or 0) * 0.02
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

function SettingsRefreshCategoryButtons()
    for _, btn in ipairs(settings_category_buttons) do
        if IsValid(btn) then
            btn.OpenTime = CurTime()
        end
    end
end

function SettingsRefreshContent()
    if not IsValid(settings_content_panel) then return end
    settings_content_panel:Clear()

    if not settings_active_category or not hg.settings.tbl[settings_active_category] then
        return
    end

    if IsValid(settings_header_label) then
        settings_header_label:SetText(settings_active_category:upper())
    end

    local scroll = vgui.Create("DScrollPanel", settings_content_panel)
    scroll:Dock(FILL)
    scroll:DockMargin(0, 0, 0, 0)
    scroll.Paint = function(self, w, h) end

    local sbar = scroll:GetVBar()
    sbar:SetWide(MenuUnit(4))
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 80)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnGrip:Paint(w, h)
        local col = self:IsHovered() and settings_color_whitey or settings_color_dim
        draw.RoundedBox(2, 1, 1, w - 2, h - 2, col)
    end

    local yOffset = MenuUnit(10)
    local sidebarWidth = math.floor(settings_sw / 3.6)
    local entryWidth = settings_sw - sidebarWidth

    for convarName, settingData in SortedPairs(hg.settings.tbl[settings_active_category]) do
        local convar = GetConVar(settingData[2])
        if not convar then continue end

        local row = vgui.Create("DPanel", scroll)
        row:SetSize(entryWidth - MenuUnit(20), MenuUnit(56))
        row:Dock(TOP)
        row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
        row.Paint = function(self, w, h)
            surface.SetDrawColor(20, 20, 30, 120)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 90)
            surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        end

        local title = vgui.Create("DLabel", row)
        title:SetPos(MenuUnit(12), MenuUnit(6))
        title:SetFont("ZCity_Settings_Small")
        title:SetTextColor(settings_color_text)
        title:SetText(settingData[3])
        title:SizeToContents()

        local help = vgui.Create("DLabel", row)
        help:SetPos(MenuUnit(12), MenuUnit(28))
        help:SetFont("ZCity_Settings_Tiny")
        help:SetTextColor(settings_color_text_dim)
        help:SetText(convar:GetHelpText() or "")
        help:SizeToContents()
        help:SetWide(entryWidth - MenuUnit(220))

        local convarType = settingData[6] or hg.GetConVarType(convar)
        local ctrlX = entryWidth - MenuUnit(32)
        local ctrlW = MenuUnit(170)

        if convarType == 'bool' then
            local toggle = vgui.Create("DButton", row)
            toggle:SetSize(MenuUnit(46), MenuUnit(22))
            toggle:SetPos(ctrlX - toggle:GetWide(), MenuUnit(17))
            toggle:SetText("")
            local animProgress = convar:GetBool() and 1 or 0
            local targetProgress = animProgress
            function toggle:Paint(w, h)
                animProgress = Lerp(FrameTime() * 8, animProgress, targetProgress)
                local bgR = Lerp(animProgress, 60, 155)
                local bgG = Lerp(animProgress, 60, 30)
                local bgB = Lerp(animProgress, 60, 30)
                draw.RoundedBox(MenuUnit(3), 0, 0, w, h, Color(20, 20, 20, 230))
                draw.RoundedBox(MenuUnit(3), 1, 1, w - 2, h - 2, Color(bgR, bgG, bgB, 200))
                local slsize = h - MenuUnit(6)
                local slPos = Lerp(animProgress, MenuUnit(3), w - slsize - MenuUnit(3))
                surface.SetDrawColor(245, 245, 245)
                draw.RoundedBox(MenuUnit(2), slPos, MenuUnit(3), slsize, slsize, Color(245, 245, 245))
            end
            function toggle:DoClick()
                local newValue = not convar:GetBool()
                if convar.GetName then
                    RunConsoleCommand(convar:GetName(), newValue and "1" or "0")
                end
                surface.PlaySound('glide/headlights_on.wav')
                targetProgress = newValue and 1 or 0
            end

        elseif convarType == 'int' then
            local decimals = settingData[4] and 2 or 0
            local min = convar:GetMin() or 0
            local max = convar:GetMax() or 100
            
            local sliderBg = vgui.Create("DButton", row)
            sliderBg:SetSize(ctrlW - MenuUnit(50), MenuUnit(24))
            sliderBg:SetPos(ctrlX - sliderBg:GetWide(), MenuUnit(16))
            sliderBg:SetText("")
            
            local curVal = decimals > 0 and convar:GetFloat() or convar:GetInt()
            local frac = math.Clamp((curVal - min) / math.max(0.0001, max - min), 0, 1)
            
            function sliderBg:Paint(w, h)
                local trackY = h / 2 - MenuUnit(1)
                surface.SetDrawColor(20, 20, 20, 230)
                surface.DrawRect(0, trackY, w, MenuUnit(2))
                
                surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 220)
                surface.DrawRect(0, trackY, w * frac, MenuUnit(2))
                
                local knobX = math.Clamp(w * frac - MenuUnit(3), 0, w - MenuUnit(6))
                surface.SetDrawColor(245, 245, 245)
                draw.RoundedBox(MenuUnit(2), knobX, h / 2 - MenuUnit(4), MenuUnit(6), MenuUnit(8), Color(245, 245, 245))
            end
            
            local isDragging = false
            
            function sliderBg:OnMousePressed(mouseCode)
                if mouseCode == MOUSE_LEFT then
                    isDragging = true
                    self:MouseCapture(true)
                end
            end
            
            function sliderBg:OnMouseReleased(mouseCode)
                if mouseCode == MOUSE_LEFT then
                    isDragging = false
                    self:MouseCapture(false)
                end
            end
            
            function sliderBg:OnCursorMoved(x, y)
                if isDragging then
                    frac = math.Clamp(x / self:GetWide(), 0, 1)
                    local val = min + frac * (max - min)
                    if decimals > 0 then
                        val = math.Round(val, decimals)
                    else
                        val = math.Round(val)
                    end
                    if convar and convar.GetName then
                        RunConsoleCommand(convar:GetName(), tostring(val))
                    end
                end
            end
            
            function sliderBg:Think()
                if not isDragging and convar then
                    local cur = decimals > 0 and convar:GetFloat() or convar:GetInt()
                    frac = math.Clamp((cur - min) / math.max(0.0001, max - min), 0, 1)
                end
            end

            local valLabel = vgui.Create("DTextEntry", row)
            valLabel:SetSize(MenuUnit(60), MenuUnit(20))
            valLabel:SetPos(ctrlX - sliderBg:GetWide() - MenuUnit(70), MenuUnit(18))
            valLabel:SetFont("ZCity_Settings_Tiny")
            valLabel:SetTextColor(settings_color_text)
            valLabel:SetText(tostring(curVal))
            valLabel:SetNumeric(true)
            valLabel.Paint = function(self, w, h)
                self:DrawTextEntryText(settings_color_text, Color(120, 130, 180), settings_color_text)
            end
            
            function valLabel:OnValueChange(val)
                if not isDragging and convar and convar.GetName then
                    local numVal = tonumber(val)
                    if numVal then
                        if decimals > 0 then
                            numVal = math.Round(numVal, decimals)
                        else
                            numVal = math.Round(numVal)
                        end
                        RunConsoleCommand(convar:GetName(), tostring(numVal))
                    end
                end
            end
            
            function valLabel:Think()
                if convar and not self:HasFocus() then
                    local cur = decimals > 0 and convar:GetFloat() or convar:GetInt()
                    if self:GetText() ~= tostring(cur) then
                        self:SetText(tostring(cur))
                    end
                end
            end

        elseif convarType == 'string' then
            local textEntry = vgui.Create("DTextEntry", row)
            textEntry:SetSize(ctrlW, MenuUnit(24))
            textEntry:SetPos(ctrlX - ctrlW, MenuUnit(16))
            textEntry:SetText(convar:GetString())
            textEntry:SetUpdateOnType(true)
            textEntry:SetFont("ZCity_Settings_Tiny")
            textEntry.Paint = function(self, w, h)
                surface.SetDrawColor(20, 20, 20, 240)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 120)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                self:DrawTextEntryText(color_white, Color(120, 130, 180), color_white)
            end
            function textEntry:OnValueChange(val)
                if convar and convar.GetName then
                    RunConsoleCommand(convar:GetName(), val)
                end
            end
        end

        yOffset = yOffset + row:GetTall() + MenuUnit(8)
    end
end

function hg.DrawSettings(ParentPanel)
    settings_sw, settings_sh = ScrW(), ScrH()
    isValidMainMenuPanel = IsValid(ParentPanel)

    ParentPanel:SetAlpha(0)
    ParentPanel.Paint = function(self, w, h)
        if hg.DrawBlur then hg.DrawBlur(self, 5) end
        draw.RoundedBox(0, 0, 0, w, h, settings_clr_verygray)
        surface.SetDrawColor(settings_menu_gradient_right)
        surface.SetTexture(tex_gradient_r)
        surface.DrawTexturedRect(0,0,w,h)
        surface.SetDrawColor(settings_clr_verygray)
        surface.SetTexture(tex_gradient_l)
        surface.DrawTexturedRect(0,0,w,h)
        surface.SetDrawColor(settings_clr_1)
        surface.SetTexture(tex_gradient_d)
        surface.DrawTexturedRect(0,0,w,h)
    end
    ParentPanel:AlphaTo(255, 0.15, 0)

    settings_category_buttons = {}
    settings_buttons = {}

    local isSuperAdmin = LocalPlayer():IsSuperAdmin()

    local allowedCategories = {}
    for categoryName, _ in pairs(hg.settings.tbl) do
        if (categoryName == "Debug" or categoryName == "Serverside gameplay") and not isSuperAdmin then
            continue
        end
        allowedCategories[categoryName] = true
    end

    if not settings_active_category or not allowedCategories[settings_active_category] then
        for categoryName, _ in pairs(allowedCategories) do
            settings_active_category = categoryName
            break
        end
    end

    local sidebarWidth = math.floor(settings_sw / 3.6)
    local sidebar = vgui.Create("DPanel", ParentPanel)
    settings_sidebar_panel = sidebar
    sidebar:SetSize(sidebarWidth, settings_sh)
    sidebar:SetPos(-sidebarWidth, 0)
    sidebar.TargetX = 0
    sidebar.Think = function(self)
        local curX, curY = self:GetPos()
        if math.abs(curX - self.TargetX) > 0.5 then
            self:SetPos(Lerp(FrameTime() * 8, curX, self.TargetX), curY)
        else
            self:SetPos(self.TargetX, curY)
        end
    end
    sidebar:DockMargin(0, 0, 0, 0)
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 15, 120))
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 90)
        surface.DrawRect(w - MenuUnit(1), 0, MenuUnit(1), h)
    end

    local sidebarHeader = vgui.Create("DPanel", sidebar)
    sidebarHeader:Dock(TOP)
    sidebarHeader:SetTall(MenuUnit(settings_header_height))
    sidebarHeader.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local sidebarHeaderTitle = vgui.Create("DLabel", sidebarHeader)
    sidebarHeaderTitle:SetPos(MenuUnit(15), MenuUnit(18))
    sidebarHeaderTitle:SetFont("ZCity_Settings_Small")
    sidebarHeaderTitle:SetTextColor(settings_color_whitey)
    sidebarHeaderTitle:SetText("SETTINGS")
    sidebarHeaderTitle:SizeToContents()
    sidebarHeaderTitle.OpenTime = CurTime()
    function sidebarHeaderTitle:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local charsToShow = math.floor(elapsed * 18)
        local target = "SETTINGS"
        local len = #target
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    for categoryName, _ in SortedPairs(hg.settings.tbl) do
        if (categoryName == "Debug" or categoryName == "Serverside gameplay") and not isSuperAdmin then
            continue
        end
        SettingsCreateCategoryButton(sidebar, categoryName, categoryName)
    end

    local backBtn = vgui.Create("DLabel", sidebar)
    backBtn:Dock(BOTTOM)
    backBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(20))
    backBtn:SetFont("ZCity_Settings_Small")
    backBtn:SetTextColor(settings_color_text)
    backBtn:SetText(string.rep("#", #"<- Return"))
    backBtn:SetMouseInputEnabled(true)
    backBtn:SizeToContents()
    backBtn:SetTall(MenuUnit(42))
    backBtn.OpenTime = CurTime()
    backBtn.HoverLerp = 0
    backBtn.LineLerp = 0
    backBtn.HoverScale = 0.008
    function backBtn:DoClick()
        if IsValid(ParentPanel) then 
            local luaMenu = ParentPanel:GetParent()
            ParentPanel:AlphaTo(0, 0.2, 0, function()
                if IsValid(ParentPanel) then ParentPanel:Remove() end
            end)
            if IsValid(luaMenu) then
                for _, child in ipairs(luaMenu:GetChildren()) do
                    if child ~= ParentPanel then
                        child:SetVisible(true)
                        child:AlphaTo(255, 0.2, 0)
                    end
                end
                if luaMenu.panelparrent then
                    luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
                    luaMenu.panelparrent:SetPos(0, 0)
                    luaMenu.panelparrent:SetSize(ScrW(), ScrH())
                    luaMenu.panelparrent:MoveToFront()
                    luaMenu.panelparrent:SetMouseInputEnabled(false)
                    luaMenu.panelparrent.Paint = function() end
                end
                if luaMenu.ResetCurrentPanel then
                    luaMenu:ResetCurrentPanel()
                end
            else
                ParentPanel:Remove()
            end
        end
    end
    function backBtn:Think()
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
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end
    function backBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = settings_color_text
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

    local mainPanel = vgui.Create("DPanel", ParentPanel)
    settings_main_panel = mainPanel
    mainPanel:SetSize(settings_sw - sidebarWidth, settings_sh)
    mainPanel:SetPos(settings_sw, 0)
    mainPanel.TargetX = sidebarWidth
    mainPanel.Think = function(self)
        local curX, curY = self:GetPos()
        if math.abs(curX - self.TargetX) > 0.5 then
            self:SetPos(Lerp(FrameTime() * 8, curX, self.TargetX), curY)
        else
            self:SetPos(self.TargetX, curY)
        end
    end
    mainPanel.Paint = function(self, w, h) end

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 0)
    header:SetTall(MenuUnit(settings_header_height))
    header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetPos(MenuUnit(25), MenuUnit(18))
    headerTitle:SetFont("ZCity_Settings_Medium")
    headerTitle:SetTextColor(settings_color_whitey)
    headerTitle:SetText(settings_active_category and settings_active_category:upper() or "SETTINGS")
    headerTitle:SetWide(settings_sw - sidebarWidth - MenuUnit(50))
    settings_header_label = headerTitle

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MenuUnit(25), MenuUnit(45))
    headerHint:SetFont("ZCity_Settings_Tiny")
    headerHint:SetTextColor(settings_color_text_dim)
    headerHint:SetText("Configure ZCity to your liking")
    headerHint:SizeToContents()

    local contentHolder = vgui.Create("DPanel", mainPanel)
    contentHolder:Dock(FILL)
    contentHolder:DockMargin(0, 0, 0, 0)
    contentHolder.Paint = function(self, w, h) end
    settings_content_panel = contentHolder

    SettingsRefreshContent()
end
