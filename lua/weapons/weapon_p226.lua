SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "SIG Sauer P226"
SWEP.Author = "SIG Sauer"
SWEP.Instructions = "A Swiss-German service pistol chambered in 9x19mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.WorldModelFake = "models/weapons/c_p226_2.mdl"

SWEP.FakePos = Vector(-23, 2, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, -0.2)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "11202111011"
SWEP.FakeBodyGroupsPresets = {
	"11202111011",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["inspect"] = "inspect",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["reload"] = {
        [0.1] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magout.wav") end,
        [0.6] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magin.wav") end,
    },
    ["reload_empty"] = {
        [0.025] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav") end,
		[0.1] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magout.wav") end,
		[0.5] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magin.wav") end,
		[0.8] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav") end,
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

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_p226r.png")
SWEP.IconOverride = "entities/arc9_eft_p226r.png"
SWEP.WepSelectIcon2box = true

SWEP.CustomShell = "9x19"

SWEP.weight = 1
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/p226/p226_fire_close.ogg", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/darsu_eft/p226/p226_fire_silenced_indoor_distant.ogg", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 22
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.1

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.2692, 2.8949)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.02, -0.02, 0), Angle(-0.03, 0.02, 0)}
SWEP.Ergonomics = 1.3
SWEP.Penetration = 7
SWEP.ShockMultiplier = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3

SWEP.LocalMuzzlePos = Vector(0, -2.5, 2.7)
SWEP.LocalMuzzleAng = Angle(0.398, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

SWEP.WorldPos = Vector(3.5, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 22
SWEP.DistSound = "zcitysnd/sound/weapons/makarov/makarov_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 4
SWEP.AnimShootMul = 3

SWEP.podkid = 1

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(-1, 0.5, 0), {}},
		[2] = {"supressor3", Vector(-1, 0.5, 0), {}},
		["mount"] = Vector(-0.1, 0.4, 0.03),
		["mountAngle"] = Angle(0, 0, 0),
	},
	sight = {
		["mountType"] = "pistolmount",
		["mount"] = Vector(-6, -0.9, 0.05),
		["mountAngle"] = Angle(0, 0, 180),
	},
	underbarrel = {
		["mount"] = Vector(12.2, 1.2, -1),
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
