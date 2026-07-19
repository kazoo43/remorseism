local MODE = MODE
MODE.name = "hmcd"

--\\Local Functions
local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end
--//

MODE.TypeSounds = {
	["standard"] = {"snd_jack_hmcd_psycho.mp3","snd_jack_hmcd_shining.mp3"},
}
local fade = 0
local HMCD_ScreenDuration = 10
local hmcd_show_associates
local hmcd_clear_associates
net.Receive("HMCD_RoundStart",function()
	for i, ply in player.Iterator() do
		ply.isTraitor = false
		ply.isGunner = false
	end

	--\\
	lply.isTraitor = net.ReadBool()
	lply.isGunner = net.ReadBool()
	MODE.Type = net.ReadString()
	local screen_time_is_default = net.ReadBool()
	lply.SubRole = net.ReadString()
	lply.MainTraitor = net.ReadBool()
	MODE.TraitorWord = net.ReadString()
	MODE.TraitorWordSecond = net.ReadString()
	MODE.TraitorExpectedAmt = net.ReadUInt(MODE.TraitorExpectedAmtBits)
	StartTime = CurTime()
	MODE.TraitorsLocal = {}
	MODE.TraitorAssociates = {}

	if(lply.isTraitor and screen_time_is_default)then
		if(MODE.TraitorExpectedAmt == 1)then
			chat.AddText("You are alone on your mission.")
		else
			if(MODE.TraitorExpectedAmt == 2)then
				chat.AddText("You have 1 accomplice")
			else
				chat.AddText("There are(is) " .. MODE.TraitorExpectedAmt - 1 .. " traitor(s) besides you")
			end

			chat.AddText("Traitor secret words are: \"" .. MODE.TraitorWord .. "\" and \"" .. MODE.TraitorWordSecond .. "\".")
		end

		local associate_count = net.ReadUInt(4)
		for key = 1, associate_count do
			local traitor_info = {
				color = net.ReadColor(false),
				name = net.ReadString(),
				ply = net.ReadEntity(),
				model = net.ReadString(),
				appearance = net.ReadTable(),
				playerclass = net.ReadString()
			}

			MODE.TraitorAssociates[#MODE.TraitorAssociates + 1] = traitor_info

			if(lply.MainTraitor)then
				MODE.TraitorsLocal[#MODE.TraitorsLocal + 1] = {traitor_info.color, traitor_info.name}
			end
		end

		if(lply.MainTraitor)then
			if(MODE.TraitorExpectedAmt > 1)then
				chat.AddText("Traitor names (only you, as a main traitor can see them):")
			end

			for _, traitor_info in ipairs(MODE.TraitorsLocal) do
				chat.AddText(traitor_info[1], "\t" .. traitor_info[2])
			end
		end
	end

	lply.Profession = net.ReadString()
	--//

	if(MODE.RoleChooseRoundTypes[MODE.Type] and !screen_time_is_default)then
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.RoleChooseRoundStartTime
	else
		MODE.DynamicFadeScreenEndTime = CurTime() + HMCD_ScreenDuration
	end

	MODE.RoleEndedChosingState = screen_time_is_default

	if(screen_time_is_default)then
		if MODE.RoundBeginSound then
			MODE.RoundBeginSound:Stop()
			MODE.RoundBeginSound = nil
		end

		MODE.RoundBeginSound = CreateSound(LocalPlayer(), "rem_newroundcommence.mp3")
		MODE.RoundBeginSound:PlayEx(1, 100)
	end

	MODE.RoundTextTilts = {}
	for i = 1, 64 do
		MODE.RoundTextTilts[i] = (math.random() < 0.5) and 3 or -3
	end

	MODE.CursorLerpX = 0
	MODE.CursorLerpY = 0

	fade = 0
	hmcd_show_associates()
end)

MODE.TypeNames = {
	["standard"] = "Homicide",
}

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

surface.CreateFont("ZB_HomicideSmall", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMedium", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMediumLarge", {
	font = font(),
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideLarge", {
	font = font(),
	size = ScreenScale(30),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHeader", {
	font = font(),
	size = ScreenScale(45),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHumongous", {
	font = font(),
	size = 255,
	weight = 400,
	antialias = true
})

MODE.TypeObjectives = {}
MODE.TypeObjectives.standard = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Murderer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are a hero. You've tasked yourself to help police find the criminal faster.",
		name = "a Hero",
		color1 = Color(158,0,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},
}

function MODE:RenderScreenspaceEffects()
	-- MODE.DynamicFadeScreenEndTime = MODE.DynamicFadeScreenEndTime or 0
	fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if(time_diff > 0)then
		zb.RemoveFade()

		local fade = math.min(time_diff / 2.5, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end

local handicap = {
	[1] = "You are handicapped: your right leg is broken.",
	[2] = "You are handicapped: you are suffering from severe obesity.",
	[3] = "You are handicapped: you are suffering from hemophilia.",
	[4] = "You are handicapped: you are physically incapacitated."
}

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

local HMCD_AssociatePanels = {}
local HMCD_AssociatePoses = {
	"pose_standing_01",
	"pose_standing_02",
	"pose_standing_03",
	"idle_all_01",
	"idle_all_angry"
}

hmcd_clear_associates = function()
	for _, pnl in ipairs(HMCD_AssociatePanels) do
		if IsValid(pnl) then pnl:Remove() end
	end

	HMCD_AssociatePanels = {}
end

local function hmcd_appearance_model_data(appearance)
	if not istable(appearance) or not hg or not hg.Appearance or not hg.Appearance.PlayerModels then return end
	return hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel]
end

local function hmcd_material_slot(mats, mat)
	if not mat then return end
	local want = string.lower(mat)
	for i = 1, #mats do
		if string.lower(mats[i] or "") == want then return i - 1 end
	end
end

local function hmcd_appearance_color(clr)
	if not clr then return Vector(1, 1, 1), Color(245, 245, 245) end
	local r = clr.r or clr.x or clr[1] or 255
	local g = clr.g or clr.y or clr[2] or 255
	local b = clr.b or clr.z or clr[3] or 255
	if r <= 1 and g <= 1 and b <= 1 then return Vector(r, g, b), Color(r * 255, g * 255, b * 255) end
	return Vector(r / 255, g / 255, b / 255), Color(r, g, b)
end

local function hmcd_apply_associate_appearance(ent, data)
	local appearance = data.appearance
	if istable(appearance) and appearance.AColor then
		local vec = hmcd_appearance_color(appearance.AColor)
		ent.GetPlayerColor = function()
			return vec
		end
	end

	local model_data = hmcd_appearance_model_data(appearance)
	if not model_data then
		if IsValid(data.ply) then
			ent:SetSkin(data.ply:GetSkin())
			for _, bg in ipairs(ent:GetBodyGroups()) do
				ent:SetBodygroup(bg.id, data.ply:GetBodygroup(bg.id))
			end
		end
		return
	end

	ent:SetSubMaterial()
	local mats = ent:GetMaterials()
	local clothes = istable(appearance.AClothes) and appearance.AClothes or {}
	local sex = model_data.sex and 2 or 1

	for key, mat in SortedPairs(model_data.submatSlots or {}) do
		local slot = hmcd_material_slot(mats, mat)
		local set = hg.Appearance.Clothes and hg.Appearance.Clothes[sex]
		local cloth = set and (set[clothes[key] or "normal"] or set.normal)
		if slot and cloth then ent:SetSubMaterial(slot, cloth) end
	end

	if hg.Appearance.FacemapsSlots then
		local facemap_slot = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[model_data.mdl]
		if facemap_slot then
			for i = 1, #mats do
				local set = hg.Appearance.FacemapsSlots[mats[i]]
				local facemap = set and set[appearance.AFacemap]
				if facemap then ent:SetSubMaterial(i - 1, facemap) end
			end
		end
	end

	local bodygroups = istable(appearance.ABodygroups) and appearance.ABodygroups or {}
	for _, bg in ipairs(ent:GetBodyGroups()) do
		local selected = bodygroups[bg.name]
		local bgdata = selected and hg.Appearance.Bodygroups and hg.Appearance.Bodygroups[bg.name]
		local bgset = bgdata and bgdata[sex] and bgdata[sex][selected]
		if not bgset then continue end
		for i = 0, #bg.submodels do
			if bgset[1] == bg.submodels[i] then
				ent:SetBodygroup(bg.id, i)
				break
			end
		end
	end
end

hmcd_show_associates = function()
	hmcd_clear_associates()
	if not lply.isTraitor then return end

	local associates = MODE.TraitorAssociates or {}
	if #associates <= 0 then return end

	local sw, sh = ScrW(), ScrH()
	local w, h = math.floor(sw * 0.2), math.floor(sh * 0.55)
	local y = math.floor(sh * 0.26)
	local slots = {
		{x = math.floor(sw * 0.055), off = -w - ScreenScale(30)},
		{x = math.floor(sw - sw * 0.055 - w), off = sw + ScreenScale(30)},
	}

	for i = 1, math.min(#associates, 2) do
		local data = associates[i]
		local slot = slots[i]
		local model_data = hmcd_appearance_model_data(data.appearance)
		local model = model_data and model_data.mdl or data.model
		if not model or model == "" or not util.IsValidModel(model) then continue end

		local panel = vgui.Create("DPanel")
		panel:SetSize(w, h)
		panel:SetPos(slot.off, y)
		panel:SetAlpha(255)
		panel:SetPaintBackground(false)
		panel:SetMouseInputEnabled(false)
		panel:SetKeyboardInputEnabled(false)
		panel.HMCDOffX = slot.off
		panel.HMCDY = y
		panel.Paint = function(self, pw, ph)
			local a = self:GetAlpha()
			local _, name_col = hmcd_appearance_color(istable(data.appearance) and data.appearance.AColor)
			draw.SimpleTextOutlined("Assistant", "ZB_HomicideMedium", pw / 2, 0, Color(190, 0, 0, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, a))
			draw.SimpleTextOutlined(data.name, "ZB_HomicideMedium", pw / 2, ScreenScale(14), Color(name_col.r, name_col.g, name_col.b, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, a))
		end
		panel.Think = function(self)
			if self.HMCDLeaving then return end
			local fade_end_time = MODE.DynamicFadeScreenEndTime or 0
			if fade_end_time - CurTime() <= 2.5 then
				self.HMCDLeaving = true
				self:MoveTo(self.HMCDOffX, self.HMCDY, 0.75, 0, 0.15)
				self:AlphaTo(0, 0.35, 0)
			end
		end

		local mp = vgui.Create("DModelPanel", panel)
		mp:SetPos(0, ScreenScale(28))
		mp:SetSize(w, h - ScreenScale(28))
		mp:SetModel(model)
		mp:SetFOV(32)
		mp:SetCamPos(Vector(68, 0, 36))
		mp:SetLookAng((Vector(0, 0, 37) - Vector(68, 0, 36)):Angle())
		mp:SetMouseInputEnabled(false)
		mp:SetAmbientLight(Color(90, 90, 100))
		mp:SetDirectionalLight(BOX_FRONT, Color(210, 210, 215))
		function mp:LayoutEntity(ent)
			if not self.HMCDApplied then
				hmcd_apply_associate_appearance(ent, data)
				self.HMCDApplied = true
			end

			ent:SetAngles(Angle(0, i == 1 and -10 or 10, 0))
			if not self.HMCDSeq then
				for add = 0, #HMCD_AssociatePoses - 1 do
					local seq = ent:LookupSequence(HMCD_AssociatePoses[((i + add - 1) % #HMCD_AssociatePoses) + 1])
					if seq and seq >= 0 then
						self.HMCDSeq = seq
						break
					end
				end

				self.HMCDSeq = self.HMCDSeq or 0
				ent:ResetSequence(self.HMCDSeq)
			end
			ent:FrameAdvance(RealFrameTime())
		end

		panel:MoveTo(slot.x, y, 0.75, 0.45 + i * 0.15, 0.15)
		HMCD_AssociatePanels[#HMCD_AssociatePanels + 1] = panel
	end
end

function MODE:HUDPaint()
	if not MODE.Type or not MODE.TypeObjectives[MODE.Type] then return end
	if lply:Team() == TEAM_SPECTATOR then return end

	local t = CurTime() - StartTime
	if t > HMCD_ScreenDuration then
		if MODE.RoundBeginSound then
			MODE.RoundBeginSound:Stop()
			MODE.RoundBeginSound = nil
		end

		hmcd_clear_associates()

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

	local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	local color_role_innocent = MODE.TypeObjectives[MODE.Type].innocent.color1

	local Rolename = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.name ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.name ) or MODE.TypeObjectives[MODE.Type].innocent.name

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

	add("Homicide", "ZB_HomicideHeader", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9)
	add("You are " .. Rolename, "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, sh * 0.5, "right", 0.7, 1.1)

	local cur_y = sh * 0.5
	local stack_delay = 1.1

	if(lply.SubRole and lply.SubRole != "")then
		cur_y = cur_y + ScreenScale(20)
		add(((MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)
		add("Assistant", "ZB_HomicideMedium", ColorRole, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	if(lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		if(lply.MainTraitor)then
			MODE.TraitorsLocal = MODE.TraitorsLocal or {}

			if(#MODE.TraitorsLocal > 1)then
				add("Traitors list:", "ZB_HomicideMedium", ColorRole, sw * 0.5, cur_y, "right", stack_delay, 1.05)
				stack_delay = stack_delay + 0.15

				for _, traitor_info in ipairs(MODE.TraitorsLocal) do
					cur_y = cur_y + ScreenScale(15)
					add(traitor_info[2], "ZB_HomicideMedium", Color(traitor_info[1].r, traitor_info[1].g, traitor_info[1].b), sw * 0.5, cur_y, "right", stack_delay, 1.05)
					stack_delay = stack_delay + 0.15
				end
			end
		else
			add("Traitor secret words:", "ZB_HomicideMedium", ColorRole, sw * 0.5, cur_y, "right", stack_delay, 1.05)
			stack_delay = stack_delay + 0.15

			cur_y = cur_y + ScreenScale(15)
			add("\"" .. MODE.TraitorWord .. "\"", "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, cur_y, "right", stack_delay, 1.05)
			stack_delay = stack_delay + 0.15

			cur_y = cur_y + ScreenScale(15)
			add("\"" .. MODE.TraitorWordSecond .. "\"", "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, cur_y, "right", stack_delay, 1.05)
			stack_delay = stack_delay + 0.15
		end
	end

	if(lply.Profession and lply.Profession != "")then
		cur_y = cur_y + ScreenScale(20)
		add("Occupation: " .. ((MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession), "ZB_HomicideMedium", color_role_innocent, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	if(handicap[lply:GetLocalVar("karma_sickness", 0)])then
		cur_y = cur_y + ScreenScale(20)
		add(handicap[lply:GetLocalVar("karma_sickness", 0)], "ZB_HomicideMedium", color_role_innocent, sw * 0.5, cur_y, "right", stack_delay, 1.05)
		stack_delay = stack_delay + 0.15
	end

	local Objective = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.objective ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.objective ) or MODE.TypeObjectives[MODE.Type].innocent.objective

	if(lply.SubRole and lply.SubRole != "")then
		if(MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Objective)then
			Objective = MODE.SubRoles[lply.SubRole].Objective
		end
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		Objective = "You are equipped with nothing. Help other traitors win."
	end

	--; WARNING Traitor's objective is not lined up with SubRole's
	if(!MODE.RoleEndedChosingState)then
		Objective = "Round is starting..."
	end

	add(Objective, "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true)

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

	if hg.PluvTown.Active then
		local pluv_appear = hmcd_ease_out(math.Clamp(t / 1.0, 0, 1))
		local pluv_a = pluv_appear * out_fade

		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * pluv_a / 2)
		surface.DrawTexturedRect(sw * 0.25 + cox, sh * 0.44 - ScreenScale(15) + coy, sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2 + cox, sh * 0.44 - ScreenScale(2) + coy, Color(0, 0, 0, 255 * pluv_a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu

net.Receive("hmcd_roundend", function()
	hmcd_clear_associates()

	local traitors, gunners = {}, {}

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local traitor = net.ReadEntity()
		traitors[key] = traitor
		traitor.isTraitor = true
	end

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local gunner = net.ReadEntity()
		gunners[key] = gunner
		gunner.isGunner = true
	end

	timer.Simple(2.5, function()


		lply.isPolice = false
		lply.isTraitor = false
		lply.isGunner = false
		lply.MainTraitor = false
		lply.SubRole = nil
		lply.Profession = nil
	end)

	traitor = traitors[1] or Entity(0)

	CreateEndMenu(traitor)
end)

net.Receive("hmcd_announce_traitor_lose", function()
	local traitor = net.ReadEntity()
	local traitor_alive = net.ReadBool()

	if(IsValid(traitor))then
		chat.AddText(color_white, (traitor_alive and "" or "Traitor "), traitor:GetPlayerColor():ToColor(), traitor:GetPlayerName() .. ", " .. traitor:Nick(), color_white, " was " .. (traitor_alive and "a Traitor." or "killed."))
	end
end)

local colGray = Color(85,85,85)
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

CreateEndMenu = function(traitor)
	if hg and hg.RoundSummaryEnabled then return end
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

	if !IsValid(hmcdEndMenu) then return end

	local players = {}

	local traitorName = IsValid(traitor) and traitor:GetPlayerName() or "unknown"
	local traitorNick = IsValid(traitor) and traitor:Nick() or "unknown"

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if !IsValid(ply) then return end
		
		players[#players + 1] = {
			nick = ply:Nick(),
			name = ply:GetPlayerName(),
			isTraitor = ply.isTraitor,
			isGunner = ply.isGunner,
			incapacitated = ply.organism and ply.organism.otrub,
			alive = ply:Alive(),
			col = ply:GetPlayerColor():ToColor(),
			frags = ply:Frags(),
			steamid = ply:IsBot() and "BOT" or ply:SteamID64(),
		}
	end

	surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5, ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX, posY)
	hmcdEndMenu:SetSize(sizeX, sizeY)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton", hmcdEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")

	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos(lengthX - lengthX / 1.1, 4)
		surface.DrawText("Close")
	end

	hmcdEndMenu.PaintOver = function(self,w,h)
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(traitorName .. " was a traitor ("..traitorNick..")")
		surface.SetTextPos(w / 2 - lengthX / 2, 20)
		surface.DrawText(traitorName .. " was a traitor ("..traitorNick..")")
	end

	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i, info in ipairs(players) do
		local but = vgui.Create("DButton",DScrollPanel)

		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")

		but.Paint = function(self,w,h)
			local col1 = (info.isTraitor and colRed) or (info.alive and colBlue) or colGray
			local col2 = info.isTraitor and (info.alive and colRedUp or colSpect1) or ((info.alive and !info.incapacitated) and colBlueUp) or colSpect1
			local name = info.nick
			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h / 2, w, h / 2)

			local col = info.col
			surface.SetFont("ZB_InterfaceMediumLarge")
			local lengthX, lengthY = surface.GetTextSize(name)

			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(w / 2 + 1, h / 2 - lengthY / 2 + 1)
			surface.DrawText(name)

			surface.SetTextColor(col.r, col.g, col.b, col.a)
			surface.SetTextPos(w / 2, h / 2 - lengthY / 2)
			surface.DrawText(name)


			local col = colSpect2
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize(info.name)
			surface.SetTextPos(15, h / 2 - lengthY / 2)
			surface.DrawText(info.name .. ((!info.alive and " - died") or (info.incapacitated and " - incapacitated") or ""))

			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(info.frags)
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(info.frags)
		end

		function but:DoClick()
			if info.steamid == "BOT" then chat.AddText(Color(255, 0, 0), "That's a bot.") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..info.steamid)
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	-- if IsValid(hmcdEndMenu) then
	-- 	hmcdEndMenu:Remove()
	-- 	hmcdEndMenu = nil
	-- end
end

--\\
net.Receive("HMCD(StartPlayersRoleSelection)", function()
	local role = net.ReadString()

	hg.SelectPlayerRole(role)
end)

function hg.SelectPlayerRole(role, mode)
	role = role or "Traitor"
	mode = mode or "standard"

	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end

	if(MODE.RoleChooseRoundTypes[mode])then
		//VGUI_HMCD_RolePanelList = vgui.Create("ZB_TraitorSelectionMenu")
		//VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList = vgui.Create("HMCD_RolePanelList")
		VGUI_HMCD_RolePanelList.RolesIDsList = MODE.RoleChooseRoundTypes[mode][role]	--; WARNING TCP Reroute
		VGUI_HMCD_RolePanelList.Mode = mode
		-- VGUI_HMCD_RolePanelList:SetSize(ScreenScale(600), ScreenScale(300))
		VGUI_HMCD_RolePanelList:SetSize(screen_scale_2(700), screen_scale_2(300))
		VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList:InvalidateParent(false)
		VGUI_HMCD_RolePanelList:Construct()
		VGUI_HMCD_RolePanelList:MakePopup()
	end
end

net.Receive("HMCD(EndPlayersRoleSelection)", function()
	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end
end)

net.Receive("HMCD(SetSubRole)", function(len, ply)
	lply.SubRole = net.ReadString()
end)
--//

--CreateEndMenu()
