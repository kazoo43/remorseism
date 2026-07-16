local function DrawSunEffect()
	local sun = util.GetSunInfo()
	if not sun then return end
	if not sun.obstruction == 0 or sun.obstruction == 0 or !sun.direction then return end
	local sunpos = EyePos() + sun.direction * 1024 * 4
	local scrpos = sunpos:ToScreen()
	local dot = (sun.direction:Dot(EyeVector()) - 0.8) * 5
	if dot <= 0 then return end
	DrawSunbeams(0.1, 0.15 * dot * sun.obstruction, 0.1, scrpos.x / ScrW(), scrpos.y / ScrH())
end

hg.postprocess = hg.postprocess or {}
local postprs = hg.postprocess
postprs.addtiveLayer = {
	bloom_darken = 0,
	bloom_mul = 0,
	bloom_sizex = 0,
	bloom_sizey = 0,
	bloom_passes = 0,
	bloom_colormul = 0,
	bloom_colorr = 0,
	bloom_colorg = 0,
	bloom_colorb = 0,
	blur_addalpha = 0,
	blur_drawalpha = 0,
	blur_delay = 0,
	toytown = 0,
	toytown_h = 0,
	brightness = 0,
	sharpen = 0,
	sharpen_dist = 0
}

postprs.layers = postprs.layers or {}
local layers = postprs.layers
local layers_name = {}
function postprs.LayerAdd(name, tab)
	tab.weight = 0
	layers_name[#layers_name+1] = name
	layers[name] = tab
end

function postprs.LayerWeight(name, lerp, value)
	layers[name].weight = LerpFT(lerp, layers[name].weight, value)
end

function postprs.LayerSetWeight(name, value)
	layers[name].weight = value
end

local addtiveLayer = postprs.addtiveLayer
local tab = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1
}

--local potatopc = GetConVar("hg_potatopc") or CreateClientConVar("hg_potatopc", "0", true, false, "enable this if you are noob", 0, 1)
local hook_Run = hook.Run
hook.Add("RenderScreenspaceEffects", "homigrad", function()
	//if potatopc:GetInt() >= 1 then return end
	hook_Run("Post Processing")
	//DrawSunEffect()
	for _, layer in ipairs(layers_name) do
		layer = layers[layer]
		local weight = layer.weight
		--for k, v in pairs(layer) do
			--if k == "weight" then continue end
		addtiveLayer["brightness"] = Lerp(weight, 0, layer["brightness"] or 0)
		--end
	end

	//DrawBloom(addtiveLayer.bloom_darken, addtiveLayer.bloom_mul, addtiveLayer.bloom_sizex, addtiveLayer.bloom_sizey, addtiveLayer.bloom_passes, addtiveLayer.bloom_colormul, addtiveLayer.bloom_colorr, addtiveLayer.bloom_colorg, addtiveLayer.bloom_colorb)
	//DrawSharpen(addtiveLayer.sharpen, addtiveLayer.sharpen_dist)
	//if not brain_motionblur then DrawMotionBlur(addtiveLayer.blur_addalpha, addtiveLayer.blur_drawalpha, addtiveLayer.blur_delay) end
	//DrawToyTown(addtiveLayer.toytown, addtiveLayer.toytown_h * ScrH())
	tab["$pp_colour_brightness"] = addtiveLayer.brightness
	DrawColorModify(tab)

	hook_Run("Post Pre Post Processing")

	hook_Run("Post Post Processing")

	hook_Run("Post Post Pre Post Processing")

	hook_Run("Post Pain Processing")
end)

local postprs = hg.postprocess
postprs.LayerAdd("main", {
	bloom_darken = 0.64,
	bloom_mul = 0.5,
	bloom_sizex = 4,
	bloom_sizey = 4,
	bloom_passes = 2,
	bloom_colormul = 1,
	bloom_colorr = 1,
	bloom_colorg = 1,
	bloom_colorb = 1
})

postprs.LayerAdd("water", {
	bloom_darken = 0.15,
	bloom_mul = 1,
	bloom_sizex = 30,
	bloom_sizey = 30,
	bloom_passes = 2,
	bloom_colormul = 1,
	bloom_colorr = 0.05,
	bloom_colorg = 0.5,
	bloom_colorb = 1,
	blur_addalpha = 0.1,
	blur_drawalpha = 0.5,
	blur_delay = 0.01
})

postprs.LayerAdd("water2", {
	toytown = 6,
	toytown_h = 4
})

postprs.LayerAdd("water3", {
	brightness = -0.5
})

local oldWaterLevel, lastWater = 0, 0
local LayerWeight = postprs.LayerWeight
local LayerSetWeight = postprs.LayerSetWeight
local CurTime = CurTime
local timecheck = CurTime()
hook.Add("Post Processing", "Main", function()
	//if potatopc:GetInt() >= 1 then return end
	//if !lply:Alive() then return end
	local ply = lply:Alive() and lply or lply:GetNWEntity("spect")
	if !IsValid(ply) then return end
	local waterLevel = oldWaterLevel
	if timecheck < CurTime() then
		local pos = hg.eye(lply)
		
		if !pos then return end

		waterLevel = (ply:WaterLevel() == 3) or ((ply:WaterLevel() > 1) and bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER)//lply:WaterLevel()

		timecheck = CurTime() + 0.1
	end

	local time = CurTime()

	if oldWaterLevel ~= waterLevel and waterLevel then
		lastWater = time + 2
	end

	local animpos = lastWater - time
	if animpos > 0 then
		LayerSetWeight("water3", animpos)
	else
		LayerSetWeight("water3", 0)
	end

	if waterLevel then
		LayerWeight("main", 0.1, 0)
		LayerWeight("water", 0.1, 1)
		LayerWeight("water2", 0.1, 1)
	else
		LayerWeight("main", 0.5, 1)
		LayerWeight("water", 0.5, 0)
		LayerWeight("water2", 0.01, 0)
	end

	oldWaterLevel = waterLevel

	DrawSunEffect()
end)

local color_red = Color( 56, 43, 0, 255)
local haloents = {
	["attachment_base"] = true,
	["ammo_base"] = true,
	["armor_base"] = true,
	["hg_flashlight"] = true,
	["homigrad_base"] = true,
	["weapon_melee"] = true,
	["weapon_bandage_sh"] = true,
	["hg_sling"] = true,
	["hg_brassknuckles"] = true,
	["weapon_m4super"] = true,
	["weapon_revolver2"] = true,
	["weapon_hg_f1_tpik"] = true
}

