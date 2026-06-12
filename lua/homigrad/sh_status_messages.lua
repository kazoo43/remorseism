
local allowedchars = {
	"ah",
	"AH",
	"ghh",
	"GH",
	"AHHH",
}

local audible_pain = {
	"You are experiencing excruciating pain.",
	"You are in severe pain."
}

local sharp_pain = {
	"You are in agony."
}

hg.sharp_pain = sharp_pain

local random_phrase = {
	"It's kinda chilly in here...",
	"Everything seems too quiet...",
	"Breathing feels oddly satisfying right now.",
	"What if this quiet lasts forever?",
	"Why isn't anything happening?",
}

local fear_hurt_ironic = {
	"I bet there's a lesson in this... if I survive.",
	"My future biographer won't believe this part.",
	"Well, this is a stupid way to go.",
	"At least my life wasn't boring.",
	"Note to self: Never do this again.",
	"This isn't the worst day to die.",
}

local fear_phrases = {
	"It's not that bad... right?",
	"I don't want to die like this.",
	"Is this really how it ends?",
	"This isn't good.",
	"Is this really how it ends?",
	"I don't want to die like this.",
	"I wish I had a way out.",
	"I regret so many things.",
	"This can't be it.",
	"I can't believe this is happening to me.",
	"I should've taken this more seriously.",
	"What if I don't make it..?",
	"This is worse than I thought.",
	"This is so unfair.",
	"I can't give up yet.",
	"I never thought it would be like this.",
	"I should've listened to my instincts.",
	"Breathe. Just breathe.",
	"Cold hands. Steady hands.",
}

local is_aimed_at_phrases = {
    "Oh God. This is it.",
    "Don't. move.",
    "Is this really how I die?",
    "I should've run. Why didn't I run?",
    "Please don't pull the trigger. Please.",
    "I can see their finger on the trigger.",
    "I don't want to die. Not like this.",
    "If I beg, will it make it worse?",
    "This can't be real. This can't be real.",
    "Someone help me. Please. Someone.",
    "I don't want to die in a place like this.",
    "I don't want my last thought to be fear.",
    "I don't want to die.",
}

local near_death_poetic = {
	"You are losing blood.",
	"Your condition is critical.",
	"You are close to blacking out.",
}

local near_death_positive = {
	"I don't want to die.",
	"I have to survive.",
	"There's still a chance.",
	"I can't let fear win.",
	"Just one more try.",
	"I refuse to die here.",
	"Alright... think this through.",
	"Just stay still. Moving makes it worse.",
	"Breathe slow. Panic won't help.",
	"It's not over until it's over.",
	"Pain is just a signal. Ignore it.",
	"If this is it... at least it's gonna be quick.",
	"I've survived worse. Probably.",
	"This isn't how I pictured it.",
}

local function get_broken_limb_message(org)
	if org.rarm == 1 then return "Your right arm is broken." end
	if org.larm == 1 then return "Your left arm is broken." end
	if org.rleg == 1 then return "Your right leg is broken." end
	if org.lleg == 1 then return "Your left leg is broken." end
end

local function get_dislocated_limb_message(org)
	if org.rarmdislocation or org.rarm == 0.5 then return "Your right arm is dislocated." end
	if org.larmdislocation or org.larm == 0.5 then return "Your left arm is dislocated." end
	if org.rlegdislocation or org.rleg == 0.5 then return "Your right leg is dislocated." end
	if org.llegdislocation or org.lleg == 0.5 then return "Your left leg is dislocated." end
end

local hungry_a_bit = {
    "Mgh, I'm hungry...",
    "Some food would be great...",
    "I'm hungry...",
    "I should eat something.",
}

local very_hungry = {
    "My stomach... Ugh...",
    "If I don't eat, I'll feel even worse...",
    "Stomach... Damn it... I feel sick",
}

local after_unconscious = {
    "You are awake.",
	"You regain consciousness.",
	"You wake up.",
}

local slight_braindamage_phraselist = {
	"Reality becomes a myth.",
	"You suffer a traumatic brain injury.",
}

local braindamage_phraselist = {
	"Bbbee.. wheea mgh?!",
	"Bmmeee... mehk...",
	"Mm--hhhh. Mmm?",
	"Ghmgh whhh...",
	"Ahgg...mg?",
	"Hgghh... D-Dmmh.",
	"Lmmmphf, mp-hf!",
	"Heeelllhhpphp...",
	"Nghh... Gmh?",
	"Ggg... Bgh..",
	"Bhrhraihin.",
}

