local SUMMARY_MAX = 3
local SUMMARY_POST_ROUND = 24
local SUMMARY_CLEAR_DELAY = 6
local SUMMARY_LIFETIME = 16

if SERVER then
	util.AddNetworkString("rem_roundsummary")

	local MELEE = {
		["weapon_hammer"] = true,
		["weapon_brick"] = true,
		["weapon_pocketknife"] = true,
		["weapon_bat"] = true,
		["weapon_leadpipe"] = true,
		["weapon_hg_extinguisher"] = true,
		["weapon_hg_crowbar"] = true,
		["weapon_hatchet"] = true,
		["weapon_hg_axe"] = true,
		["weapon_hg_machete"] = true,
		["weapon_hg_sledgehammer"] = true,
		["hg_brassknuckles"] = true,
		["weapon_hg_spear"] = true,
		["weapon_hg_spear_pro"] = true,
		["weapon_hands_sh"] = true,
	}

	local function IsMeleeKill(ply)
		local wep = IsValid(ply) and ply:GetActiveWeapon()
		if not IsValid(wep) then return false end
		if MELEE[wep:GetClass()] then return true end
		if wep.ismelee2 then return true end
		if wep.Base == "weapon_melee" then return true end
		return false
	end

	local function NewStats()
		return {
			kills = 0,
			headshotKills = 0,
			meleeKills = 0,
			rangedKills = 0,
			traitorKills = 0,
			damageDealt = 0,
			damageTaken = 0,
			headshotHits = 0,
			deaths = 0,
			diedTime = 0,
			survived = true,
		}
	end

	local function ResetStats()
		zb.RSDeathOrder = {}
		zb.RSKilledMain = nil
		for _, ply in player.Iterator() do
			ply.RSStats = NewStats()
			ply.RSLastHit = nil
		end
	end

	hook.Add("ZB_StartRound", "rem_roundsummary_reset", ResetStats)

	hook.Add("HomigradDamage", "rem_roundsummary_dmg", function(victim, dmgInfo, hitgroup, ent, harm)
		if not IsValid(victim) or not victim:IsPlayer() then return end
		local attacker = dmgInfo and dmgInfo:GetAttacker()
		if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

		attacker.RSStats = attacker.RSStats or NewStats()
		victim.RSStats = victim.RSStats or NewStats()

		harm = math.max(harm or 0, 0)
		attacker.RSStats.damageDealt = attacker.RSStats.damageDealt + harm
		victim.RSStats.damageTaken = victim.RSStats.damageTaken + harm

		local head = hitgroup == HITGROUP_HEAD
		if head then attacker.RSStats.headshotHits = attacker.RSStats.headshotHits + 1 end

		victim.RSLastHit = { att = attacker, head = head, melee = IsMeleeKill(attacker), t = CurTime() }
	end)

	hook.Add("Player_Death", "rem_roundsummary_death", function(victim)
		if not IsValid(victim) or not victim:IsPlayer() then return end

		victim.RSStats = victim.RSStats or NewStats()
		victim.RSStats.deaths = victim.RSStats.deaths + 1
		victim.RSStats.diedTime = CurTime()
		victim.RSStats.survived = false

		zb.RSDeathOrder = zb.RSDeathOrder or {}
		if victim:Team() ~= TEAM_SPECTATOR then
			zb.RSDeathOrder[#zb.RSDeathOrder + 1] = victim
		end

		local lh = victim.RSLastHit
		local killer, head, melee

		if lh and IsValid(lh.att) and lh.att:IsPlayer() and (CurTime() - lh.t) < 20 then
			killer, head, melee = lh.att, lh.head, lh.melee
		else
			local most = 0
			for att, dmg in pairs(zb.HarmDone and zb.HarmDone[victim] or {}) do
				if IsValid(att) and att:IsPlayer() and att ~= victim and dmg > most then
					most, killer = dmg, att
				end
			end
		end

		if IsValid(killer) and killer:IsPlayer() and killer ~= victim then
			killer.RSStats = killer.RSStats or NewStats()
			killer.RSStats.kills = killer.RSStats.kills + 1
			if head then
				killer.RSStats.headshotKills = killer.RSStats.headshotKills + 1
			end
			if melee then
				killer.RSStats.meleeKills = killer.RSStats.meleeKills + 1
			else
				killer.RSStats.rangedKills = killer.RSStats.rangedKills + 1
			end
			if victim.isTraitor then
				killer.RSStats.traitorKills = killer.RSStats.traitorKills + 1
			end
			if victim.MainTraitor then
				zb.RSKilledMain = killer
			end
		end
	end)

	local function ActivePlayers()
		local t = {}
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			ply.RSStats = ply.RSStats or NewStats()
			t[#t + 1] = ply
		end
		return t
	end

	local function BestBy(plys, fn)
		local best, bestv
		for _, ply in ipairs(plys) do
			local v = fn(ply)
			if v and (not bestv or v > bestv) then
				bestv, best = v, ply
			end
		end
		return best, bestv
	end

	local AWARDS = {
		{ "mvp", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local sc = s.kills * 100 + s.traitorKills * 120 + s.headshotKills * 30 + math.floor(s.damageDealt)
				return sc > 0 and sc or nil
			end)
		end },
		{ "executioner", function()
			if IsValid(zb.RSKilledMain) and zb.RSKilledMain:IsPlayer() then return zb.RSKilledMain, 1 end
		end },
		{ "headhunter", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.headshotKills return v >= 1 and v or nil end)
		end },
		{ "serialkiller", function(plys)
			return BestBy(plys, function(p)
				if not p.isTraitor then return end
				local v = p.RSStats.kills return v >= 2 and v or nil
			end)
		end },
		{ "hero", function(plys)
			return BestBy(plys, function(p)
				if p.isTraitor then return end
				local v = p.RSStats.traitorKills return v >= 1 and v or nil
			end)
		end },
		{ "melee", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.meleeKills return v >= 1 and v or nil end)
		end },
		{ "berserker", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.kills return v >= 2 and v or nil end)
		end },
		{ "sharpshooter", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.rangedKills return v >= 2 and v or nil end)
		end },
		{ "deadeye", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.kills < 2 or s.headshotKills < 1 then return end
				return math.floor((s.headshotKills / s.kills) * 100)
			end)
		end },
		{ "untouchable", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.kills >= 1 and s.damageTaken <= 0 then return s.kills end
			end)
		end },
		{ "bloodthirsty", function(plys)
			return BestBy(plys, function(p) local v = math.floor(p.RSStats.damageDealt) return v >= 80 and v or nil end)
		end },
		{ "punchingbag", function(plys)
			return BestBy(plys, function(p) local v = math.floor(p.RSStats.damageTaken) return v >= 120 and v or nil end)
		end },
		{ "survivor", function(plys)
			if not zb.RSDeathOrder or #zb.RSDeathOrder < 1 then return end
			return BestBy(plys, function(p)
				if p.RSStats.survived and p.RSStats.kills >= 1 then return p.RSStats.kills end
			end)
		end },
		{ "firstblood", function()
			local v = zb.RSDeathOrder and zb.RSDeathOrder[1]
			if IsValid(v) and v:IsPlayer() then return v, 1 end
		end },
		{ "pacifist", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.survived and s.kills == 0 and s.damageDealt < 1 then return 1 end
			end)
		end },
	}

	local function NameOf(ply)
		if not IsValid(ply) then return "Unknown" end
		local name = ply.Nick and ply:Nick() or ""
		if (name == "" or name == "Unknown") and ply.GetPlayerName then
			name = ply:GetPlayerName() or name
		end
		if name == "" then name = "Unknown" end
		return name
	end

	local ROLE_MAIN    = Color(225, 30, 30)
	local ROLE_TRAITOR = Color(190, 0, 0)
	local ROLE_HERO    = Color(158, 0, 190)
	local ROLE_POLICE  = Color(45, 90, 255)
	local ROLE_INNO    = Color(0, 120, 190)

	local function RoleFor(ply)
		if ply.MainTraitor then return "Main Murderer", ROLE_MAIN end
		if ply.isTraitor then return "Murderer", ROLE_TRAITOR end
		if ply.isGunner then return "Hero", ROLE_HERO end
		if ply.isPolice then return "Police Officer", ROLE_POLICE end
		return "Bystander", ROLE_INNO
	end

	
	
	local function TraitorsWon()
		local tAlive, iAlive = false, false
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			if not ply:Alive() then continue end
			if ply.isTraitor then
				if ply:GetNetVar("handcuffed", false) then continue end
				tAlive = true
			elseif not ply.isPolice then
				if ply.organism and ply.organism.incapacitated then continue end
				iAlive = true
			end
		end
		return tAlive and not iAlive
	end

	local function ComputeFeatured()
		local plys = ActivePlayers()
		local featured, used = {}, {}

		
		local haveMVP = false

		if TraitorsWon() then
			local best = BestBy(plys, function(p)
				if not p.isTraitor then return end
				return p.RSStats.kills * 1000 + math.floor(p.RSStats.damageDealt) + 1
			end)
			if IsValid(best) then
				used[best] = true
				haveMVP = true
				featured[#featured + 1] = { ply = best, key = "mvp", value = best.RSStats.kills or 0 }
			end
		end

		for _, award in ipairs(AWARDS) do
			if #featured >= SUMMARY_MAX then break end
			if award[1] == "mvp" and haveMVP then continue end
			local ply, value = award[2](plys)
			if IsValid(ply) and not used[ply] then
				used[ply] = true
				featured[#featured + 1] = { ply = ply, key = award[1], value = math.floor(value or 0) }
			end
		end

		if #featured == 0 then
			for _, ply in ipairs(plys) do
				if #featured >= SUMMARY_MAX then break end
				featured[#featured + 1] = { ply = ply, key = "participant", value = ply.RSStats.kills or 0 }
			end
		end

		return featured, NameOf, RoleFor
	end

	hook.Add("ZB_EndRound", "rem_roundsummary_send", function()
		if zb.CROUND == "coop" then return end

		local featured, NameOf, RoleFor = ComputeFeatured()
		if #featured == 0 then return end

		local want = CurTime() + math.max(SUMMARY_POST_ROUND, CurrentRound().end_time or 5)
		zb.END_TIME = math.max(zb.END_TIME or 0, want)

		net.Start("rem_roundsummary")
			net.WriteUInt(#featured, 4)
			for _, f in ipairs(featured) do
				local ply = f.ply
				local model = ""
				local steamid = "0"
				local spec = true

				if IsValid(ply) then
					model = ply:GetModel() or ""
					steamid = ply:IsBot() and "0" or (ply:SteamID64() or "0")
					spec = ply:Team() == TEAM_SPECTATOR
				end
			local hasAppearance = IsValid(ply) and istable(ply.CurAppearance) and ply.CurAppearance.AModel ~= nil
			local exp, skill = -1, 0
			if IsValid(ply) then
				local instance = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[ply:SteamID64()]
				exp = math.floor(tonumber((instance and instance.experience) or ply.exp or -1) or -1)
				skill = tonumber((instance and instance.skill) or ply.skill or 0) or 0
			end

				net.WriteEntity(ply)
				net.WriteString(model)
				net.WriteString(NameOf(ply))
				net.WriteString(steamid)
				net.WriteString(f.key)
				net.WriteUInt(math.Clamp(f.value, 0, 65535), 16)
				net.WriteBool(spec)
				net.WriteTable(hasAppearance and table.Copy(ply.CurAppearance) or {})
				net.WriteString(IsValid(ply) and (ply.PlayerClassName or "") or "")
				net.WriteInt(math.Clamp(exp, -1, 2147483647), 32)
				net.WriteFloat(skill)
				net.WriteBool(hasAppearance)
			end

		net.Broadcast()
	end)

	return
end

hg = hg or {}
hg.RoundSummaryEnabled = true

surface.CreateFont("Rem_Sum_AwardBig", { font = "ITC Avant Garde Gothic", size = ScreenScale(23), weight = 800, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Award", { font = "ITC Avant Garde Gothic", size = ScreenScale(18), weight = 800, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_NameBig", { font = "Lora", size = ScreenScale(17), weight = 700, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Name", { font = "Lora", size = ScreenScale(14), weight = 700, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_DescBig", { font = "Lora", size = ScreenScale(15), weight = 500, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Desc", { font = "Lora", size = ScreenScale(12.5), weight = 500, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_XPBig", { font = "Lora", size = ScreenScale(13), weight = 600, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_XP", { font = "Lora", size = ScreenScale(11), weight = 600, antialias = true, extended = true })

local AWARD_INFO = {
	mvp          = { title = "MVP OF THE ROUND", color = Color(232, 190, 70),  desc = function(v) return "Best player around" end },
	executioner  = { title = "THE EXECUTIONER",  color = Color(150, 20, 20),   desc = function(v) return "Killed the main traitor" end },
	headhunter   = { title = "HEAD HUNTER",      color = Color(200, 55, 55),   desc = function(v) return v .. " headshot kill" .. (v == 1 and "" or "s") end },
	serialkiller = { title = "SERIAL KILLER",    color = Color(170, 25, 25),   desc = function(v) return v .. " victims" end },
	hero         = { title = "THE HERO",         color = Color(70, 130, 220),  desc = function(v) return "Slayed a traitor" end },
	melee        = { title = "BRAWLER", color = Color(210, 120, 40), desc = function(v) return v .. " melee kill" .. (v == 1 and "" or "s") end },
	berserker    = { title = "BERSERKER",        color = Color(190, 45, 45),   desc = function(v) return v .. " kills" end },
	sharpshooter = { title = "SHARPSHOOTER",     color = Color(60, 170, 170),  desc = function(v) return v .. " gun kills" end },
	deadeye      = { title = "DEADEYE",          color = Color(232, 190, 70),  desc = function(v) return v .. "% headshots" end },
	untouchable  = { title = "UNTOUCHABLE",      color = Color(90, 200, 220),  desc = function(v) return "Not a scratch" end },
	bloodthirsty = { title = "BLOODTHIRSTY",     color = Color(150, 20, 20),   desc = function(v) return v .. " damage dealt" end },
	punchingbag  = { title = "DEMOLISHED",     color = Color(130, 130, 130), desc = function(v) return v .. " damage taken" end },
	survivor     = { title = "SOLE SURVIVOR",    color = Color(80, 190, 90),   desc = function(v) return "Made it out alive" end },
	firstblood   = { title = "FIRST TO FALL",    color = Color(120, 120, 120), desc = function(v) return "Died first" end },
	pacifist     = { title = "THE PACIFIST",     color = Color(220, 220, 220), desc = function(v) return "Harmed no one" end },
	participant  = { title = "SURVIVOR",         color = Color(140, 140, 140), desc = function(v) return "Stood their ground" end },
}

local RS_GradD = Material("vgui/gradient-d")
local RS_GradU = Material("vgui/gradient-u")
local RS_GradR = surface.GetTextureID("vgui/gradient-r")
local RS_GradL = surface.GetTextureID("vgui/gradient-l")
local RS_GradDTex = surface.GetTextureID("vgui/gradient-d")
local RS_BGColor = Color(10, 10, 19, 235)
local RS_BGRight = Color(18, 18, 18, 65)
local RS_BGTop = Color(100, 100, 100, 35)
local RS_FallbackBand = { icon = Material("vgui/mats_jack_awards/10") }
local RS_FallbackMedal = { icon = Material("vgui/mats_jack_awards/pt") }


local POSES = {
	{ seqs = { "idle_all_angry", "idle_all_02", "idle_all_01" },       ang = Angle(0, 0, 0),   cam = Vector(68, 0, 37),  fov = 36, target = Vector(0, 0, 38), hy = 0,    hp = 0 },
	{ seqs = { "idle_suitcase", "idle_all_01", "idle_all_02" },        ang = Angle(0, -16, 0), cam = Vector(70, 7, 35),  fov = 33, target = Vector(0, 0, 37), hy = -0.45, hp = 0 },
	{ seqs = { "idle_all_scared", "idle_all_angry", "idle_all_01" },   ang = Angle(0, 24, 0),  cam = Vector(63, -12, 34), fov = 40, target = Vector(0, 0, 35), hy = 0.25, hp = 0.15 },
	{ seqs = { "idle_all_angry", "idle_all_01", "idle_all_02" },       ang = Angle(0, -9, 0),  cam = Vector(68, 11, 36), fov = 35, target = Vector(0, 0, 38), hy = -0.3, hp = -0.05 },
}

local RS_Container
local RS_Sound

local function StopSummarySound()
	if IsValid(RS_Sound) then RS_Sound:Stop() end
	RS_Sound = nil
end

local function ApplyAppearance(ent, ply)
	if not IsValid(ent) or not IsValid(ply) then return end
	ent:SetSkin(ply:GetSkin())
	if not ply.PlayerClassName or ply.PlayerClassName == "" then
		ent:SetSubMaterial()
		local mats = ply:GetMaterials()
		for i = 1, #mats do
			local sm = ply:GetSubMaterial(i - 1)
			if sm and sm ~= "" then ent:SetSubMaterial(i - 1, sm) end
		end
	end
	for _, bg in ipairs(ent:GetBodyGroups()) do
		ent:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
	end
	local pc = ply.GetPlayerColor and ply:GetPlayerColor() or ply:GetNWVector("PlayerColor", Vector(1, 1, 1))
	ent:SetNWVector("PlayerColor", pc)
	ent.RSapplied = true
end

local function GetAppearanceModelData(appearance)
	if not istable(appearance) or not hg or not hg.Appearance or not hg.Appearance.PlayerModels then return end
	return hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel]
end

local function GetFallbackAppearance()
	if hg and hg.Appearance and istable(hg.Appearance.FallbackAppearanceTable) then
		return table.Copy(hg.Appearance.FallbackAppearanceTable)
	end
	return { AModel = "Male 09", AClothes = { main = "normal", pants = "normal", boots = "normal", hands = "normal" }, AColor = Color(0, 0, 0), AAttachments = {}, ABodygroups = {}, AFacemap = "Default" }
end

local function FindMaterialSlot(mats, mat)
	if not mat then return end
	local want = string.lower(mat)
	for i = 1, #mats do
		if string.lower(mats[i] or "") == want then return i - 1 end
	end
end

local function GetClothesMaterial(modelData, clothes, key)
	local sexID = modelData.sex and 2 or 1
	local clothesSet = hg.Appearance.Clothes and hg.Appearance.Clothes[sexID]
	if not clothesSet then return end
	return clothesSet[clothes[key] or "normal"] or clothesSet.normal
end

local function ApplyAppearanceClothes(ent, modelData, appearance, mats)
	local clothes = istable(appearance.AClothes) and appearance.AClothes or {}
	for key, mat in SortedPairs(modelData.submatSlots or {}) do
		local slot = FindMaterialSlot(mats, mat)
		local clothMat = slot and GetClothesMaterial(modelData, clothes, key)
		if clothMat then ent:SetSubMaterial(slot, clothMat) end
	end
end

local function ApplyAppearanceFacemap(ent, modelData, appearance, mats)
	if not hg.Appearance.FacemapsSlots then return end
	local facemapSlot = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelData.mdl]
	if not facemapSlot then return end
	for i = 1, #mats do
		local facemapSet = hg.Appearance.FacemapsSlots[mats[i]]
		local facemap = facemapSet and facemapSet[appearance.AFacemap]
		if facemap then ent:SetSubMaterial(i - 1, facemap) end
	end
end

local function ApplyAppearanceBodygroups(ent, modelData, appearance)
	if not hg.Appearance.Bodygroups then return end
	local bodygroups = istable(appearance.ABodygroups) and appearance.ABodygroups or {}
	for _, bg in ipairs(ent:GetBodyGroups()) do
		local selected = bodygroups[bg.name]
		if not selected then continue end
		local bodygroupData = hg.Appearance.Bodygroups[bg.name]
		local bodygroupSet = bodygroupData and bodygroupData[modelData.sex and 2 or 1] and bodygroupData[modelData.sex and 2 or 1][selected]
		if not bodygroupSet then continue end
		for i = 0, #bg.submodels do
			if bodygroupSet[1] == bg.submodels[i] then
				ent:SetBodygroup(bg.id, i)
				break
			end
		end
	end
end

local function ApplyAppearanceData(ent, ply, appearance, playerClassName)
	if not IsValid(ent) then return false end
	local modelData = GetAppearanceModelData(appearance)
	if not modelData and (not playerClassName or playerClassName == "") then return false end

	local clr = appearance.AColor or color_white
	ent:SetNWVector("PlayerColor", Vector((clr.r or 255) / 255, (clr.g or 255) / 255, (clr.b or 255) / 255))

	if playerClassName and playerClassName ~= "" and not modelData then
		if IsValid(ply) then
			ent:SetSkin(ply:GetSkin())
			ent:SetSubMaterial()
			local mats = ply:GetMaterials()
			for i = 1, #mats do
				local sm = ply:GetSubMaterial(i - 1)
				if sm and sm ~= "" then
					ent:SetSubMaterial(i - 1, sm)
				end
			end
			for _, bg in ipairs(ent:GetBodyGroups()) do
				ent:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
			end
			local pc = ply.GetPlayerColor and ply:GetPlayerColor() or ply:GetNWVector("PlayerColor", Vector(1, 1, 1))
			ent:SetNWVector("PlayerColor", pc)
		end
		return true
	end

	if ent:GetModel() ~= modelData.mdl then
		ent:SetModel(modelData.mdl)
	end
	ent:SetSubMaterial()

	local mats = ent:GetMaterials()
	ApplyAppearanceClothes(ent, modelData, appearance, mats)
	ApplyAppearanceFacemap(ent, modelData, appearance, mats)
	ApplyAppearanceBodygroups(ent, modelData, appearance)

	return true
end

local function SetupModel(mp, ply, model, pose, spec, appearance, playerClassName)
	local mdl
	if spec then
		mdl = "models/player/group01/male_09.mdl"
	else
		local modelData = GetAppearanceModelData(appearance)
		if not modelData then
			appearance = GetFallbackAppearance()
			modelData = GetAppearanceModelData(appearance)
			mp.RSFallback = true
			playerClassName = ""
		end
		mdl = modelData and modelData.mdl
		if not mdl or not util.IsValidModel(mdl) then return end
	end
	local look = (pose.target - pose.cam):Angle()
	mp:SetModel(mdl)
	mp:SetFOV(pose.fov)
	mp:SetCamPos(pose.cam)
	mp:SetLookAng(look)
	mp:SetAmbientLight(Color(90, 90, 100))
	mp:SetDirectionalLight(BOX_FRONT, Color(200, 200, 205))
	mp:SetDirectionalLight(BOX_TOP, Color(160, 160, 170))
	mp:SetDirectionalLight(BOX_RIGHT, Color(120, 120, 130))
	mp:SetDirectionalLight(BOX_LEFT, Color(110, 110, 125))
	mp:SetDirectionalLight(BOX_BACK, Color(80, 80, 100))

	function mp:LayoutEntity(ent)
		if not spec and not self.RSApplied then
			if ApplyAppearanceData(ent, ply, appearance, playerClassName) then
				self.RSApplied = true
			elseif IsValid(ply) and not ent.RSapplied then
				ApplyAppearance(ent, ply)
				self.RSApplied = true
			end
		end
		if self.RSFallback then
			ent:SetMaterial("models/debug/debugwhite")
			ent:SetColor(color_black)
		end
		ent:SetAngles(pose.ang)
		if not self.RSIdleSeq then
			local seq = -1
			for _, name in ipairs(pose.seqs) do
				local s = ent:LookupSequence(name)
				if s and s >= 0 then seq = s break end
			end
			if seq < 0 then seq = ent:LookupSequence("idle_all_01") or 0 end
			self.RSIdleSeq = seq
			self.RSWalkSeq = ent:LookupSequence("walk_all")
			if not self.RSWalkSeq or self.RSWalkSeq < 0 then
				self.RSWalkSeq = ent:LookupSequence("walk_all_moderate")
			end
			if not self.RSWalkSeq or self.RSWalkSeq < 0 then
				self.RSWalkSeq = self.RSIdleSeq
			end
		end
		local parent = self:GetParent()
		local targetSeq = IsValid(parent) and parent.RSSettled and self.RSIdleSeq or self.RSWalkSeq
		if self.RSActiveSeq ~= targetSeq then
			ent:ResetSequence(targetSeq)
			self.RSActiveSeq = targetSeq
		end
		ent:FrameAdvance(RealFrameTime())
		ent:SetPoseParameter("head_yaw", pose.hy)
		ent:SetPoseParameter("head_pitch", pose.hp)
		self:SetFOV(pose.fov)
		self:SetCamPos(pose.cam)
		self:SetLookAng(look)
	end

	if spec then
		
		function mp:PreDrawModel()
			render.SuppressEngineLighting(true)
			render.SetColorModulation(0, 0, 0)
		end
		function mp:PostDrawModel()
			render.SetColorModulation(1, 1, 1)
			render.SuppressEngineLighting(false)
		end
		return
	end

	function mp:PreDrawModel()
		if self.RSFallback then
			render.SuppressEngineLighting(true)
			render.SetColorModulation(0, 0, 0)
		end
	end

	function mp:PostDrawModel(ent)
		if self.RSFallback then
			render.SetColorModulation(1, 1, 1)
			render.SuppressEngineLighting(false)
			return
		end
		local acc = IsValid(ply) and ply.GetNetVar and ply:GetNetVar("Accessories") or (istable(appearance) and appearance.AAttachments)
		if istable(acc) and hg and hg.Accessories and DrawAccesories then
			for _, a in ipairs(acc) do
				local d = hg.Accessories[a]
				if d then DrawAccesories(ply, ent, a, d, false, true) end
			end
		end
		ent:SetupBones()
	end
end

local function GetProfileState(ply, expOverride, skillOverride)
	local exp = math.floor(tonumber((expOverride and expOverride >= 0 and expOverride) or (IsValid(ply) and ply.exp) or 0) or 0)
	local skill = tonumber(skillOverride or (IsValid(ply) and ply.skill) or 0) or 0
	local band, medal = RS_FallbackBand, RS_FallbackMedal
	if zb and zb.Experience and zb.Experience.GetAwards then
		local b, m = zb.Experience.GetAwards({ exp = exp, skill = skill })
		band = b or band
		medal = m or medal
	end
	return exp .. " XP", band, medal
end

local function BuildCard(parent, data, slot)
	local sw, sh = ScrW(), ScrH()
	local big = slot == 1
	local pose = POSES[slot] or POSES[1]

	local refW, refH = math.min(sw, 1920), math.min(sh, 1080)
	local scale = math.min(refW / 1920, refH / 1080)
	local w = big and math.floor(refW * 0.29) or math.floor(refW * 0.235)
	local h = big and math.floor(refH * 0.9) or math.floor(refH * 0.82)
	w = math.min(w, math.floor((refW - math.max(math.floor(refW * 0.03), 16) * 2) * (big and 0.38 or 0.31)))
	h = math.min(h, math.floor(sh - math.max(36, 58 * scale)))
	local infoH = big and math.floor(h * 0.34) or math.floor(h * 0.33)

	local info = AWARD_INFO[data.key] or AWARD_INFO.participant
	local accent = info.color

	local card = vgui.Create("DPanel", parent)
	card:SetSize(w, h)
	card:SetAlpha(0)
	card:SetPaintBackground(false)
	card.RSInfo = 0
	card.RSReveal = false
	card.RSSettled = false
	card.Think = function(self)
		local target = self.RSReveal and 1 or 0
		self.RSInfo = Lerp(FrameTime() * 6, self.RSInfo, target)
	end

	card.Paint = function(self, cw, ch)
		surface.SetDrawColor(0, 0, 0, big and 26 or 18)
		surface.DrawRect(0, 0, cw, ch)
		surface.SetDrawColor(255, 255, 255, 110)
		surface.DrawOutlinedRect(0, 0, cw, ch, 1)

		local rise = math.floor(infoH * self.RSInfo)
		if rise > 0 then
			local texH = math.min(ch, math.floor(rise * 2.15))
			local y = ch - texH
			surface.SetDrawColor(4, 4, 6, big and 78 or 64)
			surface.DrawRect(0, ch - rise, cw, rise)
			surface.SetMaterial(RS_GradD)
			surface.SetDrawColor(accent.r, accent.g, accent.b, big and 88 or 74)
			surface.DrawTexturedRect(0, y, cw, texH)
		end
	end

	local mp = vgui.Create("DModelPanel", card)
	mp:SetSize(w, h)
	mp:SetPos(0, 0)
	mp:SetMouseInputEnabled(false)
	SetupModel(mp, data.ply, data.model, pose, data.spec, data.appearance, data.playerclass)

	local titleFont = big and "Rem_Sum_AwardBig" or "Rem_Sum_Award"
	local descFont = big and "Rem_Sum_DescBig" or "Rem_Sum_Desc"
	local nameFont = big and "Rem_Sum_NameBig" or "Rem_Sum_Name"
	local xpFont = big and "Rem_Sum_XPBig" or "Rem_Sum_XP"

	local titleWrap = vgui.Create("DPanel", card)
	titleWrap:SetPos(0, math.floor(h * 0.04))
	titleWrap:SetSize(w, math.floor(h * 0.12))
	titleWrap:SetAlpha(0)
	titleWrap.Paint = function(self, tw, th)
		local a = self:GetAlpha()
		draw.SimpleTextOutlined(info.title, titleFont, tw / 2, 0, Color(accent.r, accent.g, accent.b, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, math.min(230, a)))
		draw.SimpleTextOutlined(string.upper(info.desc(data.value)), descFont, tw / 2, math.floor(th * 0.52), Color(240, 240, 240, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, math.min(210, a)))
	end

	local infoWrap = vgui.Create("DPanel", card)
	infoWrap:SetPos(0, h - infoH)
	infoWrap:SetSize(w, infoH)
	infoWrap:SetAlpha(0)
	infoWrap.Paint = function() end

	local avS = big and math.floor(w * 0.19) or math.floor(w * 0.205)
	local av = vgui.Create("AvatarImage", infoWrap)
	av:SetSize(avS, avS)
	av:SetPos(math.floor(w / 2 - avS / 2), math.floor(infoH * 0.1))
	av:SetMouseInputEnabled(false)
	av:SetSteamID(data.steamid, 64)
	av.PaintOver = function(self, aw, ah)
		surface.SetDrawColor(accent.r, accent.g, accent.b, 255)
		surface.DrawOutlinedRect(0, 0, aw, ah, 2)
	end

	local name = vgui.Create("DLabel", infoWrap)
	name:SetFont(nameFont)
	name:SetTextColor(Color(245, 245, 245))
	name:SetContentAlignment(5)
	name:SetExpensiveShadow(1, Color(0, 0, 0, 230))
	name:SetText(data.name)
	name:SizeToContents()

	local medal = vgui.Create("DPanel", infoWrap)
	medal:SetSize(big and math.floor(w * 0.105) or math.floor(w * 0.12), big and math.floor(w * 0.105) or math.floor(w * 0.12))
	medal.Band = RS_FallbackBand
	medal.Medal = RS_FallbackMedal
	medal.Paint = function(this, mw, mh)
		if this.Band and this.Band.icon then
			surface.SetMaterial(this.Band.icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, mw, mh)
		end
		if this.Medal and this.Medal.icon then
			surface.SetMaterial(this.Medal.icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, mw, mh)
		end
	end

	local xp = vgui.Create("DLabel", infoWrap)
	xp:SetFont(xpFont)
	xp:SetTextColor(Color(220, 220, 220))
	xp:SetContentAlignment(4)
	xp:SetExpensiveShadow(1, Color(0, 0, 0, 225))

	local lastXP, lastSkill = "", nil
	infoWrap.Think = function(self)
		local xpText, band, med = GetProfileState(data.ply, data.exp, data.skill)
		local skill = tonumber(data.skill or (IsValid(data.ply) and data.ply.skill or 0)) or 0
		if xp:GetText() ~= xpText then
			xp:SetText(xpText)
			xp:SizeToContents()
		end
		if lastXP ~= xpText or lastSkill ~= skill then
			medal.Band = band or RS_FallbackBand
			medal.Medal = med or RS_FallbackMedal
			lastXP = xpText
			lastSkill = skill
		end
		name:SetWide(w - 20)
		name:SetPos(10, av:GetY() + av:GetTall() + math.floor(infoH * 0.06))
		name:SetWrap(false)
		name:SetAutoStretchVertical(false)
		name:SetContentAlignment(5)
		local _, nameH = name:GetContentSize()
		name:SetTall(nameH)
		local medalY = infoH - medal:GetTall() - math.floor(infoH * 0.16)
		local totalW = medal:GetWide() + math.floor(w * 0.025) + xp:GetWide()
		local startX = math.floor(w / 2 - totalW / 2)
		medal:SetPos(startX, medalY)
		xp:SetPos(startX + medal:GetWide() + math.floor(w * 0.025), medalY + math.floor((medal:GetTall() - xp:GetTall()) / 2))
	end

	card.RSTitle = titleWrap
	card.RSInfoWrap = infoWrap

	return card, w, h
end

local function CloseSummary()
	StopSummarySound()
	gui.EnableScreenClicker(false)
	if IsValid(RS_Container) then
		local cont = RS_Container
		for _, card in ipairs(cont.Cards or {}) do
			if IsValid(card) then
				card:MoveTo(card.OffX, card.OffY, 0.6, 0, 0.4)
				card:AlphaTo(0, 0.5, 0)
			end
		end
		cont:AlphaTo(0, 0.65, 0, function()
			if IsValid(cont) then cont:Remove() end
		end)
	end
	RS_Container = nil
end

local function ShowSummary(featured)
	if IsValid(RS_Container) then RS_Container:Remove() end

	local sw, sh = ScrW(), ScrH()

	local container = vgui.Create("DPanel")
	container:SetSize(sw, sh)
	container:SetPos(0, 0)
	container:SetPaintBackground(false)
	container:SetMouseInputEnabled(false)
	container:SetKeyboardInputEnabled(false)
	container.Cards = {}
	container.OnRemove = function() gui.EnableScreenClicker(false) end
	RS_Container = container
	container:MakePopup()

	local bg = vgui.Create("DPanel", container)
	bg:SetSize(sw, sh)
	bg:SetPos(0, 0)
	bg:SetMouseInputEnabled(false)
	bg.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, RS_BGColor)
		if hg and hg.DrawBlur then
			hg.DrawBlur(self, 5)
		end
		surface.SetDrawColor(RS_BGRight.r, RS_BGRight.g, RS_BGRight.b, RS_BGRight.a)
		surface.SetTexture(RS_GradR)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(RS_BGColor.r, RS_BGColor.g, RS_BGColor.b, RS_BGColor.a)
		surface.SetTexture(RS_GradL)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(RS_BGTop.r, RS_BGTop.g, RS_BGTop.b, RS_BGTop.a)
		surface.SetTexture(RS_GradDTex)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	bg:SetAlpha(0)
	bg:AlphaTo(255, 0.7, 0)
	container.BG = bg

	local order = {}
	if featured[1] then order[1] = { data = featured[1], slot = 1 } end
	if featured[2] then order[2] = { data = featured[2], slot = 2 } end
	if featured[3] then order[3] = { data = featured[3], slot = 3 } end

	local cards = {}
	for _, o in ipairs(order) do
		local card, w, h = BuildCard(container, o.data, o.slot)
		cards[o.slot] = { panel = card, w = w, h = h }
	end

	local mid = cards[1]
	local gap = math.floor(sw * 0.015)

	local midX = math.floor(sw / 2 - mid.w / 2)
	local midY = math.floor(sh / 2 - mid.h / 2)

	local layout = {}
	layout[1] = { x = midX, y = midY, ox = midX, oy = sh + math.floor(sh * 0.08), delay = 0 }

	if cards[2] then
		local lx = midX - gap - cards[2].w
		local ly = math.floor(sh / 2 - cards[2].h / 2)
		layout[2] = { x = lx, y = ly, ox = lx, oy = sh + math.floor(sh * 0.1), delay = 0.08 }
	end
	if cards[3] then
		local rx = midX + mid.w + gap
		local ry = math.floor(sh / 2 - cards[3].h / 2)
		layout[3] = { x = rx, y = ry, ox = rx, oy = sh + math.floor(sh * 0.12), delay = 0.16 }
	end

	for slot, c in pairs(cards) do
		local l = layout[slot]
		c.panel.OffX, c.panel.OffY = l.ox, l.oy
		c.panel:SetPos(l.ox, l.oy)
		c.panel:MoveTo(l.x, l.y, 0.95, l.delay, 0.15)
		c.panel:AlphaTo(255, 0.45, l.delay)
		timer.Simple(l.delay + 0.9, function()
			if not IsValid(c.panel) then return end
			c.panel.RSSettled = true
			c.panel.RSReveal = true
			if IsValid(c.panel.RSTitle) then
				c.panel.RSTitle:AlphaTo(255, 0.35, 0)
			end
			if IsValid(c.panel.RSInfoWrap) then
				c.panel.RSInfoWrap:AlphaTo(255, 0.4, 0.12)
			end
		end)
		container.Cards[#container.Cards + 1] = c.panel
	end

	StopSummarySound()
	sound.PlayFile("sound/rem_roundsummary.mp3", "noblock", function(ch)
		if not IsValid(ch) then return end
		if not IsValid(RS_Container) or RS_Container ~= container then ch:Stop() return end
		RS_Sound = ch
		ch:SetVolume(0.75)
		ch:Play()
	end)

	timer.Create("rem_roundsummary_close", SUMMARY_LIFETIME, 1, function()
		if IsValid(RS_Container) and RS_Container == container then
			CloseSummary()
		end
	end)
end

net.Receive("rem_roundsummary", function()
	local count = net.ReadUInt(4)
	local featured = {}
	for i = 1, count do
		local ply = net.ReadEntity()
		local model = net.ReadString()
		local name = net.ReadString()
		local steamid = net.ReadString()
		local key = net.ReadString()
		local value = net.ReadUInt(16)
		local spec = net.ReadBool()
		local appearance = net.ReadTable()
		local playerclass = net.ReadString()
		local exp = net.ReadInt(32)
		local skill = net.ReadFloat()
		local hasAppearance = net.ReadBool()
		featured[i] = { ply = ply, model = model, name = name, steamid = steamid, key = key, value = value, spec = spec, appearance = appearance, playerclass = playerclass, exp = exp, skill = skill, hasAppearance = hasAppearance }
	end

	if count == 0 then return end

	timer.Create("rem_roundsummary_show", SUMMARY_CLEAR_DELAY, 1, function()
		ShowSummary(featured)
	end)
end)
