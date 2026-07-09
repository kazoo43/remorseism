if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
local sprayRange = CreateConVar("pepperspray_range", "160", FCVAR_REPLICATED + FCVAR_ARCHIVE, "Effective range of the pepper spray")
SWEP.PrintName = "Pepper Spray"
SWEP.Instructions = "Non-lethal self-defense tool. Causes temporary blindness and irritation."
SWEP.Category = "ZCity"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconOverride = "entities/weapon_pepperspray_tpik.png"
if CLIENT then
    SWEP.WepSelectIcon = Material("entities/weapon_pepperspray_tpik.png")
    SWEP.WepSelectIcon2 = Material("entities/weapon_pepperspray_tpik.png")
end
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ViewModel = "models/weapons/custom/v_pepperspray.mdl"
SWEP.WorldModel = "models/weapons/custom/pepperspray.mdl"
SWEP.WorldModelReal = "models/weapons/custom/v_pepperspray.mdl"
SWEP.WorldModelExchange = false
SWEP.weaponPos = Vector(0, 0, 0)
SWEP.weaponAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(-3.8, -6, 0)
SWEP.HoldAng = Angle(0, 0, 10)
SWEP.HoldType = "slam"
SWEP.modelscale = 1
SWEP.modelscale2 = 1
SWEP.AnimList = {
    ["deploy"] = { "draw", 1, false },
    ["idle"] = { "idle", 5, true },
    ["start_spray"] = { "startsh", 0.5, false },
    ["stop_spray"] = { "stopsh", 0.3, false },
    ["safety_off"] = { "safetyoff", 1, false },
    ["safety_on"] = { "safetyon", 1, false }
}
sound.Add({
    name = "PepperSpray.Loop",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 60,
    pitch = {95, 105},
    sound = "weapons/pepperspray/spray_loop.wav"
})
sound.Add({
    name = "PepperSpray.Shake",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 60,
    pitch = {95, 105},
    sound = "weapons/pepperspray/shake.wav"
})

local function GetSprayTarget(ent)
    if not IsValid(ent) then return nil end
    if ent.organism then return ent end
    if ent:IsPlayer() and IsValid(ent.FakeRagdoll) and ent.FakeRagdoll.organism then
        return ent.FakeRagdoll
    end
end

local function IsFaceHit(ent, hitPos)
    if not IsValid(ent) then return false end

    local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
    if not headBone then return false end

    local bonePos, boneAng = ent:GetBonePosition(headBone)
    if not bonePos or not boneAng then return false end

    local toHit = hitPos - bonePos
    if toHit:LengthSqr() <= 0.01 then return true end

    toHit:Normalize()
    return toHit:Dot(boneAng:Forward()) > 0.1
end

local function GetExposureProfile(owner, ent, tr)
    local dist = owner:GetShootPos():Distance(tr.HitPos)
    local rangeFrac = math.Clamp(1 - (dist / math.max(sprayRange:GetFloat(), 1)), 0.15, 1)
    local isHead = tr.HitGroup == HITGROUP_HEAD
    local isChest = tr.HitGroup == HITGROUP_CHEST or tr.HitGroup == HITGROUP_STOMACH
    local faceHit = isHead and IsFaceHit(ent, tr.HitPos)

    local eyeSeverity = 0
    local airwaySeverity = 0

    if faceHit then
        eyeSeverity = 1.0
        airwaySeverity = 0.8
    elseif isHead then
        eyeSeverity = 0.45
        airwaySeverity = 0.5
    elseif isChest then
        airwaySeverity = 0.35
    end

    if ent:IsPlayer() and owner:GetAimVector():Dot((ent:WorldSpaceCenter() - owner:GetShootPos()):GetNormalized()) > 0.96 then
        airwaySeverity = math.max(airwaySeverity, 0.2)
    end

    return eyeSeverity * rangeFrac, airwaySeverity * rangeFrac, faceHit
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner:KeyDown(IN_ATTACK) then
        self:SetNextPrimaryFire(CurTime() + 0.05)
        self:SetNWBool("IsSpraying", true)
        if not self.IsSpraying then
            self:PlayAnim("start_spray")
            self.IsSpraying = true
        end
        if SERVER then
            local tr = util.TraceLine({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * sprayRange:GetFloat(),
                filter = owner
            })
            local dist = tr.StartPos:Distance(tr.HitPos)
            if tr.Hit then
                local ent = tr.Entity
                local target = GetSprayTarget(ent)
                local org = IsValid(target) and target.organism or nil
                if org then
                    local eyeSeverity, airwaySeverity, faceHit = GetExposureProfile(owner, target, tr)

                    if eyeSeverity > 0 or airwaySeverity > 0 then
                        org.painadd = (org.painadd or 0) + eyeSeverity * 7 + airwaySeverity * 4
                        org.disorientation = math.min((org.disorientation or 0) + eyeSeverity * 1.7 + airwaySeverity * 0.7, 10)
                        org.fearadd = math.min((org.fearadd or 0) + airwaySeverity * 0.4 + eyeSeverity * 0.2, 3)

                        if ent:IsPlayer() then
                            local curExposure = ent:GetNWFloat("PS_Exposure", 0)
                            local curAirway = ent:GetNWFloat("PS_Airway", 0)
                            local curTint = ent:GetNWFloat("PS_LingeringTint", 0)
                            local curPanic = ent:GetNWFloat("PS_Panic", 0)

                            ent:SetNWFloat("PS_Exposure", math.min(curExposure + eyeSeverity * 1.15, 10))
                            ent:SetNWFloat("PS_Airway", math.min(curAirway + airwaySeverity * 1.1, 10))
                            ent:SetNWFloat("PS_Panic", math.min(curPanic + airwaySeverity * 0.5 + eyeSeverity * 0.25, 3))
                            ent:SetNWFloat("PS_LastHitTime", CurTime())
                            ent:SetNWFloat("PS_LingeringTint", math.min(curTint + eyeSeverity * 22 + airwaySeverity * 8 + (faceHit and 8 or 0), 100))
                        end
                    end

                    hg.send_bareinfo(org)
                end
            end
        end
    else
        self:SetNWBool("IsSpraying", false)
    end
