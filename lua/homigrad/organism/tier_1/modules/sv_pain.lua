local max, min, Clamp, Approach = math.max, math.min, math.Clamp, math.Approach
--local Organism = hg.organism
hg.organism.module.pain = {}
local module = hg.organism.module.pain
local consciousness_otrub_threshold = 0.3
local consciousness_fake_threshold = 0.38
local consciousness_recovery_speed = 12
local low_consciousness_recovery_speed = 16
local otrub_consciousness_recovery_speed = 20
local pain_tolerance = 120
local otrub_pain_tolerance = 90
local pain_fake_threshold = 0.9
local pain_drain_base = 20
local pain_drain_otrub_mul = 4.5
local pain_unconscious_threshold = 112
local pain_unconscious_time = 1.5
local pain_unconscious_cooldown = 12
local shock_stage_thresholds = {15, 35, 60, 80}

local function getShockScore(org)
	local blood = Clamp((5000 - (org.blood or 5000)) / 2500, 0, 1)
	local pressure = 1 - Clamp(((org.bloodPressure or 90) - 35) / 55, 0, 1)
	local output = 1 - Clamp(org.cardiacOutput or 1, 0, 1)
	local oxygen = 1 - Clamp(((org.o2 and org.o2[1] or 30) - 8) / 22, 0, 1)
	local bleeding = Clamp((org.bleed or 0) / 3, 0, 1)
	local pain = Clamp(((org.pain or 0) - 70) / 80, 0, 1)

	return Clamp((blood * 0.38 + pressure * 0.28 + output * 0.14 + oxygen * 0.12 + bleeding * 0.08 + pain * 0.08) * 100, 0, 100)
end

local function getShockStage(score)
	if score >= shock_stage_thresholds[4] then return 4 end
	if score >= shock_stage_thresholds[3] then return 3 end
	if score >= shock_stage_thresholds[2] then return 2 end
	if score >= shock_stage_thresholds[1] then return 1 end
	return 0
end

local function updateShock(owner, org, timeValue)
	local score = getShockScore(org)
	local total = math.max(score, org.shock or 0)
	local stage = getShockStage(total)
	local target = stage == 4 and 0.04 or stage == 3 and 0.2 or stage == 2 and 0.52 or stage == 1 and 0.78 or 1

	org.shockScore = score
	org.shockStage = stage
	if stage >= 1 then
		org.fearadd = math.max(org.fearadd or 0, stage * 0.25)
		org.disorientation = math.max(org.disorientation or 0, stage * 0.2)
	end
	if stage >= 2 then
		org.immobilization = math.max(org.immobilization or 0, (stage - 1) * 2)
	end
	if stage >= 3 then
		org.needfake = true
	end
	if stage > 0 then
		org.consciousness = Approach(org.consciousness, target, timeValue / (stage == 4 and 3 or stage == 3 and 7 or stage == 2 and 14 or 30))
	end

	if stage >= 4 then
		org.needotrub = true
	end
end

local function updatePainUnconscious(owner, org, timeValue)
	if org.otrub or not org.alive then
		return
	end
	org.painUnconscious = false

	local now = CurTime()
	if org.pain >= pain_unconscious_threshold and org.consciousness > 0.08 then
		org.painUnconsciousTime = (org.painUnconsciousTime or 0) + timeValue
	else
		org.painUnconsciousTime = math.max((org.painUnconsciousTime or 0) - timeValue * 0.5, 0)
	end

	if org.painUnconsciousTime >= pain_unconscious_time and now >= (org.painUnconsciousCooldown or 0) then
		org.painUnconsciousCooldown = now + pain_unconscious_cooldown
		org.painUnconsciousTime = 0
		org.needotrub = true
		org.consciousness = math.min(org.consciousness, 0.18)
		org.painUnconscious = true
	else
		org.painUnconscious = false
	end
end

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
	org.shockScore = 0
	org.shockStage = 0
	org.painUnconscious = false
	org.painUnconsciousTime = 0
	org.painUnconsciousCooldown = 0

	org.stun = 0
	org.lightstun = 0
end

module[2] = function(owner, org, timeValue)
	local adrenalineMul = min(max(1 + org.adrenaline, 1), 1.2)
	local adrenaline = org.adrenaline
	local analgesiaMul = (org.analgesia * 4 + 1)

	org.shock_turn = 10 * (!org.otrub and 1 or 0.1)

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

		org.disorientation = math.max(org.pain / 50, org.disorientation)//org.disorientation + add
		org.fearadd = 1
	end

	org.disorientation = math.min(org.disorientation, 10)

	if org.tranquilizer > 0 then
		org.tranquilizer = math.Approach(org.tranquilizer, 0, org.tranquilizer > 1 and timeValue / 5 or timeValue / 30)
		--org.shock = math.Approach(org.shock, 50, timeValue * org.tranquilizer * 5)
		--org.shock = math.Approach(org.shock, 50, timeValue * org.tranquilizer * 5)
		org.consciousness = math.Approach(org.consciousness, 0, timeValue / 30 * org.tranquilizer)
	else
		local target = org.blood < 3000 and Clamp((org.blood - 2500) / 500, 0, 1) or 1
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

	if org.isPly and org.pain >= 85 and IsValid(owner) and owner.Thought then
		owner:Thought("You are experiencing excruciating pain.", 8, "thought_excruciatingpain", 0, Color(255, 160, 160))
	end

	org.painadd = min(max(org.painadd - add * analgesiaMul, 0), 150)
	updateShock(owner, org, timeValue)
	updatePainUnconscious(owner, org, timeValue)

	//org.painkiller = Approach(org.painkiller, 0, timeValue / 240 * (org.naloxone * 25 + 1))

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
	
	--if owner.suiciding and org.adrenaline < 1.5 then
	--	org.adrenalineAdd = Approach(org.adrenalineAdd, 4, timeValue / 5)
	--end

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
		--org.needfake = true
	end

	//local tempo = math.Clamp(5 - (org.temperature - 31), 0, 15)
	
	//org.shock = math.max(org.shock, tempo * 4)
	
	org.disorientation = math.Approach(org.disorientation, 0, timeValue / 5)
end
