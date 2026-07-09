if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Fiber Wire"
SWEP.Instructions = "This is a single cylindrical, flexible strand of metal connected to two ergonomic grips made of carbon fibre and metal. Use it to strange people.\n\nLMB to swing.\nWhen strangling, press LMB to stop strangling."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/hmc/weapons/w_fibrewire.mdl"
SWEP.WorldModelReal = "models/hmc/weapons/v_fibrewire_test.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""

SWEP.HoldType = "melee"

SWEP.ForceIdleAfterDeploy = false


SWEP.HoldPos = Vector(-6,-2,0)

SWEP.AttackTime = 0.4
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(0,-5,3)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 2
SWEP.ViewPunch2 = Angle(0,0,-4)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-8)
SWEP.weaponAng = Angle(0,-90,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 0
SWEP.DamageSecondary = 0

SWEP.BlockHoldPos = Vector(-6,0,0)
SWEP.BlockHoldAng = Angle(0, 0, 0)

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 12
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 70
SWEP.AttackLen2 = 40

SWEP.AnimList = {
    ["idle"] = "charge_idle",
    ["deploy"] = "Idle2_To_Charge",
    ["attack"] = "Swing",
    ["strangle_start"] = "strangle_start",
    ["strangle_loop"] = "strangle_loop",
    ["strangle_end"] = "strangle_end",
}

function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    self.setlh = true
    if CLIENT then
        self:HideDummyBone()
        if anim == "deploy" then
            timer.Simple(0.55, function()
                if not IsValid(self) then return end
                local owner = self:GetOwner()
                local lply = LocalPlayer()
                if not IsValid(owner) or not IsValid(lply) then return end
                if owner ~= lply then return end
                if self.IsLocal and not self:IsLocal() then return end
                owner:EmitSound("homigrad/suffocation_rope_break.wav", 75, 125)
            end)
        end
    end
    return self.BaseClass.PlayAnim(self, anim, time, cycling, callback, reverse, sendtoclient)
end

local function IsFromBehind(attacker, target)
    return true
end

local function GetStrangleTrace(owner, dist)
    local filter = {owner}
    local fr = owner.FakeRagdoll
    if IsValid(fr) then filter[#filter + 1] = fr end
    return util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * (dist or 100), filter)
end

local function IsChokeZoneHit(ent, tr)
    if not IsValid(ent) then return false end

    if ent:IsNPC() then
        if tr.HitGroup == HITGROUP_HEAD or tr.HitGroup == HITGROUP_NECK or tr.HitGroup == HITGROUP_CHEST then
            return true
        end
    end

    if ent:IsPlayer() then
        if tr.HitGroup == HITGROUP_HEAD or tr.HitGroup == HITGROUP_NECK or tr.HitGroup == HITGROUP_CHEST then
            return true
        end
        local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
        if headBone and tr.HitPos then
            local pos = ent:GetBonePosition(headBone)
            if pos and pos:Distance(tr.HitPos) <= 28 then return true end
        end
        return false
    end

    if ent:IsRagdoll() then
        -- Any ragdoll should be a valid choke target (including spawned prop_ragdoll).
        if tr.Entity == ent then return true end

        -- Extra proximity fallback around neck/chest for humanoid ragdolls.
        if tr.HitPos then
            local checkBones = {10, 9, 1, 2}
            for _, bone in ipairs(checkBones) do
                local physIdx = hg.realPhysNum(ent, bone)
                if physIdx ~= nil and physIdx >= 0 then
                    local obj = ent:GetPhysicsObjectNum(physIdx)
                    if IsValid(obj) and obj:GetPos():Distance(tr.HitPos) <= 40 then
                        return true
                    end
                end
            end
        end
        return false
    end

    return false
end

local function ResolveStrangleTarget(self, ent)
    if not IsValid(ent) then return nil end

    if ent:IsPlayer() then
        if hg and hg.Fake then hg.Fake(ent) end
        return ent.FakeRagdoll or ent
    end

    return ent
end

local function FindModeNPCRagdoll(npcPos, npcModel, existing)
    local best, bestDist
    for _, ent in ipairs(ents.FindInSphere(npcPos, 220)) do
        if ent:IsRagdoll() and not existing[ent] then
            local sameModel = (ent:GetModel() == npcModel)
            local dist = ent:GetPos():DistToSqr(npcPos)
            if sameModel then dist = dist * 0.6 end
            if not best or dist < bestDist then
                best = ent
                bestDist = dist
            end
        end
    end
    return best
end


local function PrepNPCDeathRagdoll(rag)
    if not IsValid(rag) or not rag:IsRagdoll() then return end

    rag._fiberwire_spawn_colgroup = rag:GetCollisionGroup()
    rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            phys:SetVelocity(vector_origin)
            phys:AddAngleVelocity(-phys:GetAngleVelocity())
        end
    end
end

local function GetFiberwireVictimPlayer(rag)
    if not IsValid(rag) or not hg or not hg.RagdollOwner then return nil end
    local victim = hg.RagdollOwner(rag)
    if not IsValid(victim) or not victim:IsPlayer() then return nil end
    return victim
end

local function WriteFiberwireKarma(self, rag, hitgroup, harm, dmginfo)
    if CLIENT then return end
    if not zb then return end
    if not harm or harm <= 0 then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local victim = GetFiberwireVictimPlayer(rag)
    if not IsValid(victim) or not victim:Alive() then return end

    dmginfo = dmginfo or DamageInfo()
    dmginfo:SetAttacker(owner)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamageType(dmginfo:GetDamageType() ~= 0 and dmginfo:GetDamageType() or self.DamageType)

    if IsValid(rag) then
        dmginfo:SetDamagePosition(rag:GetPos())
    end

    local ent = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(victim) or victim
    hook.Run("HomigradDamage", victim, dmginfo, hitgroup or HITGROUP_NECK, ent, harm)
end



local function StartStrangle(self, victim)
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    if IsValid(owner.FakeRagdoll) then return end

    if IsValid(victim) and victim:IsNPC() then
        local npc = victim

        local dmg = DamageInfo()
        dmg:SetDamage(npc:Health() + 10)
        dmg:SetDamageType(DMG_CLUB)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        dmg:SetDamagePosition(npc:GetPos())
        dmg:SetDamageForce(vector_origin)
        npc:TakeDamageInfo(dmg)

        timer.Simple(0, function()
            local foundRag
            for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
                if ent:GetModel() == npc:GetModel() and not ent._fw_strangled then
                    foundRag = ent
                    break
                end
            end
            
            if not IsValid(foundRag) then return end
            foundRag._fw_strangled = true
            
            self:SetStrangling(true)
            self.StrangleRag = foundRag
            self.VictimPlayer = nil 

            local physCount = foundRag:GetPhysicsObjectCount()
            for i = 0, physCount - 1 do
                local phys = foundRag:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:SetMass(1)
                end
            end

            PrepNPCDeathRagdoll(foundRag)
            owner:SetMoveType(MOVETYPE_WALK)

            self:PlayAnim("strangle_start", 1, false, nil, false, true)
            timer.Simple(1, function()
                if not IsValid(self) or not self:GetStrangling() then return end
                self:PlayAnim("strangle_loop", 100, true, nil, false, true)
            end)

            owner:EmitSound("hitman/weapon/fiberwire_start_0" .. math.random(1,3) .. ".wav", 75, 100)
            self._fw_next_breath = CurTime() + 1.5
            self._fw_lock_until = CurTime() + 0.5
        end)
        return
    end

    -- Make sure the victim is ragdolled; do not ragdoll attacker
    local rag = victim
    if IsValid(victim) and victim:IsPlayer() then
        hg.Fake(victim)
        rag = victim.FakeRagdoll
        
        -- Temporarily disable collision with players when strangling starts
        if IsValid(rag) then
            rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            
            -- Restore collision after a few seconds
            timer.Simple(3, function()
                if IsValid(rag) then
                    rag:SetCollisionGroup(COLLISION_GROUP_NONE)
                end
            end)
        end
    end

    if not IsValid(rag) or not rag:IsRagdoll() then return end

    -- prevent self-strangulation: ignore own ragdoll
    local ragOwner = (hg.RagdollOwner and hg.RagdollOwner(rag)) or nil
    if ragOwner == owner then return end

    -- Mark strangling state
    self:SetStrangling(true)
    self.StrangleRag = rag


    -- === НОВОЕ: инициализация звуков ===
    self.nextBreathSound = CurTime() + math.Rand(3, 5)
    self.breathStage = 0        -- 0 = вдохи, 1 = агональное дыхание
    self.inhaleCount = 0
    
    self.suffocationSound = CreateSound(owner, "homigrad/suffocation_rope.wav")
    if self.suffocationSound then
        self.suffocationSound:SetSoundLevel(60)
        self.suffocationSound:PlayEx(0.2, math.random(115, 120))
        -- Sometimes CreateSound needs to be explicitly told to loop via DSP or restarting, but CSoundPatch:Play() looping works if the sound has cue points. If not, we have to loop it manually.
        timer.Create("FW_LoopSound_" .. self:EntIndex(), SoundDuration("homigrad/suffocation_rope.wav") or 1.5, 0, function()
            if IsValid(self) and self:GetStrangling() and self.suffocationSound then
                self.suffocationSound:Stop()
                self.suffocationSound:PlayEx(0.2, math.random(115, 120))
            else
                timer.Remove("FW_LoopSound_" .. (IsValid(self) and self:EntIndex() or ""))
            end
        end)
    end




    rag.Strangler = owner -- link for other systems
    rag.StrangleLocked = true -- lock fake controls & get-up
    self.NoIdleLoop = true -- prevent idle from overwriting the loop
    -- disable collisions during choke to avoid knocking down strangler
    rag._oldCollisionGroup = rag._fiberwire_spawn_colgroup or rag:GetCollisionGroup()
    rag._fiberwire_spawn_colgroup = nil
    rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    -- FIX: Сохраняем исходную регенерацию кислорода жертвы
    local ragPly = hg.RagdollOwner(rag)
    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism and ragPly.organism.o2 then
        ragPly._fiberwire_old_o2regen = ragPly.organism.o2.regen
        ragPly.organism.o2.regen = 0
        self._fw_last_victim_o2 = ragPly.organism.o2[1]
    -- === НОВОЕ: уведомление жертве ===
        ragPly:Notify("I'm being strangled..", true, "fiberwire_strangle_start", 3)
    else
        self._fw_last_victim_o2 = nil
    end



    






    self._fw_looping = false
    self._fw_loop_at = CurTime() + 0.6
    self._fw_lock_until = CurTime() + 1

    -- let go of anything held with hands
    do
        local hands = owner:GetWeapon("weapon_hands_sh")
        if IsValid(hands) and hands.SetCarrying then
            hands:SetCarrying() -- drop carryent
        end
        if hg and hg.SetCarryEnt2 then
            hg.SetCarryEnt2(owner) -- drop carryent2
        end
    end

    -- lock sprint while choking; store and clamp run speed
    self._fw_prev_run = owner:GetRunSpeed()
    owner:SetRunSpeed(owner:GetWalkSpeed())

    -- upfront stamina cost for starting choke
    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
        owner.organism.stamina[1] = math.max(owner.organism.stamina[1] - 50, 0)
    end

    -- play start then loop (no callback passed over net)
    self:PlayAnim("strangle_start", 0.6, false, nil, false, true)
    timer.Simple(0.6, function()
        if not IsValid(self) then return end
        if not self:GetStrangling() then return end
        self:PlayAnim("strangle_loop", 4.0, true, nil, false, true)
        self._fw_looping = true
    end)


end

local function StopStrangle(self)
    if CLIENT then return end
    local owner = self:GetOwner()


     -- FIX: Восстанавливаем регенерацию кислорода у жертвы
    local rag = self.StrangleRag
    if IsValid(rag) then
        -- FIX: Восстанавливаем регенерацию кислорода
        local ragPly = hg.RagdollOwner(rag)
        if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism and ragPly.organism.o2 then
            if ragPly._fiberwire_old_o2regen ~= nil then
                ragPly.organism.o2.regen = ragPly._fiberwire_old_o2regen
                ragPly._fiberwire_old_o2regen = nil
            end
        end

        rag.Strangler = nil
        rag.StrangleLocked = nil
        if rag._oldCollisionGroup then
            rag:SetCollisionGroup(rag._oldCollisionGroup)
            rag._oldCollisionGroup = nil
        end
    end


    self:SetStrangling(false)
    self.StrangleRag = nil
    self.NoIdleLoop = nil -- allow idle again


    -- === НОВОЕ: сброс звуковых переменных ===
    self.nextBreathSound = nil
    self.breathStage = nil
    self.inhaleCount = nil

    if self.suffocationSound then
        self.suffocationSound:Stop()
        self.suffocationSound = nil
    end
    timer.Remove("FW_LoopSound_" .. self:EntIndex())

    self.StrangleStartTime = nil
    self.InitialHeadPos = nil
    self.InitialHeadAng = nil
    self._fw_last_victim_o2 = nil
    
    self.SlittingArteryTime = nil
    self.ArterySlitDone = nil


    if CLIENT or (IsValid(owner) and owner:IsPlayer()) then
        self:PlayAnim("strangle_end", 0.6, false, nil, false, true)
        timer.Simple(0.6, function()
            if not IsValid(self) then return end
            if self.GetStrangling and self:GetStrangling() then return end
            self:PlayAnim("deploy", 1.2, false, nil, false, true)
            timer.Simple(1.2, function()
                if not IsValid(self) then return end
                if self.GetStrangling and self:GetStrangling() then return end
                self:PlayAnim("idle", 10, true, nil, false, true)
            end)
        end)
    end
    self._fw_looping = false
    self._fw_loop_at = nil

    -- restore run speed after choke ends
    if IsValid(owner) and owner:IsPlayer() and self._fw_prev_run then
        owner:SetRunSpeed(self._fw_prev_run)
        self._fw_prev_run = nil
    end

    -- clear any residual movement slowdown
    if IsValid(owner) and owner.SetNetVar then
        owner:SetNetVar("slowDown", 0)
    end
    self._fw_lock_until = nil
    self._fw_release_attack_block_until = CurTime() + 3


end
-- ========================================================================

function SWEP:OnRemove()
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
end

function SWEP:OnDrop()
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
end

-- Function to hide bone index 60 (dummy model bone)
function SWEP:HideDummyBone()
    if CLIENT then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end
        -- Hide bone index 60 to hide the dummy model
        vm:ManipulateBoneScale(60, Vector(0, 0, 0))
        vm:ManipulateBonePosition(60, Vector(0, 0, 0))
    end
end

-- make sure re-equip returns to idle with LH IK off
function SWEP:Deploy()
    local ok = self.BaseClass.Deploy(self)

    timer.Simple(0.04, function()
        if not IsValid(self) then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if owner:GetActiveWeapon() ~= self then return end
        if self.GetStrangling and self:GetStrangling() then return end
        
        self:PlayAnim("deploy", 1.2, false, nil, false, true)
        timer.Simple(1.2, function()
            if IsValid(self) and not self:GetStrangling() then
                self:PlayAnim("idle", 10, true, nil, false, true)
            end
        end)
        if CLIENT then
            self:HideDummyBone()
        end
    end)

    return ok
end

function SWEP:Holster(target)
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
    if self.BaseClass and self.BaseClass.Holster then
        return self.BaseClass.Holster(self, target)
    end
    return true
end


if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_fibrewire")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_fibrewire"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis" -- Different attachment point
SWEP.holsteredPos = Vector(6, -1.5, -6) -- Adjust position
SWEP.holsteredAng = Angle(65, 0, 0) -- Adjust rotation
SWEP.Concealed = false -- wont show up on the body
SWEP.HolsterIgnored = false -- the holster system will ignore



SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.Attack2Hit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)
function SWEP:CanBlock()
    return false
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return false
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

