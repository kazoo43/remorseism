SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TEC-9"
SWEP.Author = "Intratec"
SWEP.Instructions = "Semi-automatic pistol chambered in 9x19 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/tec9/w_tec9.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_uc_tec9.mdl"
SWEP.FakeAttachment = "1"
SWEP.FakePos = Vector(-12.6, 3.4, -2.7)
SWEP.FakeAng = Angle(0 , 0, 0)
SWEP.FakeDropPos = Vector(-12.6, 3.4, -2.7)
SWEP.FakeDropAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.AnimList = {
	idle = "idle",
	reload = "reload",
	reload_empty = "reload_empty"
}

SWEP.WepSelectIcon2 = Material("entities/zcity/tec9.png")
SWEP.IconOverride = "entities/zcity/tec9.png"
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,3,2)
SWEP.EjectAng = Angle(-80,-90,0)

SWEP.IsPistol = true

SWEP.weight = 1
SWEP.podkid = 0.5

SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(9, 0.1, 2.7)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 20
SWEP.Primary.Sound = {"weapons/uc_tec9/fire-04.ogg", 75, 100, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 4.3
SWEP.FakeReloadSounds = {
	[0.16] = "weapons/uc_tec9/mech-01.ogg",
	[0.40] = "weapons/uc_tec9/magout.ogg",
	[0.63] = "weapons/uc_tec9/magin.ogg"
}
SWEP.FakeEmptyReloadSounds = {
	[0.16] = "weapons/uc_tec9/mech-01.ogg",
	[0.40] = "weapons/uc_tec9/magout.ogg",
	[0.63] = "weapons/uc_tec9/magin.ogg",
	[0.88] = "weapons/uc_tec9/chback.ogg",
	[0.96] = "weapons/uc_tec9/chforward.ogg"
}
SWEP.FakeReloadEvents = {}
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, 0.1048, 3.5972)

SWEP.RHandPos = Vector(-5, -0.5, -1)
SWEP.LHandPos = false
SWEP.OpenBolt = true
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
function SWEP:ModelCreated(model)
	model:SetBodyGroups("000000000")
	local bone = model:LookupBone("mag2")
	if bone then model:ManipulateBoneScale(bone, vector_origin) end
end

SWEP.WorldPos = Vector(1, -1, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(0, 4, 4)
SWEP.holsteredAng = Angle(25, -70, -90)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(8,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(4.5,-2,-2.5)
SWEP.LHAng = Angle(-5,0,-90)

if CLIENT then
	concommand.Add("tec9_compare_worldmodel", function()
		local ply = LocalPlayer()
		local wep = IsValid(ply) and ply:GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "weapon_tec9" then return end

		wep.Tec9CompareWorldModel = not wep.Tec9CompareWorldModel
		if not wep.Tec9CompareWorldModel and IsValid(wep.Tec9WorldModelPreview) then
			wep.Tec9WorldModelPreview:Remove()
			wep.Tec9WorldModelPreview = nil
		end
	end)

	function SWEP:DrawPost()
		local model = self:GetWM()
		if self.Tec9CompareWorldModel and IsValid(model) then
			local preview = self.Tec9WorldModelPreview
			if not IsValid(preview) then
				preview = ClientsideModel(self.WorldModel, RENDERGROUP_BOTH)
				if not IsValid(preview) then return end
				self.Tec9WorldModelPreview = preview
				preview:SetNoDraw(true)
				preview:SetMaterial("models/wireframe")
				preview:SetColor(Color(80, 220, 255, 180))
				self:CallOnRemove("tec9_worldmodel_preview", function()
					if IsValid(preview) then preview:Remove() end
				end)
			end

			local _, _, pos, ang = self:WorldModel_Transform(true)
			if pos and ang then
				local previewPos, previewAng = LocalToWorld(self.WorldPos, self.WorldAng + (self.WorldAng2 or angle_zero), pos, ang)
				previewAng:RotateAroundAxis(previewAng:Forward(), 180)
				preview:SetPos(previewPos)
				preview:SetAngles(previewAng)
				preview:SetupBones()
				preview:DrawModel()
			end
		elseif IsValid(self.Tec9WorldModelPreview) then
			self.Tec9WorldModelPreview:Remove()
			self.Tec9WorldModelPreview = nil
		end

		if IsValid(model) then
			self.boltAnim = LerpFT(0.25, self.boltAnim or 0, 0)
			model:ManipulateBonePosition(41, Vector(0, -self.boltAnim, 0), false)
		end

		if self.mag2Reload and not self.reload then
			self.mag2Reload = nil
			self:SetMag2Visible(false)
		end
	end

	function SWEP:SetMag2Visible(visible)
		local model = self:GetWM()
		if not IsValid(model) then return end
		local bone = model:LookupBone("mag2")
		if bone then model:ManipulateBoneScale(bone, visible and Vector(1, 1, 1) or vector_origin) end
	end

	function SWEP:ReloadStartPost()
		self.mag2Reload = self:Clip1() > 0
		if self.mag2Reload then self:SetMag2Visible(true) end
	end

end

function SWEP:ShouldUseFakeModel()
	return IsValid(self:GetOwner()) and self.WorldModelFake
end

function SWEP:PrimaryShootPost()
	self.boltAnim = 7
end

function SWEP:PrimaryShootEmpty()
	if SERVER then self:PlaySnd(self.Primary.SoundEmpty, true, CHAN_AUTO) end
end
