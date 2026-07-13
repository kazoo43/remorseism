SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AA-12"
SWEP.Author = "Armsel"
SWEP.Instructions = "The AA-12 (Auto Assault-12) is an American automatic shotgun designed by Maxwell Atchisson. It is gas-operated, select-fire, and uses detachable box magazines, making it extremely effective for close-quarters combat with minimal recoil."
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_aa12.mdl"
SWEP.WorldModelReal = "models/weapons/c_aa12.mdl"
SWEP.FakePos = Vector(-15, 1, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(3.8,2.1,-27.8)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "102122003"
SWEP.ZoomPos = Vector(0, -3.3, 6.6)

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor5", Vector(-5, -1.8, 0), {}},
    },
}

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_aa12.png")
SWEP.IconOverride = "entities/arc9_eft_aa12.png"
SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "CAM_Homefield"

SWEP.MagModel = "models/weapons/arc9/darsu_eft/mods/mag_aa12_20.mdl"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.FakeMagDropBone = 57

SWEP.lmagpos = Vector(0,0,1)
SWEP.lmagang = Angle(0,90,-30)
SWEP.lmagpos2 = Vector(0,-2,0.4)
SWEP.lmagang2 = Angle(-90,0,-90)

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["inspect"] = "look",
}

SWEP.AnimsEvents = {
	["reload0"] = {
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_drum_out_0.ogg") end,
		[0.60] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_drum_in_0.ogg") end,
	},
	["reload_empty0_0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_bolt_out.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_bolt_in.ogg") end,
		[0.25] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_drum_out_0.ogg") end,
		[0.70] = function(self) self:EmitSound("weapons/darsu_eft/aa12/aa12_drum_in_0.ogg") end,
	},
	["look"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12/70 gauge"

SWEP.CustomShell = "12x70"

SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.NumBullet = 8
SWEP.Primary.Force = 35
SWEP.Primary.Sound = {"sound/weapons/darsu_eft/aa12_outdoor_close_loop1.wav", 75, 120, 140}
SWEP.SupressedSound = {"weapons/darsu_eft/m3s90/m3_fire_outdoor_silenced_close.wav", 65, 100, 100}
SWEP.Primary.SoundEmpty = {"sound/weapons/darsu_eft/aa12_outdoor_close_loop1.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.300
SWEP.ReloadTime = 8.0

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.LocalMuzzlePos = Vector(27.985,-3.5,-1)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.HoldType = "rpg"

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 11
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.02, math.cos(i * i) * 0.02, 0) * 0.5
end

SWEP.Ergonomics = 1
SWEP.WorldPos = Vector(5, -0.8, -1.1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(1, -1.5, 0)
SWEP.DistSound = "ak74/ak74_dist.wav"

SWEP.weight = 3

SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
SWEP.LHPos = Vector(15,1,-3.3)
SWEP.LHAng = Angle(-110,-180,0)

local finger1 = Angle(25,0, 40)

SWEP.ShootAnimMul = 3
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0
		vec[2] = 1*self.shooanim
		vec[3] = 0
		wep:ManipulateBonePosition(7,vec,false)
	end
end

local lfang2 = Angle(0, -15, -1)
local lfang1 = Angle(-5, -5, -5)
local lfang0 = Angle(-12, -16, 20)
local vec_zero = Vector(0,0,0)
local ang_zero = Angle(0,0,0)
function SWEP:AnimHoldPost()

end

function SWEP:AllowedInspect()
    if not self:CanUse() then return end
    if self.isReloading then return end
    if self:Clip1() < self.Primary.ClipSize then return end
    if self.drawBullet == false then return end
    return true
end
