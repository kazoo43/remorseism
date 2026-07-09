--
local PANEL = {}

local Statics = {
    {"Kills", "Kills"},
    {"Suicides", "Suicides"},
    {"Deaths", "Deaths"},
    --{"Victories being a traitor", "zb_hmcd_t_wins"},
   -- {"Neutralizings a traitor", "zb_hmcd_ino_t_kills"}
}

local tex_gradient_d = surface.GetTextureID("vgui/gradient-d")
local tex_gradient_r = surface.GetTextureID("vgui/gradient-r")
local tex_gradient_l = surface.GetTextureID("vgui/gradient-l")
local account_clr_bg = Color(10,10,19,235)
local account_clr_panel = Color(10,10,15,120)
local account_clr_header = Color(15,15,20,120)
local account_clr_white = Color(255,255,255,240)
local account_clr_text = Color(225,225,230,230)
local account_clr_dim = Color(170,170,180,185)
local account_open_sound = "ui/rem_click.wav"

local function AccountUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local function GetAccountFont(font, fallback)
    return font or fallback
end

local function GetStatValue(ply, key, request)
    if not IsValid(ply) then return 0 end
    if request and ply.GetStatVal then return ply:GetStatVal(key, 0) end
    return ply.SvDB and ply.SvDB[key] or 0
end

