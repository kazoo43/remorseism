zb = zb or {}
include("shared.lua")
include("libraries/cl_roundstart.lua")
include("loader.lua")

if not ConVarExists("hg_newspectate") then
    CreateClientConVar("hg_newspectate", "1", true, false, "Enables smooth spectator camera transitions", 0, 1)
end

function CurrentRound()
	return zb.modes[zb.CROUND]
end

zb.ROUND_STATE = 0
--0 = players can join, 1 = round is active, 2 = endround
local vecZero = Vector(0.2, 0.2, 0.2)
local vecFull = Vector(1, 1, 1)
spect,prevspect,viewmode = nil,nil,1
local hullscale = Vector(0,0,0)
net.Receive("ZB_SpectatePlayer", function(len)
	spect = net.ReadEntity()
	prevspect = net.ReadEntity()
	viewmode = net.ReadInt(4)

	timer.Simple(0.1,function()
		-- LocalPlayer():BoneScaleChange()
		LocalPlayer():SetHull(-hullscale,hullscale)
		LocalPlayer():SetHullDuck(-hullscale,hullscale)

		if viewmode == 3 then
			LocalPlayer():SetMoveType(MOVETYPE_NOCLIP)
		end
	end)
end)

zb.ROUND_TIME = zb.ROUND_TIME or 400
zb.ROUND_START = zb.ROUND_START or CurTime()
zb.ROUND_BEGIN = zb.ROUND_BEGIN or CurTime() + 5

net.Receive("updtime",function()
	local time = net.ReadFloat()
	local time2 = net.ReadFloat()
	local time3 = net.ReadFloat()

	zb.ROUND_TIME = time
	zb.ROUND_START = time2
	zb.ROUND_BEGIN = time3
end)

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local blursettings = {}
local hg_potatopc
hg = hg or {}
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	// old blur
	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		local x, y = panel:LocalToScreen(0, 0)
		if blursettings and blursettings[1] == amount and blursettings[2] == passes then
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
			return
		end
		blursettings = {amount, passes}
		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end

	--surface.SetMaterial(blur2)
	--surface.SetDrawColor(color_white)
	--local x, y = panel:LocalToScreen(0, 0)
--
	--// those are currently hardcoded cuz it would be too much of a hassle to change this
	--blur2:SetFloat("$c0_x", (amount or 5) * 2500) // density
	--blur2:SetFloat("$c0_y", (passes or 0.2) * 2000) // noise (inverted)
	--blur2:SetFloat("$c0_z", 1) // blending
--
	--render.UpdateScreenEffectTexture()
	--surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())

	-- surface.SetDrawColor(0, 0, 0, alpha or 125)
	-- surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

BlurBackground = BlurBackground or hg.DrawBlur

local keydownattack
local keydownattack2
local keydownreload

hook.Add("HUDPaint","FUCKINGSAMENAMEUSEDINHOOKFUCKME",function()
    if LocalPlayer():Alive() then return end
	local spect = LocalPlayer():GetNWEntity("spect")
	if not IsValid(spect) then return end
	if viewmode == 3 then return end
	
	surface.SetFont("HomigradFont")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = "Spectating player: "..spect:Name()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7)
	surface.DrawText(txt)
	local txt = "In-game name: "..spect:GetPlayerName()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7 + h)
	surface.DrawText(txt)
end)