local cold_phraselist = {
	"It's getting very cold..",
	"Too cold for me.",
	"I'm shivering, fucking hell, man.",
	"Extremely chilly out here..",
	"Need something to heat up...",
	"I feel pretty cold...",
	"I feel sick from that cold, fuck."
}

local freezing_phraselist = {
	"I.. ca.. can't feel m-my b-body..",
	"I can't.. f-feel my legs...",
	"I'm f-fuck-king fre-ezing..",
	"I-I think-k my face is num-mb..",
	"Cold-d..",
	"I.. can't feel any-ythi-ing..",
}

local numb_phraselist = {
	"It's not.. cold anymore..",
	"Why... does it feel warm..?",
	"I think I'm okay... I think...",
	"Finally some warmth...",
	"I'm warm again... Somehow...",
	"I was just freezing... Where did this heat come from..?",
}

local hot_phraselist = {
	"I'm so sweaty..",
	"This heat is killing me..",
	"My clothing is covered in sweat, fuck.",
	"My sweat fucking reeks. I should really cool down...",
	"It's a bit too hot, fuck, man.",
	"I'm heating up real bad...",
	"Why is it so hot in here?",
}

local heatstroke_phraselist = {
	"I NEED WATER!!",
	"Please... water...",
	"I feel dizzy... Fuuck-",
	"MY HEAD!- It hurts..",
	"My head is aching..",
}

local heatvomit_phraselist = {
	"That heat..- I'm gonna vomit-",
	"Ugghhh... I'm about to puke-",
	"Fuuck.. Oughhh.. I don't feel-"
}

local hg_showthoughts = ConVarExists("hg_showthoughts") and GetConVar("hg_showthoughts") or CreateClientConVar("hg_showthoughts", "1", true, true, "Toggle thoughts of your character", 0, 1)

