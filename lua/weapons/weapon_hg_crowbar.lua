if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Crowbar"
SWEP.Instructions = "The Crowbar is a two-handed tool which can be used as a melee weapon. It is also an iconic signature weapon of Gordon Freeman. Can break down doors.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_crowbar.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_fubar.mdl"
SWEP.WorldModelExchange = "models/weapons/ravaged/w_ravaged_crowbar.mdl"
SWEP.ViewModel = ""
SWEP.weight = 1.5
SWEP.modelscale = 1.3

SWEP.SuicidePos = Vector(9, 12, 18)
SWEP.SuicideAng = Angle(60, -30, 0)
SWEP.SuicideCutVec = Vector(1, 5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicideHoldType = "slam"

SWEP.NoHolster = true

SWEP.HoldType = "revolver"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-11, 0, 0)
SWEP.HoldAng = Angle()

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.5
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1, 1, -1)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1.2
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0, 0, -2)

SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0, 0, -19)
SWEP.weaponAng = Angle(0, -90, 0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 33
SWEP.DamageSecondary = 12

SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 1.4
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.4
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
SWEP.ChargeAttackLen = 70
SWEP.ChargeAttackTimeLength = 0.26
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -94
SWEP.ChargeStamina = 41
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 1.85
SWEP.ChargeBreakBoneMul = 1.2
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(7, 0, 0)
SWEP.ChargeHoldPos = Vector(-8, 0, 0)

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {80, 90}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {80, 90}},
}

SWEP.hitsoundextra = {
    {"shovelcrowbarshared/shovelhit1.ogg", 70, {100, 105}},
    {"shovelcrowbarshared/shovelhit2.ogg", 70, {100, 105}},
}

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 5

SWEP.MaxPenLen = 4

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 31
SWEP.StaminaSecondary = 25

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 45

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/hud/ravaged_crowbar")
    SWEP.IconOverride = "vgui/hud/ravaged_crowbar"
    SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

SWEP.AttackPos = Vector(0, 0, 0)
SWEP.BlockTier = 3
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {125, 145}}

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

SWEP.AttackTimeLength = 0.10
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0


function SWEP:PrimaryAttack()
    if hg.KeyDown(self:GetOwner(),IN_USE) then
        local tr = self.Owner:GetEyeTrace()
        if IsValid(tr.Entity) and string.find(string.lower(tr.Entity:GetClass()), "door") and self:GetOwner():GetPos():Distance(tr.Entity:GetPos()) <= 80 then
            local locked = false
            if tr.Entity.GetInternalVariable then
                locked = tr.Entity:GetInternalVariable("m_bLocked")
            end
            if not locked then
                return
            end
            if not self.BreakingDoor then
                self.BreakingDoor = true
                self.BreakStartTime = CurTime()
                self.BreakDuration = math.random(15, 20)
                self.DoorEntity = tr.Entity
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            return
        end
    end
    self.BaseClass.PrimaryAttack(self)
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(10) > 8 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 30 + self:GetOwner():GetVelocity())
    end
end

function SWEP:Think()
    if self.BreakingDoor then
        if not (hg.KeyDown(self:GetOwner(),IN_USE) and hg.KeyDown(self:GetOwner(),IN_ATTACK)) then
            self.BreakingDoor = false
        elseif not (IsValid(self.DoorEntity) and self:GetOwner():GetPos():Distance(self.DoorEntity:GetPos()) <= 80) then
            self.BreakingDoor = false
        else
            if not self.NextBreakSound then
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            if CurTime() >= self.NextBreakSound then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:EmitSound("physics/wood/wood_crate_break2.wav", 75, 100)
                end
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            if CurTime() >= self.BreakStartTime + self.BreakDuration then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:Fire("Unlock", "", 0)
                    self.DoorEntity:Fire("Open", "", 0)
                end
                self.BreakingDoor = false
            end
        end
    end
    self.BaseClass.Think(self)
end

SWEP.MinSensivity = 0.6
