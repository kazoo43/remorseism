--local Organism = hg.organism
local function isCrush(dmgInfo)
	return not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_SLASH + DMG_BLAST)
end

local function damageOrgan(org, dmg, dmgInfo, key)
	local prot = math.max(0.3 - org[key],0)
	local oldval = org[key]
	org[key] = math.Round(math.min(org[key] + dmg * (isCrush(dmgInfo) and 1 or 3), 1), 3)
	
	//local damage = org[key] - oldval
	//dmgInfo:SetDamage(dmgInfo:GetDamage() + (damage * 5))

	dmgInfo:ScaleDamage(0.8)

	return 0//isCrush(dmgInfo) and 0 or prot
end

local input_list = hg.organism.input_list
input_list.heart = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.heart

	local result = damageOrgan(org, dmg * 0.3, dmgInfo, "heart")

	hg.AddHarmToAttacker(dmgInfo, (org.heart - oldDmg) * 10, "Heart damage harm")
	
	org.shock = org.shock + dmg * 20
	org.internalBleed = org.internalBleed + (org.heart - oldDmg) * 10

	return result
end

input_list.liver = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.liver
	local prot = math.max(0.3 - org.liver,0)
	
	hg.AddHarmToAttacker(dmgInfo, (org.liver - oldDmg) * 3, "Liver damage harm")
	
	org.shock = org.shock + dmg * 20
	org.painadd = org.painadd + dmg * 35
	
	org.liver = math.min(org.liver + dmg, 1)
	local harmed = (org.liver - oldDmg)
	if org.analgesia < 0.4 and harmed >= 0.2 then
		timer.Simple(0, function()
			if harmed > 0 then -- wtf? whatever
				hg.StunPlayer(org.owner,2)
			else
				hg.LightStunPlayer(org.owner,2)
			end
		end)
	end

	org.internalBleed = org.internalBleed + harmed * 4
	
	dmgInfo:ScaleDamage(0.8)

	return 0
end

input_list.stomach = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.stomach

	local result = damageOrgan(org, dmg, dmgInfo, "stomach")

	hg.AddHarmToAttacker(dmgInfo, (org.stomach - oldDmg) * 2, "Stomach damage harm")
	
	org.internalBleed = org.internalBleed + (org.stomach - oldDmg) * 2
	return result
end

input_list.intestines = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.intestines

	local result = damageOrgan(org, dmg, dmgInfo, "intestines")

	hg.AddHarmToAttacker(dmgInfo, (org.intestines - oldDmg) * 2, "Intestines damage harm")

	org.internalBleed = org.internalBleed + (org.intestines - oldDmg) * 2
	return result
end

local brainLobeProfiles = {
	brainFrontal = {brain = 0.8, consciousness = 1.2, disorientation = 1.5, shock = 2, pain = 7, hemorrhage = 0.6},
	brainParietal = {brain = 0.7, consciousness = 1.4, disorientation = 2.2, shock = 2.5, pain = 8, hemorrhage = 0.7},
	brainTemporal = {brain = 0.9, consciousness = 1.1, disorientation = 1.3, shock = 2.5, pain = 8, hemorrhage = 0.9},
	brainOccipital = {brain = 0.75, consciousness = 1.3, disorientation = 1.1, shock = 2, pain = 7, hemorrhage = 0.75}
}

local function addBrainHemorrhage(org, amount, rate)
	org.brainHemorrhage = math.min((org.brainHemorrhage or 0) + amount, 1)
	org.brainBleedRate = math.min((org.brainBleedRate or 0) + (rate or amount * 0.0015), 0.008)
end

hg.organism.AddBrainHemorrhage = addBrainHemorrhage

