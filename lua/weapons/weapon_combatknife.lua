if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "M7 Bayonet"
SWEP.Instructions = "This is your trusty carbon-steel fixed-blade knife.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false


SWEP.SuicidePos = Vector(-7, -11, 2)
SWEP.SuicideAng = Angle(0, 60, 0)
SWEP.SuicideCutVec = Vector(1, -5, 4)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicidePunchAng = Angle(-5, -15, 0)
SWEP.CantClash = true

SWEP.WorldModel = "models/weapons/hammer/w.mdl"
SWEP.WorldModelReal = "models/weapons/cs2/c_melee_knife_m7_bayo.mdl"
SWEP.DroppedWorldModel = "models/weapons/cs2/c_melee_knife_m7_bayo.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "revolver"
SWEP.weight = 0.4

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 0.95
SWEP.WaitTime1 = 0.75
SWEP.AttackLen1 = 40

SWEP.AnimTime2 = 0.85
SWEP.Attack2Time = 0.15
SWEP.WaitTime2 = 0.7

SWEP.AttackTimeLength = 0.16
SWEP.Attack2TimeLength = 0.1

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 15
SWEP.ArteryChance = 1.65

SWEP.swingsoundextra = {
    {"knife/knife_bayonet_swing1.ogg", 60, {80, 90}},
    {"knife/knife_bayonet_swing2.ogg", 60, {80, 90}},
}

SWEP.hitsoundextra = {
    {"knife/KnifeStabIn-1.wav", 55, {105, 115}},
    {"knife/KnifeStabIn-2.wav", 55, {105, 115}},
    {"knife/KnifeStabIn-3.wav", 55, {105, 115}},
}

SWEP.BlockTier = 2
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {145, 155}}


SWEP.PenetrationPrimary = 8
SWEP.PenetrationSecondary = 4
SWEP.MaxPenLen = 6
SWEP.PenetrationSizePrimary = 0.75
SWEP.PenetrationSizeSecondary = 2.5

SWEP.StaminaPrimary = 18
SWEP.StaminaSecondary = 8.5

SWEP.ViewPunch1 = Angle(2,0,0)
SWEP.ViewPunch2 = Angle(0,1,0)
SWEP.AttackSize = 5

SWEP.basebone = 76
SWEP.noreverse = true

SWEP.weaponPos = Vector(-1,0,0)
SWEP.weaponAng = Angle(90,-90,0)
SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw_short",
    ["attack"] = "melee_01",
    ["attack2"] = "melee_02",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_cod2019_m7_bayonet.png")
	SWEP.IconOverride = "entities/arc9_cod2019_m7_bayonet.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AttackSwing = "weapons/slam/throw.wav"
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_slash.wav"
SWEP.DeploySnd = "snd_jack_hmcd_knifedraw.wav"


SWEP.SwingAng = -55

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false


SWEP.sprint_ang = Angle(30,0,0)
SWEP.HoldPos = Vector(-1.5,0,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.LHIKLerpSpeed = 0.15
SWEP.LHIKBlockPos = Vector(4, -7 , 6)
SWEP.LHIKBlockAng = Angle(-35,55,-90)
SWEP.LHIKSuicidePos = Vector(7, -8 , 5)
SWEP.LHIKSuicideAng = Angle(-35,55,-180)
SWEP.basebone = 1


SWEP.CanSuicide = true

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 5 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -1 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -11 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 20 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 60 or 0)
    return true
end

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

function SWEP:CanPrimaryAttack()
    if hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CanSecondaryAttack()
    if not self.allowsec then return false end
    self.Attack2HitFlesh = "knife/NEWRapierSlash"..math.random(1, 6)..".wav"
    return true
end

function SWEP:DrawWorldModel2()
    local oldExchange = self.WorldModelExchange
    self.WorldModelExchange = not IsValid(self:GetOwner()) and self.DroppedWorldModel or false
    self.BaseClass.DrawWorldModel2(self)
    self.WorldModelExchange = oldExchange
end
