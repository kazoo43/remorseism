local max, halfValue = math.max, util.halfValue
hg.organism.module.liver = {}
local module = hg.organism.module.liver
module[1] = function(org)
	org.liver = 0
end
module[2] = function(owner, org, mulTime)
	if not org.alive or org.hearstop then return end
end
local min, max, Clamp, Approach = math.min, math.max, math.Clamp, math.Approach
hg.organism.module.medical_system = {}
local module = hg.organism.module.medical_system
local rehab_phrases = {
	"My vision still feels unstable...",
	"I need a moment... still recovering.",
	"I'm awake, but not fully back yet.",
	"My body feels weak after blackout.",
	"I can't focus properly yet...",
	"Everything still feels heavy and slow.",
	"I should move carefully right now.",
	"I still feel dizzy after waking up.",
	"Not steady yet... need a few seconds.",
	"I'm conscious, but not recovered.",
}
local function get_role(ply)
	if not IsValid(ply) then return "none" end
	local role = string.lower(tostring(ply.Profession or ""))
	if role == "doctor" or role == "surgeon" or role == "medic" or role == "paramedic" then
		return role
	end
	return "none"
end
local function get_skill(role)
	if role == "surgeon" then return 1.0 end
	if role == "doctor" then return 0.9 end
	if role == "paramedic" then return 0.7 end
	if role == "medic" then return 0.65 end
	return 0.15
end
local function is_alive_org(org)
	return org and org.alive and IsValid(org.owner)
end
local limb_from_bone = {
	["ValveBiped.Bip01_L_UpperArm"] = "larm",
	["ValveBiped.Bip01_L_Forearm"] = "larm",
	["ValveBiped.Bip01_L_Hand"] = "larm",
	["ValveBiped.Bip01_R_UpperArm"] = "rarm",
	["ValveBiped.Bip01_R_Forearm"] = "rarm",
	["ValveBiped.Bip01_R_Hand"] = "rarm",
	["ValveBiped.Bip01_L_Thigh"] = "lleg",
	["ValveBiped.Bip01_L_Calf"] = "lleg",
	["ValveBiped.Bip01_L_Foot"] = "lleg",
	["ValveBiped.Bip01_R_Thigh"] = "rleg",
	["ValveBiped.Bip01_R_Calf"] = "rleg",
	["ValveBiped.Bip01_R_Foot"] = "rleg",
}
local function apply_med_error(actor, org, action, ctx)
	local role = get_role(actor)
	local skill = get_skill(role)
	local painPenalty = Clamp((actor.organism and actor.organism.pain or 0) / 180, 0, 0.5)
	local movePenalty = Clamp((IsValid(org.owner) and org.owner:GetVelocity():Length() or 0) / 350, 0, 0.4)
	local baseChance = 0.05
	if action == "needle" then baseChance = 0.18 end
	if action == "tourniquet" then baseChance = 0.12 end
	if action == "transfusion" then baseChance = 0.07 end
	if action == "internal_bleed_treat" then baseChance = 0.09 end
	if action == "bandage" then baseChance = 0.04 end
	local chance = baseChance * (1.15 - skill) + painPenalty + movePenalty
	if math.Rand(0, 1) > chance then return false end
	org.medical_errors = (org.medical_errors or 0) + 1
	if action == "needle" then
		if math.random(2) == 1 then
			org.lungsL[1] = min(org.lungsL[1] + 0.12, 1)
		else
			org.lungsR[1] = min(org.lungsR[1] + 0.12, 1)
		end
		org.pneumothorax = min((org.pneumothorax or 0) + 0.15, 1)
		org.shock = min((org.shock or 0) + 8, 95)
		org.owner:Notify("Something went wrong with the needle.", 6, "med_err_needle", 0)
	elseif action == "tourniquet" then
		local limb = ctx and ctx.bone and limb_from_bone[ctx.bone]
		if limb and org[limb] ~= nil then
			org[limb] = min(org[limb] + 0.08, 1)
		end
		org.painadd = min((org.painadd or 0) + 10, 150)
		org.shock = min((org.shock or 0) + 6, 95)
		org.owner:Notify("Tourniquet was applied badly.", 6, "med_err_tourniquet", 0)
	elseif action == "transfusion" then
		org.hemotransfusionshock = min((org.hemotransfusionshock or 0) + 0.2, 2)
		org.internalBleed = min((org.internalBleed or 0) + 0.15, 10)
		org.owner:Notify("Transfusion reaction feels wrong.", 6, "med_err_transfusion", 0)
	elseif action == "internal_bleed_treat" then
		org.analgesiaAdd = min((org.analgesiaAdd or 0) + 0.15, 4)
		org.consciousness = Approach(org.consciousness or 1, 0.65, 0.06)
		org.owner:Notify("Wrong dose, feeling dizzy...", 6, "med_err_dose", 0)
	elseif action == "bandage" then
		org.medical_infection = min((org.medical_infection or 0) + 0.2, 2)
		org.owner:Notify("Bandage wasn't clean enough.", 6, "med_err_bandage", 0)
	end
	if IsValid(actor) and actor ~= org.owner then
		actor:Notify("Complication occurred.", 4, "med_error_actor", 0)
	end
	return true
