if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Duct Tape"
SWEP.Instructions = "This is a roll of reinforced aluminum-colored waterproof polyethylene-coated vinyl-cloth adhesive tape. Use it to stick things together.\n\nHold LMB to stick something.\nYou can only put tape on a seam or close gap between two objects. \nPress R to change modes, taping mode and healing mode"
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.ClipSize = 0

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.ClipSize = 0
SWEP.Primary.Automatic = true

--__settings__--
SWEP.fastHitAllow = false
SWEP.HoldType = "slam"
SWEP.DamageType = DMG_CLUB
SWEP.Penetration = 2
SWEP.traceOffsetAng = Angle(70, -5, 0)
SWEP.traceOffsetVec = Vector(3, .5, 0)
SWEP.traceLen = 12
SWEP.offsetVec = Vector(4, -3.5, -1.5)
SWEP.offsetAng = Angle(90, 180, 0)
SWEP.HitSound = "Flesh.ImpactHard"
SWEP.HitSound2 = "Flesh.ImpactHard"
SWEP.HitWorldSound = "Flesh.ImpactHard"
SWEP.r_forearm = Angle(0, 15, 0)
SWEP.r_upperarm = Angle(5, -60, 15)
SWEP.r_hand = Angle(0, 0, 0)
SWEP.l_forearm = Angle(0, 0, 0)
SWEP.l_upperarm = Angle(0, 0, 0)

SWEP.weaponInvCategory = false
SWEP.DeploySnd = "physics/body/body_medium_impact_soft5.wav"
SWEP.HolsterSnd = ""
SWEP.modeNames = {
	[true] = "huy",
	[false] = "chlen"
}

SWEP.sprint_ang = Angle(20, 0, 0)
SWEP.sprint_pos = Vector(-5, 0, -5)
local clr, mat = Color(100, 100, 100, 255), "models/shiny"
function SWEP:Initialize()
	--self:SetModelScale(0.15)
	--self:SetColor(clr)
	--self:SetMaterial(mat)
	self:Activate()
	if IsValid(self:GetPhysicsObject()) then self:GetPhysicsObject():SetMass(5) end
end

function SWEP:InitializeAdd()
	--self:PhysicsInit(SOLID_VPHYSICS)
end

function SWEP:OwnerChanged()
	--self:SetModelScale(0.15)
	--self:SetColor(clr)
	--self:SetMaterial(mat)
	self:Activate()
	self:SetHoldType(self.HoldType)
	if IsValid(self:GetPhysicsObject()) then self:GetPhysicsObject():SetMass(5) end
end

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_ducttape")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_ducttape"
	SWEP.BounceWeaponIcon = false
end

--
SWEP.ViewModel = ""
SWEP.WorldModel = "models/distac/scotch.mdl"
SWEP.WorldModelReal = "models/distac/weapon/scotchanim.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.angHold = Angle(0, 0, 0)
SWEP.UnTapeables = {MAT_SAND, MAT_SLOSH, MAT_SNOW}
SWEP.TapeAmount = 100
SWEP.ShouldDeleteOnFullUse = true
SWEP.AnimList = {
	["start"] = {"start", 2.5, false},
	["stop"] = {"start", 1, false},
}

SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldPos = Vector(8, 0.2, -25)
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 120
game.AddDecal("hmcd_jackatape", "decals/mat_jack_hmcd_ducttape")

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "TapeAmount")
	self:SetTapeAmount(self.TapeAmount)
	self:NetworkVar("Float", 0, "Holding")
	self:NetworkVar("Bool", 0, "BandageMode")
	if CLIENT then self.visualBandage = self.visualBandage or self:GetBandageMode() end
end

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

--function SWEP:DrawWorldModel()
--	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
--	local WorldModel = self.model
--	local owner = self:GetOwner()
--	WorldModel:SetNoDraw(true)
--	--WorldModel:SetModelScale(0.15)
--	if IsValid(owner) then
--		local offsetVec = self.offsetVec
--		local offsetAng = self.offsetAng
--		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
--		if not boneid then return end
--		local matrix = owner:GetBoneMatrix(boneid)
--		if not matrix then return end
--		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
--		WorldModel:SetPos(newPos)
--		WorldModel:SetAngles(newAng)
--		WorldModel:SetupBones()
--	else
--		WorldModel:SetPos(self:GetPos())
--		WorldModel:SetAngles(self:GetAngles())
--	end
--
--	--WorldModel:SetColor(clr) -- поч не робит
--	--WorldModel:SetMaterial(mat)
--	
--	WorldModel:DrawModel()
--end

