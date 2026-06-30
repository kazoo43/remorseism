if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Shovel"
SWEP.Instructions = "A shovel may be big and slow but it can pack a punch.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/shovel/w.mdl"
SWEP.WorldModelReal = "models/weapons/shovel/v.mdl"
--SWEP.WorldModelExchange = "models/props_junk/Shovel01a.mdl"
SWEP.ViewModel = ""

SWEP.NoHolster = true

SWEP.bloodID = 3


SWEP.HoldType = "revolver"
SWEP.weight = 3

SWEP.HoldPos = Vector(-12,0,1)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.6
SWEP.AnimTime1 = 1.95
SWEP.WaitTime1 = 1.55
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,1,-10)
SWEP.weaponAng = Angle(180,90,-2)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 30
SWEP.DamageSecondary = 10

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 2

SWEP.canchargeattack = true
SWEP.ChargeAnimTimeBegin = 1.45
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.65
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.37
SWEP.ChargeWaitTime = 2.5
SWEP.ChargeAttackLen = 65
SWEP.ChargeAttackTimeLength = 0.34
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -84
SWEP.ChargeStamina = 44
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 1.85
SWEP.ChargeBreakBoneMul = 1.85
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(12, 0, 0)

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {80, 90}},
}

SWEP.hitsoundextra = {
    {"shovelcrowbarshared/shovelhit1.ogg", 70, {80, 95}},
    {"shovelcrowbarshared/shovelhit2.ogg", 70, {80, 95}},
}


SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 32
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 45

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_shovel.png")
	SWEP.IconOverride = "vgui/icons/ico_shovel.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AnimAlwaysBack = true

SWEP.AttackHit = "SolidMetal.ImpactHard"
SWEP.Attack2Hit = "SolidMetal.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "SolidMetal.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

SWEP.AttackTimeLength = 0.3
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 120
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 1 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 2 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -9 or 0)
    addAngLerp.p = addAngLerp.p + (self:GetBlocking() and 15 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 65 or 0)
	addAngLerp.x = addAngLerp.x + (self:GetBlocking() and -5 or 0)

    return true
end