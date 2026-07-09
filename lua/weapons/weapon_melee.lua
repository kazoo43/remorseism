if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Melee Base"
SWEP.Instructions = ""
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.WorldModel = "models/weapons/combatknife/tactical_knife_iw7_wm.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "knife"
SWEP.weight = 0.4

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:IsSprinting()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    if not owner.IsSprinting then return false end
    if owner:IsSprinting() and hg.GetCurrentCharacter(owner):IsPlayer() then return true end
end

function SWEP:CanSecondaryAttack()
    if self:GetClass() == "weapon_melee" then return false end
	return true
end

function SWEP:CanChargeAttack()
    return true
end

function SWEP:IsSecondaryAttackType(attacktype)
    return attacktype == true or attacktype == 2
end

function SWEP:IsChargeAttackType(attacktype)
    return attacktype == 3
end

function SWEP:GetAttackConfigValue(primary, secondary, charge, attacktype)
    if self:IsChargeAttackType(attacktype) then
        if charge ~= nil then
            return charge
        end

        return primary
    end

    if self:IsSecondaryAttackType(attacktype) then
        return secondary
    end

    return primary
end

function SWEP:GetAttackAnimToken(token, fallback)
    if self.AnimList and self.AnimList[token] then
        return token
    end

    return fallback
end

function SWEP:GetChargeFraction()
    return math.Clamp(((self.ChargeReleasedAt or CurTime()) - (self.ChargeStartedAt or CurTime())) / math.max(self.ChargeFullTime or 0.35, 0.001), 0, 1)
end

function SWEP:GetChargeDamageScale()
    return Lerp(self:GetChargeFraction(), 1, self.ChargeDamageMul or 1)
end

function SWEP:GetChargeBoneScale()
    return Lerp(self:GetChargeFraction(), 1, self.ChargeBreakBoneMul or 1)
end

function SWEP:GetAttackDamageBase(attacktype)
    local damage = self:GetAttackConfigValue(self.DamagePrimary, self.DamageSecondary, self.DamagePrimary, attacktype) or 0

    if self:IsChargeAttackType(attacktype) then
        damage = damage * (self.ReleasedChargeDamageMul or 1)
    end

    return damage
end

function SWEP:GetAttackHitSound(attacktype)
    return self:GetAttackConfigValue(self.AttackHit, self.Attack2Hit, self.ChargeAttackHit, attacktype)
end

function SWEP:GetAttackFleshHitSound(attacktype)
    return self:GetAttackConfigValue(self.AttackHitFlesh, self.Attack2HitFlesh, self.ChargeAttackHitFlesh, attacktype)
end

function SWEP:GetAttackSwingSound(attacktype)
    return self:GetAttackConfigValue(self.AttackSwing, self.AttackSwing, self.ChargeAttackSwing, attacktype)
end

SWEP.supportTPIK = true
SWEP.ismelee = true
SWEP.ismelee2 = true
SWEP.MaxOneHandedWeapons = 2

local function IsOneHandedMeleeWeapon(wep)
    if not IsValid(wep) then return false end
    if not wep.ismelee2 and wep.Base ~= "weapon_melee" then return false end
    return not wep.TwoHanded
end

local function GetOneHandedMeleeWeaponCount(owner, exclude)
    if not IsValid(owner) or not owner.GetWeapons then return 0 end

    local count = 0

    for _, wep in ipairs(owner:GetWeapons()) do
        if wep ~= exclude and IsOneHandedMeleeWeapon(wep) then
            count = count + 1
        end
    end

    return count
end

local function CanPickupOneHandedMeleeWeapon(owner, wep)
    if not IsOneHandedMeleeWeapon(wep) then return true end
    return GetOneHandedMeleeWeaponCount(owner, wep) < (wep.MaxOneHandedWeapons or 2)
end

local function EnforceOneHandedWeaponLimit(wep)
    if CLIENT then return end
    if not IsOneHandedMeleeWeapon(wep) then return end

    local owner = wep:GetOwner()

    if not IsValid(owner) or not owner:IsPlayer() then return end

    if CanPickupOneHandedMeleeWeapon(owner, wep) then return end

    timer.Simple(0, function()
        if not IsValid(wep) then return end

        local owner = wep:GetOwner()

        if not IsValid(owner) or not owner:IsPlayer() then return end
        if CanPickupOneHandedMeleeWeapon(owner, wep) then return end

        hg.drop(owner, wep)
    end)
end

function SWEP:PickupFunc(ply)
    if CanPickupOneHandedMeleeWeapon(ply, self) then return false end
    return true
end

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.5
SWEP.AttackLen1 = 55

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.6
SWEP.WaitTime2 = 0.4
SWEP.HitCooldownEnabled = false
SWEP.HitCooldown = 0.2
SWEP.AttackLen2 = 45

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 15
SWEP.DamageSecondary = 8
SWEP.ArteryChance = 1
SWEP.ComboEnabled = false
SWEP.ComboResetTime = 1.1
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65
SWEP.PlayerKnockbackMul = 1.55
SWEP.PlayerKnockbackUpMul = 0.45
SWEP.PlayerSecondaryKnockbackMul = 0.75
SWEP.SwingForwardBoostMinSpeed = 20
SWEP.RagdollHitForceMul = 0.5
SWEP.HeadTraceFallbackRadius = 10
SWEP.HeadRagdollChance = 0.55
SWEP.HeadRagdollForceMul = 1.35
SWEP.HeadRagdollUpMul = 1.2
SWEP.HeadRagdollMinDamage = 20

SWEP.PenetrationPrimary = 8
SWEP.PenetrationSecondary = 4

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 0.75
SWEP.PenetrationSizeSecondary = 2.5

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 8.5

SWEP.ViewPunch1 = Angle(2,0,0)
SWEP.ViewPunch2 = Angle(0,1,0)

SWEP.AttackSize = 5

SWEP.canchargeattack = false
SWEP.ChargeAnimTimeBegin = 0.2
SWEP.ChargeAnimTimeIdle = 0.35
SWEP.ChargeAnimTimeEnd = 0.8
SWEP.ChargeFullTime = 0.35
SWEP.ChargeAttackTime = 0.2
SWEP.ChargeWaitTime = 0.5
SWEP.ChargeAttackLen = 55
SWEP.ChargeAttackTimeLength = 0.15
SWEP.ChargeAttackRads = 45
SWEP.ChargeSwingAng = -90
SWEP.ChargeStamina = 10
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 0.75
SWEP.ChargeDamageMul = 1.5
SWEP.ChargeBreakBoneMul = 1.25
SWEP.ChargeMinStamina = 90
SWEP.ChargeTapCancelTime = 0.12
SWEP.ChargeHoldMinKeys = 1
SWEP.ChargeViewPunch = nil
SWEP.ChargeHoldPos = nil
SWEP.ChargeHoldAng = nil
SWEP.ChargeHoldLerpSpeed = 0.12

SWEP.weaponPos = Vector(2,0.1,-0.8)
SWEP.weaponAng = Angle(180,90,90)

SWEP.AnimList = {
    ["idle"] = "vm_knifeonly_idle",
    ["deploy"] = "vm_knifeonly_raise",
    ["attack"] = "vm_knifeonly_stab",
    ["attack2"] = "vm_knifeonly_swipe",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_iw7_tactical_knife")
	SWEP.IconOverride = "vgui/hud/tfa_iw7_tactical_knife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AttackSwing = "weapons/slam/throw.wav" --!! заменить звуки
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_slash.wav"
SWEP.DeploySnd = "snd_jack_hmcd_knifedraw.wav"
SWEP.swingsoundextra = nil
SWEP.hitsoundextra = nil
SWEP.hitsoundplus = nil
SWEP.hitsoundbrutalize = nil
SWEP.BrutalizeSkullThreshold = 0.99
SWEP.BrutalizeHitVolumeMul = 0.5
SWEP.BrutalizeExtraHitVolumeMul = 0.82

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.attack_ang = Angle(-55,-3,0)
SWEP.sprint_ang = Angle(30,0,0)

SWEP.HoldPos = Vector(-10,3,-2)
SWEP.HoldAng = Angle(-10,5,0)

SWEP.basebone = 1

SWEP.AttackPos = Vector(0,0,-10)
SWEP.AttackingPos = Vector(16,0,0)

SWEP.WorkWithFake = true

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
    self:SetHoldType(value)
    self.holdtype = value
end

function SWEP:KeyDown(key)
	return hg.KeyDown(self:GetOwner(),key)
end

function SWEP:InUse()
	local ply = self:GetOwner()

    if !IsValid(ply) then return false end
    
    local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local org = ply.organism
    
	local power = ply:GetNWFloat("power", 1)

	if power < 0.4 and ent != ply then
		return false
	end

	return ( ((not ply.InVehicle || !ply:InVehicle()) and !hg.RagdollCombatInUse(ply)) && self:KeyDown(IN_USE)) || ((ply.InVehicle && ply:InVehicle() or hg.RagdollCombatInUse(ply) or ent == ply) && not self:KeyDown(IN_USE)) || (IsValid(ply.OldRagdoll))
end

SWEP.modelscale = 1
SWEP.modelscale2 = 1
if CLIENT then
    function PrintBones( entity )
        for i = 0, entity:GetBoneCount() - 1 do
            print( i, entity:GetBoneName( i ) )
        end
    end

    function PrintAnims( entity )
        PrintTable(entity:GetSequenceList())
    end

	function SWEP:GetWM()
        if IsValid(self.worldModel) then
            return self.worldModel
        else
            self.worldModel = ClientsideModel(self.WorldModel)
            self.worldModel:SetNoDraw(true)
            self.worldModel:SetupBones()
            self:CallOnRemove("remove_worldmodel1",function()
                if IsValid(model) then
                    model:Remove()
                    model = nil
                end
            end)
        end
		return self.worldModel
	end

	local npcang = Angle(0, 0, 180)
    function SWEP:DrawWorldModel()
		local ent = self:GetOwner()
        if not IsValid(ent) then
            self:DrawWorldModel2()
        end
        
        if ent:IsNPC() then
			local RHand = ent:LookupBone("ValveBiped.Bip01_R_Hand")
			if not RHand then return end
			local matrixR = ent:GetBoneMatrix(RHand) or ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Forearm"))
			if not matrixR then 
				//matrixR = Matrix()
				//local att = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
				//matrixR:SetTranslation(att.Pos)
				//matrixR:SetAngles(att.Ang)
				return
			end

			matrixR:Rotate(npcang)

			if not IsValid(self.NPCworldModel) then
				self.NPCworldModel = ClientsideModel(self.WorldModelExchange and self.WorldModelExchange or self.WorldModel)
				self:CallOnRemove("remove_npcworldmodel1",function()
					if IsValid(self.NPCworldModel) then
						self.NPCworldModel:Remove()
						self.NPCworldModel = nil
					end
				end)
			end

			local WorldModel = self.NPCworldModel
			WorldModel:SetNoDraw(true)
			WorldModel:SetModelScale(self.modelscale2)
			WorldModel:SetRenderOrigin(matrixR:GetTranslation())
			WorldModel:SetRenderAngles(matrixR:GetAngles())
            WorldModel:SetPos(matrixR:GetTranslation())
            WorldModel:SetAngles(matrixR:GetAngles())
			WorldModel:SetupBones()
			WorldModel:DrawModel()
        end
    end

    SWEP.Current = 1

	function SWEP:DrawWorldModel2()
		local owner = self:GetOwner()
        
        if not IsValid(self.worldModel) then
            self.worldModel = self:GetWM()
        end
        
        self.worldModel:SetNoDraw(true)
        
        if IsValid(owner) and (not owner.shouldTransmit or owner.NotSeen) then return end
        if not IsValid(owner) and (not self.shouldTransmit or self.NotSeen) then return end

		local WorldModel = self.worldModel
        
        self.worldModel:SetModelScale(self.modelscale2)
        local ent = hg.GetCurrentCharacter(owner)

        local inuse = self:InUse()

        if IsValid(owner) then
            if not self.cycling then
                local dtime = SysTime() - (self.lasthuyhuy or SysTime())
                self.lasthuyhuy = SysTime()
                
                if self.stopanim and self.stopanim > 0 then
                    self.animtime = self.animtime + dtime * game.GetTimeScale()
                    self.stopanim = self.stopanim - dtime * game.GetTimeScale()
                else
                    self.stopanim = nil
                end

                local timing = (1 - math.Clamp((self.animtime - CurTime()) / self.animspeed, 0, 1))
                timing = self.reverseanim and (1 - timing) or timing
				timing = self.CustomTiming and self:CustomTiming() or timing
                
                WorldModel:SetCycle(timing)
                --PrintTable( WorldModel:GetSequenceList() )
                
                if self.callback and timing == ((not self.reverseanim) and 1 or 0) then
                    self.callback(self)
                    self.callback = nil
                end
            else
                local timing = ((CurTime() - (self.animtime - self.animspeed))%self.animspeed) / self.animspeed
                WorldModel:SetCycle(timing)
            end

            if WorldModel:GetModel() ~= self.WorldModelReal then WorldModel:SetModel(self.WorldModelReal) end
            
            local pos, ang = self:ModelAnim(WorldModel)

			WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
            WorldModel:SetPos(pos)
            WorldModel:SetAngles(ang)
		else
            if WorldModel:GetModel() ~= self.WorldModel then WorldModel:SetModel(self.WorldModel) end
			
            WorldModel:SetRenderOrigin(self:GetPos())
			WorldModel:SetRenderAngles(self:GetAngles())
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
		end

        WorldModel:SetupBones()
        
        if IsValid(owner) and !inuse then
            local bon = ent:LookupBone("ValveBiped.Bip01_R_Hand")
            if not bon then return end
            local mat = ent:GetBoneMatrix(bon)
            if not mat then return end

            local pos, ang = mat:GetTranslation(), mat:GetAngles()
            //local oldpos, oldang = WorldModel:GetPos(), WorldModel:GetAngles()

            //self.Current = LerpFT(0.1, self.Current,  and 1 or 0)
            
            //local pos = Lerp(self.Current, oldpos, pos)
            //local ang = Lerp(self.Current, oldang, ang)

            WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang) 
            WorldModel:SetPos(pos)
            WorldModel:SetAngles(ang)

            local bon = WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
            local matW = WorldModel:GetBoneMatrix(bon)

            if !matW then return end

            local invmat = mat * matW:GetInverse()

            for i = 0, WorldModel:GetBoneCount() - 1 do
                local mata = WorldModel:GetBoneMatrix(i)
                if !mata then continue end
                mata = invmat * mata
                WorldModel:SetBoneMatrix(i, mata)
            end
        end

        if not self.WorldModelExchange then
            WorldModel:DrawModel()
        end

        if IsValid(self.worldModel) and self.WorldModelExchange then
            if not IsValid(self.worldModel2) then
                self.worldModel2 = ClientsideModel(self.WorldModelExchange)
                self.worldModel2:SetNoDraw(true)
                self.worldModel2:SetupBones()
                local model = self.worldModel2

                self:CallOnRemove("remove_worldmodel2",function()
                    if IsValid(model) then
                        model:Remove()
                        model = nil
                    end
                end)
            end

            self.worldModel2:SetNoDraw(true)

            local pos,ang = self.worldModel:GetPos(),self.worldModel:GetAngles()
            local huy = self.worldModel:GetModel() == self.WorldModelReal
            
            if (IsValid(self:GetOwner()) or self.DontChangeDropped) then
                local mat = self.worldModel:GetBoneMatrix(self.basebone or 1)
                pos,ang = LocalToWorld(self.weaponPos,self.weaponAng,huy and mat and mat:GetTranslation() or self.worldModel:GetPos(),huy and mat and mat:GetAngles() or self.worldModel:GetAngles())
            end

            self.worldModel2:SetModelScale(self.modelscale)
            self.worldModel2:SetRenderOrigin(pos)
            self.worldModel2:SetRenderAngles(ang)
            self.worldModel2:SetPos(pos)
            self.worldModel2:SetAngles(ang)
            self.worldModel2:SetupBones()
            self.worldModel2:DrawModel()
        end
		
		if(self.DrawPostWorldModel)then
			self:DrawPostWorldModel()
		end

        if self:WaterLevel() > 0 then
            ClearDecalToEnt(IsValid(self.worldModel2) and self.worldModel2 or self.worldModel, self:EntIndex())
        end
	end
end

local addAng = Angle()
local addPos = Vector()

local vechuy = Vector()

local addPosLerp = Vector()
local addAngLerp = Angle()

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    return false
end

SWEP.BlockPushPos = Vector(0,0,0)
SWEP.BlockPushVel = Vector(0,0,0)
SWEP.BlockPushAng = Angle(0,0,0)
SWEP.BlockPushAngVel = Angle(0,0,0)

