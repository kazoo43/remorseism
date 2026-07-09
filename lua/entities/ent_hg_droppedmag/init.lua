AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.MagModelOverride or "models/kali/weapons/black_ops/magazines/30rd galil magazine.mdl")
	self.StoredAmmo = math.max(tonumber(self.StoredAmmo) or 0, 0)
	self.StoredAmmoType = tonumber(self.StoredAmmoType) or -1
	self.StoredAmmoName = tostring(self.StoredAmmoName or "")
	self:SetNWInt("StoredAmmo", self.StoredAmmo)
	self:SetNWInt("StoredAmmoType", self.StoredAmmoType)
	self:SetNWString("StoredAmmoName", self.StoredAmmoName)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(USE_TOGGLE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetBodygroup(1, isnumber(self.MagBodygroupValue) and self.MagBodygroupValue or 1)

	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(5)
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > 0.2 and data.Speed > 120 then
		local selfPos = self:LocalToWorld(self:OBBCenter())
		sound.Play("physics/metal/weapon_impact_hard" .. math.random(3) .. ".wav", selfPos, 75)
	end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end
	if not IsValid(ply) or not ply:IsPlayer() then return end

	if self.StoredAmmo > 0 and self.StoredAmmoType >= 0 then
		ply:GiveAmmo(self.StoredAmmo, self.StoredAmmoType, true)
	end

	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end