local bone, name
local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)
function SWEP:BoneSet(lookup_name, vec, ang)
	if IsValid(self:GetOwner()) and not self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

function SWEP:SetHandPos(noset)
	if self:GetBandageMode() or self.visualBandage then
		self.lhandik = false
		self.rhandik = false
		return
	end
	self.BaseClass.SetHandPos(self, noset)
end

function SWEP:Camera(eyePos, eyeAng, view, vellen, ply)
	if self:GetBandageMode() or self.visualBandage then
		self.camLerp = 0
		view.origin = eyePos
		return view
	end
	local tpikOrigin = self.BaseClass.Camera(self, eyePos, eyeAng, view, vellen, ply).origin
	self.camLerp = math.min(1, (self.camLerp or 0) + FrameTime() * 4)
	view.origin = eyePos + (tpikOrigin - eyePos) * self.camLerp
	return view
end

	function SWEP:DrawWorldModel2(nodraw)
		if CLIENT and (self.raiseT or 0) <= 0 and not self:GetBandageMode() and self.visualBandage then
			self.visualBandage = false
		end

		if not self.visualBandage then
		self.BaseClass.DrawWorldModel2(self, nodraw)
		return
	end

	if not IsValid(self:GetOwner()) then
		if CLIENT then
			self.ductWM = IsValid(self.ductWM) and self.ductWM or ClientsideModel(self.WorldModel)
			local mdl = self.ductWM
			mdl:SetNoDraw(true)
			mdl:SetPos(self:GetPos())
			mdl:SetAngles(self:GetAngles())
			mdl:SetupBones()
			mdl:DrawModel()
		end
		return
	end

	if CLIENT then
		self.ductWM = IsValid(self.ductWM) and self.ductWM or ClientsideModel(self.WorldModel)
		local WorldModel = self.ductWM
		WorldModel:SetNoDraw(true)

		local owner = self:GetOwner()
		local offsetVec = self.bandageOffsetVec or Vector(4, -3.5, 0)
		local offsetAng = self.bandageOffsetAng or Angle(90, 90, 0)
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		if self.raiseT > 0 then
			newPos = newPos - owner:EyeAngles():Up() * (self.raiseT * 22)
		end
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
		if not nodraw then WorldModel:DrawModel() end
	end
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	if self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated then return end
	local hold = self:GetHolding()
	if self:GetBandageMode() or self.visualBandage then
		local aimvec = self:GetOwner():GetAimVector()
		self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 4, -30 + hold / 2 + 20 * aimvec[3], 5 - hold / 3.5))
		self:BoneSet("r_forearm", vector_origin, Angle(hold / 10, -hold / 2.5, 35 - hold / 1.5))
		return
	end
	self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold / 1.5, 10))
	self:BoneSet("r_forearm", vector_origin, Angle(0, hold / 1, 0))
	self:BoneSet("l_upperarm", vector_origin, lang1)
	self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:Think()
	if CLIENT then
		local bm = self:GetBandageMode()
		if bm ~= self._visBM then
			self._visBM = bm
			self.visualBandage = bm
			self.raiseT = bm and 1 or 0
		end
		self.raiseT = math.max(0, (self.raiseT or 0) - FrameTime() * 2)
	end

	local owner = self:GetOwner()
	if IsValid(owner) and owner:KeyDown(IN_ATTACK) then return end
	self:SetHolding(math.max(self:GetHolding() - 1, 25))
	self:PlayAnim('start', 0)
end

