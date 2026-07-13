SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TT-33"
SWEP.Author = "Tula Arms Plant"
SWEP.Instructions = "An semi-automatic Soviet pistol chambered in 7.62x25 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_elite_single.mdl"
SWEP.WorldModelFake = "models/weapons/c_tt33.mdl"
-- SWEP.GetDebug = true

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_tt33.png")
SWEP.IconOverride = "entities/arc9_eft_tt33.png"
SWEP.WepSelectIcon2box = true

SWEP.FakePos = Vector(-22, 2.5, 9)
SWEP.FakeAng = Angle(-1, 0, 0)
SWEP.AttachmentPos = Vector(1.35,1.5,0.5)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.MagIndex = nil
SWEP.FakeBodyGroups = "130211"
SWEP.FakeBodyGroupsPresets = {
	"130211",
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
	["inspect"] = "inspect",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["reload"] = {
        [0.2] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_out.ogg") end,
        [0.6] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_in.ogg") end,
    },
    ["reload_empty"] = {
        [0.005] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_slider_out.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_out.ogg") end,
		[0.48] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_in.ogg") end,
		[0.68] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_slider_in.ogg") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.CustomShell = "10mm"
SWEP.EjectAng = Angle(0,0,0)

SWEP.weight = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(-1, -2.5, 7.5)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x25 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 35
SWEP.Primary.Sound = {"weapons/darsu_eft/tt33/tt_fire_outdoor_close.wav", 75, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/tt33/pb_silenced_indoor_close1.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 35
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 5

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.UseCustomWorldModel = true
SWEP.WorldPos = Vector(2, -0.8, 2.6)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -1.8, 7) -- use hg_setzoompos to set correct zoompos
SWEP.RHandPos = Vector(-13.5, 0, 3)
SWEP.LHandPos = false
SWEP.attPos = Vector(0, -2, -0.5)
SWEP.attAng = Angle(0, 0, 0)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, 1, -7)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
        ["mount"] = Vector(-1.2,0.73,0),
    }
}

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

SWEP.ShootAnimMul = 3
SWEP.SightSlideOffset = 0.8

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50
SWEP.FakeMagDropBone = "vm_mag"

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(-12.7,0,-2.4)
SWEP.lmagang2 = Angle(90,0,-110)

local magvec = Vector(0, -0.1, 0)
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(97, Vector(0, 1.5 * self.shooanim, 0), false)
		wep:ManipulateBonePosition(95, magvec, false)
	end
end

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(6,0,5),
	Angle(15,0,14),
	Angle(16,0,16),
	Angle(4,0,12),
	Angle(-6,0,-2),
	Angle(-15,7,-15),
	Angle(-16,18,-35),
	Angle(-17,17,-42),
	Angle(-18,16,-44),
	Angle(-14,10,-46),
	Angle(-2,2,-4),
	Angle(0,0,0)
}