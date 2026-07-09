if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "???"
SWEP.Instructions = "I have no idea how to handle this."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/berserk/dragonslayer/dragonslayer.mdl"
SWEP.WorldModelReal = "models/swordtemp/c_kf2_katana.mdl"
SWEP.WorldModelExchange = "models/berserk/dragonslayer/dragonslayer.mdl"
SWEP.ViewModel = ""

SWEP.CanSuicide = false


SWEP.bloodID = 3

SWEP.NoHolster = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-7,1,-4)
SWEP.HoldAng = Angle(-2,0,-4)
SWEP.DeployHoldPosLow = Vector(-9, 1, -12)
SWEP.DeployHoldAngLow = Angle(6, 0, -6)
SWEP.DeployHoldTime = 1.1
SWEP.DeploySoundPitch = 70
SWEP.FirstEquipFXDuration = 2.4
SWEP.FirstEquipFXSound = "slayerevent/slayerequipzap.ogg"
SWEP.FirstEquipFXSoundDelay = 0.85
SWEP.FirstEquipFXSoundLevel = 140
SWEP.FirstEquipFXSoundPitch = 80
SWEP.FirstEquipFXGlowFadeTime = 0.25
SWEP.FirstEquipFXParticle = "[4]arcs_electric_1_small"
SWEP.FirstEquipFXParticleCount = 8
SWEP.FirstEquipFXParticleOffset = Vector(0, -1, 24)
SWEP.FirstEquipFXParticleRand = Vector(6, 3, 32)
SWEP.FirstEquipFXShakeAmplitude = 12
SWEP.FirstEquipFXShakeFrequency = 120
SWEP.FirstEquipFXShakeDuration = 1.1
SWEP.FirstEquipFXShakeRadius = 700
SWEP.FirstEquipFXBrightness = 0.18
SWEP.FirstEquipFXBrightnessRadius = 700

SWEP.AttackTime = 0.77
SWEP.AnimTime1 = 1.85
SWEP.WaitTime1 = 3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.15
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(1,2,-2)

SWEP.ViewPunchDiv = -50

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 46
SWEP.modelscale = 0.65


SWEP.weaponPos = Vector(0.6,-6,-12)
SWEP.weaponAng = Angle(-3,85,-5)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 500
SWEP.DamageSecondary = 3
SWEP.BleedMultiplier = 4
SWEP.PainMultiplier = 2

SWEP.PenetrationPrimary = 10
SWEP.PenetrationSecondary = 0

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 0

SWEP.StaminaPrimary = 45
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 100
SWEP.AttackLen2 = 35
SWEP.weight = 1.2

SWEP.BlockTier = 10
SWEP.MeleeMaterial = "metal"
SWEP.BlockImpactSound = "physics/metal/metal_solid_impact_bullet1.wav"

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "idle",
    ["attack"] = "swing_l",

}

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/zcity/machete.png")
	SWEP.IconOverride = "entities/zcity/machete.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "slayerevent/slayerhit1.ogg"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_impact_hard1.wav"
SWEP.DeploySnd = "slayerevent/slayerequip.ogg"
SWEP.HitFleshExtra = {
    "slayerevent/slayerhit1.ogg",
    "slayerevent/slayerhit2.ogg",
    "slayerevent/slayerhit3.ogg",
    "slayerevent/slayerhit4.ogg",
    "slayerevent/slayerhit5.ogg",
    "slayerevent/slayerhit6.ogg",
}
SWEP.HitFleshExtraPitch = 85
SWEP.SwingSound = "slayerevent/slayerswing.ogg"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:InitAdd()
    self.HoldPosBase = Vector(self.HoldPos.x, self.HoldPos.y, self.HoldPos.z)
    self.HoldAngBase = Angle(self.HoldAng.p, self.HoldAng.y, self.HoldAng.r)
end

function SWEP:OwnerChanged()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:PlayAnim("idle",10,true)
        self:SetHold(self.HoldType)
        timer.Simple(0,function()
            if IsValid(self) then
                self.picked = true
            end
        end)
    else
        self:SetInAttack(false)
        timer.Simple(0,function()
            if IsValid(self) then
                self.picked = nil
            end
        end)
    end