hook.Add("HG_CalcView", "zzzzzzzUwU", function(ply, pos, angles, fov)
	if not lply:Alive() then
		if lply:KeyDown(IN_ATTACK) then
			if not keydownattack then
				keydownattack = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK,32)
				net.SendToServer()
			end
		else
			keydownattack = false
		end

		if lply:KeyDown(IN_ATTACK2) then
			if not keydownattack2 then
				keydownattack2 = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK2,32)
				net.SendToServer()
			end
		else
			keydownattack2 = false
		end

		if lply:KeyDown(IN_RELOAD) then
			if not keydownreload then
				keydownreload = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_RELOAD,32)
				net.SendToServer()
			end
		else
			keydownreload = false
		end

		local spect = lply:GetNWEntity("spect",spect)
		if not IsValid(spect) then return end

		local viewmode = lply:GetNWInt("viewmode",viewmode)
		
		if viewmode == 3 then
			if lply:GetMoveType()!=MOVETYPE_NOCLIP then
				lply:SetMoveType(MOVETYPE_NOCLIP)
			end
			lply:SetObserverMode(OBS_MODE_ROAMING)
			return
		else
			lply:SetPos(spect:GetPos())
		end
		
		local ent = hg.GetCurrentCharacter(spect)
		if not IsValid(ent) then return end
		
		local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("ValveBiped.Bip01_Spine1") or 1
		local bon = ent:GetBoneMatrix(headBone)
		
		if not bon then 
			local eyePos = ent:EyePos()
			if eyePos and eyePos ~= vector_origin then
				pos = eyePos
				ang = ent:EyeAngles()
			else
				pos = ent:GetPos() + Vector(0, 0, 64)
				ang = ent:GetAngles()
			end
		else
			pos, ang = bon:GetTranslation(), bon:GetAngles()
		end

		local eyePos, eyeAng = lply:EyePos(), lply:EyeAngles()
		
		local tr = {}
		tr.start = pos
		tr.endpos = pos + eyeAng:Forward() * -120
		tr.filter = {ent, lply, spect}
		tr.mins = Vector(-4, -4, -4)
		tr.maxs = Vector(4, 4, 4)
		tr = util.TraceHull(tr)

		if viewmode == 2 then
			pos = tr.HitPos + eyeAng:Forward() * 8
			ang = eyeAng
		elseif viewmode == 1 then
			if ent ~= spect and IsValid(ent) then
				local eyeAtt = ent:GetAttachment(ent:LookupAttachment("eyes"))
				if eyeAtt then
					ang = eyeAtt.Ang
				else
					ang = spect:EyeAngles()
				end
			else
				ang = spect:EyeAngles()
			end
			pos = pos + spect:EyeAngles():Forward() * 8
		else
			pos = eyePos
			ang = eyeAng
		end
		
		ang[3] = 0
		
		local view
		local hg_newspectate = GetConVar("hg_newspectate")
		if hg_newspectate and hg_newspectate:GetBool() then
			if not lply.spectLastPos then
				lply.spectLastPos = pos
				lply.spectLastAng = ang
			end
			
			local lerpFactor = FrameTime() * 10
			lply.spectLastPos = LerpVector(lerpFactor, lply.spectLastPos, pos)
			lply.spectLastAng = LerpAngle(lerpFactor, lply.spectLastAng, ang)

			view = {
				origin = lply.spectLastPos,
				angles = lply.spectLastAng,
				fov = fov,
			}
		else
			view = {
				origin = pos,
				angles = ang,
				fov = fov,
			}
		end

		return view
	else
		lply.spectLastPos = nil
		lply.spectLastAng = nil
		lply:SetObserverMode(OBS_MODE_NONE)
	end
end)

zb.fade = zb.fade or 0

hook.Add("RenderScreenspaceEffects", "huyhuyUwU", function()
	if zb.fade > 0 then
		zb.fade = math.Approach(zb.fade, 0, FrameTime() * 1)

		surface.SetDrawColor(0, 0, 0, 255 * math.min(zb.fade, 1))
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end)

zb.ROUND_STATE = 0
net.Receive("RoundInfo", function()
	local rnd = net.ReadString()
	
	hook.Run("RoundInfoCalled", rnd)

	if zb.CROUND ~= rnd then
		if hg.DynaMusic then
			hg.DynaMusic:Stop()
		end
	end

	zb.CROUND = rnd

	zb.ROUND_STATE = net.ReadInt(4)
	
	if zb.ROUND_STATE == 0 then
		zb.fade = 7
	end

	if zb.CROUND ~= "" then
		if CurrentRound() then
			if zb.ROUND_STATE == 3 then
				if CurrentRound().EndRound then
					CurrentRound():EndRound()
				end
			elseif zb.ROUND_STATE == 1 then
				if CurrentRound().RoundStart then
					CurrentRound():RoundStart()
				end
			end
		end
	end
end)

if IsValid(scoreBoardMenu) then
	scoreBoardMenu:Remove()
	scoreBoardMenu = nil
end

