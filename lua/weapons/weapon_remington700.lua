--ByLAZZY
SWEP.Base = "weapon_mxlr"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Remington M700"
SWEP.Author = "Mauser"
SWEP.Instructions = "Sniper rifle chambered in 7.62x51mm"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_m700.mdl"
SWEP.WorldModelReal = "models/weapons/c_m700.mdl"

SWEP.FakePos = Vector(-9, 3.6, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "01100010"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "01100010"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_m700.png")
SWEP.IconOverride = "entities/arc9_eft_m700.png"

SWEP.LocalMuzzlePos = Vector(40, -0.66, 3.8)
SWEP.LocalMuzzleAng = Angle(1, -0.2, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "762x51"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Damage = 85 -- Высокий урон для снайперки
SWEP.Primary.Force = 85
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/m700/rem700_outdoor_close1.ogg", 80, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/m700/rem700_outdoor_silenced_close.ogg", 65, 90, 100}

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor7", Vector(9, 0, 0), {}},
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-13, 1.5, 0),
    },
}

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 8
SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.7, 5)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 16
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- AnimList с правильными названиями анимаций для c_m700.mdl
SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw_empty",
    ["holster"] = "holster",
    ["holster_empty"] = "holster_empty",
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry",
    ["cycle"] = "bolt0",
    ["reload"] = "reload0",
    ["reload_empty"] = "reload_empty0",
    ["start"] = "sgreload_start",
    ["start_empty"] = "sgreload_start_empty",
    ["insert"] = "sgreload_insert",
    ["insert_empty"] = "sgreload_insert_empty",
    ["finish"] = "sgreload_end",
    ["finish_empty"] = "sgreload_end_empty",
    ["inspect"] = "look",
    ["inspect_empty"] = "look_empty",
    ["inspect_mag"] = "check_0",
    ["inspect_mag_empty"] = "check_0_empty",
    ["inspect_chamber"] = "check_chamber",
    ["inspect_chamber_empty"] = "check_chamber_empty",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
    ["jam1"] = "jam_shell",
    ["jam2"] = "jam_feed",
    ["jam3"] = "jam_hard",
    ["jam4"] = "jam_soft",
    ["enter_bipod"] = "action",
    ["enter_bipod_empty"] = "action_empty",
    ["exit_bipod"] = "action",
    ["exit_bipod_empty"] = "action_empty",
    ["reload_single"] = "reload_single",
}

