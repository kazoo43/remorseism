--[[    TO-DO
    -- Добавить менюшку с прощением! |
    -- Добавить нетворкинг |
    -- Ну и все | 
--]]

hook.Add("OnNetVarSet", "Guilt",function(index, key, var)
    if key == "Karma" then
        Entity(index).Karma = var
    end
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
    --if (ply == LocalPlayer()) and ply.Karma then
    --    ply:ChatPrint("Your current karma is "..tostring(math.Round(ply.Karma)).."")
    --end
end)

concommand.Add("hg_getkarma",function(ply)
    if not ply:IsAdmin() then return end

    net.Start("get_karma")
    net.SendToServer()
end)

net.Receive("get_karma",function(len)
    local tbl = net.ReadTable()
    local printTbl = "\nPlayers karma: \n"

    for id,karma in pairs(tbl) do
        printTbl = printTbl.."\t"..(Player(id):Name().."'s karma is "..math.Round(karma,2)).."\n"
    end

    LocalPlayer():PrintMessage(HUD_PRINTCONSOLE,printTbl)
end)

concommand.Add("hg_guilt_menu",function(ply, cmd, args)
    net.Start("open_guilt_menu")
    net.SendToServer()
end)

local OpenMenu

net.Receive("open_guilt_menu", function()
    local tbl = net.ReadTable()
    
    OpenMenu(tbl)
end)

local colGray = Color(122,122,122,255)
local BlurBackground = hg.BlurBackground
local guiltMenuOutline = Color(255, 255, 255, 255)
local guiltMenuFill = Color(0, 0, 0, 245)
local guiltMenuGradient = Color(40, 40, 40, 55)
local guiltMenuButtonIdle = Color(20, 20, 20, 235)
local guiltMenuButtonHover = Color(34, 34, 34, 235)
local gradient_u = Material("vgui/gradient-u")
local gradient_d = Material("vgui/gradient-d")

local function ScaleMenu(v)
    return math.Round(v * math.Clamp(ScrH() / 1080, 0.75, 1.15))
end

local function PaintGuiltBlur(self)
    if hg.DrawBlur then
        hg.DrawBlur(self)
    elseif BlurBackground then
        BlurBackground(self)
    end
end

