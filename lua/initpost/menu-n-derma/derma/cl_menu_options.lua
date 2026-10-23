hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString, category )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false, category }
end
local hg_firstperson_death = CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 0)
local hg_font_default = "Lora"
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", hg_font_default, true, false, "change every text font to selected because ui customization is cool")
local hg_oldradialmenu = CreateClientConVar("hg_oldradialmenu", "0", true, false, "use the old radial menu style", 0, 1)
local hg_nojogging = CreateClientConVar("hg_nojogging", "0", true, true, "Automatically sprint when holding shift.", 0, 1)
local hg_gollavo_headshot_effect = ConVarExists("hg_gollavo_headshot_effect") and GetConVar("hg_gollavo_headshot_effect") or CreateClientConVar("hg_gollavo_headshot_effect", "1", true, false, "Enable Gollavo headshot effect", 0, 1)
local hg_reduce_screeneffects = ConVarExists("hg_reduce_screeneffects") and GetConVar("hg_reduce_screeneffects") or CreateClientConVar("hg_reduce_screeneffects", "0", true, false, "Reduce screen shader effects by 50%", 0, 1)

local function ForceHGFirstPersonDeath()
	if hg_firstperson_death:GetString() != "0" then
		RunConsoleCommand("hg_firstperson_death", "0")
	end
end

local function ForceHGFont()
	if hg_font:GetString() != hg_font_default then
		RunConsoleCommand("hg_font", hg_font_default)
	end
end

ForceHGFirstPersonDeath()
ForceHGFont()

cvars.AddChangeCallback("hg_firstperson_death", function(_, _, newValue)
	if newValue != "0" then
		RunConsoleCommand("hg_firstperson_death", "0")
	end
end, "hg_firstperson_death_lock")

cvars.AddChangeCallback("hg_font", function(_, _, newValue)
	if newValue != hg_font_default then
		RunConsoleCommand("hg_font", hg_font_default)
	end
end, "hg_font_lock")

hook.Add("InitPostEntity", "hg_font_force_join", function()
	ForceHGFirstPersonDeath()
	ForceHGFont()
	timer.Simple(1, ForceHGFirstPersonDeath)
	timer.Simple(5, ForceHGFirstPersonDeath)
	timer.Simple(1, ForceHGFont)
	timer.Simple(5, ForceHGFont)
end)

local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

xbars = 17
ybars = 30

gradient_l = Material("vgui/gradient-l")

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local sw, sh = ScrW(), ScrH()

local function MenuUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local SOUND_SETTINGS_CLICK = "ui/rem_click.wav"
local SOUND_TYPEWRITER = "shitty/tap-resonant.wav"
local SOUND_TYPEWRITER_LEVEL = 55
local SOUND_TYPEWRITER_VOLUME = 0.25
local SOUND_TYPEWRITER_PITCH = 102

local function PlayTypewriterSound()
    local ply = LocalPlayer and LocalPlayer()
    if IsValid(ply) then
        ply:EmitSound(SOUND_TYPEWRITER, SOUND_TYPEWRITER_LEVEL, SOUND_TYPEWRITER_PITCH, SOUND_TYPEWRITER_VOLUME)
        return
    end
    surface.PlaySound(SOUND_TYPEWRITER)
end

local settings_header_height = 70

local function CreateSettingsFonts()
    local scale = math.min(ScrW(), ScrH()) / 1000

    surface.CreateFont("ZCity_Menu_Small", {
        font = "Verily Serif Mono",
        size = ScreenScale(20),
        weight = 200,
    })
    surface.CreateFont("ZCity_Menu_Tiny", {
        font = "Verily Serif Mono",
        size = ScreenScale(8),
        weight = 200,
    })
    surface.CreateFont("ZCity_Menu_Settings_Medium", {
        font = "Verily Serif Mono",
        size = math.max(16, math.floor(32 * scale)),
        weight = 300,
    })
    surface.CreateFont("ZCity_Menu_Settings_Small", {
        font = "Verily Serif Mono",
        size = math.max(14, math.floor(22 * scale)),
        weight = 300,
    })
    surface.CreateFont("ZCity_Menu_Settings_Tiny", {
        font = "Verily Serif Mono",
        size = math.max(12, math.floor(16 * scale)),
        weight = 300,
    })
    surface.CreateFont("ZCity_Menu_Settings_Category", {
        font = "Verily Serif Mono",
        size = ScreenScale(15),
        weight = 100
    })
end
hook.Add("OnScreenSizeChanged", "ZCity_Settings_Fonts", CreateSettingsFonts)
CreateSettingsFonts()

