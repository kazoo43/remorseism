SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "FN Five-seveN"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Pistol chambered in 5.7x28mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
SWEP.WorldModelFake = "models/weapons/c_fn57.mdl"

SWEP.FakePos = Vector(-22, 2.5, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, 0)
SWEP.AttachmentAng = Angle(90, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "11111201"
SWEP.FakeBodyGroupsPresets = {
	"11111201",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "inspect0",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
	["reload"] = {
		[0.1] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.6] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
	},
	["reload_empty"] = {
		[0.015] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_out_fast.ogg") end,
		[0.065] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_in_fast.ogg") end,
	},
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.FakeMagDropBone = "glock_mag"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_fn57.png")
SWEP.IconOverride = "entities/arc9_eft_fn57.png"

SWEP.CustomShell = "556x45"
SWEP.EjectPos = Vector(0, 3, 2)
SWEP.EjectAng = Angle(-80, -90, 0)

SWEP.IsPistol = true
SWEP.podkid = 1

SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.7x28 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 28
SWEP.Primary.Sound = {"weapons/darsu_eft/57/fiveseven_fire_indoor_close.wav", 75, 85, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/57/fiveseven_fire_silenced_indoor_close.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 30
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 2.6


SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -1.7779, 2.8612)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 10.5
SWEP.WorldPos = Vector(3.5, -1, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 20
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, -1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.weight = 0.7
SWEP.ShockMultiplier = 1

SWEP.LocalMuzzlePos = Vector(0, -1.9, 1)
SWEP.LocalMuzzleAng = Angle(1.5, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

--local to head
SWEP.RHPos = Vector(10, -4.5, 3)
SWEP.RHAng = Angle(0, -5, 90)
--local to rh
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 4
SWEP.AnimShootMul = 3

SWEP.punchmul = 1.5
SWEP.punchspeed = 3

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(-2.7, 0, 5), {}},
		[2] = {"supressor3", Vector(-1, 0.2, 0), {}},
		["mount"] = Vector(-0.1, 0.4, 0.03),
		["mountAngle"] = Angle(0, -0.75, 90),
	},
	underbarrel = {
		["mount"] = Vector(12.7, -0.1, -2.5),
		["mountAngle"] = Angle(90, -0.75, -360),
		["mountType"] = "picatinny_small"
	},
}

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1.5)
		wep:ManipulateBonePosition(48, Vector(0, 0, -1 * self.shooanim), false)
	end
end

