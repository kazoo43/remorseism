local max, min, Clamp, Approach = math.max, math.min, math.Clamp, math.Approach
hg.organism.module.depression = {}
local module = hg.organism.module.depression

local depression_max = 1
local depression_drain_time = 300
local depression_drain_boost_time = 100
local depression_pain_threshold = 60
local depression_pain_gain = 0.02
local depression_fear_threshold = 3
local depression_fear_gain = 0.015
local depression_blood_threshold = 3500
local depression_blood_gain = 0.005
local depression_blood_cap = 0.15
local depression_adrenaline_suppress_start = 0.5
local depression_adrenaline_suppress_min = 0.1
local selfharm_adrenaline_threshold = 1.5
local depression_bleedrate_threshold = 5
local depression_bleedrate_gain = 0.015
local depression_bleedrate_maxmul = 4
local depression_o2_threshold = 15
local depression_o2_gain = 0.02
local depression_bones_gain = 0.012
local depression_cold_threshold = 35
local depression_cold_gain = 0.01
local depression_panic_gain = 0.02
local depression_amputation_gain = 0.015

local selfharm_threshold = 0.4
local selfharm_roll_time_min = 5
local selfharm_roll_time_max = 12
local selfharm_chance_min = 0.25
local selfharm_chance_max = 0.7
local selfharm_pending_time = 45
local selfharm_weapon_grace = 3
local selfharm_duration_min = 5
local selfharm_duration_max = 10
local selfharm_initial_delay = 15
local selfharm_wave_time = 4
local selfharm_wave_interval_min = 5
local selfharm_wave_interval_max = 7
local selfharm_wave_presses = 10

local selfharm_phrases = {
	"I can't take my eyes off my own wrist...",
	"The urge is too strong... maybe just one cut...",
	"I need to feel something else... anything...",
	"The pain in my head needs a way out...",
}

local selfharm_pending_phrases = {
	"My eyes keep drifting to the blade...",
	"Maybe I should pick it up... just to hold it...",
	"I can't stop thinking about the knife...",
}

local depression_stage_thresholds = {0.25, 0.35, 0.5}
local depression_stage_thoughts = {
	[0.25] = {
		{text = "You are feeling down."},
	{text = "A heavy weight settles on your chest."},
	{text = "Everything looks duller than it should."},
	{text = "You feel tired for no reason."},
	},
	[0.35] = {
		{text = "You are feeling upset."},
	{text = "A quiet sadness creeps over you."},
	{text = "Nothing feels worth the effort."},
	{text = "You can feel yourself slipping."},
	},
	[0.5] = {
		{text = "You are feeling depressed."},
	{text = "A grey fog settles over everything."},
	{text = "You feel hollow, like something is missing."},
	{text = "Nothing seems to matter anymore."},
	},
}
local depression_stage_cooldown = 30
local depression_dark_threshold = 0.65
local depression_dark_thought_min = 45
local depression_dark_thought_max = 120
local depression_dark_thoughts = {
	{text = "You wont make it far."},
	{text = "You wont succeed."},
	{text = "Find something sharp.", cut = true},
	{text = "Have you lost hope?"},
	{text = "Do you miss them?"},
	{text = "You are nobody."},
	{text = "You are a waste of time."},
	{text = "You are worthless."},
	{text = "End it all."},
	{text = "You are a burden to everyone."},
	{text = "Nobody would even notice."},
	{text = "Nothing you do matters."},
	{text = "You deserve every bit of this."},
	{text = "The blade would be so easy.", cut = true},
}

local depression_notify_stage_thresholds = {0.35, 0.45, 0.55, 0.65}
local depression_notify_stage_phrases = {
	[0.35] = {
		{text = "I'm feeling down.."},
		{text = "I'm feeling kinda down.."},
		{text = "Dude... I'm bored.."},
		{text = "Mmmh... I should get busy with something."},
		{text = "This day just keeps dragging on.."},
		{text = "I dont feel like doing anything today.."},
	},
	[0.45] = {
		{text = "I feel upset.."},
		{text = "I really feel sad.."},
		{text = "Does it get worse than this?"},
		{text = "Staying strong... I hope."},
		{text = "Why does everything feel so heavy.."},
		{text = "I just want this feeling to stop.."},
	},
	[0.55] = {
		{text = "Fuck my life."},
		{text = "I cant take this anymore."},
		{text = "I need something sharp.", cut = true},
		{text = "Fuck everything."},
		{text = "I'm so tired of all this.."},
		{text = "Everything is falling apart on me.."},
	},
	[0.65] = {
		{text = "I dont see the point in any of this anymore.."},
		{text = "Nobody would even notice if I was gone.."},
		{text = "I'm so tired of fighting this.."},
		{text = "Maybe it would just be easier this way.."},
		{text = "The knife keeps calling me..", cut = true},
		{text = "Just one cut and it all goes quiet..", cut = true},
	},
}

