SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Chiappa Rhino"
SWEP.Author = "Chiappa Firearms"
SWEP.Instructions = "A unique Italian revolver chambered in .357 Magnum"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_chiappa_rhino.mdl"

SWEP.FakePos = Vector(-24, 2, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, -0.2)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "13112111111"
SWEP.FakeBodyGroupsPresets = {
	"13112111111",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "speedloader_reload__0",
	["reload_empty"] = "speedloader_reload__0",
	["inspect"] = "look__0",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["reload"] = {
        [0.025] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_out.ogg") end,
		[0.2] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_purge_all.ogg") end,
		[0.56] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_extractor.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_in.ogg") end,
    },
    ["reload_empty"] = {
        [0.025] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_out.ogg") end,
		[0.2] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_purge_all.ogg") end,
		[0.56] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_extractor.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_in.ogg") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.FakeMagDropBone = "magazine"
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_cr50ds.png")
SWEP.IconOverride = "entities/arc9_eft_cr50ds.png"
SWEP.WepSelectIcon2box = true

SWEP.CustomShell = "357"

SWEP.weight = 1.2
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_357"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".357 Magnum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Sound = {"weapons/darsu_eft/rhino/rhino_fire_indoor_close.wav", 75, 75, 70}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = 0.25
SWEP.ReloadTime = 3.5

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.3501, 3.6926)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.15, -0.15, 0), Angle(-0.2, 0.15, 0)}
SWEP.Ergonomics = 1.1
SWEP.Penetration = 10
SWEP.ShockMultiplier = 2
SWEP.punchmul = 4
SWEP.punchspeed = 1

SWEP.LocalMuzzlePos = Vector(0, -2.5, 2.7)
SWEP.LocalMuzzleAng = Angle(0.398, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

SWEP.WorldPos = Vector(4, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 20
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 5
SWEP.AnimShootMul = 4

SWEP.podkid = 2

SWEP.availableAttachments = {
	sight = {
		["mountType"] = "pistolmount",
		["mount"] = Vector(-5.6, -1.5, 0),
		["mountAngle"] = Angle(0, 0, 180),
	},
		underbarrel = {
		["mount"] = Vector(9, 1, -1),
		["mountAngle"] = Angle(0, -0.75, -90),
		["mountType"] = "picatinny_small"
	},
}

function SWEP:DrawPost()
	local wep = self:GetWM()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(54, Vector(0, 1.5 * self.shooanim, 0), false)
	end
end