end
function hg.organism.GetMedicalRole(ply)
	return get_role(ply)
end
function hg.organism.ApplyMedicalAction(actor, target, action, ctx)
	if not IsValid(actor) or not IsValid(target) or not target.organism then return end
	local org = target.organism
	if not is_alive_org(org) then return end
	local role = get_role(actor)
	local skill = get_skill(role)
	if action == "bandage" and ctx and ctx.success then
		local bonus = 0.2 * skill
		org.painadd = max((org.painadd or 0) - bonus * 6, 0)
		org.fearadd = max((org.fearadd or 0) - bonus * 0.3, 0)
	end
	if action == "tourniquet" and ctx and ctx.success then
		org.shock = max((org.shock or 0) - 2 * skill, 0)
	end
	if action == "needle" and ctx and ctx.success then
		org.pneumothorax = max((org.pneumothorax or 0) - 0.05 * skill, 0)
		org.shock = max((org.shock or 0) - 1.5 * skill, 0)
	end
	if action == "transfusion" and ctx and ctx.amount and ctx.amount > 0 then
		org.hemotransfusionshock = max((org.hemotransfusionshock or 0) - (0.03 * skill), 0)
	end
	if action == "internal_bleed_treat" and ctx and ctx.success then
		org.internalBleedHeal = min((org.internalBleedHeal or 0) + 0.3 * skill, 20)
	end
	if (org.next_med_error_check or 0) > CurTime() then return end
	org.next_med_error_check = CurTime() + 0.6
	apply_med_error(actor, org, action, ctx)
end
module[1] = function(org)
	org.rehab_otrub = 0
	org.rehab_otrub_duration = 0
	org.medical_errors = 0
	org.medical_infection = 0
	org.next_med_error_check = 0
end
module[2] = function(owner, org, timeValue)
	if not org.alive then return end
	org.medical_infection = max((org.medical_infection or 0) - timeValue / 900, 0)
	if org.medical_infection > 0 then
		org.temperature = min((org.temperature or 36.7) + timeValue / 250 * org.medical_infection, 41)
		org.fearadd = min((org.fearadd or 0) + timeValue * 0.03 * org.medical_infection, 3)
	end
	local now = CurTime()
	if now < (org.rehab_otrub or 0) then
		local dur = max(org.rehab_otrub_duration or 1, 1)
		local remain = Clamp((org.rehab_otrub - now) / dur, 0, 1)
		org.disorientation = min((org.disorientation or 0) + timeValue * (0.8 + remain), 10)
		org.immobilization = min((org.immobilization or 0) + timeValue * (3 + 5 * remain), 80)
		org.stamina.subadd = (org.stamina.subadd or 0) + remain * 0.2
		if org.isPly and (org.next_rehab_phrase or 0) < now and remain > 0.25 then
			org.next_rehab_phrase = now + math.random(15, 26)
			owner:Notify(rehab_phrases[math.random(#rehab_phrases)], 5, "rehab_otrub", 0)
		end
	end
end
hook.Add("HG_OnWakeOtrub", "organism-rehab-after-otrub", function(owner)
	if not IsValid(owner) or not owner.organism then return end
	local org = owner.organism
	local bloodFactor = Clamp((3200 - (org.blood or 3200)) / 900, 0, 1)
	local brainFactor = Clamp((org.brain or 0) / 0.6, 0, 1)
	local painFactor = Clamp((org.pain or 0) / 120, 0, 1)
	local duration = 18 + (bloodFactor * 12) + (brainFactor * 10) + (painFactor * 8)
	local role = get_role(owner)
	if role == "doctor" or role == "surgeon" then
		duration = duration * 0.8
	end
	org.rehab_otrub_duration = duration
	org.rehab_otrub = CurTime() + duration
end)
