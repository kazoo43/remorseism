AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("flashbang")

function ENT:InitAdd()
    self:Activate()
end

local burnDamageRadius = 20
local explosionDamageRadius = 30
local disorientationRadius = 300
local flashTimeMin = 1
local flashTimeMax = 5
local flashTimeDistance = 5200
function ENT:Explode()
    if self:PoopBomb() then
        self:EmitSound("weapons/p99/slideback.wav", 75)
        self.Exploded = true
        return
    end
    local SelfPos = self:GetPos()

    local effectdata = EffectData()
    effectdata:SetOrigin(SelfPos)
    effectdata:SetScale(0.5)
    effectdata:SetNormal(-self:GetAngles():Forward())
    util.Effect("eff_jack_genericboom", effectdata)
    hg.EmitAISound(SelfPos, 512, 16, 1)


    --[[net.Start("projectileFarSound")
        net.WriteString(self.SoundMain)
        net.WriteString(self.SoundFar)
        net.WriteVector(SelfPos)
        net.WriteEntity(self)
        net.WriteBool(self:WaterLevel() > 0)
        net.WriteString("")
    net.Broadcast()--]]

    --self:EmitSound(self.SoundMain, 100, 100, 1, CHAN_WEAPON)
    --self:EmitSound(self.SoundFar, 140, 100, 1, CHAN_WEAPON)

    timer.Simple(0.05, function()
        if IsValid(self) then
            self:EmitSound(table.Random(self.SoundBass), 150, 70, 0.95, CHAN_AUTO)
        end
    end)

    timer.Simple(0.1, function()
        if IsValid(self) then
            self:EmitSound(table.Random(self.SoundBass), 155, 60, 0.9, CHAN_BODY)
        end
    end)

    EmitSound(self.SoundMain, SelfPos, self:EntIndex() + 100, CHAN_STATIC, 1, 70, nil, 100)
    EmitSound(self.SoundMain, SelfPos, self:EntIndex() + 101, CHAN_STATIC, 1, 70, nil, 100)
    EmitSound(self.SoundMain, SelfPos, self:EntIndex() + 102, CHAN_STATIC, 1, 70, nil, 100)
    EmitSound(self.SoundFar, SelfPos, self:EntIndex() + 103, CHAN_STATIC, 1, 140, nil, 100)

    EmitSound("snd_jack_fireworkpop5.wav", SelfPos, self:EntIndex() + 200, CHAN_VOICE, 1, 150, nil, math.random(100, 110))

    --util.BlastDamage(self, self.owner, SelfPos, self.BlastDis / 0.01905, 5)

    for _, ply in ipairs(ents.FindInSphere(SelfPos, 700)) do
        if not ply:IsPlayer() or not ply:Alive() then continue end

        if hg.isVisible(ply:GetShootPos(), SelfPos, {ply, self}, MASK_VISIBLE) then
            local flashTime = math.Clamp(flashTimeDistance - ply:GetPos():Distance(SelfPos), flashTimeMin, flashTimeMax)
            net.Start("flashbang")
                net.WriteVector(SelfPos)
                net.WriteFloat(flashTime)
            net.Send(ply)
            hg.Fake(ply, nil, true)
            ply.organism.flashbangHoldEnd = CurTime() + flashTime
            ply.organism.lightstun = ply.organism.flashbangHoldEnd
            ply:SetLocalVar("stun", ply.organism.lightstun)
            ply.fakecd = ply.organism.flashbangHoldEnd
            ply.organism.wounds = ply.organism.wounds or {}
            ply.organism.flashbangWound = {25, vector_origin, angle_zero, "ValveBiped.Bip01_Head1", ply.organism.flashbangHoldEnd}
            table.insert(ply.organism.wounds, ply.organism.flashbangWound)
            local flashHookName = "FlashbangHeadHold_" .. ply:EntIndex()
            hook.Remove("Think", flashHookName)
            hook.Add("Think", flashHookName, function()
                if not IsValid(ply) or not ply:Alive() or not ply.organism or CurTime() > (ply.organism.flashbangHoldEnd or 0) then
                    hook.Remove("Think", flashHookName)
                    if IsValid(ply) and ply.organism and ply.organism.wounds and ply.organism.flashbangWound then
                        for i, w in ipairs(ply.organism.wounds) do
                            if w == ply.organism.flashbangWound then
                                table.remove(ply.organism.wounds, i)
                                break
                            end
                        end
                        ply.organism.flashbangWound = nil
                    end
                    return
                end
                local ragdoll = ply.FakeRagdoll
                if not IsValid(ragdoll) then return end
                local resolvePhys = hg.realPhysNum or function(_, n) return n end
                local head = ragdoll:GetPhysicsObjectNum(resolvePhys(ragdoll, 10))
                local lhand = ragdoll:GetPhysicsObjectNum(resolvePhys(ragdoll, 5))
                local rhand = ragdoll:GetPhysicsObjectNum(resolvePhys(ragdoll, 7))
                local spine = ragdoll:GetPhysicsObjectNum(resolvePhys(ragdoll, 1))
                if not IsValid(head) or not IsValid(spine) then return end
                local hPos = head:GetPos()
                local sPos = spine:GetPos()
                local sAng = spine:GetAngles()
                hg.ShadowControl(ragdoll, 10, 0.4, Angle(sAng.p + 50, sAng.y, 0), 15, 8)
                if IsValid(lhand) then
                    hg.ShadowControl(ragdoll, 3, 0.001, nil, nil, nil, sPos + sAng:Right() * -10, 25, 10)
                    hg.ShadowControl(ragdoll, 5, 0.001, nil, nil, nil, hPos - (hPos - lhand:GetPos()):GetNormalized() * 2, 100, 10)
                end
                if IsValid(rhand) then
                    hg.ShadowControl(ragdoll, 2, 0.001, nil, nil, nil, sPos + sAng:Right() * 10, 25, 10)
                    hg.ShadowControl(ragdoll, 7, 0.001, nil, nil, nil, hPos - (hPos - rhand:GetPos()):GetNormalized() * 2, 100, 10)
                end
            end)
        end

        local tr = hg.ExplosionTrace(SelfPos, ply:GetPos(), {self, ply})

        if tr.Hit then continue end

        local distance = ply:GetPos():Distance(SelfPos)
        local org = ply.organism

        if distance <= burnDamageRadius then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(50)
            dmginfo:SetDamageType(DMG_BURN)


            if IsValid(self.Owner) then
                dmginfo:SetAttacker(self.Owner)
            else
                dmginfo:SetAttacker(self)
            end

            ply:TakeDamageInfo(dmginfo)
        end

        if distance <= explosionDamageRadius then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(75)
            dmginfo:SetDamageType(DMG_BLAST)

            if IsValid(self.Owner) then
                dmginfo:SetAttacker(self.Owner)
            else
                dmginfo:SetAttacker(self)
            end

            ply:TakeDamageInfo(dmginfo)
        end

        if distance <= disorientationRadius then
            if org then
                hg.ExplosionDisorientation(org.owner, 5, 6)
				hg.RunZManipAnim(org.owner, "shieldexplosion")
                //org.owner:ViewPunch(Angle(0, 0, org.owner:GetAimVector():Dot((SelfPos - org.owner:EyePos()):GetNormalized()) * 55))
            end
        end
    end

    self:Remove()
end