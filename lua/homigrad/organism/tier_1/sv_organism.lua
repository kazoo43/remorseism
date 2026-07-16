hg.organism.module = hg.organism.module or {}
local module = hg.organism.module
hg.organism.lastindex = hg.organism.lastindex or 1000000
local panicattack_threshold = 0.45
local panicattack_add_decay_time = 90
local panicattack_rise_time = 10
local panicattack_decay_time = 200
local panicattack_gain_chance = 3
local panicattack_gain_mul = 0.4
local panicattack_disorientation = 0.45
local panicattack_adrenaline_add_target = 4
local panicattack_adrenaline_add_rise_time = 14
local panicattack_heart_roll_delay = 15
local panicattack_heart_roll_chance = 1
local panicattack_damage_scale = 0.006
local panicattack_witness_radius = 850
local panicattack_death_radius = 900
local seizure_duration = 90
local seizure_brain_damage_start = 80
local seizure_brain_damage_final = 0.99
local seizure_pose_force = 850
local seizure_pose_damp = 42
local seizure_leg_buckle = 46
local seizure_shake_freq = 5.8
local seizure_shake_amp = 1.35
local seizure_brain_trauma_gain_mul = 2
local seizure_brain_heal_gain_mul = 1.1
local seizure_temperature_gain_mul = 0.013
local seizure_temperature_low_start = 35
local seizure_temperature_high_start = 39
local seizure_brain_roll_delay = 20
local seizure_brain_roll_chance = 15
local seizure_brain_roll_gain_min = 0.04
local seizure_brain_roll_gain_max = 0.11
hook.Add("Org Clear", "Main", function(org)
	org.alive = true
	org.otrub = false
	org.entindex = IsValid(org.owner) and org.owner:EntIndex() or hg.organism.lastindex + 1
	module.pulse[1](org)
	module.blood[1](org)
	module.pain[1](org)
	module.stamina[1](org)
	module.lungs[1](org)
	module.liver[1](org)
	module.metabolism[1](org)
	module.random_events[1](org)
	module.concussion[1](org)
	module.trauma_combo[1](org)
	org.brain = 0
	org.brainFrontal = 0
	org.brainParietal = 0
	org.brainTemporal = 0
	org.brainOccipital = 0
	org.brainHemorrhage = 0
	org.brainBleedRate = 0
	org.eyeL = 0
	org.eyeR = 0
	org.consciousness = 1
	org.disorientation = 0
	org.jaw = 0
	org.spine1 = 0
	org.spine2 = 0
	org.spine3 = 0
	org.chest = 0
	org.pelvis = 0
	org.skull = 0
	org.stomach = 0
	org.intestines = 0
	org.thiamine = 0
	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false
	org.llegamputated = false
	org.rlegamputated = false
	org.rarmamputated = false
	org.larmamputated = false
	org.rhandamputated = false
	org.lhandamputated = false
	org.headamputated = false
	org.furryinfected = false
	org.health = 100
	org.canmove = true
	org.recoilmul = 1
	org.legstrength = 1
	org.meleespeed = 1
	org.temperature = 36.7
	org.superfighter = false
	org.CantCheckPulse = nil
	org.HEV = nil
	org.bleedingmul = 1
	org.neckslitSoundName = nil
	org.neckslitSoundEnt = nil
	org.last_heartbeat = CurTime()
	org.bulletwounds = 0
	org.stabwounds = 0
	org.slashwounds = 0
	org.bruises = 0
	org.burns = 0
	org.explosionwounds = 0
	org.fear = 0
	org.fearadd = 0
	org.assimilated = 0
	org.berserk = 0
	org.noradrenaline = 0
	org.panicattackadd = 0
	org.panicattack = 0
	org.panicattackActive = false
	org.nextPanicHeartRoll = 0
	org.seizure = 0
	org.seizureActive = false
	org.seizureStart = 0
	org.seizureEnd = 0
	org.nextSeizureSpasm = 0
	org.nextSeizureRoll = 0
	org.lastSeizureBrain = 0
	org.lastSeizureTemperature = org.temperature
	org.deathStateEnd = nil
	org.deathStateKilled = nil


	org.blindness = nil
	if IsValid(org.owner) then
		if org.owner:IsPlayer() and org.owner:Alive() then
			org.owner:SetHealth(100)
			org.owner:SetNetVar("wounds",{})
			org.owner:SetNetVar("arterialwounds",{})
		end
		org.owner:SetNetVar("zableval_masku", false)
	end
	org.allowholster = false
	org.just_damaged_bone = nil
	org.LodgedEntities = nil
	org.dmgstack = {}
	org.SpawnedBrainChunks = nil
end)
hook.Add("Should Fake Up", "organism", function(ply)
	local org = ply.organism
	if org.seizureActive or org.otrub or org.fake or org.nearpainlimit or org.spine1 >= hg.organism.fake_spine1 or org.spine2 >= hg.organism.fake_spine2 or org.spine3 >= hg.organism.fake_spine3 or (org.lleg == 1 and org.rleg == 1) and org.berserk <= 0.3 or (org.blood < 2900) or org.consciousness <= 0.4 then
		return false
	end
end)
local hg_unreliable_nets = ConVarExists("hg_unreliable_nets") and GetConVar("hg_unreliable_nets") or CreateConVar("hg_unreliable_nets", 0, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "Toggle unreliable net messages for some of the expensive nets", 0, 1)
util.AddNetworkString("organism_send")
util.AddNetworkString("organism_sendply")
util.AddNetworkString("hg_dislocation_minigame_pain")
util.AddNetworkString("hg_dislocation_minigame_success")
util.AddNetworkString("rem_deathstate_sound")
local CurTime = CurTime
local nullTbl = {}
local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle developer mode (enables damage traces)", 0, 1)
local function send_organism(org, ply)
	if not IsValid(org.owner) then return end
	local sendtable = {}
	sendtable.alive = org.alive
	sendtable.otrub = org.otrub
	sendtable.owner = org.owner
	sendtable.stamina = org.stamina
	sendtable.immobilization = org.immobilization
	sendtable.adrenaline = org.adrenaline
	sendtable.adrenalineAdd = org.adrenalineAdd
	sendtable.analgesia = org.analgesia
	sendtable.lleg = org.lleg
	sendtable.rleg = org.rleg
	sendtable.rarm = org.rarm
	sendtable.larm = org.larm
	sendtable.pelvis = org.pelvis
	sendtable.disorientation = org.disorientation
	sendtable.brain = org.brain
	sendtable.brainFrontal = org.brainFrontal
	sendtable.brainParietal = org.brainParietal
	sendtable.brainTemporal = org.brainTemporal
	sendtable.brainOccipital = org.brainOccipital
	sendtable.brainHemorrhage = org.brainHemorrhage
	sendtable.brainBleedRate = org.brainBleedRate
	sendtable.o2 = org.o2
	sendtable.CO = org.CO
	sendtable.blood = org.blood
	sendtable.bloodtype = org.bloodtype
	sendtable.bleed = org.bleed
	sendtable.hurt = org.hurt
	sendtable.pain = org.pain
	sendtable.shock = org.shock
	sendtable.pulse = org.pulse
	sendtable.heartbeat = org.heartbeat
	sendtable.timeValue = org.timeValue
	sendtable.holdingbreath = org.holdingbreath
	sendtable.arteria = org.arteria
	sendtable.recoilmul = org.recoilmul
	sendtable.meleespeed = org.meleespeed
	sendtable.temperature = org.temperature
	sendtable.canmove = org.canmove
	sendtable.fear = org.fear
	sendtable.llegdislocation = org.llegdislocation
	sendtable.rlegdislocation = org.rlegdislocation
	sendtable.rarmdislocation = org.rarmdislocation
	sendtable.larmdislocation = org.larmdislocation
	sendtable.jawdislocation = org.jawdislocation
	sendtable.llegamputated = org.llegamputated
	sendtable.rlegamputated = org.rlegamputated
	sendtable.rarmamputated = org.rarmamputated
	sendtable.larmamputated = org.larmamputated
	sendtable.lhandamputated = org.lhandamputated
	sendtable.rhandamputated = org.rhandamputated
	sendtable.headamputated = org.headamputated
	sendtable.lungsfunction = org.lungsfunction
	sendtable.eyeL = org.eyeL
	sendtable.eyeR = org.eyeR
	sendtable.consciousness = org.consciousness
	sendtable.assimilated = org.assimilated
	sendtable.berserk = org.berserk
	sendtable.noradrenaline = org.noradrenaline
	sendtable.panicattackadd = org.panicattackadd
	sendtable.panicattack = org.panicattack
	sendtable.seizure = org.seizure
	sendtable.seizureActive = org.seizureActive
	sendtable.seizureStart = org.seizureStart
	sendtable.seizureEnd = org.seizureEnd
	sendtable.LodgedEntities = org.LodgedEntities
	sendtable.CantCheckPulse = org.CantCheckPulse
	sendtable.blindness = org.blindness
	sendtable.critical = org.critical
	sendtable.incapacitated = org.incapacitated
	sendtable.deathStateEnd = org.deathStateEnd or 0
	sendtable.berserkActive2 = org.berserkActive2
	sendtable.noradrenalineActive = org.noradrenalineActive
	sendtable.superfighter = org.superfighter
	sendtable.concussion = org.concussion
	sendtable.nausea = org.nausea
	sendtable.concussion_tinnitus = org.concussion_tinnitus
	net.Start("organism_send", hg_unreliable_nets:GetBool())
	net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	net.WriteBool(org.owner.fullsend)
	net.WriteBool(false)
	net.WriteBool(true)
	net.WriteBool(false)
	if IsValid(ply) and ply:IsPlayer() then
		net.Send(ply)
	else
		net.Broadcast()
	end
	if org.owner == ply or not IsValid(ply) or not ply:IsPlayer() then
		org.owner.fullsend = nil
	end
