if SERVER then
    util.AddNetworkString("headtrauma_concussion_update")
end
hg.organism.module.concussion = {}
local module = hg.organism.module.concussion

local concussion_phrases = {
    "My head is ringing...",
    "Everything is spinning...",
    "I can't focus...",
    "I feel sick...",
    "What happened...?",
    "Everything is so loud...",
    "My ears are ringing...",
    "I can't think straight...",
    "The world is tilting...",
    "I'm so dizzy...",
    "My head hurts so much...",
    "Something's wrong with me...",
    "I can't hear properly...",
    "Everything's a blur...",
    "My skull is pounding...",
    "I feel like I'm gonna throw up...",
    "Where am I...?",
    "I can't keep my balance...",
    "My vision is shaking...",
    "It feels like my brain's rattling...",
    "I'm seeing double...",
    "The noise is killing me...",
    "I can't stand the light...",
    "My head's about to explode...",
    "Everything's muffled..."
}
local concussion_phrases_severe = {
    "I think I'm going to pass out...",
    "I can't see properly...",
    "Everything is blurred...",
    "I'm going to be sick...",
    "Make it stop...",
    "I can't breathe right...",
    "My head's splitting open...",
    "I'm falling... I'm falling...",
    "Everything's going black...",
    "I can't feel my legs...",
    "Please... somebody help...",
    "It hurts... it hurts so much...",
    "I'm losing consciousness...",
    "The ground won't stop moving...",
    "I can't tell up from down...",
    "My eyes won't focus...",
    "I think I'm dying...",
    "Everything's spinning too fast...",
    "I can't move my arms...",
    "Get this noise out of my head..."
}

module[1] = function(org)
    org.concussion = 0
    org.nausea = 0
    org.nextConcussionVomit = 0
    org.nextConcussionPhrase = 0
    org.concussion_tinnitus = 0
    org.concussion_effects = {
        severity = 0,
        duration = 0,
        last_impact = 0
    }
end

