SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MP-18"
SWEP.Author = ""
SWEP.Instructions = "Single-shot break action rifle chambered in 7.62x54R"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl" -- Оставил как есть
SWEP.WorldModelFake = "models/weapons/c_mp18.mdl"
SWEP.WorldModelReal = "models/weapons/c_mp18.mdl"

SWEP.FakePos = Vector(-12, 2.6, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "011101"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "011101"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30



SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mp18.png")
SWEP.IconOverride = "entities/arc9_eft_mp18.png"

SWEP.LocalMuzzlePos = Vector(20, -0.66, 7)
SWEP.LocalMuzzleAng = Angle(1, -0.2, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "762x54" -- СВД патрон

SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject" -- Можно оставить, но MP-18 выбрасывает гильзу при переломе
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

-- Характеристики
SWEP.Primary.ClipSize = 1 -- ОДНОЗАРЯДКА!
SWEP.Primary.DefaultClip = 1 -- Запас
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x54 mm" -- В оригинале 7.62x54R
SWEP.Primary.Damage = 105
SWEP.Primary.Force = 105
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
-- Звуки выстрела (MP-18)
SWEP.Primary.Sound = {"weapons/darsu_eft/mp18/mr18_fire_close.ogg", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/mp18/mr18_fire_indoor_close.ogg", 65, 100, 100} -- Или заменить на сайленс, если есть
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1

SWEP.availableAttachments = {
    barrel = {
        [1] = {"", Vector(7.3, 0.1, 0), {}},
    },
    sight = {
        ["mountType"] = "",
        ["mount"] = Vector(-22, 1.8, 0),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.8163, 5.0808)
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

-- СПИСОК АНИМАЦИЙ
SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw_empty",
    ["holster"] = "holster",
    ["holster_empty"] = "holster_empty",
    ["ready"] = "draw", -- Нет отдельного болта, используем draw как заглушку
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry",
    ["cycle"] = "idle", -- Нет цикла затвора
    ["reload"] = "reload", -- Единственная перезарядка
    ["reload_empty"] = "reload", -- Такая же
    ["inspect"] = "inspect0",
    ["inspect_empty"] = "inspect0",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

-- ПУТЬ К ЗВУКАМ MP-18
local path = "weapons/darsu_eft/mp18/"

SWEP.AnimsSounds = {
    ["draw"] = {
        [0.05] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["holster"] = {
        [0.05] = function(self) self:EmitSound("arc9_eft_shared/weap_out.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.ogg") end,
    },
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize
end

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "011101") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end self:GetWM():SetBodyGroups(new) end

function SWEP:InitializePost() 
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
end

function SWEP:AnimationPost() local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1); local sin = 1 - animpos; if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end; sin = sin * 2; sin = math.ease.InOutSine(sin); if sin > 0 then self.LHPos[1] = 18 - sin * 6; self.RHPos[1] = 1 - sin * 4; self.inanim = true else self.inanim = nil end; local wep = self:GetWeaponEntity(); if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:PrimaryShootPost()
    -- Однозарядка: после выстрела патрона нет
    -- self.drawBullet = false (это дефолт, ничего делать не надо)
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    -- Фикс бесконечной перезарядки
    if self:Clip1() >= self.Primary.ClipSize then return end

    -- Однозарядка: болт не нужен, сразу перезарядка

    if not self:CanReload() then return end

    if SERVER then
        local animName = "reload" -- Всегда одна анимация
        
        local animSpeed = 4 -- Нормальная скорость
        
        -- Тайминги (примерно из ARC9, анимация долгая ~5с)
        local reloadTime = 4.0
        
        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        
        local wep = self
        
        self:PlayAnim(animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end
            
            local ammoType = wep:GetPrimaryAmmoType()
            local availableAmmo = wep:GetOwner():GetAmmoCount(ammoType)
            
            if availableAmmo > 0 then
                wep:GetOwner():RemoveAmmo(1, ammoType)
                wep:SetClip1(1) -- Всегда 1 патрон
            end
            
            wep:SetNetVar("shootgunReload", 0)
            
            -- Фикс первого выстрела
            wep.drawBullet = true
            net.Start("hgwep draw")
                net.WriteEntity(wep)
                net.WriteBool(true)
                net.WriteFloat(CurTime() - 10) 
            net.Broadcast()
        end, false, true)
        
        -- ЗВУКИ ПЕРЕЗАРЯДКИ (MP-18)
        -- lock 0.89, open 0.97, out 1.92, in 3.41, close 4.35
        timer.Simple(0.59, function() if IsValid(wep) then wep:EmitSound(path .. "mr18_barrel_lock.ogg") end end)
        timer.Simple(0.77, function() if IsValid(wep) then wep:EmitSound(path .. "mr18_barrel_open.ogg") end end)
        timer.Simple(1.42, function() if IsValid(wep) then wep:EmitSound(path .. "mr18_round_out1.ogg") end end)
        timer.Simple(2.21, function() if IsValid(wep) then wep:EmitSound(path .. "mr18_round_in1.ogg") end end)
        timer.Simple(3.15, function() if IsValid(wep) then wep:EmitSound(path .. "mr18_barrel_close.ogg") end end)
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

