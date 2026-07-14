MODE.name = "riot"

local MODE = MODE

local voteEndTime = 0
local selectedVote = 0
local voteResults = {[1] = 0, [2] = 0, [3] = 0}
local showIntensity = 0
local shownIntensity = 2
local riotIntroTeam = nil
local riotIntroRoleName = nil
local RiotIntroStartTime = 0
local RiotIntroDuration = 10
local RiotVoteFadeStart = 0
local RiotVoteFadeEnd = 0
local RiotIntroMusic = nil
local RiotIntroMusicStart = 0
local tex_gradient_r = Material("vgui/gradient-r")
local tex_gradient_l = Material("vgui/gradient-l")
local tex_gradient_d = Material("vgui/gradient-d")

net.Receive("riot_start", function()
    shownIntensity = net.ReadInt(4)
    riotIntroTeam = net.ReadInt(4)
    riotIntroRoleName = net.ReadString()

    if IsValid(RiotVoteMenu) then
        RiotVoteMenu:Remove()
        RiotVoteMenu = nil
    end

    if RiotSound then
        RiotSound:Stop()
        RiotSound = nil
    end

    RiotIntroStartTime = CurTime()
    if RiotIntroMusic then
        RiotIntroMusic:Stop()
        RiotIntroMusic = nil
    end
    RiotIntroMusic = CreateSound(LocalPlayer(), "rem_track2.mp3")
    RiotIntroMusic:PlayEx(1.5, 100)
    RiotIntroMusicStart = RiotIntroStartTime
    MODE.RoundTextTilts = {}
    for i = 1, 64 do
        MODE.RoundTextTilts[i] = (math.random() < 0.5) and 3 or -3
    end
    MODE.CursorLerpX = 0
    MODE.CursorLerpY = 0
    showIntensity = CurTime() + 5
    zb.RemoveFade()
end)


local teams = {
	[0] = {
                objective = "Overrun the police and survive the clash.",
		name = "a Rioter",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
        },
        [1] = {
                objective = "Contain the riot and neutralize the threat.",
                name = "a Law Enforcement",
                color1 = Color(0,120,190),
                color2 = Color(0,120,190)
	},
}

local function riot_ease_out(x)
    return 1 - (1 - x) ^ 3
end

local function riot_draw_text(text, fontname, x, y, r, g, b, a, ang, xalign, yalign)
    local base = Matrix()
    base:Translate(Vector(x, y, 0))
    base:Rotate(Angle(0, ang, 0))
    base:Translate(Vector(-x, -y, 0))

    cam.PushModelMatrix(base)
        draw.SimpleText(text, fontname, x, y, Color(r, g, b, a), xalign, yalign)
    cam.PopModelMatrix()
end

local function GetIntensity(index)
    local intensities = RIOT_INTENSITIES or {}
    return intensities[index] or intensities[2] or {name = "Escalated", description = "", color = Color(255, 255, 255)}
end

local function GetVoteTotal()
    return (voteResults[1] or 0) + (voteResults[2] or 0) + (voteResults[3] or 0)
end

