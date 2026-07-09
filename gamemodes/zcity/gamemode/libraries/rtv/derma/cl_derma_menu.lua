--
local PANEL = {}

local gradient_d = surface.GetTextureID("vgui/gradient-d")
local gradient_l = surface.GetTextureID("vgui/gradient-l")
local gradient_r = surface.GetTextureID("vgui/gradient-r")
local bg = Color(10, 10, 19, 235)
local border = Color(155, 155, 155, 210)
local soft = Color(255, 255, 255, 25)

local function RTVUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local function CreateRTVFonts()
    surface.CreateFont("ZCity_RTV_Title", {
        font = "Verily Serif Mono",
        size = ScreenScale(32),
        weight = 800,
        antialias = true
    })

    surface.CreateFont("ZCity_RTV_Tiny", {
        font = "Verily Serif Mono",
        size = ScreenScale(8),
        weight = 200
    })
end

hook.Add("OnScreenSizeChanged", "ZCity_RTV_Fonts", CreateRTVFonts)
CreateRTVFonts()

function PANEL:Init()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetBorder(false)
    self:SetColorBG(bg)
    self:SetColorBR(border)
    self:SetBlurStrengh(5)
end

function PANEL:Paint( w, h )
    draw.RoundedBox(0, 0, 0, w, h, bg)
    hg.DrawBlur(self, 5)

    surface.SetDrawColor(18, 18, 18, 65)
    surface.SetTexture(gradient_r)
    surface.DrawTexturedRect(0, 0, w, h)

    surface.SetDrawColor(bg)
    surface.SetTexture(gradient_l)
    surface.DrawTexturedRect(0, 0, w, h)

    surface.SetDrawColor(100, 100, 100, 35)
    surface.SetTexture(gradient_d)
    surface.DrawTexturedRect(0, 0, w, h)

    surface.SetDrawColor(border)
    surface.DrawOutlinedRect(0, 0, w, h, 1.5)

    local title = "ROCK THE VOTE"

    draw.SimpleTextOutlined(title, "ZCity_RTV_Title", RTVUnit(28), RTVUnit(24), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)

    draw.SimpleText("ESC / EXIT", "ZCity_RTV_Tiny", w - RTVUnit(30), h - RTVUnit(22), soft, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

end

vgui.Register( "ZB_RTVMenu", PANEL, "ZFrame")
