if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Gravity Gun"
SWEP.Instructions = "The Zero Point Energy Field Manipulator. \nCommonly known as the Gravity Gun, is a Tractor beam-type weapon designed for handling hazardous materials.\n\nLMB To Punt RMB To Pull"
SWEP.Category = "Weapons - Other"
SWEP.Spawnable = true
SWEP.AdminOnly = game.IsDedicated()
SWEP.Slot = 1
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
if CLIENT then
    SWEP.WepSelectIcon = Material("entities/zcity/gravitygun.png")
    SWEP.IconOverride = "entities/zcity/gravitygun.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.WorldModel = "models/mmod/weapons/w_physics.mdl"
SWEP.WorldModelReal = "models/mmod/weapons/c_physcannon.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "slam"
SWEP.weight = 4
function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:CanSecondaryAttack()
    return true
end

SWEP.supportTPIK = true
SWEP.weaponPos = Vector(0, 0, 0)
SWEP.weaponAng = Angle(0, 0, 0)
SWEP.animtime = 0
SWEP.animspeed = 0
SWEP.cycling = false
SWEP.reverseanim = false
SWEP.setlh = true
SWEP.setrh = true
SWEP.sprint_ang = Angle(25, 0, 0)
SWEP.HoldPos = Vector(-10, -3, -3)
SWEP.HoldAng = Angle(-5, 0, 0)
SWEP.basebone = 1
SWEP.WorkWithFake = true
SWEP.modelscale = 1
SWEP.modelscale2 = 0.75
SWEP.DeploySpeed = 1
SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 70
SWEP.isTPIKBase = true
SWEP.AnimList = {
    ["deploy"] = {"draw", 5, false},
    ["attack"] = {"fire", 1, false},
    ["altfire"] = {"altfire", 1, false},
    ["idle_hold"] = {"hold_idle", 1, true},
    ["holster"] = {"fire", 1, false},
    ["idle"] = {"idle", 5, true},
}

SWEP.PuntForce = 1000000
SWEP.PuntMultiply = 850
SWEP.PullForce = 8000
SWEP.HL2PullForce = 4000
SWEP.HL2PullForceRagdoll = 3500
SWEP.MaxMass = 16500
SWEP.HL2MaxMass = 5500
SWEP.MaxPuntRange = 1650
SWEP.HL2MaxPuntRange = 550
SWEP.MaxPickupRange = 2550
SWEP.HL2MaxPickupRange = 850
SWEP.ConeWidth = 0.88
SWEP.MaxTargetHealth = 1000
SWEP.HL2MaxTargetHealth = 225
SWEP.GrabDistance = 25
SWEP.GrabDistanceRagdoll = 15
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = ""
local a = Sound("weapons/mmod/physcannon/hold_loop.wav")
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)
local IsValid, Vector, Angle, math, game, util, EffectData, ents, pairs, ipairs, table, bit, timer, GetConVar, ConVarExists = IsValid, Vector, Angle, math, game, util, EffectData, ents, pairs, ipairs, table, bit, timer, GetConVar, ConVarExists
local function b(u)
    local v = nil
    for w, x in ipairs(ents.FindByName("scgg_addon_global_dissolver")) do
        if ent:GetClass() == "env_entity_dissolver" then
            ent:Fire("Dissolve", "", 0, u)
            v = true
            break
        end
    end

    if v ~= true then
        local w = ents.Create("env_entity_dissolver")
        w:SetPos(vector_origin)
        w:SetKeyValue("target", "!activator")
        w:SetKeyValue("dissolvetype", 0)
        w:SetName("scgg_addon_global_dissolver")
        w:Spawn()
        w:Activate()
        w:Fire("Dissolve", "", 0, u)
    end
end

local function c(u, v)
    local w = nil
    if v:IsPlayer() then
        w = hg.eyeTrace(v, 32768)
    else
        w = util.TraceHull({
            start = v:EyePos(),
            endpos = v:EyePos() + v:GetAimVector() * 32768,
            filter = {u, v, hg.GetCurrentCharacter(v)},
            mins = Vector(-10, -10, -10),
            maxs = Vector(10, 10, 10),
            mask = MASK_SHOT_HULL
        })
    end
    return w
end

local function d(u)
    if u:IsPlayer() then
        if not u:Alive() then return false end
    elseif u:IsNPC() then
        if u:GetNPCState() == NPC_STATE_DEAD or u:Health() <= 0 then return false end
    end
    return true
end

local function e(u)
    if not IsValid(u.Owner) then return end
    if u.Owner:IsNPC() then
        u.Weapon:SetHoldType("shotgun")
        if SERVER then if u.Owner:Classify() == CLASS_METROPOLICE then u.Weapon:SetHoldType("smg") end end
    else
        u.Weapon:SetHoldType(u.HoldType)
    end
end

local function f(u, v)
    if v == true then
        local w = ents.Create("ambient_generic")
        w:SetPos(u:GetPos())
        w:SetKeyValue("message", a)
        w:SetKeyValue("health", "4")
        w:SetKeyValue("spawnflags", "16")
        w:SetParent(u)
        w:Spawn()
        w:Activate()
        w:Fire("PlaySound")
    else
        for w, x in ipairs(u:GetChildren()) do
            if IsValid(x) and x:GetClass() == "ambient_generic" and x:GetInternalVariable("message") == a then
                x:Fire("StopSound")
                x:Remove()
                break
            end
        end
    end
end

local function g(u)
    if IsValid(u) and u:GetMoveType() == MOVETYPE_VPHYSICS and IsValid(u:GetPhysicsObject()) and (u:GetPhysicsObject():IsMotionEnabled() or (not u:GetPhysicsObject():IsMotionEnabled() and (u:HasSpawnFlags(64) or (u:GetClass() == "func_physbox" and u:HasSpawnFlags(131072))))) then return true end
    return false
end

function SWEP:CanBePickedUpByNPCs()
    return true
end

function SWEP:GetCapabilities()
    if IsValid(self:GetOwner()) and self:GetOwner():IsNPC() then self:GetOwner():SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT) end
    return bit.bor(CAP_WEAPON_RANGE_ATTACK2, CAP_INNATE_RANGE_ATTACK1)
end

local function h(self, u)
    return false
end

function SWEP:SetupDataTables()
    self:NetworkVar("Entity", 0, "HP")
    self:NetworkVar("Entity", 1, "TP")
    self:NetworkVar("Bool", 0, "Glow")
    self:SetHP(nil)
    self:SetTP(nil)
    self:SetGlow(false)
end

local function i(self)
    self.Fading = false
    self.CoreAllowRemove = true
    self.HPCollideG = COLLISION_GROUP_NONE
    self.HPHealth = -1
    self.HPBone = nil
    self.OnDropOwner = nil
end

if SERVER then
    function SWEP:InitAdd()
        self:SetDeploySpeed(1)
        self:PlayAnim("deploy")
        e(self)
        self:SetSkin(1)
        i(self)
    end
end

