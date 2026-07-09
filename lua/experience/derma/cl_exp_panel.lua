local PANEL = {}

-- Свой шрифт панели медали, чтобы работало в любом гейммоде (в т.ч. сандбоксе,
-- где zcity-шрифт ZB_InterfaceMedium не создаётся)
surface.CreateFont("ZB_ExpMedium", {
    font = "Arial",
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

local gradient_u = Material("vgui/gradient-u")

local function PaintPanel1(self,w,h)
end

local function RenderMedalBox(w,h)
    if w > h then
        surface.SetDrawColor( 0,0,0,155 )
        surface.DrawTexturedRect( (w/2 - h/2) + 5, 0+5, h, h )
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawTexturedRect( w/2 - h/2, 0, h, h )
    else
        surface.SetDrawColor( 0,0,0,155 )
        surface.DrawTexturedRect( 0+5, ( h/2 - w/2 )+5, w, w )
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawTexturedRect( 0, h/2 - w/2, w, w )
    end
end

function PANEL:Init()
    self.Player = nil

    self.PlyLabel = vgui.Create( "DLabel", self )
    self.PlyLabel:Dock( TOP )
    self.PlyLabel:SetContentAlignment(8)
    self.PlyLabel:SetSize(0,50)
    self.PlyLabel:SetFont( "ZB_ExpMedium" )
    self.PlyLabel:SetColor(color_white)

    self.MedalPanel = vgui.Create( "DPanel", self )
    self.MedalPanel:Dock( FILL )
    self.MedalPanel.Band = nil
    self.MedalPanel.Medal = nil

    function self:Paint( w, h )  
        PaintPanel1( self, w, h )
    end

    function self.MedalPanel:Paint( w, h )
        if not self.Band or not self.Medal then return end

        -- Ленточка (ribbon / band) — верхняя часть медали
        local ribbonH = math.min(h * 0.42, w)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Band.icon)
        surface.DrawTexturedRect(0, 0, w, ribbonH)

        -- Сама медаль (disc / medal) — ниже, по центру
        local discSize = math.min(w, h - ribbonH) * 0.92
        surface.SetMaterial(self.Medal.icon)
        surface.DrawTexturedRect(w / 2 - discSize / 2, ribbonH + (h - ribbonH - discSize) / 2, discSize, discSize)
    end

    self.ExpLabel = vgui.Create( "DLabel", self )
    self.ExpLabel:Dock( BOTTOM )
    self.ExpLabel:SetContentAlignment(8)
    self.ExpLabel:SetSize(0,50)
    self.ExpLabel:SetFont( "ZB_ExpMedium" )
    self.ExpLabel:SetColor(color_white)

end

local function EXP_Text(ply, Band, Medal)
    return (Band and Band.name or "?") .. " / " .. (Medal and Medal.name or "?") .. "    " .. (ply.exp or 0) .. " XP    " .. math.Round(ply.skill or 0, 3) .. " Skill"
end

function PANEL:SetPlayer( ply )
    self.Player = ply
    local Band, Medal = ply:GetAwards()
    
    self.MedalPanel.Band = Band
    self.MedalPanel.Medal = Medal
    self.PlyLabel:SetText( ply:Nick().."'s medal" )
    self.ExpLabel:SetText( EXP_Text(ply, Band, Medal) )
    local oldexp = 0
    function self.ExpLabel:Think()
        if ply.exp != oldexp then
            local Band, Medal = ply:GetAwards()

            self.Band = Band
            self.Medal = Medal
        end
        self:SetText( EXP_Text(ply, self.Band or Band, self.Medal or Medal) )
        oldexp = ply.exp
    end
end


vgui.Register( "ZB_ExpPanel", PANEL, "DPanel" )