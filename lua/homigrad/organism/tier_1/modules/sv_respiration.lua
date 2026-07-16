local max, min, Round, Lerp, halfValue2 = math.max, math.min, math.Round, Lerp, util.halfValue2
hg.organism.module.lungs = {}
local module = hg.organism.module.lungs
module[1] = function(org)
	org.lungsL = {
		0,
		0
	}
	org.lungsR = {0, 0}
	org.trachea = 0
	org.pneumothorax = 0
	org.needle = 0
	org.nextCough = nil
	org.o2 = {
		range = 30,
		regen = 4,
		k = 0.5,
	}
	org.lungsfunction = true
	org.o2.curregen = org.o2.regen
	org.o2[1] = org.o2.range
	org.CO = 0
	org.COregen = 0
	org.lastCOBreathe = nil
	org.mannitol = 0
end
function hg.organism.OxygenateBlood(org)
	return (math.max(((1 - org.lungsL[1]) + (1 - org.lungsR[1])) / 2, 0.5) * (1 - org.trachea)) * org.o2.regen / 4 * (org.owner:WaterLevel() < 3 and 1 or 0)
end
function hg.organism.CanBreath(org)
	return org.o2 and org.o2.curregen >= org.losing_oxy
end
local function insta_send_holdingbreath(org)
	net.Start("organism_send")
	local tbl = {}
	tbl.holdingbreath = org.holdingbreath
	tbl.owner = org.owner
	net.WriteTable(tbl)
	net.WriteBool(true)
	net.WriteBool(false)
	net.WriteBool(false)
	net.WriteBool(true)
	net.Send(org.owner)
end
local function togglebreath(ply, toggle)
	local org = ply.organism
	if isbool(toggle) then
		if toggle then
			if not ply.organism.holdingbreath then
				ply.organism.holdingbreath = true
				ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav",65)
				insta_send_holdingbreath(ply.organism)
			end
		else
			if ply.organism.holdingbreath then
				ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/exhale/female/exhale_0"..math.random(5)..".wav" or "breathing/exhale/male/exhale_0"..math.random(5)..".wav",65)
				ply.organism.holdingbreath = false
				ply.releasebreathe = nil
				insta_send_holdingbreath(ply.organism)
			end
		end
	else
		if ply.organism.holdingbreath then
			ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/exhale/female/exhale_0"..math.random(5)..".wav" or "breathing/exhale/male/exhale_0"..math.random(5)..".wav",65)
			ply.organism.holdingbreath = false
			ply.releasebreathe = nil
			insta_send_holdingbreath(ply.organism)
		else
			ply.organism.holdingbreath = true
			ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav",65)
			insta_send_holdingbreath(ply.organism)
		end
	end
	local ent = hg.GetCurrentCharacter(ply)
	ent:StopSound(ply.lastPhr or "")
	ply.phrCld = 0