function SWEP:UpdateBlockHitShake()
    if not CLIENT then return end

    self.BlockPushPos = self.BlockPushPos or Vector(0,0,0)
    self.BlockPushVel = self.BlockPushVel or Vector(0,0,0)
    self.BlockPushAng = self.BlockPushAng or Angle(0,0,0)
    self.BlockPushAngVel = self.BlockPushAngVel or Angle(0,0,0)

    local dt = FrameTime()
    local stiffness = self.BlockHitShakeStiffness or 110
    local damping = self.BlockHitShakeDamping or 12
    local angStiffness = self.BlockHitShakeAngStiffness or stiffness
    local angDamping = self.BlockHitShakeAngDamping or damping

    self.BlockPushVel = self.BlockPushVel + self.BlockPushPos * (-stiffness * dt)
    self.BlockPushVel = self.BlockPushVel * math.max(0, 1 - damping * dt)
    self.BlockPushPos = self.BlockPushPos + self.BlockPushVel * dt

    self.BlockPushAngVel.p = self.BlockPushAngVel.p + self.BlockPushAng.p * (-angStiffness * dt)
    self.BlockPushAngVel.y = self.BlockPushAngVel.y + self.BlockPushAng.y * (-angStiffness * dt)
    self.BlockPushAngVel.r = self.BlockPushAngVel.r + self.BlockPushAng.r * (-angStiffness * dt)
    self.BlockPushAngVel.p = self.BlockPushAngVel.p * math.max(0, 1 - angDamping * dt)
    self.BlockPushAngVel.y = self.BlockPushAngVel.y * math.max(0, 1 - angDamping * dt)
    self.BlockPushAngVel.r = self.BlockPushAngVel.r * math.max(0, 1 - angDamping * dt)
    self.BlockPushAng.p = self.BlockPushAng.p + self.BlockPushAngVel.p * dt
    self.BlockPushAng.y = self.BlockPushAng.y + self.BlockPushAngVel.y * dt
    self.BlockPushAng.r = self.BlockPushAng.r + self.BlockPushAngVel.r * dt
end

function SWEP:AddBlockHitShake(state, normal)
    if not CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or owner ~= LocalPlayer() then return end

    local strength = state == "break" and (self.BlockHitShakeBreakMul or 2.1) or state == "parry" and (self.BlockHitShakeParryMul or 1.35) or (self.BlockHitShakeMul or 1)
    local posMul = self.BlockHitShakePosMul or 1
    local angMul = self.BlockHitShakeAngMul or 1
    self.BlockPushPos = self.BlockPushPos or Vector(0,0,0)
    self.BlockPushVel = self.BlockPushVel or Vector(0,0,0)
    self.BlockPushAng = self.BlockPushAng or Angle(0,0,0)
    self.BlockPushAngVel = self.BlockPushAngVel or Angle(0,0,0)
    local hitNormal = normal and normal:LengthSqr() > 0.001 and normal:GetNormalized() or owner:GetAimVector() * -1
    local eyeAng = owner:EyeAngles()
    local forward = eyeAng:Forward()
    local right = eyeAng:Right()
    local up = eyeAng:Up()
    local localX = hitNormal:Dot(forward)
    local localY = hitNormal:Dot(right)
    local localZ = hitNormal:Dot(up)

    self.BlockPushVel = self.BlockPushVel + Vector(-localX * 34 * posMul, -localY * 52 * posMul, math.abs(localZ) * 16 * posMul) * strength
    self.BlockPushAngVel.p = self.BlockPushAngVel.p + localY * 18 * angMul * strength
    self.BlockPushAngVel.y = self.BlockPushAngVel.y + -localX * 10 * angMul * strength
    self.BlockPushAngVel.r = self.BlockPushAngVel.r + -localY * 26 * angMul * strength
end

SWEP.SuicidePos = Vector(5, -24, 5)
SWEP.SuicideAng = Angle(0, 90, 20)
SWEP.SuicideCutVec = Vector(2, -5, 6)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5

SWEP.CanSuicide = false -- for weapon_melee its configured in Initialize

function SWEP:ModelAnim(model, pos, ang)
    local owner = self:GetOwner()

    if !IsValid(owner) or !owner:IsPlayer() then return end

    local ent = hg.GetCurrentCharacter(owner)
    local tr = hg.eyeTrace(owner, 40, ent)
    local eyeAng = owner:EyeAngles()

    local vel = ent:GetVelocity()
    local vellen = vel:Length()

    local vellenlerp = self.velocityAdd and self.velocityAdd:Length() or vellen

    if !tr then return end

    local dtime = SysTime() - (self.timetick2 or SysTime() + 0.015)

    self.walkLerped = LerpFT(0.1, self.walkLerped or 0, (owner:InVehicle()) and 0 or vellenlerp * 200)
	self.walkTime = self.walkTime or 0
    
	local walk = math.Clamp(self.walkLerped / 200, 0, 1)
	
	self.walkTime = self.walkTime + walk * dtime * 7 * game.GetTimeScale() * (owner:OnGround() and 1 or 0)
    
    self.velocityAdd = self.velocityAdd or Vector()
    self.velocityAddVel = self.velocityAddVel or Vector()

    //vel.z = vel.z + ((owner:IsFlagSet(FL_ANIMDUCKING) and !owner:IsFlagSet(FL_DUCKING)) and (100) or (!owner:IsFlagSet(FL_ANIMDUCKING) and owner:IsFlagSet(FL_DUCKING)) and (-100) or 0)
    self.velocityAddVel = LerpFT(0.9, self.velocityAddVel * 0.99, -vel * 0.01)
    self.velocityAddVel[3] = self.velocityAddVel[3]

    self.velocityAdd = LerpFT(0.03, self.velocityAdd, self.velocityAddVel)

	local huy = self.walkTime
	
	local x, y = math.cos(huy) * math.sin(huy) * walk + math.cos(CurTime() * 5) * walk * math.sin(CurTime() * 2) * 0.5, math.sin(huy) * walk * 1 + math.sin(CurTime() * 5) * walk * math.cos(CurTime() * 4) * 0.5
    
    addPos:Zero()
    addAng:Zero()
    addPosLerp:Zero()
    addAngLerp:Zero()

    addPosLerp.z = addPosLerp.z + ((hg.KeyDown(owner, IN_DUCK)) and -2 or 0)

    if !self:CustomBlockAnim(addPosLerp, addAngLerp) then
        addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -2 or 0)
        addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -4 or 0)
        addPosLerp.y = addPosLerp.y + (self:GetBlocking() and 8 or 0)
        addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -30 or 0)
    end

    if CLIENT then
        self:UpdateBlockHitShake()
        addPos:Add(self.BlockPushPos or vector_origin)
        addAng.p = addAng.p + (self.BlockPushAng and self.BlockPushAng.p or 0)
        addAng.y = addAng.y + (self.BlockPushAng and self.BlockPushAng.y or 0)
        addAng.r = addAng.r + (self.BlockPushAng and self.BlockPushAng.r or 0)
    end

    if owner:GetNWFloat("InLegKick",0) > CurTime() + 0.1 then
       addAngLerp.p = addAngLerp.p - math.min(math.abs(math.max(eyeAng.p,0)),25)
    end

    addPosLerp.x = addPosLerp.x - 20 * math.max(0.5 - tr.Fraction, 0)

    if self.CanSuicide and owner.suiciding then
        addPosLerp:Set(self.SuicidePos)
        addAngLerp:Set(self.SuicideAng)
    end

    self.lerpedAddPos = LerpFT(0.06, self.lerpedAddPos or Vector(), addPosLerp)
    self.lerpedAddAng = LerpFT(0.06, self.lerpedAddAng or Angle(), addAngLerp)

    if self:IsLocal() then
        addPos.z = x * 2 * vellenlerp * 0.3 - vellenlerp * 1
        addPos.y = y * 2 * vellenlerp * 0.3
    
        addAng.z = -x * 2// * vellenlerp * 0.3
        addAng.y = -y * 2// * vellenlerp * 0.3

        addPos.y = addPos.y - angle_difference.y * 2
        addAng.y = addAng.y + angle_difference.y * 4

        addPos.z = addPos.z + angle_difference.p * 2
        addAng.p = addAng.p + angle_difference.p * 4

        addAng.p = addAng.p + math.cos(CurTime() * 2) * 1

        //addPos.z = addPos.z + eyeAng[1] * 0.05
        addPos.x = addPos.x + eyeAng[1] * 0.05

        local veldot = self.velocityAdd:Dot(eyeAng:Right())
        
        addAng.r = addAng.r - veldot * 5 + math.cos(CurTime() * 5) * walk * 2 - angle_difference.y * 2

        //addAng.p = addAng.p + math.cos(CurTime() * 2) * 1
    end

    self.lastAddPos = addPos

    //local inattack1 = self:GetAttackType() == 1 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false
    //local inattack2 = self:GetAttackType() == 2 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false

    //self.attackanim = LerpFT(0.1, self.attackanim, (inattack1 and 0.8 or 0) - (inattack2 and 0.3 or 0))
    //self.sprintanim = LerpFT(0.05, self.sprintanim, self:IsSprinting() and 1 or 0)

    local chargeHoldTarget = ((self.Charging or (self:GetInAttack() and self:GetAttackType() == 3)) and 1) or 0
    self.chargeHoldLerp = LerpFT(self.ChargeHoldLerpSpeed or 0.12, self.chargeHoldLerp or 0, chargeHoldTarget)

    local hpos = LerpVector(self.chargeHoldLerp, self.HoldPos, self.ChargeHoldPos or self.HoldPos)
    local hang = LerpAngle(self.chargeHoldLerp, self.HoldAng, self.ChargeHoldAng or self.HoldAng)
    
    if self.SuicideStart and self.SuicideStart + self.SuicideTime > CurTime() then
        local animpos = (1 - math.Clamp((self.SuicideStart + self.SuicideTime - CurTime()) / self.SuicideTime, 0, 1))
        animpos = math.ease.OutElastic(animpos)
        
        addPos:Add(self.SuicideCutVec * animpos)
        addAng:Add(self.SuicideCutAng * animpos)
    end

    if self.cutthroat then
        local animpos = math.Clamp((self.cutthroat - CurTime() + 1) / 1, 0, 1)
        animpos = math.ease.InOutCubic(animpos)
        addPos:Add(self.SuicideCutVec * animpos)
        addAng:Add(self.SuicideCutAng * animpos)
    end

    local pos, ang = LocalToWorld(hpos + addPos + self.lerpedAddPos, hang + addAng + self.lerpedAddAng, tr.StartPos + self.velocityAdd, eyeAng)

	self.timetick2 = SysTime()

    if self.ModelAnimAdd then
        return self:ModelAnimAdd(model,pos,ang)
    end

    return pos, ang
end

SWEP.KickAng = Angle(0,0,0)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"

--hook.Add("PostDrawPlayerRagdoll","ragdollhuymelee",function(ent,ply)
function hg.RenderMelees(ent, ply, wep)
    if wep.DrawWorldModel2 then
        wep:DrawWorldModel2()
    else
        wep:DrawWorldModel()
    end
end
--end)

local host_timescale = game.GetTimeScale

function SWEP:Camera(eyePos, eyeAng, view, vellen)
    //self:SetHandPos()
    self:DrawWorldModel2()

    local WorldModel = self.worldModel

    if not IsValid(WorldModel) then return end

    local camBone = (WorldModel:LookupBone(self.FakeViewBobBone) or (self.FakeVPShouldUseHand and WorldModel:LookupBone("ValveBiped.Bip01_R_Hand") or WorldModel:LookupBone("Weapon"))) or WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
    
    if camBone then
        local matrix = WorldModel:GetBoneMatrix(camBone)

        if matrix then
            local gAngles = matrix:GetAngles()
            local _,gAngles = WorldToLocal(vector_origin, gAngles, eyePos, eyeAng)
            self.OldAngPunch = self.OldAngPunch or gAngles
            local punch = ( self.OldAngPunch - gAngles ) / (self.ViewPunchDiv or 120)
            
            self.punch = punch

            //ViewPunch2( -punch )
            ViewPunch( punch )
            
            self.OldAngPunch = gAngles
        end
    end

    local owner = self:GetOwner()
    if not owner.InVehicle then return end

    view.origin = eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5)
    view.angles = eyeAng
    
    local lpos = self.lastAddPos or vector_origin
    //view.angles[1] = view.angles[1] + lpos.z * 1
    //view.angles[2] = view.angles[2] + lpos.y * 1
    
    return view
end

local ang180, ang1 = Angle(0,180,0), Angle(-135,-90,0)
function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()
	local owner = self:GetOwner()

    self.rhandik = false
	self.lhandik = false
    
    if not IsValid(ply) or not IsValid(self.worldModel) then return end
    if not ply.shouldTransmit or ply.NotSeen then return end

    local ent = hg.GetCurrentCharacter(ply)

	local bones = hg.TPIKBonesLH

    local ply_spine_index = ent:LookupBone("ValveBiped.Bip01_Spine4")
    if !ply_spine_index then return end
    local ply_spine_matrix = ent:GetBoneMatrix(ply_spine_index)
    if !ply_spine_matrix then return end
    local wmpos = ply_spine_matrix:GetTranslation()

	local wm = self:GetWM()
	if !IsValid(wm) then return end
	-- ent:SetupBones()

	self.rhandik = self.setrh and IsValid(owner)//self.setrh
	self.lhandik = self.setlh and IsValid(owner) and (ply:GetTable().ChatGestureWeight < 0.1) and hg.CanUseLeftHand(ply) and !(owner.suiciding and self.SuicideNoLH)

    local rhmat, lhmat = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand")), ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Hand"))

	ply.rhold = rhmat
	ply.lhold = lhmat

	if self.lhandik and self:InUse() then
		for _, bone in ipairs(bones) do
			local wm_boneindex = wm:LookupBone(bone)
			if !wm_boneindex then continue end
			local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
			if !wm_bonematrix then continue end
			
			local ply_boneindex = ent:LookupBone(bone)
			if !ply_boneindex then continue end
			local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
			if !ply_bonematrix then continue end

			local bonepos = wm_bonematrix:GetTranslation()
			local boneang = wm_bonematrix:GetAngles()

			bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38)
			bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
			bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

			ply_bonematrix:SetTranslation(bonepos)
			ply_bonematrix:SetAngles(boneang)
			
            --if bone == "ValveBiped.Bip01_L_Hand" then lhmat = ply_bonematrix end
			ent:SetBoneMatrix(ply_boneindex, ply_bonematrix)
			--ent:SetBonePosition(ply_boneindex, bonepos, boneang)
		end
    else
        if ply == ent then
            local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
            if !ply_spine_index then return end
            local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
            local wmpos = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * 5

            local tr = {}
            tr.start = wmpos
            tr.endpos = wmpos + ply:GetAimVector() * 30
            tr.filter = ply

            local trace = util.TraceLine(tr)

            if trace.Hit then
                hg.DragLeftHand(ply, self, trace.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace.Entity:IsWorld() and Lerp(1, trace.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang1 - ply:EyeAngles())
            end
        end
    end

	local bones = hg.TPIKBonesRH

	if self.rhandik and self:InUse() then
		for _, bone in ipairs(bones) do
			local wm_boneindex = wm:LookupBone(bone)
			if !wm_boneindex then continue end
			local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
			if !wm_bonematrix then continue end
			
			local ply_boneindex = ent:LookupBone(bone)
			if !ply_boneindex then continue end
			local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
			if !ply_bonematrix then continue end

			local bonepos = wm_bonematrix:GetTranslation()
			local boneang = wm_bonematrix:GetAngles()

			bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38)
			bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
			bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

			ply_bonematrix:SetTranslation(bonepos)
			ply_bonematrix:SetAngles(boneang)

            --if bone == "ValveBiped.Bip01_R_Hand" then rhmat = ply_bonematrix end
            ent:SetBoneMatrix(ply_boneindex, ply_bonematrix)
			--ent:SetBonePosition(ply_boneindex, bonepos, boneang)
		end
	end

    --return rhmat,lhmat
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Blocking")
	self:NetworkVar("Float", 1, "LastBlocked")
	self:NetworkVar("Float", 2, "StartedBlocking")
    self:NetworkVar("Float", 3, "AttackWait")
    self:NetworkVar("Float", 4, "LastAttack")
    self:NetworkVar("Int", 5, "AttackType")
	self:NetworkVar("Bool", 6, "InAttack")
    self:NetworkVar("Float", 7, "AttackLength")
    self:NetworkVar("Float", 8, "AttackTime")
    self:NetworkVar("Float", 9, "BlockDisabledUntil")
end

function SWEP:OwnerChanged()
    self:CancelChargeAttack(false)
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:PlayAnim("deploy",0.5,false,nil,false)
        self:SetHold(self.HoldType)
        self:ResetCombo()
        EnforceOneHandedWeaponLimit(self)
        timer.Simple(0,function() self.picked = true end)
    else
        if self.SetInAttack then
            self:SetInAttack(false)
        else
            self.inattack = false
        end
        self:ResetCombo()
        timer.Simple(0,function() self.picked = nil end)
    end
end

function SWEP:OnRemove()
    self:CancelChargeAttack(false)
    if CLIENT then
        timer.Remove("hg_melee_hitstop_" .. self:EntIndex())
    end
    if IsValid(self.worldModel) then
        self.worldModel:Remove()
    end
end
SWEP.Initialzed = false
function SWEP:Deploy()
    if SERVER and self.Initialzed and not self:GetOwner().noSound then self:GetOwner():EmitSound(self.DeploySnd,65) end
    self.Initialzed = true
    self:CancelChargeAttack(false)
    self:ResetCombo()
    self:PlayAnim("deploy", 1, false, nil, false)
    self:SetHold(self.HoldType)
	
	return true
end

function SWEP:Holster(wep)
    self:CancelChargeAttack(false)
    self:SetInAttack(false)
    self:ResetCombo()
    return true
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