if CLIENT then
    function SWEP:PlayClawSound(u)
        local v = "Weapon_PhysCannon.OpenClaws"
        if u == true then v = "Weapon_PhysCannon.CloseClaws" end
        self:StopClawSound()
        local w = CreateSound(self, v)
        self.ActiveSnd = w
        w:Play()
    end

    function SWEP:StopClawSound()
        if self.ActiveSnd ~= nil and self.ActiveSnd:IsPlaying() then self.ActiveSnd:Stop() end
    end

    function SWEP:AdjustClaws()
        local function u(y)
            local z = FrameTime()
            local A = y + z
            return A
        end

        if self.PoseParam < 0 then
            self.PoseParam = 0
        elseif self.PoseParam > 1 then
            self.PoseParam = 1
        end

        if self.PoseParamDesired < self.PoseParam then
            if self.PoseParam >= 1 then self:PlayClawSound(true) end
            local y = nil
            if game.SinglePlayer() then
                y = u(0.0025)
            else
                y = u(0.02)
            end

            self.PoseParam = self.PoseParam - y
        elseif self.PoseParamDesired > self.PoseParam then
            if self.PoseParam <= 0 then self:PlayClawSound(false) end
            local y = nil
            if game.SinglePlayer() then
                y = u(0.05)
            else
                y = u(0.1)
            end

            self.PoseParam = self.PoseParam + y
        end

        local v, w, x = GetVMPoses(self)
        if (v and IsValid(v)) or (w and IsValid(w)) then
            if not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
            if IsValid(v) then
                v:SetPoseParameter(x, self.PoseParam)
                v:InvalidateBoneCache()
            end

            if IsValid(w) then
                w:SetPoseParameter(x, self.PoseParam)
                w:InvalidateBoneCache()
            end
        end
    end

    function SWEP:ThinkAdd()
        if ConVarExists("cl_scgg_viewmodel") then
            local v = GetConVar("cl_scgg_viewmodel"):GetString()
            if util.IsValidModel(v) and self.ViewModel ~= v then
                self.ViewModel = v
                local w = self:GetOwner():GetViewModel()
                w:SetWeaponModel(v, self)
                w:InvalidateBoneCache()
            end
        end

        if not self:GetNWBool("Glow") then
            if not self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand") then return end
            local v = DynamicLight("lantern_" .. self:EntIndex())
            if v then
                v.Pos = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
                v.r = 255
                v.g = 175
                v.b = 50
                v.Brightness = 0.3
                v.Size = 100
                v.DieTime = CurTime() + 0.5
            end
        else
            if not self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand") then return end
            local v = DynamicLight("lantern_" .. self:EntIndex())
            if v then
                v.Pos = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
                v.r = 255
                v.g = 175
                v.b = 50
                v.Brightness = 0.6
                v.Size = 160
                v.DieTime = CurTime() + 0.5
            end
        end

        if self.PoseParam == nil then self.PoseParam = 0 end
        if self.PoseParamDesired == nil then self.PoseParamDesired = 0 end
        self:AdjustClaws()
        local u = 1
        if ConVarExists("scgg_claw_mode") then u = GetConVar("scgg_claw_mode"):GetInt() end
        if u <= 0 then
            self:CloseClaws(false)
        elseif u > 0 and u < 2 then
            self:OpenClaws(false)
        elseif u >= 2 then
            local v = self:GetGlow()
            if v then self:StopClawSound() end
            local w = self:GetOwner():GetEyeTrace()
            local x = w.Entity
            local y = nil
            if (not ConVarExists("scgg_cone") or GetConVar("scgg_cone"):GetBool()) and not self:PickupCheck(x) and (not IsValid(self:GetTP())) then
                y = self:GetConeEnt(w)
            else
                y = x
            end

            if IsValid(self:GetTP()) then
                timer.Remove("scgg_claw_close_delay" .. self:EntIndex())
                self:OpenClaws(false)
            elseif self:PickupCheck(y) then
                self:OpenClaws(true)
            else
                if not timer.Exists("scgg_claw_close_delay" .. self:EntIndex()) and IsValid(self) then
                    timer.Create("scgg_claw_close_delay" .. self:EntIndex(), 0.6, 1, function()
                        if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
                            self:CloseClaws(true)
                            self:OpenClaws(false, true)
                        end
                    end)
                end
            end
        end

        self:SetNextClientThink(CurTime() + 0.5)
    end
end

local function j(ent, u, v)
    local w = ent:GetPoseParameter(u)
    local x, y = ent:GetPoseParameterRange(w)
    return v
end

function SWEP:OpenClaws(u, v)
    if SERVER then return end
    if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
    if v == nil then v = false end
    local w = "active"
    local x = self:GetWM()
    local y = self
    timer.Remove("scgg_claw_close_delay" .. self:EntIndex())
    local z = 0
    local A = 0
    if IsValid(x) then
        local B = x:GetPoseParameter(w)
        B = j(x, w, B)
    end

    if IsValid(y) then
        local B = y:GetPoseParameter(w)
        B = j(y, w, B)
    end

    if (x and z < 1) or (y and A < 1) then
        local B = x:GetPoseParameter(w)
        local C = y:GetPoseParameter(w)
        if not timer.Exists("scgg_move_claws_open" .. self:EntIndex()) then
            timer.Remove("scgg_move_claws_close" .. self:EntIndex())
            timer.Create("scgg_move_claws_open" .. self:EntIndex(), 0, 20, function()
                if not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then
                    timer.Remove("scgg_move_claws_open" .. self:EntIndex())
                    return
                end

                if IsValid(x) then
                    if B > 1 then x:SetPoseParameter(w, 1) end
                    B = (v and B - 0.1) or B + 0.1
                    x:SetPoseParameter(w, B)
                    x:InvalidateBoneCache()
                end

                if IsValid(y) then
                    if C > 1 then y:SetPoseParameter(w, 1) end
                    C = (v and C - 0.1) or C + 0.1
                    y:SetPoseParameter(w, C)
                    y:InvalidateBoneCache()
                    if A >= 0.5 then self.ClawOpenState = true end
                end
            end)

            if (B <= 0 or C <= 0) and not IsValid(self:GetHP()) and u then
                self:StopSound("weapons/mmod/physcannon/physcannon_claws_close.wav")
                self:EmitSound("weapons/mmod/physcannon/physcannon_claws_open.wav")
            end
        end

        if (not IsValid(self:GetOwner()) or not self:GetOwner():Alive()) or (not IsValid(x) and not IsValid(y)) or (z >= 1 and A >= 1) then
            timer.Remove("scgg_move_claws_open" .. self:EntIndex())
            return
        end
    end
end

function SWEP:CloseClaws(u)
    if SERVER then return end
    if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
    local v = "active"
    local w = self:GetWM()
    local x = self
    timer.Remove("scgg_claw_close_delay" .. self:EntIndex())
    local y = 0
    local z = 0
    if IsValid(w) then local A = w:GetPoseParameter(v) end
    if IsValid(x) then local A = x:GetPoseParameter(v) end
    if (w and y > 0) or (x and z > 0) then
        local A = y
        local B = z
        if not timer.Exists("scgg_move_claws_close" .. self:EntIndex()) then
            timer.Remove("scgg_move_claws_open" .. self:EntIndex())
            timer.Create("scgg_move_claws_close" .. self:EntIndex(), 0, 20, function()
                if not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then
                    timer.Remove("scgg_move_claws_close" .. self:EntIndex())
                    return
                end

                if IsValid(w) then
                    if A < 0 then w:SetPoseParameter(v, 0) end
                    A = A - 0.05
                    w:SetPoseParameter(v, A)
                    w:InvalidateBoneCache()
                end

                if IsValid(x) then
                    if B < 0 then x:SetPoseParameter(v, 0) end
                    B = B - 0.05
                    x:SetPoseParameter(v, B)
                    x:InvalidateBoneCache()
                end

                if z < 0.5 then self.ClawOpenState = false end
            end)

            if (A >= 1 or B >= 1) and not IsValid(self:GetHP()) and u then
                self:StopSound("weapons/mmod/physcannon/physcannon_claws_open.wav")
                self:EmitSound("weapons/mmod/physcannon/physcannon_claws_close.wav")
            end
        end

        if (not IsValid(self:GetOwner()) or not self:GetOwner():Alive()) or (not IsValid(w) and not IsValid(x)) or (y <= 0 and z <= 0) then
            timer.Remove("scgg_move_claws_close" .. self:EntIndex())
            return
        end
    end
end

local function k(self)
    timer.Remove("deploy_idle" .. self:EntIndex())
    timer.Remove("attack_idle" .. self:EntIndex())
    timer.Remove("scgg_move_claws_open" .. self:EntIndex())
    timer.Remove("scgg_move_claws_close" .. self:EntIndex())
    timer.Remove("scgg_claw_close_delay" .. self:EntIndex())
end

function SWEP:OwnerChanged()
    if SERVER then
        self:TPrem()
        self:HPrem()
    end

    e(self)
end

local function l(self, u)
    if IsValid(u) and self.Fading ~= true and ((((self:AllowedClass(u) and u:GetMoveType() == MOVETYPE_VPHYSICS) and (IsValid(u:GetPhysicsObject()) and u:GetPhysicsObject():GetMass() < self:GetMaxMass() and g(u) or CLIENT)) or (((u:IsNPC() or u:IsNextBot()) and u:Health() <= self:GetMaxTargetHealth()) or u:IsPlayer() or u:IsRagdoll())) and not self:NotAllowedClass(u)) then return true end
    return false
end

local function m(self, u)
    local v = 0
    if IsValid(u) then
        v = (u:GetPos() - self:GetOwner():GetPos()):LengthSqr() / self:GetMaxPuntRange()
    else
        v = self:GetMaxPuntRange() + 10
    end

    if l(self, u) and v < self:GetMaxPuntRange() then return true end
    return false
end

