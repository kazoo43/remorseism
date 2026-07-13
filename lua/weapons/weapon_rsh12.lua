SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "RSh-12"
SWEP.Author = "TsNIITochMash"
SWEP.Instructions = "A Russian heavy revolver chambered in 12.7x55mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_rsh12.mdl"

SWEP.FakePos = Vector(-23, 2, 5.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, -0.2)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "11111111"
SWEP.FakeBodyGroupsPresets = {
	"11111111",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "sg_reload_start1__0",
	["reload_empty"] = "fistful_start__0",
	["inspect"] = "look__0",
}

SWEP.AnimDurations = {
	["fistful_start__0"]    = 1.25,
	["sg_reload_start1__0"] = 3.25,
	["sg_reload_start2__0"] = 2.95,
	["sg_reload_start3__0"] = 2.65,
	["sg_reload_start4__0"] = 2.35,
}


local path = "weapons/darsu_eft/rsh12/"
SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["fistful_start__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "rsh_12_reload_start.ogg") end,
        [0.25] = function(self) self:EmitSound(path .. "rsh_12_purge_shells.ogg") end,
    },
    ["sg_reload_start1__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "rsh_12_reload_start.ogg") end,
        [0.4] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.65] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.95] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,

    },
    ["sg_reload_start2__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "rsh_12_reload_start.ogg") end,
        [0.5] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.65] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.85] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
    },
    ["sg_reload_start3__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "rsh_12_reload_start.ogg") end,
        [0.5] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
        [0.75] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
    },
    ["sg_reload_start4__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "rsh_12_reload_start.ogg") end,
        [0.6] = function(self) self:EmitSound(path .. "rsh_12_ammo_out.ogg") end,
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

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_rsh12.png")
SWEP.IconOverride = "entities/arc9_eft_rsh12.png"
SWEP.WepSelectIcon2box = true

SWEP.CustomShell = "50ae"

SWEP.weight = 1.8
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = nil
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".50 Action Express"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 55
SWEP.Primary.Sound = {"weapons/arccw_ur/deagle/fire-01.ogg", 75, 55, 65}
SWEP.SupressedSound = false
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 35
SWEP.Primary.Wait = 0.3
SWEP.ReloadTime = 5

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.3093, 4.9555)
SWEP.RHandPos = Vector(-4, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.2, -0.2, 0), Angle(-0.25, 0.2, 0)}
SWEP.Ergonomics = 0.9
SWEP.Penetration = 12
SWEP.ShockMultiplier = 3
SWEP.punchmul = 6
SWEP.punchspeed = 0.8
SWEP.ReloadHold = "pistol"

SWEP.LocalMuzzlePos = Vector(25, -3, 5.7)
SWEP.LocalMuzzleAng = Angle(0.398, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

SWEP.WorldPos = Vector(5, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 22
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 7
SWEP.AnimShootMul = 5

SWEP.podkid = 2

SWEP.availableAttachments = {
	sight = {
		["mountType"] = "picatinny",
		["mount"] = Vector(-3, 0.5, 0),
		["mountAngle"] = Angle(0, 0, 0),
	},
}

SWEP.Shooted = 0
SWEP.AutomaticDraw = false

if CLIENT then
	SWEP.FakeReloadEvents = {
		[0.15] = function(self, timeMul)
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1 * timeMul)
			else
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.4 * timeMul)
			end
		end,
	}
end

function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() ~= LocalPlayer() and not override then return false end

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

local function RSh12_FinishReload(wep)
	if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end

	local startClip = wep.reloadStartClip or wep:Clip1()
	local toLoad    = wep.reloadToLoad   or 0
	local ammoType  = wep:GetPrimaryAmmoType()
	local owner     = wep:GetOwner()

	if toLoad > 0 then
		owner:RemoveAmmo(toLoad, ammoType)
	end

	local finalClip = math.min(startClip + toLoad, wep.Primary.ClipSize)
	wep:SetClip1(finalClip)

	wep:SetNetVar("shootgunReload", 0)
	wep.reloadCoolDown = CurTime()

	wep.Shooted = 0

	wep:PlayAnim("idle", 1.0, false, nil, false, true)

	wep.drawBullet = true
	net.Start("hgwep draw")
		net.WriteEntity(wep)
		net.WriteBool(true)
		net.WriteFloat(CurTime() - 10)
	net.Broadcast()

	wep.reloadStartClip = nil
	wep.reloadToLoad    = nil
end

