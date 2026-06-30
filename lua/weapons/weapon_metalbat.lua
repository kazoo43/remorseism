if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Aluminium Bat"
SWEP.Instructions = "An Aluminium bat. The design features of the bat allow it to deliver powerful and heavy blows.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "slam"

SWEP.WorldModel = "models/weapons/baseball_bat/w.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_bat_metal.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""
SWEP.modelscale = 1.45

SWEP.basebone = 94
SWEP.bloodID = 3

SWEP.Weight = 0
SWEP.weight = 2

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/wm_baseball_bat_i.png")
	SWEP.IconOverride = "vgui/hud/wm_baseball_bat_i.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 34
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 6

SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 26
SWEP.StaminaSecondary = 10

SWEP.HoldPos = Vector(-8,0,0)
SWEP.HoldAng = Angle(0,0,-10)

SWEP.AttackTime = 0.29
SWEP.AnimTime1 = 1.45
SWEP.WaitTime1 = 0.95
SWEP.AttackLen1 = 55
SWEP.ViewPunch1 = Angle(2,4,0)
SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 1.4
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.7
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65

SWEP.canchargeattack = true
SWEP.ChargeAnimTimeBegin = 1
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.35
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.36
SWEP.ChargeWaitTime = 1.95
SWEP.ChargeAttackLen = 57
SWEP.ChargeAttackTimeLength = 0.26
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -94
SWEP.ChargeStamina = 48
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 1.85
SWEP.ChargeBreakBoneMul = 1.15
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(7, 0, 0)
SWEP.ChargeHoldPos = Vector(-8, 0, 0)

SWEP.hitsoundextra = {
    {"bat/sfx_bat_impact_02.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_04.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_05.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_06.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_07.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_08.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_09.wav", 55, {105, 115}},
    {"bat/sfx_bat_impact_10.wav", 55, {105, 115}},
}

SWEP.hitsoundplus = {
    {"bat/hitplus.ogg", 55, {105, 115}},
}

SWEP.hitsoundbrutalize = {
    {"bat/sfx_bat_impact_gore_05.wav", 70, {95, 105}},
    {"bat/sfx_bat_impact_gore_07.wav", 75, {98, 102}},
    {"bat/sfx_bat_impact_gore_08.wav", 75, {98, 102}},
    {"bat/sfx_bat_impact_gore_10.wav", 75, {98, 102}},
}

SWEP.swingsoundextra = {
    {"bat/bat_heavy1.wav", 60, {95, 105}},
    {"bat/bat_heavy2.wav", 60, {95, 105}},
    {"bat/bat_heavy3.wav", 60, {95, 105}},
}

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.AttackLen2 = 40
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(9,0.2,-1.65)
SWEP.weaponAng = Angle(-79,5,-4)

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

SWEP.BreakBoneMul = 0.95
SWEP.PainMultiplier = 0.9

SWEP.AttackTimeLength = 0.255
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 120
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.6
