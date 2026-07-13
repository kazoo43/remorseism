--ByLAZZY
SWEP.Base = "weapon_mxlr"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "SV-98"
SWEP.Author = ""
SWEP.Instructions = "Sniper rifle chambered in 7.62x51"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_sv98.mdl"
SWEP.WorldModelReal = "models/weapons/c_sv98.mdl"

SWEP.FakePos = Vector(-11, 3.6, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "01011"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "01011"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30



SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_sv98.png")
SWEP.IconOverride = "entities/arc9_eft_sv98.png"

SWEP.LocalMuzzlePos = Vector(40, -0.66, 3.8)
SWEP.LocalMuzzleAng = Angle(1, -0.2, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "762x51"

SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Damage = 85 -- Высокий урон для снайперки
SWEP.Primary.Force = 85
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/sv98/sv98_fire_close.ogg", 80, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/sv98/sv98_fire_indoor_silenced_close.ogg", 65, 90, 100}

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor7", Vector(7.3, 0.1, 0), {}},
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-22, 1, 0),
    },
}

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1
SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.70, 4.5)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 18
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw_empty",
    ["holster"] = "holster",
    ["holster_empty"] = "holster_empty",
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry",
    ["cycle"] = "bolt0",
    ["reload"] = "reload",
    ["reload_empty"] = "reload_empty",
    ["inspect"] = "inspect0",
    ["inspect_empty"] = "inspect0",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

local path = "weapons/darsu_eft/sv98/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.67] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["ready1"] = {
        [0.67] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["ready2"] = {
        [0.67] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["draw_empty"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["holster"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_out.ogg") end,
    },
    ["holster_empty"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_out.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.ogg") end,
    },
    ["fire_dry"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.ogg") end,
    },
    ["bolt0"] = {
        [0.24] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["bolt1"] = {
        [0.24] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["bolt2"] = {
        [0.24] = function(self) self:EmitSound(path .. "sv98_boltout.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "sv98_boltin.ogg") end,
    },
    ["look"] = {
        [0.3] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin1.ogg") end,
        [1.41] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin2.ogg") end,
        [2.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin3.ogg") end,
    },
    ["look_empty"] = {
        [0.3] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin1.ogg") end,
        [1.41] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin2.ogg") end,
        [2.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_rifle_spin3.ogg") end,
    },
    ["mod_switch"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weapon_light_switcher1.ogg") end,
    },
    ["mod_switch_empty"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weapon_light_switcher1.ogg") end,
    },
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize and self.drawBullet == true
end

function SWEP:AnimHoldPost()
end

function SWEP:ModelCreated(model)
    model:SetBodyGroups(self:GetRandomBodygroups() or "000000000")
end

function SWEP:PostSetupDataTables()
    self:NetworkVar("String", 0, "RandomBodygroups")
    if CLIENT then
        self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged)
    end
end

function SWEP:OnVarChanged(name, old, new)
    if not IsValid(self:GetWM()) then return end
    self:GetWM():SetBodyGroups(new)
end

function SWEP:InitializePost()
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
end

function SWEP:AnimationPost()
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then
        sin = 1 - sin
    else
        sin = sin * 1
    end
    sin = sin * 2
    sin = math.ease.InOutSine(sin)

    if sin > 0 then
        self.LHPos[1] = 18 - sin * 6
        self.RHPos[1] = 1 - sin * 4
        self.inanim = true
    else
        self.inanim = nil
    end

    local wep = self:GetWeaponEntity()
    if CLIENT and IsValid(wep) then
        wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false)
    end
end

function SWEP:GetAnimPos_Insert(time)
    return 0
end

function SWEP:GetAnimPos_Draw(time)
    return 0
end

local function cock(self, time)
    if SERVER then
        self:Draw(true)
    end

    if self:Clip1() == 0 then
        self.drawBullet = nil
    end

    if CLIENT and LocalPlayer() == self:GetOwner() then return end

    net.Start("hgwep draw")
        net.WriteEntity(self)
        net.WriteBool(self.drawBullet)
        net.WriteFloat(CurTime())
    net.Broadcast()

    self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
    self.reloadCoolDown = CurTime() + time
end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)

local vector_full = Vector(1, 1, 1)

SWEP.FakeEjectBrassATT = "2"

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    -- Блокировка, если магазин полон (исправляет бесконечную анимацию при зажатом R)
    if self:Clip1() >= self.Primary.ClipSize then return end

    -- Передёргивание затвора (быстрый болт)
    if self.drawBullet == false and SERVER then
        self:PlayAnim(self.AnimList["cycle"] or "bolt0", 1, false, nil, false, true)
        
        local boltTime = 0.6
        self.reloadCoolDown = CurTime() + boltTime
        cock(self, boltTime)
        
        local wep = self
        timer.Simple(0.24, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_boltout.ogg") end end)
        timer.Simple(0.55, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_boltin.ogg") end end)
        return
    end

    if not self:CanReload() then return end

    if SERVER then
        local isEmpty = self:Clip1() == 0
        local animName = isEmpty and "reload_empty" or "reload"
        
        local animSpeed = 4
        local reloadTime = isEmpty and 3.8 or 2.8
        
        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        
        local wep = self
        
        self:PlayAnim(self.AnimList[animName] or animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end
            
            local ammoType = wep:GetPrimaryAmmoType()
            local currentClip = wep:Clip1()
            local maxClip = wep.Primary.ClipSize
            local neededAmmo = maxClip - currentClip
            local availableAmmo = wep:GetOwner():GetAmmoCount(ammoType)
            local ammoToLoad = math.min(neededAmmo, availableAmmo)
            
            if ammoToLoad > 0 then
                wep:GetOwner():RemoveAmmo(ammoToLoad, ammoType)
                wep:SetClip1(currentClip + ammoToLoad)
            end
            
            wep:SetNetVar("shootgunReload", 0)
            
            -- Синхронизация патрона
            if wep:Clip1() > 0 then
                wep.drawBullet = true
                -- Отправляем draw в прошлом, чтобы клиент знал что патрон есть,
                -- но не запускал анимацию доставания (CurTime() - 10)
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10) 
                net.Broadcast()
            end
        end, false, true)
        
        -- Звуки с таймингами * 4
        if isEmpty then
            timer.Simple(0.16, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_mag_out.ogg") end end)
            timer.Simple(1.40, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_mag_in.ogg") end end)
            timer.Simple(2.64, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_boltout.ogg") end end)
            timer.Simple(2.96, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_boltin.ogg") end end)
        else
            timer.Simple(0.32, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_mag_out.ogg") end end)
            timer.Simple(1.84, function() if IsValid(wep) then wep:EmitSound(path .. "sv98_mag_in.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

