--ByLAZZY
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MXLR"
SWEP.Author = "Marlin"
SWEP.Instructions = "Sniper rifle chambered in 7.62x51"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_mxlr.mdl"

SWEP.FakePos = Vector(-11, 3.6, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.CantFireFromCollision = true

-- Бодигруппы
SWEP.FakeBodyGroups = "01111111111100"

SWEP.FakeBodyGroupsPresets = {
    "01111111111100"
}

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mxlr.png")
SWEP.IconOverride = "entities/arc9_eft_mxlr.png"

SWEP.LocalMuzzlePos = Vector(20, -0.66, 7)
SWEP.LocalMuzzleAng = Angle(1, -0.2, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = ".357 Magnum"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".357 Magnum"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/mxlr/marlin_outdoor_close_3.ogg", 80, 90, 100}
SWEP.SupressedSound = {"mosin/mosin_suppressed_fp.wav", 65, 90, 100}

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor7", Vector(9,0,0), {}},
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-15, 1, 0),
    },
}

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 2
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.6758, 4.9886)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- AnimList из ARC9 EFT MXLR
SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw_empty",
    ["holster"] = "holster",
    ["holster_empty"] = "holster_empty",
    ["ready"] = "ready",
    ["fire"] = "fire",
    ["fire_empty"] = "fire_last",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry_empty",
    ["cycle"] = "cycle",
    ["reload"] = "reload_single",
    ["reload_empty"] = "reload_single_empty",
    ["start"] = "sgreload_start",
    ["start_empty"] = "sgreload_start_empty",
    ["start_empty_empty"] = "sgreload_start_empty_empty",
    ["insert"] = "sgreload_insert",
    ["finish"] = "sgreload_end",
    ["finish_empty"] = "sgreload_end",
    ["inspect"] = "look",
    ["inspect_empty"] = "look_empty",
    ["inspect_mag"] = "check",
    ["inspect_mag_empty"] = "check_empty",
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
}

-- Звуки анимаций из ARC9 EFT
local path = "weapons/darsu_eft/mxlr/"
local randspin = {"arc9_eft_shared/weapon_generic_rifle_spin1.ogg","arc9_eft_shared/weapon_generic_rifle_spin2.ogg","arc9_eft_shared/weapon_generic_rifle_spin3.ogg","arc9_eft_shared/weapon_generic_rifle_spin4.ogg","arc9_eft_shared/weapon_generic_rifle_spin5.ogg","arc9_eft_shared/weapon_generic_rifle_spin6.ogg","arc9_eft_shared/weapon_generic_rifle_spin7.ogg","arc9_eft_shared/weapon_generic_rifle_spin8.ogg","arc9_eft_shared/weapon_generic_rifle_spin9.ogg","arc9_eft_shared/weapon_generic_rifle_spin10.ogg"}