local function damageBrainLobe(org, bone, dmg, dmgInfo, key)
	local profile = brainLobeProfiles[key]
	if not profile then return 0 end
	if dmgInfo:IsDamageType(DMG_BLAST) then dmg = dmg / 50 end

	local oldDmg = org[key] or 0
	local result = damageOrgan(org, dmg, dmgInfo, key)
	local delta = (org[key] or 0) - oldDmg

	org.brain = math.min((org.brain or 0) + delta * profile.brain, 1)
	org.consciousness = math.Approach(org.consciousness, 0, delta * profile.consciousness)
	org.disorientation = org.disorientation + delta * profile.disorientation
	org.shock = org.shock + dmg * profile.shock
	org.painadd = org.painadd + dmg * profile.pain

	hg.AddHarmToAttacker(dmgInfo, delta * 15, key .. " damage harm")

	local penetrating = dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT)
	local impact = dmgInfo:IsDamageType(DMG_CLUB + DMG_BLAST + DMG_CRUSH)
	local hemorrhageChance = penetrating and math.Clamp(0.3 + delta * 1.6, 0, 0.95) or impact and math.Clamp(0.04 + delta * profile.hemorrhage, 0, 0.65) or 0.02
	if delta > 0 and math.Rand(0, 1) <= hemorrhageChance then
		addBrainHemorrhage(org, delta * profile.hemorrhage, delta * (penetrating and 0.003 or 0.0012))
	end

	if key == "brainTemporal" and delta > 0.02 and math.random(2) == 1 and IsValid(org.owner) and org.owner.AddTinnitus then
		org.owner:AddTinnitus(math.Clamp(delta * 35, 1.5, 12), true)
	end

	if dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then
		local dmgPos = dmgInfo:GetDamagePosition()
		local dirCool = dmgInfo:GetDamageForce():GetNormalized()
		local effdata = EffectData()
		effdata:SetOrigin(dmgPos)
		effdata:SetRadius(dmg / 10)
		effdata:SetMagnitude(dmg / 10)
		effdata:SetScale(1)
		util.Effect("BloodImpact", effdata)

		local ent = hg.GetCurrentCharacter(org.owner)
		if IsValid(ent) and ent.organism and not ent.organism.SpawnedBrainChunks and math.random(5) == 1 then
			SpawnMeatGore(ent, dmgPos + dirCool * 5, 3, dirCool * 1000, 0.4)
			ent.organism.SpawnedBrainChunks = true
		end
	end

	if org.brain >= 0.01 and delta > 0.01 and math.random(3) == 1 then
		org.shock = 70
		timer.Simple(0.1, function()
			local rag = hg.GetCurrentCharacter(org.owner)
			if IsValid(rag) and rag:IsRagdoll() then
				hg.applyFencingToPlayer(org.owner, org)
			end
		end)
	end

	org.consciousness = math.Approach(org.consciousness, 0, dmg * 3)

	org.disorientation = org.disorientation + dmg * 1
	org.shock = org.shock + dmg * 3
	org.painadd = org.painadd + dmg * 10

	if org.isPly then
		local targetPlayer = org.owner
		if IsValid(org.owner.FakeRagdoll) then
			local ragdoll = org.owner.FakeRagdoll
			if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
		end
		if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
			targetPlayer:PlayCustomTinnitus("headhit.mp3")

			if dmg > 0.5 then
				local idx = math.random(1, 4)
				local snd = "concussion" .. idx .. ".mp3"
				net.Start("hg_play_client_sound_file")
					net.WriteString(snd)
				net.Send(targetPlayer)
			end
		end
	end

	local concIntensity = math.Clamp(dmg * 0.8, 0.1, 3.0)
	local concDuration = math.Clamp(dmg * 5, 5, 60)
	hg.organism.module.concussion.AddConcussion(org, concIntensity, concDuration)

	if org.isPly and dmg > 0.3 then
		local targetPlayer = org.owner
		if IsValid(org.owner.FakeRagdoll) then
			local ragdoll = org.owner.FakeRagdoll
			if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
		end
		if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
			local impactSeverity = math.Clamp(dmg * 2, 0.5, 6)
			net.Start("headtrauma_concussion_update")
				net.WriteFloat(impactSeverity)
				net.WriteFloat(org.concussion or 0)
			net.Send(targetPlayer)
		end
	end

	return result