function SWEP:PickupCheck(u)
    local v = 0
    if IsValid(u) then
        v = (u:GetPos() - self:GetOwner():GetPos()):LengthSqr() / self:GetMaxPickupRange()
    else
        v = self:GetMaxPickupRange() + 10
    end

    if l(self, u) and (v < self:GetMaxPickupRange()) then return true end
    return false
end

function SWEP:GetConeEnt(u)
    local function v(B)
        local C = {}
        for E, ent in ipairs(B) do
            if IsValid(ent) and ent ~= self and ent ~= self:GetOwner() then
                local F = ent:WorldSpaceCenter()
                if F:IsZero() then F = ent:GetPos() end
                local G = util.TraceLine({
                    start = self:GetOwner():EyePos(),
                    endpos = F,
                    filter = {self, self:GetOwner(), hg.GetCurrentCharacter(self:GetOwner())},
                    mask = MASK_SHOT_HULL
                })

                if G.Entity == ent then
                    local H = {{ent, (ent:GetPos() - self:GetOwner():EyePos()):LengthSqr() / self:GetMaxPickupRange()}}
                    table.Add(C, H)
                else
                end
            end
        end

        local D = {}
        for E, F in ipairs(C) do
            local G = {F[#F]}
            table.Add(D, G)
            if F == C[#C] then
                local H = table.KeyFromValue(table.SortByKey(D, true), 1)
                local I = C[H]
                local J = I[1]
                if IsValid(J) then return J end
            end
        end
    end

    local w = {}
    local x = {}
    local y = {}
    local z = {}
    local A = ents.FindInCone(self:GetOwner():EyePos(), self:GetOwner():GetAimVector(), self:GetMaxPickupRange(), self.ConeWidth)
    for B, ent in ipairs(A) do
        if l(self, ent) and ent ~= self and ent ~= self:GetOwner() then
            if ent:GetClass() == "prop_combine_ball" then
                local C = {ent}
                table.Add(w, C)
            elseif ((ent:IsNPC() or ent:IsNextBot())) or (ent:IsPlayer() and ent:Alive()) then
                local C = {ent}
                table.Add(x, C)
            elseif ent:IsRagdoll() then
                local C = {ent}
                table.Add(y, C)
            elseif ent:GetMoveType() == MOVETYPE_VPHYSICS or (self:AllowedClass(ent) and not self:NotAllowedClass(ent)) then
                local C = {ent}
                table.Add(z, C)
            end
        end
    end

    if not table.IsEmpty(w) then
        return v(w)
    elseif not table.IsEmpty(x) then
        return v(x)
    elseif not table.IsEmpty(y) then
        return v(y)
    elseif not table.IsEmpty(z) then
        return v(z)
    end
    return nil
end

local function n(u)
    local v = u:GetPos()
    if IsValid(u.Owner) then v = u.Owner:EyePos() end
    local w = ents.Create("weapon_physcannon")
    w:SetPos(v)
    w:SetAngles(u:GetAngles())
    w:Spawn()
    w:Activate()
    if IsValid(u.FadeCore) then u.FadeCore:SetParent(w) end
    local x = u:GetPhysicsObject()
    local y = w:GetPhysicsObject()
    if IsValid(x) and IsValid(y) then
        y:SetVelocity(x:GetVelocity())
        y:AddAngleVelocity(x:GetAngleVelocity())
    end

    cleanup.ReplaceEntity(u, w)
    undo.ReplaceEntity(u, w)
    undo.Finish()
    return w
end

if SERVER then
    function SWEP:Discharge()
        if self.Fading == true or IsValid(self.FadeCore) then return end
        self.Fading = true
        if IsValid(self:GetHP()) then self:Drop() end
        self:EmitSound("Weapon_Physgun.Off", 75, 100, 0.6)
        self:CloseClaws(false)
        local u = self
        local v = "core"
        if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then v = "muzzle" end
        local w = ents.Create("env_citadel_energy_core")
        if coreattachmentID ~= nil and coreattachment ~= nil then
            w:SetPos(coreattachment.Pos)
            w:SetAngles(coreattachment.Ang)
        else
            w:SetPos(self:GetPos())
            w:SetAngles(self:GetAngles())
        end

        w:SetParent(self)
        w:Spawn()
        w:Fire("SetParentAttachment", v, 0)
        w:Fire("AddOutput", "scale 1.5", 0)
        w:Fire("StartDischarge", "", 0.1)
        w:Fire("ClearParent", "", 0.89)
        w:Fire("Stop", "", 0.9)
        w:Fire("Kill", "", 1.9)
        self.FadeCore = w
        timer.Simple(0.20, function()
            if not IsValid(self) or not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then return end
            self:PlayAnim("holster")
        end)

        timer.Simple(0.90, function()
            if not IsValid(self) then return end
            if IsValid(self.FadeCore) then self.FadeCore:Remove() end
            local x = n(self)
            if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then if self:GetOwner():HasWeapon("weapon_physcannon") and IsValid(self:GetOwner():GetActiveWeapon()) and self:GetOwner():GetActiveWeapon() == self then self:GetOwner():SelectWeapon("weapon_physcannon") end end
            local y = self:GetClass()
            if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():HasWeapon(y) and self:GetOwner():GetWeapon(y) == self then
                self:GetOwner():StripWeapon(y)
            else
                if IsValid(self:GetOwner()) and self:GetOwner():IsNPC() then self:GetOwner():DropWeapon(self) end
                self:Remove()
            end
        end)
    end
end

function SWEP:ThinkAdd()
    local u = self:GetHP()
    local styleCvar = false
    if ConVarExists("scgg_style") then styleCvar = GetConVar("scgg_style"):GetBool() end
    if not styleCvar then
        self.SwayScale = 3
        self.BobScale = 1
    else
        self.SwayScale = 1
        self.BobScale = 1
    end

    if SERVER and ConVarExists("scgg_enabled") and GetConVar("scgg_enabled"):GetInt() <= 0 and not self.Fading then self:Discharge() end
    if SERVER then if IsValid(self.Core) then self.Core:SetPos(self:GetOwner():GetShootPos()) end end
    local v = nil
    if CLIENT then
        if self:PickupCheck(v) then
            self:OpenClaws(true)
        elseif IsValid(u) and self.Fading ~= true then
            timer.Remove("scgg_move_claws_close" .. self:EntIndex())
            self:OpenClaws(false)
        else
            if not timer.Exists("scgg_claw_close_delay" .. self:EntIndex()) and IsValid(self) then
                timer.Create("scgg_claw_close_delay" .. self:EntIndex(), 0.6, 1, function()
                    if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() and IsValid(self:GetOwner():GetViewModel()) then
                        self:CloseClaws(true)
                        self:OpenClaws(false, true)
                    end
                end)
            end
        end
    end

    if SERVER then
        if IsValid(u) and not self.Fading then
            self:GlowEffect()
        else
            self:RemoveGlow()
        end
    end

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        if not self:GetOwner():KeyDown(IN_ATTACK) then if ConVarExists("scgg_primary_extra") and bit.band(GetConVar("scgg_primary_extra"):GetInt(), 1) == 1 then self:SetNextPrimaryFire(CurTime() - 0.55) end end
        if SERVER then
            if self:GetOwner():KeyPressed(IN_ATTACK2) and not self.Fading then
                if IsValid(v) and v:GetMoveType() == MOVETYPE_VPHYSICS then
                    local w = v:GetPhysicsObject():GetMass()
                    if w > self:GetMaxMass() then
                        self:EmitSound("weapons/mmod/physcannon/physcannon_tooheavy.wav")
                        return
                    end
                else
                    self:EmitSound("weapons/mmod/physcannon/physcannon_tooheavy.wav")
                    return
                end
            end
        end
    end

    if IsValid(self:GetTP()) then
        for w, x in ipairs(self:GetTP():GetChildren()) do
            if x:GetClass() == "env_entity_dissolver" then
                x:Remove()
                break
            end
        end
    end

    if IsValid(u) then
        if not IsValid(self:GetOwner()) or not d(self:GetOwner()) then self:Drop() end
        if SERVER then
            local w = nil
            if u:IsRagdoll() and self.HPBone ~= nil and util.IsValidPhysicsObject(u, self.HPBone) then w = u:GetPhysicsObjectNum(self.HPBone) end
            if not IsValid(w) then
                if IsValid(u:GetPhysicsObject()) then
                    w = u:GetPhysicsObject()
                else
                    w = u
                end
            end

            if not IsValid(self:GetOwner()) then return end
            local x = u:BoundingRadius()
            local y = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.GrabDistance + x)
            local z = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.GrabDistanceRagdoll + x)
            local function A(E)
                local F = ents.FindInSphere(y, 5)
                local G = ents.FindInSphere(self:GetOwner():GetShootPos(), 15)
                for H, ent in ipairs(F) do
                    if IsValid(ent) and ent == E then return true end
                end

                for H, ent in ipairs(G) do
                    if IsValid(ent) and ent == E then return true end
                end
                return false
            end

            local B = self:GetOwner():GetShootPos() - u:WorldSpaceCenter()
            B:Normalize()
            B = B * self:GetPullForce(u)
            local C = 50.0
            if w ~= u then C = w:GetMass() end
            B = B * (C + 0.5) * (1 / 5.0)
            if not A(u) and not IsValid(self:GetTP()) or h(self, u) then
                if w ~= u then
                    w:SetVelocityInstantaneous(Vector(0, 0, 0))
                    w:AddAngleVelocity(w:GetAngleVelocity() * -1)
                    w:ApplyForceCenter(B)
                else
                    w:SetVelocity(Vector(0, 0, 0))
                end
            elseif IsValid(self:GetTP()) then
                if u:IsRagdoll() then
                    self:GetTP():SetPos(z)
                else
                    self:GetTP():SetPos(y)
                end

                self:GetTP():PointAtEntity(self:GetOwner())
            else
                self:CreateTP()
            end

            local D = u:GetAngles()
            u:SetAngles(Angle(0, D.y, D.r))
            if IsValid(w) then
                if w ~= u then
                    w:Wake()
                else
                    w:Fire("Wake")
                end
            end
        end

        if self.PropLockTime == nil then self.PropLockTime = CurTime() + 1.75 end
        if not styleCvar and CurTime() >= self.PropLockTime then
            if not IsValid(u) then
                self:SetHP(nil)
                return
            end

            local w = u:BoundingRadius()
            if (u:GetPos() - (self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.GrabDistance + w))):LengthSqr() / 80 >= 80 then self:Drop() end
        end
    elseif self.HP_PickedUp then
        self:Drop()
        self.HP_PickedUp = nil
    end