function SWEP:IsHitCooldownTarget(ent)
    return IsValid(ent) and (ent:IsPlayer() or ent:IsRagdoll() or IsValid(hg.RagdollOwner(ent)))
end

function SWEP:ApplyHitCooldown()
    if not self.HitCooldownEnabled then return end
    if self.HitCooldown == nil then return end
    local owner = self:GetOwner()
    local mul = 1
    if IsValid(owner) and owner.organism then
        mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)
    end
    self:SetAttackWait(self.HitCooldown / mul)
    self.attackwait = self.HitCooldown / mul
end

function SWEP:ClearChargeState()
    self.Charging = nil
    self.ChargeIdleLooping = nil
    self.ChargeStartedAt = nil
    self.ChargeReleasedAt = nil
    self.ReleasedChargeDamageMul = nil
    self.ReleasedChargeBoneMul = nil
    self.ChargeStaminaMul = nil
end

function SWEP:CancelChargeAttack(playIdle)
    if not self.Charging and self.ReleasedChargeDamageMul == nil and self.ReleasedChargeBoneMul == nil then return end

    self:ClearChargeState()

    if playIdle then
        self:PlayAnim("idle", 10, true)
    end
end

function SWEP:StartChargeAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self.Charging then return end
    if not owner.organism or owner.organism.stamina[1] < (self.ChargeMinStamina or 90) then return end

    local mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)

    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.HitWorld = false
    self.ComboAppliedThisAttack = nil
    self.Charging = true
    self.ChargeIdleLooping = false
    self.ChargeStartedAt = CurTime()
    self.ChargeReleasedAt = nil
    self.ReleasedChargeDamageMul = nil
    self.ReleasedChargeBoneMul = nil
    self.ChargeStaminaMul = mul

    self:PlayAnim(self:GetAttackAnimToken("charge_begin", "Attack_Charge_Begin"), (self.ChargeAnimTimeBegin or 0.2) / mul, false, nil, false, false)
end

function SWEP:ReleaseChargeAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:CancelChargeAttack(false)
        return
    end

    if not self.Charging then return end

    local mul = self.ChargeStaminaMul or (1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2))

    self.ChargeReleasedAt = CurTime()
    self.ReleasedChargeDamageMul = self:GetChargeDamageScale()
    self.ReleasedChargeBoneMul = self:GetChargeBoneScale()
    self.Charging = nil
    self.ChargeIdleLooping = nil
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.HitWorld = false
    self.ComboAppliedThisAttack = nil
    self:PlayAnim(self:GetAttackAnimToken("charge_end", "Attack_Charge_End"), (self.ChargeAnimTimeEnd or self.AnimTime1 or 1) / mul, false, nil, false, false)
    self:SetAttackType(3)
    self:SetLastAttack(CurTime() + (self.ChargeAttackTime or self.AttackTime) / mul)
    self:SetAttackTime(self:GetLastAttack() + ((self.ChargeAttackTimeLength or self.AttackTimeLength) / mul))
    self:SetAttackLength(self.ChargeAttackLen or self.AttackLen1)
    self:SetAttackWait((self.ChargeWaitTime or self.WaitTime1) / mul)
    self:SetInAttack(true)
    self.lastattack = CurTime() + (self.ChargeAttackTime or self.AttackTime) / mul
    self.attackwait = (self.ChargeWaitTime or self.WaitTime1) / mul

    if CLIENT and not self:IsLocal() and owner.AnimRestartGesture then
        owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
    end

    self.viewpunch = true
end

function SWEP:ThinkAdd()
end

function SWEP:Think()
    self:CustomThink()
end

if CLIENT then
    local sensitivity = 1

    function SWEP:AdjustMouseSensitivity()
        local owner = self:GetOwner()
        local ent = hg.GetCurrentCharacter(owner)

        local time = math.max(self:GetLastAttack() - CurTime(),0)

        local inattack1 = time / self.AttackTimeLength
        local inattack2 = time / self.Attack2TimeLength
        local inattack3 = time / (self.ChargeAttackTimeLength or self.AttackTimeLength)
        local mul = self:GetAttackType() == 1 and inattack1 or self:GetAttackType() == 3 and inattack3 or inattack2

        mul = math.max( (math.max(math.min(mul,self.MinSensivity or 0.35),0)) - (self.MinSensivity/10) ,0 )
        mul = 1-(mul)
		if wep.GetBlocking and wep:GetBlocking() then
			mul = math.Clamp(mul * 0.35, 0.2, 1)
		end

        sensitivity = math.min(sensitivity, mul)
        sensitivity = LerpFT(0.02, sensitivity, mul)
        
        return IsValid(ent) and ent:IsPlayer() and sensitivity
    end

end

function SWEP:MultiplyDMG(owner, ent, vellen, mul)
    mul = mul * 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90,1,1.3)
    mul = mul * math.Clamp(vellen / 250, 0.9, 1.25)
    mul = mul * (ent ~= owner and 0.75 or 1)
    mul = mul * (owner.MeleeDamageMul or 1)

    if owner.organism.superfighter then
        mul = mul * 5
    end

    if owner:IsBerserk() then
        mul = mul * (1 + owner.organism.berserk)
    end

    return mul
end

function SWEP:ResetCombo()
    self.ComboCount = 0
    self.ComboExpire = 0
    self.ComboAppliedThisAttack = nil
end

function SWEP:GetComboDamageMul()
    if (self.ComboExpire or 0) < CurTime() then
        self.ComboCount = 0
    end

    local step = math.Clamp((self.ComboCount or 0) + 1, 1, 3)

    if step == 2 then
        return self.ComboDamageMul2 or 1, step
    elseif step == 3 then
        return self.ComboDamageMul3 or 1, step
    end

    return self.ComboDamageMul1 or 1, step
end

function SWEP:ApplyComboDamage(dmg)
    if not self.ComboEnabled then
        return dmg
    end

    if self.ComboAppliedThisAttack then
        return dmg
    end

    local mul, step = self:GetComboDamageMul()
    self.ComboCount = step >= 3 and 0 or step
    self.ComboExpire = step >= 3 and 0 or (CurTime() + (self.ComboResetTime or 1.1))
    self.ComboAppliedThisAttack = true

    return dmg * mul
end

function SWEP:GetConfiguredHitSoundPitch(pitch)
    if istable(pitch) then
        local pitchMin = pitch.min or pitch[1] or 100
        local pitchMax = pitch.max or pitch[2] or pitchMin
        return math.random(pitchMin, pitchMax)
    end

    return pitch or 100
end

function SWEP:EmitConfiguredHitSound(owner, data, volumeMul)
    if not IsValid(owner) then return end

    if isstring(data) then
        owner:EmitSound(data, 50 * (volumeMul or 1), 100)
        return
    end

    if not istable(data) then return end

    local snd = data.sound or data.path or data[1]
    if not isstring(snd) then return end

    local volume = (data.volume or data.vol or data[2] or 50) * (volumeMul or 1)
    local pitch = self:GetConfiguredHitSoundPitch(data.pitch or data[3])

    owner:EmitSound(snd, volume, pitch)
end

function SWEP:EmitConfiguredHitSoundLayer(owner, layer, volumeMul)
    if isstring(layer) then
        self:EmitConfiguredHitSound(owner, layer, volumeMul)
        return
    end

    if not istable(layer) then return end

    local snd = layer.sound or layer.path or layer[1]
    if isstring(snd) and (layer.sound or layer.path or not istable(layer[1])) then
        self:EmitConfiguredHitSound(owner, layer, volumeMul)
        return
    end

    for _, data in ipairs(layer) do
        self:EmitConfiguredHitSoundLayer(owner, data, volumeMul)
    end
end

function SWEP:EmitConfiguredHitSoundChoice(owner, layer, volumeMul)
    self:EmitConfiguredHitSound(owner, self:GetRandomConfiguredHitSound(layer), volumeMul)
end

function SWEP:GetRandomConfiguredHitSound(layer)
    if isstring(layer) then return layer end
    if not istable(layer) then return nil end

    local snd = layer.sound or layer.path or layer[1]
    if isstring(snd) and (layer.sound or layer.path or not istable(layer[1])) then
        return layer
    end

    local count = #layer
    if count <= 0 then return nil end

    return self:GetRandomConfiguredHitSound(layer[math.random(count)])
end

function SWEP:PlayExtraHitSounds(owner, volumeMul)
    self:EmitConfiguredHitSoundChoice(owner, self.hitsoundextra, volumeMul)
    self:EmitConfiguredHitSoundChoice(owner, self.hitsoundplus, volumeMul)
end

function SWEP:PlaySwingSound(owner, attacktype)
    if self:IsChargeAttackType(attacktype) and self.ChargeSwingSoundExtra ~= nil then
        self:EmitConfiguredHitSoundLayer(owner, self.ChargeSwingSoundExtra)
        return
    end

    if self.swingsoundextra ~= nil then
        self:EmitConfiguredHitSoundLayer(owner, self.swingsoundextra)
        return
    end

    owner:EmitSound(self:GetAttackSwingSound(attacktype) or "weapons/slam/throw.wav", 50, math.random(95,105))
end

function SWEP:PrecacheConfiguredHitSoundLayer(layer)
    if isstring(layer) then
        util.PrecacheSound(layer)
        return
    end

    if not istable(layer) then return end

    local snd = layer.sound or layer.path or layer[1]
    if isstring(snd) and (layer.sound or layer.path or not istable(layer[1])) then
        util.PrecacheSound(snd)
        return
    end

    for _, data in ipairs(layer) do
        self:PrecacheConfiguredHitSoundLayer(data)
    end
end

function SWEP:GetHitVictim(ent)
    return hg.RagdollOwner(ent) or ent
end

function SWEP:IsHeadHit(ent, trace)
    local victim = self:GetHitVictim(ent)
    return self:IsHeadTrace(trace and trace.Entity, trace) or self:IsHeadTrace(victim, trace)
end

function SWEP:IsHeadTrace(ent, trace)
    if not trace then return false end
    if trace.HitGroup == HITGROUP_HEAD then return true end
    if not IsValid(ent) then return false end

    local headBone = ent.LookupBone and ent:LookupBone("ValveBiped.Bip01_Head1")
    if not headBone then return false end

    if trace.PhysicsBone ~= nil and ent.TranslateBoneToPhysBone and ent.TranslatePhysBoneToBone then
        local headPhys = ent:TranslateBoneToPhysBone(headBone)
        if headPhys ~= nil and headPhys >= 0 and trace.PhysicsBone == headPhys then
            return true
        end

        local bone = ent:TranslatePhysBoneToBone(trace.PhysicsBone)
        if bone and bone >= 0 and ent:GetBoneName(bone) == "ValveBiped.Bip01_Head1" then
            return true
        end
    end

    if trace.HitBoxBone ~= nil and ent.GetBoneName and ent:GetBoneName(trace.HitBoxBone) == "ValveBiped.Bip01_Head1" then
        return true
    end

    if trace.HitPos then
        local headMatrix = ent.GetBoneMatrix and ent:GetBoneMatrix(headBone)
        local headPos = headMatrix and headMatrix:GetTranslation() or ent.GetBonePosition and select(1, ent:GetBonePosition(headBone))
        if headPos and headPos ~= vector_origin then
            local radius = self.HeadTraceFallbackRadius or 10
            if headPos:DistToSqr(trace.HitPos) <= (radius * radius) then
                return true
            end
        end
    end

    return false
end

function SWEP:IsLegHitGroup(hitGroup)
    return hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG
end

function SWEP:IsLegTrace(ent, trace)
    if not trace then return false end
    if self:IsLegHitGroup(trace.HitGroup) then return true end
    if not IsValid(ent) then return false end

    if trace.PhysicsBone ~= nil and ent.TranslatePhysBoneToBone and ent.GetBoneName then
        local bone = ent:TranslatePhysBoneToBone(trace.PhysicsBone)
        if bone and bone >= 0 then
            local hitGroup = hg.bonetohitgroup and hg.bonetohitgroup[ent:GetBoneName(bone)]
            if self:IsLegHitGroup(hitGroup) then
                return true
            end
        end
    end

    if trace.HitBoxBone ~= nil and ent.GetBoneName then
        local hitGroup = hg.bonetohitgroup and hg.bonetohitgroup[ent:GetBoneName(trace.HitBoxBone)]
        if self:IsLegHitGroup(hitGroup) then
            return true
        end
    end

    return false
end

function SWEP:ShouldHeadRagdoll(ent, trace)
    local victim = self:GetHitVictim(ent)
    local damageThreshold = self.HeadRagdollMinDamage or 20
    local weaponDamage = math.max(self.DamagePrimary or 0, self.DamageSecondary or 0)
    if not IsValid(victim) or not victim:IsPlayer() then return false end
    if not victim:Alive() or IsValid(victim.FakeRagdoll) then return false end
    if trace and trace.HGPreventHeadRagdoll then return false end
    if weaponDamage <= damageThreshold then return false end
    if not self:IsHeadHit(ent, trace) then return false end
    return math.Rand(0, 1) <= (self.HeadRagdollChance or 0.85)
end

function SWEP:ShouldPlayBrutalizeHitSound(ent, victim, trace, attacktype)
    if self:IsSecondaryAttackType(attacktype) then return false end
    if not istable(self.hitsoundbrutalize) then return false end
    if not self:GetRandomConfiguredHitSound(self.hitsoundbrutalize) then return false end
    if not IsValid(victim) or not victim.organism then return false end
    if (victim.organism.skull or 0) < (self.BrutalizeSkullThreshold or 0.99) then return false end

    local hitEnt = IsValid(ent) and ent or trace and trace.Entity
    if IsValid(hitEnt) then
        if hitEnt:IsRagdoll() and trace and trace.PhysicsBone ~= nil and hitEnt.TranslatePhysBoneToBone and hitEnt.GetBoneName then
            local bone = hitEnt:TranslatePhysBoneToBone(trace.PhysicsBone)
            if bone and bone >= 0 then
                return hg.bonetohitgroup and hg.bonetohitgroup[hitEnt:GetBoneName(bone)] == HITGROUP_HEAD
            end
            return false
        end

        return self:IsHeadTrace(hitEnt, trace)
    end

    return self:IsHeadTrace(victim, trace)
end

function SWEP:PlaySoftHitSounds(owner, ent, trace, attacktype)
    if not IsValid(owner) then return end
    if not IsValid(ent) then return end
    if not self:IsEntSoft(ent) then return end
    if self.SoftHitPlayed then return end

    self.SoftHitPlayed = true

    local victim = self:GetHitVictim(ent)
    local brutalize = self:ShouldPlayBrutalizeHitSound(ent, victim, trace, attacktype)
    local volumeMul = brutalize and (self.BrutalizeHitVolumeMul or 0.5) or 1
    local extraVolumeMul = brutalize and (self.BrutalizeExtraHitVolumeMul or volumeMul) or 1

    owner:EmitSound(self:GetAttackFleshHitSound(attacktype), 50 * volumeMul)

    if not self:IsSecondaryAttackType(attacktype) then
        self:PlayExtraHitSounds(owner, extraVolumeMul)
    end

    if brutalize then
        self:EmitConfiguredHitSoundChoice(owner, self.hitsoundbrutalize)
    end
end

local ShouldDrawMeleeAttackHull
local DrawMeleeAttackHull

