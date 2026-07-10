if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Hammer"
SWEP.Instructions = "A regular household hammer, which has a blunt and a sharp side. Use it to block off paths or restrict someone from moving.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block/nail.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Ammo = "Nails"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/wm_hammer_i.png")
	SWEP.IconOverride = "vgui/hud/wm_hammer_i.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.bloodID = 1

SWEP.SuicidePos = Vector(-12, -4, -8)
SWEP.SuicideAng = Angle(-0, 30, -50)
SWEP.SuicideCutVec = Vector(-2, -6, 2)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)
SWEP.WorldModel = "models/weapons/hammer/w.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/weapons/hammer/w.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""
SWEP.HoldType = "melee"
SWEP.HoldPos = Vector(-15, 2, -4)
SWEP.HoldAng = Angle(-15, 0, 0)
SWEP.AttackTime = 0.34
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1
SWEP.AttackLen1 = 45
SWEP.ViewPunch1 = Angle(1, 1, 0)
SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.7
SWEP.AttackLen2 = 40
SWEP.ViewPunch2 = Angle(0, 0, -2)
SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)
SWEP.basebone = 94
SWEP.weaponPos = Vector(0, 5, -2)
SWEP.weaponAng = Angle(-5, -90, 0)
SWEP.AnimList = {
	["idle"] = "Idle",
	["deploy"] = "Draw",
	["attack"] = "Attack_Quick",
	["attack2"] = "Shove",
}

SWEP.hitsoundextra = {
    {"hammer/BodyHit-1.wav", 70, {115, 125}},
    {"hammer/BodyHit-2.wav", 70, {115, 125}},
    {"hammer/BodyHit-3.wav", 70, {115, 125}},
    {"hammer/BodyHit-4.wav", 70, {115, 125}},
    {"hammer/BodyHit-5.wav", 70, {115, 125}},
    {"hammer/BodyHit-6.wav", 70, {115, 125}},
}

SWEP.hitsoundbrutalize = {
    {"hammerbrutalize/rem_hammerbrutalize1.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize2.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize3.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize4.wav", 70, {110, 115}},
}

