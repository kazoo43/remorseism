SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "HK MP5SD"
SWEP.Author = "Heckler & Koch"
SWEP.Instructions = "Integrally suppressed submachine gun chambered in 9x19 mm\n\nRate of fire 800 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
SWEP.WorldModelFake = "models/weapons/c_mp5.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "MP5"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/arc9/darsu_eft/mods/mag_mp5_hk_std_curved_9x19_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 2.8, 0),
		ang = Angle(0, -90, 0)
	},
}

SWEP.FakePos = Vector(-11, 2.0, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(1.5, 0.4, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "1210111130"
SWEP.ZoomPos = Vector(0, -2.2637, 5.6717)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.FakeMagDropBone = 45

local path = "weapons/darsu_eft/mp5/"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
    ["reload"] = {
        [0.10] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_mag_out.ogg") end,
		[0.40] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_mag_in.ogg") end,

    },
    ["reload_empty"] = {
        [0.10] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_bolt_out.ogg") end,
		[0.30] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_mag_out.ogg") end,
		[0.55] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_mag_in.ogg") end,
		[0.80] = function(self) self:EmitSound("weapons/darsu_eft/mp5/mp5_weap_bolt_in.ogg") end,
    },
}


SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["inspect"] = "look",
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:ModelCreated(model)
	if not CLIENT then return end
	if not IsValid(model) then return end
	if not self.FakeBodyGroups then return end

	model:SetBodyGroups(self.FakeBodyGroups)

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.15] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(53, vector_origin)
			self:GetWM():ManipulateBoneScale(44, vector_full)
			self:GetWM():ManipulateBoneScale(45, vector_origin)
			self:GetWM():ManipulateBoneScale(46, vector_origin)
			self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
		[0.25] = function(self, timeMul)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.5 * timeMul, nil, nil, function()
				self:GetWM():ManipulateBoneScale(53, vector_full)
				self:GetWM():ManipulateBoneScale(44, vector_full)
				self:GetWM():ManipulateBoneScale(45, vector_full)
			end)
		end,
		[0.50] = function(self, timeMul)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(44, vector_origin)
				self:GetWM():ManipulateBoneScale(45, vector_origin)
				self:GetWM():ManipulateBoneScale(46, vector_origin)
			end
		end,
		[0.65] = function(self, timeMul)
			if self:Clip1() > 0 then
				self:GetWM():ManipulateBoneScale(44, vector_origin)
				self:GetWM():ManipulateBoneScale(45, vector_origin)
				self:GetWM():ManipulateBoneScale(46, vector_origin)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
					self:GetWM():ManipulateBoneScale(44, vector_origin)
					self:GetWM():ManipulateBoneScale(45, vector_origin)
					self:GetWM():ManipulateBoneScale(46, vector_origin)
				end)
			end
		end,
		[0.85] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(44, vector_origin)
			self:GetWM():ManipulateBoneScale(45, vector_origin)
			self:GetWM():ManipulateBoneScale(46, vector_origin)
		end,
	}
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.HeldMagModel = "models/weapons/arc9/darsu_eft/mods/mag_mp5_hk_std_curved_9x19_30.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 20
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 18
SWEP.animposmul = 2
SWEP.Primary.Sound = {"weapons/darsu_eft/mp5/fire_new/mp5sd_outdoor_close_silenced_loop1.wav", 65, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/mp5/fire_new/mp5sd_outdoor_close_silenced_loop1.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.07
SWEP.ReloadTime = 4.5
SWEP.SetSupressor = true


SWEP.PPSMuzzleEffect = "muzzleflash_mp5"

SWEP.CustomShell = "9x19"
SWEP.ShellEject = "EjectBrass_9mm"

SWEP.LocalMuzzlePos = Vector(14.706, -0.488, 3.525)
SWEP.LocalMuzzleAng = Angle(0.4, 0.09, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mp5.png")
SWEP.IconOverride = "entities/arc9_eft_mp5.png"

SWEP.weight = 2.8
SWEP.ScrappersSlot = "Primary"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = Vector(-13, 1, 0.05),
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(6, 0.7, 0)},
		["mountType"] = {"picatinny"},
	},
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 7
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.0, 0, 0) * 1
end

