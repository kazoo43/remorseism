SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Patriot"
SWEP.Author = "Colt’s Manufacturing Company"
SWEP.Instructions = "Model 231, chambered in 5.56x45\n\nRate of fire 900 rounds per minute"
SWEP.Category = "Weapons - Machineguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ud_m16.mdl"

SWEP.FakePos = Vector(-14, 2.9, 6.5)
SWEP.FakeAng = Angle(0, 0, 0.1)
SWEP.AttachmentPos = Vector(3.8,2.1,-27.8)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "534026630225"
SWEP.ZoomPos = Vector(0, 0.089, 5.1484)

SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.29] = "weapons/arccw_ud/m16/grab.ogg",
	[0.34] = "weapons/arccw_ud/m16/magout.ogg",
	[0.38] = "weapons/ak74/ak74_magout_rattle.wav",

	[0.64] = "weapons/arccw_ud/m16/grab.ogg",
	[0.64] = "weapons/arccw_ud/m16/magin.ogg",
	[0.81] = "weapons/universal/uni_crawl_l_03.wav",
	[0.99] = "weapons/universal/uni_crawl_l_04.wav",

}

SWEP.FakeEmptyReloadSounds = {

	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.29] = "weapons/arccw_ud/m16/magout_empty.ogg",
	[0.32] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.59] = "weapons/arccw_ud/m16/grab.ogg",
	[0.62] = "weapons/arccw_ud/m16/magin.ogg",

	[0.83] = "weapons/arccw_ud/m16/magtap.ogg",
	[1.01] = "weapons/universal/uni_crawl_l_04.wav",
}

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"dovetail","picatinny"},
		["mount"] = {["dovetail"] = Vector(-15, 2.5, -0.2),["picatinny"] = Vector( -15, 2.72, -0.25 )},
	},
		barrel = {
		[1] = {"supressor2", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(2.7,0,-0.2), {}},
		["mount"] = Vector(-2.2,0.45,-0.05),
	},
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_100",
	["reload_empty"] = "reload_empty_100",
}

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(3,9.5,-16.5)
SWEP.lmagang2 = Angle(0,0,-90)
SWEP.FakeMagDropBone = 52

if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.MagModel = "models/weapons/arccw/c_ud_m16.mdl"
	SWEP.FakeReloadEvents = {	
		[0.15] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,

		[0.25] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_full)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,
		[0.30] = function(self,timeMul)
			if self:Clip1() < 1 then
				local ent = hg.CreateMag( self, Vector(0,0,-12), self.FakeBodyGroups or "0", true)
				for i = 0, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, vector_origin)
				end
				ent:ManipulateBoneScale(52, vector_full)
				ent:ManipulateBoneScale(55, vector_full)

				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_origin)
				--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.50] = function(self,timeMul)
			self:GetWM():ManipulateBoneScale(52, vector_full)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(55, vector_origin)
			end
		end,
		[0.85] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(55, vector_origin)
			end
		end
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():ManipulateBoneScale(55, vector_origin)
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.BurstNum = 0


SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"

SWEP.CustomShell = "556x45"


SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 35
SWEP.Primary.Sound = {"m4a1/m4a1_fp.wav", 75, 90, 100}
SWEP.SupressedSound = {"m4a1/m4a1_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.065
SWEP.ReloadTime = 9
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magout.wav",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magin.wav",
	"weapons/tfa_ins2/akp/aks74u/aks_boltback.wav",
	"weapons/tfa_ins2/akp/aks74u/aks_boltrelease.wav",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle2" -- shared in sh_effects.lua

SWEP.LocalMuzzlePos = Vector(15.0,0.13,2.7)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.HoldType = "rpg"

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 11
SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.015 - math.cos(i) * 0.025, math.cos(i * i) * 0.025, 0) * 1
end

SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_m4a1.png")
SWEP.IconOverride = "entities/arc9_eft_m4a1.png"

SWEP.Ergonomics = 1.05
SWEP.WorldPos = Vector(5, -0.8, -1.1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(-10, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(1, -1.5, 0)
SWEP.DistSound = "m16a4/m16a4_dist.wav"



SWEP.weight = 3

--local to head
SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
--local to rh
SWEP.LHPos = Vector(15,1,-3.3)
SWEP.LHAng = Angle(-110,-180,0)

local finger1 = Angle(25,0, 40)

SWEP.ShootAnimMul = 4
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = Lerp(FrameTime()*15,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0 * self.shooanim
		vec[2] = 0 * self.shooanim
		vec[3] = -2 * self.shooanim
		wep:ManipulateBonePosition(46,vec,false)
	end
end

-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}

