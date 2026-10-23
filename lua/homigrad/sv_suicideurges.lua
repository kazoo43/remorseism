local urge_threshold = 0.35
local urge_roll_time_min = 3
local urge_roll_time_max = 7
local urge_chance_min = 0.35
local urge_chance_max = 0.9
local urge_duration = 4
local urge_presses_needed = 12
local urge_initial_delay = 8
local urge_adrenaline_threshold = 1.5

util.AddNetworkString("rem_urges_press")
util.AddNetworkString("rem_urges_end")

local function findSuicideWeapon(ply)
	local melee

	for _, wep in ipairs(ply:GetWeapons()) do
		if not IsValid(wep) or not wep.CanSuicide then continue end

		if wep.ismelee2 or wep.Base == "weapon_melee" then return wep end
		if ishgweapon(wep) and not melee then melee = wep end
	end

	return melee
end

local function hasSuicideWeapon(ply)
	return IsValid(findSuicideWeapon(ply))
end

local function autoEquipSuicideWeapon(ply)
	local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()
	if IsValid(wep) and wep.CanSuicide then return true end

	local found = findSuicideWeapon(ply)
	if not IsValid(found) then return false end

	ply:SelectWeapon(found:GetClass())
	if ply.SetActiveWeapon then ply:SetActiveWeapon(found) end

	return true
end

local function doUrgeCut(ply)
	if not hasSuicideWeapon(ply) then return end

	local org = ply.organism
	if not org or not org.alive then return end

	local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()
	if IsValid(wep) and wep.SuicideFunc then
		wep:SuicideFunc()
		return
	end

	if IsValid(wep) and ishgweapon(wep) and not (wep.ismelee2 or wep.Base == "weapon_melee") then
		if wep:Clip1() <= 0 then
			if wep.PrimaryShootEmpty then
				wep:PrimaryShootEmpty()
			elseif wep.Primary and wep.Primary.SoundEmpty then
				ply:EmitSound(wep.Primary.SoundEmpty, 75)
			end

			return
		end

		local oldStart = ply.startsuicide
		ply.startsuicide = CurTime() - 2
		ply.suiciding = true
		ply.remUrgeFiring = true
		wep:PrimaryAttack(true)
		ply.remUrgeFiring = nil
		ply.suiciding = false
		ply.startsuicide = oldStart
		return
	end

	local ent = hg.GetCurrentCharacter(ply)
	if not IsValid(ent) then return end

	local neck = ent:LookupBone("ValveBiped.Bip01_Neck1")
	if not neck then return end

	local matrix = ent:GetBoneMatrix(neck)
	if not matrix then return end

	local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(ply)
	if IsValid(wep) then dmgInfo:SetInflictor(wep) end
	dmgInfo:SetDamageType(DMG_SLASH)

	local ang = matrix:GetAngles()
	local _, cutAng = LocalToWorld(vector_origin, Angle(0, -60, 0), vector_origin, ang)

	hg.organism.input_list["arteria"](org, 0, 5, dmgInfo, nil, -cutAng:Forward())

	for i = 1, 5 do
		hg.organism.AddWoundManual(ply, 50, VectorRand(-2, 2), cutAng, "ValveBiped.Bip01_Neck1", CurTime() + math.Rand(0, 2))
	end

	ply:AddNaturalAdrenaline(math.max(2 - (org.adrenaline or 0), 0))
	org.fear = math.max(org.fear, 1)

	hook.Run("HomigradDamage", ply, dmgInfo, HITGROUP_HEAD, ent, 15)

	if IsValid(wep) then
		ply:EmitSound(wep.SuicideSound or wep.Attack2HitFlesh or wep.AttackHitFlesh, 50)
	end
end