end

input_list.brainFrontal = function(org, bone, dmg, dmgInfo) return damageBrainLobe(org, bone, dmg, dmgInfo, "brainFrontal") end
input_list.brainParietal = function(org, bone, dmg, dmgInfo) return damageBrainLobe(org, bone, dmg, dmgInfo, "brainParietal") end
input_list.brainTemporal = function(org, bone, dmg, dmgInfo) return damageBrainLobe(org, bone, dmg, dmgInfo, "brainTemporal") end
input_list.brainOccipital = function(org, bone, dmg, dmgInfo) return damageBrainLobe(org, bone, dmg, dmgInfo, "brainOccipital") end
input_list.brain = input_list.brainFrontal

hook.Add("HomigradDamage", "BrainHemorrhageTrauma", function(ply, dmgInfo, hitgroup)
	local org = ply.organism
	if not org or hitgroup ~= HITGROUP_HEAD or not org.skull then return end
	if org.skull < 0.7 then return end

	local chance = dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) and 0.2 or dmgInfo:IsDamageType(DMG_CLUB + DMG_BLAST + DMG_CRUSH) and 0.08 or 0
	chance = chance + math.max(org.skull - 0.7, 0) * 0.35
	if math.Rand(0, 1) <= chance then
		addBrainHemorrhage(org, math.Rand(0.015, 0.05), math.Rand(0.0002, 0.001))
	end
end)

local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
local function getlocalshit(ent, bone, dmgInfo, dir, hit)
	if IsValid(ent) and bone then
		local ent = IsValid(ent.FakeRagdoll) and ent.FakeRagdoll or ent
		local bonePos, boneAng = ent:GetBonePosition(bone)
		local dmgPos = not isbool(hit) and hit or bonePos
		
		local localPos, localAng = WorldToLocal(dmgPos, angZero, bonePos, boneAng)
		local _, dir2 = WorldToLocal(vecZero, dir:Angle(), vecZero, boneAng)
		dir2 = dir2:Forward()
		return localPos, localAng, dir2
	end
end

local arterySize = {
	["arteria"] = 14,
	["rarmartery"] = 6,
	["larmartery"] = 6,
	["rlegartery"] = 9,
	["llegartery"] = 9,
	["spineartery"] = 10,
}

local arteryMessages ={
	"I can feel blood rushing from my neck...",
	"My neck.. it's... pumping out blood.",
	"I'm bleeding out of my neck!"
}

local slashToArtery = {
	["rarmup"] = "rarmartery",
	["rarmdown"] = "rarmartery",
	["larmup"] = "larmartery",
	["larmdown"] = "larmartery",
	["rlegup"] = "rlegartery",
	["rlegdown"] = "rlegartery",
	["llegup"] = "llegartery",
	["llegdown"] = "llegartery",
}

local function getArteryChanceMul(dmgInfo)
	local inflictor = dmgInfo:GetInflictor()
	return IsValid(inflictor) and inflictor.ArteryChance or 1
end

local function getStaminaMul(dmgInfo)
	local att = dmgInfo:GetAttacker()
	if IsValid(att) and att.organism and att.organism.stamina then
		local stamina = att.organism.stamina
		return math.max(stamina[1] / stamina.max, 0.1)
	end
	return 1
end

