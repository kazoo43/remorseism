SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "ASH-12"
SWEP.Author = "Izhmash TsKIB SOO"
SWEP.Instructions = "12.7x55mm large-caliber assault rifle"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/shak_12/ash12/w_mk18.mdl"
SWEP.WorldModelFake = "models/weapons/c_ash12.mdl" -- Проверь путь!
SWEP.WorldModelReal = "models/weapons/c_ash12.mdl"

SWEP.FakePos = Vector(-15, 1, 4) -- Подбери в игре
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(3.5,-0.2,-0.05)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.FakeBodyGroups = "011111111" -- Подбери если нужно
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "011111111"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

-- Фейковые звуки (для совместимости)
SWEP.FakeReloadSounds = {
    [0.25] = "weapons/ak74/ak74_magout.wav",
    [0.85] = "weapons/ak74/ak74_magin.wav",
}

SWEP.FakeEmptyReloadSounds = {
    [0.25] = "weapons/ak74/ak74_magout.wav",
    [0.65] = "weapons/ak74/ak74_magin.wav",
}

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/tfa_pd2_ash12.png")
SWEP.IconOverride = "entities/tfa_pd2_ash12.png"

SWEP.LocalMuzzlePos = Vector(12,0,3)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "50cal"
SWEP.ReloadSound = "weapons/remington_870/870_shell_in_1.wav"
SWEP.CockSound = "pwb2/weapons/ithaca37stakeout/pump.wav"
SWEP.weight = 5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.ViewPunchDiv = 115

-- Характеристики
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12.7x55 mm"
SWEP.Primary.Damage = 70
SWEP.Primary.Force = 70
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
-- Звуки выстрела (ASH-12)
SWEP.Primary.Sound = {"weapons/darsu_eft/ash12/fire/ash12_outdoor_close_1.wav", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/ash12/fire/ash12_indoor_distant_loop_tail.wav", 65, 100, 100}
SWEP.Primary.Wait = 0.085 -- ~700 RPM
SWEP.NumBullet = 1

SWEP.availableAttachments = {
    sight = {
        ["mountType"] = "",
        ["mount"] = Vector(-12, 2, 0),
    }
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -3.4054, 4.4373)
SWEP.RHandPos = Vector(-32, -111, 14)
SWEP.LHandPos = Vector(37, -2, -2)
SWEP.Ergonomics = 1.0
SWEP.Penetration = 11
SWEP.WorldPos = Vector(5, -1, -2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 25

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(2, 3, 3)
SWEP.holsteredAng = Angle(215, 0, 180)

-- СПИСОК АНИМАЦИЙ

SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw",
    ["holster"] = "holster",
    ["holster_empty"] = "holster",
    ["ready"] = "ready",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["cycle"] = "bolt0",
    
    -- ИСПРАВЛЕННЫЕ ИМЕНА
    ["reload"] = "reload0", 
    ["reload_empty"] = "reload_empty0_0", -- Попробуй reload_empty0_0 если не сработает
    
    ["inspect"] = "inspect1",
    ["inspect_empty"] = "inspect1",
    ["toggle"] = "mod_switch",
}

-- ПУТЬ К ЗВУКАМ (ASH-12)
local path = "weapons/darsu_eft/ash12/"

SWEP.AnimsSounds = {
    ["ready"] = {
        [0.91] = function(self) self:EmitSound(path .. "ash12_bolt_handle_grab.ogg") end,
        [1.09] = function(self) self:EmitSound(path .. "ash12_bolt_out.ogg") end,
        [1.29] = function(self) self:EmitSound(path .. "ash12_bolt_in.ogg") end,
        [1.47] = function(self) self:EmitSound(path .. "ash12_bolt_handle_bounce.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound(path .. "ash12_trigger_hammer.wav") end,
        [0.02] = function(self) self:EmitSound(path .. "ash12_bolt_handle_bounce.ogg") end,
    },
}

SWEP.stupidgun = true

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "000000000") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end self:GetWM():SetBodyGroups(new) end
function SWEP:InitializePost() local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end; self.AnimStart_Insert = 0; self.AnimStart_Draw = 0 end
function SWEP:AnimationPost() local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1); local sin = 1 - animpos; if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end; sin = sin * 2; sin = math.ease.InOutSine(sin); if sin > 0 then self.LHPos[1] = 18 - sin * 6; self.RHPos[1] = 1 - sin * 4; self.inanim = true else self.inanim = nil end; local wep = self:GetWeaponEntity(); if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:PrimaryShootPost()
    self.drawBullet = true
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    if self:Clip1() >= self.Primary.ClipSize then return end

    local ammoType = self:GetPrimaryAmmoType()
    if self:GetOwner():GetAmmoCount(ammoType) <= 0 then return end

    if SERVER then
        local isEmpty = self:Clip1() <= 0
        local animName = isEmpty and "reload_empty" or "reload"
        
        -- Скорость анимации
        local animSpeed = 5
        
        -- Тайминги (примерно из конфига)
        -- reload_tactical: ~2.8с
        -- reload_empty: ~4.3с
        local reloadTime = isEmpty and 4.3 or 2.8
        
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
            
            wep.drawBullet = true
            if isEmpty then
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10) 
                net.Broadcast()
            end
        end, false, true)
        
        -- ЗВУКИ ПЕРЕЗАРЯДКИ (ASH-12)
        if isEmpty then
            -- reload_empty
            timer.Simple(0.03, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_1.ogg") end end) -- Заглушка, если gunflip нет
            timer.Simple(0.53, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_mag_out.ogg") end end) -- Быстрый сброс
            timer.Simple(1.95, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_mag_in.ogg") end end)
            -- Болт (из конфига reload_empty)
            timer.Simple(3.3, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_bolt_out.ogg") end end)
            timer.Simple(3.96, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_bolt_in.ogg") end end)
        else
            -- reload_tactical
            timer.Simple(0.03, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_1.ogg") end end) -- Заглушка
            timer.Simple(0.53, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_mag_out.ogg") end end) -- Быстрый сброс
            timer.Simple(2.9, function() if IsValid(wep) then wep:EmitSound(path .. "ash12_mag_in.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

SWEP.InspectAnimLH = { Vector(0, 0, 0) }
SWEP.InspectAnimLHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimRH = { Vector(0, 0, 0) }
SWEP.InspectAnimRHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimWepAng = {
    Angle(0, 0, 0),
    Angle(-5, 9, 5),
    Angle(-5, 9, 14),
    Angle(-5, 9, 16),
    Angle(-6, 10, 15),
    Angle(-5, 9, 16),
    Angle(-10, 15, -15),
    Angle(-2, 22, -15),
    Angle(0, 25, -32),
    Angle(0, 24, -45),
    Angle(0, 22, -55),
    Angle(0, 20, -56),
    Angle(0, 0, 0)
}