SWEP.hitsoundplus = {
    {"snd_jack_hmcd_hammerhit.wav", 55, {105, 115}},
}

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {110, 115}},
}

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_solid_impact_soft1.wav"
SWEP.BlockDirectionalPrimary = "overhead"
SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1
SWEP.AttackRads = 55
SWEP.AttackRads2 = 65
SWEP.SwingAng = -90
SWEP.SwingAng2 = 0
SWEP.AttackPos = Vector(0, 0, 0)
SWEP.noreverse = true
SWEP.BlockTier = 1.5
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_solid_impact_hard1.wav", 68, {95, 102}}
SWEP.UnNailables = {MAT_METAL, MAT_SAND, MAT_SLOSH, MAT_GLASS}
game.AddDecal("hmcd_jackanail", "decals/mat_jack_hmcd_nailhead")
function hgCheckBindObjects(ent1)
	if not ent1.Nails then return end
	return (ent1.Nails and ent1.Nails[0] and #ent1.Nails[0]) or 0
end

function SWEP:CanPrimaryAttack()
	return not hg.KeyDown(self:GetOwner(), IN_RELOAD)
end

SWEP.DamageType = DMG_CLUB
SWEP.PenetrationPrimary = 2
SWEP.MaxPenLen = 1
SWEP.PainMultiplier = 1.65
SWEP.PenetrationSizePrimary = 1
SWEP.StaminaPrimary = 25
SWEP.HammerModeLerpSpeed = 10
function SWEP:ThinkAdd()
	local ply = self:GetOwner()
	if SERVER and ply.suiciding then
		self:SetNetVar("AttackMode", 1)
	end

	if not self._hammerCurPos then
		self._hammerCurPos = Vector(0, 0, -6)
		self._hammerCurAng = Angle(-5, -90, 0)
		self._hammerPrevMode = self:GetNetVar("AttackMode", 1)
	end

	local mode = self:GetNetVar("AttackMode", 1)
	local targetPos, targetAng

	if mode == 1 then
		self.DamagePrimary = 19
		self.DamageType = DMG_CLUB
		self.PenetrationPrimary = 2
		self.MaxPenLen = 1
		self.PainMultiplier = 1.15
		self.PenetrationSizePrimary = 1
		self.StaminaPrimary = 26
		targetPos = Vector(0, 0, -6)
		targetAng = Angle(-5, -90, 0)
	else
		self.DamagePrimary = 15
		self.DamageType = DMG_SLASH
		self.PenetrationPrimary = 3
		self.PainMultiplier = 1.1
		self.MaxPenLen = 4
		self.PenetrationSizePrimary = 0.5
		self.StaminaPrimary = 26
		targetPos = Vector(0, 0, -6)
		targetAng = Angle(0, 90, 0)
	end

	if mode ~= self._hammerPrevMode then
		self._hammerCurPos = Vector(self.weaponPos.x, self.weaponPos.y, self.weaponPos.z)
		self._hammerCurAng = Angle(self.weaponAng.p, self.weaponAng.y, self.weaponAng.r)
		self._hammerPrevMode = mode
	end

	local ft = math.Clamp(FrameTime() * (self.HammerModeLerpSpeed or 8), 0, 1)
	self._hammerCurPos = LerpVector(ft, self._hammerCurPos, targetPos)
	self._hammerCurAng = LerpAngle(ft, self._hammerCurAng, targetAng)

	self.weaponPos = self._hammerCurPos
	self.weaponAng = self._hammerCurAng

	if CLIENT then return end
	if IsValid(ply) then
		if hg.KeyDown(ply, IN_ATTACK) and hg.KeyDown(ply, IN_RELOAD) then
			if not self.setmode then
				local int = self:GetNetVar("AttackMode", 1)
				self:SetNetVar("AttackMode", int >= 2 and 1 or (int + 1))
				self.setmode = true
			end
		else
			self.setmode = false
		end
	end
end

local function BindObjects(ent1, pos1, ent2, pos2, power, bone1, bone2)
	ent1.Nails = ent1.Nails or {}
	ent2.Nails = ent2.Nails or {}
	--ent2.Nails[bone2] = ent2.Nails[bone2] or {}
	--ent1.Nails[bone1] = ent1.Nails[bone1] or {}
	--ent2.Nails[bone2][2] = ent2.Nails[bone2][2] or 0
	--ent1.Nails[bone1][2] = ent1.Nails[bone1][2] or 0
	if not ent1.Nails[bone1] then
			local weld =
			(
				not ent1:IsRagdoll() and not ent2:IsRagdoll() 
				and constraint.Ballsocket(ent1, ent2, bone1 or 0, bone2 or 0, ent1:WorldToLocal(pos1), (500 + 1 * 100) * 5)
			)
			or constraint.Weld(ent1, ent2, bone1 or 0, bone2 or 0, (500 + 1 * 100) * 15, false, false)
			print(weld)
		if weld then
			ent1.Nails[bone1] = {weld, 1}
			weld:CallOnRemove("removefromtbl", function() ent1.Nails[bone1] = nil end)
		end
	else
		if not ent1:IsRagdoll() and not ent2:IsRagdoll() then 
			local weld = constraint.Ballsocket(ent1, ent2, bone1 or 0, bone2 or 0, ent2:WorldToLocal(pos2), (500 + 1 * 100) * 5)
		end
		local weld = ent1.Nails[bone1][1]
		if IsValid(weld) and (ent2:IsRagdoll() or ent1:IsRagdoll()) then
			weld:SetKeyValue("forcelimit", tostring( tonumber(weld:GetInternalVariable("forcelimit")) + ((500 + 1 * 100) * 5) ))
		end
		ent1.Nails[bone1][2] = ent1.Nails[bone1][2] + 1
	end

	if not ent2.Nails[bone2] then
			local weld =
			(
				not ent1:IsRagdoll() and not ent2:IsRagdoll()
				and constraint.Ballsocket(ent1, ent2, bone1 or 0, bone2 or 0, ent2:WorldToLocal(pos2), (500 + 1 * 100) * 5)
			)
			or constraint.Weld(ent1, ent2, bone1 or 0, bone2 or 0, (500 + 1 * 100) * 15, false, false)
		if weld then
			ent2.Nails[bone2] = {weld, 1}
			weld:CallOnRemove("removefromtbl", function() ent2.Nails[bone2] = nil end)
		end
	else
		if not ent1:IsRagdoll() and not ent2:IsRagdoll() then 
			local weld = constraint.Ballsocket(ent1, ent2, bone1 or 0, bone2 or 0, ent2:WorldToLocal(pos2), (500 + 1 * 100) * 5)
		end
		local weld = ent2.Nails[bone2][1]
		if IsValid(weld) and (ent2:IsRagdoll() or ent1:IsRagdoll()) then
			weld:SetKeyValue("forcelimit", tostring( tonumber(weld:GetInternalVariable("forcelimit")) + ((500 + 1 * 100) * 5) ))
		end
		ent2.Nails[bone2][2] = ent2.Nails[bone2][2] + 1
		
	end

	if ent2.Nails[bone2] then ent2.Nails[bone2][3] = ent1.Nails[bone1] and ent1.Nails[bone1][1] end
	if ent1.Nails[bone1] then ent1.Nails[bone1][3] = ent2.Nails[bone2] and ent2.Nails[bone2][1] end
	return ent1:IsWorld() and ((ent2.Nails[bone2] and ent2.Nails[bone2][2]) or 1) or ((ent1.Nails[bone1] and ent1.Nails[bone1][2]) or 1)
end

if SERVER then
	hook.Add("Should Fake Up", "NailTaped", function(ply)
		if ply and IsValid(ply.FakeRagdoll) then
			local Nails = ply.FakeRagdoll.Nails
			if Nails then
				for i, tbl in pairs(Nails) do
					if tbl[2] > 0 then
						tbl[2] = tbl[2] - 0.05
						if math.random(3) == 1 then
							local dmginfo = DamageInfo()
							dmginfo:SetDamage(15)
							dmginfo:SetAttacker(ply)
							dmginfo:SetInflictor(ply)
							dmginfo:SetDamagePosition(ply.FakeRagdoll:GetPhysicsObjectNum(tbl[1]:GetTable()["Bone1"]):GetPos())
							dmginfo:SetDamageType(DMG_SLASH)
							dmginfo:SetDamageForce(vector_up)
							ply.Penetration = 5
							ply.FakeRagdoll:TakeDamageInfo(dmginfo)
							ply.Penetration = nil
						end

						--ply.FakeRagdoll:EmitSound("tape_friction"..math.random(3)..".mp3",65)
						if tbl[2] <= 0 then
							if IsValid(Nails[i][1]) then
								Nails[i][1]:Remove()
								Nails[i][1] = nil
							end

							if IsValid(Nails[i][3]) then
								Nails[i][3]:Remove()
								Nails[i][3] = nil
							end

							Nails[i] = nil
						end
					end
				end

				if table.Count(Nails) > 0 then
					ply.fakecd = CurTime() + 1
					return false
				end
			end
		end
	end)
end

local vec1, vec2, vec3 = Vector(0, 0, .15), Vector(0, .15, 0), Vector(.15, 0, 0)
function SWEP:SprayDecals()
	local Owner = self:GetOwner()
	local Tr = util.QuickTrace(Owner:GetShootPos(), Owner:GetAimVector() * 70, {Owner})
	util.Decal("hmcd_jackanail", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
end

function SWEP:InitAdd()
	if CLIENT then return end
	self.AmmoGive = self:GetOwner().Profession and self:GetOwner().Profession == "builder" and 4 or 3
end

function SWEP:OwnerChanged()
	if IsValid(self:GetOwner()) and SERVER then
		self:GetOwner():GiveAmmo(self.AmmoGive, self.Ammo, true)
		self.AmmoGive = 0
	end
end

function SWEP:CanNail(Tr)
	local Owner = self:GetOwner()
	return (Owner:GetAmmoCount(self.Ammo) > 0) and Tr.Hit and Tr.Entity and (IsValid(Tr.Entity) or Tr.Entity:IsWorld()) and not (Tr.Entity:IsPlayer() or Tr.Entity:IsNPC()) and not table.HasValue(self.UnNailables, Tr.MatType)
end

function DoorIsOpen(door)
	return not door:GetInternalVariable("m_bLocked")
end

local vpang = Angle(3, 0, 0)

function SWEP:ThrowHammer()
	if CLIENT then return true end

	local ply = self:GetOwner()
	if not IsValid(ply) then return true end

	local ent = ents.Create("ent_throwable")
	if not IsValid(ent) then return true end
	ent.WorldModel = self.WorldModelExchange or self.WorldModel

	ent:SetPos(select(1, hg.eye(ply, 60, hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
	ent:SetAngles(ply:EyeAngles())
	ent:SetOwner(ply)
	ent:Spawn()
	ent.localshit = Vector(4, 6, 0)
	ent.wep = self:GetClass()
	ent.owner = ply
	ent.damage = 35
	ent.penetration = 5
	ent.shouldntlodge = true

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed * 0.5)
		phys:AddAngleVelocity(Vector(0, ent.MaxSpeed * 0.5, 0))
	end

	if ply.organism and ply.organism.stamina then
		ply.organism.stamina.subadd = ply.organism.stamina.subadd + 30
	end

	ply:EmitSound("weapons/slam/throw.wav", 50, math.random(95, 105))
	ply:SelectWeapon("weapon_hands_sh")
	ply:ViewPunch(Angle(0, 0, -2))

	self:Remove()

	return true
end

function SWEP:SecondaryAttack(override)
	if override then
		return self:ThrowHammer()
	end
	if CLIENT then return end
	if self:GetLastAttack() + 3 > CurTime() then return end
	local Owner = self:GetOwner()
	local Tr = hg.eyeTrace(Owner)
	if self:GetNetVar("AttackMode", 1) == 2 then
		if self:CutDuct() then return end
		if ((Tr.Entity.Nails and Tr.Entity.Nails[Tr.PhysicsBone]) or Tr.Entity.LockedDoorNail) and not self.pulling then
			Owner:EmitSound("nail_pull.mp3", 65, 100, 1, CHAN_AUTO)
			self.pulling = true
			timer.Simple(2, function()
				self.pulling = false
				if Tr.Entity.LockedDoorNail then
					if not Tr.Entity.LockedDoor and not Tr.Entity.LockedDoorMap then Tr.Entity:Fire("unlock", "", 0) end
					Tr.Entity.LockedDoorNail = nil
					Owner:SetAmmo(Owner:GetAmmoCount(self.Ammo) + (tr.Entity.CadedByBuilder and 2 or 3), self.Ammo)
					return
				end

				local tbl = Tr.Entity.Nails[Tr.PhysicsBone]
				if tbl then
					if tbl[2] <= 0 then return end
					tbl[2] = tbl[2] - 1
					Owner:SetAmmo(Owner:GetAmmoCount(self.Ammo) + 1, self.Ammo)
					if tbl[2] > 0 then return end
					if IsValid(tbl[1]) then
						tbl[1]:Remove()
						tbl[1] = nil
					end

					if IsValid(tbl[3]) then
						tbl[3]:Remove()
						tbl[3] = nil
					end

					Tr.Entity.Nails[Tr.PhysicsBone] = nil
				end
			end)
		end
	else
		if Owner:KeyDown(IN_SPEED) then return end
		if Owner:GetAmmoCount(self.Ammo) <= 0 then return end
		local AimVec = Owner:GetAimVector()
		local Tr = hg.eyeTrace(Owner)
		if self:CanNail(Tr) then
			local NewTr, NewEnt = util.QuickTrace(Tr.HitPos, AimVec * 10, {Owner, Tr.Entity}), nil
			if self:CanNail(NewTr) then
				if not NewTr.HitSky then NewEnt = NewTr.Entity end
				if NewEnt and (IsValid(NewEnt) or NewEnt:IsWorld()) and not (NewEnt:IsPlayer() or NewEnt:IsNPC() or (NewEnt == Tr.Entity)) then
					if hgIsDoor(Tr.Entity) then
						if Owner:GetAmmoCount(self.Ammo) > (Owner.Profession and Owner.Profession == "builder" and 1 or 2) then
							if not DoorIsOpen(Tr.Entity) then
								if not Tr.Entity.LockedDoorNail then Tr.Entity.LockedDoorMap = true end
							else
								Tr.Entity.LockedDoorMap = false
							end

							Tr.Entity:Fire("lock", "", 0)
							Tr.Entity.LockedDoorNail = true
							Tr.Entity.CadedByBuilder = (Owner.Profession and Owner.Profession == "builder") and true or false
							Owner:SetAmmo(Owner:GetAmmoCount(self.Ammo) - (Owner.Profession and Owner.Profession == "builder" and 2 or 3), self.Ammo)
							sound.Play("snd_jack_hmcd_hammerhit.wav", Tr.HitPos, 65, math.random(90, 110))
							self:SprayDecals()
							Owner:PrintMessage(HUD_PRINTCENTER, "Door Sealed")
							Owner:ViewPunch(vpang)
							Owner:SetAnimation(PLAYER_ATTACK1)
							self:SetNextSecondaryFire(CurTime() + 2.5)
							self:SetNextPrimaryFire(CurTime() + 2.5)
						else
							Owner:PrintMessage(HUD_PRINTCENTER, "Need at least "..tostring((Owner.Profession and Owner.Profession == "builder") and 2 or 3).." nails to seal door.")
						end
					else
						if Tr.Entity:IsRagdoll() then
							local DmgInfo = DamageInfo()
							DmgInfo:SetDamage(15)
							DmgInfo:SetDamageType(DMG_SLASH)
							DmgInfo:SetDamageForce(AimVec * 5)
							DmgInfo:SetDamagePosition(Tr.HitPos)
							DmgInfo:SetInflictor(self)
							DmgInfo:SetAttacker(Owner)
							self.Penetration = 15
							Tr.Entity:TakeDamageInfo(DmgInfo)
							self.Penetration = nil
						end

						if NewEnt:IsRagdoll() then
							local DmgInfo = DamageInfo()
							DmgInfo:SetDamage(15)
							DmgInfo:SetDamageType(DMG_SLASH)
							DmgInfo:SetDamageForce(AimVec * 5)
							DmgInfo:SetDamagePosition(NewTr.HitPos)
							DmgInfo:SetInflictor(self)
							DmgInfo:SetAttacker(Owner)
							self.Penetration = 15
							NewEnt:TakeDamageInfo(DmgInfo)
							self.Penetration = nil
						end

						local Strength, Weld = BindObjects(Tr.Entity, Tr.HitPos, NewEnt, NewTr.HitPos, 3.5, Tr.PhysicsBone or 0, NewTr.PhysicsBone or 0)
						--print(Tr.Entity,Weld)
						if Weld or Weld == nil then Owner:SetAmmo(Owner:GetAmmoCount(self.Ammo) - 1, self.Ammo) end
						sound.Play("snd_jack_hmcd_hammerhit.wav", Tr.HitPos, 65, math.random(90, 110))
						util.Decal("hmcd_jackanail", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
						Owner:ChatPrint("Bond strength: " .. tostring(Strength))
						Owner:ViewPunch(vpang)
						self:PlayAnim("attack", 0.6, false, nil, false, true)
						
						self:SetNextSecondaryFire(CurTime() + 2.5)
						self:SetNextPrimaryFire(CurTime() + 2.5)
						self:SetLastBlocked(CurTime())
					end
				end
			end
		end
	end
end