function string.Random(length)
	local length = tonumber(length)

    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = allowedchars[math.random(#allowedchars)]
    end

    return table.concat(result)
end

function hg.nothing_happening(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear < -0.6
end

function hg.fearful(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear > 0.5
end

function hg.likely_to_phrase(ply)
	local org = ply.organism

	local pain = org.pain
	local brain = org.brain
	local blood = org.blood
	local fear = org.fear
	local temperature = org.temperature
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone - CurTime()) < -3)

	return (broken_dislocated) and 5
		or (pain > 65) and 5
		or (temperature < 31 and 0.5)
		or (temperature > 38 and 0.5)
		or (blood < 3000 and 0.3)
		--or (fear > 0.5 and 0.7)
		or (brain > 0.1 and brain * 5)
		or (fear < -0.5 and 0.05)
		or -0.1
end

function IsAimedAt(ply)
    return ply.aimed_at or 0
end

local function pick_message(org, list, key)
	if not istable(list) or #list == 0 then return "" end

	local index = math.random(#list)
	local last = org[key]

	if #list > 1 and list[index] == last then
		index = index % #list + 1
	end

	local msg = list[index]
	org[key] = msg

	return msg
end

local function reset_pain_message_state(org)
	org.pain_message_state = nil
	org.pain_message_locked = nil
end

local function get_pain_message_pool()
	local pool = {}

	for _, msg in ipairs(audible_pain) do
		pool[#pool + 1] = msg
	end

	for _, msg in ipairs(sharp_pain) do
		local exists = false

		for _, old in ipairs(pool) do
			if old == msg then
				exists = true
				break
			end
		end

		if not exists then
			pool[#pool + 1] = msg
		end
	end

	return pool
end

local function pick_pain_message(org)
	local list = get_pain_message_pool()
	if #list == 0 then return "" end

	if org.pain_message_locked then return "" end

	local state = org.pain_message_state

	if not istable(state) or state.count != #list then
		state = {
			index = 1,
			repeats = 0,
			count = #list,
			exhausted = false
		}

		org.pain_message_state = state
	end

	if state.exhausted then
		org.pain_message_locked = true
		return ""
	end

	local msg = list[state.index]

	state.repeats = state.repeats + 1

	if state.repeats >= 2 then
		state.repeats = 0
		state.index = state.index + 1

		if state.index > #list then
			state.exhausted = true
			org.pain_message_locked = true
		end
	end

	return msg
end

local function get_status_message(ply)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end

	local nomessage = hook.Run("HG_CanThoughts", ply) --ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"
	if nomessage ~= nil and nomessage == false then return "" end

    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism
	
	if not org or not org.brain then return "" end

	local pain = org.pain
	local brain = org.brain
	local temperature = org.temperature
	local blood = org.blood
	local hungry = org.hungry
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone + 3 - CurTime()) < -3)

	if pain < 30 then
		reset_pain_message_state(org)
	end

	if broken_dislocated and org.just_damaged_bone then
		org.just_damaged_bone = nil
	end
	
	local broken_limb_message = get_broken_limb_message(org)
	local dislocated_limb_message = get_dislocated_limb_message(org)
	local broken_notify = broken_limb_message != nil
	local dislocated_notify = dislocated_limb_message != nil
	local after_unconscious_notify = org.after_otrub

	if not isnumber(pain) then return "" end

	local str = ""

	local most_wanted_phraselist
	
	if temperature < 35 then
		most_wanted_phraselist = temperature > 31 and cold_phraselist or (temperature < 28 and numb_phraselist or freezing_phraselist)
	elseif temperature > 38 then
		most_wanted_phraselist = temperature < 40 and hot_phraselist or heatstroke_phraselist
	end

	if not most_wanted_phraselist and hungry and hungry > 25 and math.random(3) == 1 then
		most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
	end

	if (blood < 3100) or (pain > 75) or (broken_dislocated) or (broken_notify) or (dislocated_notify) then
		if pain > 75 and (broken_dislocated) then
			most_wanted_phraselist = math.random(2) == 1 and audible_pain or {broken_notify and broken_limb_message or dislocated_limb_message}
		elseif pain > 75 then
			most_wanted_phraselist = audible_pain
		elseif broken_dislocated then
			most_wanted_phraselist = {broken_notify and broken_limb_message or dislocated_limb_message}
		end

		if pain > 100 then
			most_wanted_phraselist = sharp_pain
		end

		if not most_wanted_phraselist then
			if (broken_notify or dislocated_notify) and (blood < 3100) then
				most_wanted_phraselist = blood < 2900 and (near_death_poetic) or (math.random(2) == 1 and {broken_notify and broken_limb_message or dislocated_limb_message} or near_death_poetic)
			--elseif(broken_dislocated_notify)then
				--most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
			elseif(blood < 3100)then
				most_wanted_phraselist = near_death_poetic
			end
		end
	elseif after_unconscious_notify then
		most_wanted_phraselist = after_unconscious
	elseif hg.nothing_happening(ply) then
		most_wanted_phraselist = random_phrase

		if hungry and hungry > 25 and math.random(5) == 1 then
			most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
		end
	elseif hg.fearful(ply) then
		most_wanted_phraselist = ((IsAimedAt(ply) > 0.9) and is_aimed_at_phrases or (math.random(10) == 1 and fear_hurt_ironic or fear_phrases))
	end

	if brain > 0.1 then
		most_wanted_phraselist = brain < 0.2 and slight_braindamage_phraselist or braindamage_phraselist
	end
	
	if most_wanted_phraselist then
		if most_wanted_phraselist == sharp_pain then
			str = pick_pain_message(org)
		elseif most_wanted_phraselist == audible_pain then
			str = pick_pain_message(org)
		else
			str = pick_message(org, most_wanted_phraselist, "last_status_message")
		end

		return str
	else
		return ""
	end
end

local allowedlist_types = {
	heatvomit = heatvomit_phraselist,
}

function hg.get_phraselist(ply, type)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end
	
	local nomessage = ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"

	if nomessage then return "" end
    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism	
	if not org or not org.brain then return "" end

	if not isstring(type) or not allowedlist_types[type] then return "" end

	local needed_list = allowedlist_types[type]

	local str = pick_message(org, needed_list, "last_typed_phraselist")
	return str
end

function hg.get_status_message(ply)
	local txt = get_status_message(ply)

	return txt
end

function hg.get_status_message_notify_key(ply)
	if not IsValid(ply) or not ply.organism then return "phrase" end

	local org = ply.organism

	if org.brain > 0.1 then return "phrase_brain" end
	if org.pain > 75 then return "phrase_pain" end

	return "phrase"
end

function hg.get_status_message_notify_delay(ply)
	if not IsValid(ply) or not ply.organism then return 1 end

	local org = ply.organism

	if org.brain > 0.1 then return 2.5 end
	if org.pain > 75 then return 4 end

	return 1
end