local function OpenVoteMenu()
    if IsValid(RiotVoteMenu) then RiotVoteMenu:Remove() end

    RiotVoteMenu = vgui.Create("DFrame")
    RiotVoteMenu:SetSize(ScrW(), ScrH())
    RiotVoteMenu:SetPos(0, 0)
    RiotVoteMenu:SetTitle("")
    RiotVoteMenu:ShowCloseButton(false)
    RiotVoteMenu:SetDraggable(false)
    RiotVoteMenu:MakePopup()
    RiotVoteMenu.OpenTime = CurTime()
    RiotVoteMenu.Paint = function(self, w, h)
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local titleFrac = math.Clamp(elapsed / 0.4, 0, 1)
        local pulse = 0.5 + math.sin(CurTime() * 4) * 0.5
        local titleY = h * 0.12 - (1 - titleFrac) * 24
        local timerLeft = math.max(math.ceil(voteEndTime - CurTime()), 0)
        local timerColor = timerLeft <= 5 and Color(255, 120 + pulse * 80, 120 + pulse * 80) or Color(225, 225, 225)

        hg.DrawBlur(self, 5)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 19, 235))
        surface.SetDrawColor(18, 18, 18, 65)
        surface.SetMaterial(tex_gradient_r)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetMaterial(tex_gradient_l)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(100, 100, 100, 35)
        surface.SetMaterial(tex_gradient_d)
        surface.DrawTexturedRect(0, 0, w, h)
        draw.SimpleText("RIOT INTENSITY", "ZCity_Menu_Small", w * 0.5, titleY, Color(225, 225, 225, 255 * titleFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Vote before the round starts", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.16 - (1 - titleFrac) * 18, Color(200, 200, 200, 255 * titleFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("TIME LEFT: " .. timerLeft, "ZCity_Menu_Small", w * 0.5, h * 0.86, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    RiotVoteMenu.Think = function()
        if CurTime() >= voteEndTime and IsValid(RiotVoteMenu) then
            RiotVoteMenu:Remove()
            RiotVoteMenu = nil
        end
    end

    for i = 1, 3 do
        local data = GetIntensity(i)
        local button = vgui.Create("DButton", RiotVoteMenu)
        button:SetSize(ScrW() * 0.7, ScrH() * 0.16)
        button.TargetX = ScrW() * 0.15
        button.TargetY = ScrH() * (0.25 + (i - 1) * 0.18)
        button:SetPos((i % 2 == 0) and ScrW() + 120 or -button:GetWide() - 120, button.TargetY)
        button:SetText("")
        button.OpenTime = CurTime() + (i - 1) * 0.08
        button.HoverFrac = 0
        button.SelectFrac = 0
        button.Think = function(self)
            local x, y = self:GetPos()
            local intro = math.Clamp((CurTime() - self.OpenTime) / 0.35, 0, 1)
            self.HoverFrac = Lerp(FrameTime() * 10, self.HoverFrac, self:IsHovered() and 1 or 0)
            self.SelectFrac = Lerp(FrameTime() * 10, self.SelectFrac, selectedVote == i and 1 or 0)
            self:SetPos(Lerp(FrameTime() * 10, x, self.TargetX + self.HoverFrac * 10), self.TargetY - (1 - intro) * 4 - self.HoverFrac * 6)
        end
        button.Paint = function(self, w, h)
            local total = GetVoteTotal()
            local votes = voteResults[i] or 0
            local percent = total > 0 and math.floor(votes / total * 100) or 0
            local glow = math.max(self.HoverFrac, self.SelectFrac)
            local alpha = 190 + glow * 35
            local borderColor = Color(225, 225, 225, 120 + glow * 80)
            local fillColor = Color(0, 0, 0, alpha)

            draw.RoundedBox(0, 0, 0, w, h, fillColor)
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(data.name, "ZCity_Menu_Small", 24 + self.HoverFrac * 6, h * 0.32, Color(225, 225, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.description, "ZCity_Menu_Settings_Small", 24 + self.HoverFrac * 6, h * 0.7, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(percent .. "%", "ZCity_Menu_Small", w - 24 - self.HoverFrac * 6, h * 0.32, Color(225, 225, 225), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw.SimpleText(votes .. " votes", "ZCity_Menu_Settings_Small", w - 24 - self.HoverFrac * 6, h * 0.7, Color(210, 210, 210), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        button.DoClick = function()
            local oldVote = selectedVote
            selectedVote = i
            surface.PlaySound("ui/rem_select.wav")
            net.Start("riot_change_vote")
            net.WriteInt(oldVote, 4)
            net.WriteInt(i, 4)
            net.SendToServer()
        end
    end
end

function MODE:RenderScreenspaceEffects()
    local ct = CurTime()

    if RiotVoteFadeEnd > ct then
        local frac = math.Clamp((ct - RiotVoteFadeStart) / math.max(RiotVoteFadeEnd - RiotVoteFadeStart, 0.001), 0, 1)
        surface.SetDrawColor(0, 0, 0, 255 * frac)
        surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
        return
    end

    if RiotIntroStartTime <= 0 then return end

    local introTime = ct - RiotIntroStartTime
    if introTime > RiotIntroDuration then return end

    zb.RemoveFade()

    local introFade = math.Clamp(introTime / 1.25, 0, 1)
    local outFade = math.Clamp((RiotIntroDuration - introTime) / 4, 0, 1)
    surface.SetDrawColor(0, 0, 0, 255 * introFade * outFade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
    if not RiotIntroStartTime or RiotIntroStartTime <= 0 then return end
    if lply:Team() == TEAM_SPECTATOR then return end

    local t = CurTime() - RiotIntroStartTime
    if t > RiotIntroDuration then return end

    zb.RemoveFade()

    local intro_fade = math.Clamp(t / 1.25, 0, 1)
    local out_fade = math.Clamp((RiotIntroDuration - t) / 4, 0, 1)
    local team_ = riotIntroTeam or lply:Team()
    local teamData = teams[team_] or teams[0]
    local intensityData = GetIntensity(shownIntensity)
    local ColorRole = teamData.color1

    if RiotIntroMusic then
        RiotIntroMusic:ChangeVolume(math.min(intro_fade * out_fade * 1.5, 1.5), 0)
    end

    MODE.CursorLerpX = Lerp(FrameTime() * 6, MODE.CursorLerpX or 0, (gui.MouseX() - sw * 0.5) / (sw * 0.5))
    MODE.CursorLerpY = Lerp(FrameTime() * 6, MODE.CursorLerpY or 0, (gui.MouseY() - sh * 0.5) / (sh * 0.5))

    local cursor_reach = ScreenScale(7)
    local cox = math.Clamp(MODE.CursorLerpX, -1, 1) * cursor_reach
    local coy = math.Clamp(MODE.CursorLerpY, -1, 1) * cursor_reach

    local elements = {}
    local function add(text, fontname, col, x, y, dir, delay, plx, notilt)
        elements[#elements + 1] = {
            text = text,
            font = fontname,
            r = col.r, g = col.g, b = col.b,
            x = x, y = y,
            dir = dir, delay = delay, plx = plx or 1,
            notilt = notilt,
        }
    end

    add("Riot", "ZB_HomicideHeader", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9)
    add(intensityData.name, "ZB_HomicideMediumLarge", Color(255, 255, 255), sw * 0.5, sh * 0.2, "left", 0.25, 0.95)
    add(intensityData.description, "ZCity_Menu_Settings_Small", Color(225, 225, 225), sw * 0.5, sh * 0.26, "left", 0.45, 1, true)
    add("You are " .. (riotIntroRoleName or teamData.name), "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, sh * 0.5, "right", 0.7, 1.1)
    add(teamData.objective, "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true)

    local tilts = MODE.RoundTextTilts or {}
    for i, el in ipairs(elements) do
        local appear = riot_ease_out(math.Clamp((t - el.delay) / 2.0, 0, 1))
        local a = 255 * appear * intro_fade * out_fade

        if a > 1 then
            local slide = 1 - appear
            local x, y = el.x, el.y

            if el.dir == "left" then
                x = x - slide * ScreenScale(220)
            elseif el.dir == "right" then
                x = x + slide * ScreenScale(220)
            elseif el.dir == "bottom" then
                y = y + slide * ScreenScale(120)
            elseif el.dir == "top" then
                y = y - slide * ScreenScale(120)
            end

            x = x + cox * el.plx
            y = y + coy * el.plx

            local tilt = el.notilt and 0 or (tilts[i] or 3) * appear
            riot_draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

	if hg.PluvTown.Active then
        local pluv_appear = riot_ease_out(math.Clamp(t / 1.0, 0, 1))
        local pluv_a = pluv_appear * out_fade

        surface.SetMaterial(hg.PluvTown.PluvMadness)
        surface.SetDrawColor(255, 255, 255, math.random(175, 255) * pluv_a / 2)
        surface.DrawTexturedRect(sw * 0.25 + cox, sh * 0.44 - ScreenScale(15) + coy, sw / 2, ScreenScale(30))

        draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2 + cox, sh * 0.44 - ScreenScale(2) + coy, Color(0, 0, 0, 255 * pluv_a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local CreateEndMenu

net.Receive("riot_roundend",function()
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end)

net.Receive("riot_start_vote", function()
    voteEndTime = net.ReadFloat()
    selectedVote = 0
    voteResults = {[1] = 0, [2] = 0, [3] = 0}
    riotIntroTeam = nil
    riotIntroRoleName = nil
    RiotIntroStartTime = 0
    RiotVoteFadeStart = 0
    RiotVoteFadeEnd = 0
    if RiotIntroMusic then
        RiotIntroMusic:Stop()
        RiotIntroMusic = nil
    end
    RiotIntroMusic = CreateSound(LocalPlayer(), "rem_track1.mp3")
    RiotIntroMusic:PlayEx(1.5, 100)
    RiotIntroMusicStart = 0
    OpenVoteMenu()
end)

net.Receive("riot_vote_update", function()
    voteResults = net.ReadTable() or {[1] = 0, [2] = 0, [3] = 0}
end)

net.Receive("riot_vote_result", function()
    shownIntensity = net.ReadInt(4)
    voteResults = net.ReadTable() or {[1] = 0, [2] = 0, [3] = 0}
    if IsValid(RiotVoteMenu) then
        RiotVoteMenu:Remove()
        RiotVoteMenu = nil
    end
    if RiotIntroMusic then
        RiotIntroMusic:ChangeVolume(0, 3)
    end
    RiotVoteFadeStart = CurTime()
    RiotVoteFadeEnd = CurTime() + 3
end)

net.Receive("riot_show_selected_mode", function()
    shownIntensity = net.ReadInt(4)
    surface.PlaySound("buttons/combine_button1.wav")
end)

hook.Add("Think", "RiotIntroSoundCleanup", function()
    if not RiotIntroMusic then return end

    local mode = CurrentRound()
    if not mode or mode.name ~= "riot" then
        RiotIntroMusic:Stop()
        RiotIntroMusic = nil
        RiotIntroMusicStart = 0
        return
    end

    if RiotIntroStartTime > 0 and CurTime() - RiotIntroStartTime > RiotIntroDuration then
        RiotIntroMusic:Stop()
        RiotIntroMusic = nil
        RiotIntroMusicStart = 0
    end
end)

local colGray = Color(85,85,85,255)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
    hmcdEndMenu:Remove()
    hmcdEndMenu = nil
end

CreateEndMenu = function()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

    surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")
	
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos( lengthX - lengthX/1.1, 4)
		surface.DrawText("Close")
	end

    hmcdEndMenu.Paint = function(self,w,h)
		BlurBackground(self)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText("Players:")

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i,ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
            local col1 = (ply:Alive() and colRed) or colGray
            local col2 = (ply:Alive() and colRedUp) or colSpect1
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

            local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			
			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lengthY/2 + 1)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lengthY/2)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

            
			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			surface.SetTextPos(15,h/2 - lengthY/2)
			surface.DrawText((ply:Name() .. (not ply:Alive() and " - died" or "")) or "He quited...")

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Frags() or "He quited..." )
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(ply:Frags() or "He quited...")
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
    if IsValid(RiotVoteMenu) then
        RiotVoteMenu:Remove()
        RiotVoteMenu = nil
    end
    riotIntroTeam = nil
    riotIntroRoleName = nil
    RiotVoteFadeStart = 0
    RiotVoteFadeEnd = 0
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