end
local function send_bareinfo(org)
	if not IsValid(org.owner) then return end
	local sendtable = {}
	sendtable.alive = org.alive
	sendtable.otrub = org.otrub
	sendtable.owner = org.owner
	sendtable.bloodtype = org.bloodtype
	sendtable.blood = org.blood
	sendtable.bleed = org.bleed
	sendtable.pulse = org.pulse
	sendtable.heartbeat = org.heartbeat
	sendtable.analgesia = org.analgesia
	sendtable.o2 = org.o2
	sendtable.timeValue = org.timeValue
	sendtable.superfighter = org.superfighter
	sendtable.lungsfunction = org.lungsfunction
	sendtable.eyeL = org.eyeL
	sendtable.eyeR = org.eyeR
	sendtable.lleg = org.lleg
	sendtable.rleg = org.rleg
	sendtable.rarm = org.rarm
	sendtable.larm = org.larm
	sendtable.llegdislocation = org.llegdislocation
	sendtable.rlegdislocation = org.rlegdislocation
	sendtable.rarmdislocation = org.rarmdislocation
	sendtable.larmdislocation = org.larmdislocation
	sendtable.jawdislocation = org.jawdislocation
	sendtable.llegamputated = org.llegamputated
	sendtable.rlegamputated = org.rlegamputated
	sendtable.rarmamputated = org.rarmamputated
	sendtable.larmamputated = org.larmamputated
	sendtable.lhandamputated = org.lhandamputated
	sendtable.rhandamputated = org.rhandamputated
	sendtable.headamputated = org.headamputated
	sendtable.LodgedEntities = org.LodgedEntities
	sendtable.berserkActive2 = org.berserkActive2
	sendtable.CantCheckPulse = org.CantCheckPulse
	sendtable.noradrenalineActive = org.noradrenalineActive
	sendtable.panicattackadd = org.panicattackadd
	sendtable.panicattack = org.panicattack
	sendtable.seizure = org.seizure
	sendtable.seizureActive = org.seizureActive
	sendtable.seizureStart = org.seizureStart
	sendtable.seizureEnd = org.seizureEnd
	sendtable.brainFrontal = org.brainFrontal
	sendtable.brainParietal = org.brainParietal
	sendtable.brainTemporal = org.brainTemporal
	sendtable.brainOccipital = org.brainOccipital
	sendtable.brainHemorrhage = org.brainHemorrhage
	sendtable.brainBleedRate = org.brainBleedRate

	local rf = RecipientFilter()
	rf:AddPVS(org.owner:GetPos())
	if org.owner:IsPlayer() then rf:RemovePlayer(org.owner) end
	net.Start("organism_send", hg_unreliable_nets:GetBool())
	net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	net.WriteBool(org.owner.fullsend)
	net.WriteBool(true)
	net.WriteBool(false)
	net.WriteBool(false)
	net.Send(rf)