local function PaintGuiltFrame(self, w, h)
    PaintGuiltBlur(self)
    surface.SetDrawColor(guiltMenuFill)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(guiltMenuGradient)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetDrawColor(guiltMenuOutline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function PaintGuiltButton(self, w, h)
    if self:IsHovered() then
        surface.SetDrawColor(guiltMenuButtonHover)
        surface.DrawRect(0, 0, w, h)
    end

    if self.guiltText then
        draw.SimpleText(self.guiltText, "ZCity_Menu_Settings_Tiny", ScaleMenu(8), h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

local function PaintGuiltClose(self, w, h)
    PaintGuiltButton(self, w, h)
    draw.SimpleText(self:GetText(), "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function PaintGuiltScrollBar(self, w, h)
    surface.SetDrawColor(16, 16, 16, 220)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(guiltMenuOutline)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function PaintGuiltScrollGrip(self, w, h)
    self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.3, self:IsHovered() and 0.5 or 0.3)
    local col = 255 * self.lerpcolor
    surface.SetDrawColor(col, col, col, 255)
    surface.DrawRect(0, 0, w, h)
end

local function harmdone(harm)
    if harm >= 9 then
        return "killed you."
    elseif harm >= 5 then
        return "basically killed you."
    elseif harm >= 2 then
        return "seriously injured you."
    elseif harm >= 1 then
        return "mildly injured you."
    else
        return "damaged you a bit."
    end
end

local showstuff = CurTime() + 5
hook.Add("Player_Death","karmacheck",function(ply)
    if ply != LocalPlayer() then return end
    
    showstuff = CurTime() + 5
end)

local pressed
hook.Add("HUDPaint","shownotification",function()
    if LocalPlayer():Alive() then return end

    if showstuff > CurTime() then
        local w, h = ScrW(), ScrH()
        local x, y = w / 2, h / 25 * 24
        local txt = "Press F to open forgiveness menu."
        surface.SetFont( "HomigradFontBig" )
        surface.SetTextColor(255,255,255,255)
        local w, h = surface.GetTextSize(txt)
        surface.SetTextPos(x - w / 2, y - h / 2)
        surface.DrawText(txt)
    end

    if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) then
        if not pressed then
            showstuff = 0
            RunConsoleCommand("hg_guilt_menu")
            pressed = true
        end
    else
        pressed = nil
    end
end)

OpenMenu = function(tbl)
    if IsValid(guiltMenu) then
		guiltMenu:Remove()
		guiltMenu = nil
	end
    
	local playerCount = 0
	for ply, harm in pairs(tbl) do
		if IsValid(ply) and harm > 0.01 then playerCount = playerCount + 1 end
	end

	local rowH = ScaleMenu(34)
	local margin = math.max(8, math.min(ScaleMenu(20), ScrW() * 0.05, ScrH() * 0.05))
	local maxX = ScrW() - margin * 2
	local maxY = ScrH() - margin * 2
	local sizeX = math.Clamp(ScrW() * 0.4, math.min(ScaleMenu(480), maxX), math.min(ScaleMenu(640), maxX))
	local sizeY = math.Clamp(ScaleMenu(70) + math.max(playerCount, 3) * (rowH + ScaleMenu(5)) + ScaleMenu(16), math.min(ScaleMenu(210), maxY), math.min(ScrH() * 0.46, maxY))

	guiltMenu = vgui.Create("ZFrame")
	guiltMenu:SetTitle("")
	guiltMenu:SetSize(sizeX, sizeY)
	guiltMenu:Center()
    guiltMenu:MakePopup()
    guiltMenu:SetKeyboardInputEnabled(false)
	if guiltMenu.SetColorBG then guiltMenu:SetColorBG(guiltMenuFill) end
	if guiltMenu.SetColorBR then guiltMenu:SetColorBR(guiltMenuOutline) end

    if IsValid(guiltMenu.btnClose) then
        guiltMenu.btnClose:SetVisible(false)
        guiltMenu.btnClose:SetMouseInputEnabled(false)
    end

    local title = vgui.Create("DLabel", guiltMenu)
    title:SetPos(ScaleMenu(12), ScaleMenu(8))
    title:SetTextColor(color_white)
    title:SetText("karma")
    title:SetFont("ZCity_Menu_Settings_Small")
    title:SizeToContents()

    local button = vgui.Create("DButton", guiltMenu)
    button:SetSize(ScaleMenu(22), ScaleMenu(22))
    button:SetPos(sizeX - ScaleMenu(30), ScaleMenu(8))
    button:SetText("X")
    button:SetFont("ZCity_Menu_Settings_Small")
    button:SetTextColor(color_white)
    button.Paint = PaintGuiltClose

    function button:DoClick()
        if IsValid(guiltMenu) then
            guiltMenu:Remove()
        end
    end

	function guiltMenu:Paint( w, h )
		PaintGuiltFrame(self, w, h)
	end

    local scroll = vgui.Create("DScrollPanel", guiltMenu)
    scroll:Dock(FILL)
    scroll:DockMargin(ScaleMenu(8), ScaleMenu(34), ScaleMenu(8), ScaleMenu(8))
    scroll.Paint = nil

    local sbar = scroll:GetVBar()
    sbar:SetHideButtons(true)
    sbar.Paint = PaintGuiltScrollBar
    sbar.btnGrip.Paint = PaintGuiltScrollGrip

    if playerCount == 0 then
        local empty = vgui.Create("DLabel", scroll)
        empty:Dock(FILL)
        empty:SetText("no punishments given")
        empty:SetFont("ZCity_Menu_Settings_Tiny")
        empty:SetTextColor(color_white)
        empty:SetContentAlignment(5)
        return
    end

    local first = true
    for ply, harm in pairs(tbl) do
        if not IsValid(ply) then continue end
        if harm <= 0.01 then continue end

        local but = vgui.Create("DButton")
		but:SetSize(0, rowH)
		but:Dock(TOP)
        local mg = ScaleMenu(4)
		but:DockMargin(mg, first and mg or 0, mg, ScaleMenu(4))
        first = false
		but:SetText("")
		but.guiltText = "Forgive "..ply:Name().."? You will forgive him "..math.Round(harm,1).." karma."
		but:SetTextColor(color_white)
        but.ply = ply
        but.name = ply:Name()
        but.harm = harm
        but.Paint = PaintGuiltButton

		function but:DoClick()
            net.Start("forgive_player")
            net.WriteEntity(ply)
            net.SendToServer()
            tbl[ply] = nil
            OpenMenu(tbl)
        end

		scroll:AddItem(but)
	end
end