function SWEP:Attack(owner, ent, vellen, attacktype, inattackLength)
    //if SERVER then owner:SetNetVar("slowDown", owner:GetNetVar("slowDown", 0) + (attacktype and self.DamageSecondary or self.DamagePrimary)) end
    local secondary = self:IsSecondaryAttackType(attacktype)
    local charge = self:IsChargeAttackType(attacktype)
    
    if not self.FirstAttackTick then 
        if CLIENT then
            if owner == lply and self.viewpunch then
                ViewPunch(self:GetAttackConfigValue(self.ViewPunch1, self.ViewPunch2, self.ChargeViewPunch, attacktype) or self.ViewPunch1)
                self.viewpunch = nil
            end
        else
            self.Penetration = self:GetAttackConfigValue(self.PenetrationPrimary, self.PenetrationSecondary, self.ChargePenetration, attacktype)
            self.PenetrationSize = self:GetAttackConfigValue(self.PenetrationSizePrimary, self.PenetrationSizeSecondary, self.ChargePenetrationSize, attacktype)
            
            self:PlaySwingSound(owner, attacktype)
            
            if owner.organism then
                owner.organism.stamina.subadd = owner.organism.stamina.subadd + self:GetAttackConfigValue(self.StaminaPrimary, self.StaminaSecondary, self.ChargeStamina, attacktype) * 0.5 * math.Clamp(vellen / 200, 1, 1.25)
            end

            if charge then
                if self.CustomChargeAttack and self:CustomChargeAttack() then
                    self:SetInAttack(false)

                    return
                end
            elseif !secondary then
                if self.CustomAttack and self:CustomAttack() then
                    self:SetInAttack(false)

                    return
                end
            else
                if self.CustomAttack2 and self:CustomAttack2() then
                    self:SetInAttack(false)

                    return
                end
            end
        end
    end
    
    self.HitEnts = self.HitEnts or {owner, ent}
    
    local vellen = math.min(owner:GetVelocity():Length() * 0.05, 40)
    local eyetr = hg.eyeTrace(owner, (self:GetAttackLength() + vellen), ent, owner:GetAimVector())
    local shouldDrawHull = ShouldDrawMeleeAttackHull(owner)
    //debugoverlay.Line(eyetr.StartPos, eyetr.StartPos + eyetr.Normal * (self:GetAttackLength() + vellen), 3, color_white)
    //local ent = ents.Create("prop_physics")
    //ent:SetModel("models/props_interiors/pot01a.mdl")
    //ent:SetPos(eyetr.HitPos)
    //ent:Spawn()
    //ent:SetMoveType(MOVETYPE_NONE)
    //ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    --if self:IsEntSoft(eyetr.Entity) then return eyetr end
    
    local trace

    local amt = 6

    for i = 0, amt do
        local normal = eyetr.Normal:Angle()

        normal:RotateAroundAxis(normal:Forward(), self:GetAttackConfigValue(self.SwingAng, self.SwingAng2, self.ChargeSwingAng, attacktype) or -90)
        normal:RotateAroundAxis(normal:Up(), ((0.5 - inattackLength) * (self:GetAttackConfigValue(self.AttackRads, self.AttackRads2, self.ChargeAttackRads, attacktype) or 65)))
        normal:RotateAroundAxis(normal:Up(), (i - amt * 0.5) * 1)
        
        --debugoverlay.Line(eyetr.StartPos, eyetr.StartPos + normal:Forward() * (self:GetAttackLength() + vellen), 3, color_white)

        local tr = {}

        tr.start = eyetr.StartPos
        tr.endpos = eyetr.StartPos + normal:Forward() * (secondary and 1 or math.max(0.5, 1 - math.abs((0.5 - inattackLength) * 2))) * (self:GetAttackLength() + vellen)
        tr.filter = (secondary and self.MultiDmg2 or charge and self.MultiDmgCharge or self.MultiDmg1) and {owner, ent} or self.HitEnts

        local size = 0.15

        tr.mins = -Vector(size, size, size)
        tr.maxs = Vector(size, size, size)

        local clashTrace = self:FindMeleeClash(owner, ent, attacktype, inattackLength, tr)

        if clashTrace then
            return clashTrace
        end

        trace = util.TraceLine(tr)

        if shouldDrawHull then
            DrawMeleeAttackHull(tr, trace)
        end

        //if SERVER then
        //    local vec = trace.Normal * math.min(self.DamagePrimary * 0.5, 20)
        //    vec[3] = 0
    //
        //    owner:SetVelocity(vec)
        //end

        if self:IsEntSoft(trace.Entity) then
			break
		end
    end

    return trace
end

local bluntDecals, bluntDecalsRand = {}, 1
for i = 1, 4 do
	local mat = "decals/zcity/blunt_impact" .. i
	table.insert(bluntDecals, mat)
	game.AddDecal("Impact.BluntAdd" .. i, mat)

	list.Add("PaintMaterials", "Impact.BluntAdd" .. i)
	bluntDecalsRand = i
end

function SWEP:PlayEffects(trace, attacktype)
    local owner = self:GetOwner()
    
    if self:IsEntSoft(trace.Entity) then
        if self.DamageType == DMG_SLASH then
            util.Decal( "Blood", trace.HitPos + trace.HitNormal * 15, trace.HitPos - trace.HitNormal * 15, owner )
            util.Decal( "Blood", trace.HitPos + trace.HitNormal * 2, owner:GetPos(), trace.Entity )
        end
    elseif not self.AttackHitPlayed then
        self.AttackHitPlayed = true

        owner:EmitSound(self:GetAttackHitSound(attacktype), 50)

		if self.weight >= 1.5 and self.DamageType ~= DMG_SLASH and trace.MatType ~= MAT_GLASS and not self:IsSecondaryAttackType(attacktype) then
			util.Decal("Impact.BluntAdd" .. math.random(bluntDecalsRand), trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, owner)
			owner:ScreenShake(trace.HitPos, self.HitScreenShakeAmp or 22, self.HitScreenShakeFreq or 6, self.HitScreenShakeDur or 0.28, self.HitScreenShakeRadius or 110, false)
		end
    end
end

function SWEP:BreakGlass(ent)
	if not IsValid(ent) then return end
    if string.find(ent:GetClass(),"break") and ent:GetBrushSurfaces()[1] and string.find(ent:GetBrushSurfaces()[1]:GetMaterial():GetName(),"glass") then
        //ent:EmitSound("physics/glass/glass_sheet_impact_hard"..math.random(3)..".wav")
        
        if math.random(1, 4) == 4 and ent:Health() < 250 then
            //ent:Fire("Break")
        end
        
        return true
    else
        return false
    end
end

function SWEP:BehindAttack(ent)
    local owner = self:GetOwner()

    return self:IsEntSoft(ent) and ent:IsPlayer() and IsValid(owner) and (owner:GetAimVector():Dot(ent:GetAimVector()) > math.cos(math.rad(45)))
end

function SWEP:PunchPlayer(ent, attacktype, trnormal, dmg)
    if ent:IsPlayer() or ent:IsRagdoll() then 
        local ply = hg.RagdollOwner(ent) or ent

        if ply:IsPlayer() then
            local normal = Angle(0,0,0)
            normal:RotateAroundAxis(normal:Forward(),-(self:GetAttackConfigValue(self.SwingAng, self.SwingAng2, self.ChargeSwingAng, attacktype) or -90))
            normal:RotateAroundAxis(normal:Up(),-(self:GetAttackConfigValue(self.AttackRads, self.AttackRads2, self.ChargeAttackRads, attacktype) or 65))

            local dot = ply:GetAimVector():Dot(trnormal)
            
            local angrand = AngleRand(-5, 5)

            ply:ViewPunch((normal * -dot) * dmg * (self.HitPunchMul or 0.75) / (self.HitPunchDiv or 40))
			if ply:OnGround() or ply.organism.superfighter then
                local owner = self:GetOwner()
                local pushDir = IsValid(owner) and (ply:GetPos() - owner:GetPos()) or trnormal
                pushDir.z = 0
                if pushDir:LengthSqr() <= 0.001 then
                    pushDir = Vector(trnormal.x, trnormal.y, 0)
                end
                if pushDir:LengthSqr() > 0.001 then
                    pushDir:Normalize()
                end
                local forceMul = self:IsSecondaryAttackType(attacktype) and (self.PlayerSecondaryKnockbackMul or 0.75) or 1
                local force = pushDir * math.min(dmg * (self.PlayerKnockbackMul or 3.25) * forceMul, 140)
                force.z = math.min(dmg * (self.PlayerKnockbackUpMul or 0.45) * forceMul, 22)
                ply:SetVelocity(force)
			end
        end
    end
end

SWEP.MinSensivity = 0.35