function SWEP:CustomTiming()
	self.lasttapeamount = self.lasttapeamount or self:GetTapeAmount()
	if self:GetTapeAmount() < self.lasttapeamount then
		self.LerpedHolding = 0.25
		self.lasttapeamount = self:GetTapeAmount()
	end

	if CLIENT then
		self.raiseT = math.max(0, (self.raiseT or 0) - FrameTime() * 2)
	end

	self.LerpedHolding = math.Clamp(LerpFT(0.01, self.LerpedHolding or 0, self:GetHolding() / 100), 0, 0.68)
	self.setlh = not (self.LerpedHolding <= 0.26)
	return self.LerpedHolding
end

if CLIENT then
	local Mat = Material("vgui/wep_jack_hmcd_ducttape")
	local mul = 1
	function SWEP:DrawHUD()
		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(Mat)
		surface.DrawTexturedRect(ScrW() - 352.5, ScrH() - 252.5, 306, 156)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Mat)
		mul = Lerp(FrameTime() * 15, mul, (self:GetTapeAmount() + 10) / 100)
		surface.DrawTexturedRectUV(ScrW() - 350, ScrH() - 250, 300 * mul, 150, 0, 0, 1 * mul, 1)
		local Owner = self:GetOwner()
		local toScreen = self:GetEyeTrace().HitPos:ToScreen()
		for i = 1, 10 do
			surface.DrawCircle(toScreen.x, toScreen.y, 55 - i, 155 - i * 15, 155 - i * 15, 155 - i * 15, 205)
		end
	end
end

local function BindObjects(ent1, pos1, ent2, pos2, power, bone1, bone2)
	ent1.DuctTape = ent1.DuctTape or {}
	ent2.DuctTape = ent2.DuctTape or {}
	local Strength = ent1.DuctTape and ent1.DuctTape[bone1] and #ent1.DuctTape[bone1] or 1
	local weld = not ent1:IsRagdoll() and not ent2:IsRagdoll() and constraint.Rope(ent1, ent2, 0, 0, ent1:WorldToLocal(pos1), ent2:WorldToLocal(pos2), (pos1 - pos2):Length(), -.1, (500 + Strength * 100) * 5, 0, "", false) or constraint.Weld(ent1, ent2, bone1, bone2, (500 + Strength * 100) * 15, false, false)
	if not ent1.DuctTape[bone1] then
		ent1.DuctTape[bone1] = {weld, 1}
		weld:CallOnRemove("removefromtbl", function() ent1.DuctTape[bone1] = nil end)
	else
		ent1.DuctTape[bone1][2] = ent1.DuctTape[bone1][2] + 1
	end

	if not ent2.DuctTape[bone2] then
		ent2.DuctTape[bone2] = {weld, 1}
		weld:CallOnRemove("removefromtbl", function() ent2.DuctTape[bone2] = nil end)
	else
		ent2.DuctTape[bone2][2] = ent2.DuctTape[bone2][2] + 1
	end
	return ent1:IsWorld() and ent2.DuctTape[bone2][2] or ent1.DuctTape[bone1][2]
end

