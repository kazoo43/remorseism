--
local PLAYER = FindMetaTable("Player")

local vpang = Angle(2, -1, 1)
local LEG_KICK_DAMAGE_MUL = 0.85
local LEG_KICK_RAG_FORCE_MUL = 650
local LEG_KICK_PROP_FORCE_MUL = 90
local LEG_KICK_PLAYER_PUSH = 85
local LEG_KICK_FAKE_CHANCE = 0.65
local LEG_KICK_TRACE_RANGE = 28
local LEG_KICK_TRACE_SIZE = Vector(5, 5, 5)
local LEG_KICK_SEGMENT_SIZE = Vector(6, 6, 6)
local CURBSTOMP_DAMAGE_MUL = 1
local CURBSTOMP_RAG_FORCE_MUL = 120
local CURBSTOMP_PROP_FORCE_MUL = 20
local CURBSTOMP_PLAYER_PUSH = 12
local CURBSTOMP_FAKE_CHANCE = 0.15
local CURBSTOMP_TRACE_RANGE = 24
local CURBSTOMP_TRACE_SIZE = Vector(6, 6, 6)
local CURBSTOMP_SEGMENT_SIZE = Vector(7, 7, 7)
local CURBSTOMP_HEAD_RADIUS = 16
local CURBSTOMP_HEAD_STOMPS_TO_POP = 7
local CURBSTOMP_HEAD_RESET = 8

local function getBoneWorld(ent, boneName)
    if not IsValid(ent) then return end
    local bone = ent:LookupBone(boneName)
    if not bone then return end

    local matrix = ent:GetBoneMatrix(bone)
    if matrix then
        return matrix:GetTranslation(), matrix:GetAngles(), bone
    end

    local pos, ang = ent:GetBonePosition(bone)
    if pos and not pos:IsEqualTol(ent:GetPos(), 0.01) then
        return pos, ang, bone
    end

    return nil, nil, bone
end

local function getHeadPos(ent)
    local pos = getBoneWorld(ent, "ValveBiped.Bip01_Head1")
    if pos then return pos end
    return ent:LocalToWorld(ent:OBBCenter() + Vector(0, 0, ent:OBBMaxs().z * 0.75))
end

local function getHeadBone(ent)
    if not IsValid(ent) then return end
    return ent:LookupBone("ValveBiped.Bip01_Head1")
end

local function getHeadPhysBone(ent)
    local bone = getHeadBone(ent)
    if not bone then return end
    local physBone = ent:TranslateBoneToPhysBone(bone)
    if isnumber(physBone) and physBone >= 0 then
        return physBone
    end
end

local function traceLegSegment(self, startPos, endPos, size)
    local tr = util.TraceHull({
        start = startPos,
        endpos = endPos,
        filter = {hg.GetCurrentCharacter(self), self},
        maxs = size,
        mins = -size
    })

    return tr
end

local function getStompHeadCandidate(self, footPos)
    local bestEnt
    local bestHeadPos
    local bestDist = math.huge

    for _, ent in ipairs(ents.FindInSphere(footPos, CURBSTOMP_HEAD_RADIUS * 1.5)) do
        if not IsValid(ent) or ent == self or ent == hg.GetCurrentCharacter(self) then continue end
        if not (ent:IsPlayer() or ent:IsNPC() or ent:GetClass() == "prop_ragdoll") then continue end

        local headPos = getHeadPos(ent)
        if not headPos then continue end

        local dist = footPos:DistToSqr(headPos)
        if dist > CURBSTOMP_HEAD_RADIUS * CURBSTOMP_HEAD_RADIUS then continue end

        if dist < bestDist then
            bestDist = dist
            bestEnt = ent
            bestHeadPos = headPos
        end
    end

    if not IsValid(bestEnt) then return end

    return {
        Hit = true,
        Entity = bestEnt,
        HitPos = bestHeadPos,
        PhysicsBone = getHeadPhysBone(bestEnt) or 0
    }
end