local function hitArtery(artery, org, dmg, dmgInfo, boneindex, dir, hit)
	if isCrush(dmgInfo) then return 1 end
	if dmgInfo:IsDamageType(DMG_BLAST) then return 1 end
	if dmgInfo:IsDamageType(DMG_SLASH) and dmg < 2 then
		local staminaMul = getStaminaMul(dmgInfo)
		local arteryChanceMul = getArteryChanceMul(dmgInfo)
		local arteryChance = arteryChanceMul >= 2 and 1 or math.Clamp(0.45 * arteryChanceMul * staminaMul, 0, 1)

		if math.Rand(0, 1) > arteryChance then
			-- Didn't fully cut through, maybe just a scratch
			local scratchChance = 0.2 + 0.3 * staminaMul
			if math.Rand(0, 1) < scratchChance then
				org.painadd = org.painadd + dmg * 0.3
				if artery == "arteria" and org.isPly and IsValid(org.owner) then
					org.owner:Notify("My neck got scratched!", true, "arteria", 0)
				end
			end
			return
		end
	end
	org.painadd = org.painadd + dmg * 1
	if org[artery] == 1 then return 0 end
	if org[string.Replace(artery, "artery", "").."amputated"] then return end

	if artery ~= "arteria" then
		hg.AddHarmToAttacker(dmgInfo, 4, "Random artery punctured harm")//((1 - org[artery]) - math.max((1 - org[artery]) - dmg,0)) / 4
	else
		if org.isPly and not org.otrub then
			org.owner:Notify(table.Random(arteryMessages), true, "arteria", 0)
		end
		
		hg.AddHarmToAttacker(dmgInfo, 15, "Carotid artery punctured harm")
		org.neckslit = true
		org.needfake = true
	end

	org[artery] = math.min(org[artery] + 1, 1)

	local owner = org.owner

	if artery == "arteria" and IsValid(owner) then
		local ent = hg.GetCurrentCharacter(owner)
		if IsValid(ent) and not org.otrub and not org.needotrub and (owner:IsPlayer() and owner:Alive() or not owner:IsPlayer()) then
			ent:EmitSound("neckslit.ogg", 70, 100, 1, CHAN_AUTO)
		end

		local snd = (ThatPlyIsFemale and ThatPlyIsFemale(owner)) and "femaleneck.mp3" or "maleneck.mp3"
		timer.Simple(0, function()
			if IsValid(owner) then
				if owner:IsPlayer() and owner:Alive() then
					hg.Fake(owner, nil, true, true)
				end
				local rag = hg.GetCurrentCharacter(owner)
				if IsValid(rag) and not org.otrub and not org.needotrub and (owner:IsPlayer() and owner:Alive() or not owner:IsPlayer()) then
					rag:EmitSound(snd, 70, 100, 1, CHAN_VOICE)
					org.neckslitSoundName = snd
					org.neckslitSoundEnt = rag
				end
			end
		end)
	end

	local bonea = owner:LookupBone(boneindex)
	local localPos, localAng, dir2 = getlocalshit(owner, bonea, dmgInfo, dir, hit)
	table.insert(org.arterialwounds, {arterySize[artery], localPos, localAng, boneindex, CurTime(), dir2 * 100, artery})
	owner:SetNetVar("arterialwounds", org.arterialwounds)
	--if IsValid(owner:GetNWEntity("RagdollDeath")) then owner:GetNWEntity("RagdollDeath"):SetNetVar("wounds",org.arterialwounds) end
	return 0
end

hook.Add("PreTraceOrganBulletDamage", "hg_melee_artery_chance", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ)
	if not dmgInfo:IsDamageType(DMG_SLASH) then return end

	local artery = organ and slashToArtery[organ[1]]
	if not artery then return end
	if getArteryChanceMul(dmgInfo) <= 1 then return end

	local arteryChance = math.Clamp(getArteryChanceMul(dmgInfo) - 1, 0, 1)
	if math.Rand(0, 1) > arteryChance then return end

	hitArtery(artery, org, dmg, dmgInfo, box[6], dir, hit)
end)

input_list.arteria = function(org, bone, dmg, dmgInfo, boneindex, dir, hit)
	return hitArtery("arteria", org, dmg, dmgInfo, "ValveBiped.Bip01_Neck1", dir, hit)
