SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "UMP 45"
SWEP.Author = "Heckler & Koch"
SWEP.Instructions = "The H&K UMP is a modern polymer-framed submachine gun, designed as a more affordable and versatile successor to the iconic MP5. Chambered in 9mm, .40 S&W, or .45 ACP, it features a simple blowback action and a folding stock for compactness."
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_ump45.mdl"
SWEP.WorldModelFake = "models/weapons/c_ump45.mdl"
//SWEP.FakeScale = 1.2
//SWEP.ZoomPos = Vector(0, -0.0027, 4.6866)
SWEP.FakePos = Vector(-9.5, 1.92, 5.77)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-0.3,-0.22,-0.8)
SWEP.AttachmentAng = Angle(0,0,0)
//SWEP.MagIndex = 53
//MagazineSwap
--Entity(1):GetActiveWeapon():GetWM():AddLayeredSequence(Entity(1):GetActiveWeapon():GetWM():LookupSequence("delta_foregrip"),1)
--PrintBones(Entity(1):GetActiveWeapon():GetWM())

-- ОБЫЧНАЯ ПЕРЕЗАРЯДКА
-- Путь: weapons/tfa_ins2/ump45/handling/
SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",                    -- Одежда
	[0.35] = "weapons/tfa_ins2/ump45/handling/ump45_magout.wav",       -- Вытаскиваем магазин
	[0.65] = "weapons/universal/uni_crawl_l_02.wav",                    -- Шуршание
	[0.78] = "weapons/tfa_ins2/ump45/handling/ump45_magin.wav",        -- Вставляем магазин
	[0.94] = "weapons/universal/uni_crawl_l_04.wav",
}

-- ПЕРЕЗАРЯДКА ПРИ ПУСТОМ МАГАЗИНЕ
-- Путь: weapons/tfa_ins2/ump45/handling/
SWEP.FakeEmptyReloadSounds = {
	[0.16] = "weapons/universal/uni_crawl_l_03.wav",
	[0.22] = "weapons/tfa_ins2/ump45/handling/ump45_magrelease.wav",   -- Рычаг сброса
	[0.30] = "weapons/tfa_ins2/ump45/handling/ump45_magout.wav",       -- Выпадение магазина
	[0.45] = "weapons/tfa_ins2/ump45/handling/ump45_magin.wav",        -- Вставка нового
	
	-- Снятие с затворной задержки
	[0.85] = "weapons/tfa_ins2/ump45/handling/ump45_boltrelease.wav", 
}


SWEP.MagModel = "models/eu_homicide/mp7_magazine.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,-1,0)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 60
SWEP.FakeMagDropBone = 14

SWEP.FakeReloadEvents = {
	[0.2] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			--self:GetWM():SetBodygroup(1,1)
			--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
		end 
	end,
	[0.35] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,55,-55) )
			self:GetWM():ManipulateBoneScale(14, vector_origin)
			self:GetWM():ManipulateBoneScale(15, vector_origin)
		end 
	end,
	[0.45] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():SetBodygroup(1,0)
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
		end 
	end,
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ump.png")
SWEP.IconOverride = "entities/arc9_eft_ump.png"

SWEP.CustomShell = "9x19"
//SWEP.EjectPos = Vector(-2.5,0,-3)
SWEP.EjectAng = Angle(0,40,-15)

