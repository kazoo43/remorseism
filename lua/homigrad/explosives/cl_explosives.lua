local PropaneExplosionEffect = "cloudmaker_ground"
local ShockwaveMaterial = Material("sprites/physbeama")
local ShockwaveSegments = 18
local ShockwaveLift = 6
local ShockwaveWidthScale = 0.35
local ShockwaveMinWidth = 18
local ShockwaveMaxCount = 24
local ExplosionShockwaves = {}
local effectPerMSec = 0
local effectCDCurTime = 0
local GasTankEffects = {}
local GasTankLeakReceiveCooldown = 0.05
local GasTankMaxVisualLeaks = 1
local math_cos, math_sin, math_pi = math.cos, math.sin, math.pi
local math_max = math.max

local ExplosiveSound = {
	Fire = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_incendiary_ground_sm2",
		ShockwaveColor = Color(255, 180, 120, 45)
	},
	PropaneSC500 = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = PropaneExplosionEffect,
		ShockwaveColor = Color(220, 220, 220, 50)
	},
	Sharpnel = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_groundsplode_medium",
		ShockwaveColor = Color(255, 225, 160, 42)
	},
	Normal = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_groundsplode_small",
		ShockwaveColor = Color(255, 215, 155, 38)
	},
	CustomBarrel = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_incendiary_ground_sm2",
		ShockwaveColor = Color(255, 190, 130, 58)
	}
}

local function PlaySndDist(snd, snd2, pos, isOnWater, watersnd)
	if SERVER then return end
	local view = render.GetViewSetup(true)
	local time = pos:Distance(view.origin) / 17836
	timer.Simple(time, function()
		if not isOnWater then
			EmitSound(snd2, pos, 0, CHAN_WEAPON, 1, 110, 0, 100, 0, nil)
			EmitSound(snd, pos, 0, CHAN_AUTO, 1, time > 0.6 and 140 or 110, 0, 100, 0, nil)
		else
			EmitSound(watersnd, pos, 0, CHAN_WEAPON, 1, 100, 0, 85, 0, nil)
		end
	end)
end

PrecacheParticleSystem("fire_jet_01")

hook.Add("PostDrawTranslucentRenderables", "hg_explosion_shockwaves", function(_, skybox)
	if skybox then return end
	local time = CurTime()
	local step = math_pi * 2 / ShockwaveSegments
	render.SetMaterial(ShockwaveMaterial)

	for i = #ExplosionShockwaves, 1, -1 do
		local wave = ExplosionShockwaves[i]
		local radius = (time - wave.StartTime) * wave.Speed
		if radius >= wave.Radius then
			table.remove(ExplosionShockwaves, i)
			continue
		end

		local frac = 1 - radius / wave.Radius
		local drawColor = wave.DrawColor
		drawColor.a = wave.Alpha * frac

		local width = math_max(ShockwaveMinWidth, wave.Thickness * ShockwaveWidthScale) * (0.45 + frac * 0.55)
		local pos = wave.Pos
		local z = pos.z + ShockwaveLift
		local prev = Vector(pos.x + radius, pos.y, z)

		for segment = 1, ShockwaveSegments do
			local ang = segment * step
			local nextPos = Vector(pos.x + math_cos(ang) * radius, pos.y + math_sin(ang) * radius, z)
			render.DrawBeam(prev, nextPos, width, 0, 1, drawColor)
			prev = nextPos
		end
	end
end)

net.Receive("hg_booom", function()
	local pos = net.ReadVector()
	local type = net.ReadString()
	local radius = net.ReadFloat()
	local speed = net.ReadFloat()
	local thickness = net.ReadFloat()
	local data = ExplosiveSound[type]
	if not data then return end

	if effectCDCurTime < CurTime() then
		effectPerMSec = 0
	end

	if effectPerMSec < 10 then
		ParticleEffect(data.Effect, pos, vector_up:Angle())
		effectPerMSec = effectPerMSec + 1
		effectCDCurTime = CurTime() + 0.2
	end

	if #ExplosionShockwaves >= ShockwaveMaxCount then
		table.remove(ExplosionShockwaves, 1)
	end

	ExplosionShockwaves[#ExplosionShockwaves + 1] = {
		Pos = pos,
		Radius = radius,
		Speed = speed,
		Thickness = thickness,
		StartTime = CurTime(),
		Alpha = data.ShockwaveColor.a,
		DrawColor = Color(data.ShockwaveColor.r, data.ShockwaveColor.g, data.ShockwaveColor.b, data.ShockwaveColor.a)
	}

	PlaySndDist(table.Random(data.Near), table.Random(data.Far), pos, false, "huy")
end)

