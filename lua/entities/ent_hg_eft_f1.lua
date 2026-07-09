if SERVER then AddCSLuaFile() end
ENT.Base = "ent_hg_grenade"
ENT.Spawnable = false
ENT.Model = "models/weapons/eftnades/darsu_eft/w_f1.mdl"
ENT.timeToBoom = 3.5
ENT.Fragmentation = 90 * 3
ENT.BlastDis = 7 --meters
ENT.Penetration = 7.5

ENT.playedSound = false

function ENT:PhysicsCollide(data, phys)
    self.BaseClass.PhysicsCollide(self, data, phys)
	if data.Speed > 100 then
        self:EmitSound("weapons/darsu_eft/grenades/grenade_collision_concrete1.ogg", 75, math.random(95, 110), 1)
	end
end

function ENT:AddThink()
	if not self.timer or not self.timeToBoom or self.playedSound then return end
	--if (CurTime() - self.timer) <= 0.25 then
		//self:EmitSound("m9/m9_fp.wav", 80)
		self.playedSound = true
	--end
end