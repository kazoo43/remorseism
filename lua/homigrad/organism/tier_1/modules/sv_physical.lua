local max, min, Clamp, Approach = math.max, math.min, math.Clamp, math.Approach
hg.organism.module.pain = {}
local module = hg.organism.module.pain
local consciousness_otrub_threshold = 0.3
local consciousness_fake_threshold = 0.38
local shock_consciousness_soft_target = 0.5
local shock_consciousness_hard_target = 0
local shock_consciousness_drain_start = 10
local shock_consciousness_drain_end = 4
local consciousness_recovery_speed = 12
local low_consciousness_recovery_speed = 16
local otrub_consciousness_recovery_speed = 20
local shock_consciousness_threshold = 25
local shock_consciousness_max = 85
local pain_shock_threshold = 80
local pain_shock_target = 55
local pain_shock_gain = 2
local pain_shock_ramp_end = 120
local pain_shock_max_target = 85
local pain_shock_max_gain = 10
local pain_tolerance = 120
local otrub_pain_tolerance = 90
local pain_fake_threshold = 0.9
local pain_drain_base = 20
local pain_drain_otrub_mul = 4.5
module[1] = function(org)
	org.shock = 0
	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.nearpainlimit = false
	org.hurt = 0
	org.hurtadd = 0
	org.painkiller = 0
	org.analgesia = 0
	org.analgesiaAdd = 0
	org.naloxone = 0
	org.naloxoneadd = 0
	org.immobilization = 0
	org.painlessen = 0
	org.tranquilizer = 0
	org.shock_turn = 0
	org.stun = 0
	org.lightstun = 0