-- Do not mark as HG weapon to avoid cl_fake.lua expecting `wep.weight`.
-- This prevents a client error comparing number with nil.
-- SWEP.ishgweapon = true

-- Track strangling state
function SWEP:SetupDataTables()
    if self.BaseClass and self.BaseClass.SetupDataTables then
        self.BaseClass.SetupDataTables(self)
    end
    -- Use a free index beyond base weapon_melee’s netvars
    self:NetworkVar("Bool", 13, "Strangling")
end

function SWEP:AdjustMouseSensitivity()
    if self:GetStrangling() then
        return 0.1
    end
    return 1
end

function SWEP:PrimaryAttack()
    if (self._fw_release_attack_block_until or 0) > CurTime() then return end

    if self:GetStrangling() then
        if (self._fw_lock_until or 0) > CurTime() then return end
        
        local owner = self:GetOwner()
        if IsValid(owner) and owner:KeyDown(IN_USE) then
            if not self.SlittingArteryTime then
                self.SlittingArteryTime = CurTime()
            end
            return
        end
        
        if SERVER then StopStrangle(self) end
        return
    end
    
    local oldAttack = self:GetLastAttack()
    local res = self.BaseClass.PrimaryAttack(self)
    
    if self:GetLastAttack() ~= oldAttack and self:GetOwner():IsPlayer() then
        local mul = 1
        local ply = self:GetOwner()
        if ply.organism and ply.organism.stamina and ply.organism.stamina[1] then
            mul = 1 / math.Clamp((180 - ply.organism.stamina[1]) / 90, 1, 2)
        end
        
        local swingWait = (self.WaitTime1 or 0.4) / mul
        local expectedNextAttack = self:GetLastAttack()
        
        timer.Simple(swingWait, function()
            if IsValid(self) and IsValid(self:GetOwner()) and not self:GetStrangling() then
                if self:GetLastAttack() ~= expectedNextAttack then return end
                
                self:PlayAnim("deploy", 1.2, false, nil, false, true)
                
                timer.Simple(1.2, function()
                    if IsValid(self) and not self:GetStrangling() then
                        if self:GetLastAttack() ~= expectedNextAttack then return end
                        self:PlayAnim("idle", 10, true, nil, false, true)
                    end
                end)
            end
        end)
    end
    
    return res
