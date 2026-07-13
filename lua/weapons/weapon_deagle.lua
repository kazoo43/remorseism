SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Desert Eagle"
SWEP.Author = "Magnum Research/Israel Weapon Industries"
SWEP.Instructions = "Pistol chambered in .50 Magnum"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_deagle.mdl"
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakePos = Vector(-23, 2.55, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0.05,-0.3,0)
SWEP.AttachmentAng = Angle(90,0,0)
SWEP.FakeMagDropBone = 48

SWEP.FakeBodyGroups = "112213121"
SWEP.FakeBodyGroupsPresets = {
	"112213121",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "inspect",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["reload"] = {
        [0.1] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_mag_out.ogg") end,
        [0.55] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_mag_in.ogg") end,
    },
    ["reload_empty"] = {
        [0.025] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_chamber_out.ogg") end,
		[0.2] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_mag_out_all.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_mag_in.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/deagle/deagle_chamber_in.ogg") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl" 

SWEP.lmagpos = Vector(1.5,0,0)
SWEP.lmagang = Angle(-15,0,1)
SWEP.lmagpos2 = Vector(0,2.4,0)
SWEP.lmagang2 = Angle(0,0,-105)

if CLIENT then
	local vector_full = Vector(1, 1, 1)

	SWEP.FakeReloadEvents = {
		[0.25] = function(self,timeMul)
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1 * timeMul,nil,nil,function()
					self:GetWM():ManipulateBoneScale(48, vector_full)
					for i = 49, 55 do
						self:GetWM():ManipulateBoneScale(i, vector_full)
					end
				end)
			end
		end,
		[0.33] = function( self, timeMul ) 
			self:GetWM():ManipulateBoneScale(48, vector_origin)
			for i = 49, 55 do
				self:GetWM():ManipulateBoneScale(i, vector_origin)
			end
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,55,0) )
			end
			if self:Clip1() > 0 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.4 * timeMul,nil,nil,function()
					self:GetWM():ManipulateBoneScale(48, vector_full)
					for i = 49, 55 do
						self:GetWM():ManipulateBoneScale(i, vector_full)
					end
				end)
			end
		end
	}
end

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_deagle_xix.png")
SWEP.IconOverride = "entities/arc9_eft_deagle_xix.png"
SWEP.FakeEjectBrassATT = "2"
SWEP.CustomShell = "50ae"
--SWEP.EjectPos = Vector(0,5,5)
--SWEP.EjectAng = Angle(-80,50,0)
SWEP.EjectAddAng = Angle(0,0,0)

SWEP.weight = 1.5

SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(0, -1, 2.7)
SWEP.LocalMuzzleAng = Angle(0,-0.026,0.298)
SWEP.WeaponEyeAngles = Angle(0,0,90)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_57"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".50 Action Express"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Sound = {"weapons/darsu_eft/deagle/deagle_outdoor_close.wav", 75, 60, 70}
SWEP.SupressedSound = {"weapons/tfa_ins2/usp_tactical/fp_suppressed1.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 95, 100, CHAN_WEAPON, 2}
SWEP.Primary.Force = 30
SWEP.Primary.Wait = 0.2
SWEP.ReloadTime = 3.3


SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -1.7431, 4.2888)
SWEP.RHandPos = Vector(0, -0.5, -1)
SWEP.LHandPos = false
SWEP.Ergonomics = 0.9
SWEP.Penetration = 11
SWEP.SprayRand = {Angle(-0.4, -0.2, 0), Angle(-0.5, 0.2, 0)}
SWEP.AnimShootMul = 4
SWEP.AnimShootHandMul = 2
SWEP.WorldPos = Vector(2.5, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-90, -0, 0)
SWEP.lengthSub = 20
SWEP.availableAttachments = {
	sight = {
		["mountType"] = "pistolmount",
		["mount"] = Vector(-7, -0.2, 0),
		["mountAngle"] = Angle(0, 0, 0),
	},
	underbarrel = {
		["mount"] = Vector(12.2, -1.2, -1),
		["mountAngle"] = Angle(0, -0.75, 90),
		["mountType"] = "picatinny_small"
	},
}

SWEP.ShockMultiplier = 2

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-2, 2, 4.5)
SWEP.holsteredAng = Angle(20, -90, -90)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

SWEP.ShootAnimMul = 7

local vector_one = Vector(1,1,1)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,(self:Clip1() > 0 or self.reload) and 0 or 3)
		wep:ManipulateBonePosition(44,Vector(0 ,0 ,-1*self.shooanim ),false)
	end
end

SWEP.punchmul = 5
SWEP.punchspeed = 1
SWEP.podkid = 2
