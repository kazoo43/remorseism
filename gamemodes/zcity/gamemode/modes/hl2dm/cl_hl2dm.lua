MODE.name = "hl2dm"

local MODE = MODE

net.Receive("hl2dm_start",function()
    surface.PlaySound("hl2mode1.wav")
	zb.RemoveFade()
	hg.DynaMusic:Start( "hl_coop" )
end)

local teams = {
	[0] = {
		objective = "Kill all combines and survive.",
		name = "a Rebel",
		name_refugee = "the Refugee",
		color1 = Color(230,100,5),
		color2 = Color(210,80,0),
		color3 = Color(25, 110, 25),
        color4 = Color(5, 90, 5),
		color_subrole = Color(180, 15, 15),
	},
	[1] = {
        objective = "Destroy all rebel forces.",
        name = "a Combine Soldier",
        name_elite = "the Elite Combine Soldier",
        name_shotgunner = "the Combine Shotgunner",
        color1 = Color(0, 200, 220), -- самый
        color2 = Color(0, 180, 200),
        color3 = Color(180, 15, 15),
		color4 = Color(160, 0, 0),
        color5 = Color(190, 185, 185),
		color6 = Color(170, 175, 175),
	},
}

function MODE:RenderScreenspaceEffects()
	hg.RoundStart.Fade()
end

--// Ну вроде сделал его чуточку читаемым 
function MODE:HUDPaint()
	local team_data = teams[lply:Team()] or teams[0]
	hg.RoundStart.DrawTitle({
		header = "ZBattle | Half-Life 2 Deathmatch",
		lines = {
			{ text = "You are " .. team_data.name, color = team_data.color1 },
		},
		objective = team_data.objective ~= "" and team_data.objective or nil,
		color = team_data.color1,
	}, { startTime = zb.ROUND_START, duration = 10 })

	if hg.PluvTown.Active and (CurTime() - zb.ROUND_START) < 10 then
		local pluv_a = math.Clamp((10 - (CurTime() - zb.ROUND_START)) / 10, 0, 1)
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * pluv_a / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * pluv_a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

hook.Add("radialOptions", "CMB_Airstrike", function()
     
	local org = lply.organism
	
    if lply:GetNWString("PlayerRole") == "Elite" and not org.otrub then -- that's a feature apparently
		local tbl = {
			function()
				net.Start("ZB_RequestAirStrike") 
				net.SendToServer()
			end,
			"Request Airstrike"
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

local CreateEndMenu
local winnersounds = {
	[0] = { -- rebel wins
		"vo/episode_1/npc/male01/cit_kill04.wav",
		"vo/episode_1/npc/male01/cit_kill01.wav",
		"vo/episode_1/npc/male01/cit_kill09.wav",
		"vo/episode_1/npc/male01/cit_kill14.wav"
	},
	[1] = { -- combine wins
		"vo/episode_1/npc/male01/cit_buddykilled11.wav",
		"vo/episode_1/npc/male01/cit_buddykilled07.wav",
		"vo/episode_1/npc/male01/cit_buddykilled10.wav",
		"vo/episode_1/npc/male01/cit_buddykilled04.wav"
	},
	[2] = {"npc/combine_soldier/vo/overwatchtargetcontained.wav"}, -- draw
	[3] = {"npc/combine_soldier/vo/overwatchsectoroverrun.wav"} -- everybody died
}

net.Receive("hl2dm_roundend", function()
	local winnerteam = net.ReadInt(3)

	surface.PlaySound("ambient/alarms/warningbell1.wav")

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
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
