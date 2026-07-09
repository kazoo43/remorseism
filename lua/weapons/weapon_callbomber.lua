if(SERVER)then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "B2 Bomber Caller"
SWEP.Instructions = "Primary attack to mark a point and call a B2 bomber strike."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 8
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, 5.5, -41)
SWEP.offsetAng = Angle(180, 160, 180)

SWEP.BomberModel = "models/b2/b2.mdl"
SWEP.BombModel = "models/gbombs/250lbgp.mdl"
SWEP.BomberHeight = 4096
SWEP.MinBomberHeight = 900
SWEP.BomberSkyClearance = 350
SWEP.BomberDistance = 9000
SWEP.BomberSpeed = 1800
SWEP.BomberScale = 0.87
SWEP.BombDropHeight = 900
SWEP.BombScale = 1.35
SWEP.BlastDamage = 2500
SWEP.BlastRadius = 3500
SWEP.NukeBombClass = "gb_bomb_2000gp"
SWEP.CarpetBombClass = "gb_bomb_500gp"
SWEP.CarpetBombPairs = 8
SWEP.CarpetBombInterval = 0.5
SWEP.CarpetBombRowSpacing = 220
SWEP.AmbientSounds = {
	"jet/jet_far_001.wav",
	"jet/jet_far_002.wav"
}
SWEP.FlybySound = "jet/jet_flyby4.wav"

if SERVER then
	util.AddNetworkString("callbomber_b2_start")
	util.AddNetworkString("callbomber_b2_stop")
	util.AddNetworkString("callbomber_nuke_explode")
end

if CLIENT then
	local activeBombers = {}
	local nukeFlashEnd = 0

	net.Receive("callbomber_b2_start", function()
		local id = net.ReadUInt(16)
		local startPos = net.ReadVector()
		local endPos = net.ReadVector()
		local startTime = net.ReadFloat()
		local travelTime = net.ReadFloat()
		local ambientSound = net.ReadString()
		local snd = CreateSound(LocalPlayer(), ambientSound)

		if snd then
			snd:PlayEx(0, 100)
		end

		activeBombers[id] = {
			startPos = startPos,
			endPos = endPos,
			startTime = startTime,
			travelTime = travelTime,
			snd = snd,
			flyby = false
		}
	end)

	net.Receive("callbomber_b2_stop", function()
		local id = net.ReadUInt(16)

		if activeBombers[id] then
			activeBombers[id].stopTime = CurTime() + 3
		end
	end)

	net.Receive("callbomber_nuke_explode", function()
		nukeFlashEnd = CurTime() + 1
		surface.PlaySound("rem_nuke.ogg")
		surface.PlaySound("rem_blast.mp3")
	end)

	hook.Add("HUDPaint", "callbomber_nuke_flash", function()
		if nukeFlashEnd <= CurTime() then return end

		local alpha = math.Clamp((nukeFlashEnd - CurTime()) * 255, 0, 255)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end)

	hook.Add("Think", "callbomber_b2_sounds", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		for id, data in pairs(activeBombers) do
			local progress = math.Clamp((CurTime() - data.startTime) / data.travelTime, 0, 1)
			local remaining = math.max((data.startTime + data.travelTime) - CurTime(), 0)
			local volume = math.min((CurTime() - data.startTime) / 3, remaining / 3, 1)

			if data.stopTime then
				volume = math.min(volume, math.max((data.stopTime - CurTime()) / 3, 0))
			end

			if data.snd then
				data.snd:ChangeVolume(math.Clamp(volume, 0, 1), 0)
			end

			if not data.flyby and CurTime() >= data.startTime + data.travelTime * 0.5 - 2 then
				data.flyby = true
				ply:EmitSound("jet/jet_flyby4.mp3", 0, 65)
			end

			if progress >= 1 and volume <= 0 or data.stopTime and CurTime() >= data.stopTime then
				if data.snd then
					data.snd:Stop()
				end

				activeBombers[id] = nil
			end
		end
	end)
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:DrawWorldModel()
	if !self:GetOwner():IsPlayer() then
		self:DrawModel()
	end
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = hg.GetCurrentCharacter(self:GetOwner())

	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)

	if(IsValid(owner))then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")

		if(not boneid)then
			return
		end

		local matrix = owner:GetBoneMatrix(boneid)

		if(not matrix)then
			return
		end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
		WorldModel:DrawModel()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:DrawModel()
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:BoneSet(lookup_name, vec, ang)
	local owner = self:GetOwner()
	if IsValid(owner) and !owner:IsPlayer() then return end
	hg.bone.Set(owner, lookup_name, vec, ang, "walkietalkie", 0.01)