end
hg.send_organism = send_organism
hg.send_bareinfo = send_bareinfo
local META = FindMetaTable("Player")
function META:IsBerserk()
	if !IsValid(self) then return false end
	if self:IsPlayer() and not self:Alive() then return false end
	local org = self.organism
	return org.berserkActive2 or false
end
function META:IsStimulated()
	if !IsValid(self) then return false end
	if self:IsPlayer() and not self:Alive() then return false end
	local org = self.organism
	return org.noradrenalineActive or false
end
local META2 = FindMetaTable("Entity")
function META2:IsBerserk()
	return false
end
function META2:IsStimulated()
	return false
end
function hg.organism.AddPanicAttack(org, amount, silent)
	if not org then return 0 end
	if not isnumber(amount) or amount <= 0 then return org.panicattackadd or 0 end
	if math.random(panicattack_gain_chance) != 1 then return org.panicattackadd or 0 end
	org.panicattackadd = math.Clamp((org.panicattackadd or 0) + amount * panicattack_gain_mul, 0, 1)
	return org.panicattackadd
end
function hg.organism.AddSeizure(org, amount)
	if not org then return 0 end
	if not isnumber(amount) or amount <= 0 then return org.seizure or 0 end
	org.seizure = math.Clamp((org.seizure or 0) + amount, 0, 1)
	return org.seizure
end
local function apply_seizure_pose(rag, org, time)
	if not IsValid(rag) then return end
	local boneSpine2 = rag:LookupBone("ValveBiped.Bip01_Spine2")
	if not boneSpine2 then return end
	local spine2 = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(boneSpine2))
	if not IsValid(spine2) then return end
	local spineAng = spine2:GetAngles()
	local spinePos = spine2:GetPos()
	local force = seizure_pose_force * math.Clamp((org.pulse or 70) / 70, 0.9, 1.15)
	local damp = seizure_pose_damp
	local shake = Vector(
		math.sin(time * seizure_shake_freq) * seizure_shake_amp,
		math.sin(time * (seizure_shake_freq + 0.9)) * seizure_shake_amp * 0.8,
		math.sin(time * (seizure_shake_freq + 1.4)) * seizure_shake_amp * 0.65
	)
	local torsoAng = Angle(
		spineAng.p + 8 + math.sin(time * 3.6) * 1.4,
		spineAng.y,
		spineAng.roll + math.sin(time * 4.1) * 2.2
	)
	local leftShoulderAng = Angle(torsoAng.p + 16, torsoAng.y, torsoAng.roll - 16)
	local rightShoulderAng = Angle(torsoAng.p + 20, torsoAng.y, torsoAng.roll + 16)
	local thighAng = Angle(spineAng.p + seizure_leg_buckle + math.sin(time * 4.5) * 2.5, spineAng.y + 180, spineAng.roll + math.sin(time * 4.9) * 2.5)
	local calfAng = Angle(spineAng.p + seizure_leg_buckle + 26 + math.sin(time * 5.2) * 2, spineAng.y + 180, spineAng.roll - math.sin(time * 5.7) * 2)
	local chestPos = spinePos + torsoAng:Forward() * 3 + torsoAng:Up() * 8 + shake
	local stomachPos = spinePos + torsoAng:Forward() * 1 + torsoAng:Up() * 2 + shake * 0.75
	local lForePos = chestPos - torsoAng:Right() * 9 + torsoAng:Forward() * 1
	local rForePos = stomachPos + torsoAng:Right() * 8
	local lHandPos = chestPos - torsoAng:Right() * 5 - torsoAng:Up() * 1
	local rHandPos = stomachPos + torsoAng:Right() * 4 - torsoAng:Up() * 1
	hg.ShadowControl(rag, 8, 0.001, thighAng, force * 1.1, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 9, 0.001, thighAng, force * 1.1, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 11, 0.001, calfAng, force * 0.95, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 12, 0.001, calfAng, force * 0.95, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 2, 0.001, leftShoulderAng, force * 0.45, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 3, 0.001, rightShoulderAng, force * 0.45, damp, vector_origin, 0, 0)
	hg.ShadowControl(rag, 4, 0.001, nil, 0, 0, lForePos, force * 0.95, damp)
	hg.ShadowControl(rag, 6, 0.001, nil, 0, 0, rForePos, force * 0.95, damp)
	hg.ShadowControl(rag, 5, 0.001, nil, 0, 0, lHandPos, force * 1.2, damp)
	hg.ShadowControl(rag, 7, 0.001, nil, 0, 0, rHandPos, force * 1.2, damp)
	hg.ShadowControl(rag, 10, 0.4, Angle(torsoAng.p + 14, torsoAng.y, torsoAng.roll), 10, 6)
end
local function stop_seizure(owner, org)
	local wasActive = org.seizureActive
	org.seizure = 0
	org.seizureActive = false
	org.seizureStart = 0
	org.seizureEnd = 0
	org.nextSeizureSpasm = 0
	if wasActive and IsValid(owner) and owner:IsPlayer() and owner:Alive() then
		owner.fullsend = true
		send_organism(org, owner)
	end
end
local function start_seizure(owner, org)
	if org.seizureActive or not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	local time = CurTime()
	org.seizure = 1
	org.seizureActive = true
	org.seizureStart = time
	org.seizureEnd = time + seizure_duration
	org.nextSeizureSpasm = time
	owner.fullsend = true
	send_organism(org, owner)
end
local function resolve_panic_attacker(victim, attacker)
	if IsValid(attacker) then
		if attacker:IsPlayer() then
			return attacker
		end
		local owner = attacker.GetOwner and attacker:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then
			return owner
		end
	end
	if IsValid(victim) and victim.GetPhysicsAttacker then
		local physicsAttacker = victim:GetPhysicsAttacker()
		if IsValid(physicsAttacker) and physicsAttacker:IsPlayer() then
			return physicsAttacker
		end
	end