end

-- Preempt default damage on qualifying head-from-behind hits
function SWEP:CustomAttack()
    if CLIENT then return true end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return true end

    -- block strangling while attacker is in fake mode
    if IsValid(owner.FakeRagdoll) then return true end

    local tr = GetStrangleTrace(owner, 100)
    local hitEnt = tr.Entity
    if not IsValid(hitEnt) then return true end

    local zoneOK = IsChokeZoneHit(hitEnt, tr)
    local angleOK = true
    if zoneOK and angleOK then
        local target = ResolveStrangleTarget(self, hitEnt)
        StartStrangle(self, target)

        -- animations are handled inside StartStrangle()

        -- Cancel the default attack/damage flow
        self:SetInAttack(false)
        return true
    end

    -- No blunt damage: always cancel base attack flow
    return true
end

-- Keep victim's head close and stable in front while strangling
function SWEP:CustomThink()

    if self.BaseClass and self.BaseClass.CustomThink then
        self.BaseClass.CustomThink(self)
    end

    if self:GetStrangling() then
        local shakeMag = 0.015
        
        local owner = self:GetOwner()
        if IsValid(owner) and not owner:KeyDown(IN_USE) then
            self.SlittingArteryTime = nil
        end
        
        if self.SlittingArteryTime then
            local elapsed = CurTime() - self.SlittingArteryTime
            shakeMag = shakeMag + math.Clamp(elapsed / 2.0, 0, 1) * 0.4
            
            if SERVER and elapsed >= 2.0 and not self.ArterySlitDone then
                self.ArterySlitDone = true
                
                local rag = self.StrangleRag
                local ragPly = hg and hg.RagdollOwner and hg.RagdollOwner(rag) or nil
                
                local owner = self:GetOwner()
                
                local dmg = DamageInfo()
                dmg:SetDamage(10)
                dmg:SetDamageType(DMG_SLASH)
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                local hitPos = rag and rag:GetPos() or owner:GetPos()
                if IsValid(rag) then
                    local headPhys = hg and hg.realPhysNum and hg.realPhysNum(rag, 10)
                    if headPhys then
                        local phys = rag:GetPhysicsObjectNum(headPhys)
                        if IsValid(phys) then
                            hitPos = phys:GetPos()
                        end
                    end
                end
                dmg:SetDamagePosition(hitPos)
                
                if IsValid(ragPly) and ragPly:IsPlayer() then
                    if ragPly.organism and hg and hg.organism and hg.organism.input_list and hg.organism.input_list.arteria then
                        hg.organism.input_list.arteria(ragPly.organism, nil, 10, dmg, "ValveBiped.Bip01_Neck1", owner:GetAimVector(), hitPos)
                    end
                    WriteFiberwireKarma(self, rag, HITGROUP_NECK, zb and zb.MaximumHarm or 10, dmg)
                end
                
                StopStrangle(self)
                return
            end
        end
        
        local shake = Vector(math.Rand(-shakeMag, shakeMag), math.Rand(-shakeMag, shakeMag), math.Rand(-shakeMag, shakeMag))
        self.HoldPos = Vector(-4.85, -2, 0) + shake
    else
        self.HoldPos = Vector(-6, -2, 0)
    end

    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    -- Allow strangling to continue even if the strangler is fake (ragdolled), but we need to control from the fake ragdoll instead
    local isFake = IsValid(owner.FakeRagdoll)

    local rag = self.StrangleRag
    if not self:GetStrangling() then return end

        if IsValid(self.NPCVictim) then
        local npc = self.NPCVictim
        if not npc:Alive() then
            StopStrangle(self)
            return
        end

        local targetPos = owner:GetShootPos() + owner:GetAimVector() * 55
        npc:SetLastPosition(targetPos)
        npc:SetSchedule(SCHED_FORCED_GO_RUN)

        if npc:Health() > 0 then
            npc:SetHealth(math.max(npc:Health() - FrameTime() * 12, 0))
        end
        return
    end

    -- stop if ragdoll vanished
    if not IsValid(rag) or not rag:IsRagdoll() then
        StopStrangle(self) -- clean state
        return
    end

    -- stop if attacker died; dead victims/ragdolls are allowed targets by design
    if not owner:Alive() then
        StopStrangle(self)
        return
    end
    
    -- When the strangler is fake (ragdolled), if they get up (FakeRagdoll vanishes), we need to handle it or re-grab.
    -- Wait, if they get up, isFake becomes false, and the normal stragling logic will just resume since owner:Alive() is still true.
    -- However, if the attacker is completely dead or despawns, StopStrangle triggers.
    
    if isFake then
        if not self.FakeGraceStart then
            self.FakeGraceStart = CurTime()
        end
        
        if CurTime() - self.FakeGraceStart > 1.0 then
            if not owner:KeyDown(IN_USE) then
                StopStrangle(self)
                return
            end
        end
    else
        self.FakeGraceStart = nil
    end




        -- === НОВОЕ: звуки жертвы ===
    if IsValid(rag) then
        local ragPly = hg.RagdollOwner and hg.RagdollOwner(rag)
        if IsValid(ragPly) and ragPly:IsPlayer() then
            -- Проверяем, функционируют ли лёгкие (если нет – звуки не проигрываем)
            if not (ragPly.organism and ragPly.organism.lungsfunction == false) then
                if CurTime() >= (self.nextBreathSound or 0) then
                    local soundToPlay
                    -- Определяем пол жертвы (функция ThatPlyIsFemale должна быть доступна глобально)
                    local isFemale = false
                    if ThatPlyIsFemale then
                        isFemale = ThatPlyIsFemale(ragPly)
                    end

                    if self.breathStage == 0 then
                        -- Вдохи (inhale)
                        if isFemale then
                            local r = math.random(1, 5)
                            soundToPlay = "breathing/inhale/female/inhale_0" .. r .. ".wav"
                        else
                            local r = math.random(1, 4)
                            soundToPlay = "breathing/inhale/male/inhale_0" .. r .. ".wav"
                        end
                        self.inhaleCount = (self.inhaleCount or 0) + 1
                        if self.inhaleCount >= 5 then
                            self.breathStage = 1   -- после пяти вдохов переключаемся на агональное дыхание
                        end
                    else
                        -- Агональное дыхание (общие звуки)
                        local r = math.random(1, 13)
                        soundToPlay = "breathing/agonalbreathing_" .. r .. ".wav"
                    end

                    if soundToPlay then
                        -- Проигрываем звук от регдолла жертвы с невысокой громкостью (уровень 50)
                        rag:EmitSound(soundToPlay, 50, 100)
                    end

                    -- Устанавливаем следующий интервал (3-5 секунд)
                    self.nextBreathSound = CurTime() + math.Rand(3, 5)
                end
            end
        end
    end







    if not isFake then
        local shotang = owner:EyeAngles()
        shotang.pitch = Lerp(FrameTime()*10, shotang.pitch, 0)
        owner:SetEyeAngles( shotang )
    end
    
    local ang = owner:EyeAngles()
    ang:RotateAroundAxis(ang:Up(), 90)

    self._fw_punchshit2 = self._fw_punchshit2 or 0
    self._fw_punchshit = self._fw_punchshit or 0
    
    local headPhysNum = hg.realPhysNum(rag, 10)
    local headPhys = headPhysNum and rag:GetPhysicsObjectNum(headPhysNum)
    
    local controlEntity = isFake and owner.FakeRagdoll or owner
    
    if IsValid(headPhys) then
        if not self.StrangleStartTime then
            self.StrangleStartTime = CurTime()
            self.InitialHeadPos = headPhys:GetPos()
            self.InitialHeadAng = headPhys:GetAngles()
        end

        local shootPos = isFake and controlEntity:GetPos() + Vector(0,0,50) or controlEntity:GetShootPos()
        local aimVector = isFake and owner:GetAimVector() or controlEntity:GetAimVector()
        
        -- If strangler is ragdolled, try to attach to their hands
        if isFake then
            local lHandNum = hg.realPhysNum(controlEntity, 5)
            local rHandNum = hg.realPhysNum(controlEntity, 7)
            local lHandPhys = lHandNum and controlEntity:GetPhysicsObjectNum(lHandNum)
            local rHandPhys = rHandNum and controlEntity:GetPhysicsObjectNum(rHandNum)
            
            if IsValid(lHandPhys) and IsValid(rHandPhys) then
                shootPos = (lHandPhys:GetPos() + rHandPhys:GetPos()) / 2
                aimVector = (shootPos - controlEntity:GetPos()):GetNormalized()
                ang = aimVector:Angle()
                ang:RotateAroundAxis(ang:Up(), 90)
            end
        end

        local distanceOffset = isFake and 2 or 15
        local finalPos = shootPos + (aimVector*(distanceOffset + self._fw_punchshit2))
        local finalAng = ang
        
        local targetPos = finalPos
        local targetAng = finalAng
        
        local frac = math.Clamp((CurTime() - self.StrangleStartTime) / 1.0, 0, 1)
        if frac < 1 and self.InitialHeadPos and self.InitialHeadAng then
            local smoothFrac = frac * frac * (3 - 2 * frac)
            targetPos = LerpVector(smoothFrac, self.InitialHeadPos, finalPos)
            targetAng = LerpAngle(smoothFrac, self.InitialHeadAng, finalAng)
        end

        headPhys:SetPos(targetPos)
        self._fw_punchshit2 = Lerp(FrameTime()*10, self._fw_punchshit2, 0)
        headPhys:SetAngles(targetAng)
        headPhys:SetVelocity(Vector(0,0,0))
    end

    -- Make victim show struggle only while a living player is being choked.
    local ragPly2 = hg.RagdollOwner and hg.RagdollOwner(rag) or nil
    local ragOrg = ragPly2 and ragPly2.organism or nil
    local knockedOut = ragOrg and ragOrg.otrub == true
    local allowStruggle = IsValid(ragPly2) and ragPly2:IsPlayer() and ragPly2:Alive() and not knockedOut
    
    if allowStruggle then
        local headPhysRef = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 10))
        local lhandPhys = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 5))
        local rhandPhys = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 7))
        
        if IsValid(headPhysRef) and IsValid(lhandPhys) and IsValid(rhandPhys) then
            local pos = headPhysRef:GetPos()
            local lpos = lhandPhys:GetPos()
            local rpos = rhandPhys:GetPos()

            local leftOffset = pos - (pos - lpos):GetNormalized() * (2 + math.sin(CurTime() * 2) * 0.5)
            local rightOffset = pos - (pos - rpos):GetNormalized() * (2 + math.cos(CurTime() * 1.8) * 0.5)

            hg.ShadowControl(rag, 5, 0.001, nil, nil, nil, leftOffset, 80, 60)
            hg.ShadowControl(rag, 7, 0.001, nil, nil, nil, rightOffset, 80, 60)
        end
        
        if self._fw_punchshit < CurTime() then 
            -- Only viewpunch if the owner is not fake
            if not isFake then
                owner:ViewPunch(Angle(math.Rand(0.8, 1.8), 0, 0))
            end
            self._fw_punchshit2 = math.random(-4, -2)
            self._fw_punchshit = CurTime() + 0.3
        end
    end



         -- FIX: Принудительно блокируем регенерацию кислорода, пока длится удушье
    local ragPly = hg.RagdollOwner(rag)
    

    --[[

    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism and ragPly.organism.o2 then
        ragPly.organism.o2.curregen = 0   -- <-каждый параметр будет обнулен
    end

    ]]


    -- drain oxygen and stamina while choking (server-side)
    local ragPly = hg.RagdollOwner(rag)
    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism then
        if not ragPly:Alive() then
            StopStrangle(self)
            return
        end

        local org = ragPly.organism
        local dt = FrameTime()
        if org.o2 and org.o2.range and org.o2[1] then
            local lastO2 = self._fw_last_victim_o2
            local currentO2 = org.o2[1]
            if lastO2 and currentO2 < lastO2 then
                WriteFiberwireKarma(self, rag, HITGROUP_NECK, (lastO2 - currentO2) / math.max(org.o2.range, 1) * (zb and zb.MaximumHarm or 10))
            end
            self._fw_last_victim_o2 = currentO2
        end
        -- light, continuous choke effects
        --[[if org.o2 and org.o2[1] then
            org.o2[1] = math.max(org.o2[1] - 6 * dt, 0)
        end]]
        if org.stamina and org.stamina.subadd ~= nil then
            org.stamina.subadd = org.stamina.subadd + 6 * dt
        end
    end

    -- Keep strangulation animation looping reliably while active
    if (self._fw_loop_at or 0) > 0 and CurTime() >= self._fw_loop_at and not self._fw_looping then
        -- keep loop playing for local and remote viewers
        self:PlayAnim("strangle_loop", 4.0, true, nil, false, true)
        self._fw_looping = true
    end
    
    -- Always hide dummy bone during gameplay
    self:HideDummyBone()
