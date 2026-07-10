hg = hg or {}
hg.zchatConVars = hg.zchatConVars or {}

local function RegisterZChatConVar(name, default, description, min, max, valueType, decimals)
	hg.zchatConVars[name] = {
		name = name,
		default = tostring(default),
		description = description or "",
		min = min,
		max = max,
		type = valueType or "string",
		decimals = decimals or 0
	}
end

RegisterZChatConVar("zchat_maxmessagelength", 256, "Maximum message length allowed", 32, 512, "number", 0)
local maxLength = CreateConVar("zchat_maxmessagelength", "256", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Maximum message length allowed")

if CLIENT then
	RegisterZChatConVar("zchat_fontsize", 9, "Font scale", 3, 60, "number", 0)
	RegisterZChatConVar("zchat_font", "Lora", "Font name", nil, nil, "string", 0)
	RegisterZChatConVar("zchat_fontaa", 1, "Font anti-aliasing", 0, 1, "bool", 0)
	RegisterZChatConVar("zchat_fontweight", 1000, "Font weight", 0, 1000, "number", 0)

	local fontSize = CreateClientConVar("zchat_fontsize", 9, true, false, "Self explanatory", 3, 60)
	local fontName = CreateClientConVar("zchat_font", "Lora", true, false, "Self explanatory, should be available to GMod")
	local fontAA = CreateClientConVar("zchat_fontaa", 1, true, false, "Font anti-aliasing", 0, 1)
	local fontWeight = CreateClientConVar("zchat_fontweight", 1000, true, false, "Font weight", 0, 1000)

	if fontName:GetString() == "Courier Prime" then
		RunConsoleCommand("zchat_font", "Lora")
	end

	local function CreateChat()
		if (IsValid(hg.chat)) then
			hg.chat:Remove()
		end

		hg.chat = vgui.Create("zChatbox")
	end

	local function RefreshChatFonts()
		if IsValid(hg.chat) and hg.chat.RefreshFonts then
			hg.chat:RefreshFonts()
		end
	end

	hook.Add("InitPostEntity", "ZChat", function()
		CreateChat()
	end)

	hook.Add("PlayerStartVoice","RemoveVoicePanles",function(ply)
		if !IsValid(ply) then return end

		local other_alive = (ply:Alive() and LocalPlayer() != ply) or (ply.organism and (ply.organism.otrub or (ply.organism.brain and ply.organism.brain > 0.05)))

		return other_alive or nil
	end)

	-- CreateChat()

	hook.Add("PlayerBindPress", "ZChat", function(client, bind, pressed)
		bind = bind:lower()

		if (bind:find("messagemode") and pressed) then
			hg.chat:SetActive(true)

			return true
		end
	end)

	hook.Add("OnShowZCityPause", "ZChat", function()
		if !hg.chat:GetActive() then return end
		hg.chat:SetActive(false)

		return false
	end)

	hook.Add("HUDShouldDraw", "ZChat", function(name)
		if (name == "CHudChat") then
			return false
		end
	end)

	net.Receive("zChatMessage", function(len)
		local speaker = net.ReadEntity()
		local text = net.ReadString()
		local bWhisper = net.ReadBool()

		speaker.ChatWhisper = bWhisper

		CHAT_SPEAKER = speaker

		local supressed = hook.Run("OnPlayerChat", speaker, text, false, speaker:Alive(), bWhisper)
		if !supressed then
			chat.AddText(speaker, ": ", text)
		end

		CHAT_SPEAKER = nil
	end)

	net.Receive("zChatGlobalMessage", function(len)
		local buffer = net.ReadTable()

		chat.AddText(unpack(buffer))
	end)

	hook.Add("ChatText", "ZChat", function(index, name, text, messageType)
		if (IsValid(hg.chat)) then
			hg.chat:AddMessage(text)
		end
	end)

	function chat.AddText(...)
		if (IsValid(hg.chat)) then
			hg.chat:AddMessage(...)
		end

		-- log chat message to console
		local text = {}

		for _, v in ipairs({...}) do
			if (istable(v) or isstring(v)) then
				text[#text + 1] = v
			elseif (isentity(v) and v:IsPlayer()) then
				text[#text + 1] = team.GetColor(v:Team())
				text[#text + 1] = v:Name()
			elseif (type(v) != "IMaterial") then
				text[#text + 1] = tostring(v)
			end
		end

		text[#text + 1] = "\n"
		MsgC(unpack(text))
	end

	local function LoadFonts()
		local size = fontSize:GetFloat()
		local font = fontName:GetString()
		local fontAntiAliasing = fontAA:GetBool()
		local fontW = fontWeight:GetFloat()

		surface.CreateFont("zChatFont", {
			font = font,
			size = ScreenScale(size),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})

		surface.CreateFont("zChatFontSmall", {
			font = font,
			size = ScreenScale(4),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})

		surface.CreateFont("zChatFontHat", {
			font = font,
			size = ScreenScale(5),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})

		surface.CreateFont("ZB_ProotOSChat", {
			font = "Ari-W9500",
			size = ScreenScale(size),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})

		surface.CreateFont("BerserkChatFont", {
			font = "Who asks Satan",
			size = ScreenScale(size + 3),
			extended = true,
			weight = 0,
			antialias = fontAntiAliasing
		})
	end

	cvars.AddChangeCallback("zchat_fontsize", function()
		LoadFonts()
		RefreshChatFonts()
	end)

	cvars.AddChangeCallback("zchat_font", function()
		LoadFonts()
		RefreshChatFonts()
	end)

	cvars.AddChangeCallback("zchat_fontaa", function()
		LoadFonts()
		RefreshChatFonts()
	end)

	cvars.AddChangeCallback("zchat_fontweight", function()
		LoadFonts()
		RefreshChatFonts()
	end)

	concommand.Add("zchat_reload", function()
		LoadFonts()
		RefreshChatFonts()
	end)

	LoadFonts()

	hook.Add("ModifyMessageBuffer", "ChatFont", function(buffer, speaker)
		if !IsValid(speaker) or !speaker:IsPlayer() then return end

		if speaker.PlayerClassName == "furry" then
			buffer[#buffer + 1] = "<font=ZB_ProotOSChat>"
		elseif speaker:IsBerserk() then
			buffer[#buffer + 1] = "<font=BerserkChatFont>"
		end
	end)

	hook.Add("StartChat", "TypingBool", function()
		net.Start("zChatTyping")
			net.WriteBool(true)
		net.SendToServer()
	end)

	hook.Add("FinishChat", "TypingBool", function()
		net.Start("zChatTyping")
			net.WriteBool(false)
		net.SendToServer()
	end)

	local META = FindMetaTable("Player")

	function META:IsTyping()
		return self:GetNetVar("bIsTyping")
	end

	local ghost = Color(118, 159, 255)
	local dead = Color(255, 0, 0)
	hook.Add("OnPlayerChat", "ZChatDead", function(ply, text, bTeam, bDead, bWhisper)
		if ( ply:IsPlayer() and !ply:Alive() ) then
			chat.AddText( dead, "*DEAD* ", ghost, ply:Nick(), ghost, ": "..text )
			return true
		end
	end)
else
	util.AddNetworkString("zChatMessage")
	util.AddNetworkString("zChatGlobalMessage")
	util.AddNetworkString("zChatTyping")

	local function zChatSpamBlocked(ply, text)
		local now = CurTime()
		ply._zchat_msg_next = ply._zchat_msg_next or 0
		ply._zchat_msg_window = ply._zchat_msg_window or now
		ply._zchat_msg_count = ply._zchat_msg_count or 0
		ply._zchat_msg_dupes = ply._zchat_msg_dupes or 0

		if now < ply._zchat_msg_next then return true end

		if now - ply._zchat_msg_window >= 2 then
			ply._zchat_msg_window = now
			ply._zchat_msg_count = 0
		end

		ply._zchat_msg_count = ply._zchat_msg_count + 1
		ply._zchat_msg_next = now + 0.28

		if ply._zchat_msg_last == text then
			ply._zchat_msg_dupes = ply._zchat_msg_dupes + 1
		else
			ply._zchat_msg_dupes = 0
		end

		ply._zchat_msg_last = text

		return ply._zchat_msg_count > 5 or ply._zchat_msg_dupes > 2
	end

	net.Receive("zChatMessage", function(len, ply)
		local text = net.ReadString()
		text = string.Trim(text or "")
		if text == "" then return end
		if zChatSpamBlocked(ply, text) then return end

		local maxLen = maxLength:GetInt()

		if (text:utf8len() > maxLen) then
			text = text:utf8sub(0, maxLen)
		end

		hook.Run("PlayerSay", ply, text)
	end)

	hook.Add("PlayerSay", "ZChat", function(ply, text)
 		local txtTbl = {text}
		hook.Run("HG_PlayerSay", ply, txtTbl, text) // our shit gets called later
		text = isstring(txtTbl[1]) and txtTbl[1] or text // checks to see if shit hits the ceiling

		if text == "" then return end

		if ply:Alive() and ply.organism and ply.organism.otrub then return end

		ply.ChatWhisper = ply:Alive() and ply.ChatWhisper or false

		local rf = RecipientFilter()
		-- local checkdist = ply.ChatWhisper and 128 * 128 or 1024 * 1024
		for i, plya in player.Iterator() do
			if plya:Alive() and plya.organism and plya.organism.otrub then continue end
			if plya:Alive() and !ply:Alive() then continue end

			if (hook.Run("PlayerCanSeePlayersChat", text, false, plya, ply)) then
				rf:AddPlayer(plya)
			end
		end
		
		net.Start("zChatMessage")
			net.WriteEntity(ply)
			net.WriteString(text)
			net.WriteBool(ply.ChatWhisper)
		net.Send(rf)

		-- log chat message to console
		local textConsole = {}

		textConsole[#textConsole + 1] = ply:GetPlayerColor():ToColor()
		textConsole[#textConsole + 1] = ply:GetNWString("PlayerName", ply:Nick())
		textConsole[#textConsole + 1] = color_white
		textConsole[#textConsole + 1] = ": " .. text

		textConsole[#textConsole + 1] = "\n"

		MsgC(unpack(textConsole))

		hook.Run("PostPlayerSay", client, chatType, text)
		return ""
	end)

	net.Receive("zChatTyping", function(len, ply)
		ply._zchat_typing_next = ply._zchat_typing_next or 0
		if ply._zchat_typing_next > CurTime() then return end
		ply._zchat_typing_next = CurTime() + 0.1

		ply:SetNetVar("bIsTyping", net.ReadBool())
	end)

	local META = FindMetaTable("Player")

	function META:IsTyping()
		return self:GetNetVar("bIsTyping")
	end

	function META:zChatPrint(...)
		net.Start("zChatGlobalMessage")
			net.WriteTable({...})
		net.Send(self)
	end

	function zChatPrint(...)
		net.Start("zChatGlobalMessage")
			net.WriteTable({...})
		net.Broadcast()
	end
end