function SWEP:AlreadyHit(ent, trace, dmg)
    local ply = hg.RagdollOwner(ent)

    if IsValid(ply) and self.HitEnts[#self.HitEnts] == ply then
        return true
    else
        return false
    end
end

function SWEP:GetBlockTier()
    return math.max(self.BlockTier or 1, 1)
end

function SWEP:GetBlockMaterial()
    return self.BlockMaterial or "metal"
end

function SWEP:GetBlockParryWindow()
    return math.max((self.BlockParryWindow or 0.35) + (self.BlockParryWindowBonus or 0), 0)
end

function SWEP:GetBlockSound()
    return self.BlockSound
end

function SWEP:GetClashMaterial()
    local material = self.BlockMaterial

    if isstring(material) and material ~= "" then
        return material
    end
end

function SWEP:CanClashWeapon()
    if self.CantClash then return false end

    return self:GetClashMaterial() ~= nil
end

function SWEP:GetClashDamageType(attacktype)
    if self:IsChargeAttackType(attacktype) then
        return self.ChargeDamageType or self.DamageType
    end

    if self:IsSecondaryAttackType(attacktype) then
        return self.SecondaryDamageType or self.DamageType
    end

    return self.PrimaryDamageType or self.DamageType
end

function SWEP:GetClashSoundType(attacktype)
    return self:GetClashDamageType(attacktype) == DMG_SLASH and "sharp" or "blunt"
end

function SWEP:GetClashSoundData(otherWep, attacktype, otherAttacktype)
    local selfMaterial = self:GetClashMaterial()
    local otherMaterial = IsValid(otherWep) and otherWep.GetClashMaterial and otherWep:GetClashMaterial() or otherWep and otherWep.BlockMaterial

    if selfMaterial == "wood" or otherMaterial == "wood" then
        return self:GetDefaultBlockSound("wood", "parry")
    end

    local sharp = self:GetClashSoundType(attacktype) == "sharp" or IsValid(otherWep) and otherWep.GetClashSoundType and otherWep:GetClashSoundType(otherAttacktype) == "sharp"

    if sharp then
        return {
            {"clash/rem_clashsharp1.wav", 72, {85, 105}},
            {"clash/rem_clashsharp2.wav", 72, {85, 105}},
            {"clash/rem_clashsharp3.wav", 72, {85, 105}},
        }
    end

    return {"clash/rem_clashblunt.wav", 72, {85, 105}}
end

function SWEP:GetCurrentAttackTimeLengthForType(attacktype)
    if self:IsChargeAttackType(attacktype) then
        return self.ChargeAttackTimeLength or self.AttackTimeLength
    end

    if self:IsSecondaryAttackType(attacktype) then
        return self.Attack2TimeLength
    end

    return self.AttackTimeLength
end

function SWEP:GetCurrentAttackLengthFraction()
    local attacktype = self.GetAttackType and self:GetAttackType() or 1
    local length = math.max(self:GetCurrentAttackTimeLengthForType(attacktype) or 0, 0.001)
    return math.Clamp(math.max(self:GetAttackTime() - CurTime(), 0) / length, 0, 1)
end

function SWEP:GetClashSweep(owner, ent, attacktype, inattackLength)
    if not IsValid(owner) or not IsValid(ent) then return end

    local speedAdd = math.min(owner:GetVelocity():Length() * 0.05, 40)
    local attackLength = self:GetAttackLength() + speedAdd
    local eyetr = hg.eyeTrace(owner, attackLength, ent, owner:GetAimVector())

    if not eyetr then return end

    local normal = eyetr.Normal:Angle()
    local swingAng = self:GetAttackConfigValue(self.SwingAng, self.SwingAng2, self.ChargeSwingAng, attacktype) or -90
    local attackRads = self:GetAttackConfigValue(self.AttackRads, self.AttackRads2, self.ChargeAttackRads, attacktype) or 65
    local lengthMul = self:IsSecondaryAttackType(attacktype) and 1 or math.max(0.5, 1 - math.abs((0.5 - inattackLength) * 2))

    normal:RotateAroundAxis(normal:Forward(), swingAng)
    normal:RotateAroundAxis(normal:Up(), (0.5 - inattackLength) * attackRads)

    local startPos = eyetr.StartPos
    local endPos = startPos + normal:Forward() * lengthMul * attackLength

    return startPos, endPos, eyetr
end

local function GetSegmentClosestPoints(startA, endA, startB, endB)
    local dirA = endA - startA
    local dirB = endB - startB
    local startDelta = startA - startB
    local lenA = dirA:Dot(dirA)
    local lenB = dirB:Dot(dirB)
    local dotAB = dirA:Dot(dirB)
    local dotAStart = dirA:Dot(startDelta)
    local dotBStart = dirB:Dot(startDelta)
    local fractionA = 0
    local fractionB = 0
    local epsilon = 0.0001

    if lenA <= epsilon and lenB <= epsilon then
        return startA, startB, startA:Distance(startB)
    end

    if lenA <= epsilon then
        fractionB = math.Clamp(dotBStart / lenB, 0, 1)
    elseif lenB <= epsilon then
        fractionA = math.Clamp(-dotAStart / lenA, 0, 1)
    else
        local denom = lenA * lenB - dotAB * dotAB

        if math.abs(denom) > epsilon then
            fractionA = math.Clamp((dotAB * dotBStart - dotAStart * lenB) / denom, 0, 1)
        end

        local projectedB = dotAB * fractionA + dotBStart

        if projectedB < 0 then
            fractionB = 0
            fractionA = math.Clamp(-dotAStart / lenA, 0, 1)
        elseif projectedB > lenB then
            fractionB = 1
            fractionA = math.Clamp((dotAB - dotAStart) / lenA, 0, 1)
        else
            fractionB = projectedB / lenB
        end
    end

    local closestA = startA + dirA * fractionA
    local closestB = startB + dirB * fractionB

    return closestA, closestB, closestA:Distance(closestB)
end

function SWEP:FindClashPoint(startPos, endPos, otherStart, otherEnd)
    local closestA, closestB, dist = GetSegmentClosestPoints(startPos, endPos, otherStart, otherEnd)

    if not dist or dist > (self.ClashDistance or 12) then return end

    return (closestA + closestB) * 0.5, dist, closestA, closestB
end

function SWEP:IsClashPointValid(owner, otherOwner, clashPos, otherWep)
    if not IsValid(owner) or not IsValid(otherOwner) or not clashPos then return false end

    local toClash = clashPos - owner:EyePos()
    local toOtherClash = clashPos - otherOwner:EyePos()

    if toClash:LengthSqr() <= 0.001 or toOtherClash:LengthSqr() <= 0.001 then return false end

    toClash:Normalize()
    toOtherClash:Normalize()

    local frontDot = math.max(self.ClashFrontDot or 0.2, IsValid(otherWep) and otherWep.ClashFrontDot or 0.2)
    local facingDot = math.max(self.ClashFacingDot or -0.2, IsValid(otherWep) and otherWep.ClashFacingDot or -0.2)

    if owner:GetAimVector():Dot(toClash) < frontDot then return false end
    if otherOwner:GetAimVector():Dot(toOtherClash) < frontDot then return false end
    if owner:GetAimVector():Dot((otherOwner:EyePos() - owner:EyePos()):GetNormalized()) < facingDot then return false end
    if otherOwner:GetAimVector():Dot((owner:EyePos() - otherOwner:EyePos()):GetNormalized()) < facingDot then return false end

    return true
end

function SWEP:GetClashChance(otherWep)
    local selfTier = math.max(self:GetBlockTier() or 1, 0.1)
    local otherTier = math.max(IsValid(otherWep) and otherWep.GetBlockTier and otherWep:GetBlockTier() or otherWep and otherWep.BlockTier or 1, 0.1)
    local lowerTier = math.min(selfTier, otherTier)
    local higherTier = math.max(selfTier, otherTier)
    local ratio = lowerTier / higherTier
    local chance = math.pow(ratio, self.ClashTierChancePower or 2.35) * (self.ClashBaseChance or 0.95)

    return math.Clamp(chance, 0, 1)
end

function SWEP:GetDefaultBlockSound(material, state)
    if material == "wood" then
        if state == "break" then return {"physics/wood/wood_box_impact_hard3.wav", 76, {92, 98}} end
        if state == "parry" then return {"physics/wood/wood_plank_impact_hard3.wav", 73, {98, 106}} end
        if state == "weaken" then return {"physics/wood/wood_plank_impact_hard4.wav", 71, {94, 101}} end
        return {"physics/wood/wood_plank_impact_hard2.wav", 70, {96, 104}}
    end

    if state == "break" then return {"physics/metal/metal_solid_impact_hard3.wav", 78, {92, 98}} end
    if state == "parry" then return {"physics/metal/metal_sheet_impact_hard2.wav", 74, {98, 105}} end
    if state == "weaken" then return {"physics/metal/metal_solid_impact_hard2.wav", 72, {94, 101}} end
    return {"physics/metal/metal_sheet_impact_hard2.wav", 70, {95, 103}}
end

function SWEP:PlayConfiguredWorldSound(layer, pos, volumeMul)
    local data = self:GetRandomConfiguredHitSound(layer)

    if isstring(data) then
        sound.Play(data, pos, math.Clamp(60 * (volumeMul or 1), 0, 255), 100)
        return
    end

    if not istable(data) then return end

    local snd = data.sound or data.path or data[1]
    if not isstring(snd) then return end

    local volume = math.Clamp((data.volume or data.vol or data[2] or 60) * (volumeMul or 1), 0, 255)
    local pitch = self:GetConfiguredHitSoundPitch(data.pitch or data[3])

    sound.Play(snd, pos, volume, pitch)
end

function SWEP:DispatchBlockImpactFx(trace, blockWep, state)
    if SERVER then
        local normal = trace.HitNormal and trace.HitNormal ~= vector_origin and trace.HitNormal or -self:GetOwner():GetAimVector()
        local material = IsValid(blockWep) and blockWep.GetBlockMaterial and blockWep:GetBlockMaterial() or blockWep and blockWep.BlockMaterial or self:GetBlockMaterial()

        if material ~= "none" then
            net.Start("hg_melee_block_fx")
            net.WriteVector(trace.HitPos)
            net.WriteVector(normal)
            net.WriteString(tostring(material or "metal"))
            net.WriteString(state or "block")
            net.Broadcast()
        end

        local blockOwner = IsValid(blockWep) and blockWep.GetOwner and blockWep:GetOwner()

        if IsValid(blockOwner) and blockOwner:IsPlayer() then
            net.Start("hg_melee_block_shake")
            net.WriteEntity(blockWep)
            net.WriteVector(normal)
            net.WriteString(state or "block")
            net.Send(blockOwner)
        end
    end
end

function SWEP:PlayBlockImpactEffect(trace, blockWep, state)
    if not trace or not trace.HitPos then return end

    local material = IsValid(blockWep) and blockWep.GetBlockMaterial and blockWep:GetBlockMaterial() or blockWep and blockWep.BlockMaterial or self:GetBlockMaterial()
    local soundData = IsValid(blockWep) and blockWep.GetBlockSound and blockWep:GetBlockSound() or blockWep and blockWep.BlockSound or self:GetDefaultBlockSound(material, state)

    if soundData then
        self:PlayConfiguredWorldSound(soundData, trace.HitPos, state == "break" and 1.18 or state == "parry" and 1.06 or state == "weaken" and 1.02 or 1)
    end

    self:DispatchBlockImpactFx(trace, blockWep, state)
end

function SWEP:AbortBlockedAttack()
    self:SetInAttack(false)
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.ComboAppliedThisAttack = nil
    self.HitWorld = true
    self:ClearChargeState()
end

function SWEP:ShouldStopAttackOnBlockState(state)
    if state == "block" or state == "parry" then
        return self.StopOnBlockedHit ~= false
    end

    if state == "weaken" then
        return self.StopOnWeakenedBlock ~= false
    end

    return false
end

function SWEP:GetAttackHitStopReverse(attacktype)
    if self:IsSecondaryAttackType(attacktype) or self:IsChargeAttackType(attacktype) then
        return false
    end

    return not self.noreverse
end

function SWEP:GetAttackHitStopData(attacktype)
    return self.HitStopWorldSpeedMul or 2.35, self.HitStopWorldPause or 0.12, self:GetAttackHitStopReverse(attacktype), self.HitStopWorldStop or 0.12
end

function SWEP:ShouldStopAttackOnWorldHit(attacktype)
    return self.StopOnWorldHit ~= false and not self.noreverse
end

function SWEP:HandleChargeWorldHit(trace, attacktype)
    if not self:IsChargeAttackType(attacktype) then return false end
    if self.HitWorld then return true end

    self.HitWorld = true
    self:PlayEffects(trace, attacktype)
    self:SendMeleeHitStop(attacktype, trace.HitNormal)

    return true
end

function SWEP:SendMeleeHitStop(attacktype, normal, shakeState)
    if not SERVER then return end

    local speedMul, pause, reverse, stopanim = self:GetAttackHitStopData(attacktype)

    net.Start("hg_melee_hit_stop")
    net.WriteEntity(self)
    net.WriteFloat(speedMul)
    net.WriteFloat(pause)
    net.WriteBool(reverse)
    net.WriteFloat(stopanim or 0)
    net.WriteVector(normal and normal:GetNormalized() or vector_up)
    net.WriteString(shakeState or "")
    net.SendPVS(self:GetPos())
end

function SWEP:AbortClashAttack()
    local recoverTime = self.ClashCooldown ~= nil and self.ClashCooldown or self.WaitTime1 or 0.28
    self:SetInAttack(false)
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.ComboAppliedThisAttack = nil
    self.HitWorld = true
    self.Charging = nil
    self.ChargeIdleLooping = nil
    self.ChargeReleasedAt = nil
    self.ReleasedChargeDamageMul = nil
    self.ReleasedChargeBoneMul = nil
    self.ChargeStaminaMul = nil
    self.ClashAbortUntil = CurTime() + 0.12
    self:SetLastAttack(CurTime())
    self:SetAttackTime(CurTime())
    self:SetAttackWait(recoverTime)
    self.lastattack = CurTime()
    self.attackwait = recoverTime
end

function SWEP:ShouldAbortForClash()
    return (self.ClashAbortUntil or 0) > CurTime()
end

function SWEP:SendClashAnimStop(wep, normal)
    if not SERVER or not IsValid(wep) then return end

    net.Start("hg_melee_clash_stop")
    net.WriteEntity(wep)
    net.WriteVector(normal and normal:GetNormalized() or vector_up)
    net.SendPVS(wep:GetPos())
end

function SWEP:HandleMeleeClash(otherWep, clashPos, hitNormal, attacktype, otherAttacktype)
    if not IsValid(otherWep) or not clashPos then return end
    if (self.NextClashTime or 0) > CurTime() or (otherWep.NextClashTime or 0) > CurTime() then return end

    self.NextClashTime = CurTime() + 0.08
    otherWep.NextClashTime = CurTime() + 0.08

    local clashTrace = {
        HitPos = clashPos,
        HitNormal = hitNormal and hitNormal:GetNormalized() or vector_up,
        HGPreventHeadRagdoll = true,
    }

    self:PlayConfiguredWorldSound(self:GetClashSoundData(otherWep, attacktype, otherAttacktype), clashPos, 1)
    self:DispatchBlockImpactFx(clashTrace, self, "parry")
    self:DispatchBlockImpactFx(clashTrace, otherWep, "parry")
    if self:IsChargeAttackType(attacktype) then
        self:SendMeleeHitStop(attacktype, clashTrace.HitNormal, "parry")
    else
        self:AbortClashAttack()
        self:SendClashAnimStop(self, clashTrace.HitNormal)
    end

    if otherWep.IsChargeAttackType and otherWep:IsChargeAttackType(otherAttacktype) then
        otherWep:SendMeleeHitStop(otherAttacktype, -clashTrace.HitNormal, "parry")
    else
        otherWep:AbortClashAttack()
        self:SendClashAnimStop(otherWep, -clashTrace.HitNormal)
    end

    return {
        Entity = NULL,
        HitPos = clashPos,
        HitNormal = clashTrace.HitNormal,
        HGClash = true,
        HGPreventHeadRagdoll = true,
    }
end

function SWEP:FindMeleeClash(owner, ent, attacktype, inattackLength, tr)
    if not SERVER then return end
    if not IsValid(owner) or not IsValid(ent) then return end
    if not self:CanClashWeapon() then return end

    local searchPos = tr.start + (tr.endpos - tr.start) * 0.5
    local radius = math.max(self.ClashSearchRadius or 22, tr.start:Distance(tr.endpos) * 0.5 + (self.ClashDistance or 12))

    for _, candidate in ipairs(ents.FindInSphere(searchPos, radius)) do
        local clashOwner = hg.RagdollOwner(candidate) or candidate

        if not IsValid(clashOwner) or clashOwner == owner then continue end
        if not clashOwner:IsPlayer() and not clashOwner:IsNPC() then continue end

        local otherWep = clashOwner.GetActiveWeapon and clashOwner:GetActiveWeapon()

        if not IsValid(otherWep) or otherWep == self then continue end
        if not otherWep.ismelee2 and otherWep.Base ~= "weapon_melee" then continue end
        if not otherWep.CanClashWeapon or not otherWep:CanClashWeapon() then continue end
        if not otherWep.GetInAttack or not otherWep:GetInAttack() then continue end

        local otherAttacktype = otherWep.GetAttackType and otherWep:GetAttackType() or 1
        local otherEnt = hg.GetCurrentCharacter(clashOwner)

        if not IsValid(otherEnt) then continue end

        local otherStart, otherEnd = otherWep:GetClashSweep(clashOwner, otherEnt, otherAttacktype, otherWep:GetCurrentAttackLengthFraction())

        if not otherStart or not otherEnd then continue end

        local clashPos = self:FindClashPoint(tr.start, tr.endpos, otherStart, otherEnd)

        if not clashPos then continue end
        if not self:IsClashPointValid(owner, clashOwner, clashPos, otherWep) then continue end
        if math.Rand(0, 1) > self:GetClashChance(otherWep) then continue end

        local hitNormal = (otherEnd - tr.endpos)

        if hitNormal:LengthSqr() <= 0.001 then
            hitNormal = (clashPos - owner:EyePos())
        end

        if hitNormal:LengthSqr() <= 0.001 then
            hitNormal = owner:GetAimVector() * -1
        end

        return self:HandleMeleeClash(otherWep, clashPos, hitNormal, attacktype, otherAttacktype)
    end
end

function SWEP:GetAttackSwingAngle(attacktype)
    return self:GetAttackConfigValue(self.SwingAng, self.SwingAng2, self.ChargeSwingAng, attacktype) or -90
end

function SWEP:GetAttackBlockDirection(attacktype)
    local direction = self:GetAttackConfigValue(self.BlockDirectionalPrimary, self.BlockDirectionalSecondary, self.BlockDirectionalCharge, attacktype)

    if direction == "right" or direction == "left" or direction == "overhead" or direction == "center" or direction == "neutral" then
        return direction
    end

    local swingAng = self:GetAttackSwingAngle(attacktype)
    if math.abs(swingAng) < (self.BlockDirectionalMinSwingAng or 3) then
        return "neutral"
    end

    return swingAng < 0 and "right" or "left"
end

function SWEP:CanDirectionalBlock(blockWep, defender, attacker, attacktype, hierarchyAdvantage)
    if not IsValid(blockWep) or not IsValid(defender) or not IsValid(attacker) then return true end
    if attacker:IsNPC() or not defender:IsPlayer() then return true end

    local _, defenderAim = hg.eye(defender)
    local attackerPos = attacker:EyePos()
    local defenderPos = defender:EyePos()

    if not defenderAim then return true end

    local toAttacker = attackerPos - defenderPos
    toAttacker.z = 0

    if toAttacker:LengthSqr() <= 0.001 then return true end

    toAttacker:Normalize()
    defenderAim = defenderAim:GetNormalized()

    local frontDot = defenderAim:Dot(toAttacker)
    local frontDotNeeded = (blockWep.BlockDirectionalFrontDot or self.BlockDirectionalFrontDot or 0.05) - (blockWep.BlockDirectionalFrontLeniency or self.BlockDirectionalFrontLeniency or 0)
    if frontDot < frontDotNeeded then
        return false
    end

    if hierarchyAdvantage and (blockWep.BlockHierarchyIgnoreSide or self.BlockHierarchyIgnoreSide) then
        return true
    end

    local direction = self:GetAttackBlockDirection(attacktype)
    if direction == "neutral" then
        return true
    end

    local sideDot = defender:EyeAngles():Right():Dot(toAttacker)
    local absSideDot = math.abs(sideDot)
    local sideLeniency = blockWep.BlockDirectionalSideLeniency or self.BlockDirectionalSideLeniency or 0

    if direction == "center" then
        return absSideDot <= ((blockWep.BlockDirectionalCenterDot or self.BlockDirectionalCenterDot or 0.16) + sideLeniency)
    end

    if direction == "overhead" then
        return absSideDot <= ((blockWep.BlockDirectionalOverheadDot or self.BlockDirectionalOverheadDot or 0.28) + sideLeniency)
    end

    local neededSign = direction == "right" and 1 or -1

    return sideDot * neededSign >= ((blockWep.BlockDirectionalSideDot or self.BlockDirectionalSideDot or 0.1) - sideLeniency)
end

function SWEP:IsBlockTraceCovered(defender, trace, eyePos, aimvec, blockWep)
    local blockDist = (blockWep.BlockTraceDist or self.BlockTraceDist or 10) + (blockWep.BlockTraceCoverageBonus or self.BlockTraceCoverageBonus or 0)
    local dist = util.DistanceToLine(eyePos + aimvec * 100, eyePos, trace.HitPos)
    if dist < blockDist then
        return true
    end

    if not defender.Crouching or not defender:Crouching() then return false end
    if not self:IsLegTrace(trace.Entity or defender, trace) then return false end

    local crouchDown = blockWep.BlockCrouchLegCoverageDown or self.BlockCrouchLegCoverageDown or 28
    local crouchDist = (blockWep.BlockCrouchLegCoverageDist or self.BlockCrouchLegCoverageDist or blockDist + 4) + (blockWep.BlockCrouchTraceCoverageBonus or self.BlockCrouchTraceCoverageBonus or 0)
    local loweredPos = eyePos - Vector(0, 0, crouchDown)
    local loweredDist = util.DistanceToLine(loweredPos + aimvec * 100, loweredPos, trace.HitPos)

    return loweredDist < crouchDist
end

function SWEP:BlockingLogic(ent, mul, attacktype, trace)
    local ent = hg.RagdollOwner(ent) or ent
	local owner = self:GetOwner()

	if ent:IsPlayer() and ((istable(self.HitEnts) and !table.HasValue(self.HitEnts, ent)) or owner:IsNPC()) then
        local wep = ent:GetActiveWeapon()

        local pos, aimvec = hg.eye(ent)
        local pos2, aimvec2 = hg.eye(owner)

		if owner:IsNPC() then
			pos, aimvec, aimvec2 = owner:EyePos(), owner:GetAimVector(), owner:GetAimVector()
		end

        if not aimvec or not aimvec2 or not trace or not trace.HitPos then return 1, "none" end

        local selfdmg = math.max(self:GetAttackDamageBase(attacktype), 1)
        local swingStamina = self:GetAttackConfigValue(self.StaminaPrimary, self.StaminaSecondary, self.ChargeStamina, attacktype) or 0

        if wep.GetBlocking and wep:GetBlocking() and wep.SetStartedBlocking and self:IsBlockTraceCovered(ent, trace, pos, aimvec, wep) then
            if wep.CanBlockWeapon and not wep:CanBlockWeapon(self) then
                return 1, "none"
            end

            local attackerTier = self:GetBlockTier()
            local defenderTier = wep.GetBlockTier and wep:GetBlockTier() or math.max(wep.BlockTier or 1, 1)
            local hierarchyAdvantage = defenderTier > attackerTier
            if not self:CanDirectionalBlock(wep, ent, owner, attacktype, hierarchyAdvantage) then
                return 1, "none"
            end

            local perfectblock = CurTime() - wep:GetStartedBlocking() < (wep.GetBlockParryWindow and wep:GetBlockParryWindow() or self:GetBlockParryWindow())
            local tierDiff = attackerTier - defenderTier
            local blockStaminaCost = math.max(swingStamina * (wep.BlockHitStaminaMul or self.BlockHitStaminaMul or 0.5), 0)

            if perfectblock then
                trace.HGPreventHeadRagdoll = true

                if owner.organism and owner.organism.stamina then
                    owner.organism.stamina.subadd = owner.organism.stamina.subadd + swingStamina * (wep.BlockParryStaminaMul or self.BlockParryStaminaMul or 0.5)
                end

				if not owner:IsNPC() then
            	    self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg * 0.15)
				end
                self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg * 0.1)
                self:PlayBlockImpactEffect(trace, wep, "parry")

                return 0, "parry"
            end

            if ent.organism and ent.organism.stamina then
                ent.organism.stamina.subadd = ent.organism.stamina.subadd + blockStaminaCost
            end

            if tierDiff >= (self.BlockBreakTierDiff or 2) then
                if ent.organism and ent.organism.stamina then
                    ent.organism.stamina.subadd = ent.organism.stamina.subadd + selfdmg * (wep.BlockBreakStaminaMul or self.BlockBreakStaminaMul or 0.75)
                end

                if wep.SetBlocking then
                    wep:SetBlocking(false)
                end

                if wep.SetBlockDisabledUntil then
                    wep:SetBlockDisabledUntil(CurTime() + (wep.BlockBreakCooldown or self.BlockBreakCooldown or 1.1))
                end

                if wep.SetLastBlocked then
                    wep:SetLastBlocked(CurTime())
                end

				if not owner:IsNPC() then
            	    self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg * 0.25)
				end
                self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg * 0.35)
                self:PlayBlockImpactEffect(trace, wep, "break")

                return 1, "break"
            end

            if tierDiff > 0 then
                trace.HGPreventHeadRagdoll = true

				if not owner:IsNPC() then
            	    self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg * 0.18)
				end
                self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg * 0.2)
                self:PlayBlockImpactEffect(trace, wep, "weaken")

                return math.Clamp(wep.BlockWeakenDamageMul or self.BlockWeakenDamageMul or 0.35, 0.05, 0.95), "weaken"
            end

            trace.HGPreventHeadRagdoll = true

			if not owner:IsNPC() then
            	self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg * 0.16)
			end
            self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg * 0.18)
            self:PlayBlockImpactEffect(trace, wep, "block")

            return 0, "block"
        end
    end

    return 1, "none"
end