end

local handAng1, handAng2 = Angle(-15, -10, 10), Angle(5, -65, -60)
local actAng1, actAng2 = Angle(0, -40, -18), Angle(-5, -5, -70)
function SWEP:Step()
	local owner = self:GetOwner()
	local active = owner:KeyDown(IN_ATTACK)

	if active then
		self:SetHold(self.HoldType)
	elseif self:GetHoldType() ~= "normal" then
		self:SetHold("normal")
	end

	if owner:OnGround() and owner:GetVelocity():LengthSqr() <= 1000 and not owner:IsTyping() and not owner:IsFlagSet(FL_ANIMDUCKING) then
		self:BoneSet("l_upperarm", vector_origin, handAng1)
		self:BoneSet("l_forearm", vector_origin, handAng2)
		self:BoneSet("r_upperarm", vector_origin, active and actAng1 or angle_zero)
		self:BoneSet("r_forearm", vector_origin, active and actAng2 or angle_zero)
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Wait)

	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsAdmin() then return end

	local tr = owner:GetEyeTrace()
	if not tr.Hit then return end

	self:CallBomber(tr.HitPos)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Primary.Wait)

	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsAdmin() then return end

	local tr = owner:GetEyeTrace()
	if not tr.Hit then return end

	self:CallBomber(tr.HitPos, true)
end

function SWEP:Reload()
end