end
local function panic_witness_event(victim, attacker, amount, radius)
	if not IsValid(victim) then return end
	if not isnumber(amount) or amount <= 0 then return end
	local victimEnt = hg.GetCurrentCharacter(victim) or victim
	local victimPos = victimEnt.WorldSpaceCenter and victimEnt:WorldSpaceCenter() or victimEnt:GetPos()
	for _, watcher in ipairs(ents.FindInSphere(victimPos, radius)) do
		if not watcher:IsPlayer() or watcher == victim then continue end
		if not watcher:Alive() or not watcher.organism or watcher.organism.otrub then continue end
		if IsValid(attacker) and watcher == attacker then continue end
		local watcherEnt = hg.GetCurrentCharacter(watcher) or watcher
		local tr = util.TraceLine({
			start = watcher:EyePos(),
			endpos = victimPos,
			filter = {watcher, watcherEnt, victim, victimEnt, attacker},
			mask = MASK_SHOT
		})
		if tr.Hit then continue end
		hg.organism.AddPanicAttack(watcher.organism, amount, true)
	end
end
local numerical = {
	"One.",
	"Two.",
	"Three.",
	"Four.",
	"Five.",
	"Six.",
	"Seven.",
	"Eight.",
	"Nine.",
	"Ten.",
	"Eleven.",
	"Twelve.",
	"Thirteen.",
	"Fourteen.",
	"Fifteen.",
	"Sixteen.",
	"Seventeen.",
	"Eighteen.",
	"Nineteen.",
	"Twenty."
}
hook.Add("HomigradDamage", "Berserk", function(ply, dmgInfo, hitgroup, ent)
	local attacker, victim = dmgInfo:GetAttacker(), ply
	if !attacker or !IsValid(attacker) or (IsValid(attacker) and !attacker:IsPlayer()) then
		attacker = ply:GetPhysicsAttacker()
	end
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	if attacker == victim then return end
	if !attacker:IsBerserk() then return end
	timer.Simple(0, function()
		if IsValid(attacker) and IsValid(victim) and not victim:Alive() then
			attacker.BerserkKills = (attacker.BerserkKills or 0) + 1
			attacker:NotifyBerserk(numerical[attacker.BerserkKills] or (attacker.BerserkKills .. "."))
			attacker.organism.berserk = attacker.organism.berserk + 0.5
		end
	end)
end)
hook.Add("HomigradDamage", "PanicAttackDamage", function(ply, dmgInfo)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if not ply.organism then return end
	local amount = math.Clamp(dmgInfo:GetDamage() * panicattack_damage_scale + (dmgInfo:IsDamageType(DMG_BLAST) and 0.08 or 0), 0.03, 0.35)
	local attacker = resolve_panic_attacker(ply, dmgInfo:GetAttacker())
	hg.organism.AddPanicAttack(ply.organism, amount)
	if dmgInfo:GetDamage() <= 0 and not dmgInfo:IsDamageType(DMG_BLAST) then return end
	panic_witness_event(ply, attacker, math.Clamp(amount * 0.75, 0.04, 0.2), panicattack_witness_radius)
end)
hook.Add("Org Think", "Main", function(owner, org, timeValue)
	if not IsValid(owner) then
		hg.organism.list[owner] = nil
		return
	end
	if owner:IsPlayer() and not owner:Alive() then return end
	local isPly = owner:IsPlayer()
	org.isPly = isPly
	if isPly or org.fakePlayer then
		if not org.fakePlayer then
			org.alive = owner:Alive()
		end
	else
		org.alive = false
	end
	org.needotrub = false
	org.needfake = false
	if isPly then
		org.ownerFake = org.FakeRagdoll and true
	else
		org.ownerFake = false
	end
	org.timeValue = timeValue
	org.incapacitated = false
	org.critical = false
	if isPly then
		module.stamina[2](owner, org, timeValue)
	end
	if isPly or org.fakePlayer then
		module.lungs[2](owner, org, timeValue)
	end
	local eyeL = org.eyeL or 0
	local eyeR = org.eyeR or 0
	if eyeL < 1 and eyeR < 1 then
		org.blindness = nil
	elseif eyeL >= 1 and eyeR < 1 then
		org.blindness = 2
	elseif eyeR >= 1 and eyeL < 1 then
		org.blindness = 1
	elseif eyeL >= 1 and eyeR >= 1 then
		org.blindness = 0
	end
	if isPly then
		module.liver[2](owner, org, timeValue)
	end
	module.blood[2](owner, org, timeValue)
	local neckslit = false
	if org.arterialwounds then
		for i, wound in pairs(org.arterialwounds) do
			if wound[7] == "arteria" and wound[1] > 0 then
				neckslit = true
				break
			end
		end
	end
	org.neckslit = neckslit
	module.pain[2](owner, org, timeValue)
	if isPly then
		module.metabolism[2](owner, org, timeValue)
		module.random_events[2](owner, org, timeValue)
	end
	module.pulse[2](owner, org, timeValue)
	module.concussion[2](owner, org, timeValue)
	module.trauma_combo[2](owner, org, timeValue)
	if org.owner.PlayerClassName == "furry" then
		org.assimilated = 0
	end
	if org.owner.PlayerClassName != "furry" and org.furryinfected then
		org.assimilated = math.Approach(org.assimilated, 1, timeValue / 30 * org.pulse / 70)
		if org.assimilated == 1 then
			hg.Furrify(org.owner)
			org.furryinfected = false
		end
	else
		if (org.lightstun - CurTime()) <= 0 then
			org.assimilated = math.Approach(org.assimilated, 0, (timeValue / 60 * org.pulse / 70) * 6)
		end
	end
	if org.assimilated == 1 then
		org.assimilated = 0
		org.owner:SetPlayerClass("furry")
	end
	org.berserk = math.Approach(org.berserk, 0, timeValue / 60)
	org.noradrenaline = math.Approach(org.noradrenaline, 0, timeValue / 45)
	local oldPanicAttack = org.panicattack or 0
	org.panicattackadd = math.Approach(org.panicattackadd or 0, 0, timeValue / panicattack_add_decay_time)
	org.panicattack = math.Approach(oldPanicAttack, org.panicattackadd or 0, timeValue / ((org.panicattackadd or 0) > oldPanicAttack and panicattack_rise_time or panicattack_decay_time))
	local oldSeizureBrain = org.lastSeizureBrain or (org.brain or 0)
	local oldSeizureTemperature = org.lastSeizureTemperature or (org.temperature or 36.7)
	if org.berserk > 0 and !org.berserkActive then
		org.berserkActive = true
		owner.lastBerserkLaughSoundCD = CurTime() + 5
		timer.Simple(3.95, function()
			org.berserkActive2 = true
		end)
	elseif org.berserk <= 0 then
		org.berserkActive = false
		org.berserkActive2 = false
		owner.BerserkKills = nil
	end
	if org.noradrenaline > 0 and !org.noradrenalineActive then
		org.noradrenalineActive = true
	elseif org.noradrenaline <= 0 then
		org.noradrenalineActive = false
	end
	if oldPanicAttack < panicattack_threshold and org.panicattack >= panicattack_threshold and isPly and owner:Alive() then
		owner:Notify("I can't calm down.", 2, "panicattack_start", 2, nil, Color(255, 140, 140))
	end
	if org.panicattack >= panicattack_threshold then
		org.panicattackActive = true
		org.disorientation = math.max(org.disorientation, 0.6 + panicattack_disorientation * org.panicattack)
		org.adrenalineAdd = math.Approach(org.adrenalineAdd or 0, math.Remap(org.panicattack, panicattack_threshold, 1, panicattack_adrenaline_add_target * 0.5, panicattack_adrenaline_add_target), timeValue / panicattack_adrenaline_add_rise_time)
		if isPly and CurTime() >= (org.nextPanicHeartRoll or 0) then
			org.nextPanicHeartRoll = CurTime() + panicattack_heart_roll_delay
			if math.random(100) <= panicattack_heart_roll_chance then
				org.heartstop = true
				owner:Notify("My heart just stopped.", 2, "panicattack_heartstop", 2, nil, Color(255, 120, 120))
			end
		end
	else
		org.panicattackActive = false
		org.nextPanicHeartRoll = CurTime() + panicattack_heart_roll_delay
	end
	local brainDelta = (org.brain or 0) - oldSeizureBrain
	if brainDelta > 0 then
		hg.organism.AddSeizure(org, math.Clamp(brainDelta * seizure_brain_trauma_gain_mul, 0, 1))
	elseif brainDelta < 0 and oldSeizureBrain > 0 then
		hg.organism.AddSeizure(org, math.Clamp(-brainDelta * seizure_brain_heal_gain_mul, 0, 1))
	end
	local temperature = org.temperature or 36.7
	local previousTemperature = oldSeizureTemperature
	local heatStress = math.max(temperature - seizure_temperature_high_start, previousTemperature - seizure_temperature_high_start, 0)
	local coldStress = math.max(seizure_temperature_low_start - temperature, seizure_temperature_low_start - previousTemperature, 0)
	local temperatureStress = math.max(heatStress, coldStress)
	if temperatureStress > 0 then
		hg.organism.AddSeizure(org, timeValue * temperatureStress * seizure_temperature_gain_mul)
	end
	local curTime = CurTime()
	if (org.brain or 0) > 0.05 then
		org.nextSeizureRoll = org.nextSeizureRoll or (curTime + seizure_brain_roll_delay)
		if curTime >= org.nextSeizureRoll then
			org.nextSeizureRoll = curTime + seizure_brain_roll_delay
			if math.random(seizure_brain_roll_chance) == 1 then
				hg.organism.AddSeizure(org, math.Rand(seizure_brain_roll_gain_min, seizure_brain_roll_gain_max) * math.Clamp(math.Remap(org.brain or 0, 0.05, 1, 0.75, 1.5), 0.75, 1.5))
			end
		end
	else
		org.nextSeizureRoll = curTime + seizure_brain_roll_delay
	end
	org.lastSeizureBrain = org.brain or 0
	org.lastSeizureTemperature = temperature
	if org.seizure >= 1 and !org.seizureActive and isPly and owner:Alive() then
		start_seizure(owner, org)
	elseif org.seizureActive and org.seizure <= 0 then
		stop_seizure(owner, org)
	end
	if org.seizureActive then
		local time = CurTime()
		local seizureStart = org.seizureStart or time
		local seizureEnd = org.seizureEnd or time
		org.needfake = true
		owner.fakecd = math.max(owner.fakecd or 0, seizureEnd)
		if time >= seizureEnd then
			org.brain = math.max(org.brain or 0, seizure_brain_damage_final)
			stop_seizure(owner, org)
		else
			if time >= seizureStart + seizure_brain_damage_start then
				local frac = math.Clamp((time - (seizureStart + seizure_brain_damage_start)) / math.max(seizure_duration - seizure_brain_damage_start, 0.001), 0, 1)
				org.brain = math.max(org.brain or 0, seizure_brain_damage_final * frac)
			end
			local rag = owner.FakeRagdoll
			if IsValid(rag) then
				apply_seizure_pose(rag, org, time)
			end
		end
	end
	if (org.llegamputated or org.rlegamputated) and org.berserk <= 0.3 then
		org.needfake = true
	end
	if org.rarmamputated and org.larmamputated and owner:IsPlayer() then
		local hands = owner:GetWeapon("weapon_hands_sh")
		if owner:GetActiveWeapon() != hands then
			owner:SetActiveWeapon(hands)
		end
	end
	if org.otrub then
		org.uncon_timer = org.uncon_timer or 0
		org.uncon_timer = org.uncon_timer + timeValue
	else
		org.uncon_timer = 0
	end
	local just_went_uncon = not org.otrub and org.needotrub
	local just_woke_up = not org.needotrub and org.otrub and (org.uncon_timer or 0) > 6
	if isPly and just_went_uncon then hook.Run("HG_OnOtrub", owner); hook.Run("PlayerDropWeapon", owner) end
	if isPly and just_woke_up then hook.Run("HG_OnWakeOtrub", owner) end
	org.canmove = (org.spine2 < hg.organism.fake_spine2 and org.spine3 < hg.organism.fake_spine3) and not org.otrub
	org.canmovehead = (org.spine3 < hg.organism.fake_spine3) and not org.otrub
	if not (org.canmove and org.canmovehead and (org.stun - CurTime()) < 0) then org.needfake = true end
	if (org.blood < 2700) then org.needfake = true end
	if org.neckslit and not org.otrub then org.needfake = true end
	local just_went_uncon = not org.otrub and org.needotrub
	if org.posturing then
		local ent = hg.GetCurrentCharacter(org.owner)
		local rleg = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Foot")))
		local lleg = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Foot")))
		local rarm = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand")))
		local larm = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Hand")))
		local down = -ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine")):GetAngles():Forward()
		if IsValid(rleg) and IsValid(rarm) and IsValid(larm) and IsValid(lleg)then
			rleg:ApplyForceCenter(down * 500)
			lleg:ApplyForceCenter(down * 500)
			rarm:ApplyForceCenter(down * 500)
			larm:ApplyForceCenter(down * 500)
		end
	end
	if org.brain < 0.4 then
		local naturalHeal = org.thiamine > 0 and timeValue / 480 or timeValue / 1800
		org.thiamine = math.Approach(org.thiamine, 0, timeValue / 240)
		if org.liver < 1 then org.liver = math.Approach(org.liver, 0, naturalHeal) end
		if org.heart < 1 then org.heart = math.Approach(org.heart, 0, naturalHeal) end
		if org.stomach < 1 then org.stomach = math.Approach(org.stomach, 0, naturalHeal) end
		if org.intestines < 1 then org.intestines = math.Approach(org.intestines, 0, naturalHeal) end
		if org.lungsR[1] < 1 then org.lungsR[1] = math.Approach(org.lungsR[1], 0, naturalHeal) end
		if org.lungsL[1] < 1 then org.lungsL[1] = math.Approach(org.lungsL[1], 0, naturalHeal) end
		if (org.eyeL or 0) < 1 then org.eyeL = math.Approach(org.eyeL or 0, 0, naturalHeal) end
		if (org.eyeR or 0) < 1 then org.eyeR = math.Approach(org.eyeR or 0, 0, naturalHeal) end
	end
	if org.otrub and isPly and org.owner:Alive() then
	end
	if not org.otrub and isPly and org.owner:Alive() then
	end
	if org.neckslitSoundName and (org.otrub or org.needotrub) then
		if IsValid(org.neckslitSoundEnt) then
			org.neckslitSoundEnt:StopSound(org.neckslitSoundName)
		end
		if IsValid(owner) then
			owner:StopSound(org.neckslitSoundName)
		end
		org.neckslitSoundName = nil
		org.neckslitSoundEnt = nil
	end

	if isPly and org.otrub and org.incapacitated then
		org.deathStateEnd = org.deathStateEnd or CurTime() + 25

		if CurTime() >= org.deathStateEnd and not org.deathStateKilled then
			org.deathStateKilled = true
			owner:Kill()
			return
		end
	else
		org.deathStateEnd = nil
		org.deathStateKilled = nil
	end

	if just_went_uncon then
		org.owner.fullsend = true
	end
	if org.brain > 0.05 then
		if math.random(600) < org.brain * 20 then
			org.needfake = true
		end
	end
	org.otrub = org.needotrub
	org.fake = org.needfake
	if org.needfake and owner:IsNPC() then
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(10000)
		dmgInfo:SetAttacker(owner)
		owner:TakeDamageInfo(dmgInfo)
	end
	if owner:IsPlayer() and (org.healthRegen or 0) < CurTime() then
		org.healthRegen = CurTime() + 30
		owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + math.max(1.5 - org.hurt, 0)))
	end
	org.health = owner:Health()
	local rag = owner:IsPlayer() and owner.FakeRagdoll or owner
	if IsValid(rag) and rag:IsRagdoll() and (not owner.lastFake or owner.lastFake == 0) then rag:SetCollisionGroup((rag:GetVelocity():LengthSqr() > (200*200)) and COLLISION_GROUP_NONE or COLLISION_GROUP_WEAPON) end
	if isPly then
		if org.otrub or org.fake then hg.Fake(owner,nil,true) end
		if not org.alive and owner:Alive() then owner:Kill() end
	end
	if not org.otrub and isPly then
		local mul = hg.likely_to_phrase(owner)
		if not org.likely_phrase then org.likely_phrase = 0 end
		org.likely_phrase = math.max(org.likely_phrase + math.Rand(0, mul) / 100, 0)
		if org.likely_phrase >= 1 and !hg.GetCurrentCharacter(owner):IsOnFire() then
			org.likely_phrase = 0
			local str = hg.get_status_message(owner)
			owner:Notify(str, 1, "phrase", 1, nil, Color(255, math.Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255), math.Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255), 255))
		end
	end
	if !org.alive then org.otrub = true end
	if !org.alive then
		org.lungsfunction = false
		org.heartstop = true
	end
	time = CurTime()
	if IsValid(owner) then
		org.sendPlyTime = org.sendPlyTime or CurTime()
		if (org.sendPlyTime > time) and !just_went_uncon then return end
		org.sendPlyTime = CurTime() + 1 + (not isPly and 2 or 0)
		send_bareinfo(org)
		org.owner:SetNetVar("wounds", org.wounds)
		org.owner:SetNetVar("arterialwounds", org.arterialwounds)
		if isPly and owner:Alive() then
			send_organism(org, owner)
		end
	end
