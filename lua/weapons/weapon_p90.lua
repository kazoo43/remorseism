SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "FN P90"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Submachine gun chambered in 5.7x28 mm\n\nRate of fire 900 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.WorldModelFake = "models/weapons/c_p90.mdl"

SWEP.FakePos = Vector(-2.5, 3.65, 7.6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 2.2, -28)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "11221230002"
SWEP.ZoomPos = Vector(0, -0.6317, 5.4298)

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2, 12, 10)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "1"

SWEP.MagModel = "models/weapons/tfa_ins2/c_mwr_p90.mdl"
SWEP.lmagpos = Vector(-3.2, -3, -12)
SWEP.lmagang = Angle(0, 0, 90)
SWEP.lmagpos2 = Vector(-16, 3.4, 3)
SWEP.lmagang2 = Angle(0, 0, 0)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 20

SWEP.FakeVPShouldUseHand = false
SWEP.FakeMagDropBone = 14

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "inspect0",
}

local path = "weapons/darsu_eft/p90/"

SWEP.AnimsEvents = {
	["reload"] = {
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_mag_out.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_mag_in_01_slide.ogg") end,

	},
	["reload_empty"] = {
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_mag_out.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_mag_in_01_slide.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_bolt_in.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/p90/p90_bolt_out.ogg") end,
	},
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.15] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
		end,
		[0.45] = function(self, timeMul)
			if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self:GetWM()) and self:Clip1() < 1 then
				local ent = hg.CreateMag(self, Vector(0, 10, 5))
				for i = 0, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, vector_origin)
				end
				ent:ManipulateBoneScale(14, vector_full)
				ent:ManipulateBoneScale(15, vector_full)
			end
			self:GetWM():ManipulateBoneScale(14, vector_origin)
			self:GetWM():ManipulateBoneScale(15, vector_origin)
		end,
		[0.55] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
			self:UpdateMagazineBodygroup(math.min(self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) + self:Clip1(), 50))
		end,
		[0.85] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
		end,
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
		self:UpdateMagazineBodygroup()
	end
end

SWEP.ReloadHold = nil
SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.7x28 mm"

SWEP.CustomShell = "57x28"

SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 32
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/p90/fire/p90_indoor1.wav", 75, 120, 130}
SWEP.SupressedSound = {"weapons/darsu_eft/p90/fire/p90_silenced1.ogg", 75, 120, 130}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m14/handling/m14_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.05
SWEP.ReloadTime = 4.2

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.LocalMuzzlePos = Vector(17, -0.5, 5)
SWEP.LocalMuzzleAng = Angle(-0.2, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.StartAtt = {"holo4"}
SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = Vector(-2, -0.01, -2.1),
		["mountAngle"] = Angle(0, -0.75, -90),
	},
	barrel = {
		[1] = {"supressor1", Vector(0, 0.6, 0.1), {}},
		[2] = {"supressor8", Vector(0, 0, 0), {}},
		["mount"] = Vector(4, -0.1, 0),
		
	},
}

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 10
SWEP.Spray = {}
for i = 1, 50 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.01, math.cos(i * 8) * 0.02, 0) * 1
end

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_fn_p90.png")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "entities/arc9_eft_fn_p90.png"

SWEP.Ergonomics = 1.1
SWEP.WorldPos = Vector(-7, 0, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)
SWEP.lengthSub = 30
SWEP.handsAng = Angle(-10, 8, 0)
SWEP.DistSound = "mp5k/mp5k_dist.wav"

SWEP.weight = 2.5

SWEP.RHPos = Vector(6, -7.5, 3.5)
SWEP.RHAng = Angle(0, -10, 90)
SWEP.LHPos = Vector(5, 0, -3.5)
SWEP.LHAng = Angle(-15, -10, -90)

SWEP.ShootAnimMul = 3

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(2, 8, -4)
SWEP.holsteredAng = Angle(210, 0, 180)

function SWEP:OnReloaded()
	self.BaseClass.OnReloaded(self)

	if CLIENT then
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdateMagazineBodygroup()
			end
		end)
	end
end

function SWEP:SetClip1(amount)
	self.BaseClass.SetClip1(self, amount)

	if CLIENT then
		self:UpdateMagazineBodygroup()
	end
end

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	if CLIENT then
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdateMagazineBodygroup()
			end
		end)
	end
end

function SWEP:PrimaryShoot()
	self.BaseClass.PrimaryShoot(self)

	if CLIENT then
		self:UpdateMagazineBodygroup()
	end
end

function SWEP:UpdateMagazineBodygroup(overideClip)
	if CLIENT and IsValid(self:GetWM()) then
		local clipSize = self.Primary.ClipSize
		local currentAmmo = overideClip or self:Clip1()

		local bodygroup = math.SnapTo(currentAmmo / 5, 1)

		self:GetWM():SetBodygroup(1, bodygroup)
	end
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0, 0, 0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = Lerp(FrameTime() * 15, self.shooanim or 0, self.ReloadSlideOffset)
		vec[1] = 0 * self.shooanim
		vec[2] = 1 * self.shooanim
		vec[3] = 0 * self.shooanim
		wep:ManipulateBonePosition(8, vec, false)
	end
end

local lfang2 = Angle(0, -15, -1)
local lfang1 = Angle(-5, -5, -5)
local lfang0 = Angle(-12, -16, 20)
local vec_zero = Vector(0, 0, 0)
local ang_zero = Angle(0, 0, 0)
function SWEP:AnimHoldPost()
end