local function RSh12_PlayFistfulChain(wep, step, targetStep)
	if not IsValid(wep) then return end

	local toLoad = wep.reloadToLoad or 0
	if toLoad <= 0 then RSh12_FinishReload(wep) return end

	if step > targetStep then
		local finalClip = math.min((wep.reloadStartClip or 0) + toLoad, wep.Primary.ClipSize)
		local animEnd = "fistful_end_r" .. math.Clamp(finalClip, 1, 5)

		wep:PlayAnim(animEnd, 1.0, false, function()
			RSh12_FinishReload(wep)
		end, false, true)

		wep:EmitSound(path .. "rsh_12_reload_end.ogg")
		return
	end

	local animName = "fistful_insert" .. step
	wep:PlayAnim(animName, 1.0, false, function()
		RSh12_PlayFistfulChain(wep, step + 1, targetStep)
	end, false, true)

	timer.Simple(0.4, function()
		if IsValid(wep) then
			wep:EmitSound(path .. "rsh_12_ammo_in.ogg")
		end
	end)
end

local function RSh12_PlaySgInsertChain(wep, idx, lastIdx)
	if not IsValid(wep) then return end

	local toLoad    = wep.reloadToLoad    or 0
	local startClip = wep.reloadStartClip or wep:Clip1()
	if toLoad <= 0 then RSh12_FinishReload(wep) return end

	if idx > lastIdx then
		local finalClip = math.min(startClip + toLoad, wep.Primary.ClipSize)
		local animEnd   = "fistful_end_r" .. math.Clamp(finalClip, 1, 5)

		wep:PlayAnim(animEnd, 1.0, false, function()
			RSh12_FinishReload(wep)
		end, false, true)

		wep:EmitSound(path .. "rsh_12_reload_end.ogg")
		return
	end

	local animName = "sg_reload_insert" .. idx
	wep:PlayAnim(animName, 1.0, false, function()
		RSh12_PlaySgInsertChain(wep, idx + 1, lastIdx)
	end, false, true)

	timer.Simple(0.4, function()
		if IsValid(wep) then
			wep:EmitSound(path .. "rsh_12_ammo_in.ogg")
		end
	end)
end

function SWEP:Reload(time)
	if self.AnimStart_Draw and self.AnimStart_Draw > CurTime() - 0.5 then return end
	if not self:CanUse() then return end
	if self.reloadCoolDown and self.reloadCoolDown > CurTime() then return end
	if self.Primary.Next > CurTime() then return end
	if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

	local clip    = self:Clip1()
	local maxClip = self.Primary.ClipSize
	if clip >= maxClip then return end

	local ammoReserve = self:Ammo1()
	if ammoReserve <= 0 then return end

	if SERVER then
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local need   = maxClip - clip
		local toLoad = math.min(need, ammoReserve)
		if toLoad <= 0 then return end

		self.reloadStartClip = clip
		self.reloadToLoad    = toLoad

		if clip == 0 then
			local targetStep = math.min(toLoad, 5)

			local fistfulDur = self.AnimDurations["fistful_start__0"] or 1.25

			local estimatedTime = fistfulDur + (targetStep * 1.0) + 1.0
			self:SetNetVar("shootgunReload", CurTime() + estimatedTime)
			self.reloadCoolDown = CurTime() + estimatedTime

			self:PlayAnim("fistful_start__0", fistfulDur, false, function()
				if not IsValid(self) then return end
				RSh12_PlayFistfulChain(self, 1, targetStep)
			end, false, true)

		else
			local firstIndex = clip
			local lastIndex  = math.min(clip + toLoad - 1, 4)

			local startAnim = "sg_reload_start" .. clip .. "__0"
			local startDur = self.AnimDurations[startAnim] or 2.35

			local estimatedTime = startDur + (toLoad * 1.0) + 1.0
			self:SetNetVar("shootgunReload", CurTime() + estimatedTime)
			self.reloadCoolDown = CurTime() + estimatedTime

			self:PlayAnim(startAnim, startDur, false, function()
				if not IsValid(self) then return end
				self:EmitSound(path .. "rsh_12_ammo_out.ogg")
				RSh12_PlaySgInsertChain(self, firstIndex, lastIndex)
			end, false, true)
		end
	end
end

function SWEP:PrimaryShootPost()
	self.drawBullet = true
end

function SWEP:CanPrimaryAttack()
	return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

function SWEP:DrawPost()
	local wep = self:GetWM()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(54, Vector(0, 1.5 * self.shooanim, 0), false)
	end
end
