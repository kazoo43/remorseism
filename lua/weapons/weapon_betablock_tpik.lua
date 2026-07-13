if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Beta-Blocker"
SWEP.Instructions = "Beta blockers can help in stressful situations, will reduce your panic and adrenaline. Very useful in combat at certain doses."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/nmrih/items/phalanx/w_phalanx.mdl"
SWEP.WorldModelReal = "models/weapons/nmrih/items/phalanx/v_item_phalanx.mdl"
SWEP.WorldModelExchange = false
SWEP.WMSkin = 1
SWEP.WMSkinV = 1

SWEP.HideMeshBonesIdle = {
	"phalanx bottle",
	"bottle cap",
	"v_item_pill",
	"v_item_pill001",
	"v_item_pill002",
	"v_item_pill003",
	"v_item_pill004",
	"v_item_pill005",
}
SWEP.HideMeshBonesUse = {
	"phalanx bottle",
	"phalanx bottle2",
	"bottle cap",
	"v_item_pill",
	"v_item_pill001",
	"v_item_pill002",
	"v_item_pill003",
	"v_item_pill004",
	"v_item_pill005",
}

SWEP.HideMeshBones = SWEP.HideMeshBonesIdle

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/item_pills_custom")
	SWEP.IconOverride = "vgui/hud/item_pills_custom"
	SWEP.BounceWeaponIcon = false
end

SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.setlh = true
SWEP.setrh = true

SWEP.HoldPos = Vector(1.5, -1, -0.5)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.offsetVec = Vector(0, 0, 0)
SWEP.offsetAng = Angle(0, 0, 0)

SWEP.lpos = Vector(0, 0, 0)
SWEP.lang = Angle(0, 0, 0)

SWEP.handPosOffset = Vector(0, 0, 0)
SWEP.handAngOffset = Angle(0, 0, 0)

SWEP.modeNames = {
	[1] = "beta-blocker"
}

SWEP.UseSpeed = 4
SWEP.CallbackTimeAdjust = 1.25

SWEP.AnimList = {
	["deploy"] = { "draw", 0.5, false },
	["use"] = { "pills", 3, false, false, function(self)
		if CLIENT then return end
		self:Heal(self:GetOwner())
	end },
	["idle"] = { "idle", 5, true }
}

SWEP.TimedHideBones = {
	["bottle cap"] = 1.85,
}
SWEP.TimedShowBones = {
	["phalanx bottle"] = 0.18,
	["bottle cap"] = 0.18,
	["v_item_pill"] = 0.18,
	["v_item_pill001"] = 0.18,
	["v_item_pill002"] = 0.18,
	["v_item_pill003"] = 0.18,
	["v_item_pill004"] = 0.18,
	["v_item_pill005"] = 0.18,
}

SWEP.TimedSounds = {
	{"weapons/tfa_nmrih/items/medpills_shake_01.wav", 0.1},
	{"weapons/tfa_nmrih/items/pills_lid_twist_01.wav", 0.85},
	{"weapons/tfa_nmrih/items/pills_lid_twist_01.wav", 1.35},
	{"weapons/tfa_nmrih/items/medpills_open_01.wav", 1.37},
	{"weapons/tfa_nmrih/items/pills_lid_twist_open_01.wav", 1.92},
	{"weapons/tfa_nmrih/items/pills_lid_twist_open_01.wav", 2.2},
}

SWEP.GarbageRemoveTime = 10

SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.showstats = false

SWEP.DeploySounds = {
	"weapons/tfa_nmrih/items/medpills_draw_01.wav",
	"weapons/tfa_nmrih/items/pills_draw_01.wav",
	"snd_jack_hmcd_pillsbounce.wav",
}
SWEP.FallSnd = "snd_jack_hmcd_pillsbounce.wav"

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:InitAdd()
	self.modeValues = {
		[1] = 1
	}
end

function SWEP:Initialize()
end