local depression_minigame_phrase_interval_min = 2
local depression_minigame_phrase_interval_max = 4
local depression_minigame_phrases = {
	"YES.. YES.. CUT IT.. I NEED TO CUT IT..",
	"KEEP GOING..  STEADY.. STEADY..",
	"YES.. GO ON... FUCK... FUCK MY LIFE..",
	"END IT ALREADY.. COME ON..",
	"YES.. MORE.. DEEPER..",
	"DONT YOU DARE STOP.. KEEP CUTTING..",
	"IT HURTS SO GOOD.. KEEP GOING..",
	"ALMOST.. FINISH IT.. COME ON..",
}

util.AddNetworkString("rem_selfharm_press")
util.AddNetworkString("rem_selfharm_end")

local function isSelfHarmWeapon(wep)
	if not IsValid(wep) or not wep.Canselfharm then return false end

	return wep.ismelee2 or wep.Base == "weapon_melee"
end

local function hasSelfHarmWeapon(owner)
	local wep = owner.GetActiveWeapon and owner:GetActiveWeapon()

	return isSelfHarmWeapon(wep)
end

local function findInventorySelfHarmWeapon(owner)
	for _, wep in ipairs(owner:GetWeapons()) do
		if isSelfHarmWeapon(wep) then return wep end
	end
end

local function autoEquipSelfHarmWeapon(owner)
	if hasSelfHarmWeapon(owner) then return true end
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return false end

	local found = findInventorySelfHarmWeapon(owner)
	if not IsValid(found) then return false end

	owner:SelectWeapon(found:GetClass())
	if owner.SetActiveWeapon then owner:SetActiveWeapon(found) end

	return true
end

local function hasCutWeapon(owner)
	return hasSelfHarmWeapon(owner) or IsValid(findInventorySelfHarmWeapon(owner))
end

local function hasStrongAdrenaline(org)
	return (org.adrenaline or 0) >= selfharm_adrenaline_threshold
end