hook.Add("Player Disconnected","retrymenu",function(data)
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
end)

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font_default = "Lora"
local hg_font_legacy_default = "Courier Prime"
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", hg_font_default, true, false, "Change UI text font")
local hg_font_value = hg_font:GetString()

if hg_font_value == "" or hg_font_value == hg_font_legacy_default then
	RunConsoleCommand("hg_font", hg_font_default)
	hg_font_value = hg_font_default
end

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Courier Prime"
    local usefont = hg_font_default

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_InterfaceSmall", {
    font = font(),
    size = ScreenScale(6),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_ScrappersMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMediumLarge", {
    font = font(),
    size = 35,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceLarge", {
    font = font(),
    size = ScreenScale(20),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceHumongous", {
    font = font(),
    size = 200,
    weight = 400,
    antialias = true
})

hg.playerInfo = hg.playerInfo or {}

local function addToPlayerInfo(ply, muted, volume)
	hg.playerInfo[ply:SteamID()] = {muted and true or false, volume}

	local json = util.TableToJSON(hg.playerInfo)
	file.Write("zcity_muted.txt", json)

	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end
	end

	//PrintTable(hg.playerInfo)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "zcityhuy", function(data)
	local ply = Player(data.userid)
	if IsValid(ply) and ply.SetMuted and hg.playerInfo and hg.playerInfo[data.networkid] then
		ply:SetMuted(hg.playerInfo[data.networkid][1])
		ply:SetVoiceVolumeScale(hg.playerInfo[data.networkid][2])
	end
end)

hook.Add("InitPostEntity", "furryhuy", function()
	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end

		if hg.playerInfo then
			for i, ply in player.Iterator() do
				if not istable(hg.playerInfo[ply:SteamID()]) then
					local muted = hg.playerInfo[ply:SteamID()]
					hg.playerInfo[ply:SteamID()] = {}
					hg.playerInfo[ply:SteamID()][1] = muted
					hg.playerInfo[ply:SteamID()][2] = 1
				end//compatibility with old json

				if hg.playerInfo[ply:SteamID()] then
					ply:SetMuted(hg.playerInfo[ply:SteamID()][1])
					ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
				end
			end	
		end
	end
end)