local function getKickTrace(self, inDuck, isCurbstomp)
    local eyeAng = self:EyeAngles()
    local forward = eyeAng:Forward()
    local up = self:GetUp()
    local thighPos = getBoneWorld(self, "ValveBiped.Bip01_R_Thigh")
    local footPos = getBoneWorld(self, "ValveBiped.Bip01_R_Foot")
    local calfPos = getBoneWorld(self, "ValveBiped.Bip01_R_Calf")
    local size = isCurbstomp and CURBSTOMP_TRACE_SIZE or LEG_KICK_TRACE_SIZE
    local segmentSize = isCurbstomp and CURBSTOMP_SEGMENT_SIZE or LEG_KICK_SEGMENT_SIZE
    local fallbackPos = self:GetPos() + self:OBBCenter() + up * -5

    thighPos = thighPos or fallbackPos + up * 14
    calfPos = calfPos or fallbackPos + up * 3
    footPos = footPos or ((inDuck and fallbackPos) or self:EyePos())

    local kickDir
    if isCurbstomp then
        kickDir = (forward * 0.2 - up):GetNormalized()
    else
        kickDir = (forward + up * 0.12):GetNormalized()
    end

    local traces = {
        traceLegSegment(self, thighPos, calfPos, segmentSize),
        traceLegSegment(self, calfPos, footPos, segmentSize),
        traceLegSegment(self, footPos, footPos + kickDir * (isCurbstomp and CURBSTOMP_TRACE_RANGE or LEG_KICK_TRACE_RANGE), size)
    }

    for _, tr in ipairs(traces) do
        if tr.Hit and IsValid(tr.Entity) then
            return tr, kickDir, footPos
        end
    end

    if isCurbstomp then
        local headTr = getStompHeadCandidate(self, footPos)
        if headTr then
            return headTr, kickDir, footPos
        end
    end

    return traces[#traces], kickDir, footPos
end

local function getHeadCounterTarget(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return ent end
    if ent.IsRagdoll and ent:IsRagdoll() then
        local owner = hg.RagdollOwner(ent)
        if IsValid(owner) then return owner end
    end
    return ent
end

local function canExplodeHead(ent)
    if not IsValid(ent) then return false end
    if ent.headexploded or ent.noHead then return false end
    if ent.organism and (ent.organism.noHead or ent.organism.headamputated) then return false end
    return ent:LookupBone("ValveBiped.Bip01_Head1") ~= nil
end

local function handleCurbstompHead(ent, hitPos)
    if not canExplodeHead(ent) then return end

    local headPos = getHeadPos(ent)
    if not headPos or headPos:DistToSqr(hitPos) > CURBSTOMP_HEAD_RADIUS * CURBSTOMP_HEAD_RADIUS then return end

    local counterEnt = getHeadCounterTarget(ent)
    if not IsValid(counterEnt) then return end

    local hits = ((counterEnt.CurbstompHeadExpire or 0) > CurTime()) and (counterEnt.CurbstompHeadHits or 0) or 0
    hits = hits + 1

    counterEnt.CurbstompHeadHits = hits
    counterEnt.CurbstompHeadExpire = CurTime() + CURBSTOMP_HEAD_RESET

    if hits >= CURBSTOMP_HEAD_STOMPS_TO_POP then
        counterEnt.CurbstompHeadHits = 0
        counterEnt.CurbstompHeadExpire = 0
        hg.ExplodeHead(ent)
    end
end

function PLAYER:LegAttack()
    if not self:Alive() or hg.GetCurrentCharacter(self):IsRagdoll() or self:GetNWFloat("InLegKick",0) > CurTime() or not self:IsOnGround() or self:IsSprinting() then return end
    if self.InLegKick and self.InLegKick > CurTime() then return end
    if self:GetNWBool("TauntStopMoving", false) then return end
    if hook.Run( "PlayerCanLegAttack", self ) == false then return end

	local handClass = "weapon_hands_sh"
	if self:HasWeapon("weapon_hg_coolhands") then
		handClass = "weapon_hg_coolhands"
	else
		handClass = "weapon_hands_sh"
	end

    local hands = self:GetWeapon(handClass)
    if not IsValid(hands) then
        self:Notify("Where is your hands swep???", 1, "WHERE YOUR HANDS AT??", 0)
    return end

    local anim = "kick_pistol_base"
    anim = (self:KeyDown(IN_DUCK) or self:Crouching()) and "kick_pistol_base_crouch" or self:EyeAngles()[1] > 60 and "curbstomp_base" or self:EyeAngles()[1] > 35 and "kick_pistol_25_base" or self:EyeAngles()[1] > 20 and "kick_pistol_45_base" or anim

    self:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav",65)

    local org = self.organism
    org.stamina.subadd = org.stamina.subadd + (anim == "curbstomp_base" and 12 or 20) / (org.superfighter and 2 or 1)
    local speedmul = (2 - (org.stamina[1] / org.stamina.max))
    local speed = 1.5 * speedmul
    local animstopAdjust = 0.3 * speedmul
    local isCurbstomp = anim == "curbstomp_base"
    local dmg = isCurbstomp and 22 or 10 * (2 - speedmul)
    dmg = dmg * (self:IsBerserk() and org.berserk * 5 or 1)
    dmg = dmg * (org.legstrength or 1)
    dmg = dmg * (isCurbstomp and CURBSTOMP_DAMAGE_MUL or LEG_KICK_DAMAGE_MUL)
    --print(dmg)
    --print(speedmul)
    self:PlayCustomAnims(anim, true, speed, true, animstopAdjust, {
        [0.12] = function(self)
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            ang[1] = 0

            --self:SetVelocity(ang:Forward() * -120)
            local reportPos = self:GetPos() + self:OBBCenter()
            local tr = util.TraceLine({
                start = reportPos,
                endpos = reportPos + ang:Forward() * 32,
                filter = {hg.GetCurrentCharacter(self),self}
            })
            if tr.Hit and self:IsOnGround() then
                self:SetVelocity(ang:Forward() * -300)
            end
        end,
        [0.21] = function(self)
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            if ang[1] > 55 and not (self:KeyDown(IN_DUCK) or self:Crouching()) then
				self:ViewPunch(vpang)
				return
			else
				self:ViewPunch(-vpang)
			end
            ang[1] = 0
            local reportPos = self:GetPos() + self:OBBCenter()
            local tr = util.TraceLine({
                start = reportPos,
                endpos = reportPos + ang:Forward() * 72,
                filter = {hg.GetCurrentCharacter(self),self}
            })
            if tr.Hit and self:IsOnGround() then
                --self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
                self:SetVelocity(ang:Forward() * -150)
            end
        end,
        [0.33] = function(self) -- kick moment
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            ang[1] = 0

            self:EmitSound("player/shove_0" .. math.random(1,5) .. ".wav",65)

            local inDuck = (self:KeyDown(IN_DUCK) or self:Crouching())
            local tr, normal, footPos = getKickTrace(self, inDuck, isCurbstomp)

            local org = self.organism
            if org.rleg == 1 or org.rlegdislocation then
                org.painadd = org.painadd + 20
            end
            
            local entss = {}--ents.FindInBox( tr.HitPos + rad, tr.HitPos - rad )
            if !table.HasValue(entss, tr.Entity) then
                entss[#entss+1] = tr.Entity
            end
            local soundplayed = false
            local blacklist = {[self] = true, [hg.GetCurrentCharacter(self)] = true}
            if tr.Hit then
                soundplayed = true
                if org.rleg == 1 or org.rlegdislocation then
                    org.painadd = org.painadd + 20
                end
                self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
            end

            if IsValid(tr.Entity) and tr.Entity.fires then
            local key, fire = next(tr.Entity.fires)

                if key then 
                    tr.Entity.fires[key] = nil

                    if IsValid(key) then
                        key:Remove()
                    end
                end
            end

            for k,ent in ipairs(entss) do
                if IsValid(ent) and not blacklist[ent] then
                    local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone or 0)
                    if !ent:IsPlayer() and not IsValid(phys) then continue end
                    if not soundplayed then
                        soundplayed = true

                        if org.rleg == 1 or org.rlegdislocation then
                            org.painadd = org.painadd + 20
                        end

                        self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
                    end

                    local dmginfo = DamageInfo()

                    dmginfo:SetAttacker(self)
                    local inflictor = self:GetWeapon(handClass)
                    dmginfo:SetInflictor(inflictor)
                    dmginfo:SetDamage(dmg)
                    local ragForceMul = isCurbstomp and CURBSTOMP_RAG_FORCE_MUL or LEG_KICK_RAG_FORCE_MUL
                    local propForceMul = isCurbstomp and CURBSTOMP_PROP_FORCE_MUL or LEG_KICK_PROP_FORCE_MUL
                    local playerPush = isCurbstomp and CURBSTOMP_PLAYER_PUSH or LEG_KICK_PLAYER_PUSH
                    local force = normal * dmg * ragForceMul

                    dmginfo:SetDamageForce(force)
                    dmginfo:SetDamageType((ent:GetClass() == "func_breakable_surf") and DMG_SLASH or DMG_CLUB)
                    dmginfo:SetDamagePosition(tr.HitPos)

                    PenetrationGlobal = 1
					MaxPenLenGlobal = 1
                    hg.AddForceRag(ent, tr.PhysicsBone or 0, force, 0.25)
                    ent:TakeDamageInfo(dmginfo)
                    
                    if IsValid(phys) then
                        phys:ApplyForceOffset(normal * dmg * propForceMul, tr.HitPos)
                    end

					if ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
						ent:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav", 60, math.random(85, 105), 0.6)
					end

                    if ent:IsPlayer() then
                        local fakeChance = isCurbstomp and CURBSTOMP_FAKE_CHANCE or LEG_KICK_FAKE_CHANCE
                        if math.Rand(0, 1) <= fakeChance then
                            timer.Simple(0,function()
                                hg.Fake(ent)
                            end)
                        end

                        ent:SetVelocity(normal * playerPush)
                    end

                    if isCurbstomp then
                        handleCurbstompHead(ent, footPos or tr.HitPos)
                    end
                    if hgIsDoor(ent) and !ent:GetNoDraw() then
                        ent.HP = ent.HP or 200
                        ent.HP = ent.HP - dmg * (tr.MatType == MAT_METAL and 1 or 2)
                        ent:EmitSound( "physics/wood/wood_crate_impact_hard" .. math.random(1,4) .. ".wav" )
                        
                        if DoorIsOpen(ent) then
                            if !DoorIsOpen2(ent) then
                                ent:FastOpenDoor(self, 5, true)
                                --ent:Use(self)
                                local oldname = self:GetName()
                                self:SetName(oldname..self:EntIndex())
                                if ent:GetClass() == "func_door_rotating" then
                                    ent:Fire("open", self:GetName(), 0, self, self)
                                elseif ent:GetClass() == "prop_door_rotating" then
                                    ent:Fire("openawayfrom", self:GetName(), 0, self, self)
                                end
                                self:SetName(oldname)
                            else
                                ent:FastOpenDoor(self, 2, true)
                                ent:Fire("Close", oldname, 0, self, self)
                            end

                            ent:EmitSound("physics/wood/wood_box_impact_hard3.wav")
                        end

                        if ent.HP <= 0 then
                            hgBlastThatDoor(ent, normal * 125)
                        end
                    end
                end
            end
        end
    })
    self.InLegKick = CurTime() + speed - animstopAdjust
    self:SetNWFloat("InLegKick",CurTime() + speed - animstopAdjust)
end

hook.Add("HG_MovementCalc_2","HG-LegKickAnim",function(mul, ply, cmd, mv)
    if ply:GetNWFloat("InLegKick",0) > CurTime() then
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)
        cmd:RemoveKey(IN_JUMP)

        mv:RemoveKey(IN_MOVELEFT)
        mv:RemoveKey(IN_MOVERIGHT)
        mv:RemoveKey(IN_JUMP)

        mul[1] = math.min(math.max(0.001,1 - (ply:GetNWFloat("InLegKick",0) - CurTime()) * 2 ),1)

        if cmd:KeyDown(IN_DUCK) or ply:Crouching() then
            cmd:AddKey(IN_DUCK)
            mv:AddKey(IN_DUCK)
        else
            cmd:RemoveKey(IN_DUCK)
            mv:RemoveKey(IN_DUCK)
        end
    end
end)

concommand.Add("hg_kick",function(ply)
    ply:LegAttack()
end)