end

function SWEP:Deploy()
    if SERVER and self.Initialzed and not self:GetOwner().noSound then
        self:GetOwner():EmitSound(self.DeploySnd,65,self.DeploySoundPitch or 70)
    end
    self.Initialzed = true
    self.DeployHoldStart = CurTime()
    self:PlayAnim("idle",10,true)
    self:SetHold(self.HoldType)
    if SERVER and not self:GetNWBool("FirstEquipFXDone") then
        self:SetNWBool("FirstEquipFXDone", true)
        local fxDelay = self.FirstEquipFXSoundDelay or 0.85
        self:SetNWFloat("FirstEquipFXStart", CurTime() + fxDelay)
        timer.Simple(fxDelay, function()
            if IsValid(self) then
                self:EmitSound(self.FirstEquipFXSound or "slayerevent/slayerequipzap.ogg", self.FirstEquipFXSoundLevel or 140, self.FirstEquipFXSoundPitch or 80)
                local shakeDuration = self.FirstEquipFXDuration or 2.4
                util.ScreenShake(self:GetPos(), self.FirstEquipFXShakeAmplitude or 12, self.FirstEquipFXShakeFrequency or 120, shakeDuration, self.FirstEquipFXShakeRadius or 700)
            end
        end)
    end
	return true
end

function SWEP:Think()
    self:CustomThink()
    if not self.HoldPosBase or not self.HoldAngBase then return end
    if self.DeployHoldStart then
        local duration = self.DeployHoldTime or 1.1
        local t = math.Clamp((CurTime() - self.DeployHoldStart) / duration, 0, 1)
        if t < 1 then
            local eased = math.ease.InOutCubic(t)
            local pos = LerpVector(eased, self.DeployHoldPosLow or self.HoldPosBase, self.HoldPosBase)
            local ang = LerpAngle(eased, self.DeployHoldAngLow or self.HoldAngBase, self.HoldAngBase)
            local struggle = math.sin(t * math.pi * 6) * (1 - t) * 0.8
            pos.x = pos.x - struggle * 0.6
            pos.z = pos.z + struggle * 0.4
            ang.p = ang.p + struggle * 1.5
            ang.r = ang.r - struggle * 2
            self.HoldPos = pos
            self.HoldAng = ang
            return
        end
        self.DeployHoldStart = nil
    end
    self.HoldPos = self.HoldPosBase
    self.HoldAng = self.HoldAngBase
end