local matBlood = Material("zbattle/blood")
SWEP.BlockTier = 1
SWEP.BlockMaterial = nil
SWEP.BlockSound = nil
SWEP.BlockParryWindow = 0.35
SWEP.BlockParryWindowBonus = 0.08
SWEP.BlockWeakenDamageMul = 0.35
SWEP.BlockBreakTierDiff = 2
SWEP.BlockBreakCooldown = 0.65
SWEP.BlockBreakStaminaMul = 0.75
SWEP.BlockStaminaTierMul = 0.35
SWEP.BlockHitStaminaMul = 0.5
SWEP.BlockParryStaminaMul = 0.5
SWEP.BlockMinStamina = 70
SWEP.BlockRecoverDelay = 0.35
SWEP.BlockDirectionalFrontDot = 0.05
SWEP.BlockDirectionalSideDot = 0.12
SWEP.BlockDirectionalFrontLeniency = 0.08
SWEP.BlockDirectionalSideLeniency = 0.08
SWEP.BlockTraceDist = 10
SWEP.BlockTraceCoverageBonus = 4
SWEP.BlockCrouchLegCoverageDown = 28
SWEP.BlockCrouchLegCoverageDist = 14
SWEP.BlockCrouchTraceCoverageBonus = 6
SWEP.BlockDirectionalCenterDot = 0.16
SWEP.BlockDirectionalOverheadDot = 0.28
SWEP.BlockDirectionalMinSwingAng = 3
SWEP.BlockHierarchyIgnoreSide = false
SWEP.BlockHitShakeMul = 1.7
SWEP.BlockHitShakeParryMul = 2.15
SWEP.BlockHitShakeBreakMul = 3.25
SWEP.BlockHitShakePosMul = 1.95
SWEP.BlockHitShakeAngMul = 1.9
SWEP.BlockHitShakeStiffness = 86
SWEP.BlockHitShakeDamping = 8.25
SWEP.BlockHitShakeAngStiffness = 92
SWEP.BlockHitShakeAngDamping = 8.75
SWEP.BlockFxCountMul = 1.2
SWEP.BlockFxVelocityMul = 1.2
SWEP.BlockFxSizeMul = 1.25
SWEP.BlockFxFlareMul = 1.25
SWEP.BlockFxSmokeMul = 1.2
SWEP.BlockFxLifeMul = 1.25
SWEP.StopOnWorldHit = true
SWEP.StopOnBlockedHit = true
SWEP.StopOnWeakenedBlock = true
SWEP.CantClash = false
SWEP.ClashBaseChance = 0.95
SWEP.ClashTierChancePower = 2.35
SWEP.ClashDistance = 12
SWEP.ClashSearchRadius = 22
SWEP.ClashFrontDot = 0.2
SWEP.ClashFacingDot = -0.2
SWEP.ClashCooldown = nil
SWEP.noreverse = false
SWEP.blockPoseSoundState = nil
SWEP.ShouldAttackOnce = true

function SWEP:IsClient()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:AddDecal()
    net.Start("bloody_decal_1")
    net.WriteEntity(self)
    net.SendPVS(self:GetPos())
end

local hg_nomeleestop
local developer = GetConVar("developer")
local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer",0,FCVAR_SERVER_CAN_EXECUTE,"Toggle developer mode (enables damage traces)",0,1)

if CLIENT then
    hg_nomeleestop = ConVarExists("hg_nomeleestop") and GetConVar("hg_nomeleestop") or CreateConVar("hg_nomeleestop", 0, FCVAR_ARCHIVE, "Toggle melee stop-on-hit animation feature", 0, 1)
end

ShouldDrawMeleeAttackHull = function(owner)
    if SERVER then return false end
    if not developer or not developer:GetBool() then return false end
    if not hg_developer or not hg_developer:GetBool() then return false end
    if not IsFirstTimePredicted() then return false end
    return IsValid(owner) and owner == LocalPlayer()
end

DrawMeleeAttackHull = function(tr, trace)
    local mins = tr.mins or vector_origin
    local maxs = tr.maxs or vector_origin
    local colorTrace = trace and trace.Hit and Color(255, 80, 80) or Color(80, 255, 80)
    local colorBox = trace and trace.Hit and Color(255, 120, 120, 12) or Color(120, 255, 120, 12)
    local diff = tr.endpos - tr.start
    local ang = diff:Angle()
    local steps = math.max(math.ceil(diff:Length() / math.max((maxs - mins):Length(), 1)), 1)

    for step = 0, steps do
        debugoverlay.BoxAngles(LerpVector(step / steps, tr.start, tr.endpos), mins, maxs, ang, 0.06, colorBox)
    end

    debugoverlay.Line(tr.start, tr.endpos, 0.06, colorTrace, true)

    if trace and trace.HitPos then
        debugoverlay.Cross(trace.HitPos, 1.5, 0.06, colorTrace, true)
    end
end

local function GetMeleeAnimTiming(self)
    local animspeed = math.max(self.animspeed or 0, 0.001)
    local timing = 1 - math.Clamp((self.animtime - CurTime()) / animspeed, 0, 1)
    return self.reverseanim and (1 - timing) or timing
end

local function SetMeleeAnimTiming(self, timing, speedMul)
    local animspeed = math.max((self.animbasespeed or self.animspeed or 0) * speedMul, 0.001)
    local internalTiming = self.reverseanim and (1 - timing) or timing
    self.animspeed = animspeed
    self.animtime = CurTime() - internalTiming * animspeed + animspeed
end

local function SyncMeleeAnimToCooldown(self, timing)
    local cooldown = math.max((self:GetLastAttack() + self:GetAttackWait()) - CurTime(), 0.001)
    local animspeed = cooldown / math.max(self.reverseanim and timing or (1 - timing), 0.001)
    local internalTiming = self.reverseanim and (1 - timing) or timing
    self.animspeed = animspeed
    self.animtime = CurTime() - internalTiming * animspeed + animspeed
end

local function QueueMeleeHitStop(self, speedMul, pause, reverse, stopanim)
    if not CLIENT then return end

    self.hitstopToken = (self.hitstopToken or 0) + 1

    local token = self.hitstopToken
    local timerId = "hg_melee_hitstop_" .. self:EntIndex()
    local timing = GetMeleeAnimTiming(self)

    timer.Remove(timerId)

    self.reverseanim = reverse and true or false
    SetMeleeAnimTiming(self, timing, speedMul)
    self.stopanim = stopanim

    timer.Create(timerId, pause, 1, function()
        if not IsValid(self) then return end
        if self.hitstopToken ~= token then return end

        local currentTiming = GetMeleeAnimTiming(self)
        SyncMeleeAnimToCooldown(self, currentTiming)
    end)
end

