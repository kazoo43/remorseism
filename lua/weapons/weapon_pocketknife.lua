if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Switchblade"
SWEP.Instructions = "A small knife which can be easily hidden in your pockets.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cof/weapons/switchblade/w_switchblade.mdl"
SWEP.WorldModelReal = "models/cof/weapons/switchblade/v_switchblade.mdl"
SWEP.WorldModelExchange = false

SWEP.HoldPos = Vector(-4,0,-1)
SWEP.HoldAng = Angle(0,0,0)
SWEP.HoldType = "knife"

SWEP.noreverse = true

SWEP.SuicidePos = Vector(-10, 5, -7)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, -5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.BreakBoneMul = 0.25

SWEP.AnimList = {
    ["idle"] = "p2idle",
    ["deploy"] = "p2draw",
    ["attack"] = "p2attack1",
    ["attack2"] = "midslash1"
}

SWEP.ModeAnimLists = {
    [false] = {
        ["idle"] = "p2idle",
        ["deploy"] = "p2draw",
        ["attack"] = "p2attack1",
        ["attack2"] = "p2attack1"
    },
    [true] = {
        ["idle"] = "p1idle",
        ["deploy"] = "p1draw",
        ["attack"] = "p1attack1",
        ["attack2"] = "p1attack1"
    }
}

SWEP.swingsoundextra = {
    {"knife/knife_bayonet_swing1.ogg", 60, {80, 90}},
    {"knife/knife_bayonet_swing2.ogg", 60, {80, 90}},
}

SWEP.hitsoundextra = {
    {"pocketknife/melee_character_knife_plr_02.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_01.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_03.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_04.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_05.ogg", 55, {105, 115}},
}



SWEP.ModeSwitchTime = 0.55
SWEP.ModeSwitchToStabAnim = "p2top1"
SWEP.ModeSwitchToSlashAnim = "p1top2"
SWEP.ArteryChance = 1.25

if CLIENT then
	SWEP.WepSelectIcon = Material("cof/vgui/weapons/switchblade/640_switchblade_slot")
	SWEP.IconOverride = "cof/vgui/weapons/switchblade/640_switchblade_slot"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "weapons/knife/knife_hitwall1.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.DeploySnd = "weapons/knife/knife_deploy1.wav"

SWEP.Attack2HitFlesh = "knife/NEWRapierSlash1.wav"

SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 10
SWEP.DamageSecondary = 8

SWEP.BlockTier = 1.15
SWEP.BlockMaterial = "none"
SWEP.BlockSound = {"weapons/knife/knife_hitwall1.wav", 85, {145, 155}}

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 3
SWEP.BleedMultiplier = 1.25

SWEP.MaxPenLen = 3

SWEP.PainMultiplier = 0.5

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 15
SWEP.StaminaSecondary = 12

SWEP.AttackLen1 = 42
SWEP.AttackLen2 = 35

function SWEP:GetModeAnimList(mode)
    return self.ModeAnimLists[mode and true or false] or self.ModeAnimLists[false]
end

function SWEP:ApplyModeAnimList(mode)
    self.CurrentAnimMode = mode and true or false
    self.AnimList = table.Copy(self:GetModeAnimList(mode))
end

function SWEP:SyncModeAnimList(force)
    local mode = self:GetNetVar("mode") and true or false

    if not force and self.CurrentAnimMode == mode then return end

    self:ApplyModeAnimList(mode)
end

function SWEP:ResolveAnimName(anim)
    if anim == "inspect" or anim == "duct_cut" then return end
    return (self.AnimList and self.AnimList[anim]) or anim
end

function SWEP:CanSwitchMode()
    local owner = self:GetOwner()

    if not IsValid(owner) then return false end
    if self.Charging then return false end
    if self:GetBlocking() then return false end
    if not self:InUse() then return false end
    if (self.ModeSwitchEnd or 0) > CurTime() then return false end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return false end
    if self.lastattack and (self.lastattack + self.attackwait) > CurTime() then return false end

    return true
end

function SWEP:FinishModeSwitch(mode, token)
    timer.Simple(self.ModeSwitchTime, function()
        if not IsValid(self) then return end
        if self.ModeSwitchToken ~= token then return end

        self.ModeSwitchEnd = nil
        self:SyncModeAnimList(true)
        self:PlayAnim("idle", 10, true, nil, false, false)
    end)
end

function SWEP:StartModeSwitch(mode)
    self.ModeSwitchToken = (self.ModeSwitchToken or 0) + 1

    local switchTime = self.ModeSwitchTime
    local switchAnim = mode and self.ModeSwitchToSlashAnim or self.ModeSwitchToStabAnim
    local switchEnd = CurTime() + switchTime

    self.ModeSwitchEnd = switchEnd
    self:SetLastAttack(switchEnd)
    self:SetAttackWait(0)
    self.lastattack = switchEnd
    self.attackwait = 0
    self:SetInAttack(false)
    self:ApplyModeAnimList(mode)
    self:PlayAnim(switchAnim, switchTime, false, nil, false, false)
    self:FinishModeSwitch(mode, self.ModeSwitchToken)
end

function SWEP:Reload()
    local owner = self:GetOwner()

    if not IsValid(owner) then return end
    if not owner:KeyPressed(IN_ATTACK) then return end
    if not self:CanSwitchMode() then return end

    local mode = not self:GetNetVar("mode")

    if CLIENT then
        if not IsFirstTimePredicted() then return end
        self:StartModeSwitch(mode)
        return
    end

    self:SetNetVar("mode", mode)
    owner:ChatPrint("Changed mode to " .. (mode and "slash." or "stab."))
    self:StartModeSwitch(mode)
end

function SWEP:Deploy()
    self:SyncModeAnimList(true)
    return self.BaseClass.Deploy(self)
end

function SWEP:ThinkAdd()
    self:SyncModeAnimList()
end

function SWEP:CutDuct()
    return false
end

function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    anim = self:ResolveAnimName(anim)
    if not anim then return end

    return self.BaseClass.PlayAnim(self, anim, time, cycling, callback, reverse, sendtoclient)
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
    local check = self:GetBlocking() and self:GetWM():GetSequenceName(self:GetWM():GetSequence()) != "cut"
    addPosLerp.z = addPosLerp.z + (check and 2 or 0)
    addPosLerp.x = addPosLerp.x + (check and 0 or 0)
    addPosLerp.y = addPosLerp.y + (check and 3 or 0)
    addAngLerp.r = addAngLerp.r + (check and -15 or 0)
    addAngLerp.y = addAngLerp.y + (check and 8 or 0)
    
    return true
end

function SWEP:CanSecondaryAttack()
    if not self.allowsec then return false end
    self.Attack2HitFlesh = "knife/NEWRapierSlash"..math.random(1, 6)..".wav"
    return true
end

SWEP.AttackPos = Vector(0,0,0)
SWEP.AttackingPos = Vector(0,0,0)

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.5

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.5
SWEP.WaitTime2 = 0.4

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 2
SWEP.AttackRads2 = 55

SWEP.SwingAng = 90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true
