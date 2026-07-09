if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Scalpel"
SWEP.Instructions = "A precision surgical instrument used in surgeries, repurposed for combat. Extremely sharp and precise.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.SuicidePos = Vector(-8, -2, -6)
SWEP.SuicideAng = Angle(0, 20, -40)
SWEP.SuicideCutVec = Vector(-1, -4, 1)
SWEP.SuicideCutAng = Angle(5, 0, 0)
SWEP.SuicideTime = 0.4
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_02.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicidePunchAng = Angle(3, -10, 0)

SWEP.WorldModel = "models/weapons/w_knife_swch.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/surgeon simulator 2013/scalpel_1.mdl"
SWEP.DontChangeDropped = true
SWEP.ViewModel = ""
SWEP.HoldType = "melee"

SWEP.basebone = 39
SWEP.weaponPos = Vector(-1, 1.3, 0)
SWEP.weaponAng = Angle(0, 260, 180)

SWEP.HoldPos = Vector(-4, 0, -2)

SWEP.BreakBoneMul = 0.20

SWEP.AnimList = {
    ["idle"]    = "idle",
    ["deploy"]  = "draw",
    ["attack"]  = "stab",
    ["attack2"] = "midslash1",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/scapel.png")
	SWEP.IconOverride = "vgui/scapel.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.DeploySnd = ""

SWEP.AttackPos = Vector(0, 0, 0)
SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 8
SWEP.DamageSecondary = 6

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 3
SWEP.BleedMultiplier = 2

SWEP.MaxPenLen = 3

SWEP.PainMultiplier = 0.6

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 11

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

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 80
SWEP.AttackRads2 = 55

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

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