end

local o = {
    ["npc_strider"] = true,
    ["npc_helicopter"] = true,
    ["npc_combinedropship"] = true,
    ["npc_antliongrub"] = true,
    ["npc_turret_ceiling"] = true,
    ["npc_sniper"] = true,
    ["npc_combine_camera"] = true,
    ["npc_combinegunship"] = true,
    ["npc_bullseye"] = true,
    ["prop_ragdoll"] = true,
    ["npc_alyx"] = true,
    ["npc_barney"] = true,
    ["npc_breen"] = true,
    ["npc_citizen"] = true,
    ["npc_dog"] = true,
    ["npc_eli"] = true,
    ["npc_gman"] = true,
    ["npc_kleiner"] = true,
    ["npc_magnusson"] = true,
    ["npc_mossman"] = true,
    ["npc_odessa"] = true,
    ["npc_vortigaunt"] = true,
    ["npc_monk"] = true,
    ["npc_antlionguard"] = true,
    ["npc_antlionguardian"] = true,
}

function SWEP:NotAllowedClass(ent)
    if not IsValid(ent) then return false end
    local u = ent:GetClass()
    if o[u] then
        return true
    else
        return false
    end
end

function SWEP:AllowedClass(ent)
    if not IsValid(ent) then return false end
    local u = ent:GetClass()
    for v, w in ipairs(ent:GetChildren()) do
        if w:GetClass() == "env_entity_dissolver" then return false end
    end

    if not ent:IsNPC() and not ent:IsPlayer() and not ent:IsNextBot() and not ent:IsRagdoll() and ConVarExists("scgg_allow_others") and GetConVar("scgg_allow_others"):GetBool() and not self:NotAllowedClass(ent) then return true end
    if u == "npc_manhack" or u == "npc_turret_floor" or u == "npc_sscanner" or u == "npc_cscanner" or u == "npc_clawscanner" or u == "npc_rollermine" or u == "npc_grenade_frag" or u == "item_ammo_357" or u == "item_ammo_ar2_altfire" or u == "item_ammo_crossbow" or u == "item_ammo_pistol" or u == "item_ammo_smg1" or u == "item_ammo_smg1_grenade" or u == "item_battery" or u == "item_box_buckshot" or u == "item_healthvial" or u == "item_healthkit" or u == "item_rpg_round" or u == "item_ammo_ar2" or u == "item_item_crate" or (ent:IsWeapon() and not IsValid(ent:GetOwner())) or u == "megaphyscannon" or u == "weapon_striderbuster" or u == "combine_mine" or u == "bounce_bomb" or u == "combine_bouncemine" or u == "gmod_camera" or u == "gmod_cameraprop" or u == "helicopter_chunk" or u == "func_physbox" or u == "func_pushable" or u == "grenade_helicopter" or u == "prop_combine_ball" or u == "gmod_wheel" or u == "prop_vehicle_prisoner_pod" or u == "prop_physics_respawnable" or u == "prop_physics_multiplayer" or u == "prop_physics_override" or u == "prop_physics" or u == "prop_dynamic" then
        return true
    else
        return false
    end
end

function SWEP:FriendlyNPC(u)
    if SERVER then
        if not IsValid(u) then return false end
        if not u:IsNPC() then return false end
        if u:Disposition(self:GetOwner()) == (D_LI or D_NU or D_ER) then
            return true
        else
            return false
        end
    else
        return false
    end
end

local function p(self, u)
    if not IsValid(u) then return end
    local v = u:GetClass()
    if v ~= "npc_manhack" then return end
    u.SCGG_HurtByHookPhys = nil
    local function w(y, z)
        local A = z.OurOldVelocity:LengthSqr() / 1550
        if not y.SCGG_HurtByHookPhys and A > 250 then
            y.SCGG_HurtByHookPhys = true
            local B = DamageInfo()
            B:SetDamage(A / 10)
            B:SetDamageForce(self:GetOwner():GetPos())
            B:SetReportedPosition(self:GetOwner():GetPos())
            B:SetAttacker(self:GetOwner())
            B:SetInflictor(self)
            y:TakeDamageInfo(B)
            if IsValid(z.HitEntity) and z.HitEntity:Health() > 0 then z.HitEntity:TakeDamageInfo(B) end
        end
    end

    local x = u:AddCallback("PhysicsCollide", w)
    timer.Simple(1.0, function() if IsValid(u) then u:RemoveCallback("PhysicsCollide", x) end end)
end

local function q(self, u, v, w)
    if not SERVER then return end
    if w == nil then w = true end
    local x = DamageInfo()
    x:SetDamageForce(self:GetOwner():GetShootPos())
    x:SetDamageType(DMG_PHYSGUN)
    x:SetAttacker(self:GetOwner())
    x:SetInflictor(self)
    x:SetReportedPosition(self:GetOwner():GetShootPos())
    if w then
        x:SetDamage(self:GetMaxTargetHealth())
        x:SetDamagePosition(v)
    else
        x:SetDamage(u:Health())
    end

    if u:IsPlayer() or u:IsRagdoll() then
		hg.AddForceRag(u, 2, self:GetOwner():EyeAngles():Forward() * 42500, -0.2)
		hg.AddForceRag(u, 0, self:GetOwner():EyeAngles():Forward() * 42500, -0.2)
		hg.LightStunPlayer(u, 5)
        u:TakeDamageInfo((x / 2))
    elseif u:IsNPC() or u:IsNextBot() then
        if u:GetShouldServerRagdoll() ~= true then u:SetShouldServerRagdoll(true) end
        u:TakeDamageInfo(x)
    end
end

