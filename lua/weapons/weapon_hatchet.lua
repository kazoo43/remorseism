if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Hatchet"
SWEP.Instructions = "A single-handed striking tool with a sharp blade on one side used to cut and split wood, and a hammerhead on the other side.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Damage = 25
SWEP.Damage = 25
SWEP.HoldType = "melee"

SWEP.SuicidePos = Vector(28, 6, -31)
SWEP.SuicideAng = Angle(-70, -180, 90)
SWEP.SuicideCutVec = Vector(3, -6, 3)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.Weight = 0
SWEP.weight = 1

SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_hatchet.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/prop/re9_requiem_hatchet.mdl"
SWEP.DontChangeDropped = true
SWEP.ViewModel = ""

SWEP.bloodID = 1

SWEP.HoldPos = Vector(-12,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 1.2
SWEP.WaitTime1 = 0.75
SWEP.AttackLen1 = 45
SWEP.ViewPunch1 = Angle(1,1,0)

SWEP.noreverse = true

SWEP.Attack2Time = 0.7
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.85
SWEP.AttackLen2 = 30
SWEP.ViewPunch2 = Angle(0,0,-2)



SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 0.8
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.4
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,1,-5)
SWEP.weaponAng = Angle(-90,-90,0)

SWEP.AnimAlwaysBack = true

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
}

SWEP.hitsoundextra = {
    {"hatchet/rem_hatchet1.wav", 70, {110, 115}},
    {"hatchet/rem_hatchet2.wav", 70, {110, 115}},
    {"hatchet/rem_hatchet3.wav", 70, {110, 115}},
}

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {85, 95}},
}

SWEP.BlockTier = 2
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {125, 145}}
SWEP.BlockDirectionalPrimary = "overhead"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/handaxe.png")
	SWEP.IconOverride = "vgui/hud/handaxe.png"
	SWEP.BounceWeaponIcon = false
end


SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false


SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_solid_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 21
SWEP.DamageSecondary = 11

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 3

SWEP.StaminaPrimary = 25
SWEP.StaminaSecondary = 60

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

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()
    ent.localshit = Vector(4,6,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = 35
    ent.penetration = 5
    ent.PenetrationSize = 10
    ent.LodgeChance = 0.7
    ent.StickInWorld = true
    ent.StickPhysics = false
    ent.UnstickSnd = "physics/metal/metal_solid_impact_hard3.wav"
    ent.ArteryChance = 1.45
    ent.StickDepth = -1
    ent.returndamage = 20
    ent.returnblood = 50

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(Vector(0,ent.MaxSpeed,0))
    end
    
    ply:EmitSound("hatchet/rem_axethrow.wav",50,math.random(95,105))
    ply:SelectWeapon("weapon_hands_sh")
    ply:ViewPunch(Angle(0, 0, -8))

    self:Remove()

    return true
end

SWEP.NoHolster = true

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(6) > 3 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 75
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.55