end
module[2] = function(owner, org, timeValue)
	local adrenalineMul = min(max(1 + org.adrenaline, 1), 1.2)
	local adrenaline = org.adrenaline
	local analgesiaMul = (org.analgesia * 4 + 1)
	local painkillerMul = (org.painkiller * 0.5 + 1)
	org.shock_turn = 10 * (!org.otrub and 1 or 0.1)
	if org.shock > org.shock_turn * 1.5 * analgesiaMul * painkillerMul then
	end
	org.pain_turn = org.otrub and adrenalineMul * otrub_pain_tolerance or adrenalineMul * pain_tolerance
	local owner = org.owner
	if !org.lasthit or org.lasthit + 1.5 < CurTime() then org.shock = max(org.shock - timeValue * 4 * (org.otrub and 1 or 0.5), 0) end
	org.immobilization = max(org.immobilization - timeValue * 5 * adrenalineMul, 0)
	local shouldPainAdd = not (org.otrub or org.spine2 >= hg.organism.fake_spine2 or org.spine3 >= hg.organism.fake_spine3)
	local add = math.min(timeValue * 15, org.painadd)
	local sub = (add <= 0.2) and (timeValue * pain_drain_base * (org.otrub and pain_drain_otrub_mul or 1) + timeValue * (org.painkiller * 2) + timeValue * (org.analgesia * 4)) or (0)
	if adrenaline > 0.5 then
		sub = sub * math.max(1 - adrenaline, 0.05) / 1.5// / (adrenaline >= 2 and 16 or 8)
		add = add * math.max(1 - adrenaline, 0.05) / 1.5// / (adrenaline >= 2 and 16 or 8)
	end
	if org.pain > 60 and not org.otrub then
		add = add / 5
		if org.pain > 70 and add > 0.01 then
			sub = sub / 20
		else
			sub = sub / 5
		end
		org.disorientation = math.max(org.pain / 50, org.disorientation)
		org.fearadd = 1
	end
	org.disorientation = math.min(org.disorientation, 10)
	if org.pain > pain_shock_threshold then
		local painShockTarget = Clamp(math.Remap(org.pain, pain_shock_threshold, pain_shock_ramp_end, pain_shock_target, pain_shock_max_target), pain_shock_target, pain_shock_max_target)
		local painShockGain = Clamp(math.Remap(org.pain, pain_shock_threshold, pain_shock_ramp_end, pain_shock_gain, pain_shock_max_gain), pain_shock_gain, pain_shock_max_gain)
		org.shock = math.Approach(org.shock, painShockTarget, timeValue * painShockGain)
	end
	local shockThreshold = shock_consciousness_threshold * analgesiaMul * painkillerMul
	local shockActive = org.shock > shockThreshold
	if shockActive then
		local shockTarget = Clamp(math.Remap(org.shock, shockThreshold, shock_consciousness_max, shock_consciousness_soft_target, shock_consciousness_hard_target), shock_consciousness_hard_target, shock_consciousness_soft_target)
		local shockDrain = Clamp(math.Remap(org.shock, shockThreshold, shock_consciousness_max, shock_consciousness_drain_start, shock_consciousness_drain_end), shock_consciousness_drain_end, shock_consciousness_drain_start)
		org.consciousness = Approach(org.consciousness, shockTarget, timeValue / shockDrain)
	end
	if org.tranquilizer > 0 then
		org.tranquilizer = math.Approach(org.tranquilizer, 0, org.tranquilizer > 1 and timeValue / 5 or timeValue / 30)
		org.consciousness = math.Approach(org.consciousness, 0, timeValue / 30 * org.tranquilizer)
	elseif not shockActive then
		local target = org.blood < 3000 and (org.blood - 2500) / 500 or 1
		local recovery_speed = consciousness_recovery_speed
		if org.otrub or org.consciousness < consciousness_otrub_threshold then
			recovery_speed = otrub_consciousness_recovery_speed
		elseif org.consciousness < consciousness_fake_threshold then
			recovery_speed = low_consciousness_recovery_speed
		end
		org.consciousness = Approach(org.consciousness, target, timeValue / recovery_speed)
	end
	if org.consciousness < consciousness_otrub_threshold then
		org.needotrub = true
	end
	if org.consciousness < consciousness_fake_threshold then
		org.needfake = true
	end
	org.avgpain = min(org.avgpain + add, 150)
	if !org.lasthit or org.lasthit + 1 < CurTime() then org.avgpain = max(org.avgpain - sub, 0) end
	org.painlessen = sub
	org.pain = org.avgpain * math.max(1 - adrenaline / 4, 0.75) * math.max(1 - org.analgesia, 0)
	org.nearpainlimit = not org.otrub and org.pain >= org.pain_turn * pain_fake_threshold
	org.painadd = min(max(org.painadd - add * analgesiaMul, 0), 150)
	if org.nearpainlimit then
		org.needfake = true
	end
	org.analgesia =  Approach(org.analgesia, 0, timeValue / 240 * (org.naloxone * 25 + 1))
	if org.analgesiaAdd > 0 then
		org.analgesia =  Approach(org.analgesia, 4, timeValue / 15)
		org.analgesiaAdd = Approach(org.analgesiaAdd, 0, timeValue / 15)
	end
	org.naloxone = Approach(org.naloxone, org.naloxoneadd > 0 and 4 or 0, org.naloxoneadd > 0 and timeValue / 30 or timeValue / 60)
	org.naloxoneadd = Approach(org.naloxoneadd, 0, timeValue / 15)
	if org.adrenalineAdd > 0 then
		org.adrenaline = Approach(org.adrenaline, 4, timeValue / 5)
	end
	org.adrenalineAdd = Approach(org.adrenalineAdd, 0, org.adrenalineAdd < 0 and timeValue / 30 or timeValue / 5)
	org.adrenaline = Approach(org.adrenaline, 0, timeValue / 25)
	if org.lleg < 1 and !org.llegamputated then
		org.lleg = max(org.lleg - timeValue / 240, 0)
	end
	if org.rleg < 1 and !org.rlegamputated then
		org.rleg = max(org.rleg - timeValue / 240, 0)
	end
	if org.rarm < 1 then
		org.rarm = max(org.rarm - timeValue / 240, 0)
	end
	if org.larm < 1 then
		org.larm = max(org.larm - timeValue / 240, 0)
	end
	if org.pain > 100 then
	end
	org.disorientation = math.Approach(org.disorientation, 0, timeValue / 5)
end
local min, max, Round = math.min, math.max, math.Round
local hg_organism_stamina_sprint_mul = CreateConVar("hg_organism_stamina_sprint_mul","1",{FCVAR_ARCHIVE,FCVAR_NOTIFY,FCVAR_NEVER_AS_STRING},"Multiply stamina drain when sprinting",0,10)
local panicattack_stamina_drain_mul = 1.35
hg.organism.module.stamina = {}
local module = hg.organism.module.stamina
module[1] = function(org)
	org.adrenaline = 0
	org.adrenalineAdd = 0
	org.adrenalineStorage = 5
	org.stamina = {
		range = 60 * 3,
		regen = 1,
		sub = 0,
		subadd = 0,
		weight = 0,
		max = 60 * 3,
	}
	org.energy = 0
	org.hemotransfusionshock = 0
	org.stamina[1] = org.stamina.range
	local owner = org.owner
	org.moveMaxSpeed = IsValid(owner) and owner:IsPlayer() and owner:GetMaxSpeed() or 250