local function r(self, u, v)
    if not SERVER then return nil end
    local w = nil
    if v == nil then v = true end
    for y, z in ipairs(ents.FindInSphere(u:GetPos(), u:GetModelRadius())) do
        if z:IsRagdoll() and z:GetCreationTime() == CurTime() then
            w = z
            break
        end
    end

    local x = false
    if not IsValid(w) and u:GetClass() ~= "npc_antlion_worker" and (u:GetClass() ~= "npc_antlion" or u:GetModel() ~= "models/antlion_worker.mdl") then
        local y = ents.Create("prop_ragdoll")
        y:SetPos(u:GetPos())
        y:SetAngles(u:GetAngles() - Angle(u:GetAngles().p, 0, 0))
        y:SetModel(u:GetModel())
        if u:GetSkin() then y:SetSkin(u:GetSkin()) end
        y:SetColor(u:GetColor())
        for z, A in pairs(u:GetBodyGroups()) do
            y:SetBodygroup(A.id, u:GetBodygroup(A.id))
        end

        y:SetMaterial(u:GetMaterial())
        if not v then y:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end
        y:SetKeyValue("spawnflags", 8192)
        y:Spawn()
        w = y
        x = true
    elseif not v and not IsValid(w) then
        for y, z in ipairs(ents.FindInSphere(u:GetPos(), u:GetModelRadius())) do
            if (z:IsRagdoll() or z:GetClass() == "prop_physics") and z:GetCreationTime() == CurTime() then
                w = z
                break
            end
        end
    end

    if (u:IsNPC() or u:IsPlayer()) and IsValid(u:GetActiveWeapon()) then
        local y = u:GetActiveWeapon()
        local z = y:GetClass()
        if u:IsNPC() then
            local A = false
            if ConVarExists("scgg_weapon_vaporize") then A = GetConVar("scgg_weapon_vaporize"):GetBool() end
            if not A then
                local weaponmodel = ents.Create(z)
                if IsValid(weaponmodel) then
                    weaponmodel:SetPos(u:GetShootPos())
                    weaponmodel:SetAngles(y:GetAngles() - Angle(y:GetAngles().p, 0, 0))
                    weaponmodel:SetSkin(y:GetSkin())
                    weaponmodel:SetColor(y:GetColor())
                    weaponmodel:SetKeyValue("spawnflags", "2")
                    weaponmodel:Spawn()
                    weaponmodel:Fire("Addoutput", "spawnflags 0", 1)
                end
            elseif A then
                if IsValid(weaponmodel) then
                    local weaponmodel = ents.Create("prop_physics_override")
                    weaponmodel:SetPos(u:GetShootPos())
                    weaponmodel:SetAngles(y:GetAngles() - Angle(y:GetAngles().p, 0, 0))
                    weaponmodel:SetModel(y:GetModel())
                    weaponmodel:SetSkin(y:GetSkin())
                    weaponmodel:SetColor(y:GetColor())
                    weaponmodel:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                    weaponmodel:Spawn()
                    b(weaponmodel)
                end
            end
        end
    end

    if self:GetOwner():IsPlayer() and x == true and IsValid(w) then
        cleanup.Add(self:GetOwner(), "props", w)
        undo.Create("Ragdoll")
        undo.AddEntity(w)
        undo.SetPlayer(self:GetOwner())
        undo.Finish()
    end

    if u:IsPlayer() then
        if IsValid(u:GetRagdollEntity()) and u:GetRagdollEntity() ~= w then
            u:GetRagdollEntity():Remove()
            u:SpectateEntity(w)
            u:Spectate(OBS_MODE_CHASE)
        end
    elseif u:IsNPC() or u:IsNextBot() then
        u:Fire("Kill", "", 0)
    end

    if (v or x == true) and IsValid(w) then
        for y = 1, w:GetPhysicsObjectCount() - 1 do
            local z = w:GetPhysicsObjectNum(y)
            if z and IsValid(z) then
                if x == true then
                    local A, B = u:GetBonePosition(w:TranslatePhysBoneToBone(y))
                    z:SetPos(A)
                    z:SetAngles(B)
                end

                if v then
                    timer.Simple(0.01, function()
                        if IsValid(self) and IsValid(self:GetOwner()) and IsValid(z) then
                            if not styleCvar then
                                z:AddVelocity(self:GetOwner():GetAimVector() * (13000 / 8))
                            else
                                z:AddVelocity(self:GetOwner():GetAimVector() * (z:GetMass() * self.PuntMultiply))
                            end
                        end
                    end)
                end
            end
        end
    end
    return w
end

function SWEP:PrimaryAttack()
    if self.Fading or PrimaryFired then return end
    local u = self:GetHP()
    self:PlayAnim("attack")
    self:SetNextPrimaryFire(CurTime() + 0.55)
    if self:GetOwner():IsPlayer() then
        timer.Create("attack_idle" .. self:EntIndex(), 0.4, 1, function()
            if not IsValid(self) then return end
            if IsValid(self:GetOwner()) and IsValid(self) and self:GetOwner():GetActiveWeapon() == self and self.Fading == false then self:PlayAnim("idle") end
        end)
    end

    if IsValid(u) then
        local y = u:BoundingRadius()
        if (u:GetPos() - (self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.GrabDistance + y))):LengthSqr() / 80 >= 80 then
            return
        else
            self:DropAndShoot()
            return
        end
    end

    local v = c(self, self:GetOwner())
    local w = v.Entity
    if not m(self, w) then
        self:EmitSound("weapons/mmod/physcannon/physcannon_dryfire.wav")
        return
    end

    self:Visual(v)
    local styleCvar = false
    if ConVarExists("scgg_style") then styleCvar = GetConVar("scgg_style"):GetBool() end
    local x = true
    if ConVarExists("scgg_zap") then x = GetConVar("scgg_zap"):GetBool() end
    if SERVER then
        if (w:IsNPC() or w:IsNextBot()) and not self:AllowedClass(w) and not self:NotAllowedClass(w) or w:IsPlayer() then
            q(self, w, v.HitPos, true)
            if w:Health() > 0 then
                w:SetVelocity(self:GetOwner():GetAimVector() * Vector(2500, 2500, 0))
                return
            end

            local y = r(self, w, true)
            if x and IsValid(y) then y:SCGG_RagdollZapper() end
            if IsValid(y) then
                y:SCGG_RagdollCollideTimer()
                y:SetPhysicsAttacker(self:GetOwner(), 10)
                y:SetCollisionGroup(self.HPCollideG)
                y:SetMaterial(w:GetMaterial())
                y:Fire("FadeAndRemove", "", 120)
            end

            if self:GetOwner():IsPlayer() then self:GetOwner():AddFrags(1) end
            if x and IsValid(y) then y:Fire("StartRagdollBoogie", "", 0) end
        elseif w:GetMoveType() ~= MOVETYPE_VPHYSICS and w:Health() > 0 then
            local y = DamageInfo()
            y:SetDamage(self:GetMaxTargetHealth())
            y:SetDamageForce(self:GetOwner():GetShootPos())
            y:SetDamagePosition(v.HitPos)
            y:SetDamageType(DMG_PHYSGUN)
            y:SetAttacker(self:GetOwner())
            y:SetInflictor(self)
            y:SetReportedPosition(self:GetOwner():GetShootPos())
            w:TakeDamageInfo(y)
        end
    end

    if g(w) then w:GetPhysicsObject():EnableMotion(true) end
    if self:AllowedClass(w) or w:GetClass() == "prop_vehicle_airboat" or w:GetClass() == "prop_vehicle_jeep" or (not self:NotAllowedClass() and IsValid(w:GetPhysicsObject())) then
        if w:GetClass() == "prop_combine_ball" and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
            self:GetOwner():SimulateGravGunPickup(w)
            timer.Simple(0.01, function() if IsValid(w) and IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then self:GetOwner():SimulateGravGunDrop(w) end end)
        end

        if SERVER then
            if not IsValid(w) or not IsValid(w:GetPhysicsObject()) then return end
            local y = v.HitPos
            local z = w:GetPhysicsObject()
            if not styleCvar then
                if w:GetClass() == "prop_combine_ball" or w:GetClass() == "npc_grenade_frag" then
                    z:ApplyForceCenter(self:GetOwner():GetAimVector() * 480000)
                    z:ApplyForceOffset(self:GetOwner():GetAimVector() * 480000, y)
                    w:SetOwner(self:GetOwner())
                else
                    z:ApplyForceCenter(self:GetOwner():GetAimVector() * (z:GetMass() * self.PuntMultiply))
                    z:ApplyForceOffset(self:GetOwner():GetAimVector() * (z:GetMass() * self.PuntMultiply), y)
                end
            else
                if w:GetClass() == "prop_combine_ball" then
                    z:ApplyForceCenter(self:GetOwner():GetAimVector())
                    z:ApplyForceOffset(self:GetOwner():GetAimVector(), y)
                    w:SetOwner(self:GetOwner())
                else
                    z:ApplyForceCenter(self:GetOwner():GetAimVector() * (z:GetMass() * self.PuntMultiply))
                    z:ApplyForceOffset(self:GetOwner():GetAimVector() * (z:GetMass() * self.PuntMultiply), y)
                end
            end

            w:SetPhysicsAttacker(self:GetOwner(), 10)
        end

        p(self, w)
        w:SetSaveValue("m_flEngineStallTime", 2.0)
        w:SetSaveValue("m_hPhysicsAttacker", self:GetOwner())
    end

    if w:IsRagdoll() then
        if SERVER then
            w:SetPhysicsAttacker(self:GetOwner(), 10)
            if x then w:Fire("StartRagdollBoogie", "", 0) end
        end

        w:SCGG_RagdollZapper()
        w:SCGG_RagdollCollideTimer()
        local y = self:GetOwner()
        local z = hg.GetCurrentCharacter(y)
        if not z:IsRagdoll() then
            hg.AddForceRag(y, 2, y:EyeAngles():Forward() * -10000, 0.5)
            hg.AddForceRag(y, 0, y:EyeAngles():Forward() * -10000, 0.5)
            hg.LightStunPlayer(y, 1)
        end

        z:GetPhysicsObjectNum(0):SetVelocity(z:GetVelocity() + y:EyeAngles():Forward() * -2000)
        for A = 1, w:GetPhysicsObjectCount() - 1 do
            local B = w:GetPhysicsObjectNum(A)
            if B and B.IsValid and B:IsValid() then
                if not styleCvar then
                    B:AddVelocity(self:GetOwner():GetAimVector() * (10000 / 8))
                else
                    B:AddVelocity(self:GetOwner():GetAimVector() * (w:GetPhysicsObject():GetMass() * self.PuntMultiply))
                end
            end
        end

        if SERVER then w:SetCollisionGroup(self.HPCollideG) end
    end

    if self:AllowedClass(w) and not w:IsRagdoll() and SERVER then
        local y = DamageInfo()
        y:SetDamage(10)
        y:SetDamageForce(self:GetOwner():GetShootPos())
        y:SetDamagePosition(w:GetPos())
        y:SetDamageType(DMG_PHYSGUN)
        y:SetAttacker(self:GetOwner())
        y:SetInflictor(self)
        y:SetReportedPosition(self:GetOwner():GetShootPos())
        w:TakeDamageInfo(y)
    end