end
if CLIENT then
    local emitter = nil
    local offX = CreateClientConVar("pepperspray_offset_x", "17", true, false, "Spray offset Forward")
    local offY = CreateClientConVar("pepperspray_offset_y", "3", true, false, "Spray offset Right")
    local offZ = CreateClientConVar("pepperspray_offset_z", "-6", true, false, "Spray offset Up")
    local sndDelay = CreateClientConVar("pepperspray_sound_delay", "0.04", true, false, "Delay between spray sound loops")
    local function EmitSprayCone(emitterObj, muzzle, dir, aimang)
        local right = aimang:Right()
        local up = aimang:Up()

        for i = 1, 5 do
            local spread = right * math.Rand(-0.035, 0.035) + up * math.Rand(-0.03, 0.03)
            local dropletDir = (dir + spread):GetNormalized()
            local p = emitterObj:Add("effects/splash2", muzzle + dropletDir * math.Rand(0, 3))
            if not p then continue end

            local speed = (i <= 2) and math.Rand(700, 840) or math.Rand(420, 650)
            local air = (i <= 2) and 260 or 340

            p:SetVelocity(dropletDir * speed + Vector(0, 0, math.Rand(-8, 8)))
            p:SetDieTime(math.Rand(0.1, 0.22))
            p:SetStartAlpha(math.Rand(150, 210))
            p:SetEndAlpha(0)
            p:SetStartSize((i <= 2) and math.Rand(1.5, 2.4) or math.Rand(1.0, 1.5))
            p:SetEndSize((i <= 2) and math.Rand(2.8, 4.3) or math.Rand(1.8, 3.0))
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-8, 8))
            p:SetColor(255, math.random(135, 170), 70)
            p:SetAirResistance(air * 0.9)
            p:SetGravity(Vector(0, 0, -150))
            p:SetCollide(true)
            p:SetBounce(0.05)
            p:SetLighting(false)
        end
    end

    local function EmitLingeringMist(emitterObj, pos, dir, strength, nearSurface)
        local count = nearSurface and 3 or 2
        for i = 1, count do
            local p = emitterObj:Add("particle/particle_smokegrenade", pos + VectorRand() * (nearSurface and 3 or 5))
            if not p then continue end

            local drift = dir * math.Rand(18, 45) + VectorRand() * (nearSurface and 10 or 18)
            drift.z = drift.z + (nearSurface and math.Rand(-6, 2) or math.Rand(-2, 10))

            p:SetVelocity(drift)
            p:SetDieTime(math.Rand(1.0, 1.9) * strength)
            p:SetStartAlpha(math.Rand(34, 56))
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(7, 12) * strength)
            p:SetEndSize(math.Rand(16, 28) * strength)
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-6, 6))
            p:SetColor(245, math.random(135, 165), 85)
            p:SetAirResistance(nearSurface and 65 or 38)
            p:SetGravity(Vector(0, 0, nearSurface and -18 or -8))
            p:SetLighting(false)
            p:SetCollide(false)
        end
    end

    hook.Add("Think", "PepperSprayParticles", function()
        for _, swep in ipairs(ents.FindByClass("weapon_pepperspray_tpik")) do
            if swep:GetNWBool("IsSpraying", false) then
                local owner = swep:GetOwner()
                if not IsValid(owner) then continue end
                if not emitter then 
                    emitter = ParticleEmitter(owner:GetPos()) 
                else
                    emitter:SetPos(owner:GetPos())
                end
                local aimang = owner:EyeAngles()
                local muzzle = owner:GetShootPos() 
                             + aimang:Forward() * offX:GetFloat() 
                             + aimang:Right() * offY:GetFloat() 
                             + aimang:Up() * offZ:GetFloat()
                local dir = aimang:Forward()
                swep.NextParticle = swep.NextParticle or 0
                swep.NextMistParticle = swep.NextMistParticle or 0
                if swep.NextParticle < CurTime() then
                    swep.NextParticle = CurTime() + 0.02
                    EmitSprayCone(emitter, muzzle, dir, aimang)
                    EmitSprayCone(emitter, muzzle + dir * 2, dir, aimang)
                    local trImpact = util.TraceLine({
                        start = muzzle,
                        endpos = muzzle + dir * sprayRange:GetFloat(),
                        filter = owner
                    })
                    if trImpact.Hit then
                        for i = 1, 2 do
                            local p = emitter:Add("effects/splash2", trImpact.HitPos + trImpact.HitNormal * 1.5)
                            if p then
                                local slide = trImpact.HitNormal:Angle():Right() * math.Rand(-8, 8) + trImpact.HitNormal:Angle():Up() * math.Rand(-8, 8)
                                p:SetVelocity(trImpact.HitNormal * math.Rand(4, 10) + slide)
                                p:SetDieTime(math.Rand(0.25, 0.45))
                                p:SetStartAlpha(math.Rand(90, 130))
                                p:SetEndAlpha(0)
                                p:SetStartSize(math.Rand(1.8, 3.2))
                                p:SetEndSize(math.Rand(2.5, 4.5))
                                p:SetRoll(math.Rand(0, 360))
                                p:SetRollDelta(math.Rand(-4, 4))
                                p:SetColor(255, math.random(105, 135), 30)
                                p:SetAirResistance(500)
                                p:SetGravity(Vector(0, 0, -220))
                                p:SetCollide(true)
                                p:SetBounce(0)
                                p:SetLighting(false)
                            end
                        end
                    end
                end
                if swep.NextMistParticle < CurTime() then
                    swep.NextMistParticle = CurTime() + 0.05

                    local cloudPos = muzzle + dir * math.Rand(18, 42)
                    EmitLingeringMist(emitter, cloudPos, dir, 1.15, false)

                    local trAir = util.TraceLine({
                        start = muzzle,
                        endpos = muzzle + dir * math.min(sprayRange:GetFloat(), 70),
                        filter = owner
                    })

                    if trAir.Hit then
                        EmitLingeringMist(emitter, trAir.HitPos + trAir.HitNormal * 2, trAir.HitNormal, 1.35, true)
                    else
                        local farCloudPos = muzzle + dir * math.Rand(48, 70)
                        EmitLingeringMist(emitter, farCloudPos, dir, 1.0, false)
                    end
                end
                swep.NextSoundPlayCL = swep.NextSoundPlayCL or 0
                if swep.NextSoundPlayCL < CurTime() then
                    swep:EmitSound("PepperSpray.Loop", 65, 100, 1, CHAN_WEAPON)
                    swep.NextSoundPlayCL = CurTime() + sndDelay:GetFloat()
                end
            end
        end
    end)
end
function SWEP:ThinkAdd()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self.IsSpraying and not owner:KeyDown(IN_ATTACK) then
        self:SetNWBool("IsSpraying", false)
        self:PlayAnim("stop_spray")
        self.IsSpraying = false
    end
end
function SWEP:PreDrawViewModel(vm, wep, ply)
    if IsValid(ply) and (IsValid(ply.FakeRagdoll) or (ply.IsFirstPerson and not ply:IsFirstPerson())) then
        return true
    end
end
function SWEP:OnRemove()
end
function SWEP:SecondaryAttack()
end
function SWEP:Initialize()
    self:SetHold(self.HoldType)
    self:InitAdd()
end
function SWEP:InitAdd()
end