--[[hook.Add( "PreDrawHalos", "AddPropHalos", function() -- вариант с подсветкой всего в радиусе
	local pickuphalo = {}
	 
	local lpos = lply:GetPos()
	for _, ent in ipairs(ents.FindInSphere(lpos, 256)) do
		if IsValid(ent) and (haloents[ent.Base] or haloents[ent:GetClass()]) and not IsValid(ent:GetOwner()) then
		table.insert(pickuphalo, ent)
		local dist = lpos:Distance(ent:GetPos()) * 0.02
		--print(dist)
		color_red.r = Lerp(FrameTime()*5,color_red.r,56 / dist)
		color_red.g = Lerp(FrameTime()*5,color_red.g,43 / dist)
		end
	end
	halo.Add( pickuphalo, color_red, 1, 1, 1 )
end )]]

--[[hook.Add( "PreDrawHalos", "AddPropHalos", function() -- вариант с подсвечиванием только когда смотришь
	local pickuphalo = {}
	 
	local tr = hg.eyeTrace(lply,72)
	if IsValid(tr.Entity) and haloents[tr.Entity.Base] then
		table.insert(pickuphalo, tr.Entity)
		local dist = lply:GetPos():Distance(tr.Entity:GetPos()) * 0.03
		--print(dist)
		color_red.r = Lerp(FrameTime()*2,color_red.r,56 / dist)
		color_red.g = Lerp(FrameTime()*2,color_red.g,43 / dist)
	else
		color_red.r = Lerp(FrameTime()*2,color_red.r,0)
		color_red.g = Lerp(FrameTime()*2,color_red.g,0)
	end
	halo.Add( pickuphalo, color_red, 1, 1, 1 )
end )]]

-- funny :)

--that one furry game


local painMat = Material("effects/shaders/zb_grain")
local noiseMat = Material("effects/shaders/zb_grainwhite")
local vignetteMat = Material("effects/shaders/zb_vignette")
local assimilationMat = Material("effects/shaders/zb_assimilation")
local coldMat = Material("effects/shaders/zb_colda")
local grainMat = Material("effects/shaders/zb_grain2")
local heatMat = Material("effects/shaders/zb_heat")
local blindMat = Material("effects/shaders/zb_blind")

local PainLerp = 0
local painThresholdIntensityLerp = 1
local PanicAttackLerp = 0
local O2Lerp = 0
local assimilatedLerp = 0
local tempLerp = 36.6
local brainFrontalLerp = 0
local brainParietalLerp = 0
local brainTemporalLerp = 0
local brainOccipitalLerp = 0
local brainHemorrhageLerp = 0
local brainFrontalColor = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local show_image_time = 0
local show_some_images_time = 0
local lobotomy_mats = {
	[1] = Material("overlays/photopsiaoverlay1.png"),
	[2] = Material("overlays/photopsiaoverlay2.png"),
	[3] = Material("overlays/photopsiaoverlay3.png"),
	[4] = Material("overlays/photopsiaoverlay4.png"),
	[5] = Material("overlays/peripheralorboverlay.png"),
	[6] = Material("overlays/tallflash1.png"),
	[7] = Material("overlays/tallflash2.png"),
	[8] = Material("overlays/tallflash3.png")
}

local consciousnessTypeBeatVolume = 0.18
local dying2Volume = 0.4
local painBeatOverlayPath = "sound/rem_pain.mp3"
local panicattackOverlayPath = "sound/rem_panicattack.mp3"
local panicattackFadeStart = 0
local panicattackThreshold = 0.55
local panicattackVolumeMul = 1
local panicattackVisualExponent = 1.75
local panicattackPulseFloor = 0.78
local panicattackPulseIntensity = 0.2
local panicattackShakeIntervalMin = 0.45
local panicattackShakeIntervalMax = 1.4
local panicattackShakeMul = 0.85
local painBeatOverlayVolumeMul = 1.25
local painThresholdMax = 120
local painAgonyThreshold = 0.45
local painExcruciatingThreshold = 0.87
local painAgonyVolumeMul = 1.15
local painExcruciatingVolumeMul = 0.85
local painLayerFadeLerp = 0.06
local painEffectIntensity = 0.8
local unconsciousPainEffectIntensity = 1.55
local painPulseIntensity = 0.25
local PainStationLoading = false
local PanicStationLoading = false
local PainStationOverlayLoading = false
local AssimilationStationLoading = false
local BrainTraumaStationLoading = false
local TinnitusLoading = false
local NoiseStationLoading = false
local NoiseStation2Loading = false
local NoiseStation2DyingLoading = false
local painAudioGeneration = 0
local painLayers = {
	agony = {
		path = "rem_agony.ogg",
		threshold = painAgonyThreshold,
		volumeMul = painAgonyVolumeMul,
		fadeLerp = painLayerFadeLerp,
		currentVolume = 0,
		targetVolume = 0
	},
	excruciating = {
		path = "rem_excruciatingpain.ogg",
		threshold = painExcruciatingThreshold,
		volumeMul = painExcruciatingVolumeMul,
		fadeLerp = painLayerFadeLerp,
		currentVolume = 0,
		targetVolume = 0
	}
}
local seizureSoundPath = "sound/rem_seizure.ogg"
local seizureIntroDuration = 3
local seizureFlashDelayMin = 0.12
local seizureFlashDelayMax = 0.55
local seizureFlashDurationMin = 0.35
local seizureFlashDurationMax = 1.1
local seizureFlashSizeMin = 9000
local seizureFlashSizeMax = 18000
local seizureFinalFlashLead = 2
local seizureFinalFlashDuration = 5
local seizureFinalFlashSize = 90000
local seizureSoundVolume = 1
local seizureSoundOtrubVolume = 0.3
local seizureSoundOtrubPlaybackRate = 0.82
local seizureIntroTab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local seizureChromatic = Material("effects/shaders/merc_chromaticaberration")
local SeizureStationLoading = false
local seizureAudioGeneration = 0
local seizureClientActive = false
local seizureClientStart = 0
local seizureClientEnd = 0
local nextSeizureFlash = 0
local nextSeizureCamShake = 0
local seizureFinalFlashFired = false