end

-- Hook into melee hit resolution and start strangulation when appropriate
function SWEP:PrimaryAttackAdd(ent, trace)
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    if self:GetStrangling() then return end
    -- do not allow starting strangulation while in fake mode
    if IsValid(owner.FakeRagdoll) then return end

    local tr = GetStrangleTrace(owner, 100)
    local hitEnt = tr.Entity
    if not IsValid(hitEnt) then return end

    local zoneOK = IsChokeZoneHit(hitEnt, tr)
    local angleOK2 = true
    if zoneOK and angleOK2 then
        local target = ResolveStrangleTarget(self, hitEnt)
        StartStrangle(self, target)

        -- animation handled inside StartStrangle

        self:SetInAttack(false)
    end
end

-- Slow attacker movement while they are strangling
if SERVER then
    local function StopFiberwireForPlayer(ply)
        if not IsValid(ply) then return end

        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent.GetStrangling and ent:GetStrangling() then
                local owner = ent.GetOwner and ent:GetOwner() or nil
                local victim = GetFiberwireVictimPlayer(ent.StrangleRag)
                if owner == ply or victim == ply then
                    StopStrangle(ent)
                end
            end
        end
    end

    hook.Add("PlayerDeath", "FiberwireStopOnDeath", function(ply)
        StopFiberwireForPlayer(ply)
    end)

    hook.Add("PlayerDisconnected", "FiberwireStopOnDisconnect", function(ply)
        StopFiberwireForPlayer(ply)
    end)

    hook.Add("HG_MovementCalc_2", "FiberwireSlowMove", function(mul, ply, cmd)
        local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "weapon_zc_fiberwire_standalone" then return end
        if wep.GetStrangling and wep:GetStrangling() then
            mul[1] = mul[1] * 0.6 -- modest slowdown while choking
        end
    end)
