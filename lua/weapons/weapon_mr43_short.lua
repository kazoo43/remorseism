SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MR-43 Short"
SWEP.Author = "Molot-Oruzhie"
SWEP.Instructions = "Short version of the MR-43 side-by-side shotgun. Chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.WorldModelFake = "models/weapons/c_mr43.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mr43.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/arc9_eft_mr43.png"

SWEP.addSprayMul = 2
SWEP.ShellEject = false
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"
SWEP.weight = 3
SWEP.addweight = 4
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.02, 0.02, 0.02)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"sound/weapons/darsu_eft/mr43/mr43_fire_indoor_close1.wav", 80, 100, 75}
SWEP.Primary.Wait = 0
SWEP.OpenBolt = true

SWEP.FakePos = Vector(-14, 1.75, 3)
SWEP.FakeAng = Angle(0, 0, 2.5)
SWEP.AttachmentPos = Vector(0,-0.2,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"

SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,2)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "CAM_Homefield"

local mr43_path = "weapons/darsu_eft/mr43/"

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
	["inspect"] = "look",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
	["reload"] = {
		[0.10] = function(self) self:EmitSound(mr43_path .. "mr43_barrels_open.ogg") end,
		[0.25] = function(self) self:EmitSound(mr43_path .. "mr43_ammo_unload_single1.ogg") end,
		[0.6] = function(self) self:EmitSound(mr43_path .. "mr43_ammo_load_single1.ogg") end,
		[0.85] = function(self) self:EmitSound(mr43_path .. "mr43_barrels_close.ogg") end,
	},
	["reload_empty"] = {
		[0.10] = function(self) self:EmitSound(mr43_path .. "mr43_barrels_open.ogg") end,
		[0.25] = function(self) self:EmitSound(mr43_path .. "mr43_ammo_unload_double.ogg") end,
		[0.6] = function(self) self:EmitSound(mr43_path .. "mr43_ammo_load_double.ogg") end,
		[0.85] = function(self) self:EmitSound(mr43_path .. "mr43_barrels_close.ogg") end,
	},
	["look"] = {
		[0.01] = function(self) self:EmitSound(mr43_path .. "mr43_inspect.ogg") end,
	},
}

local vector_full = Vector(1,1,1)
SWEP.FakeReloadEvents = {
	[0.15] = function( self, timeMul )
		if CLIENT then
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1.4 * timeMul)
		end
	end
}

SWEP.FakeBodyGroups = "11043"

SWEP.stupidgun = true

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end

SWEP.cameraShakeMul = 0.25

SWEP.LocalMuzzlePos = Vector(18.893,-2.5,1.248)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Chocking = false

SWEP.punchmul = 1
SWEP.punchspeed = 0.1

SWEP.NumBullet = 8
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-26, -2.5, 1.8)
SWEP.RHandPos = Vector(-15, -2, 4)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.5, -0.2, 0), Angle(-1, 0.2, 0)}
SWEP.Ergonomics = 0.95
SWEP.Penetration = 7
SWEP.WorldPos = Vector(4, -1, -2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(-19, 0.2, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 20
SWEP.DistSound = "toz_shotgun/toz_dist.wav"

SWEP.IsPistol = false
SWEP.podkid = 2
SWEP.animposmul = 1
SWEP.ReloadTime = 6

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.ReloadHold = "pistol"

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:AnimHoldPost(model)

end

function SWEP:ReloadStartPost()
	if not self or not IsValid(self:GetOwner()) then return end
	self.reloadMiddle = CurTime() + self.ReloadTime / 3
end
SWEP.Shooted = 0
function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() != LocalPlayer() and not override then return false end
	local primary = self.Primary

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
    if not self.drawBullet or (self:Clip1() == 0 and not override) then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end
    self.Shooted = self.Shooted + 1

	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	self:PrimaryShoot()
	self:PrimaryShootPost()
end

function SWEP:Step()
	self:CoreStep()
	local owner = self:GetOwner()
	if not IsValid(owner) or not IsValid(self) then return end
	if CLIENT then
		if self.reloadMiddle and self.reloadMiddle < CurTime() then
            if self.Shooted > 0 then
				local ammotype = hg.ammotypes[string.lower( string.Replace( self.Primary and self.Primary.Ammo or "nil"," ", "") )].BulletSettings
			    self:MakeShell(ammotype.Shell, owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_L_Hand")), Angle(0,0,0), Vector(0,0,0))
                self.Shooted = self.Shooted - 1
			else
				self.reloadMiddle = nil
			end
		end
	end
end

SWEP.RHPos = Vector(3,-4,3.5)
SWEP.RHAng = Angle(0,0,90)
SWEP.LHPos = Vector(15,-1,-3.3)
SWEP.LHAng = Angle(-110,-90,-90)

local ang1 = Angle(30, -20, 0)
local ang2 = Angle(-10, 50, 0)

function SWEP:AnimationPost()
	self:BoneSet("l_finger0", vector_origin, ang1)
	self:BoneSet("l_finger02", vector_origin, ang2)
end



function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

