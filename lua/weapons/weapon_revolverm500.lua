SWEP.Base = "weapon_revolver2"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Smith & Wesson M500"
SWEP.Author = "Smith & Wesson"
SWEP.Instructions = "Revolver chambered in .500 S&W Magnum"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_ins2_revolver_sw500.mdl"
SWEP.WorldModelFake = "models/weapons/c_ins2_revolver_sw500.mdl"

SWEP.FakePos = Vector(-16, 0, 4)
SWEP.FakeAng = Angle(0, 0.1, 3)
SWEP.AttachmentPos = Vector(0, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "muzzle"

SWEP.AnimList = {
	idle = "base_idle",
	reload = "base_reload_speed",
	reload_empty = "base_reload_speed",
	fire = "base_dryfire",
	dryfire = "base_dryfire"
}

SWEP.FakeReloadSounds = {
	[0.18] = "weapons/sw500/sw500_openchamber.wav",
	[0.30] = "weapons/sw500/sw500_dumprounds1.wav",
	[0.62] = "weapons/sw500/sw500_roundin.wav",
	[0.90] = "weapons/sw500/sw500_closechamber.wav"
}
SWEP.FakeEmptyReloadSounds = {
	[0.18] = "weapons/sw500/sw500_openchamber.wav",
	[0.30] = "weapons/sw500/sw500_dumprounds2.wav",
	[0.62] = "weapons/sw500/sw500_roundin.wav",
	[0.90] = "weapons/sw500/sw500_closechamber.wav"
}
SWEP.FakeReloadEvents = {}
SWEP.availableAttachments = {}
SWEP.MagIndex = false

function SWEP:RevolverPostInit()
	self.FakeReloadEvents = {}
	self:MapEvents()
	self.Drum = {1, 1, 1, 1, 1}
	if SERVER then self:SendDrum() end
end

function SWEP:ShiftDrum(val)
	val = math.Round(val) % 5
	local drum = table.Copy(self.Drum)
	for i = 1, 5 do
		self.Drum[i] = drum[(i + val - 1) % 5 + 1]
	end
	self:SetNWInt("drumroll", self:GetNWInt("drumroll", 0) + val)
	if SERVER then self:SendDrum() end
	if CLIENT then self.DrumLastPredicted = CurTime() + 0.5 end
end

function SWEP:GetDrum()
	local data = string.Split(self:GetNWString("drum", "1 1 1 1 1"), " ")
	if (self.DrumLastPredicted or 0) < CurTime() then
		for i = 1, 5 do
			self.Drum[i] = tonumber(data[i]) or 0
		end
	end
	return self.Drum
end

function SWEP:InsertAmmo(need)
	local owner = self:GetOwner()
	local ammo = self:GetPrimaryAmmoType()
	if not owner.GetAmmoCount then self:SetClip1(self:GetMaxClip1()) return end

	if SERVER then
		owner:GiveAmmo(self:Clip1(), ammo, true)
		self:SetClip1(0)
	end

	local count = owner:GetAmmoCount(ammo)
	need = math.min(count, self:GetMaxClip1())
	self:SetClip1(need)
	for i = 1, 5 do
		self.Drum[i] = i <= need and 1 or 0
	end
	if SERVER then self:SendDrum() end
	owner:SetAmmo(count - need, ammo)
end

SWEP.WepSelectIcon2 = Material("entities/tfa_ins2_s&w_500.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/tfa_ins2_s&w_500.png"
SWEP.PPSMuzzleEffect = "muzzleflash_pistol_rbull"
SWEP.weight = 4
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2	

SWEP.LocalMuzzlePos = Vector(9, -1.98, 3.16)
SWEP.LocalMuzzleAng = Angle(0, -0.02, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)
SWEP.ShellEject = false
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".50 Action Express"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 60
SWEP.DamageMultiplier = 1.35
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 60
SWEP.Primary.Sound = {"weapons/sw500/sw500_fire.wav", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/sw500/revolver_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.25
SWEP.ReloadTime = 4

local function finishFire(self)
	if not self.reload and (self.seq == "base_fire" or self.seq == "base_dryfire") then
		self:PlayAnim("idle", 1, true)
	end
end

function SWEP:PrimaryShootPost()
	self:PlayAnim("fire", self.Primary.Wait, false, finishFire)
end

function SWEP:PrimaryShootEmpty()
	if SERVER then self:PlaySnd(self.Primary.SoundEmpty, true, CHAN_AUTO) end
	self:PlayAnim("dryfire", self.Primary.Wait, false, finishFire)
end

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.AimHold = "revolver"
SWEP.ZoomPos = Vector(1, -2.0014, 3.7604)
SWEP.RHandPos = Vector(0, 0, 1)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.2, -0.4, 0), Angle(-0.4, 0.4, 0)}
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 60
SWEP.Ergonomics = 0.85
SWEP.OpenBolt = true
SWEP.Penetration = 16
SWEP.punchmul = 6
SWEP.punchspeed = 0.45
SWEP.podkid = 12

function SWEP:PostFireBullet(bullet)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() or (owner.posture ~= 7 and owner.posture ~= 8) then return end
	if math.random(3) ~= 1 then return end

	local force = -bullet.Dir * bullet.Force
	local pos = self:WorldModel_Transform(true)
	timer.Simple(0.05, function()
		if not IsValid(self) or not IsValid(owner) or owner:GetActiveWeapon() ~= self then return end
		owner:DropWeapon(self, nil, force)
		self:SetPos(pos)
		local hands = owner:GetWeapon("weapon_hands_sh")
		if IsValid(hands) then owner:SelectWeapon("weapon_hands_sh") end

		local org = owner.organism
		if not org or not hg.organism or not hg.organism.input_list then return end
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(0.8)
		dmgInfo:SetDamageType(DMG_CLUB)
		hg.organism.input_list.rarmdown(org, 1, dmgInfo:GetDamage(), dmgInfo, owner:LookupBone("ValveBiped.Bip01_R_Forearm"), vector_up)
	end)
end

SWEP.WorldPos = Vector(4.5, -1.6, -1.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 25
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, -1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.RHPos = Vector(12, -5, 4)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)

if CLIENT then
	local loaded = {"sw500-loaded3", "sw500-loaded4", "sw500-loaded2", "sw500-loaded1"}
	local shells = {"sw500-shell1", "sw500-shell2", "sw500-shell4", "sw500-shell3", "sw500-shell5"}
	local full = Vector(1, 1, 1)
	local boneTime = CreateClientConVar("hg_m500_bone_time", "0.31", true, false, "M500 reload bone switch time", 0.15, 1.1)
	local boneReturn = CreateClientConVar("hg_m500_bone_return", "0.90", true, false, "M500 reload bone return time", 0.15, 1.1)
	local loaderEnd = CreateClientConVar("hg_m500_loader_end", "0.90", true, false, "M500 reload loader hide time", 0.15, 1.1)

	local function getReloadPart(wep)
		if not wep.reload or not wep.StaminaReloadTime or wep.StaminaReloadTime <= 0 then return end
		return 1.15 - (wep.reload - 0.05 - CurTime()) / wep.StaminaReloadTime
	end

	local function getBoneStage(part)
		if not part then return 1 end
		local start = boneTime:GetFloat()
		local finish = boneReturn:GetFloat()
		local stage = (part < start or part >= finish) and 1 or 0
		if part >= start and part < finish then stage = stage + 2 end
		if part >= start and part < loaderEnd:GetFloat() then stage = stage + 4 end
		return stage
	end

	local function setBones(model, stage)
		if model.boneStage == stage then return end
		model.boneStage = stage

		for _, name in ipairs(loaded) do
			local bone = model:LookupBone(name)
			if bone then model:ManipulateBoneScale(bone, bit.band(stage, 2) ~= 0 and full or vector_origin) end
		end
		local loader = model:LookupBone("sw500-loader")
		if loader then model:ManipulateBoneScale(loader, bit.band(stage, 4) ~= 0 and full or vector_origin) end
		for _, name in ipairs(shells) do
			local bone = model:LookupBone(name)
			if bone then model:ManipulateBoneScale(bone, bit.band(stage, 1) ~= 0 and full or vector_origin) end
		end
	end

	function SWEP:ModelCreated(model)
		setBones(model, 1)
	end

	function SWEP:DrawPost()
		local model = self:GetWM()
		if not IsValid(model) then return end

		setBones(model, getBoneStage(getReloadPart(self)))
	end

	concommand.Add("hg_m500_bones", function()
		local frame = vgui.Create("DFrame")
		frame:SetTitle("M500 reload bones")
		frame:SetSize(480, 545)
		frame:Center()
		frame:MakePopup()
		frame:DockPadding(12, 28, 12, 12)

		local function getWep()
			local wep = LocalPlayer():GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "weapon_revolverm500" then return wep end
		end

		local progress = vgui.Create("DLabel", frame)
		progress:Dock(TOP)
		progress:SetTall(24)
		progress.Think = function(self)
			local wep = getWep()
			local part = wep and getReloadPart(wep)
			self:SetText(part and string.format("Reload timeline: %.2f", part) or "Reload timeline: idle")
		end

		local preview = vgui.Create("DModelPanel", frame)
		preview:Dock(TOP)
		preview:SetTall(260)
		preview:SetModel("models/weapons/c_ins2_revolver_sw500.mdl")
		preview:SetFOV(55)
		if IsValid(preview.Entity) then
			local seq = preview.Entity:LookupSequence("base_reload_speed")
			if seq >= 0 then preview.Entity:SetSequence(seq) end
		end
		preview.LayoutEntity = function() end
		preview.PaintOver = function(self, w, h)
			if IsValid(self.Entity) and self.Entity:LookupBone("sw500-gun") then return end
			draw.SimpleText("M500 model unavailable", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local slider = vgui.Create("DNumSlider", frame)
		slider:Dock(TOP)
		slider:SetTall(40)
		slider:SetText("Show loaded at")
		slider:SetMinMax(0.15, 1.1)
		slider:SetDecimals(2)
		slider:SetConVar("hg_m500_bone_time")

		local loaderSlider = vgui.Create("DNumSlider", frame)
		loaderSlider:Dock(TOP)
		loaderSlider:SetTall(40)
		loaderSlider:SetText("Hide loader at")
		loaderSlider:SetMinMax(0.15, 1.1)
		loaderSlider:SetDecimals(2)
		loaderSlider:SetConVar("hg_m500_loader_end")

		local returnSlider = vgui.Create("DNumSlider", frame)
		returnSlider:Dock(TOP)
		returnSlider:SetTall(40)
		returnSlider:SetText("Return shells at")
		returnSlider:SetMinMax(0.15, 1.1)
		returnSlider:SetDecimals(2)
		returnSlider:SetConVar("hg_m500_bone_return")

		local scrub = vgui.Create("DNumSlider", frame)
		scrub:Dock(TOP)
		scrub:SetTall(40)
		scrub:SetText("Preview timeline")
		scrub:SetMinMax(0.15, 1.1)
		scrub:SetDecimals(2)
		scrub:SetValue(0.15)
		preview.Think = function(self)
			local model = self.Entity
			if not IsValid(model) then return end
			local part = scrub:GetValue()
			model:SetCycle(math.Clamp(part - 0.15, 0, 1))
			model:SetupBones()
			local bone = model:LookupBone("sw500-gun")
			if bone then
				local pos = model:GetBonePosition(bone)
				self:SetLookAt(pos)
				self:SetCamPos(pos + Vector(22, 24, 13))
			end
			setBones(model, getBoneStage(part))
		end

		local reset = vgui.Create("DButton", frame)
		reset:Dock(BOTTOM)
		reset:SetText("Reset timings")
		reset.DoClick = function()
			RunConsoleCommand("hg_m500_bone_time", "0.31")
			RunConsoleCommand("hg_m500_loader_end", "0.90")
			RunConsoleCommand("hg_m500_bone_return", "0.90")
			slider:SetValue(0.31)
			loaderSlider:SetValue(0.90)
			returnSlider:SetValue(0.90)
		end
	end)
end