net.Receive("hg_gastank_leak", function()
	local ent = net.ReadEntity()
	local localHolePos = net.ReadVector()
	local localNormal = net.ReadVector()
	local mode = net.ReadString()
	if not IsValid(ent) then return end

	local idx = ent:EntIndex()
	local data = GasTankEffects[idx]
	if not data then
		data = {Entity = ent, Leaks = {}, NextReceiveAt = 0}
		GasTankEffects[idx] = data
	end

	if CurTime() < (data.NextReceiveAt or 0) then return end
	data.NextReceiveAt = CurTime() + GasTankLeakReceiveCooldown

	if mode == "fire" and not data.FireSound then
		data.FireSound = CreateSound(ent, "rem_tankfire.mp3")
		if data.FireSound then
			data.FireSound:SetSoundLevel(70)
			data.FireSound:Play()
			data.FireSound:ChangePitch(108, 0)
		end
	end

	if mode == "smoke" and not data.SmokeSound then
		data.SmokeSound = CreateSound(ent, "ambient/gas/cannister_loop.wav")
		if data.SmokeSound then
			data.SmokeSound:SetSoundLevel(65)
			data.SmokeSound:Play()
			data.SmokeSound:ChangePitch(130, 0)
		end
	end

	local holePosWorld = ent:LocalToWorld(localHolePos)
	local normalWorld = (ent:LocalToWorld(localHolePos + localNormal) - holePosWorld):GetNormalized()
	local leakCount = #data.Leaks
	if leakCount >= GasTankMaxVisualLeaks then
		local oldLeak = data.Leaks[1]
		if oldLeak and oldLeak.Dummy and IsValid(oldLeak.Dummy) then
			oldLeak.Dummy:Remove()
		end
		table.remove(data.Leaks, 1)
	end

	local dummy = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_NONE)
	if not IsValid(dummy) then return end
	dummy:SetPos(holePosWorld)
	dummy:SetAngles(normalWorld:Angle())
	dummy:SetParent(ent)
	dummy:SetRenderMode(RENDERMODE_TRANSCOLOR)
	dummy:SetColor(Color(0, 0, 0, 0))

	if mode == "fire" then
		dummy.FireJet = CreateParticleSystem(dummy, "fire_jet_01", PATTACH_ABSORIGIN_FOLLOW, 0)
	end

	table.insert(data.Leaks, {Dummy = dummy, Mode = mode})
end)

net.Receive("hg_gastank_stop", function()
	local entIndex = net.ReadUInt(16)
	local data = GasTankEffects[entIndex]
	if not data then return end
	if data.FireSound then data.FireSound:Stop() end
	if data.SmokeSound then data.SmokeSound:Stop() end
	if istable(data.Leaks) then
		for _, leak in ipairs(data.Leaks) do
			if leak.Dummy and IsValid(leak.Dummy) then
				leak.Dummy:Remove()
			end
		end
	end
	GasTankEffects[entIndex] = nil
end)

hook.Add("Think", "hg_gastank_client_cleanup", function()
	for idx, data in pairs(GasTankEffects) do
		if IsValid(data.Entity) then continue end
		if data.FireSound then data.FireSound:Stop() end
		if data.SmokeSound then data.SmokeSound:Stop() end
		if istable(data.Leaks) then
			for _, leak in ipairs(data.Leaks) do
				if leak.Dummy and IsValid(leak.Dummy) then
					leak.Dummy:Remove()
				end
			end
		end
		GasTankEffects[idx] = nil
	end
end)
