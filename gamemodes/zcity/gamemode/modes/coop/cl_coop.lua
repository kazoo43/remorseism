MODE.name = "coop"

local MODE = MODE

net.Receive("coop_start",function()
	zb.RemoveFade()
	hg.DynaMusic:Start("hl_coop")

	MODE.DynamicFadeScreenEndTime = CurTime() + 8.5

	MODE.RoundBeginSound = CreateSound(LocalPlayer(), "hl2mode1.wav")
	if MODE.RoundBeginSound then
		MODE.RoundBeginSound:Play()
		MODE.RoundBeginSound:ChangeVolume(1, 0)
	end

	MODE.RoundTextTilts = {}
	for i = 1, 16 do
		MODE.RoundTextTilts[i] = math.Rand(-3, 3)
	end
end)

local teams = {
	[0] = {
		objective = "Go to the end of the map!",
		name = "rebel",
		color1 = Color(155,55,0),
		color2 = Color(129,129,129)
	}
}

function MODE:RenderScreenspaceEffects()
	local fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if time_diff > 0 then
		zb.RemoveFade()

		local fade = math.min(time_diff / 2.5, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
	end
end

local HMCD_ScreenDuration = 8.5

local function hmcd_ease_out(x)
	return 1 - (1 - x) ^ 3
end

local function hmcd_draw_text(text, fontname, x, y, r, g, b, a, ang, xalign, yalign)
	local m = Matrix()
	m:Translate(Vector(x, y, 0))
	m:Rotate(Angle(0, ang, 0))
	m:Translate(Vector(-x, -y, 0))

	cam.PushModelMatrix(m)
		draw.SimpleText(text, fontname, x, y, Color(r, g, b, a), xalign, yalign)
	cam.PopModelMatrix()
end

function MODE:HUDPaint()

	local startTimer = GetGlobalVar("coop_first_round_timer", 0)

	if startTimer > CurTime() then
		surface.SetFont("ZB_HomicideMediumLarge")

		local w, h = surface.GetTextSize("Awaiting players: ")
		local w2, h2 = surface.GetTextSize("00:00")

		surface.SetTextPos(sw * 0.5 - (w + w2) * 0.5, sh * 0.1 - h * 0.5)
		surface.SetTextColor(Color(0,162,255, 255))
		surface.DrawText("Awaiting players: ")

		surface.SetTextPos(sw * 0.5 + (w - w2) * 0.5, sh * 0.1 - h * 0.5)
		surface.DrawText(string.FormattedTime(startTimer - CurTime(), "%02i:%02i"))
	end

	local t = CurTime() - zb.ROUND_START
	if zb.ROUND_START + HMCD_ScreenDuration < CurTime() then
		if MODE.RoundBeginSound then
			MODE.RoundBeginSound:Stop()
			MODE.RoundBeginSound = nil
		end

		return
	end

	local out_fade = math.Clamp((HMCD_ScreenDuration - t) / 1.5, 0, 1)

	if MODE.RoundBeginSound then
		MODE.RoundBeginSound:ChangeVolume(out_fade, 0)
	end

	MODE.CursorLerpX = Lerp(FrameTime() * 6, MODE.CursorLerpX or 0, (gui.MouseX() - sw * 0.5) / (sw * 0.5))
	MODE.CursorLerpY = Lerp(FrameTime() * 6, MODE.CursorLerpY or 0, (gui.MouseY() - sh * 0.5) / (sh * 0.5))

	local cursor_reach = ScreenScale(7)
	local cox = math.Clamp(MODE.CursorLerpX, -1, 1) * cursor_reach
	local coy = math.Clamp(MODE.CursorLerpY, -1, 1) * cursor_reach

	if not lply:Alive() then return end
	zb.RemoveFade()

	local ColorRole = teams[0].color1
	local Rolename = (lply.role and lply.role.name) or "Unknown"
	local Objective = lply.PlayerClassName == "Gordon" and "Lead the resistance to victory!" or "Follow the Gordon!"

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

	add("Homicide | CO-OP", "ZB_HomicideHeader", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9)
	add("You are " .. Rolename, "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, sh * 0.5, "right", 0.7, 1.1)

	local cur_y = sh * 0.5
	local stack_delay = 1.1

	if lply.SubRole and lply.SubRole != "" then
		cur_y = cur_y + ScreenScale(20)
		add(((MODE.SubRoles and MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	if lply.Profession and lply.Profession != "" then
		cur_y = cur_y + ScreenScale(20)
		add("Occupation: " .. ((MODE.Professions and MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession), "ZB_HomicideMedium", teams[0].color2, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	add(Objective, "ZB_HomicideMedium", teams[0].color2, sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true)

	local tilts = MODE.RoundTextTilts or {}

	for i, el in ipairs(elements) do
		local appear = hmcd_ease_out(math.Clamp((t - el.delay) / 2.0, 0, 1))
		local a = 255 * appear * out_fade

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

			hmcd_draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

local CreateEndMenu

net.Receive("coop_roundend",function()
    CreateEndMenu()
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

    hmcdEndMenu.PaintOver = function(self,w,h)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText("Players:")

	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			if !IsValid(ply) then return end
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
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