local colGray = Color(122,122,122,255)
local colBlue = Color(130,10,10)
local colBlueUp = Color(160,30,30)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(85,85,85,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

hg.muteall = false
hg.mutespect = false

local function OpenPlayerSoundSettings(selfa, ply)
	local Menu = DermaMenu()
	
	if not hg.playerInfo[ply:SteamID()] or not istable(hg.playerInfo[ply:SteamID()]) then addToPlayerInfo(ply, false, 1) end

	local mute = Menu:AddOption( "Mute", function(self)
		if hg.muteall || hg.mutespect then return end
		
		self:SetChecked(not ply:IsMuted())
		ply:SetMuted( not ply:IsMuted() )
		selfa:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end ) -- get your stupid one line ass outta here

	mute:SetIsCheckable( true )
	mute:SetChecked( ply:IsMuted() )
	local volumeSlider = vgui.Create("DSlider", Menu)
	volumeSlider:SetLockY( 0.5 )
	volumeSlider:SetTrapInside( true )
	volumeSlider:SetSlideX(hg.playerInfo[ply:SteamID()][2]) 
	volumeSlider.OnValueChanged = function(self, x, y)
		if not IsValid(ply) then return end
		if hg.muteall or (hg.mutespect && !ply:Alive()) then return end
		hg.playerInfo[ply:SteamID()][2] = x
		ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end

	function volumeSlider:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
		draw.RoundedBox( 0, 0, 0, w*self:GetSlideX(), h, Color( 255, 0, 0 ) )
		draw.DrawText( ( math.Round( 100*self:GetSlideX(), 0 ) ).."%", "DermaDefault", w/2, h/4, color_white, TEXT_ALIGN_CENTER )
	end
	function volumeSlider.Knob.Paint(self) end

	Menu:AddPanel(volumeSlider)
	Menu:Open()
end



hook.Add("Player Getup", "nomorespect", function(ply)
	if not hg.mutespect then return end

	//ply:SetMuted(ply.oldmutedspect)
	ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
	//ply.oldmutedspect = nil

	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceMute", function(ply)
	if not hg.mutespect then return end

	//ply.oldmutedspect = ply:IsMuted()
	//ply:SetMuted(hg.mutespect)
	ply:SetVoiceVolumeScale(0)
	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceEffect", function(ply)
	if eightbit and eightbit.EnableEffect and ply.UserID then
		eightbit.EnableEffect(ply:UserID(), 0)
	end
end)

local SB = {
	bg       = Color(10, 10, 19, 235),
	panel    = Color(20, 20, 30, 120),
	header   = Color(15, 15, 20, 165),
	line     = Color(255, 255, 255, 90),
	text     = Color(225, 225, 225),
	textDim  = Color(160, 160, 160),
	white    = Color(255, 255, 255, 240),
	accent   = Color(255, 255, 255, 240),
	grip     = Color(60, 60, 60, 180),
}

local function SB_Unit(n)
	return math.floor(n * math.min(ScrW(), ScrH()) / 1000)
end

local function CreateScoreboardFonts()
	local scale = math.min(ScrW(), ScrH()) / 1000

	surface.CreateFont("ZCity_SB_Header", {
		font = "Verily Serif Mono",
		size = math.max(18, math.floor(30 * scale)),
		weight = 300,
	})
	surface.CreateFont("ZCity_SB_Title", {
		font = "Verily Serif Mono",
		size = math.max(15, math.floor(22 * scale)),
		weight = 300,
	})
	surface.CreateFont("ZCity_SB_Row", {
		font = "Verily Serif Mono",
		size = math.max(13, math.floor(18 * scale)),
		weight = 300,
	})
	surface.CreateFont("ZCity_SB_Tiny", {
		font = "Verily Serif Mono",
		size = math.max(11, math.floor(14 * scale)),
		weight = 300,
	})
end
hook.Add("OnScreenSizeChanged", "ZCity_Scoreboard_Fonts", CreateScoreboardFonts)
CreateScoreboardFonts()

local function SB_StyleScrollBar(scroll)
	local bar = scroll:GetVBar()
	bar:SetWide(SB_Unit(4))
	bar:SetHideButtons(true)
	function bar:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 80)
		surface.DrawRect(0, 0, w, h)
	end
	function bar.btnGrip:Paint(w, h)
		draw.RoundedBox(2, 1, 1, w - 2, h - 2, self:IsHovered() and SB.white or SB.grip)
	end
end

