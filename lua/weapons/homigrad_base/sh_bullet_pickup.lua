AddCSLuaFile()

-- Bullet Pickup System
-- Allows players to pick up bullets from the ground instead of just casings

if SERVER then
	util.AddNetworkString("hg_bullet_pickup")
	util.AddNetworkString("hg_bullet_pickup_effect")
	
	hg.Bullets = hg.Bullets or {}
	
	-- Create bullet entity that can be picked up
	function SWEP:CreateBulletPickup(shellType, pos, ang, vel)
		if not shellType or not pos then return end
		
		local bullet = ents.Create("prop_physics")
		if not IsValid(bullet) then return end
		
		-- Use bullet models instead of shell models
		local bulletModels = {
			["9x19"] = "models/items/boxsrounds.mdl",
			["45acp"] = "models/items/boxsrounds.mdl", 
			["556x45"] = "models/items/boxsrounds.mdl",
			["762x39"] = "models/items/boxsrounds.mdl",
			["762x51"] = "models/items/boxsrounds.mdl",
			["12x70"] = "models/items/boxbuckshot.mdl",
			["50ae"] = "models/items/boxsrounds.mdl"
		}
		
		local ammoType = self.Primary.Ammo
		local model = bulletModels[ammoType] or "models/items/boxsrounds.mdl"
		
		bullet:SetModel(model)
		bullet:SetPos(pos)
		bullet:SetAngles(ang)
		bullet:Spawn()
		
		local phys = bullet:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(0.5) -- Light weight
			phys:SetVelocity(vel or Vector(0, 0, -50))
			phys:SetMaterial("gmod_ice")
		end
		
		-- Store ammo type and amount
		bullet.AmmoType = ammoType
		bullet.AmmoAmount = math.random(3, 8) -- Random amount of bullets
		bullet:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		bullet:SetUseType(SIMPLE_USE)
		
		-- Add to bullet tracking
		table.insert(hg.Bullets, bullet)
		
		-- Auto-remove after 60 seconds
		timer.Simple(60, function()
			if IsValid(bullet) then
				bullet:Remove()
				table.RemoveByValue(hg.Bullets, bullet)
			end
		end)
		
		return bullet
	end
	
	-- Handle bullet pickup
	hook.Add("PlayerUse", "HG_BulletPickup", function(ply, ent)
		if not IsValid(ent) or not ent.AmmoType then return end
		
		-- Check if entity is a bullet
		local isBullet = false
		for _, bullet in ipairs(hg.Bullets or {}) do
			if bullet == ent then
				isBullet = true
				break
			end
		end
		
		if not isBullet then return end
		
		-- Give ammo to player
		local ammoType = ent.AmmoType
		local ammoAmount = ent.AmmoAmount or 5
		
		if ply:GetAmmoCount(ammoType) < 999 then
			ply:GiveAmmo(ammoAmount, ammoType)
			
			-- Play pickup sound
			ent:EmitSound("items/ammo_pickup.wav", 75, 100, 1)
			
			-- Send effect to clients
			net.Start("hg_bullet_pickup_effect")
				net.WriteEntity(ent)
				net.WriteVector(ent:GetPos())
			net.Broadcast()
			
			-- Remove bullet entity
			ent:Remove()
			table.RemoveByValue(hg.Bullets, ent)
			
			-- Notify player
			ply:Notify("Picked up " .. ammoAmount .. " " .. ammoType, 3)
		else
			ply:Notify("Ammo full", 3)
		end
	end)
	
	-- Cleanup bullets on map reset
	hook.Add("PostCleanupMap", "CleanupBullets", function()
		for _, bullet in ipairs(hg.Bullets or {}) do
			if IsValid(bullet) then
				bullet:Remove()
			end
		end
		hg.Bullets = {}
	end)
	
else
	-- Client-side effects for bullet pickup
	net.Receive("hg_bullet_pickup_effect", function()
		local ent = net.ReadEntity()
		local pos = net.ReadVector()
		
		if not IsValid(ent) or not pos then return end
		
		-- Create pickup effect
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetEntity(ent)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		util.Effect("cball_explode", effectdata)
		
		-- Play pickup sound locally
		LocalPlayer():EmitSound("items/ammo_pickup.wav", 75, 100, 1)
	end)
end

-- Override shell creation to create bullets instead
local originalMakeShell = SWEP.MakeShell
function SWEP:MakeBullet(shell, pos, ang, vel)
	-- Create bullet pickup entity instead of shell
	local chance = math.random(1, 3) -- 33% chance to create pickupable bullet
	
	if chance == 1 then
		self:CreateBulletPickup(shell, pos, ang, vel)
	else
		-- Create normal shell
		if originalMakeShell then
			originalMakeShell(self, shell, pos, ang, vel)
		end
	end
end
