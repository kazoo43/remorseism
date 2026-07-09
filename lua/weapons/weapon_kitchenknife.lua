if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Kitchen Knife"
SWEP.Instructions = "A common kitchen knife meant for cutting vegetables and ingredients, but works well in a pinch.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.SuicidePos = Vector(5, -23, 5)
SWEP.SuicideAng = Angle(0, 90, 20)
SWEP.SuicideCutVec = Vector(-1, -4, 1)
SWEP.SuicideCutAng = Angle(5, 0, 0)
SWEP.SuicideTime = 0.4
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_02.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicidePunchAng = Angle(3, -10, 0)

SWEP.WorldModel = "models/hatedmekkr/boneworks/weapons/melee/blades/daggers/bw_wpn_dgr_kitchen.mdl"
SWEP.WorldModelReal = "models/zac/c_kitchenknife.mdl"
SWEP.WorldModelExchange = "models/hatedmekkr/boneworks/weapons/melee/blades/daggers/bw_wpn_dgr_kitchen.mdl"
SWEP.DontChangeDropped = true
SWEP.ViewModel = ""
SWEP.HoldType = "melee"

SWEP.basebone = 39

SWEP.weaponPos = Vector(0, 0, -0.5)
SWEP.weaponAng = Angle(0, 90, 180)

SWEP.BreakBoneMul = 0.35

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 12
SWEP.DamageSecondary = 8

SWEP.PenetrationPrimary = 3.5
SWEP.PenetrationSecondary = 3
SWEP.BleedMultiplier = 1.3

SWEP.MaxPenLen = 3

SWEP.PainMultiplier = 1

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 16
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 42
SWEP.AttackLen2 = 35

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 0.8
SWEP.WaitTime1 = 0.6
SWEP.ViewPunch1 = Angle(1, 0, 0)

SWEP.Attack2Time = 0.15
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.5
SWEP.ViewPunch2 = Angle(0, 0, -1)

SWEP.AnimList = {
    ["idle"]    = "idle",
    ["deploy"]  = "draw",
    ["attack"]  = "attack_stab",
    ["attack2"] = "attack",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_cod2019_tac_knife03_v0.png")
	SWEP.IconOverride = "entities/arc9_cod2019_tac_knife03_v0.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true

SWEP.DeploySnd = ""

SWEP.AttackPos = Vector(0, 0, 0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 80
SWEP.AttackRads2 = 55

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

SWEP.BlockHoldPos = Vector(-9.5, 15, -0.95)
SWEP.BlockHoldAng = Angle(-5, 0, -45)
SWEP.BlockSound = "physics/metal/metal_solid_impact_bullet3.wav"

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
        -- Stab mode
        self.MultiDmg1 = false
        self.AttackRads = 80
        self.SwingAng = -90
        return true
    else
        -- Slash mode
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CanSecondaryAttack()
    return self.allowsec and true or false
end