local function TypeText(label,target,speed)
    local elapsed = CurTime() - (label.OpenTime or CurTime())
    local charsToShow = math.min(#target,math.floor(elapsed * speed))
    local txt = ""
    for i = 1,#target do
        txt = txt .. (i <= charsToShow and target:sub(i,i) or "#")
    end
    if label:GetText() != txt then
        label:SetText(txt)
        label:SizeToContents()
    end
end

function PANEL:Init()
    self:SetSize(ScrW()*0.55,ScrH())
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:DockPadding(0,0,0,0)
    if IsValid(self.lblTitle) then self.lblTitle:SetVisible(false) end
    self:SetAlpha(0)
    self:AlphaTo(255, 0.15, 0)
    self.StatRows = {}
    
    self.Sidebar = vgui.Create("DPanel",self)
    local Sidebar = self.Sidebar
    Sidebar:Dock(LEFT)
    Sidebar:SetWide(math.floor(self:GetWide()*0.36))
    Sidebar.Paint = function(self,w,h)
        draw.RoundedBox(0,0,0,w,h,account_clr_panel)
        surface.SetDrawColor(account_clr_white.r,account_clr_white.g,account_clr_white.b,90)
        surface.DrawRect(w - AccountUnit(1),0,AccountUnit(1),h)
    end

    local Header = vgui.Create("DPanel",Sidebar)
    Header:Dock(TOP)
    Header:SetTall(AccountUnit(70))
    Header.Paint = function(self,w,h)
        draw.RoundedBox(0,0,0,w,h,account_clr_header)
        surface.SetDrawColor(account_clr_white.r,account_clr_white.g,account_clr_white.b,140)
        surface.DrawRect(0,h - AccountUnit(1),w,AccountUnit(1))
    end

    local HeaderTitle = vgui.Create("DLabel",Header)
    HeaderTitle:SetPos(AccountUnit(15),AccountUnit(18))
    HeaderTitle:SetFont(GetAccountFont("ZCity_Menu_Small","ZB_InterfaceMedium"))
    HeaderTitle:SetTextColor(account_clr_white)
    HeaderTitle:SetText(string.rep("#",#"ACCOUNT"))
    HeaderTitle:SizeToContents()
    HeaderTitle.OpenTime = CurTime()
    HeaderTitle.Think = function(self)
        TypeText(self,"ACCOUNT",18)
    end

    self.MainInfo = vgui.Create("ZB_ExpPanel",Sidebar)
    local MInfo = self.MainInfo
    MInfo:Dock(FILL)
    MInfo:DockMargin(AccountUnit(14),AccountUnit(14),AccountUnit(14),AccountUnit(14))

    self.CloseLabel = vgui.Create("DLabel",Sidebar)
    local CloseLabel = self.CloseLabel
    CloseLabel:Dock(BOTTOM)
    CloseLabel:DockMargin(AccountUnit(15),AccountUnit(2),0,AccountUnit(20))
    CloseLabel:SetFont(GetAccountFont("ZCity_Menu_Settings_Small","ZB_InterfaceMedium"))
    CloseLabel:SetTextColor(account_clr_text)
    CloseLabel:SetText(string.rep("#",#"<- Close"))
    CloseLabel:SetMouseInputEnabled(true)
    CloseLabel:SetTall(AccountUnit(42))
    CloseLabel.OpenTime = CurTime()
    CloseLabel.HoverLerp = 0
    CloseLabel.LineLerp = 0
    CloseLabel.Think = function(self)
        local hovered = self:IsHovered()
        self.HoverLerp = Lerp(FrameTime()*10,self.HoverLerp or 0,hovered and 1 or 0)
        self.LineLerp = Lerp(FrameTime()*10,self.LineLerp or 0,hovered and 1 or 0)
        TypeText(self,"<- Close",15)
    end
    CloseLabel.Paint = function(self,w,h)
        local hovered = self:IsHovered()
        local flash = hovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = account_clr_text
        local outlineColor = Color(0,0,0,255)
        if hovered then
            local v = flash * 255
            textColor = Color(v,v,v,255)
            outlineColor = Color(255 - v,255 - v,255 - v,255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        draw.SimpleTextOutlined(self:GetText(),self:GetFont(),0,h/2,textColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER,1,outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255,255,255,255 * self.LineLerp)
            surface.DrawRect(0,h/2 + th/2,tw * self.LineLerp,math.max(1,AccountUnit(1)))
        end
        return true
    end
    local AccountFrame = self
    function CloseLabel:DoClick()
        surface.PlaySound(account_open_sound)
        AccountFrame:Close()
    end

    self.Content = vgui.Create("DPanel",self)
    local Content = self.Content
    Content:Dock(FILL)
    Content.Paint = function() end

    local ContentHeader = vgui.Create("DPanel",Content)
    ContentHeader:Dock(TOP)
    ContentHeader:SetTall(AccountUnit(70))
    ContentHeader.Paint = function(self,w,h)
        draw.RoundedBox(0,0,0,w,h,account_clr_header)
        surface.SetDrawColor(account_clr_white.r,account_clr_white.g,account_clr_white.b,140)
        surface.DrawRect(0,h - AccountUnit(1),w,AccountUnit(1))
    end

    local ContentTitle = vgui.Create("DLabel",ContentHeader)
    ContentTitle:SetPos(AccountUnit(25),AccountUnit(18))
    ContentTitle:SetFont(GetAccountFont("ZCity_Menu_Settings_Medium","ZB_InterfaceMedium"))
    ContentTitle:SetTextColor(account_clr_white)
    ContentTitle:SetText("STATISTICS")
    ContentTitle:SetWide(self:GetWide())

    local ContentHint = vgui.Create("DLabel",ContentHeader)
    ContentHint:SetPos(AccountUnit(25),AccountUnit(45))
    ContentHint:SetFont(GetAccountFont("ZCity_Menu_Settings_Tiny","ZB_InterfaceMedium"))
    ContentHint:SetTextColor(account_clr_dim)
    ContentHint:SetText("View player account stats")
    ContentHint:SizeToContents()

    local ContentHolder = vgui.Create("DPanel",Content)
    ContentHolder:Dock(FILL)
    ContentHolder:DockMargin(AccountUnit(24),AccountUnit(22),AccountUnit(24),AccountUnit(22))
    ContentHolder.Paint = function() end

    self.StatsTitle = vgui.Create("DLabel",ContentHolder)
    local StatsTitle = self.StatsTitle
    StatsTitle:Dock(TOP)
    StatsTitle:DockMargin(0,0,0,AccountUnit(10))
    StatsTitle:SetFont(GetAccountFont("ZCity_Menu_Settings_Small","ZB_InterfaceMedium"))
    StatsTitle:SetTextColor(account_clr_white)
    StatsTitle:SetText("STATISTICS")
    StatsTitle:SetTall(AccountUnit(32))

    self.StatPanel = vgui.Create("DScrollPanel",ContentHolder)
    local StatPanel = self.StatPanel
    StatPanel:Dock(FILL)
    StatPanel.Paint = function() end
end

function PANEL:SetPlayer(ply)
    self.MainInfo:SetPlayer(ply)
    self.MainInfo.PlyLabel:SetText( ply:Nick() )

    for i,stats in pairs(Statics) do
        local Stat = vgui.Create("DPanel",self.StatPanel)
        Stat:Dock(TOP)
        Stat:DockMargin(0,0,AccountUnit(8),AccountUnit(10))
        Stat:SetTall(AccountUnit(68))
        Stat.Paint = function(self,w,h)
            surface.SetDrawColor(20,20,30,120)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(account_clr_white.r,account_clr_white.g,account_clr_white.b,65)
            surface.DrawRect(0,h - AccountUnit(1),w,AccountUnit(1))
        end

        local Title = vgui.Create("DLabel",Stat)
        Title:SetPos(AccountUnit(12),AccountUnit(10))
        Title:SetFont(GetAccountFont("ZCity_Menu_Settings_Tiny","ZB_InterfaceMedium"))
        Title:SetTextColor(account_clr_dim)
        Title:SetText(string.upper(stats[1]))
        Title:SizeToContents()

        local Value = vgui.Create("DLabel",Stat)
        Value:SetPos(AccountUnit(12),AccountUnit(30))
        Value:SetFont(GetAccountFont("ZCity_Menu_Settings_Small","ZB_InterfaceMedium"))
        Value:SetTextColor(account_clr_text)
        Value:SetText(tostring(GetStatValue(ply,stats[2],true)))
        Value:SizeToContents()

        self.StatRows[i] = Value
    end
end

function PANEL:Udpate(ply)
    for i,stats in pairs(Statics) do
        local Stat = self.StatRows[i]
        if IsValid(Stat) then
            Stat:SetText(tostring(GetStatValue(ply,stats[2],false)))
            Stat:SizeToContents()
        end
    end
end

function PANEL:Close()
    if self.Closing then return end
    self.Closing = true
    if zb and zb.Experience then zb.Experience.OpenedAccount = nil end
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    self:AlphaTo(0,0.2,0,function()
        if IsValid(self) then self:Remove() end
    end)
end

local BlurBackground = (hg and hg.DrawBlur) or function() end

local function PaintFrame(self,w,h)
    if BlurBackground then BlurBackground(self,5) end
    draw.RoundedBox(0,0,0,w,h,account_clr_bg)
    surface.SetDrawColor(Color(25,25,38,180))
    surface.SetTexture(tex_gradient_r)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(account_clr_bg)
    surface.SetTexture(tex_gradient_l)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(Color(0,0,0,100))
    surface.SetTexture(tex_gradient_d)
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor(account_clr_white.r,account_clr_white.g,account_clr_white.b,140)
    surface.DrawOutlinedRect(0,0,w,h,AccountUnit(1))
end

function PANEL:Paint( w, h )  
    PaintFrame( self, w, h )
end

local AccountBase = vgui.GetControlTable("ZFrame") and "ZFrame" or "DFrame"
vgui.Register( "ZB_AccountFrame", PANEL, AccountBase )


--vgui.Create("ZB_AccountFrame"):MakePopup()