end

function SWEP:DropAndShoot()
    if not IsValid(self) then return end
    self:DropGeneral()
    local u = self:GetHP()
    if not IsValid(u) then
        self:HPrem()
        return
    end

    if SERVER then u:Fire("EnablePhyscannonPickup", "", 1) end
    local v = u:Health()
    if v ~= nil and v > 0 and self.HPHealth ~= nil and self.HPHealth > 0 then
        u:SetHealth(self.HPHealth)
        self.HPHealth = -1
    end

    if SERVER then
        if u:IsRagdoll() then
            u:SetCollisionGroup(COLLISION_GROUP_NONE)
        else
            u:SetCollisionGroup(self.HPCollideG)
        end

        u:SetPhysicsAttacker(self:GetOwner(), 10)
        self:GetOwner():SimulateGravGunDrop(u)
    end

    if u:GetClass() == "prop_combine_ball" then u:SetSaveValue("m_bLaunched", true) end
    p(self, u)
    u:SetSaveValue("m_flEngineStallTime", 2.0)
    u:SetSaveValue("m_hPhysicsAttacker", self:GetOwner())
    local styleCvar = false
    if ConVarExists("scgg_style") then styleCvar = GetConVar("scgg_style"):GetBool() end
    local w = true
    if ConVarExists("scgg_zap") then w = GetConVar("scgg_zap"):GetBool() end
    self.Secondary.Automatic = true
    if styleCvar then
        self:SetNextSecondaryFire(CurTime() + 0.5)
        self:SetNextPrimaryFire(CurTime() + 0.55)
    end

    local x = c(self, self:GetOwner())
    self:Visual(x)
    if IsValid(u) and u:IsRagdoll() then
        local y = DamageInfo()
        y:SetDamage(500)
        y:SetAttacker(self:GetOwner())
        y:SetInflictor(self)
        if SERVER and w then u:Fire("StartRagdollBoogie", "", 0) end
        for z = 1, u:GetPhysicsObjectCount() - 1 do
            local A = u:GetPhysicsObjectNum(z)
            if A and A.IsValid and A:IsValid() then
                if w then u:SCGG_RagdollZapper() end
                u:SCGG_RagdollCollideTimer()
                if IsValid(A) then
                    if not styleCvar then
                        A:AddVelocity(self:GetOwner():GetAimVector() * (20000 / 8))
                    elseif IsValid(u:GetPhysicsObject()) then
                        A:AddVelocity(self:GetOwner():GetAimVector() * (u:GetPhysicsObject():GetMass() * self.PuntMultiply))
                    end
                end
            end
        end
    elseif IsValid(u) and IsValid(u:GetPhysicsObject()) then
        local y = x.HitPos
        local z = u
        timer.Simple(0.01, function()
            if not IsValid(z) or not IsValid(z:GetPhysicsObject()) or not IsValid(self) or not IsValid(self:GetOwner()) then return end
            local A = z:GetPhysicsObject()
            if not styleCvar and z:GetClass() == "prop_combine_ball" then
                A:SetVelocity(Vector(0, 0, 0))
                A:ApplyForceCenter(self:GetOwner():GetAimVector() * 480000)
                A:ApplyForceOffset(self:GetOwner():GetAimVector() * 480000, y)
                z:SetOwner(self:GetOwner())
            elseif z:GetClass() == "prop_combine_ball" then
                A:SetVelocity(Vector(0, 0, 0))
                A:ApplyForceCenter(self:GetOwner():GetAimVector() * self.PuntForce / 0.125)
                A:ApplyForceOffset(self:GetOwner():GetAimVector() * self.PuntForce / 0.125, y)
                z:SetOwner(self:GetOwner())
            elseif not styleCvar then
                A:ApplyForceCenter(self:GetOwner():GetAimVector() * (A:GetMass() * self.PuntMultiply))
                A:ApplyForceOffset(self:GetOwner():GetAimVector() * (A:GetMass() * self.PuntMultiply), y)
            else
                A:ApplyForceCenter(self:GetOwner():GetAimVector() * self.PuntForce)
                A:ApplyForceOffset(self:GetOwner():GetAimVector() * self.PuntForce, y)
            end

            A:AddAngleVelocity(A:GetAngleVelocity() * -1)
        end)
    end

    if self.HPCollideG then self.HPCollideG = COLLISION_GROUP_NONE end
    if IsValid(self:GetTP()) then self:TPrem() end
    self:HPrem()
end

function SWEP:SecondaryAttack()
    if self.Fading == true then return end
    if IsValid(self:GetHP()) and self:GetOwner():IsPlayer() and self:GetOwner():KeyPressed(IN_ATTACK2) then
        self:PlayAnim("attack")
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:Drop()
        return
    end

    local u = c(self, self:GetOwner())
    local v = u.Entity
    local w = nil
    w = v
    self:CloseClaws(false)
    if not IsValid(w) then return end
    local styleCvar = false
    if ConVarExists("scgg_style") then styleCvar = GetConVar("scgg_style"):GetBool() end
    if (not styleCvar) and ((w:IsNPC() or w:IsNextBot() or w:IsPlayer()) and w:Health() > self:GetMaxTargetHealth()) or (w:IsNPC() and w:GetClass() == "npc_bullseye") or ((w:IsNPC() or w:IsNextBot() or w:IsPlayer() or w:IsRagdoll()) and not util.IsValidRagdoll(w:GetModel()) and not util.IsValidProp(w:GetModel())) then return end
    local x = self:GetMaxPickupRange()
    local y = (w:GetPos() - self:GetOwner():GetPos()):LengthSqr() / x
    local z = false
    local function A(B)
        if z == true then return end
        z = true
        self:PlayAnim("attack")
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:SetHP(B)
        self.HP_PickedUp = true
        if self:GetOwner():IsPlayer() then self:GetOwner():SimulateGravGunPickup(B) end
        self.HPCollideG = B:GetCollisionGroup()
        B.EmergencyHPCollide = B:GetCollisionGroup()
        B:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:Pickup()
        self:SetNextSecondaryFire(CurTime() + 0.2)
        if styleCvar then self:SetNextPrimaryFire(CurTime() + 0.1) end
        self.Secondary.Automatic = false
        if B:IsRagdoll() then if u.Entity == B then self.HPBone = u.PhysicsBone end end
    end

    if SERVER and not self:NotAllowedClass(w) and not self:AllowedClass(w) and y < x then
        if w:IsPlayer() and w:HasGodMode() == true then return end
        if w:IsNPC() or w:IsNextBot() or w:IsPlayer() then
            q(self, w, u.HitPos, false)
            if w:Health() >= 1 then return end
            local B = r(self, w, false)
            A(B)
        end
    end

    if SERVER and not z and IsValid(w:GetPhysicsObject()) and w:GetMoveType() == MOVETYPE_VPHYSICS then
        if g(w) then w:GetPhysicsObject():EnableMotion(true) end
        local B = w:GetPhysicsObject():GetMass()
        local C = self:GetPullForce() / (y * 0.002)
        local D = self.HL2PullForceRagdoll / (y * 0.001)
        if not styleCvar then if B >= (self:GetMaxMass() + 1) and w:GetClass() ~= "prop_combine_ball" then return end end
        if y < x then
            A(w)
        else
            w:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetAimVector() * -C)
        end
    end
