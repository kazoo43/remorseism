if SERVER then AddCSLuaFile() end
ENT.Base = "ent_hg_grenade"
ENT.Spawnable = false
ENT.Model = "models/weapons/eftnades/darsu_eft/w_rgo.mdl"
ENT.timeToBoom = 999
ENT.Fragmentation = 85 * 3
ENT.BlastDis = 7 --meters
ENT.Penetration = 7.5

ENT.playedSound = false

function ENT:PhysicsCollide(data, phys)
    self.BaseClass.PhysicsCollide(self, data, phys)

    if data.Speed > 100 then
        self:EmitSound("weapons/darsu_eft/grenades/grenade_collision_concrete1.ogg", 75, math.random(95, 110), 1)
    end

    if SERVER and data.Speed > 100 and not self.Exploded then
        timer.Simple(0.3, function()
            if IsValid(self) and not self.Exploded then
                self:Explode()
            end
        end)
    end
end

function ENT:AddThink()
	if not self.timer or not self.timeToBoom or self.playedSound then return end
	--if (CurTime() - self.timer) <= 0.25 then
		//self:EmitSound("m9/m9_fp.wav", 80)
		self.playedSound = true
	--end
end