local function SB_MakeButton(parent, label, getActive, onClick)
	local btn = vgui.Create("DButton", parent)
	btn:SetText("")
	btn.HoverLerp = 0
	function btn:Think()
		self.HoverLerp = LerpFT(0.18, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
	end
	function btn:Paint(w, h)
		local on = getActive and getActive() or false
		surface.SetDrawColor(20, 20, 30, 120 + 45 * self.HoverLerp)
		surface.DrawRect(0, 0, w, h)
		if on then
			surface.SetDrawColor(SB.accent.r, SB.accent.g, SB.accent.b, 55)
			surface.DrawRect(0, 0, w, h)
		end
		surface.SetDrawColor(255, 255, 255, 40 + 70 * self.HoverLerp)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		surface.SetDrawColor(on and SB.accent.r or 255, on and SB.accent.g or 255, on and SB.accent.b or 255, on and 220 or 55)
		surface.DrawRect(0, h - SB_Unit(1), w, SB_Unit(1))
		draw.SimpleText(label, "ZCity_SB_Row", w / 2, h / 2, on and SB.white or SB.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	btn.DoClick = onClick
	return btn
end

function GM:ScoreboardShow()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
	Dynamic = 0

	local lp = LocalPlayer()
	local disappearance = lp:GetNetVar("disappearance", nil)
	local roundName = CurrentRound().name
	local serverName = GetHostName() or "ZCity | Developer Server | #01"

	local sizeX = math.floor(ScrW() * 0.72)
	local sizeY = math.floor(ScrH() * 0.82)

	scoreBoardMenu = vgui.Create("ZFrame")
	scoreBoardMenu:SetSize(sizeX, sizeY)
	scoreBoardMenu:SetPos(ScrW() / 2 - sizeX / 2, ScrH() / 2 - sizeY / 2)
	scoreBoardMenu:MakePopup()
	scoreBoardMenu:SetKeyboardInputEnabled(false)
	scoreBoardMenu:ShowCloseButton(false)
	scoreBoardMenu:SetColorBG(Color(SB.bg:Unpack()))
	scoreBoardMenu:SetColorBR(SB.accent)
	scoreBoardMenu:SetBlurStrengh(4)

	local header = vgui.Create("DPanel", scoreBoardMenu)
	header:Dock(TOP)
	header:SetTall(SB_Unit(58))
	header.Paint = function(pnl, w, h)
		surface.SetDrawColor(SB.header)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(SB.accent.r, SB.accent.g, SB.accent.b, 220)
		surface.DrawRect(0, 0, SB_Unit(3), h)
		surface.SetDrawColor(SB.line)
		surface.DrawRect(0, h - SB_Unit(1), w, SB_Unit(1))

		draw.SimpleText(serverName, "ZCity_SB_Header", SB_Unit(16), h * 0.36, SB.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("ZC Version " .. tostring(hg.Version), "ZCity_SB_Tiny", SB_Unit(16), h * 0.74, SB.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local frame = engine.ServerFrameTime()
		local tick = frame > 0 and math.Round(1 / frame) or 0
		draw.SimpleText("SV TICK  " .. tick, "ZCity_SB_Title", w - SB_Unit(16), h / 2, SB.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	local footer = vgui.Create("DPanel", scoreBoardMenu)
	footer:Dock(BOTTOM)
	footer:SetTall(SB_Unit(50))
	footer.Paint = function(pnl, w, h)
		surface.SetDrawColor(SB.header)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(SB.line)
		surface.DrawRect(0, 0, w, SB_Unit(1))
	end

	local teamBtn
	if lp:Team() ~= TEAM_SPECTATOR then
		teamBtn = SB_MakeButton(footer, "SPECTATE", nil, function()
			net.Start("ZB_SpecMode")
				net.WriteBool(true)
			net.SendToServer()
			if IsValid(scoreBoardMenu) then scoreBoardMenu:Remove() scoreBoardMenu = nil end
		end)
	else
		teamBtn = SB_MakeButton(footer, "JOIN GAME", nil, function()
			net.Start("ZB_SpecMode")
				net.WriteBool(false)
			net.SendToServer()
			if IsValid(scoreBoardMenu) then scoreBoardMenu:Remove() scoreBoardMenu = nil end
		end)
	end

	local muteAll = SB_MakeButton(footer, "MUTE ALL", function() return hg.muteall end, function()
		hg.muteall = not hg.muteall
		for _, ply in player.Iterator() do
			if hg.muteall then
				ply:SetVoiceVolumeScale(0)
			else
				ply:SetVoiceVolumeScale((not hg.mutespect or ply:Alive()) and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
			end
		end
	end)

	local muteSpec = SB_MakeButton(footer, "MUTE SPECTATORS", function() return hg.mutespect end, function()
		hg.mutespect = not hg.mutespect
		for _, ply in player.Iterator() do
			if ply:Alive() then continue end
			if hg.mutespect then
				ply:SetVoiceVolumeScale(0)
			else
				ply:SetVoiceVolumeScale(not hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
			end
		end
	end)

	footer.PerformLayout = function(pnl, w, h)
		local bh = SB_Unit(30)
		local pad = SB_Unit(14)
		local gap = SB_Unit(8)
		local y = (h - bh) * 0.5

		teamBtn:SetSize(SB_Unit(120), bh)
		teamBtn:SetPos(pad, y)

		local specW = SB_Unit(160)
		local allW = SB_Unit(110)
		muteSpec:SetSize(specW, bh)
		muteSpec:SetPos(w - pad - specW, y)
		muteAll:SetSize(allW, bh)
		muteAll:SetPos(w - pad - specW - gap - allW, y)
	end

	local body = vgui.Create("DPanel", scoreBoardMenu)
	body:Dock(FILL)
	body:DockMargin(SB_Unit(10), SB_Unit(8), SB_Unit(10), SB_Unit(8))
	body.Paint = function() end

	local function MakeColumn()
		local column = vgui.Create("DPanel", body)
		column.TitleText = ""
		column.Paint = function(pnl, w, h)
			surface.SetDrawColor(SB.panel)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(15, 15, 20, 175)
			surface.DrawRect(0, 0, w, SB_Unit(26))
			surface.SetDrawColor(SB.accent.r, SB.accent.g, SB.accent.b, 175)
			surface.DrawRect(0, SB_Unit(26) - SB_Unit(1), w, SB_Unit(1))

			surface.SetDrawColor(255, 255, 255, 22)
			surface.DrawOutlinedRect(0, 0, w, h, 1)

			draw.SimpleText(pnl.TitleText, "ZCity_SB_Title", SB_Unit(10), SB_Unit(13), SB.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local scroll = vgui.Create("DScrollPanel", column)
		scroll:Dock(FILL)
		scroll:DockMargin(0, SB_Unit(28), 0, SB_Unit(2))
		scroll.Paint = function() end
		SB_StyleScrollBar(scroll)

		column.Scroll = scroll
		return column
	end

	local function AddPlayerRow(scroll, ply, spectator)
		local rowH = SB_Unit(44)
		local avaSize = rowH - SB_Unit(14)

		local row = vgui.Create("DButton", scroll)
		row:Dock(TOP)
		row:DockMargin(SB_Unit(6), SB_Unit(4), SB_Unit(6), SB_Unit(2))
		row:SetTall(rowH)
		row:SetText("")
		row.HoverLerp = 0

		function row:Think()
			self.HoverLerp = LerpFT(0.18, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
		end

		local nameX = SB_Unit(7) + avaSize + SB_Unit(10)

		function row:Paint(w, h)
			if not IsValid(ply) then return end

			surface.SetDrawColor(20, 20, 30, 120 + 55 * self.HoverLerp)
			surface.DrawRect(0, 0, w, h)

			if ply == lp then
				surface.SetDrawColor(SB.accent.r, SB.accent.g, SB.accent.b, 210)
				surface.DrawRect(0, 0, SB_Unit(2), h)
			elseif spectator then
				surface.SetDrawColor(120, 120, 130, 150)
				surface.DrawRect(0, 0, SB_Unit(2), h)
			end

			surface.SetDrawColor(255, 255, 255, 30 + 55 * self.HoverLerp)
			surface.DrawOutlinedRect(0, 0, w, h, 1)

			draw.SimpleText(ply:Name(), "ZCity_SB_Row", nameX, h / 2, spectator and SB.textDim or SB.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(ply:Ping() .. " ms", "ZCity_SB_Tiny", w - SB_Unit(42), h / 2, SB.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		local avatar = vgui.Create("AvatarImage", row)
		avatar:SetSize(avaSize, avaSize)
		avatar:SetPos(SB_Unit(7), math.floor((rowH - avaSize) / 2))
		avatar:SetMouseInputEnabled(false)
		avatar:SetPlayer(ply, 64)
		avatar.PaintOver = function(self, w, h)
			surface.SetDrawColor(255, 255, 255, 45)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		local snd = vgui.Create("DImageButton", row)
		snd:Dock(RIGHT)
		snd:DockMargin(SB_Unit(6), SB_Unit(9), SB_Unit(10), SB_Unit(9))
		snd:SetWide(SB_Unit(16))
		snd:SetImage(not ply:IsMuted() and "icon16/sound.png" or "icon16/sound_mute.png")
		snd.DoClick = function(self)
			OpenPlayerSoundSettings(self, ply)
		end
		ply.soundButton = snd

		function row:DoClick()
			if ply:IsBot() then chat.AddText(Color(255, 0, 0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/" .. ply:SteamID64())
		end

		function row:DoRightClick()
			local menu = DermaMenu()
			menu:AddOption("Account", function()
				zb.Experience.AccountMenu(ply)
			end)
			menu:AddOption("Copy SteamID", function()
				SetClipboardText(ply:SteamID())
			end)
			menu:Open()
		end
	end

	local playersCol = MakeColumn()
	local spectCol = MakeColumn()

	local nPlayers, nSpect = 0, 0
	for _, ply in player.Iterator() do
		if not IsValid(ply) then continue end
		if roundName == "fear" and not ply:Alive() then continue end
		if disappearance and ply ~= lp then continue end

		if ply:Team() == TEAM_SPECTATOR then
			AddPlayerRow(spectCol.Scroll, ply, true)
			nSpect = nSpect + 1
		else
			AddPlayerRow(playersCol.Scroll, ply, false)
			nPlayers = nPlayers + 1
		end
	end

	playersCol.TitleText = "PLAYERS  —  " .. nPlayers
	spectCol.TitleText = "SPECTATORS  —  " .. nSpect

	body.PerformLayout = function(pnl, w, h)
		local gap = SB_Unit(10)
		local cw = math.floor((w - gap) / 2)
		playersCol:SetPos(0, 0)
		playersCol:SetSize(cw, h)
		spectCol:SetPos(cw + gap, 0)
		spectCol:SetSize(w - cw - gap, h)
	end

	return true
end

function GM:ScoreboardHide()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Close()
		scoreBoardMenu = nil
	end
end
local AdminShowVoiceChat = CreateClientConVar("zb_admin_show_voicechat","0",false,false,"Show voicechat panels for admins",0,1)
hook.Add("PlayerStartVoice", "showVoicePanels", function(ply)
	if !IsValid(ply) then return end
	if LocalPlayer():IsAdmin() and AdminShowVoiceChat:GetBool() then return end

	local other_alive = (ply:Alive() and LocalPlayer() != ply) or (ply.organism and (ply.organism.otrub or (ply.organism.brain and ply.organism.brain > 0.05)))

	return other_alive or nil
end)

-- свет от молнии а саму молнию я не сделал skill issue
if CLIENT then
	net.Receive("PunishLightningEffect", function()
		local target = net.ReadEntity()
		if not IsValid(target) then return end
		local dlight = DynamicLight(target:EntIndex())
		if dlight then
			dlight.pos = target:GetPos()
			dlight.r = 126
			dlight.g = 139
			dlight.b = 212
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end)
end

/*  -- а кстати зачем здесь нэт, это же можно было на клиенте полностью сделать...
	if CLIENT then
		net.Receive("PluvCommand", function()
			local specialSteamID = "STEAM_0:1:81850653" 
			local playerSteamID = LocalPlayer():SteamID() 

			local imageURLs = {"https://sadsalat.github.io/salatis/music/boof.gif", "https://i.ibb.co/drt1Lks/KtvCLSs.webp", "https://media.tenor.com/kG4PmVvJuRIAAAAC/rain-world-rain-world-saint.gif"} 
			local soundURLs = {"https://sadsalat.github.io/salatis/music/sus-rock.mp3", "https://sadsalat.github.io/salatis/music/tiktok-raaaah-scream.mp3", "https://sadsalat.github.io/salatis/music/sus-rock.mp3"} 

			local chosenImage = imageURLs[math.random(#imageURLs)]
			local chosenSound = soundURLs[math.random(#soundURLs)]

			sound.PlayURL(chosenSound, "", function(station)
				if IsValid(station) then
					station:Play()
				else
					print("Unable to play the sound.")
				end
			end)

			local html = vgui.Create("HTML")
			html:OpenURL(chosenImage)
			html:SetSize(ScrW(), ScrH())
			html:Center()
			html:MakePopup()

			timer.Simple(3, function()
				if IsValid(html) then
					html:Remove()
				end
			end)
		end)
	end
*/

local lightningMaterial = Material("sprites/lgtning")

net.Receive("AnotherLightningEffect", function()
    local target = net.ReadEntity()
	if not IsValid(target) then return end
    local points = {}
    for i = 1, 27 do
        points[i] = target:GetPos() + Vector(0, 0, i * 50) + Vector(math.Rand(-20,20),math.Rand(-20,20),math.Rand(-20,20))
    end
    hook.Add( "PreDrawTranslucentRenderables", "LightningExample", function(isDrawingDepth, isDrawingSkybox)
        if isDrawingDepth or isDrawingSkybox then return end
        local uv = math.Rand(0, 1)
        render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD )
        render.SetMaterial(lightningMaterial)
        render.StartBeam(27)
        for i = 1, 27 do
            render.AddBeam(points[i], 20, uv * i, Color(255,255,255,255))
        end
        render.EndBeam()
        render.OverrideBlend( false )
    end )
    timer.Simple(0.1, function()
        hook.Remove("PreDrawTranslucentRenderables", "LightningExample")
    end)
end)

function GM:AddHint( name, delay )
	return false
end

local snakeGameOpen = false

concommand.Add("zb_snake", function() -- вот как здесь!
    if snakeGameOpen then
        print("[Snake Game] Игра уже запущена!")
        return
    end

    local frame = vgui.Create("ZFrame")
    frame:SetTitle("Snake Game")
    frame:SetSize(400, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDeleteOnClose(true)  
    snakeGameOpen = true  

    local gridSize = 20
    local gridWidth = 19  
    local gridHeight = 19  
    local snakePanel = vgui.Create("DPanel", frame)
    snakePanel:SetSize(380, 380)
    snakePanel:SetPos(10, 10)

    
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)

    local snake = {
        {x = 10, y = 10},
    }
	
    local snakeDirection = "RIGHT"
    local food = nil
    local score = 0
    local gameRunning = true

  
    local function spawnFood()
        local validPosition = false
        while not validPosition do
            local newFood = {
                x = math.random(0, gridWidth - 1), 
                y = math.random(0, gridHeight - 1)
            }
            validPosition = true

        
            for _, segment in ipairs(snake) do
                if segment.x == newFood.x and segment.y == newFood.y then
                    validPosition = false  
                    break
                end
            end

            
            if validPosition then
                food = newFood
            end
        end
    end

    
    local function drawSnake()
        surface.SetDrawColor(0, 255, 0, 255)
        for _, segment in ipairs(snake) do
            surface.DrawRect(segment.x * gridSize, segment.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

  
    local function drawFood()
        if food then
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawRect(food.x * gridSize, food.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

   
    local function moveSnake()
        if not gameRunning then return end

        local head = table.Copy(snake[1])

        if snakeDirection == "UP" then
            head.y = head.y - 1
        elseif snakeDirection == "DOWN" then
            head.y = head.y + 1
        elseif snakeDirection == "LEFT" then
            head.x = head.x - 1
        elseif snakeDirection == "RIGHT" then
            head.x = head.x + 1
        end

        
        if head.x < 0 or head.x >= gridWidth or head.y < 0 or head.y >= gridHeight then
            gameRunning = false
        end

       
        for _, segment in ipairs(snake) do
            if segment.x == head.x and segment.y == head.y then
                gameRunning = false
            end
        end

       
        table.insert(snake, 1, head)


        if food and head.x == food.x and head.y == food.y then
            score = score + 1
            spawnFood()  
        else
            
            table.remove(snake)
        end
    end


    local function resetGame()
        snake = {{x = 10, y = 10}}
        snakeDirection = "RIGHT"
        score = 0
        gameRunning = true
        spawnFood()  
    end


    function snakePanel:Paint(w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)

        if gameRunning then
            drawSnake()
            drawFood()
        else
            draw.SimpleText("Game Over! Press R to restart", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Score: " .. score, "DermaDefault", 10, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end


    function frame:OnKeyCodePressed(key) -- ФУРИ МУВ теперь понятно почему лагает змейка
        if key == KEY_W and snakeDirection ~= "DOWN" then
            snakeDirection = "UP"
        elseif key == KEY_S and snakeDirection ~= "UP" then
            snakeDirection = "DOWN"
        elseif key == KEY_A and snakeDirection ~= "RIGHT" then
            snakeDirection = "LEFT"
        elseif key == KEY_D and snakeDirection ~= "LEFT" then
            snakeDirection = "RIGHT"
        elseif key == KEY_R then
            resetGame()
        end
    end


    timer.Create("SnakeGameTimer", 0.2, 0, function()
        if gameRunning then
            moveSnake()
        end
        snakePanel:InvalidateLayout(true)
    end)


    frame.OnClose = function()
        timer.Remove("SnakeGameTimer")
        snakeGameOpen = false  
        print("[Snake Game] Игра закрыта.") -- НЕ РАБОТАЕТ
    end


    resetGame()
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
	if ply == LocalPlayer() then
		system.FlashWindow()
	end
end)
