--ByLAZZY
SWEP.Base = "weapon_mxlr"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "VPO-215"
SWEP.Author = ""
SWEP.Instructions = "Sniper rifle chambered in .366 TKM"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_vpo215.mdl"
SWEP.WorldModelReal = "models/weapons/c_vpo215.mdl"

SWEP.FakePos = Vector(-11, 2.5, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "0111111"
SWEP.CantFireFromCollision = true

-- Пресет бодигрупп
SWEP.FakeBodyGroupsPresets = {
    "0111111",
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_vpo215.png")
SWEP.IconOverride = "entities/arc9_eft_vpo215.png"

SWEP.LocalMuzzlePos = Vector(20, -0.66, 7)
SWEP.LocalMuzzleAng = Angle(1, -0.2, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "762x51"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

-- Характеристики
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x39 mm"  -- ИЗМЕНЕНО
SWEP.Primary.Damage = 65 
SWEP.Primary.Force = 65
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/vpo215/vpo215_fire_close.ogg", 80, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/vpo215/vpo215_fire_silenced_close.ogg", 65, 90, 100}
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1

-- АТТАЧМЕНТЫ (ИЗМЕНЕНО)
SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor7", Vector(8.3, 0.1, 0), {}},
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-18, 1, -0.05),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.8, 4.5)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.6
SWEP.Penetration = 15
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- ИСПРАВЛЕННЫЙ СПИСОК АНИМАЦИЙ ДЛЯ VPO-215
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
    ["reload"] = "reload0", -- Source = "reload0"
    ["reload_empty"] = "reload_empty0", -- Source = "reload_empty0"
    ["inspect"] = "look",
    ["inspect_empty"] = "look_empty",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

-- ПУТЬ К ЗВУКАМ VPO-215
local path = "weapons/darsu_eft/vpo215/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.67] = function(self) self:EmitSound(path .. "vpo215_boltout.ogg") end,
        [1.05] = function(self) self:EmitSound(path .. "vpo215_boltin.ogg") end,
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
        [0.24] = function(self) self:EmitSound(path .. "vpo215_boltout.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "vpo215_boltin.ogg") end,
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

    -- Фикс бесконечной перезарядки
    if self:Clip1() >= self.Primary.ClipSize then return end

    -- Передёргивание затвора
    if self.drawBullet == false and SERVER then
        -- СКОРОСТЬ БОЛТА: 1 = Нормальная
        self:PlayAnim(self.AnimList["cycle"] or "bolt0", 1, false, nil, false, true)
        
        local boltTime = 1.2
        self.reloadCoolDown = CurTime() + boltTime
        cock(self, boltTime)
        
        local wep = self
        -- Звуки болта (rem700, так как они в конфиге)
        timer.Simple(0.13, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_1.ogg") end end)
        timer.Simple(0.35, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_2.ogg") end end)
        timer.Simple(0.70, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_3.ogg") end end)
        timer.Simple(0.92, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_4.ogg") end end)
        return
    end

    if not self:CanReload() then return end

    if SERVER then
        local isEmpty = self:Clip1() == 0
        local animName = isEmpty and "reload_empty" or "reload"
        
        -- СКОРОСТЬ ПЕРЕЗАРЯДКИ: 4 = Медленная (замедляет в 4 раза)
        local animSpeed = 4
        
        -- Тайминги (примерно как в ARC9 конфиге, ~3-4 сек)
        local reloadTime = isEmpty and 4.0 or 3.0
        
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
            
            -- Фикс первого выстрела
            if wep:Clip1() > 0 then
                wep.drawBullet = true
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10) 
                net.Broadcast()
            end
        end, false, true)
        
        -- Звуки перезарядки (rem700 по конфигу)
        if isEmpty then
            -- Полная: Out 0.36, In 2.0, BoltBack 2.6, BoltFwd 3.4
            timer.Simple(0.36, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_mag_out.ogg") end end)
            timer.Simple(1.30, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_mag_in.ogg") end end)
            timer.Simple(2.10, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_1.ogg") end end)
            timer.Simple(2.60, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_bolt_4.ogg") end end)
        else
            -- Тактическая: Out 0.5, In 2.3
            timer.Simple(0.50, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_mag_out.ogg") end end)
            timer.Simple(2.65, function() if IsValid(wep) then wep:EmitSound(path .. "rem700_mag_in.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

