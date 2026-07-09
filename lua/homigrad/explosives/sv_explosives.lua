if SERVER then
	AddCSLuaFile("effects/eff_hg_co2_leak.lua")
	AddCSLuaFile("effects/eff_hg_co2_ground.lua")
end

util.AddNetworkString("hg_booom")
util.AddNetworkString("hg_gastank_leak")
util.AddNetworkString("hg_gastank_stop")
hg = hg or {}
hg.GasTank = hg.GasTank or {}
hg.GasTank.ActiveTanks = hg.GasTank.ActiveTanks or {}
hg.GasTank.ActiveClouds = hg.GasTank.ActiveClouds or {}

local RNG = math.random
local PropaneModel = "models/props_c17/canister_propane01a.mdl"
local PropaneExplosionNetType = "PropaneSC500"

function hg.FindOtherExplosive(inflictor, pos, radius)
end

function hg.MakeCombinedExplosion()
end

local DebrisSounds = {
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave01.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave010.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave02.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave03.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave04.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave05.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave06.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave07.wav",
	"explosion_debris/interior/explosion_debris_sprinkle_interior_wave09.wav"
}

local ExplosionExtraSounds = {
	"explosionextra/explode_1.wav",
	"explosionextra/explode_2.wav",
	"explosionextra/explode_3.wav",
	"explosionextra/explode_4.wav",
	"explosionextra/explode_5.wav",
	"explosionextra/explode_6.wav",
	"explosionextra/explode_7.wav",
	"explosionextra/explode_8.wav",
	"explosionextra/explode_9.wav",
	"ex1.wav",
	"ex2.wav",
	"ex3.wav",
	"ex4.wav",
	"ex5.wav",
	"ex6.wav",
	"ex7.wav",
	"ex8.wav",
	"ex9.wav",
	"ex10.wav"
}