function SWEP:CustomThink()
    local owner = self:GetOwner()
    local actwep = owner.GetActiveWeapon and owner:GetActiveWeapon()

	if SERVER and not owner:IsNPC() and owner.organism and (not owner.organism.canmove or ((owner.organism.stun - CurTime()) > 0) or (owner.organism.larm == 1 and owner.organism.rarm == 1)) and IsValid(actwep) and self == actwep then
		self:RemoveFake()
		
		hg.drop(owner)

		return
	end

    if self.CanSuicide and hg.KeyDown(owner, IN_ATTACK) and owner.suiciding and !self.SuicideStart then
        self.SuicideStart = CurTime()

        if SERVER then
            if self.SuicideFunc then
                self:SuicideFunc()
            else
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamageType(DMG_SLASH)

                local org = owner.organism
                local ent = hg.GetCurrentCharacter(owner)
                
                local ang = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Neck1")):GetAngles()
                local _, ang = LocalToWorld(vector_origin, Angle(0, -60, 0), vector_origin, ang)
                
                hg.organism.input_list["arteria"](org, 0, 5, dmgInfo, nil, -ang:Forward())
                
                for i = 1, 5 do
                    hg.organism.AddWoundManual(owner, 50, VectorRand(-2, 2), ang, "ValveBiped.Bip01_Neck1", CurTime() + math.Rand(0, 2))
                end

                owner:AddNaturalAdrenaline(math.max(2 - org.adrenaline, 0))
                org.fear = math.max(org.fear, 1)

                --timer.Simple(0, function()
                --    hg.organism.Vomit(owner, "player/flesh/flesh_bullet_impact_03.wav")
                --end)
                hook.Run("HomigradDamage", owner, dmgInfo, HITGROUP_HEAD, hg.GetCurrentCharacter(org.owner), 15)
                owner:EmitSound(self.SuicideSound or self.Attack2HitFlesh, 50)
                
                --timer.Simple(0.05, function()
                --    owner:ViewPunch(self.SuicidePunchAng or Angle(5, 10, 0))
                --end)
            end
        end
    end

    if self.SuicideStart and self.SuicideStart + self.SuicideTime < CurTime() then
        owner.suiciding = false
        self.cutthroat = CurTime()
        self.SuicideStart = nil
    end

    self:SetHold(owner.suiciding and self.SuicideHoldType or self.HoldType)

    if SERVER and owner.organism and owner.organism.rarmamputated then
        self:RemoveFake()
		
		hg.drop(owner)

        return
    end

    if owner.organism and owner.organism.larmamputated and self.TwoHanded then return end

    self:ThinkAdd()
    
    if CLIENT and owner ~= lply then return end

    //if SERVER then
        local oldblocking = self:GetBlocking()
        local blocking = self:GetBlockDisabledUntil() < CurTime() and owner.organism and owner.organism.stamina[1] >= (self.BlockMinStamina or 90) and !self:GetInAttack() and (self:GetAttackTime() - CurTime() - 0) < 0 and self:CanBlock() and hg.KeyDown(owner, IN_ATTACK2)
        --if self:CutDuct() then return end
        self:SetBlocking(blocking)
        
        if self:GetBlocking() and !oldblocking then
            self:SetStartedBlocking(CurTime())
        end
    //end

	if self:GetBlocking() then
		if not self.blockPoseSoundState then
			sound.Play("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", self:GetPos(), 65)
			self.blockPoseSoundState = true
		end
	else
		if self.blockPoseSoundState then
			sound.Play("pwb2/weapons/mac11/draw.wav", self:GetPos(), 55)
		end
		self.blockPoseSoundState = nil
	end

    if self.Charging then
        if not self.canchargeattack or not self:InUse() or self:GetBlocking() then
            self:CancelChargeAttack(true)
            return
        end

        local holdInputs = 0
        if hg.KeyDown(owner, IN_ATTACK) then
            holdInputs = holdInputs + 1
        end
        if hg.KeyDown(owner, IN_RELOAD) then
            holdInputs = holdInputs + 1
        end

        if holdInputs < (self.ChargeHoldMinKeys or 1) then
            if CurTime() - (self.ChargeStartedAt or CurTime()) < (self.ChargeTapCancelTime or 0.12) then
                self:CancelChargeAttack(true)
            else
                self:ReleaseChargeAttack()
            end
        elseif not self.ChargeIdleLooping and (self.ChargeStartedAt or CurTime()) + ((self.ChargeAnimTimeBegin or 0.2) / (self.ChargeStaminaMul or 1)) <= CurTime() then
            self.ChargeIdleLooping = true
            self:PlayAnim(self:GetAttackAnimToken("charge_idle", "Attack_Charge_Idle"), (self.ChargeAnimTimeIdle or 0.35) / (self.ChargeStaminaMul or 1), true, nil, false, false)
        end

        return
    end

    if self:GetInAttack() then
        local inattack1 = math.max(self:GetLastAttack() - CurTime(), 0) / self.AttackTime
        local inattack2 = math.max(self:GetLastAttack() - CurTime(), 0) / self.Attack2Time
        local inattack3 = math.max(self:GetLastAttack() - CurTime(), 0) / (self.ChargeAttackTime or self.AttackTime)

        local inattackL1 = math.max(self:GetAttackTime() - CurTime(), 0) / self.AttackTimeLength
        local inattackL2 = math.max(self:GetAttackTime() - CurTime(), 0) / self.Attack2TimeLength
        local inattackL3 = math.max(self:GetAttackTime() - CurTime(), 0) / (self.ChargeAttackTimeLength or self.AttackTimeLength)
        
        local ent = hg.GetCurrentCharacter(owner)
        local vellen = ent:GetVelocity():Length()

        local mul = self:MultiplyDMG(owner, ent, vellen, 1)
        
        if self:GetAttackType() == 1 and inattack1 == 0 then
            owner:LagCompensation(true)
            
            local trace = self:Attack(owner, ent, vellen, false, inattackL1)

            owner:LagCompensation(false)

            local ownerVel = owner:GetVelocity()
            ownerVel.z = 0

            if SERVER and ownerVel:LengthSqr() >= math.pow(self.SwingForwardBoostMinSpeed or 20, 2) and (owner:OnGround() or owner.organism.superfighter) then -- ранбуст для супербойцов
                local vec = owner:GetAimVector() * math.min(self.DamagePrimary * 0.5, 20)
                vec[3] = 0

                owner:SetVelocity(vec)
            end

            if !trace then return end
            if self:ShouldAbortForClash() then return end
            if trace.HGClash then return end

            local ent = trace.Entity

            local shouldhit = (IsValid(ent) or ent:IsWorld())
            local dmg = math.random(self.DamagePrimary - 3, self.DamagePrimary + 3)
            local soft = self:IsEntSoft(ent)
            local blockState = "none"
            local blockMul = 1

            if !shouldhit then
                goto meleeskip1
            end

            --self:SetInAttack(false)
            if SERVER and soft and self.HitEnts[#self.HitEnts] ~= ent then
                self:AddDecal()
            end

            if self:IsHitCooldownTarget(ent) then
                self:ApplyHitCooldown()
            end

            if CLIENT then goto meleeskip1 end

            if not soft and self:ShouldStopAttackOnWorldHit(1) then
                self:PlayEffects(trace, false)
                self:SendMeleeHitStop(1, trace.HitNormal)
                self:AbortBlockedAttack()
                return
            end

            ent:PrecacheGibs()

            mul = mul * (self:BehindAttack(ent) and 2 or 1)
            blockMul, blockState = self:BlockingLogic(ent, mul, false, trace)
            mul = mul * blockMul

            dmg = dmg * mul
            dmg = self:ApplyComboDamage(dmg)

            if self:AlreadyHit(ent, trace) then
                goto meleeskip1
            end
            
            if self.HitEnts[#self.HitEnts] ~= ent and (blockState == "none" or blockState == "break") then
                self:PlayEffects(trace, false)
            end
            
            if self.MultiDmg1 or (self.HitEnts[#self.HitEnts] ~= ent) then
                //if self:BreakGlass(ent) then
                    //goto meleeskip1
                //end

                if self.MultiDmg1 or not self:IsEntSoft(ent) then
                    dmg = dmg / (self.AttackRads * self.AttackTimeLength)
                else
                    dmg = dmg / 1.5
                end
                                
                local dmginfo = DamageInfo()

                dmginfo:SetAttacker(owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(trace.Normal * dmg)
                dmginfo:SetDamageType(ent:GetClass() == "func_breakable_surf" and DMG_SLASH or self.DamageType)
                dmginfo:SetDamagePosition(trace.HitPos)
                
                self.slash = self.MultiDmg1
                ent:TakeDamageInfo(dmginfo)
                self.attackedOnce = true
                self.slash = nil
                if blockState == "none" or blockState == "break" then
                    self:PlaySoftHitSounds(owner, ent, trace, false)
                end
                
                local hitForce = trace.Normal * math.min(dmg, 25) * 400 * (self.RagdollHitForceMul or 1)
                if self:IsHeadHit(ent, trace) then
                    hitForce.x = hitForce.x * (self.HeadRagdollForceMul or 1.35)
                    hitForce.y = hitForce.y * (self.HeadRagdollForceMul or 1.35)
                    hitForce.z = hitForce.z * (self.HeadRagdollUpMul or 1.2)
                end
                hg.AddForceRag(ent, trace.PhysicsBone or 0, hitForce, 0.5)

                self:PunchPlayer(ent, false, trace.Normal, dmg)

                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)

                if IsValid(phys) then
                    phys:ApplyForceOffset(hitForce, trace.HitPos)
                end

                if self:ShouldHeadRagdoll(ent, trace) then
                    timer.Simple(0, function()
                        local victim = self:GetHitVictim(ent)
                        if IsValid(victim) and victim:IsPlayer() and victim:Alive() and not IsValid(victim.FakeRagdoll) then
                            hg.Fake(victim)
                        end
                    end)
                end

                self:PrimaryAttackAdd(ent, trace)
            end

            if self:ShouldStopAttackOnBlockState(blockState) then
                self:SendMeleeHitStop(1, trace.HitNormal, blockState)
                self:AbortBlockedAttack()
                return
            end

            ::meleeskip1::
            
            if not ent:IsWorld() and self:IsEntSoft(ent) then
                self.HitEnts[#self.HitEnts + 1] = ent
            end

            self.FirstAttackTick = true

            if inattackL1 == 0 then
                self:SetInAttack(false)
                self.HitEnts = nil
                self.FirstAttackTick = false
                self.AttackHitPlayed = false
                self.SoftHitPlayed = false
                self.ComboAppliedThisAttack = nil
            end
        elseif self:GetAttackType() == 2 and inattack2 == 0 then
            owner:LagCompensation(true)
            
            local trace = self:Attack(owner, ent, vellen, true, inattackL2)

            owner:LagCompensation(false)

            if !trace then return end
            if self:ShouldAbortForClash() then return end
            if trace.HGClash then return end

            local ent = trace.Entity

            local shouldhit = (IsValid(ent) or ent:IsWorld())
            local dmg = math.random(self.DamageSecondary - 3, self.DamageSecondary + 3)
            local soft = self:IsEntSoft(ent)
            local blockState = "none"
            local blockMul = 1

            if !shouldhit then
                goto meleeskip2
            end

            if SERVER and self:IsEntSoft(ent) and self.DamageType == DMG_SLASH and self.HitEnts[#self.HitEnts] ~= ent then
                self:AddDecal()
            end

            if self:IsHitCooldownTarget(ent) then
                self:ApplyHitCooldown()
            end

            if CLIENT then goto meleeskip2 end

            if not soft and self:ShouldStopAttackOnWorldHit(2) then
                self:PlayEffects(trace, true)
                self:SendMeleeHitStop(2, trace.HitNormal)
                self:AbortBlockedAttack()
                return
            end

            ent:PrecacheGibs()

            if SERVER then -- ранбуст для супербойцов and (ent:OnGround() or ent.organism and ent.organism.superfighter)
                local vec = trace.Normal * math.min(self.DamageSecondary  * 0.5, 20)
                vec[3] = 0
                
                ent:SetVelocity(vec)
            end

            mul = mul * (self:BehindAttack(ent) and 2 or 1)
            blockMul, blockState = self:BlockingLogic(ent, mul, true, trace)
            mul = mul * blockMul

            dmg = dmg * mul
            dmg = self:ApplyComboDamage(dmg)

            if self:AlreadyHit(ent, trace) then
                goto meleeskip2
            end

            if self.HitEnts[#self.HitEnts] ~= ent and (blockState == "none" or blockState == "break") then
                self:PlayEffects(trace, true)
            end

            if self.MultiDmg2 or (self.HitEnts[#self.HitEnts] ~= ent) then
                //if self:BreakGlass(ent) then
                    //goto meleeskip2
                //end

                if self.MultiDmg2 or not self:IsEntSoft(ent) then
                    dmg = dmg / math.max(1,self.AttackRads2 * self.Attack2TimeLength)
                end

                local dmginfo = DamageInfo()

                dmginfo:SetAttacker(owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(trace.Normal * dmg)
                dmginfo:SetDamageType(ent:GetClass() == "func_breakable_surf" and DMG_SLASH or self.DamageType)
                dmginfo:SetDamagePosition(trace.HitPos)

                self.slash = self.MultiDmg2
                --print(dmg)
                ent:TakeDamageInfo(dmginfo)
                self.attackedOnce = true
                self.slash = nil
                if blockState == "none" or blockState == "break" then
                    self:PlaySoftHitSounds(owner, ent, trace, true)
                end

                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)
                local hitForce = trace.Normal * math.min(dmg, 25) * 400 * (self.RagdollHitForceMul or 1)
                if self:IsHeadHit(ent, trace) then
                    hitForce.x = hitForce.x * (self.HeadRagdollForceMul or 1.35)
                    hitForce.y = hitForce.y * (self.HeadRagdollForceMul or 1.35)
                    hitForce.z = hitForce.z * (self.HeadRagdollUpMul or 1.2)
                end

                hg.AddForceRag(ent, trace.PhysicsBone or 0, hitForce, 0.5)

                self:PunchPlayer(ent, true, trace.Normal, dmg)

                if IsValid(phys) then
                    phys:ApplyForceOffset(hitForce, trace.HitPos)
                end

                if self:ShouldHeadRagdoll(ent, trace) then
                    timer.Simple(0, function()
                        local victim = self:GetHitVictim(ent)
                        if IsValid(victim) and victim:IsPlayer() and victim:Alive() and not IsValid(victim.FakeRagdoll) then
                            hg.Fake(victim)
                        end
                    end)
                end

                self:SecondaryAttackAdd(ent, trace)
            end

            if self:ShouldStopAttackOnBlockState(blockState) then
                self:SendMeleeHitStop(2, trace.HitNormal, blockState)
                self:AbortBlockedAttack()
                return
            end

            ::meleeskip2::

            if not ent:IsWorld() and self:IsEntSoft(ent) then
                self.HitEnts[#self.HitEnts + 1] = ent
            end

            self.FirstAttackTick = true

            if inattackL2 == 0 then
                self:SetInAttack(false)
                self.HitEnts = nil
                self.FirstAttackTick = false
                self.AttackHitPlayed = false
                self.SoftHitPlayed = false
                self.ComboAppliedThisAttack = nil
            end
        elseif self:GetAttackType() == 3 and inattack3 == 0 then
            owner:LagCompensation(true)
            
            local trace = self:Attack(owner, ent, vellen, 3, inattackL3)

            owner:LagCompensation(false)

            local ownerVel = owner:GetVelocity()
            ownerVel.z = 0

            if SERVER and ownerVel:LengthSqr() >= math.pow(self.SwingForwardBoostMinSpeed or 20, 2) and (owner:OnGround() or owner.organism.superfighter) then
                local vec = owner:GetAimVector() * math.min(self:GetAttackDamageBase(3) * 0.5, 24)
                vec[3] = 0

                owner:SetVelocity(vec)
            end

            if !trace then return end
            if self:ShouldAbortForClash() then return end
            if trace.HGClash then return end

            local ent = trace.Entity

            local shouldhit = (IsValid(ent) or ent:IsWorld())

            local damageBase = self.DamagePrimary or 0
            local dmg = math.random(damageBase - 3, damageBase + 3) * (self.ReleasedChargeDamageMul or 1)
            local soft = self:IsEntSoft(ent)
            local blockState = "none"
            local blockMul = 1

            if !shouldhit then
                goto meleeskip3
            end

            if SERVER and soft and self.HitEnts[#self.HitEnts] ~= ent then
                self:AddDecal()
            end

            if self:IsHitCooldownTarget(ent) then
                self:ApplyHitCooldown()
            end

            if CLIENT then goto meleeskip3 end

            if not soft then
                if self:HandleChargeWorldHit(trace, 3) then
                    goto meleeskip3
                end

                if self:ShouldStopAttackOnWorldHit(3) then
                    self:PlayEffects(trace, 3)
                    self:SendMeleeHitStop(3, trace.HitNormal)
                    self:AbortBlockedAttack()
                    return
                end
            end

            ent:PrecacheGibs()

            mul = mul * (self:BehindAttack(ent) and 2 or 1)
            blockMul, blockState = self:BlockingLogic(ent, mul, 3, trace)
            mul = mul * blockMul

            dmg = dmg * mul
            dmg = self:ApplyComboDamage(dmg)

            if self:AlreadyHit(ent, trace) then
                goto meleeskip3
            end
            
            if self.HitEnts[#self.HitEnts] ~= ent and (blockState == "none" or blockState == "break") then
                self:PlayEffects(trace, 3)
            end
            
            if self.MultiDmgCharge or (self.HitEnts[#self.HitEnts] ~= ent) then
                if self.MultiDmgCharge or not self:IsEntSoft(ent) then
                    dmg = dmg / ((self.ChargeAttackRads or self.AttackRads) * (self.ChargeAttackTimeLength or self.AttackTimeLength))
                else
                    dmg = dmg / 1.5
                end
                                
                local dmginfo = DamageInfo()

                dmginfo:SetAttacker(owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(trace.Normal * dmg)
                dmginfo:SetDamageType(ent:GetClass() == "func_breakable_surf" and DMG_SLASH or self.DamageType)
                dmginfo:SetDamagePosition(trace.HitPos)
                
                local oldBreakBoneMul = self.BreakBoneMul
                self.BreakBoneMul = (self.BreakBoneMul or 1) * (self.ReleasedChargeBoneMul or 1)
                self.slash = self.MultiDmgCharge
                ent:TakeDamageInfo(dmginfo)
                self.attackedOnce = true
                self.slash = nil
                self.BreakBoneMul = oldBreakBoneMul
                if blockState == "none" or blockState == "break" then
                    self:PlaySoftHitSounds(owner, ent, trace, 3)
                end
                
                local hitForce = trace.Normal * math.min(dmg, 25) * 400 * (self.RagdollHitForceMul or 1)
                if self:IsHeadHit(ent, trace) then
                    hitForce.x = hitForce.x * (self.HeadRagdollForceMul or 1.35)
                    hitForce.y = hitForce.y * (self.HeadRagdollForceMul or 1.35)
                    hitForce.z = hitForce.z * (self.HeadRagdollUpMul or 1.2)
                end
                hg.AddForceRag(ent, trace.PhysicsBone or 0, hitForce, 0.5)

                self:PunchPlayer(ent, 3, trace.Normal, dmg)

                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)

                if IsValid(phys) then
                    phys:ApplyForceOffset(hitForce, trace.HitPos)
                end

                if self:ShouldHeadRagdoll(ent, trace) then
                    timer.Simple(0, function()
                        local victim = self:GetHitVictim(ent)
                        if IsValid(victim) and victim:IsPlayer() and victim:Alive() and not IsValid(victim.FakeRagdoll) then
                            hg.Fake(victim)
                        end
                    end)
                end

                self:ChargeAttackAdd(ent, trace)
            end

            if self:ShouldStopAttackOnBlockState(blockState) then
                self:SendMeleeHitStop(3, trace.HitNormal, blockState)
                self:AbortBlockedAttack()
                return
            end

            ::meleeskip3::
            
            if not ent:IsWorld() and self:IsEntSoft(ent) then
                self.HitEnts[#self.HitEnts + 1] = ent
            end

            self.FirstAttackTick = true

            if inattackL3 == 0 then
                self:SetInAttack(false)
                self.HitEnts = nil
                self.FirstAttackTick = false
                self.AttackHitPlayed = false
                self.SoftHitPlayed = false
                self.ComboAppliedThisAttack = nil
                self.ChargeReleasedAt = nil
                self.ReleasedChargeDamageMul = nil
                self.ReleasedChargeBoneMul = nil
                self.ChargeStaminaMul = nil
            end
        end
    else
        self.attackedOnce = nil
        self.SoftHitPlayed = false
        self.ComboAppliedThisAttack = nil
    end

end

function SWEP:PrimaryAttackAdd(ent)
end

function SWEP:SecondaryAttackAdd(ent)
end

function SWEP:ChargeAttackAdd(ent)
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1
SWEP.HitStopWorldSpeedMul = 2.35
SWEP.HitStopWorldResumeMul = 0.6
SWEP.HitStopWorldPause = 0.12
SWEP.HitStopWorldStop = 0.12
SWEP.HitStopSoftSpeedMul = 1.9
SWEP.HitStopSoftResumeMul = 0.72
SWEP.HitStopSoftPause = 0.05
SWEP.HitStopSoftStop = 0.1
SWEP.HitPunchMul = 0.75
SWEP.HitPunchDiv = 40
SWEP.HitScreenShakeAmp = 22
SWEP.HitScreenShakeFreq = 6
SWEP.HitScreenShakeDur = 0.28
SWEP.HitScreenShakeRadius = 110

SWEP.AttackRads = 45
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

function SWEP:PrimaryAttack()
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
    local ply = self:GetOwner()

    if self.cutthroat and self.cutthroat + 1 > CurTime() then return end
    if self.CanSuicide and ply.suiciding then return end
    if self.Charging then return end

    if ply.organism and ply.organism.larmamputated and self.TwoHanded then return end
    
    if self:GetLastBlocked() + (self.BlockRecoverDelay or 0.35) > CurTime() then
        //return
    end

    if self:GetBlocking() then
        self:SecondaryAttack(true)

        return
    end
    
    local ply = self:GetOwner()
    local ent = hg.GetCurrentCharacter(ply)

    if !self:InUse() then return end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end
    if self.lastattack and (self.lastattack + self.attackwait) > CurTime() then return end

    if self.canchargeattack and hg.KeyDown(ply, IN_RELOAD) then
        if not self:CanChargeAttack() then return end
        self:StartChargeAttack()
        return
    end

    if !hg.KeyDown(self:GetOwner(), IN_ATTACK2) and not self:CanPrimaryAttack() then return end

    local mul = 1 / math.Clamp((180 - self:GetOwner().organism.stamina[1]) / 90, 1, 2)

    
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.HitWorld = false
    self.ComboAppliedThisAttack = nil
    self:PlayAnim("attack", self.AnimTime1 / mul,false,nil,false,false)
    self:SetAttackType(1)
    self:SetLastAttack(CurTime() + self.AttackTime / mul)
    self:SetAttackTime(self:GetLastAttack() + (self.AttackTimeLength / mul))
    self:SetAttackLength(self.AttackLen1)
    self:SetAttackWait(self.WaitTime1 / mul)
    self:SetInAttack(true)
    self.lastattack = CurTime() + self.Attack2Time / mul
    self.attackwait = self.WaitTime2 / mul
    if CLIENT and not self:IsLocal() and ply.AnimRestartGesture then
        self:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
    end

    self.viewpunch = true
end

function SWEP:CutDuct()
    if self.DamageType ~= DMG_SLASH or CLIENT then return end
    
    local ent = hg.eyeTrace(self:GetOwner()).Entity
    
    if IsValid(ent) then
        if hgIsDoor(ent) and ent.LockedDoor then
            ent.LockedDoor = ent.LockedDoor - FrameTime() * 10
            
            if (ent.SoundTime or 0) < CurTime() then
                ent.SoundTime = CurTime() + 5

                self:GetOwner():EmitSound("tapetear.mp3",65)
                self:PlayAnim("duct_cut",5)
            end

            if ent.LockedDoor <= 0 then
                if !ent.LockedDoorNail and !ent.LockedDoorMap then ent:Fire("unlock", "", 0) end
                ent.LockedDoor = nil
            end
            
            return true
        end

        if ent.DuctTape and next(ent.DuctTape) then
            if (ent.SoundTime or 0) < CurTime() then
                ent.SoundTime = CurTime() + 5

                self:GetOwner():EmitSound("tapetear.mp3",65)
                self:PlayAnim("duct_cut",5)
            end
            
            local key = next(ent.DuctTape)
            local duct = ent.DuctTape[key]
            
            duct[2] = duct[2] - FrameTime()
            
            if duct[2] <= 0 then
                if IsValid(duct[1]) then
                    duct[1]:Remove()
                    duct[1] = nil
                end
                
                ent.DuctTape[key] = nil
            end

            return true
        end
    end
end

function SWEP:CanBlock()
    return true
end

function SWEP:SecondaryAttack(override)
    local ply = self:GetOwner()
    if ply.organism and ply.organism.larmamputated and self.TwoHanded then return end

    if self:CutDuct() then
        return
    end

    if self:CanBlock() and not override then
        return 
    end

    if self:GetLastBlocked() + (self.BlockRecoverDelay or 0.35) > CurTime() then
        return
    end

    if not self:CanSecondaryAttack() then
        
        return
    end
    
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    local ent = hg.GetCurrentCharacter(ply)

    if !self:InUse() then return end
    if (hg.KeyDown(ply, IN_USE) and not IsValid(ply.FakeRagdoll)) then return end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end
    if self.lastattack and (self.lastattack + self.attackwait) > CurTime() then return end

    local mul = 1 / math.Clamp((180 - ply.organism.stamina[1]) / 90, 1, 2)
    
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.SoftHitPlayed = false
    self.HitWorld = false
    self.ComboAppliedThisAttack = nil
    self:PlayAnim("attack2",self.AnimTime2 / mul,false,nil,false,false)
    self:SetAttackType(2)
    self:SetLastAttack(CurTime() + self.Attack2Time / mul)
    self:SetAttackTime(self:GetLastAttack() + (self.Attack2TimeLength / mul) )
    self:SetAttackLength(self.AttackLen2)
    self:SetAttackWait(self.WaitTime2 / mul)
    self:SetInAttack(true)
    self.lastattack = CurTime() + self.Attack2Time / mul
    self.attackwait = self.WaitTime2 / mul

    if CLIENT and not self:IsLocal() and ply.AnimRestartGesture then
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
    end

    self.viewpunch = true
end

function SWEP:InitAdd()
end

if CLIENT then
	SWEP.HowToUseInstructions = "<font=ZCity_Tiny>"..string.upper( (input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD") ).." to pickup</font>"
end

local util = util
function SWEP:Initialize()
    self:ResetCombo()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self:PlayAnim("idle",10,true)

	if CLIENT then
		self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. self.PrintName .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. self.HowToUseInstructions .."</colour></font>",450)
	end

    if self:GetClass() == "weapon_melee" then
        self.ImmobilizationMul = 2
        self.StaminaMul = 0.5
        self.BreakBoneMul = 0.5
        self.ShockMultiplier = 0.5
        self.PainMultiplier = 2

        self.CanSuicide = true

        function self:Reload()
            if SERVER then
                if self:GetOwner():KeyPressed(IN_ATTACK) then
                    self:SetNetVar("mode", not self:GetNetVar("mode"))
                    self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
                    --self.Swing = self:GetNetVar("mode")
                    --self.UpSwing = not self:GetNetVar("mode")
                end
            end
        end

        function self:CustomBlockAnim(addPosLerp, addAngLerp)
            addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 5 or 0)
            addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 2 or 0)
            addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -18 or 0)
            addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 20 or 0)
            addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 60 or 0)
            
            return true
        end

        function self:CanPrimaryAttack()
            if hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
            if not self:GetNetVar("mode") then
                return true
            else
                self.allowsec = true
                self:SecondaryAttack(true)
                self.allowsec = nil
                return false
            end
        end
        
        function self:CanSecondaryAttack()
            return self.allowsec and true or false
        end
    end

    self:SetAttackLength(60)
    self:SetAttackWait(0)
    if self.modelscale then
        self:SetModelScale(self.modelscale)
        self:Activate()
    end
    self:SetHold(self.HoldType)
    
    util.PrecacheSound(self.AttackSwing)
    util.PrecacheSound(self.AttackHit)
    util.PrecacheSound(self.Attack2Hit)
    util.PrecacheSound(self.AttackHitFlesh)
    util.PrecacheSound(self.Attack2HitFlesh)
    util.PrecacheSound(self.DeploySnd)
    util.PrecacheSound("clash/rem_clashblunt.wav")
    util.PrecacheSound("clash/rem_clashsharp1.wav")
    util.PrecacheSound("clash/rem_clashsharp2.wav")
    util.PrecacheSound("clash/rem_clashsharp3.wav")
    self:PrecacheConfiguredHitSoundLayer(self.swingsoundextra)
    self:PrecacheConfiguredHitSoundLayer(self.hitsoundextra)
    self:PrecacheConfiguredHitSoundLayer(self.hitsoundplus)
    self:PrecacheConfiguredHitSoundLayer(self.hitsoundbrutalize)
    self:PrecacheConfiguredHitSoundLayer(self.BlockSound)
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("metal", "block"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("metal", "weaken"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("metal", "parry"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("metal", "break"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("wood", "block"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("wood", "weaken"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("wood", "parry"))
    self:PrecacheConfiguredHitSoundLayer(self:GetDefaultBlockSound("wood", "break"))

    self:InitAdd()
end

function SWEP:IsLocal()
	if SERVER then return end
	return not ((self:GetOwner() ~= lply) or (lply ~= GetViewEntity()))
end

SWEP.tries = 10

if SERVER then
    util.AddNetworkString("melee_attack")
    util.AddNetworkString("hg_melee_hit_stop")
    util.AddNetworkString("hg_melee_block_fx")
    util.AddNetworkString("hg_melee_block_shake")
    util.AddNetworkString("hg_melee_clash_stop")
elseif CLIENT then
    net.Receive("hg_melee_block_shake", function()
        local wep = net.ReadEntity()
        local normal = net.ReadVector()
        local state = net.ReadString()

        local target = wep

        if not IsValid(target) or not target.AddBlockHitShake or target.GetOwner and target:GetOwner() ~= LocalPlayer() then
            local owner = LocalPlayer()

            if IsValid(owner) then
                local active = owner:GetActiveWeapon()

                if IsValid(active) and active.AddBlockHitShake then
                    target = active
                end
            end
        end

        if IsValid(target) and target.AddBlockHitShake then
            target:AddBlockHitShake(state, normal)
        end
    end)

    net.Receive("hg_melee_block_fx", function()
        local pos = net.ReadVector()
        local normal = net.ReadVector()
        local material = net.ReadString()
        local state = net.ReadString()
        
        if material == "none" then return end

        local emitter = ParticleEmitter(pos)

        if not emitter then return end

        local dir = normal:LengthSqr() > 0.001 and normal:GetNormalized() or vector_up
        local metal = material == "metal"
        local broken = state == "break"
        local parry = state == "parry"
        local owner = LocalPlayer()
        local active = IsValid(owner) and owner:GetActiveWeapon() or nil
        local base = weapons.GetStored and weapons.GetStored("weapon_melee") or nil
        local fxSource = IsValid(active) and active or base
        local countMul = fxSource and fxSource.BlockFxCountMul or 1
        local velocityMul = fxSource and fxSource.BlockFxVelocityMul or 1
        local sizeMul = fxSource and fxSource.BlockFxSizeMul or 1
        local flareMul = fxSource and fxSource.BlockFxFlareMul or 1
        local smokeMul = fxSource and fxSource.BlockFxSmokeMul or 1
        local lifeMul = fxSource and fxSource.BlockFxLifeMul or 1

        if metal then
            local count = math.max(1, math.Round((broken and 35 or parry and 18 or 10) * countMul))

            for i = 1, count do
                local part = emitter:Add("effects/spark", pos + dir * 2)

                if part then
                    local vel = dir * math.Rand(broken and 90 or parry and 75 or 48, broken and 180 or parry and 130 or 90) * velocityMul + VectorRand() * math.Rand(broken and 260 or parry and 170 or 100, broken and 320 or parry and 220 or 140) * velocityMul
                    part:SetVelocity(vel)
                    part:SetDieTime(math.Rand(broken and 0.95 or parry and 0.62 or 0.42, broken and 1.35 or parry and 0.82 or 0.56) * lifeMul)
                    part:SetStartAlpha(255)
                    part:SetEndAlpha(0)
                    part:SetStartSize(math.Rand((broken and 1.5 or parry and 1.8 or 2) * sizeMul, (broken and 2.2 or parry and 2.6 or 2.8) * sizeMul))
                    part:SetEndSize(0)
                    part:SetRoll(math.Rand(0, 360))
                    part:SetGravity(Vector(0, 0, broken and -350 or -220))
                    part:SetCollide(true)
                    part:SetBounce(broken and 0.45 or 0.5)
                end
            end

            for i = 1, broken and 2 or parry and 2 or 1 do
                local flare = emitter:Add("effects/yellowflare", pos + dir * 1.5)

                if flare then
                    flare:SetVelocity(dir * math.Rand(0, 12) * velocityMul + VectorRand() * 8)
                    flare:SetDieTime((broken and 0.16 or parry and 0.125 or 0.1) * lifeMul)
                    flare:SetStartAlpha(255)
                    flare:SetEndAlpha(0)
                    flare:SetStartSize((broken and 45 or parry and 30 or 20) * flareMul)
                    flare:SetEndSize(0)
                end
            end

            if broken or parry then
                for i = 1, broken and 3 or 1 do
                    local smoke = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos)

                    if smoke then
                        smoke:SetVelocity(dir * math.Rand(4, 20) * velocityMul + VectorRand() * math.Rand(18, 26) * smokeMul)
                        smoke:SetDieTime((broken and 1.7 or 0.85) * lifeMul)
                        smoke:SetStartAlpha(broken and 120 or 75)
                        smoke:SetEndAlpha(0)
                        smoke:SetStartSize((broken and 10 or 6) * smokeMul)
                        smoke:SetEndSize((broken and 22 or 14) * smokeMul)
                        smoke:SetRoll(math.Rand(0, 360))
                        smoke:SetColor(100,100,100)
                    end
                end
            end
        else
            local count = math.max(1, math.Round((broken and 30 or parry and 12 or 5) * countMul))

            for i = 1, count do
                local part = emitter:Add("effects/fleck_wood" .. math.random(1, 2), pos + dir * 1.5)

                if part then
                    local vel = dir * math.Rand(broken and 65 or parry and 42 or 24, broken and 130 or parry and 85 or 50) * velocityMul + VectorRand() * math.Rand(broken and 240 or parry and 120 or 50, broken and 300 or parry and 170 or 80) * velocityMul + Vector(0, 0, broken and 120 or parry and 75 or 50)
                    part:SetVelocity(vel)
                    part:SetDieTime(math.Rand(broken and 3.1 or parry and 2.4 or 2.2, broken and 3.8 or parry and 3.1 or 2.9) * lifeMul)
                    part:SetStartAlpha(255)
                    part:SetEndAlpha(0)
                    part:SetStartSize(math.Rand((broken and 1.8 or parry and 1.6 or 1.5) * sizeMul, (broken and 2.6 or parry and 2 or 1.8) * sizeMul))
                    part:SetEndSize(0)
                    part:SetRoll(math.Rand(0, 360))
                    part:SetGravity(Vector(0, 0, broken and -350 or -200))
                    part:SetCollide(true)
                    part:SetBounce(broken and 0.4 or 0.18)
                end
            end

            if broken or parry or state == "block" or state == "weaken" then
                for i = 1, broken and 5 or parry and 2 or 1 do
                    local smoke = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos)

                    if smoke then
                        smoke:SetVelocity(dir * math.Rand(4, 18) * velocityMul + VectorRand() * math.Rand(8, 28) * smokeMul)
                        smoke:SetDieTime((broken and 3 or parry and 1.6 or 1.1) * lifeMul)
                        smoke:SetStartAlpha(broken and 110 or parry and 65 or 50)
                        smoke:SetEndAlpha(0)
                        smoke:SetStartSize((broken and 10 or parry and 6 or 5) * smokeMul)
                        smoke:SetEndSize((broken and 20 or parry and 12 or 10) * smokeMul)
                        smoke:SetRoll(math.Rand(0, 360))
                        smoke:SetColor(95, 85, 70)
                    end
                end
            end
        end

        emitter:Finish()
    end)

    net.Receive("hg_melee_hit_stop", function()
        local wep = net.ReadEntity()
        local speedMul = net.ReadFloat()
        local pause = net.ReadFloat()
        local reverse = net.ReadBool()
        local stopanim = net.ReadFloat()
        local normal = net.ReadVector()
        local shakeState = net.ReadString()

        if not IsValid(wep) then return end

        if shakeState ~= "" and wep.AddBlockHitShake then
            wep:AddBlockHitShake(shakeState, normal)
        end

        if not hg_nomeleestop:GetBool() then
            QueueMeleeHitStop(wep, speedMul, pause, reverse, stopanim > 0 and stopanim or nil)
        end

        local owner = wep.GetOwner and wep:GetOwner()
        if IsValid(owner) and owner == LocalPlayer() then
            util.ScreenShake(wep:GetPos(), 35, 1, 1, 100)
        end
    end)

    net.Receive("hg_melee_clash_stop", function()
        local wep = net.ReadEntity()
        local normal = net.ReadVector()

        if not IsValid(wep) then return end

        if wep.AddBlockHitShake then
            wep:AddBlockHitShake("parry", normal)
        end

        QueueMeleeHitStop(wep, wep.HitStopWorldSpeedMul or 2.35, wep.HitStopWorldPause or 0.12, not wep.noreverse, wep.HitStopWorldStop or 0.12)
    end)

    net.Receive("melee_attack",function()
        local tbl = net.ReadTable()
        local ent = net.ReadEntity()
        local sendtoclient = net.ReadBool()

        if ent.IsLocal and !ent:IsLocal() then
            if IsValid(ent) and ent.PlayAnim then
                ent:PlayAnim(tbl.anim,tbl.time,tbl.cycling,tbl.callback,tbl.reverse)
                
                if (tbl.anim == "attack" or tbl.anim == "attack2") and ent:GetOwner().AnimRestartGesture and IsValid(ent:GetOwner()) and not ent:GetOwner():IsWorld() then
                    ent:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
                end
            end
        end
    end)
end

function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    if SERVER then
        sendtoclient = sendtoclient or false
        net.Start("melee_attack")
            local netTbl = {
                anim = anim,
                time = time,
                cycling = cycling,
                callback = callback,
                reverse = reverse
            }
            net.WriteTable(netTbl) 
            net.WriteEntity(self)
            net.WriteBool(sendtoclient)
        net.SendPVS(self:GetPos())
    return end
    if not IsValid(self:GetWM()) or not IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() ~= self then
		self.tries = self.tries - 1
		if self.tries > 0 then
			timer.Simple(0.01,function()
                if not IsValid(self) then return end
				self:PlayAnim(anim,time,cycling,callback,reverse)
			end)
		end
		return
	end
    self.tries = 10

    if self:GetWM():GetModel() ~= self.WorldModelReal then self:GetWM():SetModel(self.WorldModelReal) end
    
    if CLIENT then
        self.hitstopToken = (self.hitstopToken or 0) + 1
        timer.Remove("hg_melee_hitstop_" .. self:EntIndex())
        self.stopanim = nil
    end
    
    self:GetWM():SetSequence(self.AnimList[anim] or anim)
    self.animtime = CurTime() + time
    self.animbasespeed = time
    self.animspeed = time
    self.cycling = cycling
    self.reverseanim = reverse
    if callback then
        self.callback = callback
    end
end

function SWEP:SetFakeGun(ent)
	self:SetNWEntity("fakeGun", ent)
	self.fakeGun = ent
end

function SWEP:RemoveFake()
	if not IsValid(self.fakeGun) then return end
	self.fakeGun:Remove()
	self:SetFakeGun()
end

local function GetPhysBoneNum(ent,string)
	if not IsValid(ent) then return 7 end
	return ent:TranslateBoneToPhysBone(ent:LookupBone(string))
end

function SWEP:CreateFake(ragdoll)
	if IsValid(self:GetNWEntity("fakeGun")) then return end
	if not IsValid(ragdoll) then return end
	local ent = ents.Create("prop_physics")
    ent.notprop = true
	local physbonerh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_R_Hand")
	local rh = ragdoll:GetPhysicsObjectNum(physbonerh)

	ent:SetPos(rh:GetPos())
	ent:SetModel(self.WorldModel)
	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:GetPhysicsObject():SetMass(0)
    ent:SetNoDraw(true)
    ent.dontPickup = true
	ent.fakeOwner = self
	ragdoll:DeleteOnRemove(ent)
	ragdoll.fakeGun = ent
	if IsValid(ragdoll.ConsRH) then ragdoll.ConsRH:Remove() end
	self:SetFakeGun(ent)
	ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)

	ent:SetNoDraw(true)
end

function SWEP:NPCThink()
    local npc = self:GetOwner()
    if not IsValid(npc) or not npc:IsNPC() then return end

    self:SetWeaponHoldType("melee")
    
    if npc:GetClass() == "npc_metropolice" then
        self:SetWeaponHoldType("smg")
    end
    
    --npc:Fire( "GagEnable" )
    
    if npc:GetClass() == "npc_citizen" then
        --npc:Fire( "DisableWeaponPickup" )
    end
    
    local enemy = npc:GetEnemy()
    if not IsValid(enemy) then return end

    local dist = enemy:GetPos():Distance(npc:GetPos())

    if enemy and dist > 85 then
        --npc:SetSchedule(SCHED_CHASE_ENEMY)
    end

    if dist < 85 and (self.LastNPCAttack or 0) < CurTime() then
		local timerId = (self:EntIndex() .. "_NPCAttack")
		if timer.Exists(timerId) then return end

        local dmg = math.random(self.DamagePrimary - 3, self.DamagePrimary + 3)
        
        local tr = {}
        tr.start = npc:EyePos()
        tr.endpos = enemy.EyePos and enemy:EyePos() or enemy:GetPos()
        tr.filter = npc

        local trace = util.TraceLine(tr)
		--  trace.Entity == ((enemy:IsPlayer() and IsValid(enemy.FakeRagdoll) and (enemy.organism and not enemy.organism.otrib)) and enemy.FakeRagdoll or enemy)
        local trEnt = IsValid(trace.Entity) and trace.Entity
		if IsValid(trEnt) then
			self.LastNPCAttack = CurTime() + (self.AnimTime1 or 1)
            self.SoftHitPlayed = false
			self:PlaySwingSound(npc)

            npc:SetSchedule(SCHED_MELEE_ATTACK1)
			timer.Create(timerId, (self.AttackTime + 0.1) or 0.4, 1, function()
				if IsValid(self) and IsValid(npc) and npc:Alive() and IsValid(trEnt) then
					local mul = 1
					mul = mul * (self:BehindAttack(trEnt) and 2 or 1)
					local blockMul, blockState = self:BlockingLogic(trEnt, mul, false, trace)
					mul = mul * blockMul
					if blockState == "block" or blockState == "parry" then return end
					trEnt:PrecacheGibs()

					dmg = dmg * mul
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(npc)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamage(dmg)
					dmginfo:SetDamageForce(trace.Normal * dmg * 1)
					dmginfo:SetDamageType(self.DamageType)
					dmginfo:SetDamagePosition(trace.HitPos)
					trEnt:TakeDamageInfo(dmginfo)
                    if blockState == "none" or blockState == "break" then
                        self:PlaySoftHitSounds(npc, trEnt, trace, false)
                    end

					if trEnt:IsPlayer() then
						local hitForce = trace.Normal * math.min(dmg, 25) * 400 * (self.RagdollHitForceMul or 1)
						if self:IsHeadHit(trEnt, trace) then
							hitForce.x = hitForce.x * (self.HeadRagdollForceMul or 1.35)
							hitForce.y = hitForce.y * (self.HeadRagdollForceMul or 1.35)
							hitForce.z = hitForce.z * (self.HeadRagdollUpMul or 1.2)
						end
						hg.AddForceRag(trEnt, trace.PhysicsBone or 0, hitForce, 0.5)

						self:PunchPlayer(trEnt, false, trace.Normal, dmg)
		
						local phys = trEnt:GetPhysicsObjectNum(trace.PhysicsBone or 0)
		
						if IsValid(phys) then
							phys:ApplyForceOffset(hitForce, trace.HitPos)
						end

						if self:ShouldHeadRagdoll(trEnt, trace) then
							timer.Simple(0, function()
								local victim = self:GetHitVictim(trEnt)
								if IsValid(victim) and victim:IsPlayer() and victim:Alive() and not IsValid(victim.FakeRagdoll) then
									hg.Fake(victim)
								end
							end)
						end
					end
				end
				if timer.Exists(timerId) then timer.Remove(timerId) end
			end)
        end
    end
end

function SWEP:GetNPCRestTimes()
	return self.AnimTime1, self.AnimTime1
end

function SWEP:GetCapabilities()
    if (self.NPCThinktime or 0) < CurTime() then self.NPCThinktime = CurTime() + 0.01 self:NPCThink() end
    return bit.bor( CAP_WEAPON_MELEE_ATTACK1, CAP_MOVE_GROUND )
end

function SWEP:SetupWeaponHoldTypeForAI( t )
	self.ActivityTranslateAI = {}
	if ( t == "melee" ) then
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_HL2MP_IDLE_KNIFE
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "smg" ) then
	
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_RANGE_ATTACK_THROW
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "shotgun" ) then
		
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_HL2MP_IDLE_KNIFE
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "pistol") then 
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_IDLE_SHOTGUN
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_IDLE_SHOTGUN
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		
		return
	end
end

function SWEP:CanBePickedUpByNPCs()
	return true
end

--[[function SWEP:CustomAttack2() -- prikol
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.DamagePrimary * 0.7
    ent.MaxSpeed = 1300
    ent.DamageType = self.DamageType
    ent.AttackHit = "Concrete.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent.noStuck = true

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(self.ViewPunch1 * 0.6)
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end]]