function SWEP:Deploy()
	if self.DeploySounds and #self.DeploySounds > 0 then
		self.DeploySnd = self.DeploySounds[math.random(#self.DeploySounds)]
	end
	local snd = self.DeploySnd
	self.DeploySnd = ""
	local base = weapons.GetStored(self.Base)
	if base and base.Deploy then
		local ret = base.Deploy(self)
		if SERVER and snd and not self._deploySndPlayed and self:GetOwner() and not self:GetOwner().noSound then
			self._deploySndPlayed = true
			self:GetOwner():EmitSound(snd, 65, math.random(95, 105))
		end
		return ret
	end
	return true
end

function SWEP:Holster()
	self._deploySndPlayed = false

	if self.healing then
		self.healing = false
		self.callback = nil
		hook.Remove("Think", "AnimCallback" .. self:EntIndex())
		self.HideMeshBones = self.HideMeshBonesIdle
		self._wasInUse = false
	end
	return true
end

local function GarbagePhysCallback(ent, data)
	if data.DeltaTime < 0.2 then return end
	ent:EmitSound(ent.FallSnd)
end

function SWEP:Think()
	if hg.SWEPEditor_Apply then hg.SWEPEditor_Apply(self) end

	local curTime = CurTime()
	local anim = self.anim

	local inUse = anim == "use" and self.animtime and self.animtime > curTime

	if not IsFirstTimePredicted() then return end

	if inUse ~= self._wasInUse then
		self._wasInUse = inUse
		if inUse then
			self._timedApplied = {}
			self._showApplied = {}
			self._soundIdx = 1

			if not self._timedSndCache and self.TimedSounds and #self.TimedSounds > 0 then
				local sorted = {}
				for i, data in ipairs(self.TimedSounds) do
					if data[1] ~= "" then
						sorted[#sorted + 1] = {data[1], data[2]}
					end
				end
				table.sort(sorted, function(a, b) return a[2] < b[2] end)
				self._timedSndCache = sorted
				self._timedSndCount = #sorted
			end

			self.HideMeshBones = table.Copy(self.HideMeshBonesUse)
		else
			self.HideMeshBones = self.HideMeshBonesIdle
		end
	end

	if inUse and self.animtime and self.animspeed then
		local elapsed = self.animspeed - (self.animtime - curTime)
		local changed

		if self.TimedHideBones then
			for bone, time in pairs(self.TimedHideBones) do
				if not self._timedApplied[bone] and elapsed >= time then
					self._timedApplied[bone] = true
					changed = true
					self.HideMeshBones = table.Copy(self.HideMeshBones)
					self.HideMeshBones[#self.HideMeshBones + 1] = bone
				end
			end
		end

		if self.TimedShowBones then
			for bone, time in pairs(self.TimedShowBones) do
				if not self._showApplied[bone] and elapsed >= time then
					self._showApplied[bone] = true
					if not changed then
						changed = true
						self.HideMeshBones = table.Copy(self.HideMeshBones)
					end
					local list = self.HideMeshBones
					for i = #list, 1, -1 do
						if list[i] == bone then
							table.remove(list, i)
							break
						end
					end
				end
			end
		end

		if self._timedSndCache then
			local idx = self._soundIdx or 1
			local cache = self._timedSndCache
			local count = self._timedSndCount
			while idx <= count and elapsed >= cache[idx][2] do
				local data = cache[idx]
				idx = idx + 1
				if CLIENT then
					local owner = self:GetOwner()
					if IsValid(owner) then
						owner:EmitSound(data[1], 60, math.random(95, 105), 1, CHAN_STATIC)
					end
				end
			end
			self._soundIdx = idx
		end
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if not self.healing and anim == "deploy" and self.animtime and self.animtime <= curTime then
		if SERVER then
			self:PlayAnim("idle")
		end
	end
end

function SWEP:PostSetHandPos()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local ent = hg.GetCurrentCharacter(ply)
	if not IsValid(ent) then return end

	local rhBone = ent:LookupBone("ValveBiped.Bip01_R_Hand")
	if rhBone then
		local mat = ent:GetBoneMatrix(rhBone)
		if mat then
			local pos = mat:GetTranslation() + self.handPosOffset
			local ang = mat:GetAngles()
			ang.p = ang.p + self.handAngOffset.p
			ang.y = ang.y + self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(rhBone, mat)
		end
	end

	if not self.lhandik then return end

	local lhBone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
	if lhBone then
		local mat = ent:GetBoneMatrix(lhBone)
		if mat then
			local pos = mat:GetTranslation()
			local offset = self.handPosOffset
			pos.x = pos.x - offset.x
			pos.y = pos.y - offset.y
			pos.z = pos.z + offset.z
			local ang = mat:GetAngles()
			ang.p = ang.p - self.handAngOffset.p
			ang.y = ang.y - self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(lhBone, mat)
		end
	end
end

if SERVER then
	function SWEP:PrimaryAttack()
		if self.healing then return end
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		self.healing = true
		self:PlayAnim("use", self.UseSpeed, false, nil, false)
	end

	function SWEP:DropGarbage()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local chr = hg.GetCurrentCharacter(owner)
		if not IsValid(chr) then return end

		local boneid = chr:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end

		local matrix = chr:GetBoneMatrix(boneid)
		if not matrix then return end

		local ent = ents.Create("prop_physics")
		ent:SetModel(self.WorldModel)
		ent:SetPos(matrix:GetTranslation())
		ent:SetAngles(matrix:GetAngles())
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:Spawn()
		ent:Activate()
		ent:SetSkin(self.WMSkin or 0)

		ent.FallSnd = Sound(self.FallSnd)

		ent:AddCallback("PhysicsCollide", GarbagePhysCallback)

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(owner:GetAimVector() * 150 + VectorRand(-20, 20))
			phys:AddAngleVelocity(VectorRand(-50, 50))
		end

		SafeRemoveEntityDelayed(ent, self.GarbageRemoveTime)
	end

	function SWEP:Heal(ent)
		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("weapons/tfa_nmrih/items/pills_enter_mouth_01.wav", 60, math.random(95, 105))
		timer.Simple(0.7, function()
			if not IsValid(entOwner) then return end
			local snd = math.random(2) == 1 and "weapons/tfa_nmrih/items/gulp_01.wav" or "weapons/tfa_nmrih/items/gulp_02.wav"
			entOwner:EmitSound(snd, 60, math.random(95, 105))
		end)

		local mode = self.modeValues and self.modeValues[1] or self.modeValuesdef[1]

		org.adrenalineAdd = math.Approach(org.adrenalineAdd, -4, mode * 2)
		org.panicattackadd = math.max((org.panicattackadd or 0) - mode * 0.65, 0)
		org.panicattack = math.max((org.panicattack or 0) - mode * 0.2, 0)

		self.healing = false

		self:DropGarbage()
		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()

		return true
	end
end