SWEP.ShockMultiplier = 2

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -3)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.LocalMuzzlePos = Vector(15.528,0.5,4)
SWEP.LocalMuzzleAng = Angle(0.25,-0.026,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weight = 3
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "EjectBrass_57"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ".45 ACP"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 37
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 37
SWEP.animposmul = 2
-- ЗВУКИ СТРЕЛЬБЫ
-- Путь: weapons/tfa_ins2/ump45/
SWEP.Primary.Sound = {"weapons/tfa_ins2/ump45/ump45_fp.wav", 85, 120, 130}
SWEP.SupressedSound = {"weapons/tfa_ins2/ump45/ump45_suppressed_fp.wav", 75, 90, 100}

-- Звук пустого щелчка
SWEP.Primary.SoundEmpty = {"weapons/tfa_ins2/ump45/ump45_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}

SWEP.Primary.Wait = 0.09

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ump.png")

SWEP.availableAttachments = {
	barrel = {
		[1] = {"", Vector(1,4,12), {}},
		[2] = {"", Vector(0,0,0), {}},
		["Mount"] = Vector(0,0,0),
	},
	sight = {
		["mount"] = Vector(-15, 2.65, 0.84),
		["mountType"] = "picatinny",
		["empty"] = {"empty", {}},
		["removehuy"] = {},
	},
}

SWEP.ReloadTime = 3
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/mp7/magout.wav",
	"none",
	"none",
	"weapons/tfa_ins2/mp7/magin.wav",
	"none",
	"weapons/tfa_ins2/mp7/boltback.wav",
	"weapons/tfa_ins2/mp7/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "muzzleflash_FAMAS" -- shared in sh_effects.lua

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, -1.5, 5.0211)
SWEP.RHandPos = Vector(1, -1, 0)
SWEP.LHandPos = false
SWEP.Spray = {}
for i = 1, 40 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.01, math.cos(i * 8) * 0.01, 0) * 1
end

SWEP.Ergonomics = 1.1
SWEP.Penetration = 9
SWEP.WorldPos = Vector(-2, 0, -2.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 30
SWEP.handsAng = Angle(-15, 9, 0)
SWEP.DistSound = "mp5k/mp5k_dist.wav"

--local to head
SWEP.RHPos = Vector(8,-7,3)
SWEP.RHAng = Angle(-5,4,90)
--local to rh
SWEP.LHPos = Vector(9,-0.5,-3.3)
SWEP.LHAng = Angle(-40,15,-100)

SWEP.ShootAnimMul = 2

function SWEP:AnimHoldPost(model)
	--self:BoneSet("l_finger0", Vector(0, 0, 0), Angle(-5, -10, 0))
	--self:BoneSet("l_finger02", Vector(0, 0, 0), Angle(0, 25, 0))
	--self:BoneSet("l_finger01", Vector(0, 0, 0), Angle(-25, 40, 0))
	--self:BoneSet("l_finger1", Vector(0, 0, 0), Angle(-10, -40, 0))
	--self:BoneSet("l_finger11", Vector(0, 0, 0), Angle(-10, -40, 0))
	--self:BoneSet("l_finger2", Vector(0, 0, 0), Angle(-5, -50, 0))
	--self:BoneSet("l_finger21", Vector(0, 0, 0), Angle(0, -10, 0))
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self:Clip1() > 0 and 0 or 0)
		--wep:ManipulateBonePosition(2,Vector(0 ,0 ,-1.8*self.shooanim ),false)
		--wep:ManipulateBonePosition(1,Vector(-0.5*self.ReloadSlideOffset ,0 ,0.1*self.ReloadSlideOffset),false)
	end
end

--RELOAD ANIMS SMG????

SWEP.ReloadAnimLH = {
	Vector(0,0,0)
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0)
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,2,4),
	Vector(0,0,5),
	Vector(-5,-3,9),
	Vector(-15,-15,2),
	Vector(-15,-15,2),
	Vector(-2,1,8),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,2),
	"fastreload",
	Vector(-5,2,-1),
	Vector(-12,1,-3),
	Vector(-10,1,-3),
	Vector(-5,4,-1),
	"reloadend",
	"reloadend"
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-25,25,-44),
	Angle(-15,25,-45),
	Angle(-25,25,-45),
	Angle(-35,26,-44),
	Angle(-35,25,-45),
	Angle(-25,25,-44),
	Angle(-25,25,-44),
	Angle(-45,45,-55),
	Angle(-35,45,-55),
	Angle(-15,15,-24),
	Angle(0,0,0)
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
	5,
	5,
	5,
	0,
	0,
	0,
	0,
	0,
	0
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
	Angle(15,0,5),
	Angle(15,0,14),
	Angle(15,0,14),
	Angle(15,0,15),
	Angle(15,0,16),
	Angle(12,0,5),
	Angle(2,0,-15),
	Angle(0,0,-45),
	Angle(0,0,-45),
	Angle(0,0,-45),
	Angle(0,0,-45),
	Angle(5,15,-65),
	Angle(5,15,-65),
	Angle(4,15,-65),
	Angle(0,0,0)
}