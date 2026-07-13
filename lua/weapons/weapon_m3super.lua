SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "M3 Super 90"
SWEP.Author = "Benelli"
SWEP.Instructions = "Semi-automatic shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/zcity/w_shot_m3juper90.mdl"
SWEP.WorldModelFake = "models/weapons/c_m3super90.mdl"
SWEP.WorldModelReal = "models/weapons/c_m3super90.mdl"

SWEP.FakePos = Vector(-10, 3.6, 6.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "01111101021"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "01111101021"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_m3super90.png")
SWEP.IconOverride = "entities/arc9_eft_m3super90.png"

SWEP.LocalMuzzlePos = Vector(27.985,-1,5)
SWEP.LocalMuzzleAng = Angle(0.2, -0.0, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "12x70"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = true
SWEP.UseCustomWorldModel = true

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Damage = 16 * 8
SWEP.Primary.Force = 12
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.04
SWEP.Primary.NumShots = 8

SWEP.Primary.Sound = {"weapons/darsu_eft/m3s90/m3_fire_outdoor_close.wav", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/m3s90/m3_fire_outdoor_silenced_close.wav", 65, 100, 100}
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 8

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor5", Vector(8, 0, 0), {}},
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-15, 0.2, 1),
        ["mountAngle"] = Angle(0, 0, 90),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.6816, 5.6011)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-1, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- ============================================
-- АНИМАЦИИ
-- ============================================

SWEP.AnimList = {
    ["idle"] = "idle",
    ["draw"] = "draw",
    ["holster"] = "holster",
    ["ready"] = "ready0_pa",
    ["fire"] = "fire",
    ["cycle"] = "pump2",
    ["fistful_start"] = "fistful_start",
    ["fistful1"] = "fistful1",
    ["fistful2"] = "fistful2",
    ["fistful3"] = "fistful3",
    ["fistful4"] = "fistful4",
    ["fistful5"] = "fistful5",
    ["fistful_end"] = "fistful_end",
    ["inspect"] = "look",
}

local snd_path = "weapons/darsu_eft/m3s90/"

SWEP.AnimsEvents = {
    ["inspect"] = {
        [0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
    },
    ["fistful_start"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "mr133_shell_pickup.ogg") end,
        [0.3] = function(self) self:EmitSound(snd_path .. "mr133_magcover.ogg") end,
    },
    ["fistful1"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "m3_shell_in1.ogg") end,
    },
    ["fistful2"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "m3_shell_in2.ogg") end,
    },
    ["fistful3"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "m3_shell_in1.ogg") end,
    },
    ["fistful4"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "m3_shell_in2.ogg") end,
    },
    ["fistful5"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "m3_shell_in1.ogg") end,
    },
    ["fistful_end"] = {
        [0.05] = function(self) self:EmitSound(snd_path .. "mr133_magcover.ogg") end,
    },
    ["pump2"] = {
        [0.08] = function(self) self:EmitSound(snd_path .. "m3_pump_in.ogg") end,
        [0.15] = function(self) self:EmitSound(snd_path .. "pump_jam_extract.ogg") end,
        [0.28] = function(self) self:EmitSound(snd_path .. "m3_pump_out.ogg") end,
    },
    ["ready0_pa"] = {
        [0.01] = function(self) self:EmitSound(snd_path .. "mr133_draw.ogg") end,
        [0.63] = function(self) self:EmitSound(snd_path .. "m3_pump_in.ogg") end,
        [0.87] = function(self) self:EmitSound(snd_path .. "m3_pump_out.ogg") end,
    },
    ["draw"] = {
        [0.01] = function(self) self:EmitSound(snd_path .. "mr133_draw.ogg") end,
    },
}

SWEP.stupidgun = true

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "01111101021") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end self:GetWM():SetBodyGroups(new) end

function SWEP:InitializePost()
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
    self.isReloading = false
end

function SWEP:AnimationPost()
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end
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
    if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end
end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:PrimaryShootPost()
end

function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

-- ============================================
-- FISTFUL RELOAD (CALLBACK-BASED, LIKE MR-153)
-- ============================================

SWEP.isReloading = false
SWEP.ReloadShellsInserted = 0

local function reloadFunc(self)
    if not SERVER then return end

    if self:Clip1() >= self.Primary.ClipSize or self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then
        self:PlayAnim(self.AnimList["fistful_end"], 0.75, false, function()
            if self:Clip1() > 0 then
                self.drawBullet = true
                net.Start("hgwep draw")
                    net.WriteEntity(self)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10)
                net.Broadcast()
            end

            self:SetNetVar("shootgunReload", 0)
            self.isReloading = false
        end, false, true)
        return
    end

    if SERVER then self:SetNetVar("shootgunReload", CurTime() + 0.8) end

    local insertCount = self.ReloadShellsInserted + 1
    local animName = "fistful" .. math.Clamp(insertCount, 1, 5)

    self:PlayAnim(self.AnimList[animName], 0.6, false, function()
        if not IsValid(self) then return end

        self:InsertAmmo(1)
        self.ReloadShellsInserted = self.ReloadShellsInserted + 1
        reloadFunc(self)
    end, false, true)
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self.isReloading then return end
    local ply = self:GetOwner()
    if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end

    if not self:CanReload() then return end
    if self:Clip1() >= self.Primary.ClipSize then return end

    if SERVER then
        self.isReloading = true
        self.ReloadShellsInserted = 0
        self:SetNetVar("shootgunReload", CurTime() + 1.2)

        self:PlayAnim(self.AnimList["fistful_start"], 0.7, false, function()
            reloadFunc(self)
        end, false, true)
    end
end

function SWEP:CanPrimaryAttack()
    return not self.isReloading
end

-- ============================================
-- ОСМОТР
-- ============================================

function SWEP:AllowedInspect()
    if not self:CanUse() then return end
    if self.isReloading then return end
    if self:Clip1() < self.Primary.ClipSize then return end
    if self.drawBullet == false then return end
    return true
end

function SWEP:ReloadEnd() end


