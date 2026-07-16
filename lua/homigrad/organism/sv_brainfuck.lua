local CurTime, IsValid = CurTime, IsValid
local math_min, math_max, math_clamp, math_rand, math_random, math_sin = math.min, math.max, math.Clamp, math.Rand, math.random, math.sin
local VectorRand = VectorRand

hook.Remove("Should Fake Up", "BrainfuckFencing")
hook.Remove("Fake", "BrainfuckFencing")
hook.Remove("HG_OnOtrub", "BrainfuckFencing")
hook.Remove("RagdollDeath", "BrainfuckStart")
hook.Remove("Org Clear", "BrainfuckClear")
hook.Remove("HomigradDamage", "DecorticateTrigger")
hook.Remove("HomigradDamage", "BrainfuckFencing")

hg.applyFencingToPlayer = nil
hg.applyDecorticateToPlayer = nil
hg.applyLazarusToPlayer = nil
hg.applyCushingToPlayer = nil

local CHANCE, FORCE, VIBRATION = 0, 1200, 150
local extendDur, rigorDur, flexionDur = {4, 10}, {10, 20}, {6, 12}
local RIGOR_DAMP, FLEXION_FORCE = 8, 400
local DECORTICATE_START, DECEREBRATE_START = 0.2, 0.7
local POSTURE_DEATH_FADE = 8
local FENCING_DURATION, FENCING_FADE, FENCING_RECENT_DAMAGE = 3.8, 0.35, 1.5
local FENCING_HEAVY_DURATION, FENCING_HEAVY_FORCE = 0.18, 35
local POSTURE_SHAKE_REFRESH = {0.08, 0.36}
local FENCING_FORCE_MUL, FENCING_DAMP_MUL = 1, 1
local POSTURE_FADE_IN, POSTURE_FADE_OUT = {0.35, 0.75}, 2.5
local POSTURE_FORCE_MUL, POSTURE_DAMP_MUL = 1, 1

util.AddNetworkString("hg_brainfuck_posture_maker")

concommand.Add("hg_posture_maker", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	net.Start("hg_brainfuck_posture_maker")
	net.Send(ply)
end)

local decerebrateOffsets = {
	["male09"] = {
		[1] = {pos = Vector(0.000, 10.843, -3.734), ang = Angle(6.540, 90.000, 90.000)},
		[2] = {pos = Vector(-7.724, 19.912, -2.491), ang = Angle(-7.603, -101.592, -94.129)},
		[3] = {pos = Vector(7.724, 19.912, -2.491), ang = Angle(-7.606, -78.362, -85.877)},
		[4] = {pos = Vector(15.264, 10.992, -3.040), ang = Angle(-4.284, -98.168, -82.393)},
		[5] = {pos = Vector(22.676, 2.225, -2.886), ang = Angle(-12.399, -60.642, -0.208)},
		[6] = {pos = Vector(-15.264, 10.992, -3.040), ang = Angle(-9.897, -81.047, -104.082)},
		[7] = {pos = Vector(-29.779, -0.579, 21.670), ang = Angle(7.231, -113.556, -179.180)},
		[8] = {pos = Vector(-3.890, 0.000, 0.000), ang = Angle(-2.857, -87.461, -90.141)},
		[9] = {pos = Vector(-3.984, -17.826, -0.874), ang = Angle(5.104, -90.299, -90.000)},
		[10] = {pos = Vector(-0.002, 26.038, -1.315), ang = Angle(12.777, 89.905, -90.156)},
		[11] = {pos = Vector(3.890, 0.000, 0.000), ang = Angle(-0.025, -92.535, -89.999)},
		[12] = {pos = Vector(3.984, -17.826, -0.875), ang = Angle(5.103, -89.701, -90.000)},
		[13] = {pos = Vector(4.069, -34.286, -2.345), ang = Angle(5.851, -90.035, -92.846)},
		[14] = {pos = Vector(-4.069, -34.286, -2.345), ang = Angle(5.821, -89.420, -86.815)}
	},
	["female06"] = {
		[1] = {pos = Vector(0.000, 11.654, -1.888), ang = Angle(11.243, 90.000, 90.000)},
		[2] = {pos = Vector(-5.697, 19.976, -1.384), ang = Angle(-4.395, -94.588, -92.376)},
		[3] = {pos = Vector(5.697, 19.976, -1.384), ang = Angle(-4.397, -85.366, -87.627)},
		[4] = {pos = Vector(11.722, 10.707, -2.613), ang = Angle(-3.486, -105.294, -83.293)},
		[5] = {pos = Vector(17.831, 1.310, -2.698), ang = Angle(-12.797, -70.679, -4.330)},
		[6] = {pos = Vector(-11.722, 10.707, -2.613), ang = Angle(-9.110, -74.011, -103.162)},
		[7] = {pos = Vector(-24.933, -1.494, 21.859), ang = Angle(6.377, -102.147, -175.190)},
		[8] = {pos = Vector(-3.984, 0.000, 0.000), ang = Angle(-2.699, -84.854, -90.134)},
		[9] = {pos = Vector(-3.343, -15.906, -0.825), ang = Angle(5.925, -87.692, -90.000)},
		[10] = {pos = Vector(0.000, 25.183, -1.606), ang = Angle(12.777, 90.000, -90.000)},
		[11] = {pos = Vector(3.984, 0.000, 0.000), ang = Angle(0.131, -95.143, -90.007)},
		[12] = {pos = Vector(3.343, -15.906, -0.825), ang = Angle(5.925, -92.308, -90.000)},
		[13] = {pos = Vector(2.633, -33.506, -2.653), ang = Angle(6.250, -90.056, -92.846)},
		[14] = {pos = Vector(-2.634, -33.506, -2.653), ang = Angle(6.085, -89.407, -86.812)}
	}
}

