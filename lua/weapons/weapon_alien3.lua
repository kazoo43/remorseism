--ByLazzy
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Pulse Rifle MK2"
SWEP.Author = "Alien 3"
SWEP.Instructions = "99 Rounds. Kill them all."
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = "" -- Используем FakeWM
SWEP.WorldModel = "models/weapons/w_m41a.mdl"

-- ВАЖНО: Сюда нужно вписать путь к модели от ПЕРВОГО ЛИЦА (c_m41a.mdl или v_m41a.mdl)
-- Если у тебя нет c_ модели, оставь w_, но анимации могут выглядеть странно
SWEP.WorldModelFake = "models/weapons/v_pulseriflemk2.mdl" 
SWEP.WorldModelReal = "models/weapons/v_pulseriflemk2.mdl"

-- Настройки позиционирования (Подгони через swep_pos_editor!)
SWEP.FakePos = Vector(-15, -1, 1) 
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.FakeBodyGroups = "000000000"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "000000000"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

-- Фейковые звуки (для совместимости)
SWEP.FakeReloadSounds = {
    [0.25] = "sound/weapons/pulserifle/magout.ogg",
    [0.85] = "sound/weapons/pulserifle/magin.ogg",
}
SWEP.FakeEmptyReloadSounds = {
    [0.25] = "sound/weapons/pulserifle/magout.ogg",
    [0.85] = "sound/weapons/pulserifle/magin.ogg",
}

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl" -- Если есть модель магазина M41A, впиши сюда
SWEP.FakeReloadEvents = {}
SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arccw_pulseriflemk2.png")
SWEP.IconOverride = "entities/arccw_pulseriflemk2.png"

SWEP.LocalMuzzlePos = Vector(32,0,5.5)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "556x45"
SWEP.ReloadSound = "sound/weapons/pulserifle/magin.ogg"
SWEP.CockSound = "sound/weapons/pulserifle/struggle.ogg"
SWEP.weight = 3
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject" -- Поменял на Rifle
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

-- Характеристики
SWEP.Primary.ClipSize = 99
SWEP.Primary.DefaultClip = 99
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Damage = 40
SWEP.Primary.Force = 30
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
-- Звуки выстрела
SWEP.Primary.Sound = {"Weapon_M41A.FIRE", 75, 90, 100} -- Убедись что этот звук существует или замени на путь к файлу
SWEP.SupressedSound = {"Weapon_M41A.FIRE", 65, 90, 100}
SWEP.Primary.Wait = 0.03 -- 0.03 слишком быстро (это 2000 RPM), поставил ~660 RPM. Верни 0.03 если хочешь миниган.
SWEP.NumBullet = 1

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
-- Звуки доставания/убирания (Alien)
SWEP.DeploySnd = {"alien1.mp3", 55, 100, 110} 
SWEP.HolsterSnd = {"alien4.mp3", 55, 100, 110}

SWEP.HoldType = "ar2" -- Для Pulse Rifle лучше подходит AR2
SWEP.ZoomPos = Vector(-1, -3.3, 1)
SWEP.RHandPos = Vector(-2, 0, -5)
SWEP.LHandPos = Vector(5, -2, -0)
SWEP.Ergonomics = 1
SWEP.Penetration = 13
SWEP.WorldPos = Vector(10, -1, -4.3)
SWEP.WorldAng = Angle(0, 0, 0.5)
SWEP.attPos = Vector(3, 0.5, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(9, 9, 1)
SWEP.holsteredAng = Angle(-30, 180, 0)

-- СПИСОК АНИМАЦИЙ
SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle", 
    ["draw"] = "draw",
    ["draw_empty"] = "draw",
    ["holster"] = "holster",
    ["holster_empty"] = "holster",
    ["ready"] = "draw",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "idle",
    ["reload"] = "reload", -- Единственная анимация перезарядки
    ["reload_empty"] = "reload", -- Используем ту же, т.к. другой нет
    ["inspect"] = "idle", -- Если нет inspect
    ["toggle"] = "idle",
}

-- ПУТЬ К ЗВУКАМ
local pathPULSE = "sound/weapons/pulserifle"

-- Автоматические звуки анимаций (Draw, Fire)
SWEP.AnimsSounds = {
    ["draw"] = {
        [0.0] = function(self) self:EmitSound("alien1.mp3") end,
    },
    ["holster"] = {
        [0.0] = function(self) self:EmitSound("alien4.mp3") end,
    },
    ["fire"] = {
        -- Звук выстрела обычно обрабатывается в PrimaryAttack, но можно и тут
    },
}

SWEP.stupidgun = true

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "000000000") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end self:GetWM():SetBodyGroups(new) end
function SWEP:InitializePost() local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end; self.AnimStart_Insert = 0; self.AnimStart_Draw = 0 end
function SWEP:AnimationPost() 
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end
    sin = sin * 2
    sin = math.ease.InOutSine(sin)
    if sin > 0 then self.inanim = true else self.inanim = nil end
    local wep = self:GetWeaponEntity()
    if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(0, Vector(0, 0, sin * -3), false) end 
end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

SWEP.GunCamPos = Vector(0, -2, 0)
SWEP.GunCamAng = Angle(0, 0, 0)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

-- Автомат: просто сохраняем патрон
function SWEP:PrimaryShootPost()
    self.drawBullet = true
end

-- ПЕРЕЗАРЯДКА M41A
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
        local animName = "reload" -- У этого оружия только одна анимация перезарядки
        
        local animSpeed = 2.5
        
        -- Тайминг анимации (судя по звукам 32 кадра / 30 = ~1.1 сек)
        -- Но лучше дать чуть больше времени
        local reloadTime = 2.0 
        
        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        
        local wep = self
        
        -- Старт Loop звука ("alien3.mp3")
        wep:EmitSound("alien3.mp3", 70, 100, 0.85, CHAN_STATIC)
        
        self:PlayAnim(animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end
            
            -- Стоп Loop звука
            wep:StopSound("alien3.mp3")
            
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
            wep.drawBullet = true
            if isEmpty then
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10) 
                net.Broadcast()
            end
        end, false, true)
        
        -- ЗВУКИ ПЕРЕЗАРЯДКИ (Тайминги из твоего описания: 5/30, 27.5/30, 32.5/30)
        -- magout = 0.16s
        -- struggle = 0.91s
        -- magin = 1.08s
        timer.Simple(0.16, function() if IsValid(wep) then wep:EmitSound(pathPULSE .. "magout.ogg") end end)
        timer.Simple(0.91, function() if IsValid(wep) then wep:EmitSound(pathPULSE .. "struggle.ogg") end end)
        timer.Simple(1.08, function() if IsValid(wep) then wep:EmitSound(pathPULSE .. "magin.ogg") end end)
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
    Angle(-15, 25, 5),
    Angle(-15, 25, 24),
    Angle(-15, 24, 26),
    Angle(-16, 26, 25),
    Angle(-15, 24, 26),
    Angle(-10, 25, -15),
    Angle(-2, 22, -15),
    Angle(0, 25, -22),
    Angle(0, 24, -45),
    Angle(0, 22, -45),
    Angle(0, 20, -35),
    Angle(0, 0, 0)
}