if SERVER then
	function SWEP:GetBomberHeight(targetPos)
		local tr = util.TraceLine({
			start = targetPos + Vector(0, 0, 64),
			endpos = targetPos + Vector(0, 0, self.BomberHeight + self.BomberSkyClearance),
			mask = MASK_SOLID_BRUSHONLY
		})

		if tr.Hit then
			return math.Clamp(tr.HitPos.z - targetPos.z - self.BomberSkyClearance, self.MinBomberHeight, self.BomberHeight)
		end

		return self.BomberHeight
	end

	function SWEP:CallBomber(targetPos, carpetBomb)
		local direction = VectorRand()
		direction.z = 0

		if direction:IsZero() then
			direction = Vector(1, 0, 0)
		end

		direction:Normalize()

		local bomberHeight = self:GetBomberHeight(targetPos)
		local startPos = targetPos - direction * self.BomberDistance + Vector(0, 0, bomberHeight)
		local endPos = targetPos + direction * self.BomberDistance + Vector(0, 0, bomberHeight)
		local bomber = ents.Create("prop_dynamic")

		if not IsValid(bomber) then return end

		bomber:SetModel(self.BomberModel)
		bomber:SetModelScale(self.BomberScale, 0)
		bomber:SetPos(startPos)
		bomber:SetAngles((-direction):Angle())
		bomber:SetSolid(SOLID_NONE)
		bomber:SetMoveType(MOVETYPE_NOCLIP)
		bomber:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		bomber:Spawn()

		local weapon = self
		local dropped = false
		local carpetIndex = 0
		local travelDistance = startPos:Distance(endPos)
		local startTime = CurTime()
		local travelTime = travelDistance / self.BomberSpeed
		local carpetStartTime = startTime + travelTime * 0.5 - 3
		local timerName = "b2_bomber_" .. bomber:EntIndex()
		local ambientSound = self.AmbientSounds[math.random(1, #self.AmbientSounds)]

		net.Start("callbomber_b2_start")
			net.WriteUInt(bomber:EntIndex(), 16)
			net.WriteVector(startPos)
			net.WriteVector(endPos)
			net.WriteFloat(startTime)
			net.WriteFloat(travelTime)
			net.WriteString(ambientSound)
		net.Broadcast()

		bomber:CallOnRemove(timerName, function()
			timer.Remove(timerName)

			net.Start("callbomber_b2_stop")
				net.WriteUInt(bomber:EntIndex(), 16)
			net.Broadcast()
		end)

		timer.Create(timerName, 0, 0, function()
			if not IsValid(bomber) then timer.Remove(timerName) return end
			if not IsValid(weapon) then bomber:Remove() return end

			local progress = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)
			local pos = LerpVector(progress, startPos, endPos)
			bomber:SetPos(pos)

			if carpetBomb then
				while carpetIndex < weapon.CarpetBombPairs and CurTime() >= carpetStartTime + carpetIndex * weapon.CarpetBombInterval do
					weapon:DropCarpetBombPair(pos, direction)
					carpetIndex = carpetIndex + 1
				end
			elseif not dropped and progress >= 0.5 then
				dropped = true
				weapon:DropNukeBomb(pos, direction)
			end

			if progress >= 1 then
				bomber:Remove()
			end
		end)
	end

	function SWEP:DropCarpetBombPair(dropPos, direction)
		local right = direction:Angle():Right()

		self:DropGredBomb(dropPos + right * self.CarpetBombRowSpacing * 0.5, direction)
		self:DropGredBomb(dropPos - right * self.CarpetBombRowSpacing * 0.5, direction)
	end

	function SWEP:DropGredBomb(dropPos, direction)
		local owner = self:GetOwner()
		local bomb = ents.Create(self.CarpetBombClass)

		if not IsValid(bomb) then return end

		bomb.IsOnPlane = true
		bomb.GBOWNER = owner
		bomb.Owner = owner
		bomb:SetPos(dropPos)
		bomb:SetAngles(direction:Angle() + Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		if IsValid(owner) then
			bomb:SetPhysicsAttacker(owner)
		end

		local phys = bomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(direction * self.BomberSpeed + Vector(0, 0, -1500))
		end

		if bomb.Arm then
			bomb:Arm()
		end
	end

	function SWEP:DropNukeBomb(dropPos, direction)
		local owner = self:GetOwner()
		local bomb = ents.Create(self.NukeBombClass)

		if not IsValid(bomb) then return end

		bomb.IsOnPlane = true
		bomb.GBOWNER = owner
		bomb.Owner = owner
		bomb:SetPos(dropPos)
		bomb:SetAngles(direction:Angle() + Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		if IsValid(owner) then
			bomb:SetPhysicsAttacker(owner)
		end

		local phys = bomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(direction * self.BomberSpeed + Vector(0, 0, -1500))
		end

		local oldExplode = bomb.Explode
		local weapon = self

		bomb.Explode = function(ent, pos)
			if IsValid(weapon) and not ent.CallBomberNuked then
				ent.CallBomberNuked = true
				weapon:NukeExplode(pos or ent:GetPos())
			end

			if oldExplode then
				return oldExplode(ent, pos)
			end
		end

		if bomb.Arm then
			bomb:Arm()
		end
	end

	function SWEP:NukeExplode(pos)
		net.Start("callbomber_nuke_explode")
		net.Broadcast()

		for i, ply in player.Iterator() do
			if IsValid(ply) and ply:Alive() then
				ply:Kill()
			end
		end
	end

	function SWEP:DropBomb(targetPos, dropPos)
		local bomb = ents.Create("prop_physics")

		if not IsValid(bomb) then return end

		bomb:SetModel(self.BombModel)
		bomb:SetModelScale(self.BombScale, 0)
		bomb:SetPos(dropPos)
		bomb:SetAngles(Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		local phys = bomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetMass(500)
			phys:SetVelocity(Vector(0, 0, -1200))
		end

		local weapon = self
		bomb.PhysicsCollide = function(ent, data)
			if not IsValid(ent) or ent.Exploded then return end
			ent.Exploded = true
			weapon:LodgeBomb(ent, data)
			weapon:DetonateBomb(ent, data.HitPos or targetPos)
		end
	end

	function SWEP:LodgeBomb(bomb, data)
		local phys = bomb:GetPhysicsObject()
		local hitPos = data.HitPos or bomb:GetPos()
		local hitNormal = data.HitNormal or vector_up

		bomb:SetPos(hitPos - hitNormal * 18)
		bomb:SetMoveType(MOVETYPE_NONE)
		bomb:SetCollisionGroup(COLLISION_GROUP_WORLD)

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	function SWEP:DetonateBomb(bomb, targetPos)
		local pos = IsValid(bomb) and bomb:GetPos() or targetPos
		util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, pos, self.BlastRadius, self.BlastDamage)
		util.ScreenShake(pos, 60, 120, 4, self.BlastRadius * 2)
	end
end