local decorticateOffsets = {
	["male09"] = {
		[1] = {ang = Angle(6.532, 87.147, 89.675)},
		[2] = {ang = Angle(-31.880, -106.651, -102.970)},
		[3] = {ang = Angle(-21.395, -71.168, -64.864)},
		[4] = {ang = Angle(-18.419, 157.210, -43.869)},
		[5] = {ang = Angle(3.913, 136.291, 67.706)},
		[6] = {ang = Angle(-12.286, -21.858, -177.798)},
		[7] = {ang = Angle(6.814, 22.481, 109.636)},
		[8] = {ang = Angle(-17.013, -87.335, -90.868)},
		[9] = {ang = Angle(5.104, -90.299, -90.000)},
		[10] = {ang = Angle(26.951, 89.862, -90.170)},
		[11] = {ang = Angle(-8.519, -92.567, -89.575)},
		[12] = {ang = Angle(5.103, -89.701, -90.000)},
		[13] = {ang = Angle(-22.460, -88.573, -93.064)},
		[14] = {ang = Angle(-22.480, -91.057, -86.570)}
	},
	["female06"] = {
		[1] = {ang = Angle(11.229, 87.110, 89.437)},
		[2] = {ang = Angle(-28.522, -100.299, -101.310)},
		[3] = {ang = Angle(-17.990, -77.884, -66.263)},
		[4] = {ang = Angle(-19.488, 150.210, -44.447)},
		[5] = {ang = Angle(3.145, 125.600, 71.682)},
		[6] = {ang = Angle(-12.661, -14.923, -176.630)},
		[7] = {ang = Angle(4.653, 33.073, 106.189)},
		[8] = {ang = Angle(-16.855, -84.730, -90.860)},
		[9] = {ang = Angle(5.925, -87.692, -90.000)},
		[10] = {ang = Angle(26.950, 90.000, -90.000)},
		[11] = {ang = Angle(-8.362, -95.173, -89.583)},
		[12] = {ang = Angle(5.925, -92.308, -90.000)},
		[13] = {ang = Angle(-22.061, -88.598, -93.053)},
		[14] = {ang = Angle(-22.217, -91.041, -86.575)}
	}
}