hg.settings:AddOpt("Gameplay","hg_newthoughts", "New thoughts")
hg.settings:AddOpt("Gameplay","hg_showthoughts", "Show thoughts")
hg.settings:AddOpt("Gameplay","hg_hints", "Show hints")
hg.settings:AddOpt("Gameplay","hg_gary", "HG GARY")
hg.settings:AddOpt("Gameplay","hg_deathfadeout", "Death fade out")
hg.settings:AddOpt("Gameplay","hg_nojogging", "Disable jogging")
hg.settings:AddOpt("Gameplay","deatheffect_death_screen", "Cinematic death screen")
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
hg.settings:AddOpt("Optimization","hg_reduce_screeneffects", "Reduce screen effects 50%")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "Animations Draw Distance", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_anim_fps", "Animations FPS", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "Attachment Draw Distance", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "Maximum Smoke Trails", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK Render Distance", true, nil, "int")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "Blood Draw Distance")
hg.settings:AddOpt("Blood","hg_blood_fps", "Blood FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "Blood Sprites (DISABLED FOR EVERYONE)")
hg.settings:AddOpt("Blood","hg_old_blood", "Old blood")

hg.settings.tbl["UI"] = hg.settings.tbl["UI"] or {}
hg.settings.tbl["UI"]["hg_font"] = nil
hg.settings:AddOpt("UI","hg_oldradialmenu", "Old Radial Menu")

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "Shooting Blur")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "Dynamic Ammo Inspect")
hg.settings:AddOpt("Weapons","hg_zoomsensitivity", "Scope sensitivity")
hg.settings:AddOpt("Weapons","hg_highpitchgunfire", "Toggle high pitched gunfire sounds inside buildings")
hg.settings:AddOpt("Weapons","hg_gollavo_headshot_effect", "Gollavo headshot effect")

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
    
        draw.SimpleText(ctgName, 'ZCity_Menu_Settings_Category', w / 2, h / 2, color3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
local info_row_gradient = Material("vgui/gradient-l")
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

local info_sections = {
    {title = "Rank", key = "rank"},
    {title = "Leaderboard", key = "leaderboard"},
    {title = "Credits", key = "credits", disabled = true, disabledColor = Color(105, 105, 105, 180)},
    {title = "Socials", key = "socials"}
}
local info_credit_lines = {
    "PLACEHOLDER",
    "PLACEHOLDER",
    "PLACEHOLDER"
}
local info_fallback_band = {
    icon = Material("vgui/mats_jack_awards/10")
}
local info_fallback_medal = {
    icon = Material("vgui/mats_jack_awards/pt")
}
local info_stat_rows = {
    {"Kills", "Kills"},
    {"Headshots", "Headshots"},
    {"Deaths", "Deaths"},
    {"Suicides", "Suicides"}
}
local info_social_links = {
    {
        title = "Lapse",
        subtitle = "In judgement. (Official Community Server)",
        url = DISCORD_URL or "https://discord.gg/Tgz7N58PzV",
        icon = Material("vgui/lapseinjudgement.png", "smooth")
    },
    {
        title = "Z-CITY English Community Server",
        subtitle = "Official community server for the Z-CITY repository. (ENG)",
        url = "https://discord.gg/SjqRcv3yYY",
        icon = Material("vgui/zcityeng.png", "smooth")
    },
    {
        title = "Z-CITY Russian Community Server",
        subtitle = "Official community server for the Z-CITY repository. (RUS)",
        url = "https://discord.gg/475EmEdTgH",
        icon = Material("vgui/zcityrus.png", "smooth")
    },
    {
        title = "Community Hub (RENCHDEDSEX'S ZCITY SERVER)",
        subtitle = "If you are looking for a more vanilla-ish BETTER alternative.",
        url = "https://discord.gg/3UrJapj6kF",
        icon = Material("vgui/communhub.png", "smooth")
    }
}
local info_social_icon_size = MenuUnit(24)
local info_social_icon_x = MenuUnit(18)
local info_social_text_x = MenuUnit(54)
local info_social_button_w = MenuUnit(72)
local info_social_button_h = MenuUnit(24)
local info_social_button_right = MenuUnit(18)
local info_judge_logo = Material("vgui/judgelogo.png", "noclamp smooth")
local info_judge_url = "https://discord.gg/hsRfFdEDTH"
local info_active_section = nil
local info_section_buttons = {}
local info_content_panel = nil
local info_header_label = nil

local function InfoGetObtainedAchievements()
    local results = {}
    if not hg or not hg.achievements or not hg.achievements.achievements_data then return results end
    local created = hg.achievements.achievements_data.created_achevements or {}
    local localach = hg.achievements.GetLocalAchievements and hg.achievements.GetLocalAchievements() or {}

    for key, ach in pairs(created) do
        local playerData = localach and localach[key] or nil
        local value = playerData and playerData.value or ach.start_value or 0
        if value >= (ach.needed_value or 1) then
            results[#results + 1] = ach
        end
    end

    table.sort(results, function(a, b)
        return tostring(a.name or "") < tostring(b.name or "")
    end)

    return results
end

local function InfoHasLocalAchievement(key)
    if not hg or not hg.achievements or not hg.achievements.achievements_data then return false end
    local created = hg.achievements.achievements_data.created_achevements or {}
    local ach = created[key]
    if not ach then return false end
    local localach = hg.achievements.GetLocalAchievements and hg.achievements.GetLocalAchievements() or {}
    local playerData = localach and localach[key] or nil
    return (playerData and playerData.value or ach.start_value or 0) >= (ach.needed_value or 1)
end

local info_stat_methods = {
    Kills = "GetKills",
    Deaths = "GetDeaths",
    Suicides = "GetSuicides"
}

local function InfoGetPlayerStat(ply, key)
    if not IsValid(ply) then return 0 end

    local cached = ply.SvDB and ply.SvDB[key]
    if cached ~= nil then
        return tonumber(cached) or 0
    end

    if key == "Headshots" then
        return tonumber(ply:GetNWInt("Headshots", 0)) or 0
    end

    local methodName = info_stat_methods[key]
    local method = methodName and ply[methodName]
    if isfunction(method) then
        return tonumber(method(ply)) or 0
    end

    return 0
end

local INFO_STORED_STAT_NET = "get_svPData"
local INFO_RANK_NET = "zb_xp_get"

local function InfoCanStartNet(messageName)
    return util.NetworkStringToID(messageName) ~= 0
end

local function InfoRequestStoredStat(ply, key)
    if not IsValid(ply) or not InfoCanStartNet(INFO_STORED_STAT_NET) then return end
    net.Start(INFO_STORED_STAT_NET)
        net.WriteEntity(ply)
        net.WriteString(key)
    net.SendToServer()
end

local function InfoRefreshLocalRankData()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if InfoCanStartNet(INFO_RANK_NET) then
        net.Start(INFO_RANK_NET)
            net.WriteEntity(ply)
        net.SendToServer()
    end

    for _, statData in ipairs(info_stat_rows) do
        InfoRequestStoredStat(ply, statData[2])
    end

    if hg and hg.achievements and hg.achievements.LoadAchievements then
        hg.achievements.LoadAchievements()
    end
end

hook.Add("RoundInfoCalled", "InfoRankRoundRefresh", function()
    timer.Simple(0, function()
        if zb and zb.ROUND_STATE == 3 then
            InfoRefreshLocalRankData()
        end
    end)
end)

hg.Leaderboard = hg.Leaderboard or {Rows = {}, NextRequest = 0}

function hg.Leaderboard.Request(limit)
    if not InfoCanStartNet("zb_sql_leaderboard") then return end
    if (hg.Leaderboard.NextRequest or 0) > CurTime() then return end
    hg.Leaderboard.NextRequest = CurTime() + 3

    net.Start("zb_sql_leaderboard")
        net.WriteUInt(math.Clamp(limit or 10, 1, 10), 8)
    net.SendToServer()
end

function hg.Leaderboard.Get(limit)
    hg.Leaderboard.Request(limit)

    local rows = hg.Leaderboard.Rows or {}
    if limit and #rows > limit then
        local trimmed = {}
        for i = 1, limit do
            trimmed[i] = rows[i]
        end
        return trimmed
    end

    return rows
end

function hg.Leaderboard.GetAwards(row)
    if not row or not zb or not zb.Experience or not zb.Experience.GetAwards then return info_fallback_band, info_fallback_medal end
    return zb.Experience.GetAwards({skill = row.skill or 0, exp = row.xp or 0})
end

if not hg.Leaderboard.NetHooked then
    net.Receive("zb_sql_leaderboard", function()
        local count = net.ReadUInt(8)
        local rows = {}

        for i = 1, count do
            rows[i] = {
                steamid = net.ReadString(),
                name = net.ReadString(),
                skill = net.ReadFloat(),
                xp = net.ReadUInt(32),
                kills = net.ReadUInt(16),
                deaths = net.ReadUInt(16),
                kd = net.ReadFloat()
            }
        end

        hg.Leaderboard.Rows = rows
    end)

    hg.Leaderboard.NetHooked = true
end

local function SettingsCreateCategoryButton(pParent, strTitle, categoryKey)
    local id = #settings_category_buttons + 1
    settings_category_buttons[id] = vgui.Create("DLabel", pParent)
    local btn = settings_category_buttons[id]
    btn:SetText(string.rep("#", #strTitle))
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Menu_Settings_Small")
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
        surface.PlaySound(SOUND_SETTINGS_CLICK)
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
        if self.TypewriterTarget ~= targetText then
            self.TypewriterTarget = targetText
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. targetText:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
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
        if convarName == "hg_gollavo_headshot_effect" and not InfoHasLocalAchievement("gollavo") then continue end
        if convarName == "hg_reduce_screeneffects" and not GetConVar("hg_potatopc"):GetBool() then continue end
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
        title:SetFont("ZCity_Menu_Settings_Small")
        title:SetTextColor(settings_color_text)
        title:SetText(settingData[3])
        title:SizeToContents()

        local help = vgui.Create("DLabel", row)
        help:SetPos(MenuUnit(12), MenuUnit(28))
        help:SetFont("ZCity_Menu_Settings_Tiny")
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
                surface.PlaySound(SOUND_SETTINGS_CLICK)
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
            valLabel:SetFont("ZCity_Menu_Settings_Tiny")
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
            textEntry:SetFont("ZCity_Menu_Settings_Tiny")
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
    sidebarHeaderTitle:SetFont("ZCity_Menu_Settings_Small")
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
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
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
    backBtn:SetFont("ZCity_Menu_Settings_Small")
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
        surface.PlaySound(SOUND_SETTINGS_CLICK)
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
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
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
    headerTitle:SetFont("ZCity_Menu_Settings_Medium")
    headerTitle:SetTextColor(settings_color_whitey)
    headerTitle:SetText(settings_active_category and settings_active_category:upper() or "SETTINGS")
    headerTitle:SizeToContents()
    headerTitle:SetWide(settings_sw - sidebarWidth - MenuUnit(50))
    settings_header_label = headerTitle

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MenuUnit(25), MenuUnit(45))
    headerHint:SetFont("ZCity_Menu_Settings_Tiny")
    headerHint:SetTextColor(settings_color_text_dim)
    headerHint:SetText("Preferences.")
    headerHint:SizeToContents()

    local contentHolder = vgui.Create("DPanel", mainPanel)
    contentHolder:Dock(FILL)
    contentHolder:DockMargin(0, 0, 0, 0)
    contentHolder.Paint = function(self, w, h) end
    settings_content_panel = contentHolder

    SettingsRefreshContent()
end

local keybinds_content_panel = nil
local keybinds_header_label = nil

local function KeybindsFormatKey(key)
    if not key or key == KEY_NONE or key == -999 then return "NONE" end
    local keyName = input.GetKeyName(key)
    return keyName and string.upper(keyName) or tostring(key)
end

local function KeybindsSetBind(bindName, slot, key)
    hg.Binds.CurrentBinds[bindName] = hg.Binds.CurrentBinds[bindName] or {KEY_NONE, nil}
    hg.Binds.CurrentBinds[bindName][slot] = key == KEY_NONE and nil or key
    hg.Binds.SaveThem()
end

local function KeybindsResetDefaults()
    for bindName, keys in pairs(hg.Binds.StandartBinds or {}) do
        hg.Binds.CurrentBinds[bindName] = {keys[1], keys[2]}
    end
    hg.Binds.SaveThem()
end

local function KeybindsCreateSidebarButton(pParent, strTitle)
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

    function btn:Think()
        local isHovered = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)
        self:DockMargin(math.Round(MenuUnit(15) + self.HoverLerp * MenuUnit(2)), MenuUnit(2), 0, 0)

        local targetText = "[ " .. strTitle .. " ]"
        local charsToShow = math.min(#targetText, math.floor((CurTime() - self.OpenTime) * 15))
        local ntxt = ""
        for i = 1, #targetText do
            ntxt = ntxt .. (i <= charsToShow and targetText:sub(i, i) or "#")
        end
        if self:GetText() ~= ntxt then
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
            outlineColor = Color(255 - v, 255 - v, 255 - v, 255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        return true
    end
end

local function KeybindsCreateBinder(parent, bindName, slot, x, y)
    local binder = vgui.Create("DBinder", parent)
    binder:SetSize(MenuUnit(120), MenuUnit(28))
    binder:SetPos(x, y)
    binder:SetValue((hg.Binds.CurrentBinds[bindName] or {})[slot] or KEY_NONE)
    binder:SetFont("ZCity_Menu_Settings_Tiny")

    function binder:Paint(w, h)
        surface.SetDrawColor(20, 20, 20, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, self:IsHovered() and 210 or 120)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText(self.Trapping and "PRESS A BUTTON" or KeybindsFormatKey(self:GetValue()), "ZCity_Menu_Settings_Tiny", w / 2, h / 2, settings_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return true
    end

    function binder:OnChange(key)
        KeybindsSetBind(bindName, slot, key)
    end

    return binder
end

function KeybindsRefreshContent()
    if not IsValid(keybinds_content_panel) then return end
    keybinds_content_panel:Clear()

    if IsValid(keybinds_header_label) then
        keybinds_header_label:SetText("KEYBINDS")
    end

    local scroll = vgui.Create("DScrollPanel", keybinds_content_panel)
    scroll:Dock(FILL)
    scroll.Paint = function() end

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

    local entryWidth = keybinds_content_panel:GetWide()
    if entryWidth <= 0 then entryWidth = settings_sw end

    for bindName, bindData in SortedPairs(hg.Binds.CurrentBinds or {}) do
        local row = vgui.Create("DPanel", scroll)
        row:SetSize(entryWidth - MenuUnit(20), MenuUnit(68))
        row:Dock(TOP)
        row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
        row.Paint = function(self, w, h)
            surface.SetDrawColor(20, 20, 30, 120)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 90)
            surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        end

        local title = vgui.Create("DLabel", row)
        title:SetPos(MenuUnit(12), MenuUnit(7))
        title:SetFont("ZCity_Menu_Settings_Small")
        title:SetTextColor(settings_color_text)
        title:SetText(hg.Binds.Names[bindName] or bindName)
        title:SizeToContents()

        local help = vgui.Create("DLabel", row)
        help:SetPos(MenuUnit(12), MenuUnit(34))
        help:SetFont("ZCity_Menu_Settings_Tiny")
        help:SetTextColor(settings_color_text_dim)
        help:SetText(bindName)
        help:SizeToContents()

        local clear = vgui.Create("DButton", row)
        clear:SetSize(MenuUnit(62), MenuUnit(28))
        clear:SetText("")
        clear.Paint = function(self, w, h)
            surface.SetDrawColor(20, 20, 20, 240)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, self:IsHovered() and 210 or 120)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText("Clear", "ZCity_Menu_Settings_Tiny", w / 2, h / 2, settings_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        clear.DoClick = function()
            hg.Binds.CurrentBinds[bindName] = {KEY_NONE, nil}
            hg.Binds.SaveThem()
            KeybindsRefreshContent()
        end

        local binder1 = KeybindsCreateBinder(row, bindName, 1, 0, MenuUnit(20))
        local binder2 = KeybindsCreateBinder(row, bindName, 2, 0, MenuUnit(20))

        row.PerformLayout = function(self, w, h)
			clear:SetPos(w - MenuUnit(350), MenuUnit(20))
			binder1:SetPos(w - MenuUnit(274), MenuUnit(20))
			binder2:SetPos(w - MenuUnit(140), MenuUnit(20))
        end
    end
end

function hg.DrawKeybinds(ParentPanel)
    settings_sw, settings_sh = ScrW(), ScrH()

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

    local mainPanel = vgui.Create("DPanel", ParentPanel)
    mainPanel:SetSize(settings_sw, settings_sh)
    mainPanel:SetPos(settings_sw, 0)
    mainPanel.TargetX = 0
    mainPanel.Think = function(self)
        local curX, curY = self:GetPos()
        if math.abs(curX - self.TargetX) > 0.5 then self:SetPos(Lerp(FrameTime() * 8, curX, self.TargetX), curY) else self:SetPos(self.TargetX, curY) end
    end
    mainPanel.Paint = function() end

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MenuUnit(settings_header_height))
    header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetPos(MenuUnit(25), MenuUnit(18))
    headerTitle:SetFont("ZCity_Menu_Settings_Medium")
    headerTitle:SetTextColor(settings_color_whitey)
    headerTitle:SetText("KEYBINDS")
    headerTitle:SizeToContents()
    headerTitle:SetWide(settings_sw - MenuUnit(50))
    keybinds_header_label = headerTitle

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MenuUnit(25), MenuUnit(45))
    headerHint:SetFont("ZCity_Menu_Settings_Tiny")
    headerHint:SetTextColor(settings_color_text_dim)
    headerHint:SetText("If you have the buttons already binded via console you can still use these as alternatives.")
    headerHint:SizeToContents()

	local backBtn = vgui.Create("DLabel", ParentPanel)
	backBtn:SetPos(MenuUnit(15), settings_sh - MenuUnit(62))
	backBtn:SetFont("ZCity_Menu_Settings_Small")
	backBtn:SetTextColor(settings_color_text)
	backBtn:SetText(string.rep("#", #"<- Return"))
	backBtn:SetMouseInputEnabled(true)
	backBtn:SizeToContents()
	backBtn:SetTall(MenuUnit(42))
	backBtn.OpenTime = CurTime()
	backBtn.HoverLerp = 0
	backBtn.LineLerp = 0
	backBtn.HoverScale = 0.008
	backBtn:MoveToFront()
	function backBtn:DoClick()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        if not IsValid(ParentPanel) then return end
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
            if luaMenu.ResetCurrentPanel then luaMenu:ResetCurrentPanel() end
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
		if self.TypewriterTarget ~= target then
			self.TypewriterTarget = target
			self.LastTypewriterChars = 0
		end
		if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
			PlayTypewriterSound()
		end
		self.LastTypewriterChars = charsToShow
		local ntxt = ""
		for i = 1, len do
			if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
			else ntxt = ntxt .. "#" end
		end
		if self:GetText() ~= ntxt then
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

    local resetBtn = vgui.Create("DButton", header)
    resetBtn:SetSize(MenuUnit(120), MenuUnit(28))
	resetBtn:SetPos(settings_sw - resetBtn:GetWide() - MenuUnit(15), MenuUnit(21))
    resetBtn:SetText("")
    resetBtn.Paint = function(self, w, h)
        surface.SetDrawColor(20, 20, 20, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, self:IsHovered() and 210 or 120)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("Reset defaults", "ZCity_Menu_Settings_Tiny", w / 2, h / 2, settings_color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    resetBtn.DoClick = function()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        KeybindsResetDefaults()
        KeybindsRefreshContent()
    end

    local contentHolder = vgui.Create("DPanel", mainPanel)
    contentHolder:Dock(FILL)
    contentHolder.Paint = function() end
    keybinds_content_panel = contentHolder

    KeybindsRefreshContent()
end

local function InfoCreateSectionButton(pParent, strTitle, sectionKey)
    local id = #info_section_buttons + 1
    info_section_buttons[id] = vgui.Create("DLabel", pParent)
    local btn = info_section_buttons[id]
    btn:SetText(string.rep("#", #strTitle))
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Menu_Settings_Small")
    btn:SetTall(MenuUnit(42))
    btn:Dock(TOP)
    btn:DockMargin(MenuUnit(15), MenuUnit(2), 0, 0)
    btn.SectionKey = sectionKey
    local sectionData
    for _, data in ipairs(info_sections) do
        if data.key == sectionKey then
            sectionData = data
            break
        end
    end
    btn.SectionDisabled = sectionData and sectionData.disabled or false
    btn.DisabledColor = sectionData and sectionData.disabledColor or Color(105, 105, 105, 180)
    btn.RColor = btn.SectionDisabled and btn.DisabledColor or Color(225,225,225)
    btn.OpenTime = CurTime()
    btn.LineLerp = 0
    btn.HoverLerp = 0

    function btn:DoClick()
        if not IsValid(self) then return end
        if self.SectionDisabled then return end
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        info_active_section = self.SectionKey
        InfoRefreshContent()
    end

    function btn:Think()
        local isHovered = not self.SectionDisabled and self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)
        self:DockMargin(
            math.Round(MenuUnit(15) + self.HoverLerp * MenuUnit(2)),
            MenuUnit(2),
            0,
            0
        )

        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local isActive = not self.SectionDisabled and info_active_section == self.SectionKey
        local targetText = isActive and ("[ " .. strTitle .. " ]") or strTitle
        local len = #targetText
        if charsToShow > len then charsToShow = len end
        if self.TypewriterTarget ~= targetText then
            self.TypewriterTarget = targetText
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. targetText:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    function btn:Paint(w, h)
        local isHovered = not self.SectionDisabled and self:IsHovered()
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
        local scale = 1 + (self.HoverLerp or 0) * 0.008
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

function InfoRefreshContent()
    if not IsValid(info_content_panel) then return end
    info_content_panel:Clear()

    local sectionKey = info_active_section or "rank"
    for _, sectionData in ipairs(info_sections) do
        if sectionData.key == sectionKey and sectionData.disabled then
            sectionKey = "rank"
            info_active_section = "rank"
            break
        end
    end

    if IsValid(info_header_label) then
        local currentTitle = "INFORMATION"
        for _, sectionData in ipairs(info_sections) do
            if sectionData.key == info_active_section then
                currentTitle = string.upper(sectionData.title)
                break
            end
        end
        info_header_label:SetText(currentTitle)
    end
    local contentWidth = info_content_panel:GetWide()
    local contentHeight = info_content_panel:GetTall()

    if sectionKey == "rank" then
        InfoRefreshLocalRankData()

        local holder = vgui.Create("DPanel", info_content_panel)
        holder:Dock(FILL)
        holder:DockMargin(MenuUnit(20), MenuUnit(20), MenuUnit(20), MenuUnit(20))
        holder.Paint = function() end

        local card = vgui.Create("DPanel", holder)
        card:Dock(FILL)
        card.Paint = function(self, w, h)
            surface.SetDrawColor(20, 20, 30, 130)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 90)
            surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        end

        local scroll = vgui.Create("DScrollPanel", card)
        scroll:Dock(FILL)
        scroll:DockMargin(MenuUnit(18), MenuUnit(18), MenuUnit(18), MenuUnit(18))
        scroll.Paint = function() end

        local scrollBar = scroll:GetVBar()
        scrollBar:SetWide(MenuUnit(4))
        scrollBar:SetHideButtons(true)
        function scrollBar:Paint(w, h)
            surface.SetDrawColor(0, 0, 0, 80)
            surface.DrawRect(0, 0, w, h)
        end
        function scrollBar.btnGrip:Paint(w, h)
            local col = self:IsHovered() and settings_color_whitey or settings_color_dim
            draw.RoundedBox(2, 1, 1, w - 2, h - 2, col)
        end

        local profileBlock = vgui.Create("DPanel", scroll)
        profileBlock:Dock(TOP)
        profileBlock:DockMargin(0, 0, 0, MenuUnit(18))
        profileBlock:SetTall(MenuUnit(370))
        profileBlock.Paint = function() end

        local medalPanel = vgui.Create("DPanel", profileBlock)
        medalPanel:SetSize(MenuUnit(200), MenuUnit(200))
        medalPanel.Band = nil
        medalPanel.Medal = nil
        medalPanel.Paint = function(self, w, h)
            if self.Band and self.Band.icon then
                surface.SetMaterial(self.Band.icon)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(0, 0, w, h)
            end
            if self.Medal and self.Medal.icon then
                surface.SetMaterial(self.Medal.icon)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        local playerLabel = vgui.Create("DLabel", profileBlock)
        playerLabel:SetFont("ZCity_Menu_Settings_Medium")
        playerLabel:SetTextColor(settings_color_whitey)
        playerLabel:SetContentAlignment(5)
        playerLabel:SetText("")

        local xpLabel = vgui.Create("DLabel", profileBlock)
        xpLabel:SetFont("ZCity_Menu_Settings_Small")
        xpLabel:SetTextColor(settings_color_text)
        xpLabel:SetContentAlignment(5)
        xpLabel:SetText("")

        local skillLabel = vgui.Create("DLabel", profileBlock)
        skillLabel:SetFont("ZCity_Menu_Settings_Small")
        skillLabel:SetTextColor(settings_color_text_dim)
        skillLabel:SetContentAlignment(5)
        skillLabel:SetText("")

        local medalLabel = vgui.Create("DLabel", profileBlock)
        medalLabel:SetFont("ZCity_Menu_Settings_Small")
        medalLabel:SetTextColor(settings_color_text)
        medalLabel:SetContentAlignment(5)
        medalLabel:SetText("")

        local bandLabel = vgui.Create("DLabel", profileBlock)
        bandLabel:SetFont("ZCity_Menu_Settings_Tiny")
        bandLabel:SetTextColor(settings_color_text_dim)
        bandLabel:SetContentAlignment(5)
        bandLabel:SetText("")

        profileBlock.PerformLayout = function(self, w, h)
            local medalSize = math.min(MenuUnit(200), math.max(MenuUnit(130), math.floor(w * 0.28)))
            medalPanel:SetSize(medalSize, medalSize)
            medalPanel:SetPos(math.floor((w - medalSize) * 0.5), 0)

            playerLabel:SetPos(0, medalPanel:GetY() + medalPanel:GetTall() + MenuUnit(14))
            playerLabel:SetSize(w, MenuUnit(38))
            xpLabel:SetPos(0, playerLabel:GetY() + MenuUnit(34))
            xpLabel:SetSize(w, MenuUnit(28))
            skillLabel:SetPos(0, xpLabel:GetY() + MenuUnit(26))
            skillLabel:SetSize(w, MenuUnit(28))
            medalLabel:SetPos(0, skillLabel:GetY() + MenuUnit(34))
            medalLabel:SetSize(w, MenuUnit(26))
            bandLabel:SetPos(0, medalLabel:GetY() + MenuUnit(22))
            bandLabel:SetSize(w, MenuUnit(24))
            self:SetTall(bandLabel:GetY() + bandLabel:GetTall() + MenuUnit(10))
        end

        local statsTitle = vgui.Create("DLabel", scroll)
        statsTitle:Dock(TOP)
        statsTitle:DockMargin(0, 0, 0, MenuUnit(10))
        statsTitle:SetFont("ZCity_Menu_Settings_Small")
        statsTitle:SetTextColor(settings_color_whitey)
        statsTitle:SetText("STATISTICS")
        statsTitle:SetTall(MenuUnit(28))

        local statsGrid = vgui.Create("DPanel", scroll)
        statsGrid:Dock(TOP)
        statsGrid:DockMargin(0, 0, 0, MenuUnit(18))
        statsGrid:SetTall(MenuUnit(160))
        statsGrid.Paint = function() end

        local statCards = {}
        for _, statData in ipairs(info_stat_rows) do
            local statPanel = vgui.Create("DPanel", statsGrid)
            statPanel.Paint = function(self, w, h)
                surface.SetDrawColor(20, 20, 30, 120)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 65)
                surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
            end

            local title = vgui.Create("DLabel", statPanel)
            title:SetPos(MenuUnit(12), MenuUnit(10))
            title:SetFont("ZCity_Menu_Settings_Tiny")
            title:SetTextColor(settings_color_text_dim)
            title:SetText(string.upper(statData[1]))
            title:SizeToContents()

            local value = vgui.Create("DLabel", statPanel)
            value:SetPos(MenuUnit(12), MenuUnit(30))
            value:SetFont("ZCity_Menu_Settings_Small")
            value:SetTextColor(settings_color_text)
            value:SetText("0")
            value:SizeToContents()

            statCards[#statCards + 1] = {
                key = statData[2],
                panel = statPanel,
                value = value
            }
        end

        local kdPanel = vgui.Create("DPanel", statsGrid)
        kdPanel.Paint = function(self, w, h)
            surface.SetDrawColor(20, 20, 30, 120)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 65)
            surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
        end

        local kdTitle = vgui.Create("DLabel", kdPanel)
        kdTitle:SetPos(MenuUnit(12), MenuUnit(10))
        kdTitle:SetFont("ZCity_Menu_Settings_Tiny")
        kdTitle:SetTextColor(settings_color_text_dim)
        kdTitle:SetText("K/D")
        kdTitle:SizeToContents()

        local kdValue = vgui.Create("DLabel", kdPanel)
        kdValue:SetPos(MenuUnit(12), MenuUnit(30))
        kdValue:SetFont("ZCity_Menu_Settings_Small")
        kdValue:SetTextColor(settings_color_text)
        kdValue:SetText("0.00")
        kdValue:SizeToContents()

        statsGrid.PerformLayout = function(self, w, h)
            local gap = MenuUnit(8)
            local columns = w < MenuUnit(520) and 1 or 2
            local cardW = math.floor((w - gap * (columns - 1)) / columns)
            local cardH = MenuUnit(66)
            local allCards = {}
            for _, statCard in ipairs(statCards) do
                allCards[#allCards + 1] = statCard.panel
            end
            allCards[#allCards + 1] = kdPanel

            for i, pnl in ipairs(allCards) do
                local row = math.floor((i - 1) / columns)
                local col = (i - 1) % columns
                pnl:SetPos(col * (cardW + gap), row * (cardH + gap))
                pnl:SetSize(cardW, cardH)
            end

            local rows = math.ceil(#allCards / columns)
            self:SetTall(rows * cardH + math.max(0, rows - 1) * gap)
        end

        local achievementsTitle = vgui.Create("DLabel", scroll)
        achievementsTitle:Dock(TOP)
        achievementsTitle:DockMargin(0, 0, 0, MenuUnit(10))
        achievementsTitle:SetFont("ZCity_Menu_Settings_Small")
        achievementsTitle:SetTextColor(settings_color_whitey)
        achievementsTitle:SetText("OBTAINED ACHIEVEMENTS")
        achievementsTitle:SetTall(MenuUnit(28))

        local achievementsHolder = vgui.Create("DPanel", scroll)
        achievementsHolder:Dock(TOP)
        achievementsHolder.Paint = function() end

        local achievementsEmpty = vgui.Create("DLabel", achievementsHolder)
        achievementsEmpty:Dock(TOP)
        achievementsEmpty:SetFont("ZCity_Menu_Settings_Tiny")
        achievementsEmpty:SetTextColor(settings_color_text_dim)
        achievementsEmpty:SetContentAlignment(5)
        achievementsEmpty:SetText("NO ACHIEVEMENTS OBTAINED YET")
        achievementsEmpty:SetTall(MenuUnit(28))

        local achievementRows = {}
        local function RefreshAchievements()
            local obtained = InfoGetObtainedAchievements()
            for _, pnl in ipairs(achievementRows) do
                if IsValid(pnl) then
                    pnl:Remove()
                end
            end
            achievementRows = {}

            achievementsEmpty:SetVisible(#obtained == 0)
            achievementsHolder:SetTall(MenuUnit(28))

            if #obtained == 0 then
                return
            end

            local totalHeight = 0
            for _, ach in ipairs(obtained) do
                local row = vgui.Create("DPanel", achievementsHolder)
                row:Dock(TOP)
                row:DockMargin(0, 0, 0, MenuUnit(8))
                row:SetTall(MenuUnit(56))
                row.Paint = function(self, w, h)
                    surface.SetDrawColor(20, 20, 30, 120)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 55)
                    surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
                end

                local title = vgui.Create("DLabel", row)
                title:SetPos(MenuUnit(12), MenuUnit(10))
                title:SetFont("ZCity_Menu_Settings_Small")
                title:SetTextColor(settings_color_text)
                title:SetText(ach.name or "Achievement")
                title:SizeToContents()

                local desc = vgui.Create("DLabel", row)
                desc:SetPos(MenuUnit(12), MenuUnit(30))
                desc:SetFont("ZCity_Menu_Settings_Tiny")
                desc:SetTextColor(settings_color_text_dim)
                desc:SetText(ach.description or "")
                row.PerformLayout = function(self, w, h)
                    desc:SetWide(w - MenuUnit(24))
                end

                achievementRows[#achievementRows + 1] = row
                totalHeight = totalHeight + row:GetTall() + MenuUnit(8)
            end

            achievementsHolder:SetTall(totalHeight)
        end

        local statValues = {
            Kills = 0,
            Headshots = 0,
            Deaths = 0,
            Suicides = 0
        }
        local lastExp = -1
        local lastSkill = -1
        local lastAchievementSignature = ""
        card.Think = function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return end

            local band, medal = info_fallback_band, info_fallback_medal
            if ply.GetAwards then
                band, medal = ply:GetAwards()
            end
            band = band or info_fallback_band
            medal = medal or info_fallback_medal
            medalPanel.Band = band
            medalPanel.Medal = medal

            local playerName = ply:GetNWString("PlayerName", "")
            if playerName == "" then
                playerName = ply:Nick()
            end

            local newExp = math.floor(tonumber(ply.exp) or 0)
            local newSkill = math.Round(tonumber(ply.skill) or 0, 3)
            if lastExp ~= newExp or lastSkill ~= newSkill then
                playerLabel:SetText(string.upper(playerName))
                xpLabel:SetText(newExp .. " XP")
                skillLabel:SetText(newSkill .. " Skill")
                medalLabel:SetText("Medal: " .. string.upper((medal and medal.name) or "UNRANKED"))
                bandLabel:SetText("Band: " .. ((band and band.name and band.name ~= "") and string.upper(band.name) or "SOON"))
                lastExp = newExp
                lastSkill = newSkill
                profileBlock:InvalidateLayout(true)
            end

            for _, statData in ipairs(statCards) do
                statValues[statData.key] = InfoGetPlayerStat(ply, statData.key)
                statData.value:SetText(tostring(math.floor(statValues[statData.key] or 0)))
                statData.value:SizeToContents()
            end

            local effectiveDeaths = math.max(statValues.Deaths - statValues.Suicides, 0)
            local kd = statValues.Kills / math.max(effectiveDeaths, 1)
            kdValue:SetText(string.format("%.2f", kd))
            kdValue:SizeToContents()

            local obtained = InfoGetObtainedAchievements()
            local signature = tostring(#obtained)
            for i, ach in ipairs(obtained) do
                signature = signature .. "|" .. tostring(ach.name or i)
            end
            if signature ~= lastAchievementSignature then
                lastAchievementSignature = signature
                RefreshAchievements()
            end
        end

    elseif sectionKey == "leaderboard" then
        local holder = vgui.Create("DPanel", info_content_panel)
        holder:Dock(FILL)
        holder.Paint = function() end

        local scroll = vgui.Create("DScrollPanel", holder)
        scroll:Dock(FILL)
        scroll:DockMargin(MenuUnit(24), MenuUnit(24), MenuUnit(24), MenuUnit(24))
        scroll.Paint = function() end

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

        local title = vgui.Create("DLabel", scroll)
        title:Dock(TOP)
        title:DockMargin(0, 0, 0, MenuUnit(10))
        title:SetFont("ZCity_Menu_Settings_Small")
        title:SetTextColor(settings_color_whitey)
        title:SetText("TOP 10 PLAYERS")
        title:SetTall(MenuUnit(30))

        local rows = {}
        local lastRefresh = 0

        local function RebuildRows()
            for _, row in ipairs(rows) do
                if IsValid(row) then row:Remove() end
            end
            rows = {}

            local leaders = hg.Leaderboard.Get(10)
            if #leaders == 0 then
                local empty = vgui.Create("DLabel", scroll)
                empty:Dock(TOP)
                empty:SetTall(MenuUnit(34))
                empty:SetFont("ZCity_Menu_Settings_Tiny")
                empty:SetTextColor(settings_color_text_dim)
                empty:SetContentAlignment(5)
                empty:SetText("NO SQL LEADERBOARD DATA")
                rows[#rows + 1] = empty
                return
            end

            for rank, data in ipairs(leaders) do
                local rowRank = rank
                local rowData = data
                local row = vgui.Create("DPanel", scroll)
                row:Dock(TOP)
                row:DockMargin(0, 0, 0, MenuUnit(8))
                row:SetTall(MenuUnit(64))
                row.PlayerData = rowData
                row.HoverLerp = 0
                row.Paint = function(self, w, h)
                    self.HoverLerp = LerpFT(0.18, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
                    surface.SetMaterial(info_row_gradient)
                    surface.SetDrawColor(85, 85, 85, 120 + 40 * self.HoverLerp)
                    surface.DrawTexturedRect(0, 0, w, h)
                    surface.SetDrawColor(0, 0, 0, 145)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(255, 255, 255, 30 + 55 * self.HoverLerp)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                    surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, rowRank <= 3 and 185 or 95)
                    surface.DrawRect(0, 0, MenuUnit(2), h)
                    draw.SimpleText("#" .. rowRank, "ZCity_Menu_Settings_Small", MenuUnit(15), h / 2, settings_color_whitey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(self.PlayerData.name, "ZCity_Menu_Settings_Small", MenuUnit(96), MenuUnit(22), settings_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.format("K/D %.2f", self.PlayerData.kd), "ZCity_Menu_Settings_Tiny", MenuUnit(96), MenuUnit(43), settings_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("XP " .. self.PlayerData.xp, "ZCity_Menu_Settings_Tiny", w - MenuUnit(54), MenuUnit(22), settings_color_text_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("K " .. math.floor(self.PlayerData.kills) .. "  D " .. math.floor(self.PlayerData.deaths), "ZCity_Menu_Settings_Tiny", w - MenuUnit(18), MenuUnit(43), settings_color_text_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end

                local avatar = vgui.Create("AvatarImage", row)
                avatar:SetSize(MenuUnit(38), MenuUnit(38))
                avatar:SetPos(MenuUnit(42), MenuUnit(13))
                avatar:SetMouseInputEnabled(false)
                avatar:SetSteamID(rowData.steamid, 64)
                avatar.PaintOver = function(self, w, h)
                    surface.SetDrawColor(255, 255, 255, 45)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end

                local medal = vgui.Create("DPanel", row)
                medal:SetSize(MenuUnit(28), MenuUnit(28))
                row.PerformLayout = function(self, w, h)
                    medal:SetPos(w - MenuUnit(48), MenuUnit(8))
                end
                medal.Paint = function(self, w, h)
                    local band, med = hg.Leaderboard.GetAwards(rowData)
                    band = band or info_fallback_band
                    med = med or info_fallback_medal
                    if band and band.icon then
                        surface.SetMaterial(band.icon)
                        surface.SetDrawColor(255, 255, 255, 220)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end
                    if med and med.icon then
                        surface.SetMaterial(med.icon)
                        surface.SetDrawColor(255, 255, 255, 240)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end
                end

                rows[#rows + 1] = row
            end
        end

        scroll.Think = function()
            if lastRefresh > CurTime() then return end
            lastRefresh = CurTime() + 2
            RebuildRows()
        end
        RebuildRows()

    elseif sectionKey == "credits" then
        local scroll = vgui.Create("DScrollPanel", info_content_panel)
        scroll:Dock(FILL)
        scroll:DockMargin(MenuUnit(24), MenuUnit(24), MenuUnit(24), MenuUnit(24))
        scroll.Paint = function() end

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

        for _, line in ipairs(info_credit_lines) do
            local row = vgui.Create("DPanel", scroll)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, MenuUnit(10))
            row:SetTall(MenuUnit(64))
            row.Paint = function(self, w, h)
                surface.SetDrawColor(20, 20, 30, 120)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 80)
                surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
            end

            local text = vgui.Create("DLabel", row)
            text:SetPos(MenuUnit(18), MenuUnit(18))
            text:SetFont("ZCity_Menu_Settings_Small")
            text:SetTextColor(settings_color_text)
            text:SetText(line)
            text:SizeToContents()
        end

    elseif sectionKey == "socials" then
        local holder = vgui.Create("DPanel", info_content_panel)
        holder:Dock(FILL)
        holder.Paint = function() end

        local bottomLogo = vgui.Create("DPanel", holder)
        bottomLogo:Dock(BOTTOM)
        bottomLogo:SetTall(MenuUnit(270))
        bottomLogo.Paint = function() end

        local alsoCheck = vgui.Create("DLabel", bottomLogo)
        alsoCheck:Dock(TOP)
        alsoCheck:SetTall(MenuUnit(30))
        alsoCheck:SetFont("ZCity_Menu_Settings_Small")
        alsoCheck:SetTextColor(settings_color_text)
        alsoCheck:SetContentAlignment(5)
        alsoCheck:SetText("Also check out:")

        local judgeButton = vgui.Create("DButton", bottomLogo)
        judgeButton:SetText("")
        judgeButton.HoverLerp = 0
        judgeButton:SetCursor("hand")
        judgeButton.DoClick = function()
            gui.OpenURL(info_judge_url)
        end
        judgeButton.Think = function(self)
            self.HoverLerp = LerpFT(0.12, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        end
        judgeButton.Paint = function(self, w, h)
            local scale = 1 + (self.HoverLerp or 0) * 0.08
            local maxW = w / 1.08
            local maxH = h / 1.08
            local aspect = math.max(1, info_judge_logo:Height()) / math.max(1, info_judge_logo:Width())
            local baseW = math.min(maxW, maxH / aspect)
            local baseH = baseW * aspect
            local drawW = baseW * scale
            local drawH = baseH * scale
            local drawX = math.floor(w * 0.5 - drawW * 0.5)
            local drawY = math.floor(h * 0.5 - drawH * 0.5)

            surface.SetMaterial(info_judge_logo)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
        end
        bottomLogo.PerformLayout = function(self, w, h)
            local areaH = h - alsoCheck:GetTall()
            local aspect = math.max(1, info_judge_logo:Height()) / math.max(1, info_judge_logo:Width())
            local buttonW = math.min(w - MenuUnit(20), MenuUnit(390))
            local buttonH = math.min(areaH - MenuUnit(10), MenuUnit(210), buttonW * aspect)
            buttonW = buttonH / aspect
            judgeButton:SetSize(math.ceil(buttonW * 1.08), math.ceil(buttonH * 1.08))
            judgeButton:SetPos(math.floor(w * 0.5 - judgeButton:GetWide() * 0.5), alsoCheck:GetTall() + math.floor(areaH * 0.5 - judgeButton:GetTall() * 0.5))
        end

        local scroll = vgui.Create("DScrollPanel", holder)
        scroll:Dock(FILL)
        scroll:DockMargin(MenuUnit(24), MenuUnit(24), MenuUnit(24), MenuUnit(24))
        scroll.Paint = function() end

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

        for _, social in ipairs(info_social_links) do
            local row = vgui.Create("DButton", scroll)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, MenuUnit(10))
            row:SetTall(MenuUnit(70))
            row:SetText("")
            row.HoverLerp = 0
            row.DoClick = function()
                if social.url and social.url ~= "" then
                    gui.OpenURL(social.url)
                end
            end
            row.Think = function(self)
                self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
            end
            row.Paint = function(self, w, h)
                local alpha = 120 + 30 * (self.HoverLerp or 0)
                local iconSize = info_social_icon_size
                local iconX = info_social_icon_x
                local iconY = math.floor(h * 0.5 - iconSize * 0.5)
                local buttonW = info_social_button_w
                local buttonH = info_social_button_h
                local buttonX = w - info_social_button_right - buttonW
                local buttonY = math.floor(h * 0.5 - buttonH * 0.5)
                surface.SetDrawColor(20, 20, 30, alpha)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 80 + 80 * (self.HoverLerp or 0))
                surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
                if social.icon then
                    surface.SetMaterial(social.icon)
                    surface.SetDrawColor(255, 255, 255, 220)
                    surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
                end
                draw.SimpleText(social.title, "ZCity_Menu_Settings_Small", info_social_text_x, MenuUnit(20), settings_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(social.subtitle, "ZCity_Menu_Settings_Tiny", info_social_text_x, MenuUnit(42), settings_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(0, 0, 0, 245)
                surface.DrawRect(buttonX, buttonY, buttonW, buttonH)
                surface.SetDrawColor(255, 255, 255, 210)
                surface.DrawOutlinedRect(buttonX, buttonY, buttonW, buttonH, 1)
                draw.SimpleText("Join", "ZCity_Menu_Settings_Tiny", buttonX + buttonW * 0.5, buttonY + buttonH * 0.5, settings_color_whitey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end

function hg.DrawInformation(ParentPanel)
    settings_sw, settings_sh = ScrW(), ScrH()

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

    info_section_buttons = {}

    if not info_active_section then
        info_active_section = info_sections[1] and info_sections[1].key or "rank"
    end

    local sidebarWidth = math.floor(settings_sw / 3.6)
    local sidebar = vgui.Create("DPanel", ParentPanel)
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
    sidebarHeaderTitle:SetFont("ZCity_Menu_Small")
    sidebarHeaderTitle:SetTextColor(settings_color_whitey)
    sidebarHeaderTitle:SetText("INFORMATION")
    sidebarHeaderTitle:SizeToContents()
    sidebarHeaderTitle.OpenTime = CurTime()
    function sidebarHeaderTitle:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local charsToShow = math.floor(elapsed * 18)
        local target = "INFORMATION"
        local len = #target
        if charsToShow > len then charsToShow = len end
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    for _, sectionData in ipairs(info_sections) do
        InfoCreateSectionButton(sidebar, sectionData.title, sectionData.key)
    end

    local backBtn = vgui.Create("DLabel", sidebar)
    backBtn:Dock(BOTTOM)
    backBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(20))
    backBtn:SetFont("ZCity_Menu_Settings_Small")
    backBtn:SetTextColor(settings_color_text)
    backBtn:SetText(string.rep("#", #"<- Return"))
    backBtn:SetMouseInputEnabled(true)
    backBtn:SizeToContents()
    backBtn:SetTall(MenuUnit(42))
    backBtn.OpenTime = CurTime()
    backBtn.HoverLerp = 0
    backBtn.LineLerp = 0
    function backBtn:DoClick()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
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
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then ntxt = ntxt .. target:sub(i, i)
            else ntxt = ntxt .. "#" end
        end
        if self:GetText() ~= ntxt then
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
        local scale = 1 + (self.HoverLerp or 0) * 0.008
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
    mainPanel.Paint = function() end

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MenuUnit(settings_header_height))
    header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(settings_color_whitey.r, settings_color_whitey.g, settings_color_whitey.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetPos(MenuUnit(25), MenuUnit(18))
    headerTitle:SetFont("ZCity_Menu_Settings_Medium")
    headerTitle:SetTextColor(settings_color_whitey)
    headerTitle:SetText("RANK")
    headerTitle:SizeToContents()
    headerTitle:SetWide(settings_sw - sidebarWidth - MenuUnit(50))
    info_header_label = headerTitle

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetPos(MenuUnit(25), MenuUnit(45))
    headerHint:SetFont("ZCity_Menu_Settings_Tiny")
    headerHint:SetTextColor(settings_color_text_dim)
    headerHint:SetText("View rank and social links")
    headerHint:SizeToContents()

    local contentHolder = vgui.Create("DPanel", mainPanel)
    contentHolder:Dock(FILL)
    contentHolder.Paint = function() end
    info_content_panel = contentHolder

    InfoRefreshContent()
end