local function pickPhrase(owner, pool)
	local canCut = hasCutWeapon(owner)

	local choices = {}
	for _, phrase in ipairs(pool) do
		if not phrase.cut or canCut then
			choices[#choices + 1] = phrase.text
		end
	end

	if #choices == 0 then return end

	return choices[math.random(#choices)]
end

function hg.organism.StartSelfHarm(owner)
	if not IsValid(owner) or not owner:IsPlayer() then return end

	local org = owner.organism
	if not org or not org.alive or owner.selfharming then return end
	if hasStrongAdrenaline(org) then return end
	if owner.suiciding or owner.remUrgeEnd then return end
	if (owner.remUrgeCooldown or 0) > CurTime() then return end

	owner.selfharming = true
	local dur = math.Rand(selfharm_duration_min, selfharm_duration_max)
	org.selfharmUntil = CurTime() + dur
	org.selfharmPendingUntil = nil
	owner:SetNWFloat("rem_selfharm_pending", 0)
	org.selfharmNextWave = nil
	org.selfharmWaveStart = CurTime()
	org.selfharmWaveEnd = org.selfharmUntil
	org.selfharmNextCut = CurTime() + 1
	org.selfharmPresses = 0
	owner:SetNWBool("selfharming", true)
	owner:SetNWFloat("rem_selfharm_wave_end", org.selfharmWaveEnd)

	if org.isPly then
		owner:Notify(selfharm_phrases[math.random(#selfharm_phrases)], 12, "selfharm", 0)
	end
end

function hg.organism.EndSelfHarm(owner, finished)
	if not IsValid(owner) then return end

	owner.selfharming = false
	owner:SetNWBool("selfharming", false)

	local org = owner.organism
	if org then
		if finished then
			org.depression = math.max((org.depression or 0) - 0.2, 0)
		end

		org.selfharmUntil = 0
		org.selfharmPendingUntil = nil
		org.selfharmGrace = nil

		if owner:IsPlayer() then
			owner:SetNWFloat("rem_selfharm_pending", 0)
		end

		local cooldown = CurTime() + math.Rand(15, 25)
		org.selfharmNextRoll = cooldown
		owner.remUrgeCooldown = math.max(owner.remUrgeCooldown or 0, cooldown)
		org.selfharmNextWave = nil
		org.selfharmWaveEnd = nil
		org.selfharmWaveStart = nil
		org.selfharmNextCut = nil
		org.selfharmPresses = 0
	end

	if owner:IsPlayer() then
		owner:SetNWFloat("rem_selfharm_wave_end", 0)

		if finished then
			net.Start("rem_selfharm_end")
			net.Send(owner)
		end
	end
end

module[1] = function(org)
	org.depression = 0
	org.depressionadd = 0
	org.depressionBlood = 0
	org.depressionThoughtStage = nil
	org.depressionNextStageThought = nil
	org.depressionNextDarkThought = nil
	org.depressionNotifyStage = nil
	org.depressionNextNotifyThought = nil
	org.depressionNextMinigamePhrase = nil
	org.selfharmNextRoll = CurTime() + selfharm_initial_delay
	org.selfharmUntil = 0
	org.selfharmPendingUntil = nil
	org.selfharmGrace = nil
	org.selfharmNextWave = nil
	org.selfharmWaveEnd = nil
	org.selfharmWaveStart = nil
	org.selfharmNextCut = nil
	org.selfharmPresses = 0

	local owner = org.owner
	if IsValid(owner) then
		owner.selfharming = false
		owner:SetNWBool("selfharming", false)
		owner:SetNWFloat("rem_selfharm_pending", 0)

		if owner:IsPlayer() then
			owner:SetNWFloat("rem_selfharm_wave_end", 0)
		end
	end
end

local function doSelfHarmCut(owner)
	local wep = owner.GetActiveWeapon and owner:GetActiveWeapon()
	if not IsValid(wep) or not wep.DoSelfHarmCut then return end

	wep:DoSelfHarmCut()
end

local function updateSelfHarmCutTick(owner, org)
	local now = CurTime()

	if not org.selfharmNextCut then return end
	if now < org.selfharmNextCut then return end

	local presses = org.selfharmPresses or 0
	org.selfharmPresses = 0
	org.selfharmNextCut = now + 1

	if presses < 2 and org.alive and not org.heartstop then
		doSelfHarmCut(owner)
	end
end

local function updateSelfHarm(owner, org)
	updateSelfHarmCutTick(owner, org)

	if (org.selfharmUntil or 0) < CurTime() then
		hg.organism.EndSelfHarm(owner, true)
		return
	end

	if org.otrub or owner.suiciding or org.larmamputated or hasStrongAdrenaline(org) then
		hg.organism.EndSelfHarm(owner)
		return
	end

	if not hasSelfHarmWeapon(owner) then
		org.selfharmGrace = org.selfharmGrace or CurTime() + selfharm_weapon_grace

		if CurTime() > org.selfharmGrace then
			hg.organism.EndSelfHarm(owner)
		end
	else
		org.selfharmGrace = nil
	end
end

local function updatePending(owner, org)
	if owner.selfharming then return end

	if (org.selfharmPendingUntil or 0) < CurTime() then
		if owner:GetNWFloat("rem_selfharm_pending", 0) ~= 0 then
			owner:SetNWFloat("rem_selfharm_pending", 0)
		end

		return
	end

	if org.otrub or owner.suiciding or org.larmamputated or hasStrongAdrenaline(org) then
		org.selfharmPendingUntil = nil
		owner:SetNWFloat("rem_selfharm_pending", 0)
		return
	end

	if not hasSelfHarmWeapon(owner) then
		if (org.selfharmNextEquip or 0) < CurTime() then
			org.selfharmNextEquip = CurTime() + 1

			autoEquipSelfHarmWeapon(owner)
		end

		return
	end

	org.selfharmNextEquip = nil

	hg.organism.StartSelfHarm(owner)
end

local function rollSelfHarm(owner, org)
	if (org.depression or 0) < selfharm_threshold then return end
	if hasStrongAdrenaline(org) then return end
	if (org.selfharmNextRoll or 0) > CurTime() then return end

	org.selfharmNextRoll = CurTime() + math.Rand(selfharm_roll_time_min, selfharm_roll_time_max)

	if org.otrub or owner.suiciding or org.larmamputated then return end

	local frac = Clamp((org.depression - selfharm_threshold) / (depression_max - selfharm_threshold), 0, 1)
	local chance = Lerp(frac, selfharm_chance_min, selfharm_chance_max)

	if math.Rand(0, 1) > chance then return end

	if hasSelfHarmWeapon(owner) then
		hg.organism.StartSelfHarm(owner)
		return
	end

	if autoEquipSelfHarmWeapon(owner) then
		hg.organism.StartSelfHarm(owner)
		return
	end

	org.selfharmPendingUntil = CurTime() + selfharm_pending_time
	owner:SetNWFloat("rem_selfharm_pending", org.selfharmPendingUntil)

	if org.isPly then
		owner:Notify(table.Random(selfharm_pending_phrases), 12, "selfharmpending", 0)
	end
end

module[2] = function(owner, org, timeValue)
	if hg.organism.IsMentalDisabled and hg.organism.IsMentalDisabled() then
		org.depression = 0
		org.depressionadd = 0
		org.depressionBlood = 0

		if owner.selfharming then
			hg.organism.EndSelfHarm(owner)
		end

		return
	end

	if owner.selfharming and (not org.alive or org.heartstop) then
		hg.organism.EndSelfHarm(owner)
	end

	if not org.alive then return end
	if org.heartstop then return end

	if org.otrub then
		if owner.selfharming then
			hg.organism.EndSelfHarm(owner)
		end

		return
	end

	local add = 0

	local pain = org.pain or 0
	if pain > depression_pain_threshold then
		add = add + depression_pain_gain * timeValue
	end

	local fear = org.fear or 0
	if fear > depression_fear_threshold then
		add = add + depression_fear_gain * timeValue
	end

	local bloodAdd = 0

	local blood = org.blood or 5000
	if blood < depression_blood_threshold then
		bloodAdd = bloodAdd + depression_blood_gain * timeValue
	end

	local bleedrate = org.bleed or 0
	if bleedrate > depression_bleedrate_threshold then
		bloodAdd = bloodAdd + depression_bleedrate_gain * min(bleedrate / depression_bleedrate_threshold, depression_bleedrate_maxmul) * timeValue
	end

	local bloodAllowed = depression_blood_cap - (org.depressionBlood or 0)
	if bloodAllowed <= 0 then
		bloodAdd = 0
	else
		bloodAdd = min(bloodAdd, bloodAllowed)
		org.depressionBlood = (org.depressionBlood or 0) + bloodAdd
	end

	add = add + bloodAdd

	local o2 = org.o2 and org.o2[1] or 30
	if o2 < depression_o2_threshold then
		add = add + depression_o2_gain * timeValue
	end

	if (org.immobilization or 0) > 0 or (org.spine1 or 0) > 0.5 or (org.spine2 or 0) > 0.5 or (org.spine3 or 0) > 0.5 or (org.lleg or 0) >= 0.5 or (org.rleg or 0) >= 0.5 then
		add = add + depression_bones_gain * timeValue
	end

	if (org.temperature or 36.7) < depression_cold_threshold then
		add = add + depression_cold_gain * timeValue
	end

	if org.panicattackActive then
		add = add + depression_panic_gain * timeValue
	end

	if org.larmamputated or org.rarmamputated or org.llegamputated or org.rlegamputated then
		add = add + depression_amputation_gain * timeValue
	end

	if (org.depressionadd or 0) > 0 then
		local applied = min(org.depressionadd, timeValue / 5)
		org.depressionadd = max(org.depressionadd - applied, 0)
		add = add + applied
	end

	local adrenaline = org.adrenaline or 0
	if adrenaline > depression_adrenaline_suppress_start then
		add = add * max(1 - adrenaline * 0.2, depression_adrenaline_suppress_min)
	end

	org.depression = Clamp((org.depression or 0) + add, 0, depression_max)

	local drainRate = timeValue / depression_drain_time
	if pain < 30 and fear < 2 and blood > 4000 then
		drainRate = drainRate * (depression_drain_time / depression_drain_boost_time)
	end

	if org.superfighter then
		drainRate = drainRate * 4
	end

	if (org.depression or 0) > 0.5 then
		drainRate = drainRate / 2.5
	end

	org.depression = max((org.depression or 0) - drainRate, 0)
	org.depressionBlood = max((org.depressionBlood or 0) - drainRate, 0)

	if owner:IsPlayer() then
		local dep = org.depression or 0

		if owner:GetInfoNum("hg_newthoughts", 0) > 0 then
			local stage = org.depressionThoughtStage

			if stage and dep < stage then
				org.depressionThoughtStage = nil
			end

			if dep < depression_stage_thresholds[1] then
				org.depressionThoughtStage = nil
			elseif (org.depressionNextStageThought or 0) < CurTime() then
				stage = org.depressionThoughtStage or 0

				for i = #depression_stage_thresholds, 1, -1 do
					local threshold = depression_stage_thresholds[i]

					if dep >= threshold then
						if stage < threshold then
							org.depressionThoughtStage = threshold
							org.depressionNextStageThought = CurTime() + depression_stage_cooldown
							owner:Thought(pickPhrase(owner, depression_stage_thoughts[threshold]), 6, "depression_stage_" .. threshold, 0)
						end

						break
					end
				end
			end

			if dep > depression_dark_threshold then
				if (org.depressionNextDarkThought or 0) < CurTime() then
					org.depressionNextDarkThought = CurTime() + math.Rand(depression_dark_thought_min, depression_dark_thought_max)
					owner:Thought(pickPhrase(owner, depression_dark_thoughts), 6, "depression_dark", 0)
				end
			else
				org.depressionNextDarkThought = nil
			end
		else
			local notifyStage = org.depressionNotifyStage

			if notifyStage and dep < notifyStage then
				org.depressionNotifyStage = nil
			end

			if dep < depression_notify_stage_thresholds[1] then
				org.depressionNotifyStage = nil
			elseif (org.depressionNextNotifyThought or 0) < CurTime() then
				notifyStage = org.depressionNotifyStage or 0

				for i = #depression_notify_stage_thresholds, 1, -1 do
					local threshold = depression_notify_stage_thresholds[i]

					if dep >= threshold then
						if notifyStage < threshold then
							org.depressionNotifyStage = threshold
							org.depressionNextNotifyThought = CurTime() + depression_stage_cooldown
							owner:Notify(pickPhrase(owner, depression_notify_stage_phrases[threshold]), 6, "depression_notify_stage_" .. threshold, 0)
						end

						break
					end
				end
			end

			if (owner.selfharming or owner.suiciding or owner.remUrgeEnd) and (org.depressionNextMinigamePhrase or 0) < CurTime() then
				org.depressionNextMinigamePhrase = CurTime() + math.Rand(depression_minigame_phrase_interval_min, depression_minigame_phrase_interval_max)
				owner:Notify(depression_minigame_phrases[math.random(#depression_minigame_phrases)], 3, "depression_minigame", 0)
			elseif not owner.selfharming and not owner.suiciding and not owner.remUrgeEnd then
				org.depressionNextMinigamePhrase = nil
			end
		end
	end

	if owner.selfharming then
		updateSelfHarm(owner, org)
	elseif owner:IsPlayer() then
		rollSelfHarm(owner, org)
		updatePending(owner, org)
	end
end

function hg.organism.AddDepression(org, amount)
	if not org then return 0 end
	if not isnumber(amount) or amount <= 0 then return org.depressionadd or 0 end

	org.depressionadd = Clamp((org.depressionadd or 0) + amount, 0, depression_max)

	return org.depressionadd
end

concommand.Add("selfharm", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if not ply.organism or ply.selfharming or ply.suiciding or ply.remUrgeEnd then return end
	if (ply.remUrgeCooldown or 0) > CurTime() then return end
	if ply.organism and (ply.organism.depression or 0) < 0.5 then
		if ply:GetInfoNum("hg_newthoughts", 0) > 0 then
			ply:Thought("You shouldnt do this.", 6, "depression_block_selfharm", 0)
		else
			ply:Notify("I shouldnt do this", 6, "depression_block_selfharm", 0)
		end
		return
	end

	if not hasSelfHarmWeapon(ply) then
		if not autoEquipSelfHarmWeapon(ply) then
			ply:ChatPrint("You need a weapon with SWEP.Canselfharm enabled to self harm.")
			return
		end
	end

	hg.organism.StartSelfHarm(ply)
end)

net.Receive("rem_selfharm_press", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local org = ply.organism
	if not org then return end
	if not org.selfharmWaveEnd or org.selfharmWaveEnd < CurTime() then return end

	org.selfharmPresses = (org.selfharmPresses or 0) + 1
end)