local fencingOffsets = {
	["male09"] = {
		[2] = {ang = Angle(-37.045, -105.045, -85.963)},
		[3] = {ang = Angle(-44.859, -61.829, -55.931)},
		[4] = {ang = Angle(-25.275, -157.402, -8.719)},
		[5] = {ang = Angle(18.369, 160.064, 98.145)},
		[6] = {ang = Angle(-28.958, 53.028, 34.571)},
		[7] = {ang = Angle(-1.339, -1.693, 74.846)},
		[8] = {ang = Angle(-14.129, -96.146, -48.883)},
		[9] = {ang = Angle(-8.891, -78.821, -46.443)},
		[10] = {ang = Angle(12.777, 89.905, -90.156)},
		[11] = {ang = Angle(-31.164, -86.388, -52.031)},
		[12] = {ang = Angle(38.609, -100.609, -77.015)},
		[13] = {ang = Angle(-5.608, -92.318, -84.065)},
		[14] = {ang = Angle(-30.825, -75.116, -60.820)}
	},
	["female06"] = {
		[2] = {ang = Angle(-33.726, -98.938, -84.097)},
		[3] = {ang = Angle(-41.284, -68.324, -56.945)},
		[4] = {ang = Angle(-25.633, -164.044, -9.989)},
		[5] = {ang = Angle(16.043, 150.152, 101.607)},
		[6] = {ang = Angle(-30.158, 60.254, 34.493)},
		[7] = {ang = Angle(-4.705, 9.362, 72.585)},
		[8] = {ang = Angle(-13.971, -93.535, -48.900)},
		[9] = {ang = Angle(-8.086, -76.238, -46.278)},
		[10] = {ang = Angle(12.777, 90.000, -90.000)},
		[11] = {ang = Angle(-31.007, -89.000, -52.020)},
		[12] = {ang = Angle(39.416, -103.343, -77.216)},
		[13] = {ang = Angle(-5.209, -92.337, -84.082)},
		[14] = {ang = Angle(-30.571, -75.143, -60.742)}
	}
}