local function stopSeizureEffects()
	seizureClientActive = false
	seizureClientStart = 0
	seizureClientEnd = 0
	nextSeizureFlash = 0
	nextSeizureCamShake = 0
	seizureFinalFlashFired = false
	SeizureStationLoading = false
	seizureAudioGeneration = seizureAudioGeneration + 1

	if IsValid(SeizureStation) then
		SeizureStation:Stop()
		SeizureStation = nil
	end
end

local function ensureSeizureStation()
	if IsValid(SeizureStation) or SeizureStationLoading then return end

	local generation = seizureAudioGeneration
	SeizureStationLoading = true
	sound.PlayFile(seizureSoundPath, "noblock noplay", function(station)
		SeizureStationLoading = false
		if generation != seizureAudioGeneration then
			if IsValid(station) then
				station:Stop()
			end
			return
		end
		if IsValid(station) then
			station:SetVolume(0)
			station:Play()
			station:EnableLooping(true)
			SeizureStation = station
		end
	end)
end

local function addSeizureFlash(isFinal)
	if not hg.AddFlash then return end

	local view = render.GetViewSetup(true)
	local pos = view.origin + view.angles:Forward() * math.Rand(isFinal and 140 or 120, isFinal and 220 or 210) + view.angles:Right() * math.Rand(isFinal and -45 or -110, isFinal and 45 or 110) + view.angles:Up() * math.Rand(isFinal and -45 or -80, isFinal and 45 or 80)
	local time = isFinal and seizureFinalFlashDuration or math.Rand(seizureFlashDurationMin, seizureFlashDurationMax)
	local size = isFinal and seizureFinalFlashSize or math.Rand(seizureFlashSizeMin, seizureFlashSizeMax)

	hg.AddFlash(view.origin, 1, pos, time, size)
end

local function updateSeizureEffects(org)
	if org.seizureActive and (org.seizureStart or 0) > 0 and (org.seizureEnd or 0) > CurTime() then
		if not seizureClientActive or seizureClientStart != org.seizureStart or seizureClientEnd != org.seizureEnd then
			seizureClientActive = true
			seizureClientStart = org.seizureStart
			seizureClientEnd = org.seizureEnd
			nextSeizureFlash = math.max(seizureClientStart + seizureIntroDuration, CurTime() + seizureIntroDuration)
			nextSeizureCamShake = CurTime()
			seizureFinalFlashFired = false
		end

		ensureSeizureStation()
		if IsValid(SeizureStation) then
			SeizureStation:SetVolume(org.otrub and seizureSoundOtrubVolume or seizureSoundVolume)
			SeizureStation:SetPlaybackRate(org.otrub and seizureSoundOtrubPlaybackRate or 1)
		end

		local seizureElapsed = math.max(CurTime() - seizureClientStart, 0)
		if seizureElapsed < seizureIntroDuration then
			local intensity = math.min(seizureElapsed, seizureIntroDuration)
			seizureIntroTab["$pp_colour_contrast"] = intensity / 2
			seizureIntroTab["$pp_colour_addr"] = intensity / 10
			seizureIntroTab["$pp_colour_brightness"] = intensity / 10
			DrawColorModify(seizureIntroTab)
			DrawBloom(0.65, intensity * 4, 9, 9, 1, 1, intensity / 16, 0.2, 0.2)

			render.UpdateScreenEffectTexture()
			seizureChromatic:SetFloat("$c0_x", 3.5 - intensity)
			seizureChromatic:SetInt("$c0_y", 1)
			render.SetMaterial(seizureChromatic)
			render.DrawScreenQuad()
		end

		if seizureElapsed >= seizureIntroDuration and CurTime() >= nextSeizureFlash then
			addSeizureFlash(false)
			nextSeizureFlash = CurTime() + math.Rand(seizureFlashDelayMin, seizureFlashDelayMax)
		end

		if CurTime() >= nextSeizureCamShake then
			ViewPunch(Angle(math.Rand(-1.25, 1.25), math.Rand(-1.4, 1.4), math.Rand(-0.45, 0.45)))
			ViewPunch2(Angle(math.Rand(-0.55, 0.55), math.Rand(-0.8, 0.8), math.Rand(-0.7, 0.7)))
			nextSeizureCamShake = CurTime() + math.Rand(0.025, 0.06)
		end

		if not seizureFinalFlashFired and CurTime() >= seizureClientEnd - seizureFinalFlashLead then
			addSeizureFlash(true)
			seizureFinalFlashFired = true
		end
	else
		stopSeizureEffects()
	end
end

local function stopPainLayer(layer)
	layer.targetVolume = 0
	layer.currentVolume = 0
	if layer.station then
		layer.station:Stop()
		layer.station = nil
	end
end

local function stopPainLayers()
	painAudioGeneration = painAudioGeneration + 1
	for _, layer in pairs(painLayers) do
		stopPainLayer(layer)
	end
end

local function ensurePainLayer(layer)
	if layer.station then return end
	layer.station = CreateSound(lply, layer.path)
	if !layer.station then return end
	layer.station:PlayEx(0, 100)
end

local function updatePainLayer(layer, normalizedPain, baseVolume)
	local shouldPlay = normalizedPain >= layer.threshold and baseVolume > 0.001
	layer.targetVolume = shouldPlay and math.Clamp(math.Remap(normalizedPain, layer.threshold, 1, 0, layer.volumeMul), 0, layer.volumeMul) * math.min(baseVolume, 1) or 0
	layer.currentVolume = LerpFT(layer.fadeLerp, layer.currentVolume or 0, layer.targetVolume)
	if shouldPlay then
		ensurePainLayer(layer)
	end
	if !layer.station then return end
	layer.station:ChangeVolume(layer.currentVolume, 0)
	if !shouldPlay and layer.currentVolume <= 0.01 then
		layer.station:Stop()
		layer.station = nil
	end
end