-- Звуки анимаций
SWEP.AnimsSounds = {
    -- Ready
    ["ready0"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.4] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["ready1"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.4] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["ready2"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.4] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- Draw/Holster
    ["draw"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_draw.wav") end,
    },
    ["draw_empty"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_draw.wav") end,
    },
    ["holster"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_draw.wav") end,
    },
    ["holster_empty"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_draw.wav") end,
    },
    
    -- Fire
    ["fire"] = {
        [0.1] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.3] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["fire_dry"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_trigger.wav") end,
    },
    
    -- Bolt (cycle)
    ["bolt0"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.3] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["bolt1"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.3] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["bolt2"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.3] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- Reload (магазинная)
    ["reload0"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload0t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty0"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload1"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload1t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty1"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload2"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload2t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty2"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload3"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload3t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty3"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload4"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload4t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty4"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload5"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload5t"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
    },
    ["reload_empty5"] = {
        [0.3] = function(self) self:EmitSound("weapons/ak74/ak74_magout.wav") end,
        [0.8] = function(self) self:EmitSound("weapons/ak74/ak74_magin.wav") end,
        [1.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["reload_single"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_bulletin_" .. math.random(1, 4) .. ".wav") end,
        [1.0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- SG Reload (по одному патрону)
    ["sgreload_start"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
    },
    ["sgreload_start_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
    },
    ["sgreload_insert"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_bulletin_" .. math.random(1, 4) .. ".wav") end,
    },
    ["sgreload_insert_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_bulletin_" .. math.random(1, 4) .. ".wav") end,
    },
    ["sgreload_end"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["sgreload_end_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- Look (осмотр)
    ["look"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["look_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
        [1.5] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    
    -- Check
    ["check_0"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_0_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_1"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_1_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_2"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_2_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_3"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_3_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_4"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_4_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_5"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_5_empty"] = {
        [0.2] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["check_chamber"] = {
        [0.15] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.6] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["check_chamber_empty"] = {
        [0.15] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.6] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- Mod switch
    ["mod_switch"] = {
        [0] = function(self) self:EmitSound("buttons/button14.wav") end,
    },
    ["mod_switch_empty"] = {
        [0] = function(self) self:EmitSound("buttons/button14.wav") end,
    },
    
    -- Jams
    ["jam_shell"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["jam_feed"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["jam_hard"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    ["jam_soft"] = {
        [0] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltback.wav") end,
        [0.5] = function(self) self:EmitSound("weapons/tfa_ins2/k98/mosin_boltforward.wav") end,
    },
    
    -- Action
    ["action"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
    ["action_empty"] = {
        [0] = function(self) self:EmitSound("weapons/ak74/ak74_magout_rattle.wav") end,
    },
}

SWEP.stupidgun = true

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize and self.drawBullet == true
end

function SWEP:AnimHoldPost()
end

function SWEP:ModelCreated(model)
    model:SetBodyGroups(self:GetRandomBodygroups() or "000000000")
end

function SWEP:PostSetupDataTables()
    self:NetworkVar("String", 0, "RandomBodygroups")
    if CLIENT then
        self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged)
    end
end

function SWEP:OnVarChanged(name, old, new)
    if not IsValid(self:GetWM()) then return end
    self:GetWM():SetBodyGroups(new)
end

function SWEP:InitializePost()
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
end

local ang1 = Angle(0, -10, 0)
local ang2 = Angle(0, -10, 0)

function SWEP:AnimationPost()
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then
        sin = 1 - sin
    else
        sin = sin * 1
    end
    sin = sin * 2
    sin = math.ease.InOutSine(sin)

    if sin > 0 then
        self.LHPos[1] = 18 - sin * 6
        self.RHPos[1] = 1 - sin * 4
        self.inanim = true
    else
        self.inanim = nil
    end

    local wep = self:GetWeaponEntity()
    if CLIENT and IsValid(wep) then
        wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false)
    end
end

function SWEP:GetAnimPos_Insert(time)
    return 0
end

function SWEP:GetAnimPos_Draw(time)
    return 0
end

local function cock(self, time)
    if SERVER then
        self:Draw(true)
    end

    if self:Clip1() == 0 then
        self.drawBullet = nil
    end

    if CLIENT and LocalPlayer() == self:GetOwner() then return end

    net.Start("hgwep draw")
        net.WriteEntity(self)
        net.WriteBool(self.drawBullet)
        net.WriteFloat(CurTime())
    net.Broadcast()

    self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait

    local ply = self:GetOwner()
    self.reloadCoolDown = CurTime() + time
end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)

local vector_full = Vector(1, 1, 1)

local function reloadFunc(self)
    if not SERVER then return end
    if SERVER then self:SetNetVar("shootgunReload", CurTime() + 1.1) end
    if self.MagIndex then
        self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
    end

    self:PlayAnim(self.AnimList["insert"] or "sgreload_insert", 1, false, function()
        self:InsertAmmo(1)
        if self.MagIndex then
            self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
        end

        local key = hg.KeyDown(self:GetOwner(), IN_RELOAD)

        if key and self:CanReload() then
            reloadFunc(self)
            return
        end

        if not self.drawBullet then
            cock(self, 1)
            self:PlayAnim(self.AnimList["finish_empty"] or "sgreload_end_empty", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true)
        else
            self:PlayAnim(self.AnimList["finish"] or "sgreload_end", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true)
        end
    end, false, true)
end

SWEP.FakeEjectBrassATT = "2"

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    if self.drawBullet == false and SERVER then
        cock(self, 1)
        self:PlayAnim(self.AnimList["cycle"] or "bolt0", 1, false, nil, false, true)
        return
    end

    if not self:CanReload() then return end

    if SERVER then
        self:SetNetVar("shootgunReload", CurTime() + 1.1)
        self:PlayAnim(self.AnimList["start"] or "sgreload_start", 1, false, function()
            reloadFunc(self)
        end, false, true)
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