function hgCheckDuctTapeObjects(ent1)
	if not ent1.DuctTape then return end
	return (ent1.DuctTape and ent1.DuctTape[0] and #ent1.DuctTape[0]) or 0
end

if SERVER then
	hook.Add("Should Fake Up", "DuctTaped", function(ply)
		if ply and IsValid(ply.FakeRagdoll) then
			local dtape = ply.FakeRagdoll.DuctTape
			if dtape then
				for i, tbl in pairs(dtape) do
					if tbl[2] > 0 then
						tbl[2] = tbl[2] - 0.2
						ply.FakeRagdoll:EmitSound("tape_friction" .. math.random(3) .. ".mp3", 65)
						if tbl[2] <= 0 then
							if IsValid(tbl[1]) then
								tbl[1]:Remove()
								tbl[1] = nil
							end

							dtape[i] = nil
						end

						break
					end
				end

				if table.Count(dtape) > 0 then
					ply.fakecd = CurTime() + 1
					return false
				end
			end
		end
	end)
end

local function LimbGroup(boneName)
	if not boneName then return nil end
	if boneName:find("Head") then return "skull" end
	if boneName:find("Spine2") or boneName:find("Chest") then return "chest" end
	if boneName:find("Spine1") or boneName:find("Spine") or boneName:find("Pelvis") then return "pelvis" end
	if boneName:find("L_Thigh") or boneName:find("L_Calf") then return "lleg" end
	if boneName:find("R_Thigh") or boneName:find("R_Calf") then return "rleg" end
	if boneName:find("L_UpperArm") or boneName:find("L_Forearm") or boneName:find("L_Hand") then return "larm" end
	if boneName:find("R_UpperArm") or boneName:find("R_Forearm") or boneName:find("R_Hand") then return "rarm" end
	return nil
end

local function NearestBoneName(ent, pos)
	if not IsValid(ent) or not pos then return nil end
	ent:SetupBones()
	local best, bestd = nil, math.huge
	for i = 0, ent:GetBoneCount() - 1 do
		local m = ent:GetBoneMatrix(i)
		if not m then continue end
		local d = m:GetTranslation():DistToSqr(pos)
		if d < bestd then bestd, best = d, ent:GetBoneName(i) end
	end
	return best
end

if SERVER then
	function SWEP:Bandage(ent, bone)
		local org = ent.organism
		local owner = self:GetOwner()
		if not org then return end

		local tape = self:GetTapeAmount()
		local tapeStart = tape


		if tape <= 0 or not (#org.wounds > 0 or org.lleg == 1 or org.rleg == 1 or org.skull >= 0.6 or org.chest == 1 or org.rarm == 1 or org.larm == 1) then return end
		table.sort(org.wounds, function(a, b) return a[1] > b[1] end)

		local done = false
		local bandaged = false

		if not bone then
			for i = 1, #org.wounds do
				if tape > 0 and #org.wounds > 0 then
					local biggestWound = org.wounds[1][1]
					local healedWound = math.max(biggestWound - tape, 0)
					local woundHeal = tape - (biggestWound - healedWound)
					org.bleed = math.max(org.bleed - (biggestWound - healedWound), 0)
					org.wounds[1][1] = healedWound
					tape = woundHeal > 0.1 and woundHeal or 0

					if (biggestWound - healedWound) > 0.1 then
						bandaged = true
					end

					ent.ducttaped_limbs = ent.ducttaped_limbs or {}
					local bone_name = org.wounds[1][4]
					if not ent.ducttaped_limbs[bone_name] then
						ent.ducttaped_limbs[bone_name] = true
						done = true
					end
					if org.wounds[1][1] == 0 then table.remove(org.wounds, 1) end
				end
			end
		else
			local bonewounds = {}

		for i, tbl in pairs(org.wounds) do
			if LimbGroup(tbl[4]) == bone then
				table.insert(bonewounds, i)
			end
		end

			for i = 1, #bonewounds do
				if tape ~= 0 and #bonewounds > 0 then
					if org.wounds[bonewounds[1]] then
						local biggestWound = org.wounds[bonewounds[1]][1]
						local healedWound = math.max(biggestWound - tape, 0)
						local woundHeal = tape - (biggestWound - healedWound)
						org.bleed = math.max(org.bleed - (biggestWound - healedWound), 0)
						org.wounds[bonewounds[1]][1] = healedWound
						tape = woundHeal

						org.pain = math.max(org.pain - (biggestWound - healedWound) / 4, 0)

						if (biggestWound - healedWound) > 0.1 then
							bandaged = true
						end

						ent.ducttaped_limbs = ent.ducttaped_limbs or {}
						local bone_name = ent:GetBoneName(ent:LookupBone(org.wounds[bonewounds[1]][4]))

						if not ent.ducttaped_limbs[bone_name] then
							ent.ducttaped_limbs[bone_name] = true
							done = true
						end

						if org.wounds[bonewounds[1]][1] == 0 then table.remove(org.wounds, bonewounds[1]) end
					end
					table.remove(bonewounds, 1)
				end
			end
		end
		org.owner:SetNetVar("wounds", org.wounds)
		timer.Create("bandage_limbs" .. ent:EntIndex(), 0.1, 1, function()
 			ent:SetNetVar("ducttaped_limbs", ent.ducttaped_limbs)
			if ent:IsRagdoll() and hg.RagdollOwner(ent) and hg.RagdollOwner(ent):Alive() then
				hg.RagdollOwner(ent):SetNetVar("ducttaped_limbs", ent.ducttaped_limbs)
			end
		end)

		local amt = 25
		if (not bone or bone == "skull") and org.skull >= 0.6 and tape >= amt then
			org.skull = 0.59
			tape = tape - amt
			org.bandagedskull = true
			org.pain = math.max(org.pain - 7, 0)
			done = true
		end

		if (not bone or bone == "chest") and org.chest == 1 and tape >= amt then
			org.chest = org.chest - 0.05
			tape = tape - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if (not bone or bone == "lleg") and org.lleg == 1 and tape >= amt and not org.llegamputated then
			org.lleg = org.lleg - 0.05
			tape = tape - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if (not bone or bone == "rleg") and org.rleg == 1 and tape >= amt and not org.rlegamputated then
			org.rleg = org.rleg - 0.05
			tape = tape - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if (not bone or bone == "rarm") and org.rarm == 1 and tape >= amt and not org.rarmamputated then
			org.rarm = org.rarm - 0.05
			tape = tape - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if (not bone or bone == "larm") and org.larm == 1 and tape >= amt and not org.larmamputated then
			org.larm = org.larm - 0.05
			tape = tape - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if tape < tapeStart then
			owner:EmitSound("snd_jack_hmcd_bandage.wav", 60, math.random(95, 105))
		end

		self:SetTapeAmount(tape)
		return done
	end

	function SWEP:Heal(ent, bone)
		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 10, 100))
		end
		local done = self:Bandage(ent, bone)
		if self:GetTapeAmount() <= 0 and self.ShouldDeleteOnFullUse then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end

		return done
	end
