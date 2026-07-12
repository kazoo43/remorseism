AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(USE_TOGGLE)
	self:DrawShadow(true)
	self:SetModelScale(self.modelscale or 1)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(2)
		phys:Wake()
		phys:EnableMotion(true)
	end
	self.created = CurTime()

	timer.Simple(0, function()
		if not IsValid(self) then return end

		self:SetModelScale(self.modelscale or 1)
	end)

	timer.Simple(0.5,function()
		if not IsValid(self) then return end
		
		self:SetOwner()
	end)
end

local impactSounds = {
	[MAT_CONCRETE] = {"physics/concrete/concrete_impact_hard1.wav", "physics/concrete/concrete_impact_hard2.wav", "physics/concrete/concrete_impact_hard3.wav"},
	[MAT_METAL] = {"physics/metal/metal_sheet_impact_hard2.wav", "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard7.wav"},
	[MAT_WOOD] = {"physics/wood/wood_plank_impact_hard1.wav", "physics/wood/wood_plank_impact_hard2.wav", "physics/wood/wood_plank_impact_hard3.wav"},
	[MAT_DIRT] = {"physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav"},
	[MAT_SAND] = {"physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav"},
	[MAT_FLESH] = {"physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav"},
	[MAT_GLASS] = {"physics/glass/glass_impact_hard1.wav", "physics/glass/glass_impact_hard2.wav", "physics/glass/glass_impact_hard3.wav"},
	[MAT_PLASTIC] = {"physics/plastic/plastic_box_impact_hard1.wav", "physics/plastic/plastic_box_impact_hard5.wav"},
	[MAT_TILE] = {"physics/concrete/concrete_impact_hard1.wav", "physics/concrete/concrete_impact_hard3.wav"},
}

local function StickToWorld(ent, hitPos, hitNormal, hitVel)
	local physObj = ent:GetPhysicsObject()
	if IsValid(physObj) then
		physObj:SetVelocity(vector_origin)
		physObj:SetAngleVelocity(vector_origin)
		physObj:EnableMotion(false)

		if ent.StickPhysics == false then
			physObj:EnableCollisions(false)
		end
	end

	local ang = hitVel:Angle()
	local forward = ang:Forward()
	local tipOffset = ent:OBBMaxs().x

	local tipTarget = hitPos - hitNormal * (ent.StickDepth or 5)
	ent:SetAngles(ang)
	ent:SetPos(tipTarget - forward * tipOffset)

	if ent.StickPhysics == false then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end

	ent.Stuck = true

	ent:EmitSound(ent.AttackHit or "Canister.ImpactHard", 65)

	util.Decal("ManhackCut", hitPos + hitNormal, hitPos - hitNormal)
end