local function stopthings()
	PainLerp = 0
	painThresholdIntensityLerp = 1
	PanicAttackLerp = 0
	O2Lerp = 0
	shockLerp = 0
	assimilatedLerp = 0
	tempLerp = 36.6
	consciousnessLerp = 1
	brainFrontalLerp = 0
	brainParietalLerp = 0
	brainTemporalLerp = 0
	brainOccipitalLerp = 0
	brainHemorrhageLerp = 0

	lply.tinnitus = 0
	nextPanicAttackShake = 0
	PainStationLoading = false
	PanicStationLoading = false
	PainStationOverlayLoading = false
	AssimilationStationLoading = false
	BrainTraumaStationLoading = false
	TinnitusLoading = false
	NoiseStationLoading = false
	NoiseStation2Loading = false
	NoiseStation2DyingLoading = false
	stopPainLayers()
	stopSeizureEffects()
	
	if IsValid(PainStation) then
		PainStation:Stop()
		PainStation = nil
	end

	if IsValid(NoiseStation) then
		NoiseStation:Stop()
		NoiseStation = nil
	end

	if IsValid(NoiseStation2) then
		NoiseStation2:Stop()
		NoiseStation2 = nil
	end

	if IsValid(NoiseStation2Dying) then
		NoiseStation2Dying:Stop()
		NoiseStation2Dying = nil
	end

	if IsValid(PainStationOverlay) then
		PainStationOverlay:Stop()
		PainStationOverlay = nil
	end

	if IsValid(PanicStation) then
		PanicStation:Stop()
		PanicStation = nil
	end

	if IsValid(BrainTraumaStation) then
		BrainTraumaStation:Stop()
		BrainTraumaStation = nil
	end

	if IsValid(BrainTraumaStation2) then
		BrainTraumaStation2:Stop()
		BrainTraumaStation2 = nil
	end

	if IsValid(BrainTraumaStation3) then
		BrainTraumaStation3:Stop()
		BrainTraumaStation3 = nil
	end

	if IsValid(BrainTraumaStation4) then
		BrainTraumaStation4:Stop()
		BrainTraumaStation4 = nil
	end

	if IsValid(BrainTraumaStation5) then
		BrainTraumaStation5:Stop()
		BrainTraumaStation5 = nil
	end

	if IsValid(Tinnitus) then
		Tinnitus:Stop()
		Tinnitus = nil
	end

	if IsValid(AssimilationStation) then
		AssimilationStation:Stop()
		AssimilationStation = nil
	end
end

local stations = {
	0.06,
	0.1,
	0.15,
	0.22,
	0.27,
}