local GasTankModels = {
	["models/props_c17/canister01a.mdl"] = true,
	["models/props_c17/canister02a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
	["models/props_c17/canister_propane01a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true
}

local GasTankPushForce = {
	Default = 100,
	["models/props_c17/canister01a.mdl"] = 125,
	["models/props_c17/canister02a.mdl"] = 125,
	["models/props_junk/PropaneCanister001a.mdl"] = 120,
	["models/props_c17/canister_propane01a.mdl"] = 135,
	["models/props_junk/propane_tank001a.mdl"] = 35
}

local GasTankSmokeSettings = {
	NextTick = 0.35,
	Magnitude = 1.4,
	DrainPerTick = 1.15,
	CloudRadius = 280,
	CloudLife = 36,
	PlayerRefresh = 0,
	PlayerTick = 0.55,
	IgniteTick = 0.15,
	GroundCloudsPerTick = 1,
	GroundCloudRadius = 90,
	GroundCloudLife = 42,
	AirCloudLift = 42,
	SpreadTick = 1.15,
	SpreadDistance = 55,
	AirSpreadDistance = 75,
	SpreadChildrenPerTick = 1,
	SpreadDepth = 3,
	MinSpreadRadius = 85,
	SmokeAffectRadius = 120,
	GroundAffectRadius = 100,
	AirAffectRadius = 90
}

local GasTankMainThinkInterval = 0.03
local GasTankAngularVelocityScale = 1.8
local GasTankExplodeDelayMin = 1
local GasTankExplodeDelayMax = 5
local GasTankLeakBroadcastRate = 0.06
local GasTankMaxLeaks = 4
local GasTankMaxClouds = 96
local GasTankRoomFireCount = 7
local GasTankRoomFireRadius = 220
local GasTankRoomFireLife = 90

local hg, util, IsValid, timer, coroutine, Vector, ents, game, net = hg, util, IsValid, timer, coroutine, Vector, ents, game, net
local CurTime, DamageInfo, EmitSound, SafeRemoveEntity = CurTime, DamageInfo, EmitSound, SafeRemoveEntity
local math_Clamp, math_max, math_min, math_random, math_sqrt = math.Clamp, math.max, math.min, math.random, math.sqrt
local ents_FindInSphere = ents.FindInSphere

local vecCone = Vector(5, 5, 0)
local BlastWaveSpeed = 5200
local BlastWaveThickness = 120
local BlastWaveForce = 50000
local BlastMaxTargets = 96

local function GetExplosionNetType(ent, defaultType)
	return ent:GetModel() == PropaneModel and PropaneExplosionNetType or defaultType
end

function hg.PlayExtraExplosionSound(pos, entIndex, volume)
	if not pos then return end
	local snd = ExplosionExtraSounds[math_random(#ExplosionExtraSounds)]
	local idx = entIndex or 0
	local vol = volume or 1
	EmitSound(snd, pos, idx + 400, CHAN_ITEM, vol, 145, 0, math_random(95, 105))
	timer.Simple(0.04, function()
		EmitSound(snd, pos, idx + 401, CHAN_AUTO, vol * 0.7, 135, 0, math_random(90, 100))
	end)
end

local function SendExplosionNet(pos, explosionType, radius)
	net.Start("hg_booom")
		net.WriteVector(pos)
		net.WriteString(explosionType)
		net.WriteFloat(radius)
		net.WriteFloat(BlastWaveSpeed)
		net.WriteFloat(BlastWaveThickness)
	net.SendPVS(pos)
end

local function EmitDebris(ent, count)
	if count <= 10 or not IsValid(ent) then return end
	EmitSound(DebrisSounds[math_random(#DebrisSounds)], ent:GetPos(), ent:EntIndex(), CHAN_AUTO, 1, 80)
	EmitSound(DebrisSounds[math_random(#DebrisSounds)], ent:GetPos(), ent:EntIndex(), CHAN_AUTO, 1, 80)
	EmitSound(DebrisSounds[math_random(#DebrisSounds)], ent:GetPos(), ent:EntIndex(), CHAN_AUTO, 1, 80)
end

local function ApplyBlastDamage(data, enta, tracePos, len)
	local force = tracePos - data.Pos
	local forceLen = force:Length()
	if forceLen <= 0 then
		force = enta:GetPos() - data.Pos
		forceLen = force:Length()
	end
	if forceLen <= 0 then
		force = VectorRand()
		forceLen = 1
	end
	force:Div(forceLen)

	local tr = hg.ExplosionTrace(data.Pos, tracePos, data.Filter)
	local blocked = tr.Entity != enta
	local behindwall = blocked and tr.MatType != MAT_GLASS
	local frac = math_Clamp((data.Distance - len) / data.Distance, 0, 1)
	local forceFrac = math_max(frac, data.MinForceFrac)
	local damageFrac = math_max(frac ^ data.DamageExponent, data.MinDamageFrac)
	local forceadd = force * forceFrac * data.ForceMul

	if enta.organism then
		local owner = enta.organism.owner
		if IsValid(owner) and owner:IsPlayer() and (not behindwall or not data.BlockBehindWallDisorient) then
			local div = behindwall and data.BehindWallDisorientDiv or 1
			hg.ExplosionDisorientation(enta, data.DisorientPower * frac / div, data.DisorientTime * frac / div)
			if not enta.organism.otrub then
				hg.organism.AddPanicAttack(enta.organism, math.Clamp(frac * 0.22 / div + data.Damage * damageFrac / 900, 0.04, 0.28), true)
			end
			hg.RunZManipAnim(owner, "shieldexplosion")
		end
	end

	if blocked then
		forceadd = forceadd / 5
		damageFrac = damageFrac / 5
	end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(data.Damage * damageFrac)
	dmginfo:SetDamageType(data.DamageType)
	dmginfo:SetAttacker(IsValid(data.Owner) and data.Owner or game.GetWorld())
	dmginfo:SetInflictor(IsValid(data.Ent) and data.Ent or (IsValid(data.Owner) and data.Owner or game.GetWorld()))
	dmginfo:SetDamagePosition(tracePos)
	dmginfo:SetDamageForce(forceadd)
	enta:TakeDamageInfo(dmginfo)

	if enta:IsPlayer() then
		hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
		hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)
		timer.Simple(0, function()
			if IsValid(enta) then
				hg.LightStunPlayer(enta)
			end
		end)
	end

	local phys = enta:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(forceadd)
		data.HitPhysCount = data.HitPhysCount + 1
	end
end

local function FinishBlastWave(data)
	EmitDebris(data.Ent, data.HitPhysCount)
	if data.OnFinish then
		data.OnFinish(data)
	end
end

local function ApplyBlastBurst(data)
	data.Filter = IsValid(data.Ent) and {data.Ent} or {}
	data.HitPhysCount = 0
	data.HitEnts = {}
	data.ForceMul = data.ForceMul or BlastWaveForce
	data.MinForceFrac = data.MinForceFrac or 0.5
	data.MinDamageFrac = data.MinDamageFrac or 0.5
	data.DamageExponent = data.DamageExponent or 1
	data.DisorientPower = data.DisorientPower or 5
	data.DisorientTime = data.DisorientTime or 6
	data.BehindWallDisorientDiv = data.BehindWallDisorientDiv or 1
	local hitCount = 0

	for _, enta in ipairs(ents_FindInSphere(data.Pos, data.Distance)) do
		if hitCount >= (data.MaxTargets or BlastMaxTargets) then break end
		if enta == data.Ent or not IsValid(enta) or data.HitEnts[enta] then continue end
		data.HitEnts[enta] = true
		local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
		local lenSqr = tracePos:DistToSqr(data.Pos)
		if lenSqr > data.Distance * data.Distance then continue end
		ApplyBlastDamage(data, enta, tracePos, math_sqrt(lenSqr))
		hitCount = hitCount + 1
	end

	FinishBlastWave(data)
end

local function StartShrapnel(ent, selfPos, owner, force, mass, countMul)
	if not IsValid(ent) then return end
	mass = math_max(mass or 10, 1)

	local bullet = {}
	bullet.Src = selfPos
	bullet.Spread = vecCone
	bullet.Force = 0.01
	bullet.Damage = force
	bullet.AmmoType = "Metal Debris"
	bullet.Attacker = owner
	bullet.Distance = 15000
	bullet.DisableLagComp = true
	bullet.Filter = {ent}
	table.Add(bullet.Filter, hg.drums2)

	local multi = math_min(mass / 5, 20)
	local co

	ent.ShrapnelDone = nil
	co = coroutine.create(function()
		local lastShrapnel = SysTime()
		for i = 1, multi * countMul do
			lastShrapnel = SysTime()
			if not IsValid(ent) then return end
			bullet.Dir = ent:GetAngles():Forward() * math_random(-1, 1)
			bullet.Spread = vecCone * (i / mass / 5)
			ent:FireLuaBullets(bullet, true)
			lastShrapnel = SysTime() - lastShrapnel
			if lastShrapnel > 0.001 then
				coroutine.yield()
			end
		end
		ent.ShrapnelDone = true
	end)

	coroutine.resume(co)

	local index = ent:EntIndex()
	timer.Create("GrenadeCheck_" .. index, 0, 0, function()
		if not IsValid(ent) then
			timer.Remove("GrenadeCheck_" .. index)
			return
		end
		if coroutine.status(co) != "dead" then
			coroutine.resume(co)
		end
		if ent.ShrapnelDone then
			SafeRemoveEntity(ent)
			timer.Remove("GrenadeCheck_" .. index)
		end
	end)
end

local ExpTypes = {
	Fire = function(ent, force, mass, info)
		mass = mass or 10
		info = info or {}
		local scaledMass = math_min(mass / 10, 20)
		local scaledForce = force * scaledMass
		local selfPos = ent:LocalToWorld(ent:OBBCenter())
		local owner = ent.owner or ent
		local blastDamage = scaledForce * (info.DamageMul or 1) * 2
		local rad = scaledForce * (info.RangeMul or 1) / 8
		local distance = rad / 0.01905

		hg.PlayExtraExplosionSound(selfPos, ent:EntIndex(), 1)
		hgBlastDoors(ent, selfPos, scaledForce / 50, scaledForce / 15)
		hg.ExplosionEffect(selfPos, scaledForce / 0.2, 80)
		SendExplosionNet(selfPos, GetExplosionNetType(ent, "Fire"), distance)

		if IsValid(ent) then
			local fireMulti = math_min(mass / 5, 20)
			local tr = util.QuickTrace(selfPos, -vector_up * 500, {ent})
			local fire = CreateVFire(game.GetWorld(), tr.HitPos, tr.HitNormal, 150 / 7 * fireMulti, ent)
			if IsValid(fire) then
				fire:ChangeLife(150)
			end
			for i = 1, fireMulti / 2 do
				local randvec = VectorRand(-1000, 1000)
				randvec[3] = math_random(100, 1000)
				CreateVFireBall(20, 50, selfPos + vector_up * 10, randvec)
			end
		end

		ApplyBlastBurst({
			Ent = ent,
			Owner = owner,
			Pos = selfPos,
			Distance = distance,
			Damage = blastDamage,
			DamageType = DMG_BLAST + DMG_BURN,
			ForceMul = BlastWaveForce * (info.KnockbackMul or 1),
			MinForceFrac = info.MinForceFrac or 0.5,
			MinDamageFrac = info.MinDamageFrac or 0.5,
			DamageExponent = info.DamageExponent or 1,
			BehindWallDisorientDiv = 3
		})

		util.ScreenShake(selfPos, 100, 900, 1, 5000)
		StartShrapnel(ent, selfPos, owner, scaledForce, mass, 3)
	end,
	Sharpnel = function(ent, force, mass, info)
		mass = mass or 10
		info = info or {}
		local rad = force * (info.RangeMul or 1) / 8
		local selfPos = ent:LocalToWorld(ent:OBBCenter())
		local owner = ent.owner or ent
		local distance = rad / 0.01905
		local blastDamage = force * (info.DamageMul or 1)

		hg.PlayExtraExplosionSound(selfPos, ent:EntIndex(), 1)
		hgBlastDoors(ent, selfPos, force / 50)
		hg.ExplosionEffect(selfPos, force / 0.2, 80)
		SendExplosionNet(selfPos, "Sharpnel", distance)
		ApplyBlastBurst({
			Ent = ent,
			Owner = owner,
			Pos = selfPos,
			Distance = distance,
			Damage = blastDamage,
			DamageType = DMG_BLAST,
			ForceMul = BlastWaveForce * (info.KnockbackMul or 1),
			MinForceFrac = info.MinForceFrac or 0.5,
			MinDamageFrac = info.MinDamageFrac or 0.5,
			DamageExponent = info.DamageExponent or 1,
			BlockBehindWallDisorient = true
		})

		util.ScreenShake(selfPos, 100, 900, 1, 5000)
		StartShrapnel(ent, selfPos, owner, force, mass, 5)
	end,
	Normal = function(ent, force, mass, info)
		info = info or {}
		local rad = force * (info.RangeMul or 1) / 8
		local selfPos = ent:LocalToWorld(ent:OBBCenter())
		local owner = ent.owner or ent
		local distance = rad / 0.01905
		local blastDamage = force * (info.DamageMul or 1)

		hg.PlayExtraExplosionSound(selfPos, ent:EntIndex(), 1)
		hgBlastDoors(ent, selfPos, force / 50)
		hg.ExplosionEffect(selfPos, force / 0.2, 80)
		SendExplosionNet(selfPos, "Normal", distance)
		ApplyBlastBurst({
			Ent = ent,
			Owner = owner,
			Pos = selfPos,
			Distance = distance,
			Damage = blastDamage,
			DamageType = DMG_BLAST,
			ForceMul = BlastWaveForce * (info.KnockbackMul or 1),
			MinForceFrac = info.MinForceFrac or 0.5,
			MinDamageFrac = info.MinDamageFrac or 0.5,
			DamageExponent = info.DamageExponent or 1,
			BlockBehindWallDisorient = true,
			OnFinish = function(data)
				if IsValid(data.Ent) then
					SafeRemoveEntity(data.Ent)
				end
			end
		})

		util.ScreenShake(selfPos, 100, 900, 1, 2000)
	end,
	CustomBarrel = function(ent, force, mass, info)
		info = info or {}
		local selfPos = ent:LocalToWorld(ent:OBBCenter())
		local owner = ent.owner or ent
		local scaledForce = force * (info.ForceMul or 1.35)
		local rad = scaledForce * (info.RangeMul or 1.1) / 6.5
		local distance = rad / 0.01905
		local blastDamage = scaledForce * (info.DamageMul or 1.35)

		hg.PlayExtraExplosionSound(selfPos, ent:EntIndex(), 1.2)
		hgBlastDoors(ent, selfPos, scaledForce / 35, scaledForce / 10)
		hg.ExplosionEffect(selfPos, scaledForce / 0.18, 85)
		SendExplosionNet(selfPos, GetExplosionNetType(ent, "CustomBarrel"), distance)

		for i = 1, 8 do
			CreateVFireBall(14, 24, selfPos + vector_up * 12, VectorRand(-350, 350) + Vector(0, 0, math_random(150, 350)))
		end

		local tr = util.QuickTrace(selfPos, -vector_up * 500, {ent})
		local fire = CreateVFire(game.GetWorld(), tr.HitPos, tr.HitNormal, 95, ent)
		if IsValid(fire) then
			fire:ChangeLife(95)
		end

		ApplyBlastBurst({
			Ent = ent,
			Owner = owner,
			Pos = selfPos,
			Distance = distance,
			Damage = blastDamage,
			DamageType = DMG_BLAST + DMG_BURN,
			ForceMul = BlastWaveForce * (info.KnockbackMul or 1.1),
			MinForceFrac = info.MinForceFrac or 0.2,
			MinDamageFrac = info.MinDamageFrac or 0.08,
			DamageExponent = info.DamageExponent or 1.25,
			BehindWallDisorientDiv = 2,
			OnFinish = function(data)
				if IsValid(data.Ent) then
					SafeRemoveEntity(data.Ent)
				end
			end
		})

		util.ScreenShake(selfPos, 120, 900, 1, 5000)
	end
}

function hg.PropExplosion(ent, expType, force, mass, info)
	if ent.HasExploded then return end
	ent.HasExploded = true
	ExpTypes[expType](ent, force, mass, info)
end

local function ConsumeIEDBonus(ent)
	local bonus = ent.IEDBlastBonus or 0
	local ied = ent.IEDOwner

	ent.IEDBlastBonus = nil
	ent.IEDOwner = nil

	if IsValid(ied) then
		ied.KABOOM = true
		ied.HaveTheBomb = nil
		ied:SetDialing(false)
		ied:SetDetonateAt(0)
		ent:StopSound(ied.CallSound)
		if IsValid(ied.AttachedBombVisual) then
			ied.AttachedBombVisual:Remove()
			ied.AttachedBombVisual = nil
		end
	end

	return bonus, ied
end

local expItems = {
	["models/props_c17/oildrum001_explosive.mdl"] = {ExpType = "Fire", Force = 75, RangeMul = 1.35},
	["models/props_junk/gascan001a.mdl"] = {ExpType = "Fire", Force = 40, RangeMul = 1.3},
	["models/props_junk/propane_tank001a.mdl"] = {ExpType = "Sharpnel", Force = 30, RangeMul = 1.35},
	["models/props_junk/metalgascan.mdl"] = {ExpType = "Fire", Force = 40, RangeMul = 1.3},
	["models/props_junk/PropaneCanister001a.mdl"] = {ExpType = "Sharpnel", Force = 40, RangeMul = 1.3},
	["models/props_c17/canister01a.mdl"] = {ExpType = "Sharpnel", Force = 45, RangeMul = 1.25},
	["models/props_c17/canister02a.mdl"] = {ExpType = "Sharpnel", Force = 45, RangeMul = 1.25},
	[PropaneModel] = {ExpType = "Fire", Force = 28, RangeMul = 0.5, DamageMul = 0.5, KnockbackMul = 0.85, MinForceFrac = 0.18, MinDamageFrac = 0.03, DamageExponent = 1.65}
}

hg.expItems = expItems

local function RegisterGasTank(ent)
	if not IsValid(ent) then return end
	if not GasTankModels[ent:GetModel()] then return end
	local idx = ent:EntIndex()
	if hg.GasTank.ActiveTanks[idx] then return end
	hg.GasTank.ActiveTanks[idx] = {
		Ent = ent,
		IsActive = false,
		Leaks = {}
	}
end

local function IsLeakingTankOnFire(ent)
	if not IsValid(ent) then return false end
	if not istable(ent.fires) then return false end
	local entIndex = ent:EntIndex()
	for fireEnt, _ in pairs(ent.fires) do
		if IsValid(fireEnt) and fireEnt.hgLeakSourceEntIndex != entIndex then
			return true
		end
	end
	return false
end

local function RemoveLeakFire(leak)
	if not istable(leak) then return end
	if IsValid(leak.FireEnt) then
		leak.FireEnt:Remove()
	end
	leak.FireEnt = nil
end

local function RemoveTankLeakFires(data)
	if not istable(data) or not istable(data.Leaks) then return end
	for i = 1, #data.Leaks do
		RemoveLeakFire(data.Leaks[i])
	end
end

local function EnsureLeakFire(ent, leak)
	if not IsValid(ent) or not istable(leak) or not leak.LocalHolePos then return end
	if IsValid(leak.FireEnt) then return end
	local holePos = ent:LocalToWorld(leak.LocalHolePos)
	local normal = leak.LocalNormal or Vector(0, 0, 1)
	local worldNormal = ent:LocalToWorld(leak.LocalHolePos + normal) - holePos
	if worldNormal:LengthSqr() < 0.001 then
		worldNormal = ent:GetForward()
	end
	worldNormal:Normalize()
	local fire = CreateVFire(ent, holePos, worldNormal, 35, ent)
	if IsValid(fire) then
		fire.hgLeakSourceEntIndex = ent:EntIndex()
		fire:ChangeLife(45)
		leak.FireEnt = fire
	end
end

local function IsWoodProp(ent)
	if not IsValid(ent) then return false end
	if ent:GetClass() != "prop_physics" then return false end
	if GasTankModels[ent:GetModel()] then return false end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local mat = string.lower(phys:GetMaterial() or "")
		if string.find(mat, "wood", 1, true) then return true end
	end
	local mdl = string.lower(ent:GetModel() or "")
	if string.find(mdl, "wood", 1, true) then return true end
	if string.find(mdl, "crate", 1, true) then return true end
	if string.find(mdl, "pallet", 1, true) then return true end
	return false
end

local function ResolveGasTankLeak(target, dmginfo)
	local dmgPos = dmginfo:GetDamagePosition()
	if dmginfo:IsDamageType(DMG_BLAST) then
		dmgPos = target:NearestPoint(dmgPos)
	end
	local holePos = target:NearestPoint(dmgPos)
	local center = target:WorldSpaceCenter()
	local outward = holePos - center
	if outward:LengthSqr() < 0.001 then
		outward = target:GetForward()
	end
	outward:Normalize()
	local localHole = target:WorldToLocal(holePos)
	local localNormal = target:WorldToLocal(holePos + outward) - localHole
	if localNormal:LengthSqr() < 0.001 then
		localNormal = Vector(1, 0, 0)
	else
		localNormal:Normalize()
	end
	return localHole, localNormal
end

local function RemoveCloudsForTank(idx)
	for i = #hg.GasTank.ActiveClouds, 1, -1 do
		local cloud = hg.GasTank.ActiveClouds[i]
		if cloud and cloud.TankEntIndex == idx then
			table.remove(hg.GasTank.ActiveClouds, i)
		end
	end
end

local function InsertGasCloud(cloud)
	if #hg.GasTank.ActiveClouds >= GasTankMaxClouds then
		table.remove(hg.GasTank.ActiveClouds, 1)
	end
	hg.GasTank.ActiveClouds[#hg.GasTank.ActiveClouds + 1] = cloud
end

local function AddGasCloud(data, holePos, dir, cloudType)
	if not istable(data) then return end
	local idx = data.EntIndex
	if not idx then return end
	local pos = holePos + dir * 26
	local radius = GasTankSmokeSettings.CloudRadius
	local expireAt = CurTime() + GasTankSmokeSettings.CloudLife
	local spreadDistance = GasTankSmokeSettings.SpreadDistance
	local affectRadius = GasTankSmokeSettings.SmokeAffectRadius
	if cloudType == "ground" then
		local tr = util.TraceLine({
			start = holePos + vector_up * 12,
			endpos = holePos - vector_up * 220,
			mask = MASK_SOLID_BRUSHONLY
		})
		if tr.Hit then
			pos = tr.HitPos + tr.HitNormal * 3 + VectorRand() * GasTankSmokeSettings.GroundCloudRadius
			pos.z = tr.HitPos.z + 3
		else
			pos = holePos
		end
		radius = GasTankSmokeSettings.CloudRadius * 0.9
		expireAt = CurTime() + GasTankSmokeSettings.GroundCloudLife
		affectRadius = GasTankSmokeSettings.GroundAffectRadius
	elseif cloudType == "air" then
		pos = holePos + dir * GasTankSmokeSettings.AirCloudLift + vector_up * 14
		spreadDistance = GasTankSmokeSettings.AirSpreadDistance
		affectRadius = GasTankSmokeSettings.AirAffectRadius
	end
	InsertGasCloud({
		Pos = pos,
		Radius = radius,
		AffectRadius = affectRadius,
		ExpireAt = expireAt,
		NextPlayerAt = 0,
		NextIgniteAt = 0,
		NextSpreadAt = CurTime() + GasTankSmokeSettings.SpreadTick,
		TankEntIndex = idx,
		Owner = data.Owner,
		LeakMode = data.LeakMode,
		CloudType = cloudType,
		SpreadLeft = GasTankSmokeSettings.SpreadDepth,
		SpreadDistance = spreadDistance
	})
end

local function SpreadGasCloud(cloud)
	if not cloud or (cloud.SpreadLeft or 0) <= 0 then return end
	cloud.NextSpreadAt = CurTime() + GasTankSmokeSettings.SpreadTick
	for i = 1, GasTankSmokeSettings.SpreadChildrenPerTick do
		if #hg.GasTank.ActiveClouds >= GasTankMaxClouds then break end
		local offset = VectorRand() * (cloud.SpreadDistance or GasTankSmokeSettings.SpreadDistance)
		local pos = cloud.Pos + offset
		if cloud.CloudType == "ground" then
			offset.z = 0
			local tr = util.TraceLine({
				start = cloud.Pos + offset + vector_up * 48,
				endpos = cloud.Pos + offset - vector_up * 280,
				mask = MASK_SOLID_BRUSHONLY
			})
			if tr.Hit then
				pos = tr.HitPos + tr.HitNormal * 3
			else
				pos.z = cloud.Pos.z
			end
		elseif cloud.CloudType == "air" then
			pos.z = pos.z + math_random(-12, 18)
		else
			pos.z = pos.z + math_random(-8, 8)
		end
		InsertGasCloud({
			Pos = pos,
			Radius = math_max((cloud.Radius or GasTankSmokeSettings.CloudRadius) * 0.88, GasTankSmokeSettings.MinSpreadRadius),
			AffectRadius = math_max((cloud.AffectRadius or GasTankSmokeSettings.SmokeAffectRadius) * 0.9, GasTankSmokeSettings.GroundAffectRadius * 0.75),
			ExpireAt = math_min(cloud.ExpireAt, CurTime() + GasTankSmokeSettings.CloudLife * 0.6),
			NextPlayerAt = 0,
			NextIgniteAt = 0,
			NextSpreadAt = CurTime() + GasTankSmokeSettings.SpreadTick,
			TankEntIndex = cloud.TankEntIndex,
			Owner = cloud.Owner,
			LeakMode = cloud.LeakMode,
			CloudType = cloud.CloudType,
			SpreadLeft = cloud.SpreadLeft - 1,
			SpreadDistance = cloud.SpreadDistance
		})
	end
	cloud.SpreadLeft = cloud.SpreadLeft - 1
end

local function SpawnGroundGasEffects(holePos)
	local tr = util.TraceLine({
		start = holePos + vector_up * 12,
		endpos = holePos - vector_up * 220,
		mask = MASK_SOLID_BRUSHONLY
	})
	if not tr.Hit then return end
	for i = 1, GasTankSmokeSettings.GroundCloudsPerTick do
		local offset = VectorRand() * GasTankSmokeSettings.GroundCloudRadius
		offset.z = 0
		local smoke = EffectData()
		smoke:SetOrigin(tr.HitPos + tr.HitNormal * 2 + offset)
		smoke:SetNormal(VectorRand():GetNormalized())
		smoke:SetMagnitude(GasTankSmokeSettings.Magnitude * 0.85)
		util.Effect("eff_hg_co2_ground", smoke, true, true)
	end
end

local function SpawnRoomFirePatch(pos, owner)
	for i = 1, GasTankRoomFireCount do
		local offset = VectorRand() * GasTankRoomFireRadius
		offset.z = math_random(-20, 20)
		local startPos = pos + offset + vector_up * 32
		local tr = util.TraceLine({
			start = startPos,
			endpos = startPos - vector_up * 300,
			mask = MASK_SOLID_BRUSHONLY
		})
		if tr.Hit then
			local fire = CreateVFire(game.GetWorld(), tr.HitPos, tr.HitNormal, 70, owner or game.GetWorld())
			if IsValid(fire) then
				fire:ChangeLife(GasTankRoomFireLife)
			end
		end
	end
end

local function IsGasIgnitionSource(ent)
	if not IsValid(ent) then return false end
	local class = ent:GetClass()
	if class == "ent_zcity_match" and ent.GetFireLeft and ent:GetFireLeft() > 0 then
		return true
	end
	if class == "vfire" or class == "vfire_ball" then
		return true
	end
	if istable(ent.fires) and next(ent.fires) != nil then
		return true
	end
	return false
end

local function IsGasIgnitionSourceForCloud(ent, cloud)
	if not IsGasIgnitionSource(ent) then return false end
	if not cloud then return true end
	if cloud.LeakMode == "fire" then return false end
	if ent.hgLeakSourceEntIndex and ent.hgLeakSourceEntIndex == cloud.TankEntIndex then return false end
	return true
end

local function TryLeakIgniteNearby(ent, data, holePos, dir)
	if not IsValid(ent) or not istable(data) then return end
	local curTime = CurTime()
	if curTime < (data.NextLeakIgniteThink or 0) then return end
	data.NextLeakIgniteThink = curTime + 0.25
	data.NextIgniteTimes = data.NextIgniteTimes or {}
	local ignitePos = holePos + dir * 35
	local ignitedCount = 0
	for _, v in ipairs(ents.FindInSphere(ignitePos, 120)) do
		if v == ent or not IsValid(v) then continue end
		local idx = v:EntIndex()
		if curTime < (data.NextIgniteTimes[idx] or 0) then continue end
		local targetPos = v.WorldSpaceCenter and v:WorldSpaceCenter() or v:GetPos()
		local tr = util.TraceLine({
			start = holePos,
			endpos = targetPos,
			filter = {ent}
		})
		if tr.Hit and tr.Entity != v then continue end
		if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
			if not (istable(v.fires) and next(v.fires) != nil) then
				local downTrace = util.QuickTrace(targetPos + vector_up * 12, -vector_up * 80, {ent, v})
				local firePos = downTrace.Hit and downTrace.HitPos or targetPos
				local fireNormal = downTrace.Hit and downTrace.HitNormal or vector_up
				local fire = CreateVFire(game.GetWorld(), firePos, fireNormal, 50, ent)
				if IsValid(fire) then
					fire:ChangeLife(55)
				end
			end
			data.NextIgniteTimes[idx] = curTime + 1.35
			ignitedCount = ignitedCount + 1
		elseif IsWoodProp(v) then
			if not (istable(v.fires) and next(v.fires) != nil) then
				local nearest = v:NearestPoint(holePos)
				local normal = nearest - v:WorldSpaceCenter()
				if normal:LengthSqr() < 0.001 then
					normal = vector_up
				else
					normal:Normalize()
				end
				local fire = CreateVFire(game.GetWorld(), nearest, normal, 45, ent)
				if IsValid(fire) then
					fire:ChangeLife(45)
				end
			end
			data.NextIgniteTimes[idx] = curTime + 1.5
			ignitedCount = ignitedCount + 1
		end
		if ignitedCount >= 2 then break end
	end
end

local function IgniteGasCloud(cloud, source)
	if not cloud then return end
	local idx = cloud.TankEntIndex
	local data = hg.GasTank.ActiveTanks[idx]
	local owner = cloud.Owner
	if IsValid(source) then
		if source.debil and IsValid(source.debil) then
			owner = source.debil
		elseif source.GetOwner then
			local sourceOwner = source:GetOwner()
			if IsValid(sourceOwner) then
				owner = sourceOwner
			end
		end
	end
	SpawnRoomFirePatch(cloud.Pos, owner)
	if data and IsValid(data.Ent) then
		if IsValid(owner) then
			data.Ent.LastAttacker = owner
		end
		hg.GasTankDetonate(data.Ent)
	end
	RemoveCloudsForTank(idx)
end

function hg.GasTankDetonate(ent)
	if not IsValid(ent) or ent.IsExploding then return end
	ent.IsExploding = true
	local idx = ent:EntIndex()
	local data = hg.GasTank.ActiveTanks[idx]
	RemoveTankLeakFires(data)
	RemoveCloudsForTank(idx)
	local baseGas = (data and data.BaseGasAmount) or (ent.Volume or 75)
	local curGas = (data and data.GasAmount) or baseGas
	local ratio = math_Clamp(curGas / baseGas, 0.55, 1)

	net.Start("hg_gastank_stop")
	net.WriteUInt(idx, 16)
	net.SendPVS(ent:GetPos())

	hg.GasTank.ActiveTanks[idx] = nil

	local phys = ent:GetPhysicsObject()
	local mass = IsValid(phys) and phys:GetMass() or 30
	local iedBonus, ied = ConsumeIEDBonus(ent)
	hg.PropExplosion(ent, "CustomBarrel", (baseGas * 2.15 * ratio) + iedBonus, mass, {
		RangeMul = 1.15,
		DamageMul = 1.2,
		KnockbackMul = 1.1,
		MinForceFrac = 0.2,
		MinDamageFrac = 0.08,
		DamageExponent = 1.2
	})
	if IsValid(ied) then
		ied:Remove()
	end
end

hook.Add("OnEntityCreated", "hg_gastank_spawn", function(ent)
	timer.Simple(0, function()
		RegisterGasTank(ent)
	end)
end)

hook.Add("InitPostEntity", "hg_gastank_mapinit", function()
	timer.Simple(1, function()
		for mdl, _ in pairs(GasTankModels) do
			for _, ent in ipairs(ents.FindByModel(mdl)) do
				RegisterGasTank(ent)
			end
		end
	end)
end)

timer.Simple(0, function()
	for mdl, _ in pairs(GasTankModels) do
		for _, ent in ipairs(ents.FindByModel(mdl)) do
			RegisterGasTank(ent)
		end
	end
end)

hook.Add("Think", "hg_gastank_mainloop", function()
	local curTime = CurTime()

	for i = #hg.GasTank.ActiveClouds, 1, -1 do
		local cloud = hg.GasTank.ActiveClouds[i]
		if not cloud or curTime > (cloud.ExpireAt or 0) then
			table.remove(hg.GasTank.ActiveClouds, i)
			continue
		end

		if curTime >= (cloud.NextSpreadAt or 0) then
			SpreadGasCloud(cloud)
		end

		if curTime >= (cloud.NextPlayerAt or 0) then
			cloud.NextPlayerAt = curTime + GasTankSmokeSettings.PlayerTick
			for _, ply in ipairs(ents_FindInSphere(cloud.Pos, cloud.AffectRadius or cloud.Radius)) do
				if ply:IsPlayer() and ply:Alive() and ply.organism then
					ply.organism.lastCOBreathe = curTime
				end
			end
		end

		if curTime >= (cloud.NextIgniteAt or 0) then
			cloud.NextIgniteAt = curTime + GasTankSmokeSettings.IgniteTick
			for _, ent in ipairs(ents_FindInSphere(cloud.Pos, cloud.Radius)) do
				if IsGasIgnitionSourceForCloud(ent, cloud) then
					IgniteGasCloud(cloud, ent)
					break
				end
			end
		end
	end

	for idx, data in pairs(hg.GasTank.ActiveTanks) do
		local ent = data.Ent
		if not IsValid(ent) then
			RemoveTankLeakFires(data)
			RemoveCloudsForTank(idx)
			hg.GasTank.ActiveTanks[idx] = nil
			continue
		end

		if not data.IsActive and IsLeakingTankOnFire(ent) then
			hg.GasTankDetonate(ent)
			continue
		end

		if not data.IsActive then continue end

		if curTime < (data.NextMainThinkAt or 0) then continue end
		local prevThinkAt = data.LastMainThinkAt or curTime
		local thinkDelta = math_max(curTime - prevThinkAt, GasTankMainThinkInterval)
		local thinkScale = math_Clamp(thinkDelta / GasTankMainThinkInterval, 0.65, 3.5)
		data.LastMainThinkAt = curTime
		data.NextMainThinkAt = curTime + GasTankMainThinkInterval

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) and istable(data.Leaks) then
			local pushForce = GasTankPushForce[ent:GetModel()] or GasTankPushForce.Default
			for i = 1, #data.Leaks do
				local leak = data.Leaks[i]
				if leak and leak.LocalHolePos then
					local holePos = ent:LocalToWorld(leak.LocalHolePos)
					local dir = (ent:LocalToWorld(leak.LocalHolePos + leak.LocalNormal) - holePos):GetNormalized()
					dir = (dir + VectorRand() * 0.1):GetNormalized()
					phys:ApplyForceCenter(dir * pushForce * thinkScale)
					phys:AddAngleVelocity(VectorRand() * GasTankAngularVelocityScale * thinkScale)

					if leak.Mode == "fire" and curTime > (data.NextBurnTime or 0) then
						data.NextBurnTime = curTime + 0.1
						TryLeakIgniteNearby(ent, data, holePos, dir)
						local smoke = EffectData()
						smoke:SetOrigin(holePos + dir * 18)
						smoke:SetNormal(dir)
						smoke:SetMagnitude(GasTankSmokeSettings.Magnitude * 0.75)
						smoke:SetEntity(ent)
						util.Effect("eff_hg_co2_leak", smoke, true, true)
						AddGasCloud(data, holePos, dir, "air")
						if data.GasAmount then
							data.GasAmount = math_max(0, data.GasAmount - GasTankSmokeSettings.DrainPerTick * 0.8)
						end
					end

					if leak.Mode == "smoke" and curTime > (leak.NextSmokeTime or 0) then
						if (data.GasAmount or 0) <= 0 then
							leak.Mode = "empty"
							continue
						end
						leak.NextSmokeTime = curTime + GasTankSmokeSettings.NextTick
						local smoke = EffectData()
						smoke:SetOrigin(holePos)
						smoke:SetNormal(dir)
						smoke:SetMagnitude(GasTankSmokeSettings.Magnitude)
						smoke:SetEntity(ent)
						util.Effect("eff_hg_co2_leak", smoke, true, true)
						AddGasCloud(data, holePos, dir, "smoke")
						SpawnGroundGasEffects(holePos)
						for i = 1, GasTankSmokeSettings.GroundCloudsPerTick do
							AddGasCloud(data, holePos, dir, "ground")
						end
						if data.GasAmount then
							data.GasAmount = math_max(0, data.GasAmount - GasTankSmokeSettings.DrainPerTick)
						end
					end
				end
			end
		end

		if (data.GasAmount or 0) <= 0 and data.LeakMode == "smoke" then
			data.IsActive = false
			RemoveTankLeakFires(data)
			data.Leaks = {}
			net.Start("hg_gastank_stop")
			net.WriteUInt(idx, 16)
			net.SendPVS(ent:GetPos())
			continue
		end

		if data.ExplodeAt and curTime > data.ExplodeAt then
			local hasFire = false
			for i = 1, #data.Leaks do
				if data.Leaks[i] and data.Leaks[i].Mode == "fire" then
					hasFire = true
					break
				end
			end
			if hasFire then
				hg.GasTankDetonate(ent)
			else
				data.ExplodeAt = curTime + 1
			end
		end
	end
end)

hook.Add("PostCleanupMap", "hg_gastank_reset", function()
	for _, data in pairs(hg.GasTank.ActiveTanks) do
		RemoveTankLeakFires(data)
	end
	hg.GasTank.ActiveTanks = {}
	hg.GasTank.ActiveClouds = {}
end)

hook.Add("EntityTakeDamage", "ExplosiveDamage", function(target, dmginfo)
	if IsValid(target) then
		local tankData = hg.GasTank.ActiveTanks[target:EntIndex()]
		if tankData then
			if not tankData.IsActive and (dmginfo:IsDamageType(DMG_BURN) or IsLeakingTankOnFire(target)) then
				hg.GasTankDetonate(target)
				dmginfo:SetDamage(0)
				return true
			end

			if dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_BUCKSHOT) or dmginfo:IsDamageType(DMG_BLAST) then
				if not tankData.IsActive then
					tankData.IsActive = true
					tankData.EntIndex = target:EntIndex()
					tankData.NextBurnTime = 0
					tankData.NextLeakBroadcastAt = 0
					tankData.Owner = dmginfo:GetAttacker()
					if not tankData.BaseGasAmount then
						tankData.BaseGasAmount = target.Volume or 75
						tankData.GasAmount = tankData.BaseGasAmount
					end
					local attacker = dmginfo:GetAttacker()
					if IsValid(attacker) then
						target.LastAttacker = attacker
						tankData.Owner = attacker
					end
				end

				local localHole, localNormal = ResolveGasTankLeak(target, dmginfo)
				local mode = tankData.LeakMode or (RNG(100) <= 45 and "fire" or "smoke")
				tankData.LeakMode = mode
				tankData.ExplodeAt = mode == "fire" and (tankData.ExplodeAt or (CurTime() + math.Rand(GasTankExplodeDelayMin, GasTankExplodeDelayMax))) or nil
				if #tankData.Leaks >= GasTankMaxLeaks then
					local removedLeak = table.remove(tankData.Leaks, 1)
					RemoveLeakFire(removedLeak)
				end
				tankData.Leaks[#tankData.Leaks + 1] = {
					LocalHolePos = localHole,
					LocalNormal = localNormal,
					Mode = mode,
					Time = CurTime()
				}

				local curTime = CurTime()
				if curTime >= (tankData.NextLeakBroadcastAt or 0) then
					tankData.NextLeakBroadcastAt = curTime + GasTankLeakBroadcastRate
					net.Start("hg_gastank_leak")
					net.WriteEntity(target)
					net.WriteVector(localHole)
					net.WriteVector(localNormal)
					net.WriteString(mode)
					net.SendPVS(target:GetPos())
				end

				local phys = target:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
					phys:EnableMotion(true)
				end

				dmginfo:SetDamage(0)
				return true
			end

			if tankData.IsActive then
				dmginfo:SetDamage(0)
				return true
			end
		end
	end

	if IsValid(target) and expItems[target:GetModel()] then
		hook.Run("ExplosivesTakeDamage", target, dmginfo)
		local rnd = CurrentRound and CurrentRound()
		if (rnd and rnd.name == "coop" and dmginfo:IsDamageType(DMG_BLAST_SURFACE + DMG_BLAST + DMG_BURN + DMG_BULLET + DMG_BUCKSHOT + DMG_AIRBOAT) or dmginfo:IsDamageType(DMG_BLAST_SURFACE + DMG_BLAST + DMG_BURN)) and not target.babahnut then
			target.hp = target.hp or 50
			target.hp = target.hp - (dmginfo:GetDamage() / (dmginfo:IsDamageType(DMG_BURN) and 12.5 or 0.5))
			if target.hp <= 0 and (not target.Volume or target.Volume > 0) and not target.babahnut then
				local tbl = expItems[target:GetModel()]
				local phys = target:GetPhysicsObject()
				local mass = IsValid(phys) and phys:GetMass() or 10
				local iedBonus, ied = ConsumeIEDBonus(target)
				target.babahnut = true
				hg.PropExplosion(target, tbl.ExpType, ((target.Volume or tbl.Force) * 2) + iedBonus, mass, tbl)
				if IsValid(ied) then
					ied:Remove()
				end
			end
		end
		dmginfo:ScaleDamage(0)
		return true
	end
end)