function ENT:Think()
	if not IsValid(self:GetPhysicsObject()) then return end
	if self.Stuck then
		self.Stress = (self.Stress or 0) - FrameTime() * 20
		if self.Stress < 0 then self.Stress = 0 end

		if (self.Stress or 0) > 500 then
			local physObj = self:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:EnableMotion(true)
				physObj:Wake()
			end
			self.Stuck = false
			self.Stress = 0
			self:EmitSound("physics/wood/wood_plank_impact_hard3.wav", 75, math.random(90, 110))
			self:NextThink(CurTime() + 0.1)
			return true
		elseif (self.Stress or 0) > 300 and not self.CreakPlayed then
			self.CreakPlayed = true
			self:EmitSound("physics/wood/wood_plank_impact_hard2.wav", 45, math.random(130, 150))
		elseif (self.Stress or 0) <= 300 then
			self.CreakPlayed = false
		end

		for _, ply in ipairs(player.GetAll()) do
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK) then
				local tr = ply:GetEyeTrace()
				if tr.Entity == self then
					self:EmitSound("physics/wood/wood_plank_impact_hard3.wav", 65, math.random(110, 130))
					local physObj = self:GetPhysicsObject()
					if IsValid(physObj) then
						physObj:EnableMotion(true)
						physObj:Wake()
						physObj:SetVelocity(ply:GetAimVector() * 500)
					end
					self.Stuck = false
					self:NextThink(CurTime() + 0.1)
					return true
				end
			end
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end
	local speed = self:GetPhysicsObject():GetVelocity():LengthSqr()

	if self.constrained then return end
	if self.AeroDrag then
		AeroDrag(self, self:GetAngles():Forward(), 10)
	end
	if not self.StickInWorld then
		self:SetCollisionGroup(speed < 220000 and COLLISION_GROUP_WEAPON or COLLISION_GROUP_NONE)
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.removed then return end

	if self.Stuck then
		local hitEnt = data.HitEntity
		if IsValid(hitEnt) and hitEnt:GetClass() ~= "worldspawn" then
			local hitPhys = hitEnt:GetPhysicsObject()
			local hitMass = IsValid(hitPhys) and hitPhys:GetMass() or 1
			self.Stress = (self.Stress or 0) + data.Speed * hitMass * 0.01
		end
		return
	end

	if self.StickInWorld and data.HitEntity:IsWorld() then
		local stick = self.StickAnywhere or math.abs(data.HitNormal.z) < 0.7
		if stick then
			StickToWorld(self, data.HitPos, data.HitNormal, data.OurOldVelocity)
			return
		end
	end

	local hitMat = data.HitEntity:GetMaterialType()
	local snds = impactSounds[hitMat]
	local speedChance = math.Clamp(data.Speed / 600, 0, 1)
	local playChance = math.Rand(0, 1) < (0.35 + speedChance * 0.65)
	if playChance then
		if snds then
			local vol = math.Clamp(data.Speed / 600, 0.35, 1) * 70
			self:EmitSound(snds[math.random(#snds)], vol, math.random(90, 110))
		elseif data.HitEntity:IsWorld() then
			local vol = math.Clamp(data.Speed / 600, 0.35, 1) * 70
			self:EmitSound("physics/concrete/concrete_impact_hard1.wav", vol, math.random(90, 110))
		end
	end

	if data.Speed < 400 then return end

	-- resolve ragdoll to real player
	local hitEnt = data.HitEntity
	local ragdollOwner = IsValid(hitEnt) and hitEnt:GetNWEntity("ply")
	if not IsValid(ragdollOwner) and hitEnt:GetClass() == "prop_ragdoll" then
		return
	end
	local target = IsValid(ragdollOwner) and ragdollOwner or hitEnt

	-- headshot detection trace
	local headTr = {}
	headTr.start = data.HitPos
	headTr.endpos = data.HitPos + data.OurOldVelocity
	headTr.filter = self
	local headTrace = util.TraceLine(headTr)

	local isHeadshot = target.organism and headTrace.HitGroup == HITGROUP_HEAD

	local speedFraction = math.Clamp(data.Speed / self.MaxSpeed, 0, 1)
	self.Penetration = (self.penetration or 1) * speedFraction
	self.PenetrationSize = self.PenetrationSize or math.max((self.penetration or 1) * 0.5, 1)

	local baseDmg = (self.damage or 20) * math.Clamp((data.Speed / self.MaxSpeed), 0, 1)
	if isHeadshot then
		baseDmg = baseDmg * (self.HeadshotMultiplier or 1.3)
	end

	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(baseDmg)
	dmginfo:SetDamageForce(data.OurOldVelocity)
	dmginfo:SetDamageType(self.DamageType or DMG_SLASH)
	dmginfo:SetDamagePosition(data.HitPos)
	target:TakeDamageInfo(dmginfo)

	if target.organism then
		self:EmitSound(self.AttackHitFlesh, 65)

		if (self.DamageType or DMG_SLASH) == DMG_SLASH then
			util.Decal("Blood", data.HitPos + data.HitNormal * 2, data.HitPos - data.HitNormal * 2, hitEnt)
			util.Decal("Blood", data.HitPos + data.HitNormal * 2, data.HitPos - data.HitNormal * 2)
		elseif (self.DamageType or DMG_SLASH) == DMG_CLUB then
			if hitEnt:IsPlayer() then
				hg.ApplyBruiseTo(hitEnt, hitEnt, data.HitPos, data.HitNormal)
			elseif hitEnt:GetClass() == "prop_ragdoll" then
				local ragOwner = hg.RagdollOwner(hitEnt)
				if IsValid(ragOwner) and ragOwner:IsPlayer() then
					hg.ApplyBruiseTo(hitEnt, ragOwner, data.HitPos, data.HitNormal)
				end
			end
		end
	end

	-- headshot ragdoll trigger
	if isHeadshot and target:IsPlayer() and target:Alive() and not IsValid(target.FakeRagdoll) then
		if math.random() <= 0.55 then
			timer.Simple(0, function()
				if IsValid(target) and target:Alive() and not IsValid(target.FakeRagdoll) then
					hg.Fake(target)
				end
			end)
		end
	end

	local lodgeChance = self.LodgeChance or 0
	if (target.organism) and ((self.DamageType or DMG_SLASH) == DMG_SLASH) and lodgeChance > 0 then
		local speedFraction = math.Clamp((data.Speed - 400) / math.max(self.MaxSpeed - 400, 1), 0, 1)
		local velNorm = data.OurOldVelocity:GetNormalized()
		local hitDot = math.abs(velNorm:Dot(data.HitNormal))
		local finalChance = lodgeChance * speedFraction * hitDot

		if math.Rand(0, 1) <= finalChance then
			local tr = util.TraceLine({
				start = data.HitPos,
				endpos = data.HitPos + data.OurOldVelocity,
				filter = self,
			})
			local bone = tr.PhysicsBone
			local mat = hitEnt:GetBoneMatrix(hitEnt:TranslatePhysBoneToBone(bone))

			local stickAng = data.OurOldVelocity:Angle()
			local lpos, lang = WorldToLocal(tr.HitPos, stickAng, mat:GetTranslation(), mat:GetAngles())

			local org = target.organism
			org.LodgedEntities = org.LodgedEntities or {}
			org.LodgedEntities[#org.LodgedEntities + 1] = {
				PhysBoneID = bone,
				OffsetPos = lpos,
				OffsetAng = lang,
				model = self:GetModel(),
				takeent = self.wep,
			}

			net.Start("organism_send")

			local tbl = {}
			tbl.LodgedEntities = org.LodgedEntities
			tbl.owner = org.owner
		
			net.WriteTable(tbl)
			net.WriteBool(true)
			net.WriteBool(false)
			net.WriteBool(false)
			net.WriteBool(true)
			net.Broadcast()

			self:Remove()
			self.removed = true
		end
	end
end

function ENT:Use(ply)
	if self.created + 0.5 > CurTime() then return end
	if self.removed then return end
	if IsValid(ply.FakeRagdoll) then return end
	if self.wep then
		self.removed = true

		if self.Stuck then
			self:EmitSound(self.UnstickSnd or "physics/wood/wood_plank_impact_hard3.wav", 65, math.random(110, 130))
		end

		local wep = ents.Create(self.wep)
		wep:Spawn()
		wep:SetPos(self:GetPos())
		wep:SetAngles(self:GetAngles())
		wep.poisoned2 = self.poisoned2

		if not hook.Run("PlayerCanPickupWeapon",ply,wep) then wep.IsSpawned = true wep.init = true wep:Remove() self:Remove() return end

		if constraint.FindConstraint( self, "Weld" ) then
			local tbl = constraint.FindConstraint( self, "Weld" )
			if tbl.Ent2:IsPlayer() or tbl.Ent2:IsRagdoll() then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.returndamage or 10)
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetDamageType(DMG_SLASH)
				self.PainMultiplier = 0.5
				tbl.Ent2:TakeDamageInfo(dmginfo)
				hg.organism.AddWoundManual(tbl.Ent2,self.returnblood or 10,vector_origin,angle_zero,tbl["Bone2"] or 0,CurTime())
			end
		end

		self:Remove()
		ply:PickupWeapon(wep)
	end
end