if CLIENT then
    local postprs = hg and hg.postprocess
    if postprs and postprs.LayerAdd and not postprs.layers["slayersword_zap"] then
        postprs.LayerAdd("slayersword_zap", {
            brightness = 0.18
        })
    end
    local glowMat = Material("models/debug/debugwhite")
    function SWEP:DrawPostWorldModel()
        local startTime = self:GetNWFloat("FirstEquipFXStart", 0)
        if startTime <= 0 then
            if postprs and postprs.LayerSetWeight then
                postprs.LayerSetWeight("slayersword_zap", 0)
            end
            return
        end
        local duration = self.FirstEquipFXDuration or 1.7
        local elapsed = CurTime() - startTime
        if elapsed < 0 then return end
        if elapsed > duration then
            if self.ZapPfxActive and IsValid(self.worldModel2) then
                self.worldModel2:StopParticles()
            end
            if self.ZapPfxAnchors then
                for i = 1, #self.ZapPfxAnchors do
                    local anchor = self.ZapPfxAnchors[i]
                    if IsValid(anchor) then
                        anchor:StopParticles()
                        anchor:Remove()
                    end
                end
            end
            self.ZapPfxActive = nil
            self.ZapPfxAnchors = nil
            self.ZapPfxAnchorOffsets = nil
            if postprs and postprs.LayerSetWeight then
                postprs.LayerSetWeight("slayersword_zap", 0)
            end
            return
        end
        if not IsValid(self.worldModel2) then return end
        if postprs and postprs.layers and postprs.layers["slayersword_zap"] then
            postprs.layers["slayersword_zap"].brightness = self.FirstEquipFXBrightness or 0.18
        end
        if self.LastFXStart ~= startTime then
            self.LastFXStart = startTime
            self.ZapPfxActive = nil
            if self.ZapPfxAnchors then
                for i = 1, #self.ZapPfxAnchors do
                    local anchor = self.ZapPfxAnchors[i]
                    if IsValid(anchor) then
                        anchor:StopParticles()
                        anchor:Remove()
                    end
                end
            end
            self.ZapPfxAnchors = nil
            self.ZapPfxAnchorOffsets = nil
        end
        if not self.ZapPfxAnchors then
            self.ZapPfxAnchors = {}
            self.ZapPfxAnchorOffsets = {}
            local count = self.FirstEquipFXParticleCount or 4
            local rand = self.FirstEquipFXParticleRand or vector_origin
            for i = 1, count do
                local anchor = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
                anchor:SetNoDraw(true)
                anchor:DrawShadow(false)
                self.ZapPfxAnchors[i] = anchor
                self.ZapPfxAnchorOffsets[i] = Vector(math.Rand(-rand.x, rand.x), math.Rand(-rand.y, rand.y), math.Rand(0, rand.z))
            end
        end
        local basePos = self.worldModel2:GetPos()
        local baseAng = self.worldModel2:GetAngles()
        local offset = self.FirstEquipFXParticleOffset or vector_origin
        for i = 1, #self.ZapPfxAnchors do
            local anchor = self.ZapPfxAnchors[i]
            if IsValid(anchor) then
                local randOffset = self.ZapPfxAnchorOffsets and self.ZapPfxAnchorOffsets[i] or vector_origin
                local worldOffset = LocalToWorld(offset + randOffset, angle_zero, basePos, baseAng)
                anchor:SetPos(worldOffset)
                anchor:SetAngles(baseAng)
            end
        end
        if not self.ZapPfxActive then
            self.ZapPfxActive = true
            for i = 1, #self.ZapPfxAnchors do
                local anchor = self.ZapPfxAnchors[i]
                if IsValid(anchor) then
                    ParticleEffectAttach(self.FirstEquipFXParticle or "[4]arcs_electric_1_small", 1, anchor, 1)
                end
            end
        end
        local fadeTime = self.FirstEquipFXGlowFadeTime or 0.25
        fadeTime = math.min(fadeTime, duration * 0.5)
        local intensity = elapsed < fadeTime and (elapsed / fadeTime) or ((duration - elapsed) / fadeTime)
        intensity = math.Clamp(intensity, 0, 1)
        if postprs and postprs.LayerSetWeight then
            local ply = LocalPlayer()
            local proximity = 0
            if IsValid(ply) then
                local dist = ply:EyePos():Distance(basePos)
                proximity = 1 - math.Clamp(dist / (self.FirstEquipFXBrightnessRadius or 700), 0, 1)
                if self:GetOwner() == ply then
                    proximity = math.max(proximity, 1)
                end
            end
            postprs.LayerSetWeight("slayersword_zap", proximity * intensity)
        end
        local flicker = 0.5 + 0.35 * math.sin(CurTime() * 75) + 0.15 * math.sin(CurTime() * 140 + 1.3)
        flicker = math.Clamp(flicker, 0, 1)
        local r = Lerp(flicker, 1, 0.35)
        local g = Lerp(flicker, 1, 0.7)
        local b = 1
        render.SuppressEngineLighting(true)
        render.MaterialOverride(glowMat)
        render.SetColorModulation(r, g, b)
        render.SetBlend(0.8 * intensity)
        self.worldModel2:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        render.MaterialOverride(nil)
        render.SuppressEngineLighting(false)
    end
end

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:CanPrimaryAttack()
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.05

SWEP.AttackRads = 65
SWEP.AttackRads2 = 35

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = true
SWEP.MultiDmg2 = false

function SWEP:SecondaryAttackAdd(ent, trace)
    if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then trace.Entity:SetVelocity(trace.Normal * 70 * (trace.Entity:IsNPC() and 35 or 5)) end
    local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone or 0)

    if IsValid(phys) then
        phys:ApplyForceOffset(trace.Normal * 42 * 100,trace.HitPos)
    end
end

SWEP.MinSensivity = 0.25
