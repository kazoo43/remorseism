--ByLAZZY
SWEP.Base = "weapon_mxlr"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AVT-40"
SWEP.Author = "Russia"
SWEP.Instructions = "Sniper rifle chambered in 7.62x54R"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl" -- РќРµРѕР±С…РѕРґРёРјРѕ Р·Р°РјРµРЅРёС‚СЊ WM
SWEP.WorldModelFake = "models/weapons/c_svt.mdl"


SWEP.FakePos = Vector(-15, 1, 4)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(3.5,-0.2,-0.05)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.FakeBodyGroups = "02111011111"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "02111011111"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30



SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_svt.png")
SWEP.IconOverride = "entities/arc9_eft_svt.png"

SWEP.LocalMuzzlePos = Vector(29.848,-0.027,2.552)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "762x54"

SWEP.weight = 3.5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true
SWEP.ViewPunchDiv = 115

-- РҐР°СЂР°РєС‚РµСЂРёСЃС‚РёРєРё
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Damage = 55
SWEP.Primary.Force = 55
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
-- Р—РІСѓРєРё РІС‹СЃС‚СЂРµР»Р° (SVD, С‚Р°Рє РєР°Рє Сѓ SVT РјРѕРіСѓС‚ Р±С‹С‚СЊ РїСЂРѕР±Р»РµРјС‹ СЃ РїСѓС‚СЏРјРё)
SWEP.Primary.Sound = {"weapons/darsu_eft/svt/fire/avt_outdoor_distant_loop2.wav", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/svt/fire/avt_outdoor_distant_loop2.wav", 65, 100, 100}
SWEP.Primary.Wait = 0.075
SWEP.NumBullet = 1

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor1", Vector(-5, 1, 0.2), {}},
    },
    sight = {
        ["mountType"] = {"dovetail",},
        ["mount"] = Vector(-35, 2.2, 0.),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, -3.3, 3.126)
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

-- РЎРџРРЎРћРљ РђРќРРњРђР¦РР™
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
    ["reload"] = "reload0", -- РСЃРїРѕР»СЊР·СѓРµРј reload0 РґР»СЏ РІСЃРµРіРѕ
    ["reload_empty"] = "reload_empty0", 
    ["inspect"] = "look",
    ["inspect_empty"] = "look_empty",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

-- РџРЈРўР¬ Рљ Р—Р’РЈРљРђРњ (AVT40/SKS)
local path = "weapons/darsu_eft/svt/"
local pathsks = "weapons/darsu_eft/sks/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.05] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
        [0.57] = function(self) self:EmitSound(pathsks .. "sks_slider_up.ogg") end,
        [0.83] = function(self) self:EmitSound(pathsks .. "sks_slider_down.ogg") end,
        [1.14] = function(self) self:EmitSound(path .. "m203_flip_2.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.wav") end,
    },
    ["bolt0"] = {
        [0.24] = function(self) self:EmitSound(pathsks .. "svd_slider_check_in.ogg") end,
        [0.55] = function(self) self:EmitSound(pathsks .. "svd_slider_check_out.ogg") end,
    },
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize
end

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "000000000") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end self:GetWM():SetBodyGroups(new) end
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
        local animName = "reload" 
        
        -- РќР• РњР•РќРЇР•Рњ (РєР°Рє РїСЂРѕСЃРёР»)
        local animSpeed = 4
        local reloadTime = isEmpty and 5.5 or 4.1
        
        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        
        local wep = self
        
        -- 1. РЎРјРµРЅР° РјР°РіР°Р·РёРЅР°
        self:PlayAnim(animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end
            
            if isEmpty then
                -- 2. Р‘РѕР»С‚ (Р·Р°РїСѓСЃРєР°РµРј СЃ РЅРѕСЂРјР°Р»СЊРЅРѕР№ СЃРєРѕСЂРѕСЃС‚СЊСЋ 1)
                wep:PlayAnim("ready", 1, false, function()
                    if not IsValid(wep) then return end
                    
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
                    net.Start("hgwep draw")
                        net.WriteEntity(wep)
                        net.WriteBool(true)
                        net.WriteFloat(CurTime() - 10) 
                    net.Broadcast()
                end, false, true)
                
                           -- Р—РІСѓРєРё Р±РѕР»С‚Р° (Р·Р°РїСѓСЃРєР°СЋС‚СЃСЏ СЃСЂР°Р·Сѓ РїРѕСЃР»Рµ РЅР°С‡Р°Р»Р° Р°РЅРёРјР°С†РёРё ready)
                timer.Simple(0.2, function() if IsValid(wep) then wep:EmitSound(pathsks .. "sks_slider_up.ogg") end end)
                timer.Simple(0.6, function() if IsValid(wep) then wep:EmitSound(pathsks .. "sks_slider_down.ogg") end end)
                
            else
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
            end
        end, false, true)
        
           -- Р—РІСѓРєРё СЃРјРµРЅС‹ РјР°РіР°Р·РёРЅР°
        timer.Simple(0.5, function() if IsValid(wep) then wep:EmitSound(path .. "avt_magrelease_button_down.ogg") end end)
        timer.Simple(1.0, function() if IsValid(wep) then wep:EmitSound(path .. "avt_mag_out.ogg") end end)
        timer.Simple(2.5, function() if IsValid(wep) then wep:EmitSound(path .. "avt_mag_in.ogg") end end) -- Р§СѓС‚СЊ СЂР°РЅСЊС€Рµ С‡РµРј 2.84
        timer.Simple(3.2, function() if IsValid(wep) then wep:EmitSound(path .. "avt_magrelease_button_up.ogg") end end)
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end