end)
hook.Add("Org Think", "regenerationberserk", function(owner, org, timeValue)
	if not owner:IsPlayer() or not owner:Alive() then return end
	if !owner:IsBerserk() then return end
	org.blood = math.Approach(org.blood, 5000, timeValue * 60)
	for i, wound in pairs(org.wounds) do
		wound[1] = math.max(wound[1] - timeValue * 10,0)
	end
	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math.max(wound[1] - timeValue * 10,0)
	end
	org.internalBleed = math.max(org.internalBleed - timeValue * 10, 0)
	local regen = timeValue / 120 * org.berserk
	org.lleg = math.max(org.lleg - regen, 0)
	org.rleg = math.max(org.rleg - regen, 0)
	org.rarm = math.max(org.rarm - regen, 0)
	org.larm = math.max(org.larm - regen, 0)
	org.chest = math.max(org.chest - regen, 0)
	org.pelvis = math.max(org.pelvis - regen, 0)
	org.spine1 = math.max(org.spine1 - regen, 0)
	org.spine2 = math.max(org.spine2 - regen, 0)
	org.spine3 = math.max(org.spine3 - regen, 0)
	org.skull = math.max(org.skull - regen, 0)
	org.liver = math.max(org.liver - regen, 0)
	org.intestines = math.max(org.intestines - regen, 0)
	org.heart = math.max(org.heart - regen, 0)
	org.stomach = math.max(org.stomach - regen, 0)
	org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math.max((org.lungsR[2] or 0) - regen, 0)
	org.lungsL[2] = math.max((org.lungsL[2] or 0) - regen, 0)
	org.eyeL = math.max((org.eyeL or 0) - regen, 0)
	org.eyeR = math.max((org.eyeR or 0) - regen, 0)
	local oldBrain = org.brain or 0
	org.brain = math.max(oldBrain - regen, 0)
	hg.organism.AddSeizure(org, math.Clamp((oldBrain - org.brain) * seizure_brain_heal_gain_mul, 0, 1))
	org.lastSeizureBrain = org.brain
	org.hungry = 0
	org.pain = math.Approach(org.pain, 0, timeValue * 10)
	org.painadd = math.Approach(org.painadd, 0, timeValue * 10)
	org.avgpain = math.Approach(org.avgpain, 0, timeValue * 10)
	org.shock = math.Approach(org.shock, 0, timeValue * 10)
	org.immobilization = math.Approach(org.immobilization, 0, timeValue * 10)
	org.disorientation = math.Approach(org.disorientation, 0, timeValue * 10)
	org.lungsfunction = true
	org.heartstop = false
	owner:SetRunSpeed(math.min(500, 400 + (25 * org.berserk)))
end)
hook.Add("Org Think", "regenerationnoradrenaline", function(owner, org, timeValue)
	if not owner:IsPlayer() or not owner:Alive() then return end
	if org.noradrenaline <= 0 then return end
	local regen = timeValue / 60 * org.noradrenaline
	org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math.max((org.lungsR[2] or 0) - regen, 0)
	org.lungsL[2] = math.max((org.lungsL[2] or 0) - regen, 0)
	org.eyeL = math.max((org.eyeL or 0) - regen, 0)
	org.eyeR = math.max((org.eyeR or 0) - regen, 0)
	org.hungry = 0
	org.pain = math.Approach(org.pain, 0, regen * 10)
	org.painadd = math.Approach(org.painadd, 0, regen * 10)
	org.avgpain = math.Approach(org.avgpain, 0, regen * 10)
	org.shock = math.Approach(org.shock, 0, regen * 10)
	org.immobilization = math.Approach(org.immobilization, 0, regen * 10)
	org.disorientation = math.Approach(org.disorientation, 0, regen * 10)
	org.adrenaline = math.Approach(org.adrenaline, 5, regen * 100)
	org.analgesia = math.Approach(org.analgesia, 1, regen * 10)
	if org.noradrenaline > 2 then
		local oldBrain = org.brain or 0
		org.brain = math.Approach(oldBrain, 0.3, timeValue / 60)
		hg.organism.AddSeizure(org, math.Clamp((oldBrain - org.brain) * seizure_brain_heal_gain_mul, 0, 1))
		org.lastSeizureBrain = org.brain
	end
	org.pulse = math.Approach(org.pulse, 70, regen * 10)
	org.heartbeat = math.Approach(org.heartbeat, 220, regen * 10)
	org.lungsfunction = true
	org.heartstop = false
end)
concommand.Add("hg_organism_setvalue", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not args[3] then
		if isbool(ply.organism[args[1]]) then
			ply.organism[args[1]] = tonumber(args[2]) != 0
		else
			ply.organism[args[1]] = tonumber(args[2])
		end
	end
	if args[3] then
		for i,pl in pairs(player.GetListByName(args[3])) do
			if isbool(pl.organism[args[1]]) then
				pl.organism[args[1]] = tonumber(args[2]) != 0
			else
				pl.organism[args[1]] = tonumber(args[2])
			end
		end
	end
end)
concommand.Add("hg_organism_setvalue2", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	ply.organism[args[1]][tonumber(args[2])] = tonumber(args[3])
end)
concommand.Add("hg_organism_clear", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not args[1] then
		hg.organism.Clear(ply.organism)
	end
	if args[1] then
		for i,pl in pairs(player.GetListByName(args[1])) do
			hg.organism.Clear(pl.organism)
		end
	end
end)
hook.Add("SetupMove", "hg-speed", function(ply, mv) end)
hook.Add("StartCommand","hg_lol",function(ply,cmd)
	if not ply:Alive() or not ply.organism then return end
	if ply.organism.seizureActive then
		cmd:ClearMovement()
		cmd:ClearButtons()
	elseif ply.organism.otrub then
		cmd:ClearMovement()
	end
end)
hook.Add("PlayerDeath","next-respawn-full",function(ply)
	ply.fullsend = true
end)
hook.Add("PlayerDeath", "PanicAttackWitnessDeath", function(victim, inflictor, attacker)
	local realAttacker = resolve_panic_attacker(victim, attacker)
	panic_witness_event(victim, realAttacker, 0.14, panicattack_death_radius)
end)
hook.Add("OnNPCKilled", "PanicAttackWitnessNPCDeath", function(victim, attacker, inflictor)
	local realAttacker = resolve_panic_attacker(victim, attacker)
	panic_witness_event(victim, realAttacker, 0.1, panicattack_death_radius)
end)
hook.Add("HG_OnWakeOtrub", "afterOtrub", function( owner )
	owner.organism.after_otrub = true
	local str = hg.get_status_message(owner)
	owner.organism.after_otrub = nil
	timer.Simple(0.1,function()
		if not IsValid(owner) then return end
		owner:Notify(str, 1, "wake", 1, nil, Color(255, math.Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255), math.Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255)) )
	end)
	owner.organism.fearadd = owner.organism.fearadd + 5
	owner:SendLua("system.FlashWindow()")
