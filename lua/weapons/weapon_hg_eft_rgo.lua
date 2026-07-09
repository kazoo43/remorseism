if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "RGO"
SWEP.Instructions =
[[RGO is a defensive fragmentation grenade.
High fragment density and dangerous close blast radius.
Best used from cover and prepared positions.

R on surface: set tripwire.

LMB - High throw
In high throw mode:
RMB - release safety lever
R - reinsert pin

RMB - Low throw
In low throw mode:
LMB - release safety lever
R - reinsert pin
]]

SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true

SWEP.WorldModel = "models/weapons/EFTNades/darsu_eft/w_rgo_unthrowed.mdl"
SWEP.WorldModelReal = "models/weapons/EFTNades/darsu_eft/c_rgn_rgo_1.mdl"
SWEP.WorldModelExchange = false

SWEP.ENT = "ent_hg_eft_rgo"

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/weapon_hg_eft_rgo.png")
	SWEP.IconOverride = "entities/weapon_hg_eft_rgo.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/rgd5_skoba.mdl"

SWEP.AnimsEvents = {
	["draw"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/darsu_eft/grenades/rgd_draw.ogg",65)
		end,
	},
	["fire_start"] = {
		[0.31] = function(self)
			self:EmitSound("weapons/darsu_eft/grenades/rgd_pin.ogg",65)
		end,
	},
}

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "draw", 1.1, false },
    ["attack"] = { "fire1", 1, false, false, function(self)

		if CLIENT then return end

		self:Throw(1200, self.SpoonTime or CurTime(),nil,Vector(2,4,0),Angle(-40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.65 },
	["attack2"] = { "fire2", 0.8, false, false, function(self)
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		if CLIENT then return end
		self:Throw(600, self.SpoonTime or CurTime(),nil,Vector(0,4,-6),Angle(40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end

			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"fire_start", 1.5, false, false, function(self) 
		self:SetShowPin(false)
		--self:PlayAnim("attack")
		self.ReadyToThrow = true
	end,0.8},
	["pullbacklow"] = {"fire_start", 1.5, false, false, function(self) 
		--self:PlayAnim("attack2")
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.8},
	["trapplace"] = {"mine_fire", 1.8, false, false, function(self)
		self.ReadyToTrap = true
	end},
	["idle"] = {"idle", 1, false,false,function(self)
	end}
}

SWEP.HoldPos = Vector(-2,-1,-1.5)
SWEP.HoldAng = Angle(0,0,0)
SWEP.NoTrap = false

SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 50

SWEP.CallbackTimeAdjust = 0.1

SWEP.traceLen = 5

SWEP.ItemsBones = {
	["Grenade"] = {88},
	["Pin"] = {92},
}

SWEP.CoolDown = 0

SWEP.SpoonSounds = {
	[1] = {"snd_jack_spoonfling.ogg", 65},
	[2] = {"weapons/darsu_eft/grenades/gren_fuze1.ogg", 70, 200, true}
}