end

function SWEP:Pickup()
    local u = self:GetHP()
    if not IsValid(u) then
        self:PlayAnim("attack")
        return
    end

    self:StopSound("weapons/mmod/physcannon/physcannon_claws_open.wav")
    self:StopSound("weapons/mmod/physcannon/physcannon_claws_close.wav")
    self:EmitSound("weapons/mmod/physcannon/physcannon_pickup.wav")
    f(self, true)
    self:PlayAnim("attack")
    self.PropLockTime = nil
    timer.Simple(0.4, function()
        if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and self:GetOwner():IsPlayer() and d(self:GetOwner()) and self:GetOwner():GetActiveWeapon() == self and self.Fading == false then
            self:PlayAnim("idle_hold")
        else
            self:PlayAnim("idle")
        end
    end)

    local v = c(self, self:GetOwner())
    u:Fire("DisablePhyscannonPickup", "", 0)
    local w = u:Health()
    if w > 0 then
        self.HPHealth = w
        u:SetHealth(999999999)
    end

    if u:IsRagdoll() then
        u:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        if not ConVarExists("scgg_zap") or GetConVar("scgg_zap"):GetBool() then u:SCGG_RagdollZapper(true) end
    end
	
	if u:IsPlayer() then
        hg.LightStunPlayer(u)
    end
	
    if u:GetClass() == "prop_combine_ball" then
        u:SetOwner(self:GetOwner())
        if IsValid(u:GetPhysicsObject()) then u:GetPhysicsObject():AddGameFlag(FVPHYSICS_WAS_THROWN) end
    end
end

function SWEP:Drop(u, v)
    if not IsValid(self) then return end
    local w = self:GetHP()
    local x = self:GetOwner()
    if not IsValid(self:GetOwner()) and IsValid(u) then x = u end
    self:DropGeneral()
    if SERVER and IsValid(w) then
        w:Fire("EnablePhyscannonPickup", "", 1)
        if w:IsRagdoll() then
            w:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        else
            w:SetCollisionGroup(self.HPCollideG)
        end

        local y = w
        timer.Simple(0.01, function()
            if not IsValid(y) or not IsValid(y:GetPhysicsObject()) then return end
            local A = y:GetPhysicsObject()
            if y:GetClass() == "prop_combine_ball" then
                A:SetVelocity(Vector(0, 0, 0))
                A:ApplyForceCenter(Vector(math.random(360), math.random(360), math.random(360)) * 3000)
            else
                A:AddAngleVelocity(A:GetAngleVelocity() * -1)
            end
        end)

        local z = w:Health()
        if z > 0 and self.HPHealth > 0 then
            w:SetHealth(self.HPHealth)
            self.HPHealth = -1
        end
    end

    self:PlayAnim("attack")
    if SERVER and IsValid(w) and w:IsRagdoll() then
        local y = true
        if ConVarExists("scgg_zap") then y = GetConVar("scgg_zap"):GetBool() end
        if y then w:SCGG_RagdollZapper() end
        w:SCGG_RagdollCollideTimer()
        if y then w:Fire("StartRagdollBoogie", "", 0) end
    end

    self.Secondary.Automatic = true
    if not v or v == false then self:EmitSound("weapons/mmod/physcannon/physcannon_drop.wav") end
    self:SetNextSecondaryFire(CurTime() + 0.5)
    if SERVER and IsValid(w) then x:SimulateGravGunDrop(w) end
    timer.Simple(0.4, function()
        if not IsValid(self) or not IsValid(self) then return end
        if IsValid(x) and x:GetActiveWeapon() == self and self.Fading == false then self:PlayAnim("idle") end
    end)

    self:TPrem()
    self:HPrem()
    if self.HPCollideG then self.HPCollideG = COLLISION_GROUP_NONE end
end

function SWEP:DropGeneral()
    self.PropLockTime = nil
    self.HPBone = nil
    f(self, false)
    if SERVER then self:RemoveGlow() end
    local u = self:GetHP()
    if IsValid(u) then
        local v = u:GetPhysicsObject()
        local w = 150.0
        local x = Vector(0, 0, 0)
        if IsValid(v) then
            x = v:GetVelocity()
        else
            x = u:GetVelocity()
        end

        if x.x > w then
            x.x = w
        elseif x.x < -w then
            x.x = -w
        end

        if x.y > w then
            x.y = w
        elseif x.y < -w then
            x.y = -w
        end

        x.z = 0
        if u:IsRagdoll() then
            for y = 1, u:GetPhysicsObjectCount() - 1 do
                local z = u:GetPhysicsObjectNum(y)
                if z and z.IsValid and IsValid(z) then z:SetVelocity(x) end
            end
        end

        if IsValid(v) then
            v:SetVelocity(x)
        else
            u:SetVelocity(x)
        end
    end
end

local s = Color(255, 255, 255, 100)
function SWEP:Visual(u)
    local v = self:GetOwner()
    self:PlayAnim("altfire")
    v:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/mmod/physcannon/superphys_launch" .. math.random(4) .. ".wav")
    if SERVER and v.PlayerClassName ~= "Gordon" then
        local A = hg.GetCurrentCharacter(v)
        if not A:IsRagdoll() then
            hg.AddForceRag(v, 2, v:EyeAngles():Forward() * -15000, 0.5)
            hg.AddForceRag(v, 0, v:EyeAngles():Forward() * -15000, 0.5)
            hg.LightStunPlayer(v, 1)
        end

        A:GetPhysicsObjectNum(0):SetVelocity(A:GetVelocity() + v:EyeAngles():Forward() * -2000)
    end

    if SERVER then
        local A = ents.Create("light_dynamic")
        A:SetKeyValue("brightness", "5")
        A:SetKeyValue("distance", "200")
        A:SetLocalPos(v:GetShootPos())
        A:SetLocalAngles(self:GetAngles())
        A:Fire("Color", "255 175 50")
        A:SetParent(self)
        A:Spawn()
        A:Activate()
        A:Fire("TurnOn", "", 0)
        self:DeleteOnRemove(A)
        timer.Simple(0.15, function() if IsValid(A) then A:Remove() end end)
    end

    if IsValid(v) and v:IsPlayer() then
        v:ViewPunch(Angle(-math.random(10, 20), math.random(-1, 1) == 1 and -15 or 15, math.random(-25, 25)) / (v.PlayerClassName == "Gordon" and 4 or 1))
        v:ScreenFade(SCREENFADE.IN, s, 0.25, 0)
    end

    local w = self:GetHP()
    local x = EffectData()
    if not IsValid(w) or u.Entity ~= w then
        x:SetOrigin(u.HitPos)
    else
        x:SetOrigin(w:GetPos())
    end

    x:SetStart(v:GetShootPos())
    x:SetAttachment(1)
    x:SetEntity(self)
    util.Effect("PhyscannonTracer", x)
    local y = EffectData()
    y:SetEntity(u.Entity)
    y:SetMagnitude(15)
    y:SetScale(15)
    y:SetRadius(15)
    y:SetColor(255, 150, 50)
    util.Effect("TeslaHitBoxes", y)
    u.Entity:EmitSound("Weapon_StunStick.Activate")
    if SERVER then self:MuzzleEffect() end
    local z = EffectData()
    z:SetMagnitude(30)
    z:SetScale(30)
    z:SetRadius(30)
    z:SetOrigin(u.HitPos)
    z:SetNormal(u.HitNormal)
    util.Effect("ManhackSparks", z)
