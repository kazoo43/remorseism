if SERVER then AddCSLuaFile() end
ENT.Base        = "projectile_base"
ENT.Author      = "Sadsalat"
ENT.Category    = "ZCity Other"
ENT.PrintName   = "GL Grenade"
ENT.Spawnable   = false
ENT.AdminOnly   = true

ENT.Model       = "models/weapons/EFTNades/darsu_eft/40x46_m406.mdl"
ENT.Sound = "m67/m67_detonate_01.wav"
ENT.SoundFar = "m67/m67_detonate_far_dist_01.wav"
ENT.SoundWater = "m67/water/m67_water_detonate_01.wav"

ENT.Speed        = 76 
ENT.TruhstTime   = 0
ENT.BlastDamage  = 199
ENT.BlastDis     = 7
ENT.Fragmentation = 10
ENT.BlastDis = 7
ENT.SafetyDistance = 7


if SERVER then
 
    util.PrecacheSound(ENT.Sound)
    util.PrecacheSound(ENT.SoundFar)
    util.PrecacheSound(ENT.SoundWater)
 
    function ENT:Initialize()
        self.BaseClass.Initialize(self)
 
        if self.snd then
            self:StopLoopingSound(self.snd)
            self.snd = nil
        end
 
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(0.45)
            phys:EnableGravity(true)
            phys:SetDamping(0, 0)
            phys:Wake()
        end
 
        self.StartPos    = self:GetPos()
        self.SafetyArmed = false

    end
 

    function ENT:CheckSafetyDistance()
        if not self.StartPos then
            self.StartPos = self:GetPos()
            return false
        end
 
        local dist = self:GetPos():Distance(self.StartPos)
 
        if dist >= (self.SafetyDistance / 0.01905) and not self.SafetyArmed then
            self.SafetyArmed = true
            self:EmitSound("buttons/button16.wav", 50, 150, 0.3)
        end
 
        return self.SafetyArmed
    end
 
    local function IsSoftSurface(trace)
        local surfName = util.GetSurfacePropName(trace.SurfaceProps or 0):lower()
        return surfName:find("dirt")   or
               surfName:find("mud")    or
               surfName:find("grass")  or
               surfName:find("sand")   or
               surfName:find("gravel") or
               surfName:find("snow")   or
               surfName:find("flesh")  or
               surfName:find("foliage")
    end
 

    function ENT:AboutToHit2(trace)
        return true
    end
 

    function ENT:PhysicsCollide2(data, physobj)
        if self.Exploded then return true end
 
        local hitPos    = data.HitPos
        local hitNormal = data.HitNormal
        local hitEntity = data.HitEntity
 
        local tr = util.TraceHull({
            start  = self:GetPos(),
            endpos = hitPos,
            mins   = Vector(-2, -2, -2),
            maxs   = Vector(2, 2, 2),
            filter = self
        })
 
        local trace = {
            Hit          = tr.Hit,
            HitPos       = tr.HitPos     or hitPos,
            HitNormal    = tr.HitNormal  or hitNormal,
            Entity       = tr.Entity     or hitEntity,
            MatType      = tr.MatType    or 0,
            HitTexture   = tr.HitTexture or "unknown",
            SurfaceProps = tr.SurfaceProps or 0
        }
 
        local armed = self:CheckSafetyDistance()
 
        if IsSoftSurface(trace) then
            if IsValid(physobj) then
                physobj:EnableMotion(false)
                physobj:Sleep()
                physobj:SetVelocity(Vector(0, 0, 0))
                physobj:SetAngleVelocity(Vector(0, 0, 0))
            end
            self:SetMoveType(MOVETYPE_NONE)
 
            if armed then
                timer.Simple(0.08, function()
                    if IsValid(self) and not self.Exploded then
                        self:Detonate()
                    end
                end)
            end
        else
            if armed then
                self:Detonate()
            end
        end
 
        return true
    end
 
    function ENT:Think()
        if self.Removed then return end
 
        if not self.SafetyArmed then
            self:CheckSafetyDistance()
        end

        if self.DetonateTime and CurTime() >= self.DetonateTime then
            if not self.Exploded then
                self:Detonate()
            end
            return
        end
 
        self:NextThink(CurTime())
        return true
    end
 
    -- ----------------------------------------------------------------
    --  Звук взрыва: рассылаем по сети, база не играет свой
    -- ----------------------------------------------------------------
    util.AddNetworkString("gl_grenade_explosion_sound")
 
    function ENT:PlayDistantExplosionSounds()
        net.Start("gl_grenade_explosion_sound")
            net.WriteVector(self:GetPos())
            net.WriteString(self.Sound)
            net.WriteString(self.SoundFar)
            net.WriteBool(self:WaterLevel() > 0)
            net.WriteString(self.SoundWater)
        net.Broadcast()
    end
 
    function ENT:Detonate()
        self:PlayDistantExplosionSounds()
        self.NoExplosionSound = true   -- говорим базе не играть свой звук
        self.BaseClass.Detonate(self)
    end
 
end -- SERVER
 
-- ============================================================
if CLIENT then
 
    function ENT:Draw()
        self:DrawModel()
    end
 
    net.Receive("gl_grenade_explosion_sound", function()
        local pos      = net.ReadVector()
        local sndClose = net.ReadString()
        local sndFar   = net.ReadString()
        local inWater  = net.ReadBool()
        local sndWater = net.ReadString()
 
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
 
        local dist = ply:GetPos():Distance(pos)
        local time = dist / 17836   -- скорость звука в юнитах/сек
 
        -- Определяем снаружи или в помещении
        local tr = util.TraceLine({
            start  = pos,
            endpos = pos + Vector(0, 0, 2000),
            mask   = MASK_SOLID_BRUSHONLY
        })
        local bOutdoor       = tr.HitSky or not tr.Hit
        local roomMultiplier = bOutdoor and 1.0 or 0.7
 
        if inWater then
            -- Под водой: приглушённый подводный звук с задержкой
            timer.Simple(time, function()
                EmitSound(sndWater, pos, 0, CHAN_AUTO, 1, 130 * roomMultiplier, 0, 85, SOUND_LEVEL_GUNFIRE)
            end)
        elseif dist <= 1500 then
            -- Вблизи: сразу ближний звук без задержки
            EmitSound(sndClose, pos, 0, CHAN_AUTO, 1, 120 * roomMultiplier, 0, 100, SOUND_LEVEL_GUNFIRE)
        else
            -- Вдали: задержка по расстоянию + дальний звук
            timer.Simple(time, function()
                if not IsValid(LocalPlayer()) then return end
 
                local baseVolume = math.Clamp(150 - (dist / 100), 60, 150) * roomMultiplier
                local farPitch   = math.Clamp(100 - (dist / 1000), 70, 95)
 
                EmitSound(sndFar, pos, 0, CHAN_STATIC, 1, baseVolume, 0, farPitch, SOUND_LEVEL_GUNFIRE)
 
                -- Эхо при очень большой дистанции
                if dist > 3000 then
                    timer.Simple(0.5, function()
                        EmitSound(sndFar, pos, 1, CHAN_STATIC, 1, baseVolume * 0.6, 0, farPitch - 15, SOUND_LEVEL_GUNFIRE)
                    end)
                end
            end)
        end
    end)
 
end -- CLIENT