end
local hg_infstamina = CreateConVar("hg_infstamina", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Toggle infinite stamina (excausts only from other organism effects, not from running/attacking)", 0, 1)
module[2] = function(owner, org, timeValue)
	local stamina = org.stamina
	local painfrommoving = (stamina.sub * (org.chest))
	if painfrommoving > 0 then
		if (org.jaw == 1) or org.jawdislocation then
		end
		if (org.chest > 0.25) then
		end
	end
	stamina.sub = 0
	local velLen = 0
	if owner:IsPlayer() then
		local wep = owner:GetActiveWeapon()
		local walk = owner:KeyDown(IN_FORWARD) or owner:KeyDown(IN_BACK) or owner:KeyDown(IN_MOVELEFT) or owner:KeyDown(IN_MOVERIGHT)
		velLen = max(min(owner:GetVelocity():Length(), org.moveMaxSpeed), 0) / (owner:GetRunSpeed() / hg_organism_stamina_sprint_mul:GetFloat())
		if (owner:OnGround() or owner:WaterLevel() >= 2) and walk and not owner:InVehicle() and owner.hg_isJogging and org.stamina[1] > 20 then
			stamina.sub = (owner:WaterLevel() >= 2 and 2 or 1) * (velLen ^ 0.5) * 0.6
		elseif (owner:OnGround() or owner:WaterLevel() >= 2) and walk and not owner:InVehicle() and owner.hg_isSprinting and org.stamina[1] > 20 then
			stamina.sub = (owner:WaterLevel() >= 2 and 2 or 1) * (velLen ^ 0.5) * 1.10
		end
	end
	if org.superfighter then
		org.stamina.subadd = org.stamina.subadd / 4
	end
	if org.chest > 0.3 then
		org.lungsL[2] = math.min(org.lungsL[2] + stamina.sub / 200 * org.chest, 1)
		org.lungsR[2] = math.min(org.lungsR[2] + stamina.sub / 200 * org.chest, 1)
	end
	stamina.sub = stamina.sub + stamina.subadd + (org.painkiller > 1.6 and (stamina[1] > 10 and 0.8 or 0) or 0) + (org.analgesia > 1.7 and (stamina[1] > 10 and 2 or 0) or 0)
	stamina.sub = stamina.sub * (owner.StaminaExhaustMul or 1)
	stamina.sub = stamina.sub / (1 + org.berserk)
	if org.o2[1] < 10 then
		stamina.sub = 0
	end
	stamina.subadd = 0
	stamina.weight = owner:IsPlayer() and math.Clamp((1 / hg.CalculateWeight(owner,250)) - 1,0,1) or 0
	local muffed = owner.armors and owner.armors["face"] == "mask2"
	stamina.sub = stamina.sub + stamina.sub * stamina.weight * (muffed and 2 or 1)
	if (org.panicattack or 0) >= 0.45 then
		stamina.sub = stamina.sub * panicattack_stamina_drain_mul
	end
	org.hungry = org.hungry or 0
	stamina.max = (org.superfighter and 2 or 1) * ((stamina.range * (1 - (org.pneumothorax) / 2) + org.adrenaline * 20 ) * math.max(1 - org.hemotransfusionshock,0.2)) * math.max(1 - (org.hungry/100),0.65)
	stamina[1] = max(stamina[1] - stamina.sub * timeValue * 16 * (2 - (org.o2[1] / org.o2.range)), 0)
	stamina[1] = min(stamina[1] + stamina.regen * timeValue * 8 * 1.5 * math.max(org.stamina[1] / org.stamina.max, 0.2) ^ 0.5 * (org.noradrenaline / 2 + 1) * (org.o2[1] / org.o2.range) * (org.adrenaline / 16 + 1) * (org.satiety/700 + 1) * ((owner:IsPlayer() and owner:Crouching() and velLen < 0.1) and 1.1 or 1) * (org.holdingbreath and 0 or 1) * (org.lungsfunction and 1 or 0), stamina.max)
	if org.nextAdrenalineRegen and org.nextAdrenalineRegen < CurTime() then
		org.adrenalineStorage = math.Approach(org.adrenalineStorage, 5, timeValue / 60 * (org.satiety * 0.01 + 1))
	end
	if hg_infstamina:GetBool() then
		stamina.sub = 0
		stamina[1] = stamina.max
	end
end
function hg.organism.AddNaturalAdrenaline(org, fAmount)
	if org.adrenalineStorage == 0 then return end
	if fAmount < 0 then return end
	local amt = math.min(org.adrenalineStorage, fAmount)
	org.adrenaline = math.min(org.adrenaline + amt, 5)
	org.adrenalineStorage = org.adrenalineStorage - amt
	org.nextAdrenalineRegen = CurTime() + 30
end
local entMeta = FindMetaTable("Entity")
function entMeta:AddNaturalAdrenaline(fAmount)
	local org = self.organism
	if !org then return end
	hg.organism.AddNaturalAdrenaline(org, fAmount)
end
local vecZero = Vector(0, 0, 0)
hook.Add("FinishMove", "!homigrad-organism", function(ply, move)
	local vel = move:GetFinalJumpVelocity()
	if !ply.organism then return end
	if vel ~= vecZero then ply.organism.stamina[1] = max(ply.organism.stamina[1] - ply:GetJumpPower() / 10,0) end
	ply.organism.moveMaxSpeed = move:GetMaxSpeed()
end)