local function endUrge(ply, cancel)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local resisted = (ply.remUrgePresses or 0) >= urge_presses_needed
	local manual = ply.remUrgeManual

	ply.remUrgeEnd = nil
	ply.remUrgeManual = nil
	ply.remUrgePresses = 0
	ply:SetNWFloat("rem_urges_end", 0)
	ply.suiciding = false

	if not manual then
		ply.remUrgeCooldown = CurTime() + math.Rand(15, 25)
	end

	net.Start("rem_urges_end")
	net.Send(ply)

	local org = ply.organism
	if org then
		org.depression = math.max((org.depression or 0) - 0.2, 0)

		if not manual then
			org.selfharmNextRoll = math.max(org.selfharmNextRoll or 0, ply.remUrgeCooldown)
		end
	end

	if not cancel and not resisted and ply:Alive() then
		doUrgeCut(ply)
	end
end

local function startUrge(ply, manual)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local org = ply.organism
	if not org or not org.alive or org.heartstop or org.otrub then return end
	if not hasSuicideWeapon(ply) then return end
	if (org.adrenaline or 0) >= urge_adrenaline_threshold then return end
	if ply.remUrgeEnd then return end
	if not manual and (ply.remUrgeCooldown or 0) > CurTime() then return end

	if ply.selfharming then
		hg.organism.EndSelfHarm(ply)
	end

	autoEquipSuicideWeapon(ply)

	ply.suiciding = true
	ply.remUrgeManual = manual or nil
	ply.remUrgePresses = 0
	ply.remUrgeEnd = CurTime() + urge_duration
	ply:SetNWFloat("rem_urges_end", ply.remUrgeEnd)

	timer.Create("rem_urges_end_" .. ply:EntIndex(), urge_duration, 1, function()
		if not IsValid(ply) or not ply.remUrgeEnd then return end

		endUrge(ply)
	end)
end

hg.StartSuicideUrge = startUrge

timer.Create("rem_suicideurges_roll", 1, 0, function()
	local now = CurTime()

	for _, ply in ipairs(player.GetAll()) do
		local org = ply.organism
		if not org or not org.alive or org.heartstop or org.otrub then continue end
		if hg.organism.IsMentalDisabled and hg.organism.IsMentalDisabled() then continue end
		if ply.remUrgeEnd then
			if (org.adrenaline or 0) >= urge_adrenaline_threshold then
				endUrge(ply, true)
			end

			continue
		end
		if (ply.remUrgeCooldown or 0) > now then continue end
		if ply.suiciding or ply.selfharming then continue end
		if (org.adrenaline or 0) >= urge_adrenaline_threshold then continue end

		local dep = org.depression or 0
		if dep <= urge_threshold then continue end
		if not hasSuicideWeapon(ply) then continue end

		ply.remUrgeNextRoll = ply.remUrgeNextRoll or now + math.Rand(urge_initial_delay * 0.5, urge_initial_delay)
		if ply.remUrgeNextRoll > now then continue end

		ply.remUrgeNextRoll = now + math.Rand(urge_roll_time_min, urge_roll_time_max)

		local frac = math.Clamp((dep - urge_threshold) / (1 - urge_threshold), 0, 1)

		if math.Rand(0, 1) <= Lerp(frac, urge_chance_min, urge_chance_max) then
			startUrge(ply)
		end
	end
end)

net.Receive("rem_urges_press", function(_, ply)
	if not IsValid(ply) then return end
	if not ply.remUrgeEnd or ply.remUrgeEnd < CurTime() then return end

	ply.remUrgePresses = (ply.remUrgePresses or 0) + 1
end)

hook.Add("PlayerDeath", "REM_UrgesCleanup", function(ply)
	ply.remUrgeManual = nil

	if not ply.remUrgeEnd then return end

	timer.Remove("rem_urges_end_" .. ply:EntIndex())

	ply.remUrgeEnd = nil
	ply.remUrgePresses = 0
	ply:SetNWFloat("rem_urges_end", 0)
	ply.suiciding = false
end)

hook.Add("PlayerDisconnected", "REM_UrgesCleanup", function(ply)
	if not ply.remUrgeEnd then return end

	timer.Remove("rem_urges_end_" .. ply:EntIndex())

	ply.remUrgeEnd = nil
end)