end

-- No custom Think needed; base melee handles attack ticks

if SERVER then
    -- Prevent the currently strangled ragdoll from physically colliding with the strangler.
    hook.Add("ShouldCollide", "FiberwireNoCollideStranglerAndVictim", function(ent1, ent2)
        if not IsValid(ent1) or not IsValid(ent2) then return end

        local rag, ply
        if ent1:IsRagdoll() and ent2:IsPlayer() then
            rag, ply = ent1, ent2
        elseif ent2:IsRagdoll() and ent1:IsPlayer() then
            rag, ply = ent2, ent1
        else
            return
        end

        if rag.Strangler == ply then
            return false
        end
    end)

    -- block fake controls while strangled
    hook.Add("CanControlFake", "FiberwireStrangleLock", function(ply, rag)
        local r = ply and ply.FakeRagdoll
        if IsValid(r) and r.StrangleLocked then
            return false
        end
    end)

    -- prevent getting up while strangled
    hook.Add("Should Fake Up", "FiberwireStrangleLockUp", function(ply)
        local r = ply and ply.FakeRagdoll
        if IsValid(r) and r.StrangleLocked then
            return true
        end
    end)

    -- remove sprint input while strangling to enforce no-run
    hook.Add("StartCommand", "FiberwireNoSprint", function(ply, cmd)
        local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "weapon_zc_fiberwire_standalone" then return end
        if wep.GetStrangling and wep:GetStrangling() then
            cmd:RemoveKey(IN_SPEED)
        end
    end)
end

if CLIENT then
    function SWEP:DrawHUD()
        if GetViewEntity() ~= LocalPlayer() then return end
        if LocalPlayer():InVehicle() then return end
        
        if self:GetStrangling() then
            local x = ScrW() / 2
            local y = ScrH() / 2
            
            local xrand, yrand = math.random(-1, 1), math.random(-1, 1)
            draw.SimpleText("E + LMB to slit neck.", "HomigradFontMedium", x + 2 + xrand, y + 26 + yrand, color_black, TEXT_ALIGN_CENTER)
            draw.SimpleText("E + LMB to slit neck.", "HomigradFontMedium", x + xrand, y + 25 + yrand, color_red, TEXT_ALIGN_CENTER)
        end
    end
end