local fencingArmBones = {[2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true}

local function getPostureShake(rag, physBone, postureType, scale)
	local time = CurTime()
	rag.postureShake = rag.postureShake or {}
	local shake = rag.postureShake[physBone]
	if not shake or shake.postureType ~= postureType or time >= shake.next then
		local amp = postureType == "fencing" and (fencingArmBones[physBone] and 0.85 or 0.12) or 1.15
		local burst = math_random(100) <= (postureType == "fencing" and fencingArmBones[physBone] and 14 or 18) and math_rand(1.15, 1.7) or 1
		shake = {
			postureType = postureType,
			next = time + math_rand(POSTURE_SHAKE_REFRESH[1], POSTURE_SHAKE_REFRESH[2]),
			p = math_rand(-amp, amp) * burst * scale,
			y = math_rand(-amp, amp) * burst * scale,
			r = math_rand(-amp * 0.28, amp * 0.28) * burst * scale,
			phase = math_rand(0, 6.28),
			freq = math_rand(2.2, 9.5)
		}
		rag.postureShake[physBone] = shake
	end

	local pulse = 0.45 + math_sin(time * shake.freq + shake.phase) * 0.55
	return shake.p * pulse, shake.y * pulse, shake.r * pulse
end

local function getBrainLobeSeverity(org)
	return math_min(org.brainFrontal or 0, 0.2)
		+ math_min(org.brainParietal or 0, 0.2)
		+ math_min(org.brainTemporal or 0, 0.2)
		+ math_min(org.brainOccipital or 0, 0.2)
end

local function startFencing(org, dur)
	if not org then return end
	local time = CurTime()
	if not org.fencingEnd or time >= org.fencingEnd then org.fencingHeavyEnd = time + FENCING_HEAVY_DURATION end
	org.fencingStart = time
	org.fencingEnd = time + (dur or FENCING_DURATION)
end

local function applyFencingToPlayer(ply, dur)
	if not IsValid(ply) or not ply.organism then return end
	startFencing(ply.organism, dur)
end

hg.applyFencingToPlayer = applyFencingToPlayer

local function getFencingScale(org)
	if not org.fencingEnd then return end
	local time = CurTime()
	if time >= org.fencingEnd then
		org.fencingStart, org.fencingEnd, org.fencingHeavyEnd = nil, nil, nil
		return
	end

	return 0.75
end

local function clearPostureFade(org)
	org.postureFadeType, org.postureFadeStart, org.postureFadeDur = nil, nil, nil
	org.postureFadeOutStart, org.postureFadeOutType, org.postureLastScale = nil, nil, nil
end

local function applyPostureFade(org, postureType, severity, scale)
	local time = CurTime()
	if org.postureDeadDone and (not postureType or (severity or 0) <= (org.postureDeadDoneSeverity or 0) + 0.01) then
		clearPostureFade(org)
		return
	end

	if postureType then
		org.postureDeadDone, org.postureDeadDoneSeverity = nil, nil
		if org.postureFadeType ~= postureType then
			org.postureFadeType = postureType
			org.postureFadeStart = time
			org.postureFadeDur = math_rand(POSTURE_FADE_IN[1], POSTURE_FADE_IN[2])
		end

		local fade = math_clamp((time - (org.postureFadeStart or time)) / (org.postureFadeDur or POSTURE_FADE_IN[2]), 0, 1)
		org.postureFadeOutStart, org.postureFadeOutType = nil, nil
		org.postureLastScale = scale * fade
		return postureType, severity, org.postureLastScale
	end

	if not org.postureFadeType or not org.postureLastScale or org.postureLastScale <= 0.01 then
		clearPostureFade(org)
		return
	end

	org.postureFadeOutStart = org.postureFadeOutStart or time
	org.postureFadeOutType = org.postureFadeOutType or org.postureFadeType
	local fade = math_clamp(1 - (time - org.postureFadeOutStart) / POSTURE_FADE_OUT, 0, 1)
	if fade <= 0.01 then
		clearPostureFade(org)
		return
	end

	return org.postureFadeOutType, severity or org.postureSeverity, org.postureLastScale * fade
end

local function getPostureState(org)
	local fencingScale = getFencingScale(org)
	if fencingScale then return "fencing", math_max(org.brain or 0, getBrainLobeSeverity(org)), fencingScale end

	local lobeSeverity = getBrainLobeSeverity(org)
	local brainSeverity = org.brain or 0
	lobeSeverity = math_clamp(lobeSeverity * 1.25, 0, 1)
	brainSeverity = math_clamp(brainSeverity * 1.15, 0, 1)
	local severity = math_clamp(math_max(brainSeverity, lobeSeverity, brainSeverity * 0.6 + lobeSeverity * 0.7), 0, 1)

	if severity < DECORTICATE_START then return applyPostureFade(org) end

	local wantsDecerebrate = lobeSeverity >= DECEREBRATE_START or brainSeverity >= 0.85
	local keepDecerebrate = org.postureType == "decerebrate" and (lobeSeverity >= 0.62 or brainSeverity >= 0.78)
	local postureType = (wantsDecerebrate or keepDecerebrate) and "decerebrate" or "decorticate"
	local start = postureType == "decerebrate" and DECEREBRATE_START or DECORTICATE_START
	local scale = math_clamp((severity - start) / (1 - start), 0, 1) ^ 0.65

	return applyPostureFade(org, postureType, severity, 0.55 + scale * 0.45)
end

local function applyFencingHeavy(rag, org)
	if not IsValid(rag) or not org.fencingHeavyEnd then return end
	if CurTime() >= org.fencingHeavyEnd then org.fencingHeavyEnd = nil return end

	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if IsValid(phys) then phys:ApplyForceCenter(Vector(0, 0, -phys:GetMass() * FENCING_HEAVY_FORCE)) end
	end
end

local function processPosture(rag, postureType, scale)
	if not IsValid(rag) then return end

	local reference = rag:GetPhysicsObjectNum(0)
	if not IsValid(reference) then return end

	local model = string.lower(rag:GetModel() or "")
	local postureOffsets = postureType == "fencing" and fencingOffsets or postureType == "decorticate" and decorticateOffsets or decerebrateOffsets
	local offsets = string.find(model, "female", 1, true) and postureOffsets.female06 or postureOffsets.male09
	local referenceAng = reference:GetAngles()
	local force = 450 + 750 * scale
	local damp = 18 + 42 * scale
	if postureType == "fencing" then
		force = force * FENCING_FORCE_MUL
		damp = damp * FENCING_DAMP_MUL
	else
		force = force * POSTURE_FORCE_MUL
		damp = damp * POSTURE_DAMP_MUL
	end
	if force <= 1 then return end

	for physBone, offset in pairs(offsets) do
		local ang = offset.ang
		local boneForce, boneDamp = force, damp
		if postureType == "fencing" and not fencingArmBones[physBone] then boneForce, boneDamp = boneForce * 0.45, boneDamp * 0.45 end
		local shakeP, shakeY, shakeR = getPostureShake(rag, physBone, postureType, scale)
		ang = Angle(ang.p + shakeP, ang.y + shakeY, ang.r + shakeR)

		local _, targetAng = LocalToWorld(vector_origin, ang, vector_origin, referenceAng)
		hg.ShadowControl(rag, physBone, postureType == "fencing" and 0.07 or 0.04, targetAng, boneForce, boneDamp, vector_origin, 0, 0)
	end
end

local function getPosturePlayer(owner, rag, org)
	if IsValid(owner) and owner:IsPlayer() then return owner end
	if IsValid(rag) and IsValid(rag.ply) and rag.ply:IsPlayer() then return rag.ply end
	org = org or {}
	if IsValid(org.owner) and org.owner:IsPlayer() then return org.owner end
end

local function printPostureDebug(owner, rag, org, postureType, severity, scale)
	if not postureType or org.postureDebugLastType == postureType then return end
	local developer = GetConVar("developer")
	if not developer or developer:GetInt() < 1 then return end

	local ply = getPosturePlayer(owner, rag, org)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local time = CurTime()
	if time < (org.postureDebugNext or 0) then return end
	org.postureDebugNext = time + 1.5
	org.postureDebugLastType = postureType

	PrintMessage(HUD_PRINTTALK, string.format("[posture] %s triggered %s (severity %.2f, scale %.2f)", ply:Nick(), postureType, severity or 0, scale or 0))
end

local function printSpasmDebug(rag, stype, dur)
	local developer = GetConVar("developer")
	if not developer or developer:GetInt() < 1 then return end

	local org = IsValid(rag) and rag.organism
	local ply = getPosturePlayer(nil, rag, org)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local time = CurTime()
	if time < (rag.spasmDebugNext or 0) then return end
	rag.spasmDebugNext = time + 1.5

	PrintMessage(HUD_PRINTTALK, string.format("[posture] %s triggered spasm:%s (duration %.1f)", ply:Nick(), stype or "unknown", dur or 0))
end

local spasmTypes = {[1] = {35, "extend"}, [2] = {25, "rigor"}, [3] = {15,"flexion"}} --;; Че хотите добавляйте изменяйте

local extendBones = {
	["ValveBiped.Bip01_R_Hand"] = true, ["ValveBiped.Bip01_L_Hand"] = true,
	["ValveBiped.Bip01_R_Foot"] = true, ["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true, ["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_R_Calf"] = true, ["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_R_UpperArm"] = true, ["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_R_Thigh"] = true, ["ValveBiped.Bip01_L_Thigh"] = true,
}

local flexionBones = {
	{"ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_Spine2", 1.2},
	{"ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_Spine2", 1.2},
	{"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_Spine2", 1.0},
	{"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_Spine2", 1.0},
	{"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine2", 0.6},
}

local rigorBones = {
	"ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2",
}



local function getRandomSpasm()
	local _, stype = hg.WeightedRandomSelect(spasmTypes, 1)

	return stype
end

hg.getRandomSpasm = getRandomSpasm

local function applySpasm(rag, stype)
	if not IsValid(rag) then return end
	if rag.organism and rag.organism.posturing then return end
	local dur = stype == "extend" and extendDur or stype == "rigor" and rigorDur or flexionDur
	dur = math_rand(dur[1], dur[2])
	
	rag.spasm, rag.spasmType, rag.spasmDur, rag.spasmForce = true, stype, dur, FORCE
	rag.spasmEnd, rag.spasmStart = CurTime() + dur, CurTime()
	printSpasmDebug(rag, stype, dur)
	
	if stype == "rigor" then
		rag.rigorActive = true
	end
	--rag:EmitSound("physics/body/body_medium_break" .. math_random(2, 4) .. ".wav", 60, math_random(70, 90), 0.4)
end

hg.applySpasm = applySpasm

local function processExtend(rag, fade)
	if rag.organism and rag.organism.posturing then return end
	local force, pulse = rag.spasmForce or FORCE, 0.7 + math_sin(CurTime() * 8) * 0.3
	local pelvis = rag:LookupBone("ValveBiped.Bip01_Pelvis")
	if not pelvis then return end
	local pelvisPos = rag:GetBonePosition(pelvis)
	
	for name in pairs(extendBones) do
		local bone = rag:LookupBone(name)
		if not bone then continue end
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
		if not IsValid(phys) then continue end
		local dir = (rag:GetBonePosition(bone) - pelvisPos):GetNormalized()
		phys:ApplyForceCenter((dir * force * fade * pulse) + VectorRand(-VIBRATION, VIBRATION) * fade)
	end
end

local function processRigor(rag, fade)
	if rag.organism and rag.organism.posturing then return end
	if not rag.rigorActive then return end
	local damp = RIGOR_DAMP * fade + 0.5
	
	for i = 1, #rigorBones do
		local bone = rag:LookupBone(rigorBones[i])
		if not bone then continue end
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
		if not IsValid(phys) then continue end
		--phys:SetDamping(damp, damp * 2)
		if fade > 0.3 then phys:ApplyForceCenter(VectorRand(-45, 45) * fade) end
	end
end

local function processFlexion(rag, fade)
	if rag.organism and rag.organism.posturing then return end
	local force, pulse = FLEXION_FORCE, 0.8 + math_sin(CurTime() * 5) * 0.2
	for i = 1, #flexionBones do
		local d = flexionBones[i]
		local bone, targetBone = rag:LookupBone(d[1]), rag:LookupBone(d[2])
		if not bone or not targetBone then continue end
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
		if not IsValid(phys) then continue end
		local dir = (rag:GetBonePosition(targetBone) - rag:GetBonePosition(bone)):GetNormalized()
		phys:ApplyForceCenter((dir * force * d[3] * fade * pulse) + VectorRand(-30, 30) * fade)
	end
end

local function clearSpasm(rag)
	if rag.spasmType == "rigor" and rag.rigorActive then
		for i = 1, #rigorBones do
			local bone = rag:LookupBone(rigorBones[i])
			if not bone then continue end
			local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
			if IsValid(phys) then phys:SetDamping(0.5, 1) end
		end
	end
	rag.spasm, rag.spasmEnd, rag.spasmStart, rag.spasmDur, rag.spasmForce, rag.spasmType, rag.rigorActive = nil, nil, nil, nil, nil, nil, nil
end

hook.Add("Org Clear", "BrainfuckClear", function(org)
	org.fencingStart, org.fencingEnd, org.fencingBrainDamage = nil, nil, nil
	org.postureDeathStart, org.postureDeadDone, org.postureDeadDoneSeverity = nil, nil, nil
	org.postureDeathSeverity, org.postureDeathType, org.postureDeathFaded = nil, nil, nil
	org.postureDebugLastType, org.postureDebugNext = nil, nil
	clearPostureFade(org)
end)

hook.Add("RagdollDeath", "BrainfuckStart", function(ply, rag)
	local org = IsValid(rag) and rag.organism or IsValid(ply) and ply.organism
	if not org then return end
	org.postureDeathStart, org.postureDeadDone, org.postureDeadDoneSeverity = nil, nil, nil
	org.postureDeathSeverity, org.postureDeathType, org.postureDeathFaded = nil, nil, nil
end)

hook.Add("HomigradDamage", "BrainfuckFencing", function(ply, dmgInfo, hitgroup)
	if not IsValid(ply) or not ply:IsPlayer() or hitgroup ~= HITGROUP_HEAD then return end
	local org = ply.organism
	if not org then return end
	org.fencingBrainDamage = CurTime()
end)

hook.Add("HG_OnOtrub", "BrainfuckFencing", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local org = ply.organism
	if not org then return end

	local time = CurTime()
	local brainSeverity = math_max(org.brain or 0, getBrainLobeSeverity(org))
	local recentBrainDamage = org.fencingBrainDamage and time - org.fencingBrainDamage <= FENCING_RECENT_DAMAGE
	if recentBrainDamage or ((org.consciousness or 1) <= 0.4 and brainSeverity > 0.01) then startFencing(org) end
end)

hook.Add("Fake", "BrainfuckFencing", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local org = ply.organism
	if not org or (not org.needotrub and not org.otrub) then return end

	local time = CurTime()
	local brainSeverity = math_max(org.brain or 0, getBrainLobeSeverity(org))
	local recentBrainDamage = org.fencingBrainDamage and time - org.fencingBrainDamage <= FENCING_RECENT_DAMAGE
	if recentBrainDamage or ((org.consciousness or 1) <= 0.4 and brainSeverity > 0.01) then startFencing(org) end
end)

hook.Add("Org Think", "BrainfuckThink", function(owner)
	if not IsValid(owner) then return end
	local deathRag = owner:IsPlayer() and owner:GetNWEntity("RagdollDeath")
	local rag = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or IsValid(deathRag) and deathRag or (owner:IsRagdoll() and owner or nil)
	local org = (IsValid(rag) and rag.organism) or owner.organism
	if not org then return end
	local time = CurTime()
	if org.postureThinkStamp == time then return end
	org.postureThinkStamp = time
	local postureType, postureSeverity, postureScale = getPostureState(org)
	local ply = IsValid(org.owner) and org.owner or owner
	deathRag = IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("RagdollDeath") or deathRag
	local dead = org.postureDeathStart ~= nil or deathRag == rag or owner:IsRagdoll() and (not IsValid(ply) or not ply:IsPlayer() or not ply:Alive())
	if dead and postureType then
		if not org.postureDeathStart or org.postureDeathType ~= postureType or (postureSeverity or 0) > (org.postureDeathSeverity or 0) + 0.05 then
			org.postureDeathStart = CurTime()
		end
		org.postureDeathSeverity, org.postureDeathType = postureSeverity or 0, postureType
		local deathFade = postureType == "fencing" and 1 or math_clamp(1 - (CurTime() - org.postureDeathStart) / POSTURE_DEATH_FADE, 0, 1)
		local postureFade = postureType == org.postureFadeType and math_clamp((time - (org.postureFadeStart or time)) / (org.postureFadeDur or POSTURE_FADE_IN[2]), 0, 1) or 1
		org.postureDeathFaded = deathFade <= 0.01
		postureScale = postureType == "fencing" and 1 or postureScale and math_max(postureScale, 0.55 * postureFade) * deathFade
	elseif not dead then
		org.postureDeathStart, org.postureDeathSeverity, org.postureDeathType, org.postureDeathFaded = nil, nil, nil, nil
	end
	if not postureScale or postureScale <= 0.01 then
		local hadPosture = postureType ~= nil
		postureType = nil
		if dead and (not hadPosture or org.postureDeathFaded) then
			org.postureDeadDone = true
			org.postureDeadDoneSeverity = postureSeverity or 0
			org.fencingStart, org.fencingEnd = nil, nil
			clearPostureFade(org)
		end
	end
	org.posturing = postureType ~= nil
	org.postureType = postureType
	org.postureSeverity = postureSeverity
	org.postureScale = postureScale
	if not postureType then org.postureDebugLastType = nil return end
	printPostureDebug(owner, rag, org, postureType, postureSeverity, postureScale)
	if rag.spasm then clearSpasm(rag) end
	if postureType == "fencing" then applyFencingHeavy(rag, org) end
	processPosture(rag, postureType, postureScale)
end)