end

function SWEP:FindObjects()
	local Owner = self:GetOwner()
	local Pos, Vec, GotOne, Tries, TrOne, TrTwo = select(1, hg.eye(Owner)), Owner:GetAimVector(), false, 0, nil, nil
	while not GotOne and (Tries < 100) do
		local Tr = util.QuickTrace(Pos - Vec * 10, Vec * 60, {Owner})
		local FindBone = util.QuickTrace(Pos, Vec * 60, {Owner})
		if Tr.Hit and not Tr.HitSky and not table.HasValue(self.UnTapeables, Tr.MatType) then
			GotOne = true
			TrOne = Tr
			TrOne.PhysicsBone = FindBone.PhysicsBone
		end

		Tries = Tries + 1
	end

	if GotOne then
		GotOne = false
		Tries = 0
		while not GotOne and (Tries < 100) do
			local Tr = util.QuickTrace(Pos - Vec * 10, Vec * 60 + VectorRand() * 1, {Owner, TrOne.Entity})
			local FindBone = util.QuickTrace(Pos, Vec * 60, {Owner, TrOne.Entity})
			if Tr.Hit and not Tr.HitSky and not table.HasValue(self.UnTapeables, Tr.MatType) and (Tr.Entity ~= TrOne.Entity) then
				GotOne = true
				TrTwo = Tr
				TrTwo.PhysicsBone = FindBone.PhysicsBone
			end

			Tries = Tries + 1
		end
	end

	if TrOne and TrTwo then
		return true, TrOne, TrTwo
	else
		return false, nil, nil
	end
end