end

input_list.rarmartery = function(org, bone, dmg, dmgInfo, boneindex, dir, hit) return hitArtery("rarmartery", org, dmg, dmgInfo, boneindex, dir, hit) end
input_list.larmartery = function(org, bone, dmg, dmgInfo, boneindex, dir, hit) return hitArtery("larmartery", org, dmg, dmgInfo, boneindex, dir, hit) end
input_list.rlegartery = function(org, bone, dmg, dmgInfo, boneindex, dir, hit) return hitArtery("rlegartery", org, dmg, dmgInfo, boneindex, dir, hit) end
input_list.llegartery = function(org, bone, dmg, dmgInfo, boneindex, dir, hit) return hitArtery("llegartery", org, dmg, dmgInfo, boneindex, dir, hit) end
input_list.spineartery = function(org, bone, dmg, dmgInfo, boneindex, dir, hit) return 0 end--hitArtery("spineartery", org, dmg, dmgInfo, boneindex, dir, hit) end
input_list.eyeL = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.eyeL or 0
	dmg = dmg * 3
	org.eyeL = math.min((org.eyeL or 0) + dmg, 1)

	hg.AddHarmToAttacker(dmgInfo, dmg * 5, "Left eye damage harm")
	org.painadd = org.painadd + dmg * 20
	org.shock = org.shock + dmg * 10

	dmgInfo:ScaleDamage(0.8)
	return 0
end

input_list.eyeR = function(org, bone, dmg, dmgInfo)
	local oldDmg = org.eyeR or 0
	dmg = dmg * 3
	org.eyeR = math.min((org.eyeR or 0) + dmg, 1)

	hg.AddHarmToAttacker(dmgInfo, dmg * 5, "Right eye damage harm")
	org.painadd = org.painadd + dmg * 20
	org.shock = org.shock + dmg * 10

	dmgInfo:ScaleDamage(0.8)
	return 0
end

input_list.lungsL = function(org, bone, dmg, dmgInfo)
	local prot = math.max(0.3 - org.lungsL[1],0)
	local oldval = org.lungsL[1]

	hg.AddHarmToAttacker(dmgInfo, (dmg * 0.25), "Lung left damage harm")

	org.lungsL[1] = math.min(org.lungsL[1] + dmg / 4, 1)
	if (dmgInfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BUCKSHOT)) or (math.random(3) == 1) then org.lungsL[2] = math.min(org.lungsL[2] + dmg * 1, 1) end

	org.internalBleed = org.internalBleed + (org.lungsL[1] - oldval) * 2
	
	dmgInfo:ScaleDamage(0.8)

	return 0//isCrush(dmgInfo) and 1 or prot
end

input_list.lungsR = function(org, bone, dmg, dmgInfo)
	local oldval = org.lungsR[1]

	hg.AddHarmToAttacker(dmgInfo, (dmg * 0.25), "Lung right damage harm")

	org.lungsR[1] = math.min(org.lungsR[1] + dmg / 4, 1)
	if (dmgInfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BUCKSHOT)) or (math.random(3) == 1) then org.lungsR[2] = math.min(org.lungsR[2] + dmg * 1, 1) end

	org.internalBleed = org.internalBleed + (org.lungsR[1] - oldval) * 2

	dmgInfo:ScaleDamage(0.8)

	return 0//isCrush(dmgInfo) and 1 or prot
end

input_list.trachea = function(org, bone, dmg, dmgInfo)
	do return 0 end
	local oldDmg = org.trachea

	if dmgInfo:IsDamageType(DMG_BLAST) then dmg = dmg / 5 end

	local result = damageOrgan(org, dmg * 2, dmgInfo, "trachea")

	hg.AddHarmToAttacker(dmgInfo, (org.trachea - oldDmg) * 8, "Trachea damage harm")

	//org.internalBleed = org.internalBleed + dmg * 2

	return result
end