end

local t = FindMetaTable("Entity")
function t:SCGG_RagdollZapper(u)
    local v = "scgg_zapper_" .. self:EntIndex()
    if u ~= nil and u == true then
        timer.Remove(v)
        return
    end

    local w = 0.2
    local x = 24
    if timer.Exists(v) then
        timer.Adjust(v, w, x)
        return
    end

    local function y()
        local z = EffectData()
        if not IsValid(self) then
            timer.Remove(v)
            return
        end

        z:SetOrigin(self:GetPos())
        z:SetStart(self:GetPos())
        z:SetMagnitude(5)
        z:SetEntity(self)
        util.Effect("teslaHitBoxes", z)
        self:EmitSound("Weapon_StunStick.Activate", 75, math.Rand(99, 101), 0.1, SNDLVL_45dB)
    end

    y()
    timer.Create(v, w, x, function()
        y()
        if not IsValid(self) then
            timer.Remove(v)
            return
        end

        if timer.RepsLeft(v) <= 0 then
            timer.Remove(v)
            return
        end
    end)
end

function t:SCGG_RagdollCollideTimer()
    local u = "scgg_collidecheck_" .. self:EntIndex()
    if timer.Exists(u) then
        timer.Adjust(u, 2.0, 1)
        return
    end

    local function v(ent)
        if not IsValid(ent) then return false end
        local w = ent:GetCollisionGroup()
        if w ~= COLLISION_GROUP_WEAPON or w ~= COLLISION_GROUP_DEBRIS or w ~= COLLISION_GROUP_DEBRIS_TRIGGER or w ~= COLLISION_GROUP_WORLD then
            return true
        else
            return false
        end
    end

    timer.Create(u, 4.5, 1, function()
        if not IsValid(self) then return end
        local w = self:GetCollisionGroup()
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end)
end

function SWEP:Deploy()
    self:SetDeploySpeed(1)
    self:PlayAnim("deploy")
    i(self)
    self.OnDropOwner = self:GetOwner()
    self:SetNextSecondaryFire(CurTime() + 5)
    k(self)
    if IsValid(self:GetOwner()) then
        if self:GetOwner():IsPlayer() then
            local u = self:GetOwner():GetViewModel()
            local v = 0
            v = u:SequenceDuration()
            timer.Create("deploy_idle" .. self:EntIndex(), v, 1, function()
                if not IsValid(self) then return true end
                if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveWeapon()) and self:GetOwner():GetActiveWeapon() == self and self.Fading == false then self:PlayAnim("idle") end
                self:SetNextSecondaryFire(CurTime() + 0.01)
            end)
        end
    end

    self:EmitSound("weapons/mmod/physcannon/gravgun_deploy.wav", 70, math.random(95, 105))
    return true
end

function SWEP:Holster()
    local u = self:GetOwner().PlayerClassName ~= "Gordon"
    local v = nil
    local own = self:GetOwner()
    v = "models/weapons/shadowysn/c_superphyscannon.mdl"
    if IsValid(own) and own:IsPlayer() and own:GetInfo("cl_scgg_viewmodel") then v = own:GetInfo("cl_scgg_viewmodel") end
    if self.ViewModel ~= self.WorldModel and util.IsValidModel(v) and not IsUselessModel(v) then self.ViewModel = v end
    self:SetDeploySpeed(1)
	if SERVER then
    if IsValid(own) and u then hg.drop(own, self) end
	end
    k(self)
    self:SetPoseParameter("active", 0)
    self:SetHP(nil)
    self:TPrem()
    self:HPrem()
    return true
end

function SWEP:OnDrop()
    local u = self:GetHP()
    if SERVER then
        self:TPrem()
        self:HPrem()
    end

    if IsValid(self.OnDropOwner) then self:Drop(self.OnDropOwner, true) end
    if IsValid(u) then self:SetHP(nil) end
end

function SWEP:HPrem()
    self:SetHP(nil)
    self.HP_PickedUp = nil
end

function SWEP:TPrem()
    if SERVER and IsValid(self:GetTP()) then self:GetTP():Remove() end
    if IsValid(self.Const) and (self.Const:IsConstraint() or self.Const:GetClass() == "phys_ragdollconstraint") then
        if SERVER then self.Const:Remove() end
        self.Const = nil
    end

    self:SetTP(nil)
end

function SWEP:CreateTP()
    local u = self:GetHP()
    if not IsValid(u) then return end
    local v = nil
    if u:GetClass() == "prop_combine_ball" or u:GetClass() == "npc_manhack" then
        v = ents.Create("prop_dynamic")
    else
        v = ents.Create("prop_physics")
    end

    self:SetTP(v)
    local w = nil
    if u:IsRagdoll() and self.HPBone ~= nil and util.IsValidPhysicsObject(u, self.HPBone) then w = u:GetPhysicsObjectNum(self.HPBone) end
    if not IsValid(w) then if IsValid(u:GetPhysicsObject()) then w = u:GetPhysicsObject() end end
    if IsValid(w) and u:IsRagdoll() then
        v:SetPos(w:GetPos())
    elseif not u:WorldSpaceCenter():IsZero() then
        v:SetPos(u:WorldSpaceCenter())
    else
        v:SetPos(u:GetPos())
    end

    v:SetModel("models/props_junk/PopCan01a.mdl")
    v:Spawn()
    v:SetCollisionGroup(COLLISION_GROUP_WORLD)
    v:SetRenderMode(RENDERMODE_TRANSCOLOR)
    v:SetColor(Color(255, 255, 255, 0))
    v:PointAtEntity(self:GetOwner())
    if v:GetClass() == "prop_physics" then
        v:GetPhysicsObject():SetMass(50000)
        v:GetPhysicsObject():EnableMotion(false)
    end

    local x = c(self, self:GetOwner())
    local y = math.Clamp(x.PhysicsBone, 0, 1)
    if IsValid(w) and u:IsRagdoll() then y = self.HPBone end
    if u:IsRagdoll() and IsValid(v:GetPhysicsObject()) and IsValid(w) then
        local z = ents.Create("phys_ragdollconstraint")
        self.Const = z
        z:SetPhysConstraintObjects(w, v:GetPhysicsObject())
        z:SetKeyValue("teleportfollowdistance", 1.0)
        local A = 180.0
        z:SetKeyValue("xmin", -A)
        z:SetKeyValue("xmax", A)
        z:SetKeyValue("ymin", -A)
        z:SetKeyValue("ymax", A)
        z:SetKeyValue("zmin", -A)
        z:SetKeyValue("zmax", A)
        local B = 15.0
        z:SetKeyValue("xfriction", B)
        z:SetKeyValue("yfriction", B)
        z:SetKeyValue("zfriction", B)
        z:SetPos(v:GetPos())
        z:Spawn()
        z:Activate()
    else
        self.Const = constraint.Weld(v, u, 0, y, 0, false)
    end
end

function SWEP:GetPullForce(u)
    if IsValid(u) and u:IsRagdoll() then
        return self.HL2PullForceRagdoll
    else
        return self.HL2PullForce
    end
end

function SWEP:GetMaxMass()
    return self.HL2MaxMass
end

function SWEP:GetMaxPuntRange()
    return self.HL2MaxPuntRange
end

function SWEP:GetMaxPickupRange()
    return self.HL2MaxPickupRange
end

function SWEP:GetMaxTargetHealth()
    return self.HL2MaxTargetHealth
end

if SERVER then
    function SWEP:MuzzleEffect()
    end

    function SWEP:CoreEffect()
        if not IsValid(self.Core) then
            self.Core = ents.Create("MegaPhyscannonCore")
            self.Core:SetPos(self:GetOwner():GetShootPos())
            self.Core:Spawn()
        end

        self.CoreAllowRemove = false
        if not IsValid(self.Core) then return end
        self.Core:SetParent(self:GetOwner())
        self.Core:SetOwner(self:GetOwner())
    end

    function SWEP:GlowEffect()
        self:SetGlow(true)
    end

    function SWEP:RemoveCore()
        if not self.Core then return end
        if not IsValid(self.Core) then return end
        self.CoreAllowRemove = true
        self.Core:Remove()
        self.Core = nil
    end

    function SWEP:RemoveGlow()
        self:SetGlow(false)
    end
end
