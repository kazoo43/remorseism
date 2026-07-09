if SERVER then
    util.AddNetworkString("headtrauma_concussion_update")
end
hg.organism.module.concussion = {}
local module = hg.organism.module.concussion
module[1] = function(org)
    org.concussion = 0
    org.concussion_effects = {
        severity = 0,
        duration = 0,
        last_impact = 0
    }
end
module[2] = function(ply, org, timeValue)
    if org.concussion > 0 then
        org.concussion = math.max(org.concussion - timeValue * 0.1, 0)
        if org.consciousness then
            local drainRate = 0.032 + (org.concussion_effects.severity * 0.02)
            org.consciousness = math.max(org.consciousness - (org.concussion * drainRate) * timeValue, 0)
        end
        if org.concussion > 1.5 then
            org.disorientation = math.max(org.disorientation or 0, org.concussion * 0.8)
        end
        if org.concussion > 2.5 then
            org.needfake = true
            org.immobilization = math.max(org.immobilization or 0, org.concussion * 10)
            if math.random() < org.concussion * 0.05 then
                org.nausea = math.max(org.nausea or 0, org.concussion * 2)
            end
        end
        if org.concussion_effects.duration > 0 then
            org.concussion_effects.duration = math.max(org.concussion_effects.duration - timeValue, 0)
            if org.concussion_effects.severity > 0.3 and (org.concussion_effects.last_impact or 0) < CurTime() - 2 then
                net.Start("headtrauma_concussion_update")
                    net.WriteFloat(org.concussion_effects.severity)
                    net.WriteFloat(org.concussion)
                net.Send(ply)
                org.concussion_effects.last_impact = CurTime()
            end
        end
    end
end
function module.AddConcussion(org, intensity, duration)
    if not org or not org.concussion then return end
    org.concussion = math.min(org.concussion + intensity, 5.0)
    org.concussion_effects.severity = math.max(org.concussion_effects.severity, intensity)
    org.concussion_effects.duration = math.max(org.concussion_effects.duration, duration or 10)
    if intensity > 2.0 then
        org.disorientation = math.max(org.disorientation or 0, intensity * 0.5)
        org.panic = math.max(org.panic or 0, intensity * 0.3)
    end
end
function module.HasConcussionSymptoms(org)
    return org and org.concussion and org.concussion > 0.5
end
function module.GetConcussionSeverity(org)
    if not org or not org.concussion then return 0 end
    if org.concussion < 1.0 then return "mild"
    elseif org.concussion < 2.5 then return "moderate"
    elseif org.concussion < 4.0 then return "severe"
    else return "critical" end
end
local min, max, Clamp, Approach = math.min, math.max, math.Clamp, math.Approach
hg.organism.module.trauma_combo = {}
local module = hg.organism.module.trauma_combo
module[1] = function(org)
	org.combo_hemohypoxia = 0
	org.combo_painhypovolemia = 0
	org.nextComboPhrase = 0
end
local combo_hemohypoxia_phrases = {
	"I can't breathe... and I'm freezing...",
	"I'm fading out...",
	"Everything is going dark..."
}
local combo_painhypovolemia_phrases = {
	"Too much pain... I can't move...",
	"I feel weak and dizzy...",
	"I might collapse..."
}
module[2] = function(owner, org, timeValue)
	if not org.alive then
		org.combo_hemohypoxia = 0
		org.combo_painhypovolemia = 0
		return
	end
	local o2 = org.o2 and org.o2[1] or 30
	local blood = org.blood or 5000
	local hemoPart = Clamp((2600 - blood) / 1100, 0, 1)
	local hypoPart = Clamp((14 - o2) / 10, 0, 1)
	local comboHemohypoxiaTarget = hemoPart * hypoPart
	org.combo_hemohypoxia = Approach(org.combo_hemohypoxia or 0, comboHemohypoxiaTarget, timeValue / 6)
	local painPart = Clamp((org.pain - 60) / 35, 0, 1)
	local hypoVolPart = Clamp((3300 - blood) / 1000, 0, 1)
	local comboPainHypovolemiaTarget = painPart * hypoVolPart
	org.combo_painhypovolemia = Approach(org.combo_painhypovolemia or 0, comboPainHypovolemiaTarget, timeValue / 6)
	local hemohypoxia = org.combo_hemohypoxia or 0
	if hemohypoxia > 0 then
		org.shock = min((org.shock or 0) + timeValue * 8 * hemohypoxia, 85)
		org.disorientation = min((org.disorientation or 0) + timeValue * 1.3 * hemohypoxia, 10)
		org.fearadd = min((org.fearadd or 0) + timeValue * 0.4 * hemohypoxia, 3)
		org.consciousness = Approach(org.consciousness or 1, max(0.05, 0.35 - hemohypoxia * 0.25), timeValue / 10 * hemohypoxia)
	end
	local painhypo = org.combo_painhypovolemia or 0
	if painhypo > 0 then
		org.immobilization = min((org.immobilization or 0) + timeValue * 12 * painhypo, 90)
		org.shock = min((org.shock or 0) + timeValue * 6 * painhypo, 90)
		org.fearadd = min((org.fearadd or 0) + timeValue * 0.25 * painhypo, 3)
		if org.stamina then
			org.stamina.subadd = (org.stamina.subadd or 0) + painhypo * 0.35
		end
	end
	if org.isPly and not org.otrub and (org.nextComboPhrase or 0) < CurTime() then
		if hemohypoxia > 0.5 then
			org.nextComboPhrase = CurTime() + math.random(14, 22)
			owner:Notify(combo_hemohypoxia_phrases[math.random(#combo_hemohypoxia_phrases)], 6, "combo_hemohypoxia", 0)
		elseif painhypo > 0.55 then
			org.nextComboPhrase = CurTime() + math.random(14, 22)
			owner:Notify(combo_painhypovolemia_phrases[math.random(#combo_painhypovolemia_phrases)], 6, "combo_painhypovolemia", 0)
		end
	end
end