function SWEP:PrimaryAttack()
	if self:GetBandageMode() then
		if SERVER then
			local tr = hg.eyeTrace(self:GetOwner())
			local ent = tr.Entity
			local chr = self:GetOwner()
			local bone
			if IsValid(ent) then
				local tchr = hg.GetCurrentCharacter(ent)
				if tchr == hg.GetCurrentCharacter(self:GetOwner()) then
					bone = LimbGroup(NearestBoneName(ent, tr.HitPos))
				end
			end
			self:Heal(chr, bone)
		end
		return
	end
	local Owner = self:GetOwner()
	if Owner:KeyDown(IN_SPEED) then return end
	if not hg.CanUseLeftHand(Owner) or not hg.CanUseRightHand(Owner) then return end
	if self:GetHolding() == 25 or self:GetHolding() == 95 then
		self:EmitSound("player/clothes_generic_foley_0"..math.random(5)..".wav", 55, math.random(95, 105), 0.25)
	end

	if SERVER then
		if not self.TapeAmount then self.TapeAmount = 100 end
		local Go, TrOne, TrTwo = self:FindObjects()
		self:SetHolding(math.Clamp(self:GetHolding() + 1, 25, 100))
		if Go then
			if self:GetHolding() < 100 then return end
			local DoorSealed = false
			if hgIsDoor(TrOne.Entity) then
				DoorSealed = true
				if not DoorIsOpen(TrOne.Entity) then
					if not TrOne.Entity.LockedDoor then TrOne.Entity.LockedDoorMap = true end
				else
					TrOne.Entity.LockedDoorMap = false
				end

				TrOne.Entity:Fire("lock", "", 0)
				TrOne.Entity.LockedDoor = self.TapeAmount
			end

			if hgIsDoor(TrTwo.Entity) then
				DoorSealed = true
				if not DoorIsOpen(TrTwo.Entity) then
					if not TrTwo.Entity.LockedDoor then TrTwo.Entity.LockedDoorMap = true end
				else
					TrTwo.Entity.LockedDoorMap = false
				end

				TrTwo.Entity:Fire("lock", "", 0)
				TrTwo.Entity.LockedDoor = self.TapeAmount
			end

			if DoorSealed then
				self.TapeAmount = self.TapeAmount - 100
				self:SetTapeAmount(self.TapeAmount)
				sound.Play("snd_jack_hmcd_ducttape.wav", TrOne.HitPos, 65, math.random(80, 120))
				Owner:SetAnimation(PLAYER_ATTACK1)
				Owner:ViewPunch(Angle(3, 0, 0))
				self:SprayDecals()
				Owner:PrintMessage(HUD_PRINTCENTER, "Door Sealed")
				timer.Simple(.1, function() if self.TapeAmount <= 0 then self:Remove() end end)
				self:SetHolding(25)
			else
				local Strength = BindObjects(TrOne.Entity, TrOne.HitPos, TrTwo.Entity, TrTwo.HitPos, 2, TrOne.PhysicsBone, TrTwo.PhysicsBone)
				if not self.TapeAmount then self.TapeAmount = 100 end
				self.TapeAmount = self.TapeAmount - 10
				self:SetTapeAmount(self.TapeAmount)
				sound.Play("snd_jack_hmcd_ducttape.wav", TrOne.HitPos, 65, math.random(80, 120))
				Owner:SetAnimation(PLAYER_ATTACK1)
				Owner:ViewPunch(Angle(3, 0, 0))
				util.Decal("hmcd_jackatape", TrOne.HitPos + TrOne.HitNormal, TrOne.HitPos - TrOne.HitNormal)
				util.Decal("hmcd_jackatape", TrTwo.HitPos + TrTwo.HitNormal, TrTwo.HitPos - TrTwo.HitNormal)
				--Owner:PrintMessage(HUD_PRINTCENTER,"Bond strength: "..tostring(Strength))
				Owner:ChatPrint("Bond strength: " .. tostring(Strength))
				timer.Simple(.1, function() if self.TapeAmount <= 0 then self:Remove() end end)
				self:SetHolding(25)
			end
		end
	end

	--self:SetNextPrimaryFire(CurTime() + 1.5)
end

function SWEP:SecondaryAttack()
	if self:GetBandageMode() then
		if SERVER then
			local tr = hg.eyeTrace(self:GetOwner())
			local ent = tr.Entity
			if not IsValid(ent) then return end
			local chr = hg.GetCurrentCharacter(ent)
			if not chr or chr == hg.GetCurrentCharacter(self:GetOwner()) then return end
			local bone = LimbGroup(NearestBoneName(ent, tr.HitPos))
			self:Heal(chr, bone)
		end
		return
	end
end

function SWEP:CanSecondaryAttack()
	return self:GetBandageMode() and true or false
end

function SWEP:Reload()
	if SERVER and self:GetOwner():KeyPressed(IN_RELOAD) then
		local mode = not self:GetBandageMode()
		self:SetBandageMode(mode)
	end
end