SWEP.AnimsSounds = {
    ["ready"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/mr133_draw.ogg") end,
        [0.41] = function(self) self:EmitSound(path .. "marlin_bolt_out_empt.ogg") end,
        [0.64] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/mr133_draw.ogg") end,
    },
    ["draw_empty"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/mr133_draw.ogg") end,
    },
    ["holster"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/mr133_holster.ogg") end,
    },
    ["holster_empty"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/mr133_holster.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_hammer_in.ogg") end,
    },
    ["dryfire"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_hammer_in.ogg") end,
    },
    ["dryfire_empty"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_hammer_out.ogg") end,
    },
    ["cycle"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.15] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.2] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
    },
    ["reload_single"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.3] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound("weapons/darsu_eft/mosin/ammo_singleround_pickup.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "marlin_round_in_chamber.ogg") end,
        [1.56] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [1.75] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["reload_single_empty"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.3] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound("weapons/darsu_eft/mosin/ammo_singleround_pickup.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "marlin_round_in_chamber.ogg") end,
        [1.56] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [1.75] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["sgreload_start"] = {
        [0.1] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["sgreload_start_empty"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.3] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound("weapons/darsu_eft/mosin/ammo_singleround_pickup.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "marlin_round_in_chamber.ogg") end,
        [1.74] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [1.9] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["sgreload_start_empty_empty"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.3] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound("weapons/darsu_eft/mosin/ammo_singleround_pickup.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "marlin_round_in_chamber.ogg") end,
        [1.74] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [1.9] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["sgreload_insert"] = {
        [0] = function(self) self:EmitSound("weapons/darsu_eft/mosin/ammo_singleround_pickup.ogg") end,
        [0.32] = function(self) 
            local sounds = { path .. "marlin_round_in_1.ogg", path .. "marlin_round_in_2.ogg", path .. "marlin_round_in_3.ogg", path .. "marlin_round_in_4.ogg", path .. "marlin_round_in_5.ogg" }
            self:EmitSound(sounds[math.random(#sounds)]) 
        end,
        [0.7] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["sgreload_end"] = {
        [0.1] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["look"] = {
        [0.17] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.45] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [2.6] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["look_empty"] = {
        [0.17] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.45] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [2.6] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["check"] = {
        [0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.3] = function(self) self:EmitSound(path .. "marlin_mag_check.ogg") end,
        [1.0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["check_empty"] = {
        [0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.3] = function(self) self:EmitSound(path .. "marlin_mag_check.ogg") end,
        [1.0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["check_chamber"] = {
        [0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.15] = function(self) self:EmitSound(path .. "marlin_bolt_out_check.ogg") end,
        [0.7] = function(self) self:EmitSound(path .. "marlin_bolt_in_check.ogg") end,
        [1.89] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["check_chamber_empty"] = {
        [0] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.15] = function(self) self:EmitSound(path .. "marlin_bolt_out_check.ogg") end,
        [0.7] = function(self) self:EmitSound(path .. "marlin_bolt_in_check.ogg") end,
        [1.89] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["mod_switch"] = {
        [0] = function(self) 
            local sounds = {"arc9_eft_shared/weapon_light_switcher1.ogg", "arc9_eft_shared/weapon_light_switcher2.ogg", "arc9_eft_shared/weapon_light_switcher3.ogg"}
            self:EmitSound(sounds[math.random(#sounds)]) 
        end,
    },
    ["mod_switch_empty"] = {
        [0] = function(self) 
            local sounds = {"arc9_eft_shared/weapon_light_switcher1.ogg", "arc9_eft_shared/weapon_light_switcher2.ogg", "arc9_eft_shared/weapon_light_switcher3.ogg"}
            self:EmitSound(sounds[math.random(#sounds)]) 
        end,
    },
    ["jam_shell"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.15] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.25] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [0.33] = function(self) self:EmitSound(path .. "marlin_bolt_in_fail_1.ogg") end,
        [0.6] = function(self) self:EmitSound(path .. "marlin_gunflip_look_1.ogg") end,
        [1.37] = function(self) self:EmitSound(path .. "marlin_shell_extract.ogg") end,
        [1.96] = function(self) self:EmitSound(path .. "marlin_gunflip_2.ogg") end,
        [2.4] = function(self) self:EmitSound(path .. "marlin_gunflip_3.ogg") end,
        [3.1] = function(self) self:EmitSound(path .. "marlin_gunflip_1.ogg") end,
        [3.58] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["jam_feed"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [0.15] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.25] = function(self) self:EmitSound(path .. "marlin_bolt_in_fail_1.ogg") end,
        [0.7] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.25] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [2.05] = function(self) self:EmitSound(path .. "marlin_bolt_in_fail_1.ogg") end,
        [2.55] = function(self) self:EmitSound(path .. "marlin_bolt_in_fail_2.ogg") end,
        [3.1] = function(self) self:EmitSound(path .. "marlin_feed_flip_1.ogg") end,
        [3.7] = function(self) self:EmitSound(path .. "marlin_feed_flip_2.ogg") end,
        [3.81] = function(self) self:EmitSound(path .. "generic_jam_shell_ remove_medium3.ogg") end,
        [4.35] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [4.45] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [4.7] = function(self) self:EmitSound(path .. "marlin_gunflip_look_1.ogg") end,
        [5.1] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [5.3] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [5.57] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["jam_hard"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_fail_1.ogg") end,
        [0.15] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound(path .. "marlin_bolt_out_fail_2.ogg") end,
        [0.84] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.4] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [2.26] = function(self) self:EmitSound(path .. "marlin_bolt_out_fail_1.ogg") end,
        [2.66] = function(self) self:EmitSound(path .. "marlin_bolt_out_check.ogg") end,
        [3] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [3.44] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [3.64] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
        [3.88] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
    },
    ["jam_soft"] = {
        [0] = function(self) self:EmitSound(path .. "marlin_bolt_out_fail_1.ogg") end,
        [0.15] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [0.55] = function(self) self:EmitSound(path .. "marlin_bolt_out_fail_2.ogg") end,
        [0.84] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.4] = function(self) self:EmitSound(randspin[math.random(#randspin)]) end,
        [1.85] = function(self) self:EmitSound(path .. "marlin_bolt_out_check.ogg") end,
        [2.35] = function(self) self:EmitSound(path .. "marlin_bolt_out_shell.ogg") end,
        [2.57] = function(self) self:EmitSound(path .. "marlin_bolt_in.ogg") end,
    },
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize and self.drawBullet == true
end

function SWEP:AnimHoldPost()
end

function SWEP:ModelCreated(model)
    -- Устанавливаем все бодигруппы для полной комплектации
    model:SetBodyGroups(self:GetRandomBodygroups() or "01111111111110")
end

function SWEP:PostSetupDataTables()
    self:NetworkVar("String", 0, "RandomBodygroups")
    if CLIENT then
        self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged)
    end
end

function SWEP:OnVarChanged(name, old, new)
    if not IsValid(self:GetWM()) then return end
    if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end
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

   -- local wep = self:GetWeaponEntity()
   -- if CLIENT and IsValid(wep) then
   --     wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false)
    --end
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
            self:PlayAnim(self.AnimList["finish_empty"] or "sgreload_end", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true) 
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
        self:PlayAnim(self.AnimList["cycle"] or "cycle", 1, false, nil, false, true)
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

