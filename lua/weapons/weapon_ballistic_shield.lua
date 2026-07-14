if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Ballistic Shield"
SWEP.Instructions = "Anti-ballistic shield for police entry teams. Stops pistol caliber rounds while deployed, covers your back when holstered.\n\nLMB to shove.\nRMB to brace."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 3

SWEP.WorldModel = "models/weapons/arccw_go/v_shield.mdl"
SWEP.WorldModelReal = "models/weapons/arccw_go/v_shield.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "melee2"
SWEP.weight = 5

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.CanSuicide = false
SWEP.WorkWithFake = true
SWEP.WepSelectIcon = Material("entities/shit.png")
SWEP.WepSelectIcon2 = Material("entities/shit.png")
SWEP.IconOverride = "entities/shit.png"

SWEP.HoldPos = Vector(5, 1, 2)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.AnimList = {
	["idle"] = "idle",
	["deploy"] = "deploy",
	["attack"] = "bash",
	["attack2"] = "bash",
}

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 1
SWEP.WaitTime1 = 0.9
SWEP.AttackLen1 = 40
SWEP.ViewPunch1 = Angle(1, 1, 0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.9
SWEP.AttackLen2 = 40
SWEP.ViewPunch2 = Angle(1, -1, 0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.15
SWEP.AttackRads = 40
SWEP.AttackRads2 = 40
SWEP.SwingAng = 0
SWEP.SwingAng2 = 0

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 20
SWEP.DamageSecondary = 15
SWEP.PenetrationPrimary = 1
SWEP.PenetrationSecondary = 1
SWEP.MaxPenLen = 1
SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 3
SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 20
SWEP.PainMultiplier = 1.2

SWEP.AttackSwing = "weapons/slam/throw.wav"
SWEP.AttackHit = "physics/metal/metal_barrel_impact_hard7.wav"
SWEP.Attack2Hit = "physics/metal/metal_barrel_impact_hard7.wav"
SWEP.AttackHitFlesh = "physics/body/body_medium_break3.wav"
SWEP.Attack2HitFlesh = "physics/body/body_medium_break3.wav"
SWEP.DeploySnd = "physics/metal/metal_canister_impact_soft2.wav"


SWEP.ShieldMaxSpeed = 600

SWEP.ShieldFrontDot = -0.25
SWEP.ShieldBackDot = 0.35

local shieldClass = "weapon_ballistic_shield"

local BackBone = "ValveBiped.Bip01_Spine2"
local BackPos = Vector(10, -1, 1)
local BackAng = Angle(0, -90, -90)

local function ShieldBlocksBullet(ply, data)
	if not ply:Alive() then return false end

	local shield = ply:GetWeapon(shieldClass)
	if not IsValid(shield) then return false end

	local ammo = hg.ammotypeshuy and hg.ammotypeshuy[data.AmmoType or ""]
	local speed = ammo and ammo.BulletSettings and ammo.BulletSettings.Speed or 400
	if speed > (shield.ShieldMaxSpeed or 600) then return false end

	local dir = data.Trace.Normal

	local fake = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll
		or (IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() and ply.OldRagdoll)

	if fake then
		if ply:GetActiveWeapon() == shield then return false end

		local boneId = fake:LookupBone(BackBone)
		if not boneId then return false end

		local matrix = fake:GetBoneMatrix(boneId)
		if not matrix then return false end

		local backOut = matrix:GetAngles():Right()

		return dir:Dot(backOut) < -(shield.ShieldBackDot or 0.35)
	end

	local fwd = ply:GetAimVector()

	local flatDir = Vector(dir.x, dir.y, 0):GetNormalized()
	local flatFwd = Vector(fwd.x, fwd.y, 0):GetNormalized()
	local dot = flatDir:Dot(flatFwd)

	if ply:GetActiveWeapon() == shield then
		return dot < (shield.ShieldFrontDot or -0.25)
	end

	return dot > (shield.ShieldBackDot or 0.35)
end

hook.Add("PostEntityFireBullets", "hg_shield_block", function(shooter, data)
	local ply = data.Trace.Entity

	if IsValid(ply) and not ply:IsPlayer() and ply.IsRagdoll and ply:IsRagdoll() then
		local owner = hg.RagdollOwner and hg.RagdollOwner(ply)
		if IsValid(owner) and owner:IsPlayer() then ply = owner end
	end

	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not ShieldBlocksBullet(ply, data) then return end

	if SERVER or IsFirstTimePredicted() then
		local fx = EffectData()
		fx:SetOrigin(data.Trace.HitPos)
		fx:SetNormal(-data.Trace.Normal)
		util.Effect("StunstickImpact", fx)
	end

	if SERVER then
		sound.Play("physics/metal/metal_solid_impact_bullet" .. math.random(2, 4) .. ".wav", data.Trace.HitPos, 80, math.random(90, 110))
	end

	return false
end)

if CLIENT then
	local backModels = {}

	local function DrawBackShield(ply)
		local csmdl = backModels[ply]

		if not IsValid(ply) or not ply:Alive() then
			if IsValid(csmdl) then csmdl:SetNoDraw(true) end
			return
		end

		local wep = ply.GetWeapon and ply:GetWeapon(shieldClass)
		if not IsValid(wep) or ply:GetActiveWeapon() == wep then
			if IsValid(csmdl) then csmdl:SetNoDraw(true) end
			return
		end

		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		local boneId = ent:LookupBone(BackBone)
		if not boneId then return end

		local matrix = ent:GetBoneMatrix(boneId)
		if not matrix then return end

		if not IsValid(csmdl) then
			csmdl = ClientsideModel(wep.WorldModel)
			if not IsValid(csmdl) then return end
			csmdl:SetNoDraw(true)
			backModels[ply] = csmdl
		end

		local pos, ang = LocalToWorld(BackPos, BackAng, matrix:GetTranslation(), matrix:GetAngles())

		csmdl:SetRenderOrigin(pos)
		csmdl:SetRenderAngles(ang)
		csmdl:SetupBones()
		csmdl:DrawModel()
	end

	hook.Add("PostPlayerDraw", "hg_shield_back", function(ply)
		if IsValid(ply.FakeRagdoll) then return end
		DrawBackShield(ply)
	end)

	hook.Add("PostDrawTranslucentRenderables", "hg_shield_back_fake", function(bDepth, bSkybox)
		if bSkybox then return end

		for _, ply in player.Iterator() do
			if IsValid(ply.FakeRagdoll) then
				DrawBackShield(ply)
			end
		end
	end)

	timer.Create("hg_shield_back_cleanup", 5, 0, function()
		for ply, csmdl in pairs(backModels) do
			if not IsValid(ply) then
				if IsValid(csmdl) then csmdl:Remove() end
				backModels[ply] = nil
			end
		end
	end)
end
