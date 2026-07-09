SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AK-12"
SWEP.Author = "Izhevsk Machine-Building Plant"
SWEP.Instructions = "The AK-12, \"Avtomat Kalashnikova, 2012\" (GRAU index 6P70) is a Russian gas-operated assault rifle chambered in 7.62×39mm designed and manufactured by the Kalashnikov Concern (formerly Izhmash), making it the fifth generation of Kalashnikov rifles."
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_ak400.mdl"
SWEP.WorldModelFake = "models/weapons/c_ak400.mdl" -- Контент инсурги https://steamcommunity.com/sharedfiles/filedetails/?id=3437590840
//SWEP.FakeScale = 0.9
SWEP.FakePos = Vector(7, -2.61, 6.27)
SWEP.FakeAng = Angle(0, 180, 0)
SWEP.AttachmentPos = Vector(65,20.5, 25.5)
SWEP.AttachmentAng = Angle(180,0,-270)
SWEP.MagIndex = 6
//MagazineSwap
--Entity(1):GetActiveWeapon():GetWM():AddLayeredSequence(Entity(1):GetActiveWeapon():GetWM():LookupSequence("delta_foregrip"),1)


-- ОБЫЧНАЯ ПЕРЕЗАРЯДКА (Когда патроны еще есть)
SWEP.FakeReloadSounds = {
	[0.35] = "weapons/tfa_ins2/ak400/handling/ak74_magout.wav",
	[0.38] = "weapons/tfa_ins2/ak400/handling/ak74_magout_rattle.wav",
	[0.65] = "weapons/tfa_ins2/ak400/handling/ak74_magin.wav",
	-- Звуки одежды/трения оставляем стандартные (если они есть на сервере)
	[0.75] = "weapons/universal/uni_crawl_l_03.wav",
	[0.95] = "weapons/universal/uni_crawl_l_05.wav",
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "Spine"
SWEP.ViewPunchDiv = 115

-- ПЕРЕЗАРЯДКА ПРИ ПУСТОМ МАГАЗИНЕ
SWEP.FakeEmptyReloadSounds = {
	[0.25] = "weapons/tfa_ins2/ak400/handling/ak74_magout.wav",
	[0.34] = "weapons/tfa_ins2/ak400/handling/ak74_magout_rattle.wav",
	[0.65] = "weapons/tfa_ins2/ak400/handling/ak74_magin.wav",
	[0.75] = "weapons/universal/uni_crawl_l_05.wav",
	-- Затвор
	[0.87] = "weapons/tfa_ins2/ak400/handling/ak74_boltback.wav",
	[0.96] = "weapons/tfa_ins2/ak400/handling/ak74_boltrelease.wav",
}

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
local vector_full = Vector(1, 1, 1)
SWEP.FakeReloadEvents = {
	[0.2] = function( self ) 
		if CLIENT and self:Clip1() > 1 then
			if self.MagIndex then
				self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
			end
		end 
	end,
	[1.09] = function( self ) 
		if CLIENT and self:Clip1() > 1 then
			if self.MagIndex then
				self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
			end
		end 
	end,
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
}



SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 0)
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.45x39 mm"

SWEP.CustomShell = ""
SWEP.EjectPos = Vector(0,-8,3.5)
SWEP.EjectAng = Angle(0,90,0)

SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 38
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 38
SWEP.Primary.Sound = {"weapons/tfa_ins2/ak400/ak12_semi.wav", 75, 120, 140}
SWEP.Primary.SoundEmpty = {"weapons/tfa_ins2/ak400/handling/ak74_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.075
SWEP.ReloadTime = 3.1


SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1" -- shared in sh_effects.lua

SWEP.LocalMuzzlePos = Vector(-28.5,0,3.75)
SWEP.LocalMuzzleAng = Angle(0,180,90)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.HoldType = "ar2"
SWEP.ZoomPos = Vector(10, 4.95, 0.86)
SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 11
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.02, math.cos(i * i) * 0.02, 0) * 0.5
end

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ak12.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/arc9_eft_ak12.png"

SWEP.Ergonomics = 1
SWEP.WorldPos = Vector(3, -1, -0.5)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, -6, 28)
SWEP.attAng = Angle(0, -180, -180)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(1, -1.5, 0)
SWEP.DistSound = "ak74/ak74_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(42, -0.7, 14.5)},
	},
	barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor8", Vector(0,0,0), {}},
		["mount"] = Vector(12, -1.2 , 0.5),
	},
	grip = {
		["mount"] = { [""] = Vector(26.5,-1.9,0),  },
		["mountType"] = {"ak12"}
	},
	}

SWEP.weight = 3

--local to head
SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
--local to rh
SWEP.LHPos = Vector(14,1.5,-3.6)
SWEP.LHAng = Angle(-110,-180,0)

local finger1 = Angle(25,0, 40)

SWEP.ShootAnimMul = 3
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	local vec = Vector(0,0,0)
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0*self.shooanim
		vec[2] = 1.5*self.shooanim
		vec[3] = 0*self.shooanim
		wep:ManipulateBonePosition(3,vec,false)
	end
end

local lfang2 = Angle(0, -15, -1)
local lfang1 = Angle(-5, -5, -5)
local lfang0 = Angle(-12, -15, 20)
local vec_zero = Vector(0,0,0)
local ang_zero = Angle(0,0,0)
function SWEP:AnimHoldPost()

end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-1.5,1.5,-7),
	Vector(-1.5,1.5,-7),
	Vector(-1.5,1.5,-7),
	Vector(-6,7,-9),
	Vector(-15,7,-15),
	Vector(-15,6,-15),
	Vector(-13,5,-5),
	Vector(-1.5,1.5,-7),
	Vector(-1.5,1.5,-7),
	Vector(-1.5,1.5,-7),
	"fastreload",
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,1),
	Vector(8,1,2),
	Vector(9,4,-4),
	Vector(9,5,-4),
	Vector(8,5,-4),
	Vector(1,5,-3),
	Vector(1,5,-2),
	Vector(0,4,-1),
	Vector(0,5,0),
	"reloadend",
	Vector(-2,2,1),
	Vector(0,0,0),
}

SWEP.ReloadSlideAnim = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	3,
	3,
	0,
	0,
	0,
	0
}


SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-70,0,110),
	Angle(-50,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-60,0,95),
	Angle(0,0,60),
	Angle(0,0,30),
	Angle(0,0,2),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(15,0,-50),
	Angle(15,0,-50),
	Angle(15,0,-50),
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,15,-17),
	Angle(-14,14,-22),
	Angle(-10,15,-24),
	Angle(12,14,-23),
	Angle(11,15,-20),
	Angle(12,14,-19),
	Angle(11,14,-20),
	Angle(7,17,-22),
	Angle(0,14,-21),
	Angle(0,15,-22),
	Angle(0,24,-23),
	Angle(0,25,-22),
	Angle(-15,24,-25),
	Angle(-15,25,-23),
	Angle(5,0,2),
	Angle(0,0,0),
}

-- Inspect Assault

SWEP.InspectAnimLH = {
	Vector(0,0,0)
}
SWEP.InspectAnimLHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimRH = {
	Vector(0,0,0)
}
SWEP.InspectAnimRHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(15,15,15),
	Angle(15,15,24),
	Angle(15,15,24),
	Angle(15,15,24),
	Angle(15,7,24),
	Angle(10,3,-5),
	Angle(2,3,-15),
	Angle(0,4,-22),
	Angle(0,3,-45),
	Angle(0,3,-45),
	Angle(0,-2,-2),
	Angle(0,0,0)
}