module[2] = function(ply, org, timeValue)
    if not org.concussion then org.concussion = 0 end
    if not org.nausea then org.nausea = 0 end
    if not org.concussion_tinnitus then org.concussion_tinnitus = 0 end
    if not org.concussion_effects then
        org.concussion_effects = {severity = 0, duration = 0, last_impact = 0}
    end
    if org.concussion <= 0 and org.nausea <= 0 then return end

    if org.concussion > 0 then
        local decayRate = 0.08 + (org.concussion > 3 and 0.04 or 0)
        org.concussion = math.max(org.concussion - timeValue * decayRate, 0)

        if org.consciousness then
            local drainRate = 0.032 + (org.concussion_effects.severity * 0.02)
            org.consciousness = math.max(org.consciousness - (org.concussion * drainRate) * timeValue, 0)
        end

        if org.concussion > 1.0 then
            org.disorientation = math.max(org.disorientation or 0, org.concussion * 0.6)
        end

        if org.concussion > 2.0 then
            org.needfake = true
            org.immobilization = math.max(org.immobilization or 0, org.concussion * 8)
        end

        if org.concussion > 1.5 then
            org.shock = math.min((org.shock or 0) + timeValue * 2 * org.concussion, 50)
            org.fearadd = math.min((org.fearadd or 0) + timeValue * 0.15 * org.concussion, 2)
        end

        if org.concussion > 0.5 and math.random() < org.concussion * 0.03 then
            org.nausea = math.max(org.nausea or 0, org.concussion * 1.5)
        end

        if org.concussion > 0.3 then
            org.concussion_tinnitus = math.max(org.concussion_tinnitus or 0, org.concussion * 0.4)
        end

        if org.concussion > 1.0 and org.isPly and not org.otrub and IsValid(ply) and ply:IsPlayer() and (org.nextConcussionPhrase or 0) < CurTime() then
            if org.concussion > 2.5 then
                ply:Notify(concussion_phrases_severe[math.random(#concussion_phrases_severe)], 5, "concussion_phrase", 0)
            else
                ply:Notify(concussion_phrases[math.random(#concussion_phrases)], 5, "concussion_phrase", 0)
            end
            org.nextConcussionPhrase = CurTime() + math.random(8, 18)
        end

        if org.concussion_effects.duration > 0 then
            org.concussion_effects.duration = math.max(org.concussion_effects.duration - timeValue, 0)
            if org.concussion_effects.severity > 0.3 and IsValid(ply) and ply:IsPlayer() and (org.concussion_effects.last_impact or 0) < CurTime() - 1.5 then
                net.Start("headtrauma_concussion_update")
                    net.WriteFloat(org.concussion_effects.severity)
                    net.WriteFloat(org.concussion)
                net.Send(ply)
                org.concussion_effects.last_impact = CurTime()
            end
        end
    end

    org.concussion_tinnitus = math.Approach(org.concussion_tinnitus or 0, 0, timeValue * 0.15)

    if (org.nausea or 0) > 0 then
        org.nausea = math.max(org.nausea - timeValue * 0.06, 0)

        if org.nausea > 1.5 and not org.otrub then
            local now = CurTime()
            if now > (org.nextConcussionVomit or 0) then
                local vomitDelay = math.Rand(6, 16) / math.Clamp(org.nausea, 0.5, 5)
                -- floor the interval so a maxed-out nausea can't trigger vomiting every second
                vomitDelay = math.max(vomitDelay, 4)
                org.nextConcussionVomit = now + vomitDelay
                hg.organism.VomitConcussion(ply)
            end
        end

        if org.nausea > 2.0 and not org.otrub then
            org.disorientation = math.max(org.disorientation or 0, org.nausea * 0.4)
        end
    end
end

function module.AddConcussion(org, intensity, duration)
    if not org then return end
    if not org.concussion then org.concussion = 0 end
    if not org.nausea then org.nausea = 0 end
    if not org.concussion_tinnitus then org.concussion_tinnitus = 0 end
    if not org.concussion_effects then
        org.concussion_effects = {severity = 0, duration = 0, last_impact = 0}
    end

    -- Prevent a flurry of weak hits (e.g. melee on a helmet) from linearly stacking
    -- into a maxed-out concussion + endless vomiting. Successive impacts that land
    -- very close together count far less, and the closer the brain already is to
    -- being fully rattled, the less each additional blow adds (diminishing returns).
    local now = CurTime()
    org.concussion_lastImpact = org.concussion_lastImpact or 0
    local sinceLast = now - org.concussion_lastImpact
    local rapidScale = math.Clamp(sinceLast / 1.5, 0.15, 1)
    org.concussion_lastImpact = now

    local headroom = math.Clamp((5.0 - org.concussion) / 5.0, 0, 1)
    local add = intensity * rapidScale * (0.35 + 0.65 * headroom)

    org.concussion = math.min(org.concussion + add, 5.0)
    org.concussion_effects.severity = math.max(org.concussion_effects.severity or 0, add)
    org.concussion_effects.duration = math.max(org.concussion_effects.duration or 0, duration or math.Clamp(intensity * 5, 5, 60))
    org.concussion_tinnitus = math.max(org.concussion_tinnitus or 0, add * 0.6)
    org.nausea = math.max(org.nausea or 0, add * 0.5)
    if add > 1.5 then
        org.disorientation = math.max(org.disorientation or 0, add * 0.5)
    end
    if add > 2.0 then
        org.panic = math.max(org.panic or 0, add * 0.3)
        org.needfake = true
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

if SERVER then
    concommand.Add("hg_concussion_test", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        local intensity = tonumber(args[1]) or 1.5
        local duration = tonumber(args[2]) or 15
        if not ply.organism then return end
        hg.organism.module.concussion.AddConcussion(ply.organism, intensity, duration)
        ply:Notify("Concussion: " .. math.Round(intensity, 2) .. " / " .. math.Round(duration, 1) .. "s", 5, "conc_test", 0)
    end)
end
