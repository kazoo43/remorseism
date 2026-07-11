if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Barbed Wire Bat"
SWEP.Instructions = "An Aluminium bat wrapped in barbed wire. The design allows powerful blows,\nbut the wire shreds flesh and causes bleeding.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "slam"

SWEP.WorldModel = "models/criminality/metalbat.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_bat_metal.mdl"
SWEP.WorldModelExchange = "models/criminality/metalbat.mdl" -- visible model swapped, animations kept from WorldModelReal
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""
SWEP.modelscale = 1.1

SWEP.basebone = 94
SWEP.bloodID = 3

SWEP.Weight = 0
SWEP.weight = 2

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/crimbat.png")
	SWEP.IconOverride = "vgui/hud/crimbat.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 28
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 6

SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 45
SWEP.StaminaSecondary = 20

SWEP.HoldPos = Vector(-8,0,0)
SWEP.HoldAng = Angle(0,0,-10)

SWEP.AttackTime = 0.5
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.AttackLen1 = 45
SWEP.ViewPunch1 = Angle(2,4,0)
SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 1
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.7
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65
SWEP.BlockDirectionalCharge = "overhead" --left, right, overhead, center, neutral

SWEP.canchargeattack = true
SWEP.ChargeAnimTimeBegin = 1
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.6
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.5
SWEP.ChargeWaitTime = 2.4
SWEP.ChargeAttackLen = 47
SWEP.MeleeReachMul = 1.3
SWEP.ChargeAttackTimeLength = 0.26
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -94
SWEP.ChargeStamina = 70
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 1.85
SWEP.ChargeBreakBoneMul = 1.15
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(7, 0, 0)
SWEP.ChargeHoldPos = Vector(-8, 0, 0)

SWEP.hitsoundextra = {
    {"punch/Punch-01.wav", 55, {105, 115}},
    {"punch/Punch-02.wav", 55, {105, 115}},
    {"punch/Punch-03.wav", 55, {105, 115}},
    {"punch/Punch-04.wav", 55, {105, 115}},
    {"punch/Punch-05.wav", 55, {105, 115}},
    {"punch/Punch-06.wav", 55, {105, 115}},
    {"punch/Punch-07.wav", 55, {105, 115}},
    {"punch/Punch-08.wav", 55, {105, 115}},
    {"punch/Punch-09.wav", 55, {105, 115}},
    {"punch/Punch-10.wav", 55, {105, 115}},
}

SWEP.hitsoundplus = {
    {"baseballbat/hit1.ogg", 55, {105, 125}},
    {"baseballbat/hit2.ogg", 55, {105, 125}},
    {"baseballbat/hit3.ogg", 55, {105, 125}},
}

SWEP.hitsoundbrutalize = {
    {"hammerbrutalize/rem_hammerbrutalize1.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize2.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize3.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize4.wav", 70, {110, 115}},
}

SWEP.swingsoundextra = {
    {"baseballbat/swing.ogg", 60, {95, 105}},
}

SWEP.Attack2Time = 0.45
SWEP.AnimTime2 = 1.3
SWEP.WaitTime2 = 1.1
SWEP.AttackLen2 = 20
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(-17.,-0.7,3.2)
SWEP.weaponAng = Angle(101,0,-94)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.Attack2Hit = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)
SWEP.BlockTier = 3
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {125, 145}}

SWEP.NoHolster = true

SWEP.BreakBoneMul = 0.8
SWEP.PainMultiplier = 0.76

SWEP.AttackTimeLength = 0.255
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 120
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.6

SWEP.MultiDmg1 = true 
SWEP.MultiDmg2 = true
SWEP.MultiDmgCharge = true

SWEP.BleedChance = 0.7
SWEP.BleedMinWounds = 1
SWEP.BleedMaxWounds = 4
SWEP.BleedMinStrength = 8
SWEP.BleedMaxStrength = 32

if SERVER then
    function SWEP:ApplyWireBleed(ent, trace)
        if not IsValid(ent) then return end

        local victim = IsValid(hg.RagdollOwner(ent)) and hg.RagdollOwner(ent) or ent
        if not IsValid(victim) or not victim:IsPlayer() or not victim.organism then return end

        if math.random() > (self.BleedChance or 1) then return end

        local physBone = (trace and trace.PhysicsBone) or 0
        local bone = victim:TranslatePhysBoneToBone(physBone or 0) or 0
        local boneName = victim:GetBoneName(bone)

        local woundCount = math.random(self.BleedMinWounds or 1, self.BleedMaxWounds or 3)

        for i = 1, woundCount do
            local strength = math.Rand(self.BleedMinStrength or 8, self.BleedMaxStrength or 32)
            local localPos = VectorRand(-3, 3)
            local localAng = AngleRand()

            hg.organism.AddWoundManual(victim, strength, localPos, localAng, boneName, CurTime())
        end
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:ApplyWireBleed(ent, trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:ApplyWireBleed(ent, trace)
    end

    function SWEP:ChargeAttackAdd(ent, trace)
        self:ApplyWireBleed(ent, trace)
    end
end
