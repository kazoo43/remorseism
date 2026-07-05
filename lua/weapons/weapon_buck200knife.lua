if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Buck 120 General"
SWEP.Instructions = "Large hunting knife, has a blood drain, which allows you to make stabs with strong bleeding. Used in the movie Scream as the killer's primary weapon.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/hammer/w.mdl"
SWEP.WorldModelReal = "models/weapons/gleb/c_knife_t.mdl"
SWEP.WorldModelExchange = "models/zcity/weapons/custom_knife/buck.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 1.2
SWEP.modelscale2 = 1

SWEP.SuicidePos = Vector(16, -1, -3)
SWEP.SuicideAng = Angle(-40, 180, 0)
SWEP.SuicideCutVec = Vector(1, -5, 4)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicidePunchAng = Angle(-5, -15, 0)

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 0


SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 0

SWEP.BleedMultiplier = 1.5
SWEP.PainMultiplier = 1.8

SWEP.DamagePrimary = 23
SWEP.DamageSecondary = 10

SWEP.BlockTier = 2
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {145, 155}}

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.basebone = 76

SWEP.HoldPos = Vector(-2,-5,-5)
SWEP.HoldAng = Angle(-15,20,-10)

SWEP.AttackPos = Vector(0,0,0)
SWEP.AttackingPos = Vector(0,0,0)

SWEP.weaponPos = Vector(-1,0,0)
SWEP.weaponAng = Angle(90,-90,0)

SWEP.HoldType = "revolver"

--SWEP.InstantPainMul = 0.25

--models/weapons/gleb/c_knife_t.mdl
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_buck120.png")
	SWEP.IconOverride = "vgui/icons/ico_buck120.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.BreakBoneMul = 0.26
SWEP.ImmobilizationMul = 0.45
SWEP.StaminaMul = 0.5
SWEP.HadBackBonus = true

SWEP.attack_ang = Angle(0,0,0)
function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self.Initialzed = true
    self:PlayAnim("idle",10,true)

    self:SetHold(self.HoldType)

    self:InitAdd()
end

SWEP.swingsoundextra = {
    {"knife/knife_bayonet_swing1.ogg", 60, {80, 90}},
    {"knife/knife_bayonet_swing2.ogg", 60, {80, 90}},
}

SWEP.hitsoundextra = {
    {"knife/KnifeStabIn-1.wav", 55, {105, 115}},
    {"knife/KnifeStabIn-2.wav", 55, {105, 115}},
    {"knife/KnifeStabIn-3.wav", 55, {105, 115}},
}

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 1
SWEP.WaitTime1 = 0.76

SWEP.ArteryChance = 1.85

SWEP.AnimTime2 = 0.85
SWEP.Attack2Time = 0.15
SWEP.WaitTime2 = 0.56
SWEP.noreverse = true

SWEP.Attack2HitFlesh = "knife/NEWRapierSlash1.wav"

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab_miss",
    ["attack2"] = "midslash1",
}

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -4 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 15 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -7 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 60 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 90 or 0)
	addAngLerp.x = addAngLerp.x + (self:GetBlocking() and -60 or 0)
    
    return true
end

function SWEP:CanSecondaryAttack()
    if not self.allowsec then return false end
    self.Attack2HitFlesh = "knife/NEWRapierSlash"..math.random(1, 6)..".wav"
    return true
end

SWEP.AttackTimeLength = 0.16
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 35
SWEP.AttackRads2 = 65
SWEP.CantClash = true

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

SWEP.LHIKLerpSpeed = 0.1
SWEP.LHIKBlockPos = Vector(-10, 1 , 10)
SWEP.LHIKBlockAng = Angle(65,155,-245)
SWEP.LHIKSuicidePos = Vector(-4, 1 , 14)
SWEP.LHIKSuicideAng = Angle(75,155,-245)

function SWEP:GetLHIKStateOffset()
    local owner = self:GetOwner()
    if not IsValid(owner) then return vector_origin, angle_zero end
    if self.CanSuicide and owner.suiciding then
        return self.LHIKSuicidePos or vector_origin, self.LHIKSuicideAng or angle_zero
    end
    if self.GetBlocking and self:GetBlocking() then
        return self.LHIKBlockPos or vector_origin, self.LHIKBlockAng or angle_zero
    end
    return vector_origin, angle_zero
end

function SWEP:DrawPostWorldModel()
    if not self.setlh then return end

    local wm = self:GetWM()
    if not IsValid(wm) then return end

    local offsetPos, offsetAng = self:GetLHIKStateOffset()
    local lerpSpeed = self.LHIKLerpSpeed or 0.15
    self.LHIKLerpedPos = LerpFT(lerpSpeed, self.LHIKLerpedPos or Vector(), offsetPos)
    self.LHIKLerpedAng = LerpFT(lerpSpeed, self.LHIKLerpedAng or Angle(), offsetAng)
    offsetPos = self.LHIKLerpedPos or vector_origin
    offsetAng = self.LHIKLerpedAng or angle_zero

    if offsetPos:LengthSqr() <= 0.0001 and math.abs(offsetAng.p) <= 0.001 and math.abs(offsetAng.y) <= 0.001 and math.abs(offsetAng.r) <= 0.001 then return end

    local handBone = wm:LookupBone("ValveBiped.Bip01_L_Hand")
    if not handBone then return end

    local handMatrix = wm:GetBoneMatrix(handBone)
    if not handMatrix then return end

    local basePos = handMatrix:GetTranslation()
    local baseAng = handMatrix:GetAngles()
    local movedPos, movedAng = LocalToWorld(offsetPos, offsetAng, basePos, baseAng)

    for _, boneName in ipairs(hg.TPIKBonesLH or {}) do
        local boneIndex = wm:LookupBone(boneName)
        if not boneIndex then continue end

        local boneMatrix = wm:GetBoneMatrix(boneIndex)
        if not boneMatrix then continue end

        local relPos, relAng = WorldToLocal(boneMatrix:GetTranslation(), boneMatrix:GetAngles(), basePos, baseAng)
        local newPos, newAng = LocalToWorld(relPos, relAng, movedPos, movedAng)

        boneMatrix:SetTranslation(newPos)
        boneMatrix:SetAngles(newAng)
        wm:SetBoneMatrix(boneIndex, boneMatrix)
    end
end