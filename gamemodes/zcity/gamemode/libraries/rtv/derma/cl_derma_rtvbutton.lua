--
local PANEL = {}

local gradient_r = surface.GetTextureID("vgui/gradient-r")
local gradient_l = surface.GetTextureID("vgui/gradient-l")
local col_bg = Color(18, 18, 24, 190)
local col_bg_hover = Color(32, 32, 38, 220)
local col_accent = Color(155, 155, 155, 220)
local col_gray = Color(135, 135, 135)

BlurBackground = BlurBackground or hg.DrawBlur

local function RTVUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local function CreateRTVButtonFonts()
    surface.CreateFont("ZCity_RTV_Button", {
        font = "Verily Serif Mono",
        size = ScreenScale(14),
        weight = 200
    })

    surface.CreateFont("ZCity_RTV_ButtonTiny", {
        font = "Verily Serif Mono",
        size = ScreenScale(7),
        weight = 200
    })

    surface.CreateFont("ZCity_RTV_Voted", {
        font = "Verily Serif Mono",
        size = ScreenScale(18),
        weight = 800
    })
end

hook.Add("OnScreenSizeChanged", "ZCity_RTV_ButtonFonts", CreateRTVButtonFonts)
CreateRTVButtonFonts()

function PANEL:Init()
    self.Map = ""
    self.Votes = 0
    self.lerp = 0
    self.BipCD = 0
    
    self.hovered = false
    self.alpha = 0
    self.setalpha = 0

    self:SetFont("ZCity_RTV_Button")
	self:SetPaintBackground(false)
	self:SetContentAlignment(5)
    self:SetTextColor(color_white)

    self.disabled = false
    self.selected = false
end


function PANEL:Paint(w, h)
    if self.disabled then return end

    self.HoverFrac = Lerp(FrameTime() * 8, self.HoverFrac or 0, self:IsHovered() and 1 or 0)

    surface.SetDrawColor(col_bg.r + (col_bg_hover.r - col_bg.r) * self.HoverFrac, col_bg.g + (col_bg_hover.g - col_bg.g) * self.HoverFrac, col_bg.b + (col_bg_hover.b - col_bg.b) * self.HoverFrac, col_bg.a + (col_bg_hover.a - col_bg.a) * self.HoverFrac)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(0, 0, 0, 170)
    surface.SetTexture(gradient_l)
    surface.DrawTexturedRect(0, 0, w, h)

    local iconSize = math.min(h - RTVUnit(12), RTVUnit(74))
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(RTVUnit(8), h / 2 - iconSize / 2, iconSize, iconSize)

    if self.MapIcon then
        surface.SetDrawColor(255, 255, 255, 210)
        surface.SetMaterial(self.MapIcon)
        surface.DrawTexturedRect(RTVUnit(8), h / 2 - iconSize / 2, iconSize, iconSize)
    else
        draw.SimpleText("?", "ZCity_RTV_Button", RTVUnit(8) + iconSize / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local progressStart = iconSize + RTVUnit(18)

    if self.Win and self.BipCD < CurTime() then
        self.alpha = 255
        surface.PlaySound("buttons/blip1.wav")
        self.BipCD = CurTime() + 1
        self:CreateAnimation(0.5, {
            index = 1,
            target = {
                alpha = 0
            },
            easing = "inExpo",
            bIgnoreConfig = true
        })
    end

    surface.SetDrawColor(col_accent.r, col_accent.g, col_accent.b, 95 + 80 * self.HoverFrac)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    surface.SetDrawColor(col_accent.r, col_accent.g, col_accent.b, self.alpha)
    surface.DrawRect(0, 0, w, h)

    local titleX = progressStart
    draw.SimpleTextOutlined(self:GetText(), "ZCity_RTV_Button", titleX, h / 2 - RTVUnit(8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
    draw.SimpleText(tostring(self.Votes) .. " VOTES", "ZCity_RTV_ButtonTiny", w - RTVUnit(14), h / 2 + RTVUnit(11), col_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if self.Win then
        draw.SimpleText("LEADING", "ZCity_RTV_ButtonTiny", w - RTVUnit(14), h / 2 - RTVUnit(12), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    if self.selected then
        draw.SimpleTextOutlined("VOTED", "ZCity_RTV_Voted", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end

    return true

end

function PANEL:OnCursorEntered()
    if self.disabled then return end
    self:CreateAnimation(0.1, {
        index = 1,
        target = {
            alpha = 155
        },
        easing = "inExpo",
        bIgnoreConfig = true
    })
    self.hovered = true
end

function PANEL:OnCursorExited()
    self:CreateAnimation(0.3, {
        index = 1,
        target = {
            alpha = self.setalpha
        },
        easing = "outExpo",
        bIgnoreConfig = true
    })
    self.hovered = false
end

function PANEL:SetSelected(value)
    self.selected = value
    self:OnCursorExited()
end

function PANEL:Disabled(bool)
    self.disabled = bool
    if bool then
        self:SetTextColor(Color(255, 255, 255, 50))
        self:SetCursor("arrow")
    else
        self:SetTextColor(color_white)
        self:SetCursor("hand")
    end
end

vgui.Register("ZB_RTVButton", PANEL, "DButton")
