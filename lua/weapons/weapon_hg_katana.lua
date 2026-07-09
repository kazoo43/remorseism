if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Katana"
SWEP.Instructions = "A traditional Japanese katana featuring a curved, single-edged blade designed for precision and balance. Lightweight and efficient, it allows for quick, controlled swings and smooth handling in close-range use.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/hatedmekkr/boneworks/weapons/melee/blades/swords/bw_wpn_swd_katana.mdl"
SWEP.WorldModelReal = "models/swordtemp/c_kf2_katana.mdl"
SWEP.WorldModelExchange = "models/hatedmekkr/boneworks/weapons/melee/blades/swords/bw_wpn_swd_katana.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(20, 1, -27)
SWEP.SuicideAng = Angle(-90, -180, 90)
SWEP.SuicideCutVec = Vector(3, -6, 0)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "weapons/knife/knife_hit1.wav"
SWEP.CanSuicide = false
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.NoHolster = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-6,1,-4)
SWEP.HoldAng = Angle(-2,0,-4)

SWEP.AttackTime = 0.57
SWEP.AnimTime1 = 1.45
SWEP.WaitTime1 = 1.65
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.15
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(1,2,-2)

SWEP.ViewPunchDiv = -50

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 46

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,-70,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 40
SWEP.DamageSecondary = 3
SWEP.BleedMultiplier = 1.35
SWEP.PainMultiplier = 1.2

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 0

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 0

SWEP.StaminaPrimary = 35
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 35
SWEP.weight = 3

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "deploy",
    ["attack"] = "swing_l",

}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/katana.png")
	SWEP.IconOverride = "vgui/katana.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "machete/machetehit1.ogg"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_impact_hard1.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"
SWEP.SwingSound = "machete/macheteswing1.ogg"
SWEP.HitFleshExtra = {
    "hit_flesh1.wav",
    "hit_flesh2.wav",
    "hit_flesh3.wav",
    "hit_flesh4.wav",
    "hit_flesh5.wav",
    "hit_flesh6.wav",
    "hit_flesh7.wav",
    "hit_flesh8.wav",
    }
SWEP.HitFleshExtraPitch = 85
SWEP.ArteryChance = 1.1
SWEP.SwingSoundPitch = 110

SWEP.HitFleshPlus = "machete/machetehit1.ogg"

SWEP.BlockTier = 3
SWEP.MeleeMaterial = "metal"
SWEP.BlockImpactSound = "physics/metal/metal_solid_impact_bullet1.wav"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CanSecondaryAttack()
    local owner = self:GetOwner()
    if owner.organism and owner.organism.larmamputated then return end

    self.DamageType = DMG_CLUB
    self.AttackHit = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.Attack2Hit = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.Attack2HitFlesh = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.setlh = true
    self.HoldType = "duel"
    timer.Simple(0.5,function()
        if IsValid(self) then
            self.HoldType = "slam"
        end
    end)
    return false
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "snd_jack_hmcd_knifehit.wav"
    self.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
    self.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.05

SWEP.AttackRads = 65
SWEP.AttackRads2 = 35

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = true
SWEP.MultiDmg2 = false

function SWEP:SecondaryAttackAdd(ent, trace)
    if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then trace.Entity:SetVelocity(trace.Normal * 70 * (trace.Entity:IsNPC() and 35 or 5)) end
    local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone or 0)

    if IsValid(phys) then
        phys:ApplyForceOffset(trace.Normal * 42 * 100,trace.HitPos)
    end
end

SWEP.MinSensivity = 0.25