function SWEP:SprayDecals()
	local Owner = self:GetOwner()
	local pos = select(1, hg.eye(Owner))
	local aim = Owner:GetAimVector()
	local Tr = util.QuickTrace(pos, aim * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
	local Tr2 = util.QuickTrace(pos, (aim + Vector(0, 0, .15)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr2.HitPos + Tr2.HitNormal, Tr2.HitPos - Tr2.HitNormal)
	local Tr3 = util.QuickTrace(pos, (aim + Vector(0, 0, -.15)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr3.HitPos + Tr3.HitNormal, Tr3.HitPos - Tr3.HitNormal)
	local Tr4 = util.QuickTrace(pos, (aim + Vector(0, .15, 0)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr4.HitPos + Tr4.HitNormal, Tr4.HitPos - Tr4.HitNormal)
	local Tr5 = util.QuickTrace(pos, (aim + Vector(0, -.15, 0)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr5.HitPos + Tr5.HitNormal, Tr5.HitPos - Tr5.HitNormal)
	local Tr6 = util.QuickTrace(pos, (aim + Vector(.15, 0, 0)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr6.HitPos + Tr6.HitNormal, Tr6.HitPos - Tr6.HitNormal)
	local Tr7 = util.QuickTrace(pos, (aim + Vector(-.15, 0, 0)) * 70, {Owner})
	util.Decal("hmcd_jackatape", Tr7.HitPos + Tr7.HitNormal, Tr7.HitPos - Tr7.HitNormal)
end

if CLIENT then
	local DucttapeModelMale = "models/distac/newbandage.mdl"
	local DucttapeModelFemale = "models/distac/newbandage_f.mdl"
	local DuctTapeMat = CreateMaterial("ducttapemat", "VertexLitGeneric", {
		["$basetexture"] = "models/debug/debugwhite",
		["$color"] = "0.62 0.62 0.6",
		["$detail"] = "models/debug/debugwhite",
	})
	local DuctBodyGroupsMale = {
		["ValveBiped.Bip01_Pelvis"] = "belly",
		["ValveBiped.Bip01_Spine"] = "groin",
		["ValveBiped.Bip01_Spine1"] = "belly",
		["ValveBiped.Bip01_Spine2"] = "Chest",
		["ValveBiped.Bip01_L_UpperArm"] = "HandUpLeft",
		["ValveBiped.Bip01_L_Forearm"] = "HandDownLeft",
		["ValveBiped.Bip01_L_Hand"] = "HandLeft",
		["ValveBiped.Bip01_R_UpperArm"] = "HandUpRight",
		["ValveBiped.Bip01_R_Forearm"] = "HandDownRight",
		["ValveBiped.Bip01_R_Hand"] = "HandRight",
		["ValveBiped.Bip01_L_Thigh"] = "LegUpLeft",
		["ValveBiped.Bip01_L_Calf"] = "LegDownLeft",
		["ValveBiped.Bip01_R_Thigh"] = "LegUpRught",
		["ValveBiped.Bip01_R_Calf"] = "LegDownRught",
	}
	local DuctBodyGroupsFemale = {
		["ValveBiped.Bip01_Pelvis"] = "belly-f",
		["ValveBiped.Bip01_Spine"] = "groin-f",
		["ValveBiped.Bip01_Spine1"] = "belly-f",
		["ValveBiped.Bip01_Spine2"] = "Chest-f",
		["ValveBiped.Bip01_L_UpperArm"] = "HandUpLeft-f",
		["ValveBiped.Bip01_L_Forearm"] = "HandDownLeft-f",
		["ValveBiped.Bip01_L_Hand"] = "HandLeft-f",
		["ValveBiped.Bip01_R_UpperArm"] = "HandUpRight-f",
		["ValveBiped.Bip01_R_Forearm"] = "HandDownRight-f",
		["ValveBiped.Bip01_R_Hand"] = "HandRight-f",
		["ValveBiped.Bip01_L_Thigh"] = "LegUpLeft-f",
		["ValveBiped.Bip01_L_Calf"] = "LegDownLeft-f",
		["ValveBiped.Bip01_R_Thigh"] = "LegUpRught-f",
		["ValveBiped.Bip01_R_Calf"] = "LegDownRught-f",
	}

	local function remove_ducttapes(ent)
		if IsValid(ent.ducttapesModel) then
			ent.ducttapesModel:Remove()
		end
		ent.ducttapesModel = nil
	end

	hook.Add("OnNetVarSet", "ducttape_netvar", function(index, key, var)
		if key == "ducttaped_limbs" then
			local ent = Entity(index)
			if IsValid(ent) then
				remove_ducttapes(ent)
				ent.ducttaped_limbs = var
				ent:CallOnRemove("remove_ducttapes", function()
					remove_ducttapes(ent)
				end)
			end
		end
	end)

	function hg.RenderDuctTape(ent, ply)
		if not ent.ducttaped_limbs then return end
		if not next(ent.ducttaped_limbs) then return end
		if not IsValid(ent.ducttapesModel) then
			ent.ducttapesModel = (ThatPlyIsFemale(ent) and ClientsideModel(DucttapeModelFemale) or ClientsideModel(DucttapeModelMale))
			local model = ent.ducttapesModel
			ent:CallOnRemove("removeducttapes", function()
				if IsValid(model) then model:Remove(); model = nil end
			end)
		end

		local model = ent.ducttapesModel
		model:SetNoDraw(true)
		model:SetPos(ent:GetPos() + vector_up * 1)
		model:SetParent(ent)
		model:AddEffects(EF_BONEMERGE)
		model:SetMaterial("ducttapemat")
		local dontmakehands = false
		if not hg.Appearance.FuckYouModels[1][ent:GetModel()] and not hg.Appearance.FuckYouModels[2][ent:GetModel()] then dontmakehands = true end

		if not model.BodygroupsApplied then
			for k, v in pairs(ent.ducttaped_limbs) do
				if dontmakehands and (k == "ValveBiped.Bip01_L_Hand" or k == "ValveBiped.Bip01_R_Hand") then continue end
				model:SetBodygroup(model:FindBodygroupByName(ThatPlyIsFemale(ent) and DuctBodyGroupsFemale[k] or DuctBodyGroupsMale[k] or ""), 1)
			end

			for k, v in pairs(hg.amputatedlimbs2) do
				local children = hg.get_children(ent, k)
				table.insert(children, k)
				for k2, v2 in ipairs(children) do
					if ent.ducttaped_limbs[v2] and ent.organism and ent.organism[hg.amputatedlimbs2[v2] .. "amputated"] then
						model:SetBodygroup(model:FindBodygroupByName(ThatPlyIsFemale(ent) and DuctBodyGroupsFemale[v2] or DuctBodyGroupsMale[v2] or ""), 0)
					end
				end
			end

			model.BodygroupsApplied = true
		end
		model:DrawModel()
	end

	hook.Add("CoolPostDrawAppearance", "ducttape_render", function(ent, ply)
		if IsValid(ent) then hg.RenderDuctTape(ent, ply) end
	end)
end

if SERVER then
	hook.Add("Fake", "ducttape-setfake", function(ply, ragdoll)
		if not IsValid(ragdoll) then return end
		ragdoll.ducttaped_limbs = table.Copy(ply.ducttaped_limbs or {})
		ply:SetNetVar("ducttaped_limbs", ply.ducttaped_limbs or {})
		ragdoll:SetNetVar("ducttaped_limbs", ragdoll.ducttaped_limbs)
	end)

	hook.Add("Player Spawn", "remove-ducttapes", function(ply)
		if OverrideSpawn then return end
		ply:SetNetVar("ducttaped_limbs", {})
		ply.ducttaped_limbs = {}
	end)

	hook.Add("Player_Death", "remove-ducttapes-huy", function(ply)
		if IsValid(ply.FakeRagdoll) then
			ply.FakeRagdoll.ducttaped_limbs = table.Copy(ply.ducttaped_limbs or {})
			ply.FakeRagdoll:SetNetVar("ducttaped_limbs", ply.FakeRagdoll.ducttaped_limbs)
		end
		ply:SetNetVar("ducttaped_limbs", {})
		ply.ducttaped_limbs = {}
	end)
end