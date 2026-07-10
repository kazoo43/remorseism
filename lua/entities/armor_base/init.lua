AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local vecZero, vec30 = Vector(0,0,0), Vector(0,0,30)
function ENT:Initialize()
	self:SetModel(self.PhysModel or self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self:SetPos(self:GetPos() + vec30)

	if self.material and !istable(self.material) then
		self.mat = self.material
		self:SetSubMaterial(0,self.material)
	end

	if self.material and istable(self.material) then
		self.mat = table.Random(self.material)
		self:SetSubMaterial(0,self.mat)
	end

	if self.skins then
		self.skin = self.skins[math.random(#self.skins)]
		self:SetSkin(self.skin)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmgInfo)
	if self.broken or self:GetNWBool("ArmorBroken", false) then return end
	if not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end

	self.shotsLeft = self.shotsLeft or hg.GetArmorBreakShotCount(self.name)
	self.shotsLeft = self.shotsLeft - 1

	if self.shotsLeft > 0 then return end

	hg.SetArmorBrokenEntity(self)
	hg.PlayArmorBreakSound(self)
end

function ENT:Use(activator)
	self:TakeByPlayer(activator)
end

function ENT:TakeByPlayer(activator)
	if not activator:IsPlayer() then return end
	if self.broken or self:GetNWBool("ArmorBroken", false) then
		activator:Notify("This armor is broken.", true, "armor_broken_pickup", 3)
		return
	end

	local can = hg.AddArmor(activator,self.name, self)
    if can then
		if self.zablevano then
			activator:SetNetVar("zableval_masku", true)
		end

		self:EmitSound("snd_jack_hmcd_disguise.wav", 75, math.random(90,110), 1, CHAN_ITEM)
        self:Remove()
	end
end

function ENT:ApplyData(ply,equipment)
	ply:SetNWString("ArmorMaterials" .. equipment, self.mat)
	ply:SetNWInt("ArmorSkins" .. equipment, self.skin or 0)
	ply.armors_shots = ply.armors_shots or {}
	ply.armors_broken = ply.armors_broken or {}
	ply.armors_broken_mul = ply.armors_broken_mul or {}
	ply.armors_broken[equipment] = self.broken or self:GetNWBool("ArmorBroken", false) or nil
	ply.armors_broken_mul[equipment] = self.brokenProtectionMul or nil
	ply.armors_shots[equipment] = ply.armors_broken[equipment] and nil or self.shotsLeft or hg.GetArmorBreakShotCount(equipment)
end

function ENT:ReciveData(ply,equipment)
	--print(ply,equipment, ply:GetNWString("ArmorMaterials" .. equipment, self.mat))
	self.mat = ply:GetNWString("ArmorMaterials" .. equipment, self.mat)
	self:SetSubMaterial(0,self.mat)

	self.skin = ply:GetNWInt("ArmorSkins" .. equipment, self.skin or 0)
	self:SetSkin(self.skin)
	self.shotsLeft = ply.armors_shots and ply.armors_shots[equipment] or self.shotsLeft
	self.brokenProtectionMul = ply.armors_broken_mul and ply.armors_broken_mul[equipment] or self.brokenProtectionMul
	if ply.armors_broken and ply.armors_broken[equipment] then
		hg.SetArmorBrokenEntity(self)
		self.shotsLeft = nil
	end
end

hook.Add("ItemsTransfered","TransferMats",function(ply, ragdoll)
	local armors = ply:GetNetVar("Armor",{})
	ragdoll.armors = ply.armors
	ragdoll.armors_shots = ragdoll.armors_shots or {}
	ragdoll.armors_health = ply.armors_health
	ragdoll.armors_broken = ply.armors_broken
	ragdoll.armors_broken_mul = ply.armors_broken_mul
	for k,v in pairs(armors) do
		ragdoll:SetNWString("ArmorMaterials" .. v, ply:GetNWString("ArmorMaterials" .. v))
		ply:SetNWString("ArmorMaterials" .. v, nil)

		ragdoll:SetNWInt("ArmorSkins" .. v, ply:GetNWInt("ArmorSkins" .. v))
		ply:SetNWInt("ArmorSkins" .. v, nil)
		ragdoll.armors_shots[v] = ply.armors_shots and ply.armors_shots[v] or nil
	end

	local fakeRag = ply:GetNWEntity("FakeRagdoll", NULL)
	if IsValid(fakeRag) and fakeRag ~= ragdoll then
		fakeRag.armors = ragdoll.armors
		fakeRag.armors_shots = ragdoll.armors_shots
		fakeRag.armors_health = ragdoll.armors_health
		fakeRag.armors_broken = ragdoll.armors_broken
		fakeRag.armors_broken_mul = ragdoll.armors_broken_mul
		fakeRag:SetNetVar("Armor", ragdoll:GetNetVar("Armor", {}))
		fakeRag:SetNetVar("HideArmorRender", ply:GetNetVar("HideArmorRender", false))
	end
end)

hook.Add("ItemTransfer", "TransferMats", function(ply, ent, placement, armor)
	ply:SetNWString("ArmorMaterials" .. armor, ent:GetNWString("ArmorMaterials" .. armor))
	ent:SetNWString("ArmorMaterials" .. armor, nil)

	ply:SetNWInt("ArmorSkins" .. armor, ent:GetNWInt("ArmorSkins" .. armor))
	ent:SetNWInt("ArmorSkins" .. armor, nil)
	ply.armors_shots = ply.armors_shots or {}
	ply.armors_shots[armor] = ent.armors_shots and ent.armors_shots[armor] or ply.armors_shots[armor]
	ply.armors_broken = ply.armors_broken or {}
	ply.armors_broken_mul = ply.armors_broken_mul or {}
	ply.armors_broken[armor] = ent.armors_broken and ent.armors_broken[armor] or ply.armors_broken[armor]
	ply.armors_broken_mul[armor] = ent.armors_broken_mul and ent.armors_broken_mul[armor] or ply.armors_broken_mul[armor]
end)