local choosera = 1
local tempolerp = 0
local lerpblood = 0
local addtime = CurTime()
local nextPanicAttackShake = 0
local hurtoverlay = Material("zcity/neurotrauma/damageOverlay.png", "smooth")
hook.Add("Post Post Processing", "ItHurts", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	local painVolume = 0
	local normalizedPain = 0
	local panicVolume = 0
	
	if IsValid(PainStation) then
		PainStation:SetVolume(0)
	end

	if IsValid(PainStationOverlay) then
		PainStationOverlay:SetVolume(0)
	end

	if IsValid(PanicStation) then
		PanicStation:SetVolume(0)
	end
	
	if !lply:Alive() and !IsValid(spect) then stopthings() return end
	if !lply:Alive() and viewmode != 1 then stopthings() return end
	local organism = lply:Alive() and lply.organism or (IsValid(spect) and spect.organism)
	if not organism then stopthings() return end
	if not organism.brain then stopthings() return end
	local org = organism

	updateSeizureEffects(org)
	
	if org.blindness or amtflashed >= 0.8 then
		local blindness = ((org.blindness and math.Round(org.blindness) == 0) or amtflashed >= 0.8) and 0 or (org.blindness)
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		
		blindMat:SetFloat("$c0_x", 5)
		blindMat:SetFloat("$c0_y", CurTime())
		blindMat:SetFloat("$c0_z", math.Round(blindness))
	
		render.SetMaterial(blindMat)
		render.DrawScreenQuad()
	end

	if (org.consciousness < 0.7) then
		lerpblood = LerpFT(0.01, lerpblood or 0, math.Clamp((0.7 - org.consciousness) * 5, 0, 1) * 255)
		local lowblood = (3600 - (org.blood or 5000)) / 600

		addtime = addtime + FrameTime() / 6
		local amt = (math.cos(addtime) + math.sin(addtime * 3) + math.sin(addtime * 2)) / 90
		local amt2 = (math.sin(addtime) + math.cos(addtime * 5) + math.sin(addtime * 6)) / 90
		local mat = Matrix({
			{1 - amt, amt, 0, -amt2 / 2},
			{amt2, 1 - amt2, 0, -amt / 2},
			{0, 0, 1, 0},
			{0, 0, 0, 1},
		})
		hurtoverlay:SetMatrix("$basetexturetransform", mat)
		surface.SetMaterial(hurtoverlay)
		surface.SetDrawColor(0, 0, 0, lerpblood)
		surface.DrawTexturedRect(-ScrW() * 2.0, -ScrH() * 2.0, ScrW() * 5, ScrH() * 5)
		//ViewPunch(Angle(-amt * 1, amt2 * 1,0))
		//ViewPunch2(Angle(-amt * 1, amt2 * 1,0))
	end

	if (!IsValid(PainStation) or PainStation:GetState() != GMOD_CHANNEL_PLAYING) and not PainStationLoading then
		local generation = painAudioGeneration
		PainStationLoading = true
		sound.PlayFile("sound/zbattle/pain_beat.ogg", "noblock noplay", function(station)
			PainStationLoading = false
			if generation != painAudioGeneration then
				if IsValid(station) then
					station:Stop()
				end
				return
			end
			if IsValid(station) then
				station:SetVolume(0)
				station:Play()
				station:SetTime(math.min(math.Rand(0, station:GetLength()), 139))
				PainStation = station
				station:EnableLooping(true)
			end
		end)
	end

	if (!IsValid(PainStationOverlay) or PainStationOverlay:GetState() != GMOD_CHANNEL_PLAYING) and not PainStationOverlayLoading then
		local generation = painAudioGeneration
		PainStationOverlayLoading = true
		sound.PlayFile(painBeatOverlayPath, "noblock noplay", function(station)
			PainStationOverlayLoading = false
			if generation != painAudioGeneration then
				if IsValid(station) then
					station:Stop()
				end
				return
			end
			if IsValid(station) then
				station:SetVolume(0)
				station:Play()
				station:SetTime(IsValid(PainStation) and PainStation:GetTime() or 0)
				PainStationOverlay = station
				station:EnableLooping(true)
			end
		end)
	end

	local LerpFT = LerpFT or Lerp

	if !org or !org.o2 or !isnumber(org.o2[1]) or !org.analgesia then stopthings() return end

	brainFrontalLerp = LerpFT(0.025, brainFrontalLerp, org.brainFrontal or 0)
	brainParietalLerp = LerpFT(0.025, brainParietalLerp, org.brainParietal or 0)
	brainTemporalLerp = LerpFT(0.025, brainTemporalLerp, org.brainTemporal or 0)
	brainOccipitalLerp = LerpFT(0.025, brainOccipitalLerp, org.brainOccipital or 0)
	brainHemorrhageLerp = LerpFT(0.02, brainHemorrhageLerp, org.brainHemorrhage or 0)

	local o2 = org.o2[1] or 0
	o2 = o2 + (org.CO or 0)
	local brain = org.brain or 0
	O2Lerp = LerpFT(0.01, O2Lerp, (30 - o2) * (org.otrub and 2 or 10) + (brain * 100) * (org.otrub and 1 or 5))

	tempLerp = LerpFT(0.01, tempLerp, org.temperature)
	local panicattackVisual = math.Clamp(math.Remap(org.panicattack or 0, panicattackFadeStart, panicattackThreshold, 0, 1), 0, 1)
	PanicAttackLerp = LerpFT(0.03, PanicAttackLerp, panicattackVisual ^ panicattackVisualExponent)

	if tempLerp > 38 then
		local heat = tempLerp - 38

		render.UpdateScreenEffectTexture()

		heatMat:SetFloat("$c0_x", -CurTime() * 0.25)//math.sin(CurTime() * 0.1) * CurTime() * 0.01) //time
		heatMat:SetFloat("$c0_y", 0.06 * heat)//(math.sin(CurTime()) + 1) * 2) //intensity (strict)
		heatMat:SetFloat("$c2_x", (math.sin(CurTime()) - 2) * heat)

		render.SetMaterial(heatMat)
		render.DrawScreenQuad()
	end

	local pain = org.pain or 0
	pain = math.max(pain - 15, 0)
	local shock = (org.shock or 0) * 1 + (1 - org.consciousness) * 40
	shockLerp = LerpFT(0.01, shockLerp or 0, shock + (lply.suiciding and math.max(0, org.heartbeat - 90) or 0))
	consciousnessLerp = LerpFT(org.consciousness < (consciousnessLerp or 1) and 1 or 0.01, consciousnessLerp or 1, org.consciousness)
	-- local immobilization = org.immobilization
	PainLerp = LerpFT(0.05, PainLerp, math.max(pain * (org.otrub and 0.2 or 1), 0))
	assimilatedLerp = LerpFT(0.01, assimilatedLerp, (org.assimilated or 0))

	if assimilatedLerp > 0.001 then
		render.UpdateScreenEffectTexture()

		assimilationMat:SetFloat("$c0_x", -CurTime())//math.sin(CurTime() * 0.1) * CurTime() * 0.01) //time
		assimilationMat:SetFloat("$c0_y", assimilatedLerp * 3)//(math.sin(CurTime()) + 1) * 2) //intensity (strict)
		local ctime = CurTime() * 2
		local val = math.Clamp(3 - 1 / 3 * (math.sin(ctime * 2.8862) + math.cos(ctime * 1.115) - math.sin(ctime * 0.6215) + 3), 0, 5)
		local val2 = math.Clamp(1 - 1 / 6 * (math.sin(ctime * 1.1862) + math.cos(ctime * 2.315) - math.sin(ctime * 0.9215) + 3), 0, 1)
		assimilationMat:SetFloat("$c1_y", val)
		assimilationMat:SetFloat("$c1_x", val2 - 0.5)

		if (!IsValid(AssimilationStation) or AssimilationStation:GetState() != GMOD_CHANNEL_PLAYING) and not AssimilationStationLoading then
			AssimilationStationLoading = true
			sound.PlayFile("sound/zbattle/furry/conversion/assimilation_noise3.ogg", "noblock noplay", function(station, err)
				AssimilationStationLoading = false
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					AssimilationStation = station
					station:EnableLooping(true)
				end
			end)
		else
			AssimilationStation:SetVolume(assimilatedLerp * 2)
			//AssimilationStation:SetPlaybackRate(assimilatedLerp * 1)
		end

		render.SetMaterial(assimilationMat)
		render.DrawScreenQuad()
	else
		if IsValid(AssimilationStation) then
			AssimilationStation:Stop()
			AssimilationStation = nil
		end
	end

	if (org.consciousness or 0) < 1 then
		local consciousness = 1 - consciousnessLerp
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		
		grainMat:SetFloat("$c0_x", CurTime()) -- time
		grainMat:SetFloat("$c0_y", 0.5) -- gate
		grainMat:SetFloat("$c0_z", consciousness * 3) -- Pixelize
		grainMat:SetFloat("$c1_x", consciousness) -- lerp
		grainMat:SetFloat("$c1_y", 10) -- vignette intensity
		grainMat:SetFloat("$c1_z", consciousness) -- BlurIntensity
		grainMat:SetFloat("$c2_x", 0) -- r
		grainMat:SetFloat("$c2_y", 0) -- g
		grainMat:SetFloat("$c2_z", 0) -- b
		grainMat:SetFloat("$c3_x", 0) -- ImageIntensity
	
		render.SetMaterial(grainMat)
		render.DrawScreenQuad()
	end

	if PanicAttackLerp > 0.001 then
		local panicBase = PanicAttackLerp
		local panicPulse = panicBase * (panicattackPulseFloor + math.ease.InOutSine(math.abs(math.cos(CurTime() * 2))) * panicattackPulseIntensity)

		render.UpdateScreenEffectTexture()

		heatMat:SetFloat("$c0_x", -CurTime() * 0.1)
		heatMat:SetFloat("$c0_y", panicBase * 0.014 + panicPulse * 0.055)
		heatMat:SetFloat("$c2_x", panicBase * 0.28 + panicPulse * 1.7)

		render.SetMaterial(heatMat)
		render.DrawScreenQuad()

		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()

		grainMat:SetFloat("$c0_x", CurTime())
		grainMat:SetFloat("$c0_y", -1)
		grainMat:SetFloat("$c0_z", 1 + panicBase * 1.4)
		grainMat:SetFloat("$c1_x", panicBase * 3.2 + panicPulse * 5.8)
		grainMat:SetFloat("$c1_y", panicBase * 0.08 + panicPulse * 0.22)
		grainMat:SetFloat("$c1_z", panicBase * 0.08 + panicPulse * 0.24)
		grainMat:SetFloat("$c2_x", panicBase * 0.04 + panicPulse * 0.12)
		grainMat:SetFloat("$c2_y", 0.075 * panicBase)
		grainMat:SetFloat("$c2_z", 0)
		grainMat:SetFloat("$c3_x", 0)

		render.SetMaterial(grainMat)
		render.DrawScreenQuad()

		if not org.otrub and panicBase > 0.15 and CurTime() >= nextPanicAttackShake then
			local shakeMul = (0.25 + panicBase * 0.9) * panicattackShakeMul
			ViewPunch(Angle(math.Rand(-0.8, 0.6), math.Rand(-1, 1), math.Rand(-0.2, 0.2)) * shakeMul)
			ViewPunch2(Angle(math.Rand(-0.25, 0.35), math.Rand(-0.55, 0.55), math.Rand(-0.4, 0.4)) * shakeMul)
			nextPanicAttackShake = CurTime() + math.Rand(panicattackShakeIntervalMin, panicattackShakeIntervalMax)
		end
	else
		nextPanicAttackShake = 0
	end

	local tempo = math.Clamp((5 - (tempLerp - 29)) * 0.5 - 5 * (org.heartbeat < 1 and 1 or 0), 0, 5)
	tempolerp = LerpFT(0.01, tempolerp, tempo)
	
	if (tempolerp > 0) then
		render.UpdateScreenEffectTexture()

		coldMat:SetFloat("$c0_y", tempolerp)
		
		render.SetMaterial(coldMat)
		render.DrawScreenQuad()
	end

	if (PainLerp > 0.001 or shockLerp > 5) or org.otrub then
		local strobe = math.ease.InOutSine(math.abs(math.cos(CurTime() * 2))) * PainLerp * painPulseIntensity
		pain = PainLerp + strobe
		shock = shockLerp

		if org.otrub then
			DrawMotionBlur(0.1, 1., 0.01)
			lply:ScreenFade( SCREENFADE.IN, Color(0,0,0), 2, 0.5 )
		end
		
		//if pain > 10 then
			painVolume = math.Clamp(math.Remap(pain, 0, painThresholdMax, 0, 2), 0, 2)
			normalizedPain = math.Clamp(pain / painThresholdMax, 0, 1)
			if IsValid(PainStation) then
				PainStation:SetVolume(painVolume)
			end

			if IsValid(PainStationOverlay) then
				PainStationOverlay:SetVolume(painVolume * painBeatOverlayVolumeMul)
			end
		//else
		//	if IsValid(PainStation) then
		//		PainStation:Stop()
		//		PainStation = nil
		//	end
		//end
	else
		//if IsValid(PainStation) then
		//	PainStation:Stop()
		//	PainStation = nil
		//end
	end

	updatePainLayer(painLayers.agony, normalizedPain, painVolume)
	updatePainLayer(painLayers.excruciating, normalizedPain, painVolume)

	if PanicAttackLerp > 0.001 and not org.otrub then
		if (!IsValid(PanicStation) or PanicStation:GetState() != GMOD_CHANNEL_PLAYING) and not PanicStationLoading then
			PanicStationLoading = true
			sound.PlayFile(panicattackOverlayPath, "noblock noplay", function(station)
				PanicStationLoading = false
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					PanicStation = station
					station:EnableLooping(true)
				end
			end)
		end

		panicVolume = math.Clamp(PanicAttackLerp * panicattackVolumeMul, 0, 1)
		if IsValid(PanicStation) then
			PanicStation:SetVolume(panicVolume)
		end
	elseif IsValid(PanicStation) then
		PanicStation:Stop()
		PanicStation = nil
	end

	local brainTrauma = math.max(brain, (org.brainHemorrhage or 0) * 0.85)
	if brainTrauma > 0.01 then
		local chooser = 1
		for i, choose in ipairs(stations) do
			if choose < brainTrauma then
				chooser = i
			end
		end
	
		if choosera != chooser then
			BrainTraumaStationLoading = false
		end

		if (!IsValid(BrainTraumaStation) or choosera != chooser or BrainTraumaStation:GetState() != GMOD_CHANNEL_PLAYING) and not BrainTraumaStationLoading then
			if IsValid(BrainTraumaStation) then
				BrainTraumaStation:Stop()
				BrainTraumaStation = nil
			end

			BrainTraumaStationLoading = true
			sound.PlayFile("sound/rem_cerebralanoxia.wav", "noblock noplay", function(station, err)
				BrainTraumaStationLoading = false
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					BrainTraumaStation = station
					station:EnableLooping(true)
				end
			end)
			choosera = chooser
		end

		if IsValid(BrainTraumaStation) then
			BrainTraumaStation:SetVolume(math.Clamp(!org.otrub and brainTrauma * 2 or 0, 0, 1))
		end
	else
		if IsValid(BrainTraumaStation) then
			BrainTraumaStation:Stop()
			BrainTraumaStation = nil
		end
	end

	//if brain > 0.1 and not org.otrub and show_some_images_time > 0 and false then
	local temporalTinnitus = math.Clamp(((org.brainTemporal or 0) - 0.1) / 0.9, 0, 1)
	local tinnitusTime = lply.tinnitus and math.max(lply.tinnitus - CurTime(), 0) or 0
	if (tinnitusTime > 0 or temporalTinnitus > 0.01) and lply:Alive() then
		if (!IsValid(Tinnitus) or Tinnitus:GetState() != GMOD_CHANNEL_PLAYING) and not TinnitusLoading then
			TinnitusLoading = true
			sound.PlayFile("sound/zcitysnd/real_sonar/tinnitus"..math.random(3)..".mp3", "noblock noplay", function(station, err)
				TinnitusLoading = false
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					Tinnitus = station
					station:EnableLooping(true)
				end
			end)
		end

		if IsValid(Tinnitus) then
			Tinnitus:SetVolume(math.Clamp(math.max(tinnitusTime / 10, temporalTinnitus * 0.65), 0, 1))
		end
	else
		if IsValid(Tinnitus) then
			Tinnitus:Stop()
			Tinnitus = nil
		end
	end
	
	if brain > 0.1 and not org.otrub then
		if show_some_images_time > 0 then
			brain_motionblur = true
			DrawMotionBlur(0.1, 1., 0.1)
			show_some_images_time = show_some_images_time - 1
			if show_image_time <= 0 and math.random(10 * (1 - brain)) < 2 then
				show_image_time = 250 * (0.1 * 3) * math.Rand(0.1, 1) * (math.random(2) == 1 and 0.1 or 1)
				lobotomy_index = math.random(#lobotomy_mats)
			end

			if show_image_time > 0 then
				show_image_time = show_image_time - 1

				if lobotomy_index then
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(lobotomy_mats[lobotomy_index])
					local rand = 5
					surface.DrawTexturedRect(-math.random(rand), -math.random(rand), ScrW() + math.random(rand), ScrH() + math.random(rand))
				end
			end
		else
			brain_motionblur = false
			show_some_images_time = math.random(1200) < (brain * 15) and 250 or 0
		end
	else
		brain_motionblur = false
		show_image_time = 0
		lobotomy_index = 0
	end
	

	if O2Lerp > 1 then
		render.UpdateScreenEffectTexture()
		
		o2 = O2Lerp
		
		noiseMat:SetFloat("$c0_y", 1 - o2 / 200) //Gate
		noiseMat:SetFloat("$c0_z", 1) //ColorIntensity
		noiseMat:SetFloat("$c1_x", math.Clamp(o2 / 200, 0, 2)) //Lerp
		noiseMat:SetFloat("$c1_y", o2 * (!org.otrub and 0.05 or 1)) //Vignette
		noiseMat:SetFloat("$c2_x", CurTime() + 10000) //Time

		render.SetMaterial(noiseMat)
		render.DrawScreenQuad()
		
		if o2 > 50 and !org.otrub then
			if (!IsValid(NoiseStation2) or NoiseStation2:GetState() != GMOD_CHANNEL_PLAYING) and not NoiseStation2Loading then
				NoiseStation2Loading = true
				sound.PlayFile("sound/rem_dying1.mp3", "noblock noplay", function(station)
					NoiseStation2Loading = false
					if IsValid(station) then
						station:SetVolume(0)
						station:Play()
						station:SetTime(math.min(brain / 0.5 * station:GetLength()), 87)
						NoiseStation2 = station
						station:EnableLooping(true)
					end
				end)
			end

			if (!IsValid(NoiseStation2Dying) or NoiseStation2Dying:GetState() != GMOD_CHANNEL_PLAYING) and not NoiseStation2DyingLoading then
				NoiseStation2DyingLoading = true
				sound.PlayFile("sound/rem_dying2.mp3", "noblock noplay", function(station)
					NoiseStation2DyingLoading = false
					if IsValid(station) then
						station:SetVolume(0)
						station:Play()
						NoiseStation2Dying = station
						station:EnableLooping(true)
					end
				end)
			end
			
			if IsValid(NoiseStation2) then
				NoiseStation2:SetVolume(math.Clamp((o2 - 50) / 100 + (brain > 0.3 and (brain - 0.3) * 5 or 0), 0, consciousnessTypeBeatVolume))
			end

			if IsValid(NoiseStation2Dying) then
				NoiseStation2Dying:SetVolume(math.Clamp((o2 - 50) / 100 + (brain > 0.3 and (brain - 0.3) * 5 or 0), 0, dying2Volume))
			end
		else
			if IsValid(NoiseStation2) then
				NoiseStation2:SetVolume(0)
			end

			if IsValid(NoiseStation2Dying) then
				NoiseStation2Dying:SetVolume(0)
			end
		end
		
		if o2 > 20 and org.otrub then
			if (!IsValid(NoiseStation) or NoiseStation:GetState() != GMOD_CHANNEL_PLAYING) and not NoiseStationLoading then
				NoiseStationLoading = true
				sound.PlayFile("sound/rem_dying1.mp3", "noblock noplay", function(station)
					NoiseStationLoading = false
					if IsValid(station) then
						station:SetVolume(0)
						station:Play()
						station:SetTime(math.min(brain / 0.5 * station:GetLength(), 200))
						NoiseStation = station
						station:EnableLooping(true)
					end
				end)
			end

			if IsValid(NoiseStation) then
				NoiseStation:SetVolume(math.Clamp((o2 - 30) / 100 + (brain > 0.3 and (brain - 0.3) * 5 or 0), 0, 1))
			end
		else
			if IsValid(NoiseStation) then
				NoiseStation:SetVolume(0)
			end
		end
	else
		if IsValid(NoiseStation) then
			NoiseStation:Stop()
			NoiseStation = nil
		end
	end
end)

hook.Add("Post Post Pre Post Processing", "BrainLobeEffects", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	if !lply:Alive() and (!IsValid(spect) or viewmode != 1) then return end

	local org = lply:Alive() and lply.organism or (IsValid(spect) and spect.organism)
	if not org or org.otrub then return end

	local frontal = math.Clamp(brainFrontalLerp, 0, 1)
	local parietal = math.Clamp(brainParietalLerp, 0, 1)
	local temporal = math.Clamp(brainTemporalLerp, 0, 1)
	local occipital = math.Clamp(brainOccipitalLerp, 0, 1)
	local hemorrhage = math.Clamp(brainHemorrhageLerp, 0, 1)

	if frontal > 0.01 then
		brainFrontalColor["$pp_colour_brightness"] = -frontal * 0.035
		brainFrontalColor["$pp_colour_contrast"] = 1 - frontal * 0.18
		brainFrontalColor["$pp_colour_colour"] = 1 - frontal * 0.7
		brainFrontalColor["$pp_colour_mulr"] = frontal * 0.05
		brainFrontalColor["$pp_colour_mulb"] = frontal * 0.08
		DrawColorModify(brainFrontalColor)

		render.UpdateScreenEffectTexture()
		grainMat:SetFloat("$c0_x", CurTime() * 0.7)
		grainMat:SetFloat("$c0_y", 0.35)
		grainMat:SetFloat("$c0_z", frontal * 2.6)
		grainMat:SetFloat("$c1_x", frontal * 1.25)
		grainMat:SetFloat("$c1_y", frontal * 3.5)
		grainMat:SetFloat("$c1_z", frontal * 0.65)
		grainMat:SetFloat("$c2_x", frontal * 0.08)
		grainMat:SetFloat("$c2_y", 0)
		grainMat:SetFloat("$c2_z", frontal * 0.12)
		grainMat:SetFloat("$c3_x", 0)
		render.SetMaterial(grainMat)
		render.DrawScreenQuad()
	end

	if parietal > 0.01 then
		DrawMotionBlur(0.025 + parietal * 0.08, 0.35 + parietal * 0.55, 0.015 + parietal * 0.09)
		DrawSharpen(parietal * 0.8, parietal * 1.4)
	end

	if temporal > 0.01 then
		render.UpdateScreenEffectTexture()
		seizureChromatic:SetFloat("$c0_x", 3.4 - temporal * 2.6)
		seizureChromatic:SetInt("$c0_y", 1)
		render.SetMaterial(seizureChromatic)
		render.DrawScreenQuad()
	end

	if occipital > 0.01 then
		surface.SetDrawColor(255, 255, 255, math.Clamp(occipital * 235, 0, 235))
		surface.SetMaterial(lobotomy_mats[5])
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		if occipital > 0.6 then
			surface.SetDrawColor(0, 0, 0, math.Remap(occipital, 0.6, 1, 0, 210))
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end
		surface.SetDrawColor(255, 255, 255, 255)
	end

	if hemorrhage > 0.01 then
		local pulse = hemorrhage * (0.7 + math.abs(math.sin(CurTime() * 2.2)) * 0.3)
		render.UpdateScreenEffectTexture()
		vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
		vignetteMat:SetFloat("$c0_z", pulse * 2.2)
		vignetteMat:SetFloat("$c1_y", pulse * 3.2)
		render.SetMaterial(vignetteMat)
		render.DrawScreenQuad()

		render.UpdateScreenEffectTexture()
		painMat:SetFloat("$c2_x", CurTime() + 10000)
		painMat:SetFloat("$c0_y", 0.8)
		painMat:SetFloat("$c0_z", pulse)
		painMat:SetFloat("$c1_x", pulse * 0.45)
		painMat:SetFloat("$c1_y", pulse * 0.7)
		render.SetMaterial(painMat)
		render.DrawScreenQuad()
	end
end)

hook.Add("Post Pain Processing", "PainEffects", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	if !lply:Alive() and (!IsValid(spect) or viewmode != 1) then return end

	local org = lply:Alive() and lply.organism or (IsValid(spect) and spect.organism)
	if not org or not org.brain then return end
	if not ((PainLerp > 0.001 or shockLerp > 5) or org.otrub) then return end

	local strobe = math.ease.InOutSine(math.abs(math.cos(CurTime() * 2))) * PainLerp * painPulseIntensity
	local pain = PainLerp + strobe
	local shock = shockLerp
	local thresholdReached = PainLerp >= painThresholdMax
	painThresholdIntensityLerp = LerpFT(0.03, painThresholdIntensityLerp, thresholdReached and 5 or 1)
	local intensityMul = painThresholdIntensityLerp
	local coverage = thresholdReached and 1 or math.Clamp(pain / 70, 0, 0.95)
	local effectIntensity = pain / 32 * painEffectIntensity * intensityMul + math.max(shock - 5, 0) / 2.4 * painEffectIntensity

	render.UpdateScreenEffectTexture()

	vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
	vignetteMat:SetFloat("$c0_z", org.otrub and 5 * unconsciousPainEffectIntensity or effectIntensity)
	vignetteMat:SetFloat("$c1_y", org.otrub and 10 * unconsciousPainEffectIntensity or effectIntensity)

	render.SetMaterial(vignetteMat)
	render.DrawScreenQuad()

	render.UpdateScreenEffectTexture()

	painMat:SetFloat("$c2_x", CurTime() + 10000)
	painMat:SetFloat("$c0_y", 0.8)
	painMat:SetFloat("$c0_z", org.otrub and unconsciousPainEffectIntensity or painEffectIntensity * intensityMul)
	painMat:SetFloat("$c1_x", coverage)
	painMat:SetFloat("$c1_y", coverage)

	render.SetMaterial(painMat)
	render.DrawScreenQuad()
end)

hook.Add("Player_Death", "ItDoesntNow", function(ply)
	if !((ply == lply) or (ply == lply:GetNWEntity("spect"))) then return end

	stopthings()
end)

hook.Add("Player Spawn", "ItDoesntNow", function(ply)
	if ply != lply then return end

	stopthings()
end)

local function removeflash()
	if IsValid(lply.blindflash) then
		lply.blindflash:Remove()
	end
end

hook.Add("PreDrawOpaqueRenderables", "renderblindnessflash", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	
	if !lply:Alive() and !IsValid(spect) then removeflash() return end
	if !lply:Alive() and viewmode != 1 then removeflash() return end

	local organism = lply:Alive() and lply.organism or (IsValid(spect) and spect.organism)
	if not organism or isbool(organism) then return end

	if !(organism.blindness or (amtflashed or 0) >= 0.8) then removeflash() return end
	local blindness = ((organism.blindness and math.Round(organism.blindness) == 0) or amtflashed >= 0.8) and 0 or (organism.blindness)

	local eyesmode = math.Round(blindness)
	
	local view = render.GetViewSetup(true)
	
	if not IsValid(lply.blindflash) then
		lply.blindflash = ProjectedTexture()
		lply.blindflash:SetTexture("effects/flashlight001")
		lply.blindflash:SetEnableShadows(false)
		lply.blindflash:SetConstantAttenuation(.1)
	end
	
	local Ang = view.angles
	Ang[2] = Ang[2] + (eyesmode == 2 and 90 or eyesmode == 1 and -90 or 0)
	Ang[1] = eyesmode == 0 and Ang[1] or 0
	lply.blindflash:SetFarZ(40)
	lply.blindflash:SetFOV(160)
	lply.blindflash:SetBrightness(1)
	lply.blindflash:SetPos(view.origin)
	lply.blindflash:SetAngles(Ang)
	lply.blindflash:Update()
end)
