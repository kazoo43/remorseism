--ByLAZZY
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TKPD"
SWEP.Author = "Russia"
SWEP.Instructions = "Sniper rifle chambered in 7.62x51"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/c_tkpd.mdl"

SWEP.FakePos = Vector(-15, 1, 4)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(3.5,-0.2,-0.05)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.StartAtt = {"ironsight1"}

SWEP.ViewPunchDiv = 235
SWEP.FakeBodyGroups = "02111111114"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "02111111114"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"

SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_tkpd.png")
SWEP.IconOverride = "entities/arc9_eft_tkpd.png"
SWEP.LocalMuzzlePos = Vector(29.848,-3.5,2.552)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "762x51"
SWEP.weight = 3.5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.ViewPunchDiv = 115

-- Характеристики
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x54 mm"
SWEP.Primary.Damage = 95
SWEP.Primary.Force = 95
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0

-- Исправленные пути к звукам выстрела (SVDS)
SWEP.Primary.Sound = {"weapons/darsu_eft/svds/svd_fire_close.ogg", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/svds/svd_fire_silenced_close.ogg", 65, 100, 100}
SWEP.Primary.Wait = 0.45 
SWEP.NumBullet = 1

SWEP.availableAttachments = {
    barrel = {
        [1] = {"", Vector(-5, 0, 0), {}},
    },
    sight = {
        ["mountType"] = {"picatinny", "ironsight"},
        ["mount"] = Vector(-35, 2.2, 0.05),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, -3.3, 5.126)
SWEP.RHandPos = Vector(-8, -2, 6)
SWEP.LHandPos = Vector(6, -3, 1)
SWEP.Ergonomics = 0.85
SWEP.Penetration = 17
SWEP.WorldPos = Vector(5, -1.2, -1)
SWEP.WorldAng = Angle(0, 0, 0)
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
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["fire_empty"] = "fire_last",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry_empty",
    ["cycle"] = "bolt0",
    ["reload"] = "reload0",
    ["reload_empty"] = "reload_empty0_0",
    ["inspect"] = "look",
    ["inspect_empty"] = "look_empty",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

-- ИСПРАВЛЕННЫЙ ПУТЬ К ЗВУКАМ (SVDS)
local path = "weapons/darsu_eft/svds/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.67] = function(self) self:EmitSound(path .. "svd_slider_in.ogg") end,
        [1.02] = function(self) self:EmitSound(path .. "svd_slider_out.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.wav") end,
    },
    ["bolt0"] = {
        [0.24] = function(self) self:EmitSound(path .. "svd_slider_in.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "svd_slider_out.ogg") end,
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
        
        -- НЕ МЕНЯЕМ (как просил)
        local animSpeed = 5
        local reloadTime = isEmpty and 4.0 or 3.2
        
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
        
        -- ЗВУКИ (Оригинальные тайминги, чтобы влезть в 3.2/4.0 сек)
        if isEmpty then
            -- reload_empty0_0
            timer.Simple(0.68, function() if IsValid(wep) then wep:EmitSound(path .. "svd_mag_out.ogg") end end)
            timer.Simple(2.10, function() if IsValid(wep) then wep:EmitSound(path .. "svd_mag_in.ogg") end end)
            timer.Simple(3.45, function() if IsValid(wep) then wep:EmitSound(path .. "svd_slider_in.ogg") end end)
            timer.Simple(4.0, function() if IsValid(wep) then wep:EmitSound(path .. "svd_slider_out.ogg") end end)
        else
            -- reload0
            timer.Simple(0.50, function() if IsValid(wep) then wep:EmitSound(path .. "svd_mag_button.ogg") end end)
            timer.Simple(0.68, function() if IsValid(wep) then wep:EmitSound(path .. "svd_mag_out.ogg") end end)
            timer.Simple(2.9, function() if IsValid(wep) then wep:EmitSound(path .. "svd_mag_in.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