end)
hook.Add("HG_OnOtrub", "fearful", function( plya )// ЧЕ
	local ent = hg.GetCurrentCharacter(plya)
	for i,ply in ipairs(ents.FindInSphere(ent:GetPos(),256)) do
		if not ply:IsPlayer() or not ply.organism or plya == ply then continue end
		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ent:GetPos()
		tr.filter = {ply,ent}
		if not util.TraceLine(tr).Hit then
			ply.organism.adrenalineAdd = ply.organism.adrenalineAdd + 0.3
			ply.organism.fearadd = ply.organism.fearadd + 0.3
		end
	end
end)
local unlucky_dislocations = {
	"Why can't I fix this goddamn dislocation...",
	"Please... why is it so hard.",
	"Just go back in place already...",
	"This is irritating",
	"I should try again",
}
local finally_fixed = {
	"Finally.",
	"That was harder than I thought",
	"One dislocation away.",
}
local function fixlimb(org, key, fixer)
	if math.random(100) > (97 + (fixer != org.owner and (fixer.organism and fixer.organism.pain or 0) or 0) - (org.analgesia * 50 + org.painkiller * 15) - (fixer != org.owner and 30 or 0) - (fixer.tries or 0) * 10 - (fixer.Profession == "doctor" and 100 or 0) - (org.owner == fixer and (IsValid(org.owner.FakeRagdoll) or (org.owner.Crouching and org.owner:Crouching())) and 10 or 0)) then
		org[key.."dislocation"] = false
		if hg.fakeBoneFlop and hg.fakeBoneFlop.ClearStoredLimb(org, key) then
			hg.fakeBoneFlop.ScheduleRebuild(org.owner)
		end
		org.painadd = org.painadd + 5 * math.random(1, 3)
		org.fearadd = org.fearadd + 0.1
		org.owner:EmitSound("physics/flesh/flesh_impact_hard6.wav", 65)
		if fixer == org.owner and (fixer.tries or 0) > 3 and math.random(3) == 1 then
			fixer:Notify(finally_fixed[math.random(#finally_fixed)], 1, "dislocations_unlucky", 1, nil, Color(255, 255, 255, 255))
		end
		fixer.tries = 0
	else
		fixer.tries = (fixer.tries or 0) + 1
		org.painadd = org.painadd + 15 * math.random(1, 3)
		org.fearadd = org.fearadd + 0.3
		org.owner:EmitSound("physics/body/body_medium_impact_soft"..math.random(7)..".wav", 65)
		if fixer.Profession != "doctor" and math.random(5) == 1 then
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(50)
			dmgInfo:SetDamageType(DMG_CLUB)
			hg.organism.input_list[key.."down"](org.owner.organism, 1, 6, dmgInfo, 0, vector_up)
		end
		if fixer == org.owner and fixer.tries > 3 and math.random(3) == 1 then
			fixer:Notify(unlucky_dislocations[math.random(#unlucky_dislocations)], 1, "dislocations_unlucky", 1, nil, Color(255, 255, 255, 255))
		end
	end
end
concommand.Add("hg_fixdislocation", function(ply, cmd, args)
	local fixer = ply
	if math.Round(tonumber(args[2])) == 1 then
		ply = hg.eyeTrace(fixer).Entity
	end
	if !IsValid(ply) or !ply.organism then return end
	ply = ply.organism.owner
	local org = ply.organism
	if !fixer:Alive() or !org or fixer.organism.otrub then return end
	if (fixer.tried_fixing_limb or 0) > CurTime() then return end
	if !fixer.organism.canmove or !fixer.organism.canmovehead or fixer.organism.pain > 60 then return end
	fixer.tried_fixing_limb = CurTime() + fixer.organism.pain / 30
	if math.Round(tonumber(args[1])) == 1 then
		if org.llegdislocation then
			fixlimb(org, "lleg", fixer)
		elseif org.rlegdislocation then
			fixlimb(org, "rleg", fixer)
		end
	elseif math.Round(tonumber(args[1])) == 2 then
		if org.larmdislocation then
			fixlimb(org, "larm", fixer)
		elseif org.rarmdislocation then
			fixlimb(org, "rarm", fixer)
		end
	elseif math.Round(tonumber(args[1])) == 3 then
		if org.jawdislocation then
			fixlimb(org, "jaw", fixer)
		end
	end
end)

local function hg_ResolveDislocationPatient(target, fixer)
	if not IsValid(target) then return nil end
	if target:IsPlayer() then return target end
	if IsValid(target.organism) and IsValid(target.organism.owner) then return target.organism.owner end
	local plyref = target:GetNWEntity("ply")
	if IsValid(plyref) then return plyref end
	return nil
end

net.Receive("hg_dislocation_minigame_pain", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end

	local target = net.ReadEntity()
	local patient = hg_ResolveDislocationPatient(target, ply)

	if IsValid(patient) and patient:IsPlayer() and patient != ply then
		local org = patient.organism
		if not org then return end

		org.painadd = org.painadd + 5
		org.fearadd = org.fearadd + 0.1
		patient:EmitSound("physics/body/body_medium_impact_hard1.wav", 60, 100, 1, CHAN_AUTO)
		return
	end

	local org = ply.organism
	if not org then return end

	org.painadd = org.painadd + 5
	org.fearadd = org.fearadd + 0.1
	ply:EmitSound("physics/body/body_medium_impact_hard1.wav", 60, 100, 1, CHAN_AUTO)
end)

net.Receive("hg_dislocation_minigame_success", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end

	local target = net.ReadEntity()
	local patient = hg_ResolveDislocationPatient(target, ply) or ply

	if patient != ply and (not IsValid(patient) or not patient:IsPlayer() or patient == ply or ply:GetPos():Distance(patient:GetPos()) > 200) then
		patient = ply
	end

	local org = patient.organism
	if not org then return end

	local limbType = net.ReadInt(4)
	local failures = net.ReadInt(16)

	local key
	if limbType == 1 then
		if org.llegdislocation then key = "lleg"
		elseif org.rlegdislocation then key = "rleg" end
	elseif limbType == 2 then
		if org.larmdislocation then key = "larm"
		elseif org.rarmdislocation then key = "rarm" end
	elseif limbType == 3 then
		if org.jawdislocation then key = "jaw" end
	end

	if key then
		org[key.."dislocation"] = false
		if hg.fakeBoneFlop and hg.fakeBoneFlop.ClearStoredLimb(org, key) then
			hg.fakeBoneFlop.ScheduleRebuild(org.owner)
		end

		org.painadd = org.painadd + 5
		org.fearadd = org.fearadd + 0.1

		if failures > 0 then
			org.painadd = org.painadd + (failures * 2)
		end

		patient:EmitSound("physics/body/body_medium_impact_soft1.wav", 60, 100, 1, CHAN_AUTO)

		if patient == ply then
			ply:Notify("You fixed your dislocation.", 3, "fix", 2)
		else
			ply:Notify("You fixed " .. patient:GetName() .. "'s dislocation.", 3, "fix", 2)
			patient:Notify(ply:GetName() .. " fixed your dislocation.", 3, "fix", 2)
		end
	end
end)

hook.Add("OnEntityWaterLevelChanged", "ClearBlood", function(ent, old, new)
	if new >= 2 then
		if ent:IsOnFire() then ent:Extinguish() end
		ent:RemoveAllDecals()
	end
end)
