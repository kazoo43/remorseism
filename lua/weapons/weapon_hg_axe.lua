if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Fire Axe"
SWEP.Instructions = "An axe is an implement that has been used for millennia to shape, split, and cut wood. Can break down doors.\n\nLMB to attack.\nR + LMB to charge.\nRMB to block."
SWEP.Category = "Weapons - Melee"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/ravaged/w_ravaged_fireaxe.mdl"
SWEP.WorldModelReal = "models/weapons/ravaged/anim_axe_fire.mdl"
SWEP.WorldModelExchange = "models/weapons/ravaged/w_ravaged_fireaxe.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(0, -1, -26)
SWEP.SuicideAng = Angle(-70, 50, -30)
SWEP.SuicideCutVec = Vector(-2, 4, -3)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicideHoldType = "slam"

SWEP.Weight = 0
SWEP.weight = 2.5

SWEP.HoldType = "pistol"

SWEP.HoldPos = Vector(-12, -9, -1)
SWEP.HoldAng = Angle(0, 11, 0)

SWEP.AttackTime = 0.51
SWEP.AnimTime1 = 2.45
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1, 1, -1)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0, 0, -2)
SWEP.canchargeattack = true
SWEP.ChargeAnimTimeBegin = 1.45
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.65
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.41
SWEP.ChargeWaitTime = 2.5
SWEP.ChargeAttackLen = 70
SWEP.ChargeAttackTimeLength = 0.34
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -78
SWEP.ChargeStamina = 48
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 2.05
SWEP.ChargeBreakBoneMul = 2.1
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(12, 0, 0)
SWEP.ChargeHoldPos = Vector(-7, -5, -1)

SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(-0.75, 4, -3)
SWEP.weaponAng = Angle(-1, -100, -1)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
    ["charge_begin"] = "Attack_Charge_Begin",
    ["charge_idle"] = "Attack_Charge_Idle",
    ["charge_end"] = "Attack_Charge_End",
}

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 51
SWEP.DamageSecondary = 14
SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 1.5
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.4
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65


SWEP.PenetrationPrimary = 6
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 10

SWEP.PenetrationSizePrimary = 5.5
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 37
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 40

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/ravaged_fireaxe")
	SWEP.IconOverride = "vgui/hud/ravaged_fireaxe"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true


SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.ChargeAttackHit = "Canister.ImpactHard"
SWEP.ChargeAttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.hitsoundbrutalize = {
    {"axe/axehit1.wav", 70, {111, 155}},
    {"axe/axehit2.wav", 75, {111, 155}},
    {"axe/axehit3.wav", 75, {111, 115}},
    {"axe/axehit4.wav", 75, {111, 155}},
}

SWEP.hitsoundextra = {
    {"hardimpact/body_medium_break2.wav", 70, {85, 102}},
    {"hardimpact/body_medium_break3.wav", 70, {85, 102}},
    {"hardimpact/body_medium_break4.wav", 70, {85, 102}},
}

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {85, 95}},
}

SWEP.AttackPos = Vector(0,0,0)
SWEP.BlockTier = 4
SWEP.BlockMaterial = "wood"
SWEP.BlockSound = {"physics/wood/wood_plank_impact_hard1.wav", 70, {96, 104}}

SWEP.NoHolster = true

SWEP.AnimAlwaysBack = true

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 75
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

function SWEP:CanChargeAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    self.ChargeAttackHit = "Canister.ImpactHard"
    self.ChargeAttackHitFlesh = "snd_jack_hmcd_axehit.wav"
    return true
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(7) > 3 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end
end

function SWEP:ChargeAttackAdd(ent)
    self:PrimaryAttackAdd(ent)
end

SWEP.MinSensivity = 0.7

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBaseBone = "base"
SWEP.ViewPunchDiv = 50
