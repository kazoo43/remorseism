
MODE.name = "dm"

local MODE = MODE

local radius = nil
local mapsize = 7500

local roundend = false
local DM_ScreenDuration = 10
local dmZoneBursts = {}

local snds = {
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/ujuwzquyre/01.%20A%20Grim%20Feeling.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/zgagxqybov/02.%20Alley%20.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/qsoislqepd/17.%20Hazardous.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/zqxkrixwbn/26.%20Rooftops.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/kvlgywwwnt/13.%20Escape.mp3"
}

local deathmatch_nozone = ConVarExists("deathmatch_nozone") and GetConVar("deathmatch_nozone") or CreateConVar("deathmatch_nozone", 0, FCVAR_REPLICATED, "Allows to disable deathmatch mode zone.", 0, 1)

local function restartMusic()
	local snd = snds[math.random(#snds)]

	if IsValid(dmmusic) then
		dmmusic:Stop()
		dmmusic = nil
	end
	
	sound.PlayURL(snd, "mono noblock noplay", function(station, errID, err)
		if IsValid(station) then
			station:EnableLooping(true)
			station:SetVolume(0.1)
			
			dmmusic = station
		else
			print(errID, err)
		end
	end)
end


net.Receive("dm_start",function()
	roundend = false

	zb.RemoveFade()
	
	ZonePos = net.ReadVector()
	zonedistance = net.ReadFloat()

        StartTime = CurTime()
        MODE.DynamicFadeScreenEndTime = CurTime() + DM_ScreenDuration
        MODE.RoundTextTilts = {}

        for i = 1, 64 do
                MODE.RoundTextTilts[i] = (math.random() < 0.5) and 3 or -3
        end

        MODE.CursorLerpX = 0
        MODE.CursorLerpY = 0

        if MODE.RoundBeginSound then
                MODE.RoundBeginSound:Stop()
                MODE.RoundBeginSound = nil
        end

        MODE.RoundBeginSound = CreateSound(LocalPlayer(), "rem_dmround.mp3")
        MODE.RoundBeginSound:PlayEx(1, 100)

	sound.PlayFile( "sound/ambient/energy/force_field_loop1.wav", "noblock", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			zb.SoundStation = station
			
			station:Play()
			station:EnableLooping( true )
			station:SetVolume(0)
		end
	end )
end)

net.Receive("dm_zone_burst", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) then return end

        local burst = dmZoneBursts[ply]
        if burst and burst.station then
                burst.station:Stop()
        end

        dmZoneBursts[ply] = {
                endTime = CurTime() + 1.65
        }
end)

hook.Add("Think", "ZoneSoundThink", function()
	if CurrentRound() and CurrentRound().name ~= "dm" then return end
	local station = zb.SoundStation
	if not IsValid(station) then return end
	if deathmatch_nozone:GetBool() then return end
	local radius = MODE.GetZoneRadius()
	local volume = math.Clamp((LocalPlayer():GetPos():Distance(ZonePos) - radius) + 200,0,200) / 200
	station:SetVolume(volume)
end)

hook.Add("Think", "DMZoneBurstSound", function()
        for ply, burst in pairs(dmZoneBursts) do
                if not IsValid(ply) or CurTime() >= burst.endTime then
                        if burst.station then
                                burst.station:Stop()
                        end

                        dmZoneBursts[ply] = nil
                        continue
                end

                local target = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or IsValid(ply:GetNWEntity("RagdollDeath")) and ply:GetNWEntity("RagdollDeath") or ply

                if burst.target ~= target then
                        if burst.station then
                                burst.station:Stop()
                        end

                        burst.target = target
                        burst.station = nil

                        if IsValid(target) then
                                burst.station = CreateSound(target, "rem_intracranialied.mp3")
                                burst.station:PlayEx(1, 100)
                        end
                end
        end
end)

local fighter = {
    objective = "Kill everyone.",
    name = "Fighter",
    color1 = Color(0,120,190)
}

local function dm_ease_out(x)
        return 1 - (1 - x) ^ 3
end

local function dm_draw_text(text, fontname, x, y, r, g, b, a, ang, xalign, yalign)
        local m = Matrix()
        m:Translate(Vector(x, y, 0))
        m:Rotate(Angle(0, ang, 0))
        m:Translate(Vector(-x, -y, 0))

        cam.PushModelMatrix(m)
                draw.SimpleText(text, fontname, x, y, Color(r, g, b, a), xalign, yalign)
        cam.PopModelMatrix()
end

--local zonemodel = ClientsideModel("models/hunter/misc/sphere375x375.mdl",RENDERGROUP_TRANSLUCENT)
--zonemodel:SetNoDraw(true)
--zonemodel:SetMaterial("hmcd_dmzone")

local mat = Material("hmcd_dmzone")
local mapsize = 7500

function MODE:PostDrawTranslucentRenderables(bDepth, bSkybox, isDraw3DSkybox)
	if(!bSkybox and !isDraw3DSkybox) and !deathmatch_nozone:GetBool() then
		local radius = MODE.GetZoneRadius()
		render.SetMaterial(mat)
          render.SetColorModulation(1, 0.15, 0.15)
          render.SetBlend(0.45)
                render.DrawSphere( ZonePos, -radius, 60, 60, color_white )
          render.SetBlend(1)
          render.SetColorModulation(1, 1, 1)
	end
	--zonemodel:DrawModel()
end

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

function MODE:HUDPaint()
        if StartTime and (CurTime() - StartTime) >= DM_ScreenDuration and zb.ROUND_START + 20 > CurTime() then
                local timerText = string.FormattedTime(zb.ROUND_START + 20 - CurTime(), "%02i:%02i:%02i")
                surface.SetFont("ZB_HomicideMediumLarge")
                local tw, th = surface.GetTextSize(timerText)

                draw.SimpleTextOutlined(timerText, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.06, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 220))
        end

        if not lply:Alive() or lply:Team() == TEAM_SPECTATOR or not StartTime then return end

        local t = CurTime() - StartTime
        if t > DM_ScreenDuration then
                if MODE.RoundBeginSound then
                        MODE.RoundBeginSound:Stop()
                        MODE.RoundBeginSound = nil
                end

                return
        end

        local out_fade = math.Clamp((DM_ScreenDuration - t) / 1.5, 0, 1)

        if MODE.RoundBeginSound then
                MODE.RoundBeginSound:ChangeVolume(out_fade, 0)
        end

        MODE.CursorLerpX = Lerp(FrameTime() * 6, MODE.CursorLerpX or 0, (gui.MouseX() - sw * 0.5) / (sw * 0.5))
        MODE.CursorLerpY = Lerp(FrameTime() * 6, MODE.CursorLerpY or 0, (gui.MouseY() - sh * 0.5) / (sh * 0.5))

        local cursor_reach = ScreenScale(7)
        local cox = math.Clamp(MODE.CursorLerpX, -1, 1) * cursor_reach
        local coy = math.Clamp(MODE.CursorLerpY, -1, 1) * cursor_reach

        local elements = {}
        local tilts = MODE.RoundTextTilts or {}

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

        add("DeathMatch", "ZB_HomicideHeader", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9)
        add("You are a " .. fighter.name, "ZB_HomicideMediumLarge", fighter.color1, sw * 0.5, sh * 0.5, "right", 0.7, 1.1)
        add(fighter.objective, "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true)

        for i, el in ipairs(elements) do
                local appear = dm_ease_out(math.Clamp((t - el.delay) / 2.0, 0, 1))
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

                        dm_draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
        end

        if hg.PluvTown.Active then
                local pluv_appear = dm_ease_out(math.Clamp(t / 1.0, 0, 1))
                local pluv_a = pluv_appear * out_fade

                surface.SetMaterial(hg.PluvTown.PluvMadness)
                surface.SetDrawColor(255, 255, 255, math.random(175, 255) * pluv_a / 2)
                surface.DrawTexturedRect(sw * 0.25 + cox, sh * 0.44 - ScreenScale(15) + coy, sw / 2, ScreenScale(30))

                draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2 + cox, sh * 0.44 - ScreenScale(2) + coy, Color(0, 0, 0, 255 * pluv_a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
end

local CreateEndMenu = nil
local wonply = nil

net.Receive("dm_end",function()
	local ent = net.ReadEntity()
	local most_violent_player = net.ReadEntity()

        for ply, burst in pairs(dmZoneBursts) do
                if burst.station then
                        burst.station:Stop()
                end
                dmZoneBursts[ply] = nil
        end

	if IsValid(most_violent_player) then
		most_violent_player.most_violent_player = true
	end

	wonply = nil
	if IsValid(ent) then
		ent.won = true
		wonply = ent
	end

	zb.SoundStation = nil
	roundend = CurTime()
	
	if(MODE.SoundStation and MODE.SoundStation:IsValid())then
		MODE.SoundStation:Stop()
		
		MODE.SoundStation = nil
	end
	
end)

local colGray = Color(85,85,85,255)
local colRed = Color(217,201,99)
local colRedUp = Color(207,181,59)

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

    hmcdEndMenu.PaintOver = function(self,w,h)

		local txt = (wonply and wonply:GetPlayerName() or "Nobody").." won!"
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(txt)
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText(txt)
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i,ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			local col1 = ((ply.won or ply.most_violent_player) and colRed) or (ply:Alive() and colBlue) or colGray
            local col2 = ((ply.won or ply.most_violent_player) and colRedUp) or (ply:Alive() and colBlueUp) or colSpect1
			
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
			surface.DrawText((ply:Name() .. (ply.most_violent_player and " - MVP" or (not ply:Alive() and " - died" or ""))))

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
    for i,ply in player.Iterator() do
		ply.won = nil
		ply.most_violent_player = nil
    end

    for ply, burst in pairs(dmZoneBursts) do
            if burst.station then
                    burst.station:Stop()
            end
            dmZoneBursts[ply] = nil
    end

    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