end
concommand.Add("hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if not ply:Alive() then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end
	if (ply.cooldownbreathe or 0) > CurTime() then return end
	ply.cooldownbreathe = CurTime() + 0.5
	togglebreath(ply)
end)
concommand.Add("+hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if not ply:Alive() then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end
	if (ply.cooldownbreathe or 0) > CurTime() then return end
	ply.cooldownbreathe = CurTime() + 0.5
	togglebreath(ply,true)
end)
concommand.Add("-hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end
	if (ply.cooldownbreathe or 0) > CurTime() then ply.releasebreathe = ply.cooldownbreathe return end
	togglebreath(ply,false)
end)
local lowoxy = {
	"I'm gonna faint right now... There's not enough oxygen.",
	"There's not enough oxygen... I can't hold much longer...",
	"I really need some fresh air...",
	"I'm gasping for air...",
	"Need to breathe air... or I'm gonna faint right here..."
}
local lowoxy_critical = {
	"Can't... breathe...",
	"Air... please...",
	"I'm suffocating...",
	"Help... I can't...",
	"Everything's... going dark..."
}
local hypoxia_symptoms = {
	"My head is spinning... I need air...",
	"I feel lightheaded...",
	"Everything's getting fuzzy...",
	"I can't think straight... need oxygen...",
	"My fingers are tingling..."
}
local not_enough_intake = {
	"I need to breathe...",
	"I'm struggling to breathe...",
}
local drop_mask = {
	"I can't breathe in this mask... I need to take it off.",
	"Drop the mask, it's not worth it...",
	"It's fucking disgusting... and I surely can't breathe in this...",
	"Fucking stinks... Gotta take this mask off...",
}
local pneumothorax_phrases = {
	"I can feel something filling my lungs.",
	"It's getting harder to breathe.",
	"I'm really struggling to breathe.",
	"My chest feels tight... something's wrong.",
	"Every breath hurts...",
	"I can't get enough air in..."
}
local choking_phrases = {
	"I'm choking!",
	"Can't... breathe... something's stuck...",
	"I can't get air in!",
	"Help me... I'm choking!"
}
local drugged = {
	"Ohhh hohoohoooo Ie-like it.....",
	"Fukkenh awesomee..... ffffeeelin gooooood..",
	"That's theh sStuffff DUDeeee",
	"I reallly like whatEvER I'm feeling right now....",
	"Oh yeahhhh this feels gooood!",
	"I want to feel likhe this for theRRRREST of my life",
	"Why am I here even?.. wWhatever whuhhh heh",
	"Whoa re you? Gett outtaheree...",
	"Don't want anything else... this is pERRRfect!..",
}
local hunger_phrases = {
	"My stomach is growling...",
	"I need to eat something...",
	"Haven't eaten in a while...",
	"I'm getting hungry...",
	"Need to find some food..."
}
local starvation_phrases = {
	"I'm starving... I need food...",
	"My body is eating itself...",
	"I feel so weak from hunger...",
	"Can't... think... need calories...",
	"I'm dying of hunger..."
}
local starvation_critical = {
	"Can't... move... no energy...",
	"Everything's... fading...",
	"So... hungry...",
	"I can't... hold on..."
}
local bit_band,util_PointContents = bit.band,util.PointContents
local color_white, color_red, color_red2, color_red3 = Color(255, 255, 255), Color(255, 0, 0), Color(200, 55, 55), Color(255, 100, 100)
module[2] = function(owner, org, timeValue)
	local o2 = org.o2
	local losing_oxy = timeValue * 1 * math.Clamp(org.o2[1] / 30, 0.25, 1)
	org.losing_oxy = losing_oxy
	o2[1] = max(o2[1] - losing_oxy, 0)
	local ent = hg.GetCurrentCharacter(owner)
	local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
	if (not bone) or (bone < 0) then bone = 6 end
	local head = ent:GetBonePosition(bone)
	if not head then
		head = ent:GetBonePosition(0)
	end
	if org.o2.curregen == 0 and org.holdingbreath then
		togglebreath(owner, false)
	end
	if org.holdingbreath then
		if org.stamina[1] < 90 or org.o2[1] <= 10 then
			togglebreath(owner, false)
		end
		if owner.releasebreathe and owner.releasebreathe < CurTime() then
			togglebreath(owner, false)
			owner.releasebreathe = nil
		end
	end
	if not head then head = owner:GetPos() end
	local inwater = bit_band(util_PointContents(head),CONTENTS_WATER) == CONTENTS_WATER
	local success = owner:IsBerserk() or (not org.heartstop and org.alive and not (org.brain >= 0.4 and math.random(10 - (org.brain * 10)) < 4) and org.lungsfunction)
	if success and owner:IsPlayer() and inwater then success = false end
	if success and org.choking then org.needfake = true success = false end
	if success and org.vomitInThroat then success = false end
	org.choking = false
	local pneumothorax = (org.lungsR[2] == 1 or org.lungsL[2] == 1) and org.needle == 0
	org.needle = math.Approach(org.needle, 0, timeValue / 1200)
	org.pneumothorax = pneumothorax and min(org.pneumothorax + timeValue / 180 * (org.lungsL[2] + org.lungsR[2]), (org.lungsL[2] + org.lungsR[2]) / 2) or max(org.pneumothorax - timeValue / 10, 0)
	if org.lastCOBreathe and org.lastCOBreathe + 1 > CurTime() then
		org.COregen = math.Approach(org.COregen, 30, timeValue * 1)
	else
		org.COregen = math.Approach(org.COregen, 0, timeValue * 0.5)
	end
	org.CO = max(org.CO - timeValue, 0)
	if success then
		local oxygenate = hg.organism.OxygenateBlood(org) * 0.5
		local lerp = min(max(org.pulse - 20, 0) / 20, 1)
		local regen = Lerp(lerp, 0, o2.regen * oxygenate * math.Rand(0.95, 1.05))
		org.CO = min(org.CO + (org.COregen > 0 and timeValue * 1.5 or 0), 30)
		org.consciousness = math.min(org.consciousness, (30 - org.CO) / 30)
		local mask_blevota = owner:GetNetVar("zableval_masku", false)
		local sprayed = org.is_sprayed_at
		org.is_sprayed_at = nil
		local regenerate = regen * timeValue * 4 * (org.stamina[1] / org.stamina.max) * (mask_blevota and 0 or 1) * ((org.temperature > 38) and math.Clamp(math.Remap(org.temperature, 38, 41, 1, 0.1), 0.1, 1) or 1)
		o2[1] = min(o2[1] + regenerate * math.Clamp(org.o2[1] / 30, 0.25, 1) * (org.holdingbreath and 0 or 1) * (sprayed and 0 or 1) * min((10 / max(org.CO,1)),1), o2.range * math.max(1 - org.pneumothorax * org.pneumothorax, 0.1) * math.min(org.blood / 4500, 1) * math.max(1 - (org.lungsL[1] + org.lungsR[1]) / 2, 0.5))
		o2.curregen = regenerate
		o2[1] = max(o2[1] - (org.CO > 0 and o2.curregen * 1.1 * (org.CO / 30) or 0),0)
	else
		o2.curregen = 0
	end
	if owner:IsBerserk() then
		o2[1] = math.max(5, o2[1])
	end
	if org.isPly and not org.otrub and o2.curregen < losing_oxy and org.analgesia <= 1.5 and !org.heartstop then
		if mask_blevota then
			if o2[1] < 15 then
				org.owner:Notify("DROP THE FUCKING MASK", 25, "take_gasmask2", 0, nil, color_red2)
			else
				org.owner:Notify(drop_mask[math.random(#drop_mask)], 15, "take_gasmask", 0)
			end
		else
			if o2[1] < 25 and o2[1] > 12 then
				org.owner:Notify(not_enough_intake[math.random(#not_enough_intake)], 61, "oxygen_lowintake", 0)
			end
		end
		if o2[1] < 12 then
			org.owner:Notify(lowoxy[math.random(#lowoxy)], 30, "lowoxy", 0, nil, color_red3)
			if o2[1] < 6 then
				org.owner:Notify(lowoxy_critical[math.random(#lowoxy_critical)], 30, "lowoxy2", 0, nil, color_red)
			end
		end
		if o2[1] < 20 and o2[1] > 10 then
			if not org.nextHypoxiaPhrase or org.nextHypoxiaPhrase < CurTime() then
				org.owner:Notify(hypoxia_symptoms[math.random(#hypoxia_symptoms)], 15, "hypoxia_symptoms", 0)
				org.nextHypoxiaPhrase = CurTime() + math.Rand(20, 35)
			end
		end
	end
	if org.analgesia > 1.5 then
		org.owner:Notify(drugged[math.random(#drugged)], 30, "drugged", 0, nil, color_white)
	end
	if org.analgesia > 1.5 or org.painkiller > 2.4 then
		if math.Rand(0, 500) < (org.analgesia + org.painkiller) then
		end
	end
	if o2[1] == 0 then
		if math.random(50) == 1 then
			org.lungsfunction = false
		end
	else
		if math.random(50) == 1 then
			org.lungsfunction = true
		end
	end
	if (org.lungsL[1] == 1 and org.lungsR[1] == 1) or org.heartstop then
		org.lungsfunction = false
	end
	if org.isPly then
		if org.pneumothorax > 0 then
			org.owner:Notify(pneumothorax_phrases[1], true, "pneumothorax1",10)
		else
			org.owner:ResetNotification("pneumothorax1")
		end
		if org.pneumothorax > 0.3 then
			org.owner:Notify(pneumothorax_phrases[2], true, "pneumothorax2", 5)
		else
			org.owner:ResetNotification("pneumothorax2")
		end
		if org.pneumothorax > 0.5 then
			org.owner:Notify(pneumothorax_phrases[3], true, "pneumothorax3", 5)
		else
			org.owner:ResetNotification("pneumothorax3")
		end
	end
	local k = halfValue2(o2[1], o2.range, o2.k)
	if o2[1] < 10 then
		if org.isPly then
			hg.StunPlayer(owner, 3)
		end
	end
	if o2[1] < 12 then
		org.needfake = true
		if org.isPly then
			hg.LightStunPlayer(owner, 3)
		end
	end
	if o2[1] < 4 then
		org.needotrub = true
	end
	if org.lungsR[1] < 0.5 then
	end
	if org.lungsL[1] < 0.5 then
	end
	if owner:IsBerserk() then
		org.brain = math.min(0.5, org.brain)
	end
	if org.skull >= 0.6 then k = 0 end
	if org.brain >= 0.6 then k = 0 end

	local frontal = org.brainFrontal or 0
	local parietal = org.brainParietal or 0
	local temporal = org.brainTemporal or 0
	local occipital = org.brainOccipital or 0
	local hemorrhage = org.brainHemorrhage or 0
	local bleedRate = org.brainBleedRate or 0

	org.disorientation = math.max(org.disorientation, frontal * 0.35 + parietal * 0.65 + temporal * 0.25)
	org.immobilization = math.max(org.immobilization, parietal * 8)
	org.consciousness = math.min(org.consciousness, 1 - frontal * 0.35 - temporal * 0.15)
	if hemorrhage > 0 then
		org.brain = min(org.brain + timeValue * hemorrhage / (hemorrhage < 0.3 and 900 or 300), 1)
		org.disorientation = math.max(org.disorientation, hemorrhage * 0.9)
		org.consciousness = math.min(org.consciousness, 1 - hemorrhage * 0.45)
		org.painadd = math.max(org.painadd, hemorrhage * 25)
	end

	if hg.organism.AddSeizure and temporal > 0.2 then
		hg.organism.AddSeizure(org, timeValue * temporal / 1200)
	end

	if bleedRate > 0 then
		org.brainHemorrhage = min(hemorrhage + timeValue * bleedRate * 0.4, 1)
		org.brain = min(org.brain + timeValue * bleedRate * (1 + hemorrhage), 1)
		org.brainBleedRate = max(bleedRate - timeValue / 600000, 0)
	end

	if occipital > 0.35 then
		org.disorientation = math.max(org.disorientation, occipital * 0.4)
	end

	if org.skull < 1 and org.skull >= 0.5 and org.bandagedskull then
		org.skull = math.Approach(org.skull, 0, timeValue / 600)
	end

        if org.brain >= 0.5 then
		if org.brain >= 0.5 then
			if math.random(60) == 1 then
				org.heartstop = true
			end
		end
		if org.brain > 0.35 and !org.heartstop then
			if math.random(60) == 1 then
				org.lungsfunction = true
			end
		end
		org.needotrub = true
	end
	local death_from_braindamage = false
	if org.brain >= 0.7 and org.alive then
		death_from_braindamage = true
		org.alive = false
	end

	if org.isPly then
		if org.brain > 0.1 and org.brain < 0.3 then
			org.owner:Notify(math.random(2) == 1 and "My head hurts..." or "Where am I?", true, "brain", 5)
		else
			org.owner:ResetNotification("brain")
		end
	end
	org.brain = max(org.brain - timeValue / 400 * ((org.mannitol > 0 and org.brain < 0.6) and 1 or (org.brain > 0.1 and 0.1 or 0)), 0)
	org.mannitol = math.Approach(org.mannitol, 0, timeValue / 200)
	if k < 0.25 then
		if not org.alive and owner:IsPlayer() and death_from_braindamage and org.o2[1] == 0 then
			hg.achievements.AddPlayerAchievement(owner,"brain",1)
			if org.analgesia > 1 then
				hg.achievements.AddPlayerAchievement(owner,"drugs",1)
			end
		end
		org.brain = min(org.brain + timeValue / (org.brain < 0.3 and 300 or 120) * math.min(((org.o2[1] < 0.25 and 1 or 0) + (org.brainHemorrhage or 0)), 1), 1)
	end
end
local hg_hungersystem = CreateConVar("hg_hungersystem", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Enables/disabled hunger system", 0, 1)
local max, min, Round, Lerp, halfValue2 = math.max, math.min, math.Round, Lerp, util.halfValue2
hg.organism.module.metabolism = {}
local module = hg.organism.module.metabolism
module[1] = function(org)
	org.satiety = 0
    org.hungry = 0
    org.hungryDmgCd = 0
end
local colorRed = Color(125,25,25)
module[2] = function(owner, org, timeValue)
    if org.satiety <= 0 and hg_hungersystem:GetBool() then
        org.hungry = min(max(org.hungry + timeValue * 0.01, 0),100)
        org.hungryDmgCd = org.hungryDmgCd or 0
        if org.alive and org.hungryDmgCd < CurTime() and org.hungry > 45 then
            org.painadd = org.painadd + 25 * (org.hungry/45)
            org.hungryDmgCd = CurTime() + (math.random(40,55) - (org.hungry/5.5))
            if org.hungry > 80 then
                org.stomach = math.min(org.stomach + 0.1,1)
                if org.stomach > 0.85 and org.heart < 0.3 then
                    org.heart = org.heart + 0.1
                end
                if org.heart > 0.3 then
                    org.o2.regen = 0
                end
            end
        end
    else
        org.hungry = min(max(org.hungry - timeValue * 2, 0),100)
    end
    org.hungry = Round(org.hungry or 0,3)
    if (org.intestines > 0.5 or org.stomach > 0.5) and not org.otrub and owner:IsPlayer() and org.satiety > 1 then
        if not org.randomPainSound or org.randomPainSound < CurTime() then
            org.randomPainSound = CurTime() + math.random(20,45)
            owner:EmitSound("zcitysnd/"..(ThatPlyIsFemale(owner) and "female" or "male").."/pain_"..math.random(1,8)..".mp3")
            org.painadd = org.painadd + 20
        end
    end
    if org.satiety == 0 then return end
    org.satiety = min(max(org.satiety - timeValue * 0.5, 0), 100)
    org.blood = min(org.blood + timeValue * (org.satiety/10) , 5000)
    org.regeneratehp = (!((org.regeneratehp or 0) >= 1) and min( (org.regeneratehp or 0) + timeValue * (org.satiety/100), 1)) or 0
    owner:SetHealth(min(owner:Health() + org.regeneratehp,100))

    if org.isPly and not org.otrub and org.hungry > 0 then
        if org.hungry > 30 and org.hungry <= 60 then
            if not org.nextHungerPhrase or org.nextHungerPhrase < CurTime() then
                owner:Notify(hunger_phrases[math.random(#hunger_phrases)], 12, "hunger_mild", 0)
                org.nextHungerPhrase = CurTime() + math.Rand(30, 50)
            end
        elseif org.hungry > 60 and org.hungry <= 80 then
            if not org.nextHungerPhrase or org.nextHungerPhrase < CurTime() then
                owner:Notify(starvation_phrases[math.random(#starvation_phrases)], 12, "starvation_moderate", 0)
                org.nextHungerPhrase = CurTime() + math.Rand(20, 35)
            end
        elseif org.hungry > 80 then
            if not org.nextHungerPhrase or org.nextHungerPhrase < CurTime() then
                owner:Notify(starvation_critical[math.random(#starvation_critical)], 12, "starvation_critical", 0)
                org.nextHungerPhrase = CurTime() + math.Rand(12, 22)
            end
        end
    end
end
