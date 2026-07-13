SWEP.Base = "weapon_mr43_short"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MR-43"
SWEP.Author = "Molot-Oruzhie"
SWEP.Instructions = "MR-43 is a side by side smoothbore shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mr43.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/arc9_eft_mr43.png"

SWEP.SprayRand = {Angle(-0.2, -0.4, 0), Angle(-0.4, 0.4, 0)}

SWEP.cameraShakeMul = 1
SWEP.FakeBodyGroups = "10133"
SWEP.addSprayMul = 1
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"
SWEP.weight = 4
SWEP.addweight = 2
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"sound/weapons/darsu_eft/mr43/mr43_fire_indoor_close1.wav", 80, 100, 75}
SWEP.Primary.Wait = 0
SWEP.OpenBolt = true

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end

SWEP.CanEpicRun = false

SWEP.LocalMuzzlePos = Vector(37.893,-2.5,1.648)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.RHandPos = Vector(-15, -2, 4)
SWEP.LHandPos = Vector(-15, -2, 4)

SWEP.IsPistol = false
SWEP.podkid = 0.5
SWEP.punchmul = 4
SWEP.punchspeed = 1
SWEP.animposmul = 2

SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.2

SWEP.attPos = Vector(0, 0.2, 0)
SWEP.attAng = Angle(0, 0, 0)

SWEP.Ergonomics = 0.8

SWEP.ZoomPos = Vector(-26, -2.5, 1.8)

SWEP.RHPos = Vector(3,-4.5,3.5)
SWEP.RHAng = Angle(0,0,90)
SWEP.LHPos = Vector(15,-0.9,-3.3)
SWEP.LHAng = Angle(-110,-90,-90)

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}