SWEP.Ergonomics = 1.1
SWEP.WorldPos = Vector(4, -0.8, -0.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(1, 0, 0)
SWEP.attAng = Angle(-0.02, 0, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(7, 2, 0)

-- tpik hand positions
SWEP.RHPos = Vector(3, -7, 3.5)
SWEP.RHAng = Angle(0, -8, 90)
SWEP.LHPos = Vector(11, 1.6, -3)
SWEP.LHAng = Angle(-110, -180, 5)

SWEP.ShootAnimMul = 2

function SWEP:AnimHoldPost(model)
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	local wm = self:GetWM()
	if not IsValid(wm) then return end

	if not IsValid(self.HeldMagCSModel) then
		self.HeldMagCSModel = ClientsideModel(self.HeldMagModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldMagCSModel) then
			self.HeldMagCSModel:SetNoDraw(true)
		end
	end

	if not IsValid(self.HeldMagCSModel) then return end

	local boneName = self.HeldMagBone
	local boneID = wm:LookupBone(boneName)
	if not boneID then return end

	local boneMatrix = wm:GetBoneMatrix(boneID)
	if not boneMatrix then return end

	local pos = boneMatrix:GetTranslation()
	local ang = boneMatrix:GetAngles()

	local lpos, lang = LocalToWorld(self.HeldMagOffsetPos, self.HeldMagOffsetAng, pos, ang)

	self.HeldMagCSModel:SetRenderOrigin(lpos)
	self.HeldMagCSModel:SetRenderAngles(lang)
	self.HeldMagCSModel:SetPos(lpos)
	self.HeldMagCSModel:SetAngles(lang)
	self.HeldMagCSModel:SetupBones()
	self.HeldMagCSModel:DrawModel()
end


--========================================================
-- DROPPED EFT MODEL + MODULAR PARTS
--========================================================

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)

SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local BC_VECTOR_ZERO = Vector(0, 0, 0)
	local BC_ANGLE_ZERO = Angle(0, 0, 0)

	function SWEP:BC_CreateDroppedFakeWorldModel()
		if not self.WorldModelFake then return end
		if IsValid(self.BC_DroppedFakeWorldModel) then return end

		local model = ClientsideModel(self.WorldModelFake, RENDERGROUP_BOTH)
		if not IsValid(model) then return end

		model:SetNoDraw(true)
		model:DrawShadow(true)

		if self.FakeScale then
			model:SetModelScale(self.FakeScale, 0)
		end

		if self.FakeBodyGroups then
			model:SetBodyGroups(self.FakeBodyGroups)
		end

		if self.ModelCreated then
			self:ModelCreated(model)
		end

		self.BC_DroppedFakeWorldModel = model
	end

	function SWEP:BC_CreateDroppedPartModels()
		if not istable(self.ARC9Parts) then return end

		self.BC_DroppedPartModels = self.BC_DroppedPartModels or {}
		self.BC_DroppedPartPaths = self.BC_DroppedPartPaths or {}

		for partName, partData in pairs(self.ARC9Parts) do
			if not istable(partData) or not isstring(partData.model) or partData.model == "" then
				continue
			end

			local model = self.BC_DroppedPartModels[partName]
			local oldPath = self.BC_DroppedPartPaths[partName]

			if IsValid(model) and oldPath ~= partData.model then
				model:Remove()
				model = nil
			end

			if not IsValid(model) then
				model = ClientsideModel(partData.model, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.BC_DroppedPartModels[partName] = model
					self.BC_DroppedPartPaths[partName] = partData.model
				end
			end
		end
	end

	function SWEP:BC_RemoveDroppedModels()
		if self.BC_DroppedPartModels then
			for partName, model in pairs(self.BC_DroppedPartModels) do
				if IsValid(model) then model:Remove() end
			end
		end
		self.BC_DroppedPartModels = nil
		self.BC_DroppedPartPaths = nil

		if IsValid(self.BC_DroppedFakeWorldModel) then
			self.BC_DroppedFakeWorldModel:Remove()
		end
		self.BC_DroppedFakeWorldModel = nil
	end

	local function BC_ApplyPartAppearance(model, partData)
		if not IsValid(model) or not istable(partData) then return end

		if partData.skin ~= nil then
			model:SetSkin(partData.skin)
		end

		if istable(partData.bodygroups) then
			for bodygroupID, value in pairs(partData.bodygroups) do
				model:SetBodygroup(tonumber(bodygroupID) or bodygroupID, tonumber(value) or 0)
			end
		end

		if istable(partData.submaterials) then
			for materialID, materialPath in pairs(partData.submaterials) do
				model:SetSubMaterial(tonumber(materialID) or materialID, materialPath or "")
			end
		end
	end

	function SWEP:BC_DrawDroppedFakeWorldAndParts()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end

		if not IsValid(self.BC_DroppedFakeWorldModel) then
			self:BC_CreateDroppedFakeWorldModel()
		end

		self:BC_CreateDroppedPartModels()

		local basePosition, baseAngles = LocalToWorld(
			self.WorldPartsOffsetPos or BC_VECTOR_ZERO,
			self.WorldPartsOffsetAng or BC_ANGLE_ZERO,
			self:GetPos(),
			self:GetAngles()
		)

		local fake = self.BC_DroppedFakeWorldModel

		if IsValid(fake) then
			fake:SetRenderOrigin(basePosition)
			fake:SetRenderAngles(baseAngles)
			fake:SetPos(basePosition)
			fake:SetAngles(baseAngles)
			fake:InvalidateBoneCache()
			fake:SetupBones()
			fake:DrawModel()
		end

		if not istable(self.ARC9Parts) or not self.BC_DroppedPartModels then return end

		for partName, partData in pairs(self.ARC9Parts) do
			local model = self.BC_DroppedPartModels[partName]
			if not IsValid(model) or not istable(partData) then continue end

			local boneName = partData.bone or ""
			local extraPosition = BC_VECTOR_ZERO
			local extraAngles = BC_ANGLE_ZERO

			if partName == "magazine" and self.WorldMagazineBoneOverride then
				boneName = self.WorldMagazineBoneOverride
				extraPosition = self.WorldMagazineOffsetPos or BC_VECTOR_ZERO
				extraAngles = self.WorldMagazineOffsetAng or BC_ANGLE_ZERO
			end

			local partBasePosition = basePosition
			local partBaseAngles = baseAngles

			if IsValid(fake) and isstring(boneName) and boneName ~= "" then
				local boneID = fake:LookupBone(boneName)
				if boneID ~= nil then
					local boneMatrix = fake:GetBoneMatrix(boneID)
					if boneMatrix then
						partBasePosition = boneMatrix:GetTranslation()
						partBaseAngles = boneMatrix:GetAngles()
					end
				end
			end

			local localPosition = (partData.pos or BC_VECTOR_ZERO) + extraPosition
			local localAngles = Angle(
				(partData.ang or BC_ANGLE_ZERO).p,
				(partData.ang or BC_ANGLE_ZERO).y,
				(partData.ang or BC_ANGLE_ZERO).r
			)
			localAngles:Add(extraAngles)

			local position, angles = LocalToWorld(localPosition, localAngles, partBasePosition, partBaseAngles)

			model:SetRenderOrigin(position)
			model:SetRenderAngles(angles)
			model:SetPos(position)
			model:SetAngles(angles)

			BC_ApplyPartAppearance(model, partData)

			model:InvalidateBoneCache()
			model:SetupBones()
			model:DrawModel()
		end
	end

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:BC_DrawDroppedFakeWorldAndParts()
	end

	function SWEP:DrawWorldModelTranslucent()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:BC_DrawDroppedFakeWorldAndParts()
	end

	function SWEP:OnRemove()
		self:BC_RemoveDroppedModels()
		if IsValid(self.HeldMagCSModel) then
			self.HeldMagCSModel:Remove()
		end
	end
end

--========================================================
-- FIRE ANIMATION
--========================================================

SWEP.FireAnimTime = 0.07
SWEP.FireAnimCandidates = {"fire", "fire1"}

function SWEP:PrimaryShootPost()
	if not CLIENT then return end
	if self.reload then return end
	if not self:ShouldUseFakeModel() then return end

	local worldModel = self:GetWM()
	if not IsValid(worldModel) then return end

	local selectedSequence
	for _, sequenceName in ipairs(self.FireAnimCandidates) do
		local sequenceID = worldModel:LookupSequence(sequenceName)
		if sequenceID ~= nil and sequenceID >= 0 then
			selectedSequence = sequenceName
			break
		end
	end

	if not selectedSequence then return end

	self.AnimList.fire = selectedSequence
	self:PlayAnim("fire", self.FireAnimTime, false)

	local timerName = "BC_FireAnimation_" .. self:EntIndex()
	timer.Create(timerName, self.FireAnimTime, 1, function()
		if not IsValid(self) or self.reload then return end
		if self.Primary and (self.Primary.Next or 0) > CurTime() then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end
